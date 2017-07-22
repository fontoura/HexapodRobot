package stream.socket;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.SocketChannel;

import stream.Stream;

public class TCPSocketStream implements Stream {
	private SocketChannel m_channel;
	private Selector m_selector;
	private long m_relativeTimeout;
	private long m_absoluteTimeout;

	protected TCPSocketStream(SocketChannel channel) {
		this.m_channel = channel;
	}

	public static final TCPSocketStream open(String host, int port) {
		SocketAddress address = new InetSocketAddress(host, port);
		SocketChannel channel = null;
		try {
			channel = SocketChannel.open(address);
			channel.configureBlocking(false);
		} catch (Exception e) {
			if (null != channel) {
				try {
					channel.close();
				} catch (IOException e2) {
				}
				channel = null;
			}
		}
		if (null == channel)
			return null;
		return new TCPSocketStream(channel);
	}

	@Override
	public boolean open() {
		return m_channel.isOpen();
	}

	@Override
	public boolean close() {
		try {
			m_channel.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
		try {
			m_selector.wakeup();
		} catch (Exception e) {
			e.printStackTrace();
			
		}
		return true;
	}

	@Override
	public boolean isOpen() {
		return m_channel.isOpen();
	}

	@Override
	public boolean setTimeouts(Timeouts timeouts) {
		m_absoluteTimeout = timeouts.absolute;
		m_relativeTimeout = timeouts.relative;
		return true;
	}

	@Override
	public void getTimeouts(Timeouts timeouts) {
		if (null != timeouts) {
			timeouts.absolute = m_absoluteTimeout;
			timeouts.relative = m_relativeTimeout;
		}
	}

	@Override
	public int read(byte[] buffer, int offset, int length) {
		if (length == 0) {
			return 0;
		}
		if (m_channel == null) {
			return 0;
		}

		// envolve os bytes em um buffer.
		ByteBuffer wrappedBuffer = ByteBuffer.wrap(buffer, offset, length);

		// contador de bytes lidos.
		int readSoFar = 0;

		// cria um seletor de canais de leitura.
		SelectionKey key = null;
		try {
			m_selector = Selector.open();
			key = m_channel.register(m_selector, SelectionKey.OP_READ);
		} catch (IOException e) {
			return 0;
		}

		while (length > 0) {
			if (m_channel == null) {
				break;
			}
			if (!m_channel.isOpen()) {
				break;
			}

			// determina se a operação sofre timeout e qual é ele.
			boolean hasTimeout;
			long timeout;
			if (readSoFar == 0) {
				if (m_absoluteTimeout >= 0) {
					timeout = m_absoluteTimeout;
					hasTimeout = true;
				} else {
					timeout = 0;
					hasTimeout = false;
				}
			} else {
				if (m_relativeTimeout >= 0) {
					timeout = m_relativeTimeout;
					hasTimeout = true;
				} else {
					timeout = 0;
					hasTimeout = false;
				}
			}

			// se tiver timeout, espera pelos dados.
			if (hasTimeout) {
				// verifica se recebe algo até o tempo limite.
				int result;
				try {
					m_selector.select(timeout);
					result = (m_selector.selectedKeys().contains(key)) ? 1 : 0;
				} catch (IOException e) {
					result = -1;
				}

				// se houver erro, fecha o socket e termina a operação.
				if (-1 == result) {
					this.close();
					break;
				}

				// se sofreu timeout, termina a operação.
				if (0 == result) {
					break;
				}
			} else {
				// espera até receber algo.
				int result;
				try {
					m_selector.select();
					result = (m_selector.selectedKeys().contains(key)) ? 1 : 0;
				} catch (IOException e) {
					result = -1;
				}

				// se houver erro, fecha o socket e termina a operação.
				if (-1 == result) {
					this.close();
					break;
				}

				// se sofreu timeout inesperadamente, vai para a próxima iteração.
				if (0 == result) {
					continue;
				}
			}

			// recebe efetivamente os dados.
			int readNow;
			try {
				readNow = m_channel.read(wrappedBuffer);
			} catch (IOException e) {
				readNow = -1;
			}

			// se houver erro, fecha o socket e termina a operação.
			if (0 == readNow || -1 == readNow) {
				this.close();
				break;
			}

			// avança a posição no buffer.
			length -= readNow;

			// contabiliza o número de bytes lidos.
			readSoFar += readNow;
		}

		// retorna o total de bytes lidos.
		return readSoFar;
	}

	@Override
	public int write(byte[] buffer, int offset, int length) {
		if (length == 0) {
			return 0;
		}
		if (m_channel == null) {
			return 0;
		}

		int result;
		try {
			result = m_channel.write(ByteBuffer.wrap(buffer, offset, length));
		} catch (IOException e) {
			result = 0;
			this.close();
		}
		return result;
	}
}
