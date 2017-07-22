/*
 * stream.socket.cpp
 *
 *  Created on: 27/10/2012
 *      Author: Felipe Michels Fontoura
 */

#include <cstdio>

#include "stream.socket.h"

#ifdef _WIN32
#define WINVER 0x0502
#define _WIN32_WINNT 0x0502
#include <windows.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#endif /* _WIN32 */

namespace stream
{
	namespace socket
	{
		TCPServerSocket::TCPServerSocket(uint32_t port)
		{
			m_port = port;
		}

		TCPServerSocket::~TCPServerSocket()
		{
		}

		TCPSocketStream::TCPSocketStream()
		{
		}

		TCPSocketStream::~TCPSocketStream()
		{
		}

#ifdef _WIN32
		WSADATA Win32SocketInfoData;

		class Win32SocketStream :
			public TCPSocketStream
		{
			private:
				SOCKET m_socket;
				int m_absoluteTimeout;
				int m_relativeTimeout;
			public:
				Win32SocketStream(SOCKET socket);
				virtual ~Win32SocketStream();
				virtual bool open();
				virtual bool close();
				virtual bool isOpen();
				virtual bool setTimeouts(int absolute, int relative);
				virtual void getTimeouts(int* absolute, int* relative);
				virtual int read(uint8_t* buffer, int offset, int length);
				virtual int write(uint8_t* buffer, int offset, int length);
		};

		class Win32ServerSocket :
			public TCPServerSocket
		{
			protected:
				SOCKET m_socket;
				bool m_open;
			public:
				Win32ServerSocket(uint32_t port);
				virtual ~Win32ServerSocket();
				virtual TCPSocketStream* accept();
				virtual bool close();
			private:
				bool open();
		};

		void initSocket()
		{
			::WSAStartup(MAKEWORD(2, 0), &Win32SocketInfoData);
		}

		void finalizeSocket()
		{
			::WSACleanup();
		}

		Win32SocketStream::Win32SocketStream(SOCKET socket)
				: TCPSocketStream()
		{
			m_socket = socket;
			m_relativeTimeout = 0;
			m_absoluteTimeout = 0;
		}

		Win32SocketStream::~Win32SocketStream()
		{
			this->close();
		}

		bool Win32SocketStream::open()
		{
			return this->isOpen();
		}

		bool Win32SocketStream::close()
		{
			// se não fechou ainda, fecha.
			if (INVALID_SOCKET != m_socket)
			{
				::closesocket(this->m_socket);
				this->m_socket = INVALID_SOCKET;
			}
			return true;
		}

		bool Win32SocketStream::isOpen()
		{
			return (INVALID_SOCKET != m_socket);
		}

		bool Win32SocketStream::setTimeouts(int absolute, int relative)
		{
			m_absoluteTimeout = absolute;
			m_relativeTimeout = relative;
			return true;
		}

		void Win32SocketStream::getTimeouts(int* absolute, int* relative)
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

		int Win32SocketStream::read(uint8_t* buffer, int offset, int length)
		{
			if (length == 0)
			{
				return 0;
			}
			if (m_socket == INVALID_SOCKET)
			{
				return 0;
			}
			buffer = &(buffer[offset]);

			// contador de bytes lidos.
			int readSoFar = 0;

			// cria um set de descritores de socket.
			fd_set ReadFDs;
			FD_ZERO(&ReadFDs);
			FD_SET(m_socket, &ReadFDs);

			while (length > 0)
			{
				if (m_socket == INVALID_SOCKET)
				{
					break;
				}

				// determina se a operação sofre timeout e qual é ele.
				bool hasTimeout;
				long timeout;
				if (readSoFar == 0)
				{
					if (m_absoluteTimeout >= 0)
					{
						timeout = m_absoluteTimeout;
						hasTimeout = true;
					}
					else
					{
						hasTimeout = false;
					}
				}
				else
				{
					if (m_relativeTimeout >= 0)
					{
						timeout = m_relativeTimeout;
						hasTimeout = true;
					}
					else
					{
						hasTimeout = false;
					}
				}

				// se tiver timeout, espera pelos dados.
				if (hasTimeout)
				{
					timeval timeoutTimeval;
					timeoutTimeval.tv_sec = timeout / 1000;
					timeoutTimeval.tv_usec = 1000 * (timeout % 1000);

					// verifica se recebe algo até o tempo limite.
					int result = ::select(0, &ReadFDs, NULL, NULL, &timeoutTimeval);

					// se houver erro, fecha o socket e termina a operação.
					if (SOCKET_ERROR == result)
					{
						this->close();
						break;
					}

					// se sofreu timeout, termina a operação.
					if (0 == result)
					{
						break;
					}
				}
				else
				{
					// espera até receber algo.
					int result = ::select(0, &ReadFDs, NULL, NULL, NULL);

					// se houver erro, fecha o socket e termina a operação.
					if (SOCKET_ERROR == result)
					{
						this->close();
						break;
					}

					// se sofreu timeout inesperadamente, vai para a próxima iteração.
					if (0 == result)
					{
						continue;
					}
				}

				// recebe efetivamente os dados.
				int readNow = ::recv(m_socket, (char*) buffer, length, 0);

				// se houver erro, fecha o socket e termina a operação.
				if (0 == readNow || SOCKET_ERROR == readNow)
				{
					this->close();
					break;
				}

				// avança a posição no buffer.
				buffer = &(buffer[readNow]);
				length -= readNow;

				// contabiliza o número de bytes lidos.
				readSoFar += readNow;
			}

			// retorna o total de bytes lidos.
			return readSoFar;
		}

