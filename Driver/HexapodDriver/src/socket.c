/*
 * socket.c
 *
 *  Created on: 27/10/2012
 *      Author: Felipe Michels Fontoura
 */

#include "socket.h"
#include "macros.h"

#include <stdint.h>

#ifdef _WIN32

#include <stdio.h>
#include <windows.h>
#include <winsock2.h>
#include <ws2tcpip.h>

WSADATA __INTERNAL__SOCKET_INFO_DATA;
#define socket_info_data __INTERNAL__SOCKET_INFO_DATA

/* implementacao em Windows. */

int socket_init()
{
	int result = WSAStartup(MAKEWORD(2, 0), &socket_info_data);
	if (result != 0) return -1;
	else return 0;
}

void socket_finalize()
{
	WSACleanup();
}

int socket_server_open(socket_server_ptr* server_info, uint32_t port)
{
	struct addrinfo hints;
	struct addrinfo* address;
	int result;

	ZeroMemory(&hints, sizeof(hints));
	hints.ai_family = AF_INET;
	hints.ai_socktype = SOCK_STREAM;
	hints.ai_protocol = IPPROTO_TCP;
	hints.ai_flags = AI_PASSIVE;

	/* obtem o IP local, que sera usado pelo servidor. */
	char port_str[16];
	sprintf(port_str, "%u", port);
	printf("%s\n", port_str);

	result = getaddrinfo("127.0.0.1", port_str, &hints, &address);
	if (result != 0) {
		return -1;
	}

	/* cria um socket. */
	SOCKET server_socket = socket(address->ai_family, address->ai_socktype, address->ai_protocol);
	if (server_socket == INVALID_SOCKET) {
		freeaddrinfo(address);
		return -1;
	}

	/* associa o socket a uma porta. */
	result = bind(server_socket, address->ai_addr, (int)address->ai_addrlen);
	if (result == SOCKET_ERROR)
	{
		freeaddrinfo(address);
		closesocket(server_socket);
		return -1;
	}
	freeaddrinfo(address);

	/* coloca o socket em espera. */
	result = listen(server_socket, SOMAXCONN);
	if (result == SOCKET_ERROR) {
		closesocket(server_socket);
		return -1;
	}

	/* cria a estrutura com informações sobre o socket. */
	socket_server_ptr new_server_info = new(socket_server_t);
	new_server_info->port = port;
	new_server_info->_win32_socket = server_socket;
	*server_info = new_server_info;
	return 0;
}

int socket_server_accept(socket_server_ptr serversocket_info, socket_conn_ptr* socket_info)
{
	struct sockaddr address;
	ZeroMemory(&address, sizeof(address));
	int addrlen = sizeof(struct sockaddr);
	SOCKET client_socket = accept(serversocket_info->_win32_socket, &address, &addrlen);
	if (client_socket == INVALID_SOCKET)
	{
		int err = WSAGetLastError();
		printf("ACCEPT FALHOU: %i!\n", err);
		return -1;
	}
	char* name = (char*)malloc(addrlen);
	strcpy(name, address.sa_data);
	socket_conn_ptr socket_c = (socket_conn_ptr)malloc(sizeof(socket_conn_t));
	socket_c->address = name;
	socket_c->_win32_socket = client_socket;
	*socket_info = socket_c;
	return 0;
}

void socket_server_close(socket_server_ptr socket)
{
	if (socket == NULL) return;
	if (socket->_win32_socket == INVALID_SOCKET) return;
	closesocket(socket->_win32_socket);
	socket->_win32_socket = INVALID_SOCKET;
}

void socket_server_dispose(socket_server_ptr* socket)
{
	if (socket == NULL) return;
	if (*socket == NULL) return;
	socket_server_close(*socket);
	free((void*)*socket);
	*socket = NULL;
}

void socket_conn_configureTimeouts(socket_conn_ptr socket_info, int absolute, int relative)
{
	socket_info->absoluteTimeout = absolute;
	socket_info->relativeTimeout = relative;
}

