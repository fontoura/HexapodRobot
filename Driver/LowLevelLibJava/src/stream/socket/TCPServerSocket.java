package stream.socket;

import java.io.IOException;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;

import concurrent.semaphore.Semaphore;
import concurrent.time.Stoptimer;

public class TCPServerSocket {
	private int m_port;
	private ServerSocketChannel m_channel;
	private Semaphore m_mutex;

	private TCPServerSocket(int port, ServerSocketChannel channel) {
		m_port = port;
		m_channel = channel;
		m_mutex = Semaphore.create(1, 1);
	}

	@Override
	protected void finalize() throws Throwable {
		this.close();
		super.finalize();
	}

	public TCPSocketStream accept() {
		TCPSocketStream stream = null;

		// entra na região crítica.
		m_mutex.down();
		ServerSocketChannel channel = m_channel;

		if (channel != null) {
			// define modo assíncrono para o canal.
			try {
				channel.configureBlocking(true);
			} catch (IOException e) {
				channel = null;
			}
			if (channel != null) {
				// tenta aceitar uma conexão.
				SocketChannel socket = null;
				boolean error = false;
				try {
					socket = m_channel.accept();
				} catch (IOException e) {
					error = true;
				}
				if (null != socket) {
					try {
						socket.configureBlocking(false);
					} catch (IOException e) {
						try {
							socket.close();
						} catch (IOException e2) {}
						socket = null;
						error = true;
					}
				}

				if (error) {
					// se houve erro ao tentar aceitar a conexão, aborta.
					m_channel = null;
				} else {
					// se aceitou uma conexão, cria um fluxo de socket e interrompe.
					stream = new TCPSocketStream(socket);
				}
			}
		}

		// sai da região crítica.
		m_mutex.up();

		// retorna o fluxo de socket criado (ou null).
		return stream;
	}

	public TCPSocketStream accept(long timeout) {
		TCPSocketStream stream = null;

		// entra na região crítica.
		m_mutex.down();
		ServerSocketChannel channel = m_channel;

		if (channel != null) {
			// define modo assíncrono para o canal.
			try {
				channel.configureBlocking(false);
			} catch (IOException e) {
				channel = null;
			}

			// cria um cronômetro para medir o tempo desde o começo da operação.
			Stoptimer timer = new Stoptimer();

			// enquanto não atingir o tempo limite...
			do {
				// se o canal for inválido, aborta.
				if (null == channel) {
					break;
				}

				// tenta aceitar uma conexão.
				SocketChannel socket = null;
				boolean error = false;
				try {
					socket = m_channel.accept();
				} catch (IOException e) {
					error = true;
				}
				if (null != socket) {
					try {
						socket.configureBlocking(false);
					} catch (IOException e) {
						try {
							socket.close();
						} catch (IOException e2) {}
						socket = null;
						error = true;
					}
				}

				// se houve erro ao tentar aceitar a conexão, aborta.
				if (error) {
					m_channel = null;
					break;
				}

				if (null != socket) {
					// se aceitou uma conexão, cria um fluxo de socket e
					// interrompe.
					stream = new TCPSocketStream(socket);
					break;
				} else {
					// do contrário, espera 5 ms.
					try {
						Thread.sleep(5);
					} catch (InterruptedException e) {}
				}

				// atualiza o canal.
				channel = m_channel;
			} while (timer.getMilliseconds() < timeout);
		}

		// sai da região crítica.
		m_mutex.up();

		// retorna o fluxo de socket criado (ou null).
		return stream;

	}

	public boolean close() {
		ServerSocketChannel channel = m_channel;
		m_channel = null;
		if (null != channel) {
			try {
				channel.close();
			} catch (IOException e) {
				return false;
			}
		}
		return true;
	}

	public int getPort() {
		return m_port;
	}

	/**
	 * Creates a TCP server socket bound to a certain port.
	 * @param port
	 * @return
	 */
	public static TCPServerSocket create(int port) {
		InetAddress localAddress = null;
		InetSocketAddress serverAddress = null;
		ServerSocketChannel channel = null;
		boolean success;
		try {
			localAddress = InetAddress.getLocalHost();
			serverAddress = new InetSocketAddress(port);
			channel = ServerSocketChannel.open();
			channel.socket().bind(serverAddress);
			success = true;
		} catch (IOException e) {
			success = false;
		}

		if (success) {
			return new TCPServerSocket(port, channel);
		} else {
			if (null != localAddress) {
				localAddress = null;
			}
			if (null != serverAddress) {
				serverAddress = null;
			}
			if (null != channel) {
				try {
					channel.close();
				} catch (Exception e) {}
				channel = null;
			}
			return null;
		}
	}
}
