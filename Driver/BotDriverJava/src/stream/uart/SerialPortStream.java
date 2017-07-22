package stream.uart;

import gnu.io.SerialPort;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import stream.Stream;
import concurrent.semaphore.Semaphore;

public class SerialPortStream implements Stream {
	protected String m_port;
	protected int m_baudRate;
	protected int m_byteSize;
	protected SerialPortStopBits m_stopBits;
	protected SerialPortParity m_parity;
	protected long m_absoluteTimeout;
	protected long m_relativeTimeout;
	private gnu.io.SerialPort m_rxtxPort;
	private Semaphore m_semaphore;

	private SerialPortStream(String port, int baudRate, int byteSize, SerialPortStopBits stopBits, SerialPortParity parity) {
		m_port = port;
		m_baudRate = baudRate;
		m_byteSize = byteSize;
		m_stopBits = stopBits;
		m_parity = parity;
		m_absoluteTimeout = 0;
		m_relativeTimeout = 0;
		m_semaphore = Semaphore.create(1, 1);
	}

	protected void finalize() throws Throwable {
		this.close();
	}

	public boolean open() {
		if (null != m_rxtxPort) {
			return true;
		}

		// tenta obter o identificador da porta.
		gnu.io.CommPortIdentifier identifier;
		try {
			identifier = gnu.io.CommPortIdentifier.getPortIdentifier(m_port);
		} catch (gnu.io.NoSuchPortException e) {
			return false;
		}

		// tenta abrir uma conexão com a porta.
		gnu.io.CommPort rxtxGenericPort;
		try {
			rxtxGenericPort = identifier.open("stream.usart.SerialStream", 100);
		} catch (gnu.io.PortInUseException e) {
			identifier = null;
			return false;
		}

		// verifica se a porta é serial.
		gnu.io.SerialPort rxtxPort;
		if (rxtxGenericPort instanceof gnu.io.SerialPort) {
			rxtxPort = (gnu.io.SerialPort) rxtxGenericPort;
			rxtxGenericPort = null;
		} else {
			rxtxGenericPort.close();
			rxtxGenericPort = null;
			identifier = null;
			return false;
		}

		// define os parametros.
		int dataBits;
		int stopBits;
		int parity;

		switch (m_byteSize) {
			case 5:
				dataBits = gnu.io.SerialPort.DATABITS_5;
				break;
			case 6:
				dataBits = gnu.io.SerialPort.DATABITS_6;
				break;
			case 7:
				dataBits = gnu.io.SerialPort.DATABITS_7;
				break;
			case 8:
				dataBits = gnu.io.SerialPort.DATABITS_8;
				break;
			default:
				rxtxPort.close();
				rxtxPort = null;
				identifier = null;
				return false;
		}
		switch (m_stopBits) {
			case STOPBITS_ONE:
				stopBits = gnu.io.SerialPort.STOPBITS_1;
				break;
			case STOPBITS_ONE_DOT_FIVE:
				stopBits = gnu.io.SerialPort.STOPBITS_1_5;
				break;
			case STOPBITS_TWO:
				stopBits = gnu.io.SerialPort.STOPBITS_2;
				break;
			default:
				rxtxPort.close();
				rxtxPort = null;
				identifier = null;
				return false;
		}
		switch (m_parity) {
			case PARITY_NONE:
				parity = gnu.io.SerialPort.PARITY_NONE;
				break;
			case PARITY_ODD:
				parity = gnu.io.SerialPort.PARITY_ODD;
				break;
			case PARITY_EVEN:
				parity = gnu.io.SerialPort.PARITY_EVEN;
				break;
			default:
				rxtxPort.close();
				rxtxPort = null;
				identifier = null;
				return false;
		}

		try {
			rxtxPort.setSerialPortParams(m_baudRate, dataBits, stopBits, parity);
			rxtxPort.setFlowControlMode(SerialPort.FLOWCONTROL_RTSCTS_OUT);
		} catch (gnu.io.UnsupportedCommOperationException e) {
			rxtxPort.close();
			rxtxPort = null;
			identifier = null;
			return false;
		}

		m_rxtxPort = rxtxPort;
		return true;
	}

	public boolean close() {
		if (null != m_rxtxPort) {
			m_rxtxPort.close();
			m_rxtxPort = null;
		}
		return true;
	}