int socket_conn_read(socket_conn_ptr socket_info, uint8_t* buffer, int length)
{
	if (length == 0) return 0;
	if (socket_info == NULL) return 0;
	if (socket_info->_win32_socket == INVALID_SOCKET) return 0;

	/* contadores de bytes lidos e por ler. */
	int read = 0;
	int remaining = length;

	/* obtem o instante atual de tempo e calcula o tempo limite */
	long now = GetTickCount();
	long endTime = now;

	/* se o timeout absoluto nao for infinito, adiciona ao tempo limite. */
	if (socket_info->absoluteTimeout >= 0)
	{
		endTime += socket_info->absoluteTimeout;
	}

	/* se o timeout relativo nao for infinito, adiciona ao tempo limite. */
	if (socket_info->relativeTimeout >= 0)
	{
		endTime += socket_info->relativeTimeout;
	}

	/* cria um conjunto de sockets que contem apenas o socket. */
	struct fd_set ReadFDs;
    FD_ZERO(&ReadFDs);
	FD_SET(socket_info->_win32_socket, &ReadFDs);

	while (-1)
	{
		/* determina se a operacao atual tem um timeout. */
		struct timeval timeval;
		struct timeval* timeval_addr;
		if (read == 0) {
			/* esta no primeiro byte. verifica se tem timeout. */
			if (socket_info->absoluteTimeout < 0) timeval_addr = NULL;
			else timeval_addr = &timeval;
		} else {
			/* esta a frente do primeiro byte. verifica se tem timeout. */
			if (socket_info->relativeTimeout < 0) timeval_addr = NULL;
			else timeval_addr = &timeval;
		}

		/* se a operacao atual tem timeout, calcula o tempo faltante. */
		if (timeval_addr != NULL)
		{
			long remainingTime = endTime - now;
			if (remainingTime < 0) break;
			timeval.tv_sec = remainingTime / 1000;
			timeval.tv_usec = 1000 * (remainingTime % 1000);
		}

		/* espera ate o socket receber algo ou atingir o tempo limite. */
		int result = select(0, &ReadFDs, NULL, NULL, timeval_addr);
		if (result == SOCKET_ERROR)
		{
			/* verifica se o erro foi o socket desconectado. */
			int error = WSAGetLastError();
			if (error == WSAECONNRESET) socket_conn_close(socket_info);
			break;
		}

		/* se nao leu nenhum bytes, decide o que fazer. */
		if (result == 0) {
			if (read == 0) {
				/* esta no primeiro byte. se tiver timeout continua esperando, senao para. */
				if (socket_info->absoluteTimeout >= 0) break;
				else continue;
			} else {
				/* esta a frente do primeiro byte. se tiver timeout continua esperando, senao para. */
				if (socket_info->relativeTimeout >= 0) break;
				else continue;
			}
		}

		/* determina a quantidade de bytes disponiveis. */
		int amount = recv(socket_info->_win32_socket, &(buffer[read]), remaining, MSG_PEEK);
		if (amount > remaining) amount = remaining;
		/* se nao ha bytes disponiveis, verifica se houve erro */
		if (amount <= 0) {
			/* verifica se o erro foi o socket desconectado. */
			int error = WSAGetLastError();
			if (error == WSAECONNRESET) socket_conn_close(socket_info);
			break;
		}

		/* recebe efetivamente os bytes. */
		amount = recv(socket_info->_win32_socket, &(buffer[read]), amount, 0);

		/* se nao pode receber os bytes, verifica se houve erro */
		if (amount <= 0) {
			/* verifica se o erro foi o socket desconectado. */
			int error = WSAGetLastError();
			if (error == WSAECONNRESET) socket_conn_close(socket_info);
			break;
		}
		if (read == 0) {
			/* se esta no primeiro esta no primeiro byte. */
			/* se o primeiro byte tem timeout, mas nao os outros, define o tempo limite. */
			if (socket_info->absoluteTimeout < 0) {
				endTime = GetTickCount() + socket_info->relativeTimeout;
			}
		}

		/* computa o numero de bytes lidos. */
		read += amount;
		remaining -= amount;

		/* para se encheu o buffer. */
		if (remaining == 0) break;

		/* calcula os tempos. */
		endTime += socket_info->relativeTimeout * amount;
		now = GetTickCount();
	}

	/* retorna quantos caracteres leu. */
	return read;
}

int socket_conn_isAlive(socket_conn_ptr conn)
{
	return conn->_win32_socket != INVALID_SOCKET;
}

void socket_conn_close(socket_conn_ptr socket)
{
	if (socket == NULL) return;
	free((void*)socket->address);
	closesocket(socket->_win32_socket);
	socket->_win32_socket = INVALID_SOCKET;
}

void socket_conn_dispose(socket_conn_ptr* socket)
{
	if (socket == NULL) return;
	if (*socket == NULL) return;
	socket_conn_close(*socket);
	free((void*)*socket);
	*socket = NULL;
}

#endif /* _WIN32 */
