/*
 * stream.uart.cpp
 *
 *  Created on: 21/10/2012
 */

#include "globaldefs.h"
#include "stream.uart.h"
#include <string.h>

#ifdef __WIN32__
#define WINVER 0x0501
#define _WIN32_WINNT 0x0501
#include <windows.h>
#include <setupapi.h>
#endif /* __WIN32__ */

#ifdef __NIOS2__
#include <cstdlib>
#include <FreeRTOS.h>
#include <task.h>
#include "concurrent.thread.h"
#include <fcntl.h>
#include <unistd.h>
#endif /* __NIOS2__ */

namespace stream
{
	namespace uart
	{
		class SerialPortStreamImpl :
			public SerialPortStream
		{
			friend class SerialPortStream;
			_pool_decl(SerialPortStreamImpl, _POOL_SIZE_FOR_SERIALPORTSTREAMS)

		private:
#ifdef __WIN32__
				HANDLE m_handle;
#endif /* __WIN32__ */

#ifdef __NIOS2__
				int m_file;
				long m_absoluteTimeout;
				long m_relativeTimeout;
#endif /* __NIOS2__ */

			protected:
				SerialPortStreamImpl();
				virtual ~SerialPortStreamImpl();

			public:
				void initialize(char* port, int baudRate, int byteSize, SerialPortStopBits stopBits, SerialPortParity parity);
				void finalize();
				bool open();
				bool close();
				bool isOpen();
				bool setTimeouts(int absolute, int relative);
				void getTimeouts(int* absolute, int* relative);
				int read(uint8_t* buffer, int offset, int length);
				int write(uint8_t* buffer, int offset, int length);
		};

		_pool_inst(SerialPortStreamImpl, _POOL_SIZE_FOR_SERIALPORTSTREAMS)

		SerialPortStream::SerialPortStream()
		{
			m_port = NULL;
			m_baudRate = 0;
			m_bitRate = 0;
			m_stopBits = SERIALPORT_STOPBITS_ONE;
			m_parity = SERIALPORT_PARITY_NONE;
			m_absoluteTimeout = 0;
			m_relativeTimeout = 0;
		}

		SerialPortStream::~SerialPortStream()
		{
		}

		void SerialPortStream::initialize(char* port, int baudRate, int bitRate, SerialPortStopBits stopBits, SerialPortParity parity)
		{
			// copia o nome da porta.
			int portLength = strlen(port) + 1;
			char* portCopy = new char[portLength];
			::memcpy(portCopy, port, portLength);

			// define os parâmetros.
			m_port = portCopy;
			m_baudRate = baudRate;
			m_bitRate = bitRate;
			m_stopBits = stopBits;
			m_parity = parity;
			m_absoluteTimeout = 0;
			m_relativeTimeout = 0;
		}

		SerialPortStream* SerialPortStream::create(char* port, int baudRate, int byteSize, SerialPortStopBits stopBits, SerialPortParity parity)
		{
			_new_inst(SerialPortStreamImpl, serialStream);
			serialStream->initialize(port, baudRate, byteSize, stopBits, parity);
			return serialStream;
		}

		SerialPortStreamImpl::SerialPortStreamImpl()
		{
#ifdef __WIN32__
			m_handle = INVALID_HANDLE_VALUE;
#endif /* __WIN32__ */
#ifdef __NIOS2__
			m_file = 0;
#endif /* __NIOS2__ */
		}

		SerialPortStreamImpl::~SerialPortStreamImpl()
		{
		}

		void SerialPortStreamImpl::initialize(char* port, int baudRate, int bitRate, SerialPortStopBits stopBits, SerialPortParity parity)
		{
			SerialPortStream::initialize(port, baudRate, bitRate, stopBits, parity);

#ifdef __WIN32__
			m_handle = INVALID_HANDLE_VALUE;
#endif /* __WIN32__ */
#ifdef __NIOS2__
			m_file = 0;
#endif /* __NIOS2__ */
	}

