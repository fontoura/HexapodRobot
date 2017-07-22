package protocol;

import global.Global;
import stream.Stream;
import stream.Stream.Timeouts;
import concurrent.semaphore.Semaphore;

/**
 * Classe definindo um canal de troca da mensagens.
 */
public class Channel {
	private static final void DEBUG(String message) {
		System.out.println(message);
		System.out.flush();
	}

	/**
	 * Enumeração de estados do canal.
	 *
	 */
	protected static enum ChannelStatus {
		/**
		 * Indica canal ainda não aberto.
		 */
		NotStarted,
		
		/**
		 * Indica canal aberto.
		 */
		Running,
		
		/**
		 * Indica canal fechado.
		 */
		Stopped
	};

	/**
	 * Estado atual do canal.
	 */
	private ChannelStatus m_status;

	/**
	 * Fluxo de dados sobre o qual o canal é construído.
	 */
	private Stream m_stream;

	/**
	 * Thread de recebimento de mensagens.
	 */
	private Thread m_receiveThread;

	/**
	 * Mutex para controlar operações de envio.
	 */
	private Semaphore m_sendMutex;

	/**
	 * Objeto com callback de recebimento de mensagem.
	 */
	private ChannelMessageCallback m_messageCallback;

	/**
	 * Objeto com callback de fechamento de canal.
	 */
	private ChannelClosedCallback m_closedCallback;

	/**
	 * Magic word do protocolo em uso.
	 */
	private int m_magicWord;

	/**
	 * Iimeout (em milissegundos) do recebimento de cada byte de uma mensagem.
	 */
	private long m_byteTimeout;

	protected Channel(Stream stream, int magicWord, long byteTimeout) {
		m_status = ChannelStatus.NotStarted;
		m_stream = stream;
		m_sendMutex = Semaphore.create(1, 1);
		m_magicWord = magicWord;
		m_byteTimeout = byteTimeout;
	}

	@Override
	protected void finalize() throws Throwable {
		this.stop();
		super.finalize();
	}

	public static Channel create(Stream stream, int magicWord, long byteTimeout) {
		return new Channel(stream, magicWord, byteTimeout);
	}

	public boolean send(Message message) {
		m_sendMutex.down();
		if (m_status == ChannelStatus.Running) {
			/*try {
				throw new Exception("DEBUG");
			} catch (Exception e) {
				e.printStackTrace(System.out);
				System.out.flush();
			}*/
			DEBUG("Enviando mensagem pelo MessageChannel...");
			byte[] header = new byte[16];
			Global.writeLittleEndian32(header, 0x0, m_magicWord);
			Global.writeLittleEndian16(header, 0x4, (short) message.getType());
			Global.writeLittleEndian16(header, 0x6, (short) message.getId());
			Global.writeLittleEndian16(header, 0x8, (short) message.getLength());
			short checksumHeader = Global.checksum16(header, 0, 0xa);
			short checksumBody = Global.checksum16(message.getBuffer(), 0, message.getLength());
			short checksumXor = (short)(checksumHeader ^ checksumBody);
			Global.writeLittleEndian16(header, 0xa, (short) checksumHeader);
			Global.writeLittleEndian16(header, 0xc, (short) checksumXor);
			Global.writeLittleEndian16(header, 0xe, (short) checksumBody);
			int written = m_stream.write(header, 0, 0x10);
			if (written == 0x10) {
				written = m_stream.write(message.getBuffer(), 0, message.getLength());
				if (written == message.getLength()) {
					DEBUG("Mensagem enviada com sucesso pelo MessageChannel...");
					m_sendMutex.up();
					return true;
				}
			}
		}
		DEBUG("Nao foi possivel enviar a mensagem pelo MessageChannel...");
		m_sendMutex.up();
		return false;
	}

	public void start() {
		m_sendMutex.down();
		if (m_status == ChannelStatus.NotStarted) {
			m_receiveThread = new Thread(new ChannelThreadBody(this));
			m_receiveThread.start();
			m_status = ChannelStatus.Running;
		}
		m_sendMutex.up();
	}