		int Win32SocketStream::write(uint8_t* buffer, int offset, int length)
		{
			if (length == 0)
			{
				return 0;
			}
			if (m_socket == INVALID_SOCKET)
			{
				return 0;
			}
			int result = ::send(m_socket, (char*) &(buffer[offset]), length, 0);
			if (result == SOCKET_ERROR)
			{
				this->close();
				return 0;
			}
			else
			{
				return result;
			}
		}

		Win32ServerSocket::Win32ServerSocket(uint32_t port)
				: TCPServerSocket(port)
		{
			m_open = false;
			m_socket = INVALID_SOCKET;
		}

		Win32ServerSocket::~Win32ServerSocket()
		{
			this->close();
			m_open = false;
			m_socket = INVALID_SOCKET;
		}

		TCPSocketStream* Win32ServerSocket::accept()
		{
			// se não está aberto, abre.
			if (!m_open)
			{
				this->open();
			}

			// se não está aberto, aborta.
			if (!m_open)
			{
				return NULL;
			}

			// aceita o socket.
			struct sockaddr address;
			::ZeroMemory(&address, sizeof(address));
			int addrlen = sizeof(struct sockaddr);
			SOCKET clientSocket = ::accept(m_socket, &address, &addrlen);
			if (INVALID_SOCKET == clientSocket)
			{
				return NULL;
			}
			return new Win32SocketStream(clientSocket);
		}

		bool Win32ServerSocket::close()
		{
			// se não fechou ainda, fecha.
			if (INVALID_SOCKET != m_socket)
			{
				::closesocket(m_socket);
				m_open = false;
				m_socket = INVALID_SOCKET;
			}
			return true;
		}

		bool Win32ServerSocket::open()
		{
			struct addrinfo hints;
			struct addrinfo* address;
			int result;

			::ZeroMemory(&hints, sizeof(hints));
			hints.ai_family = AF_INET;
			hints.ai_socktype = SOCK_STREAM;
			hints.ai_protocol = IPPROTO_TCP;
			hints.ai_flags = AI_PASSIVE;

			// obtém o IP local, que será usado pelo servidor.
			char portString[16];
			sprintf(portString, "%u", m_port);
			fflush(stdout);
			result = ::getaddrinfo("127.0.0.1", portString, &hints, &address);
			if (0 != result)
			{
				return false;
			}

			// cria um socket.
			SOCKET serverSocket = ::socket(address->ai_family, address->ai_socktype, address->ai_protocol);
			if (INVALID_SOCKET == serverSocket)
			{
				::freeaddrinfo(address);
				return false;
			}

			// associa o socket a uma porta.
			result = ::bind(serverSocket, address->ai_addr, (int) address->ai_addrlen);
			::freeaddrinfo(address);
			if (SOCKET_ERROR == result)
			{
				::closesocket(serverSocket);
				return false;
			}
			::freeaddrinfo(address);

			// coloca o socket em escuta.
			result = ::listen(serverSocket, SOMAXCONN);
			if (result == SOCKET_ERROR)
			{
				::closesocket(serverSocket);
				return false;
			}

			// salva o socket criado.
			m_socket = serverSocket;
			m_open = true;
			return true;
		}

		TCPServerSocket* TCPServerSocket::create(uint32_t port)
		{
			return new Win32ServerSocket(port);
		}
#endif /* _WIN32 */
	}
}