		bool SerialPortStreamImpl::open()
		{
#ifdef __WIN32__
			// verifica se a porta já está aberta.
			if (INVALID_HANDLE_VALUE != m_handle)
			{
				return true;
			}

			// tenta criar a conexão com a porta serial.
			HANDLE handle = ::CreateFileA(m_port, GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL);
			if (INVALID_HANDLE_VALUE == handle)
			{
				return false;
			}

			// tenta definir o baud rate e os demais parâmetros.
			DCB dcb;
			FillMemory(&dcb, sizeof(dcb), 0);
			BOOL result = ::GetCommState(handle, &dcb);
			if (0 == result)
			{
				::CloseHandle(handle);
				return false;
			}
			dcb.BaudRate = m_baudRate;
			dcb.ByteSize = m_bitRate;
			switch (m_stopBits)
			{
				case SERIALPORT_STOPBITS_ONE_DOT_FIVE:
					dcb.StopBits = ONE5STOPBITS;
					break;
				case SERIALPORT_STOPBITS_TWO:
					dcb.StopBits = TWOSTOPBITS;
					break;
				default:
					dcb.StopBits = ONESTOPBIT;
					break;
			}
			switch (m_parity)
			{
				case SERIALPORT_PARITY_EVEN:
					dcb.Parity = EVENPARITY;
					break;
				case SERIALPORT_PARITY_ODD:
					dcb.Parity = ODDPARITY;
					break;
				default:
					dcb.Parity = NOPARITY;
					break;
			}
			result = ::SetCommState(handle, &dcb);
			if (0 == result)
			{
				::CloseHandle(handle);
				return false;
			}

			// tenta definir os timeouts.
			COMMTIMEOUTS timeouts;
			timeouts.ReadIntervalTimeout = (m_relativeTimeout < 0) ? MAXDWORD : m_relativeTimeout;
			timeouts.ReadTotalTimeoutMultiplier = (m_relativeTimeout < 0) ? MAXDWORD : m_relativeTimeout;
			timeouts.ReadTotalTimeoutConstant = (m_absoluteTimeout < 0) ? MAXDWORD : m_absoluteTimeout;
			timeouts.WriteTotalTimeoutMultiplier = 0;
			timeouts.WriteTotalTimeoutConstant = 0;
			result = ::SetCommTimeouts(handle, &timeouts);
			if (0 == result)
			{
				::CloseHandle(handle);
				return false;
			}

			// salva a handle.
			m_handle = handle;
#endif /* __WIN32__ */
#ifdef __NIOS2__
			// se ja está aberto, ok.
			if (0 != m_file)
			{
				return true;
			}

			// tenta criar a conexao com a porta serial.
			int file = ::open(m_port, O_RDWR | O_NONBLOCK);
			if (-1 == file)
			{
				return false;
			}
			m_file = file;
#endif /* __NIOS2__ */

			return true;
		}

		bool SerialPortStreamImpl::close()
		{
#ifdef __WIN32__
			// se não fechou o handle, fecha.
			if (INVALID_HANDLE_VALUE != m_handle)
			{
				::CloseHandle(m_handle);
				m_handle = INVALID_HANDLE_VALUE;
			}
#endif /* __WIN32__ */
#ifdef __NIOS2__
			// se ja está fechado, ok.
			if (0 == m_file)
			{
				return true;
			}

			// fecha a conexao com a porta serial.
			::close(m_file);
			m_file = 0;
#endif /* __NIOS2__ */
			return true;
		}

		bool SerialPortStreamImpl::isOpen()
		{
			bool result = false;

#ifdef __WIN32__
			result = (INVALID_HANDLE_VALUE != m_handle);
#endif /* __WIN32__ */
#ifdef __NIOS2__
			result = (0 != m_file);
#endif /* __NIOS2__ */

			return result;
		}

		bool SerialPortStreamImpl::setTimeouts(int absolute, int relative)
		{
#ifdef __WIN32__
			// se está fechado, simplesmente define as variáveis.
			if (INVALID_HANDLE_VALUE == m_handle)
			{
				m_absoluteTimeout = absolute;
				m_relativeTimeout = relative;
				return true;
			}

			// tenta definir os timeouts.
			COMMTIMEOUTS timeouts;
			timeouts.ReadIntervalTimeout = (relative < 0) ? MAXDWORD : relative;
			timeouts.ReadTotalTimeoutMultiplier = 0;//(relative < 0) ? MAXDWORD : relative;
			timeouts.ReadTotalTimeoutConstant = (absolute < 0) ? MAXDWORD : absolute;
			timeouts.WriteTotalTimeoutMultiplier = 0;
			timeouts.WriteTotalTimeoutConstant = 0;
			BOOL result = ::SetCommTimeouts(m_handle, &timeouts);

			// verifica se conseguiu definir os timeouts.
			if (0 != result)
			{
				m_absoluteTimeout = absolute;
				m_relativeTimeout = relative;
			}
			else
			{
				return false;
			}
#endif /* __WIN32__ */
#ifdef __NIOS2__
			m_absoluteTimeout = absolute;
			m_relativeTimeout = relative;
#endif /* __NIOS2__ */

			return true;
		}