	public boolean isOpen() {
		if (null != m_rxtxPort) {
			return true;
		} else {
			return false;
		}
	}

	public boolean setTimeouts(Timeouts timeouts) {
		m_absoluteTimeout = timeouts.absolute;
		m_relativeTimeout = timeouts.relative;
		return true;
	}

	public void getTimeouts(Timeouts timeouts) {
		timeouts.absolute = m_absoluteTimeout;
		timeouts.relative = m_relativeTimeout;
	}

	public int read(byte[] buffer, int offset, int length) {
		// determina a hora atual.
		long now = System.currentTimeMillis();

		// guarda o horário da última leitura e a quantidade de leituras.
		long lastTimestamp = now;
		int totalRead = 0;

		// inicia o ciclo de leitura.
		while (totalRead < length) {
			// obtém o fluxo.
			InputStream in;
			if (null != m_rxtxPort) {
				try {
					in = m_rxtxPort.getInputStream();
				} catch (IOException e) {
					in = null;
				}
			} else {
				in = null;
			}

			// aborta o ciclio, se a stream não puder ser obtida.
			if (null == in) {
				this.close();
				break;
			}

			// verifica se há caracteres prontos para leitura.
			int available;
			try {
				available = in.available();
			} catch (IOException e) {
				available = -1;
			}

			// se houve erro, aborta a leitura.
			if (-1 == available) {
				break;
			}

			// se não há nada por ler, espera até o próximo byte.
			if (0 == available) {
				// verifica o tempo de espera a partir do byte atual.
				long timeout = (totalRead == 0) ? m_absoluteTimeout : m_relativeTimeout;
				boolean hasTimeout = (timeout >= 0);
				timeout += lastTimestamp;

				// define o tempo máximo de espera.
				long sleepMillis;
				if (hasTimeout) {
					sleepMillis = timeout - now;
				} else {
					sleepMillis = 10;
				}

				if (0 < sleepMillis) {
					// se o tempo de espera é positivo, entra em espera (de no máximo 100 ms).
					if (10 < sleepMillis)
						sleepMillis = 10;
					try {
						Thread.sleep(sleepMillis);
					} catch (InterruptedException e) {}
				} else {
					// se já estourou o tempo máximo de espera, aborta.
					break;
				}

				// atualiza o horário atual.
				now = System.currentTimeMillis();
			} else {
				// verifica se os caracreres disponíveis excedem o limite.
				if (length < totalRead + available) {
					available = length - totalRead;
				}

				// lê efetivamente os bytes.
				int readNow = 0;
				try {
					readNow = in.read(buffer, offset + totalRead, available);
				} catch (IOException e) {
					readNow = 0;
				}

				// se houve erro, aborta.
				if (0 == readNow) {
					break;
				}

				// contabiliza os caracteres lidos
				totalRead += readNow;

				// atualiza o horário atual.
				now = System.currentTimeMillis();
				lastTimestamp = now;
			}
		}

		// retorna contagem de bytes,
		return totalRead;
	}

	public int write(byte[] buffer, int offset, int length) {
		// obtém o fluxo.
		OutputStream out;
		if (null != m_rxtxPort) {
			try {
				out = m_rxtxPort.getOutputStream();
			} catch (IOException e) {
				out = null;
			}
		} else {
			out = null;
		}

		// aborta, se a stream não puder ser obtida.
		if (null == out) {
			this.close();
			return 0;
		}

		// escreve os bytes e retorna a quantidade de bytes.
		m_semaphore.down();
		int amount = 0;
		try {
			out.write(buffer, offset, length);
			out.flush();
			amount = length;
		} catch (IOException e) {
			e.printStackTrace();
		}
		/*
		for (int i = 0; i < length; i++) {
			try {
				out.write(buffer, offset + i, 1);
				out.flush();
				amount++;
			} catch (IOException e) {
				break;
			}
			try {
				Thread.sleep(1);
			} catch (Exception e) {}
			if (i % 8 == 0) {
				try {
					Thread.sleep(10);
				} catch (Exception e) {}
			}
		}
		*/
		m_semaphore.up();
		return amount;

	}

	public static SerialPortStream create(String port, int baudRate, int byteSize, SerialPortStopBits stopBits, SerialPortParity parity) {
		return new SerialPortStream(port, baudRate, byteSize, stopBits, parity);
	}
}