	public void stop() {
		m_sendMutex.down();
		if (m_status == ChannelStatus.Running) {
			m_stream.close();
			m_status = ChannelStatus.Stopped;
		}
		m_sendMutex.up();
	}

	public boolean isRunning() {
		return m_stream.isOpen();
	}

	public void join() {
		Thread thread = null;
		m_sendMutex.down();
		if (m_status != ChannelStatus.NotStarted) {
			thread = m_receiveThread;
		}
		m_sendMutex.up();
		if (null != thread) {
			try {
				thread.join();
			} catch (InterruptedException e) {
			}
		}
	}

	public ChannelMessageCallback getMessageCallback() {
		return m_messageCallback;
	}

	public void setMessageCallback(ChannelMessageCallback handler) {
		m_messageCallback = handler;
	}

	public ChannelClosedCallback getClosedCallback() {
		return m_closedCallback;
	}

	public void setClosedCallback(ChannelClosedCallback closedHandler) {
		m_closedCallback = closedHandler;
	}

	void receive() {
		Stream stream = m_stream;
		ChannelMessageCallback handler;
		Message message;
		while (stream.isOpen()) {

			// espera pela magic word.
			byte[] header = new byte[0x10];
			stream.setTimeouts(new Timeouts(-1, m_byteTimeout));
			int read = stream.read(header, 0, 0x10);
			stream.setTimeouts(new Timeouts(m_byteTimeout, m_byteTimeout));

			// verifica se recebeu tudo.
			if (read != 0x10) {
				DEBUG("Recebida mensagem com cabecalho muito curto pelo MessageChannel...");
				do {
					read = stream.read(header, 0, 1);
				} while (read > 0);
				continue;
			}

			// espera pelo corpo da mensagem.
			int magicWord = Global.readLittleEndian32(header, 0x0);
			short type = Global.readLittleEndian16(header, 0x4);
			short id = Global.readLittleEndian16(header, 0x6);
			short length = Global.readLittleEndian16(header, 0x8);
			short checksumHeader = Global.readLittleEndian16(header, 0xa);
			short checksumXor = Global.readLittleEndian16(header, 0xc);
			short checksumBody = Global.readLittleEndian16(header, 0xe);

			// verifica se a magic word está errada.
			if (magicWord != m_magicWord) {
				DEBUG("Recebida mensagem com Magic Word invalida pelo MessageChannel...");
				do {
					read = stream.read(header, 0, 1);
				} while (read > 0);
				continue;
			}

			// verifica se os checksums do cabeçalho batem.
			if (checksumXor != (short)(checksumBody ^ checksumHeader)) {
				DEBUG("Recebida mensagem com cabecalho inconsistente pelo MessageChannel...");
				do {
					read = stream.read(header, 0, 1);
				} while (read > 0);
				continue;
			}
			short calculatedChecksumHeader = Global.checksum16(header, 0, 0xa);
			if (checksumHeader != calculatedChecksumHeader) {
				DEBUG("Recebida mensagem com cabecalho corrompido pelo MessageChannel...");
				do {
					read = stream.read(header, 0, 1);
				} while (read > 0);
				continue;
			}

			// lê o corpo da mensagem.
			message = Message.create(type, length);
			message.setId(id);
			if (length > 0) {
				read = stream.read(message.getBuffer(), 0, length);
			} else {
				read = 0;
			}

			// verifica se leu o corpo da mensagem.
			if (read == length) {
				// verifica se o checksum é válido.
				short calculatedChecksumBody = Global.checksum16(message.getBuffer(), 0, message.getLength());
				if (calculatedChecksumBody == checksumBody) {
					handler = m_messageCallback;
					if (null != handler) {
						handler.onMessage(message);
						handler = null;
					}
				}
			}
			message = null;
		}
		ChannelClosedCallback closedHandler = m_closedCallback;
		m_closedCallback = null;
		if (closedHandler != null) {
			closedHandler.onMessageChannelClosed(this);
			closedHandler = null;
		}
		m_messageCallback = null;
	}
}