		void SerialPortStreamImpl::getTimeouts(int* absolute, int* relative)
		{
			if (absolute != NULL)
			{
				*absolute = m_absoluteTimeout;
			}
			if (relative != NULL)
			{
				*relative = m_relativeTimeout;
			}
		}

#ifdef __NIOS2__
		long currentTimeMillis()
		{
			return xTaskGetTickCount() * portTICK_RATE_MS;
		}
#endif /* __NIOS2__ */

		int SerialPortStreamImpl::read(uint8_t* buffer, int offset, int length)
		{
			int totalRead = 0;

#ifdef __WIN32__
			if (INVALID_HANDLE_VALUE == m_handle)
			{
				return 0;
			}
			if (m_absoluteTimeout < 0)
			{
				_COMSTAT comstat;
				::ClearCommError(m_handle, NULL, &comstat);
				while (comstat.cbInQue == 0)
				{
					::Sleep(10);
					::ClearCommError(m_handle, NULL, &comstat);
				}
			}
			DWORD count = length;
			BOOL result = ::ReadFile(m_handle, (char*) &(buffer[offset]), length, &count, NULL);
			if (0 == result)
			{
				return 0;
			}
			totalRead = count;
#endif /* __WIN32__ */
#ifdef __NIOS2__
			if (0 == length)
			{
				return 0;
			}

			// determina a hora atual.
			long now = currentTimeMillis();

			// guarda o horário da última leitura e a quantidade de leituras.
			long lastTimestamp = now;

			// inicia o ciclo de leitura.
			while (totalRead < length)
			{
				// obtém o descritor de arquivo.
				int file = m_file;

				// se já fechou o arquivo, aborta.
				if (0 == file)
				{
					break;
				}

				// verifica se há caracteres prontos para leitura.
				int readNow = ::read(file, (void*)&(buffer[offset + totalRead]), length - totalRead);

				// verifica se sofreu timeout.
				if (readNow == -1 && errno == ENOMEM) // deveria ser EAGAIN
				{
					readNow = 0;
				}

				// se houve erro, aborta.
				if (0 > readNow)
				{
					this->close();
					break;
				}

				// se não há nada por ler, espera até o próximo byte.
				if (0 == readNow)
				{
					// verifica o tempo de espera a partir do byte atual.
					long timeout = (totalRead == 0) ? m_absoluteTimeout : m_relativeTimeout;
					bool hasTimeout = (timeout >= 0);
					timeout += lastTimestamp;

					// define o tempo máximo de espera.
					long sleepMillis;
					if (hasTimeout)
					{
						sleepMillis = timeout - now;
					}
					else
					{
						sleepMillis = 10;
					}

					if (0 < sleepMillis)
					{
						// se o tempo de espera é positivo, entra em espera (de no máximo 10 ms).
						if (10 < sleepMillis)
						{
							sleepMillis = 10;
						}
						concurrent::thread::Thread::sleep(sleepMillis);
					}
					else
					{
						// se já estourou o tempo máximo de espera, aborta.
						break;
					}

					// atualiza o horário atual.
					now = currentTimeMillis();
				}
				else
				{
					// contabiliza os caracteres lidos
					totalRead += readNow;

					// atualiza o horário atual.
					now = currentTimeMillis();
					lastTimestamp = now;
				}
			}
#endif /* __NIOS2__ */

			// retorna contagem de bytes,
			return totalRead;
		}

		int SerialPortStreamImpl::write(uint8_t* buffer, int offset, int length)
		{
			int totalWritten = 0;

#ifdef __WIN32__
			if (0 == length)
			{
				return 0;
			}
			if (INVALID_HANDLE_VALUE == m_handle)
			{
				return 0;
			}
			DWORD count = 0;
			BOOL result = ::WriteFile(m_handle, (char*) &(buffer[offset]), length, &count, NULL);
			if (0 == result)
			{
				return 0;
			}
			totalWritten = count;
#endif /* __WIN32__ */
#ifdef __NIOS2__
			if (0 == length)
			{
				return 0;
			}
			int file = m_file;
			if (0 == file)
			{
				return 0;
			}
			totalWritten = ::write(file, &(buffer[offset]), length);
			if (0 > totalWritten) return 0;
#endif /* __NIOS2__ */

			return totalWritten;
		}

		void SerialPortStreamImpl::finalize()
		{
			this->close();
			delete m_port;
			m_port = NULL;
			_del_inst(SerialPortStreamImpl);
		}
	}
}

