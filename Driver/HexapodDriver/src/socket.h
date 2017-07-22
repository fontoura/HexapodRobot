/*
 * socket.h
 *
 *  Created on: 29/10/2012
 *      Author: Felipe Michels Fontoura
 */

#ifndef SOCKET_H_
#define SOCKET_H_

#include "version.h"
#include <stdint.h>

#ifdef _WIN32
#include <windows.h>
#endif /* _WIN32 */

/* estrutura que define a conexao de um socket. */
typedef struct
{
	char* address;
	int absoluteTimeout;
	int relativeTimeout;
#ifdef _WIN32
	SOCKET _win32_socket;
#endif /* _WIN32 */
} socket_conn_t, *socket_conn_ptr;

/* estrutura que define um socket de servidor. */
typedef struct
{
	uint32_t port;
#ifdef _WIN32
	SOCKET _win32_socket;
#endif /* _WIN32 */
} socket_server_t, *socket_server_ptr;

/* inicializa o sistema de acesso a sockets. */
int socket_init();

/* finaliza o sistema de acesso a sockets. */
void socket_finalize();

/* abre um socket de servidor. */
int socket_server_open(socket_server_ptr* socket_server, uint32_t port);

/* espera por uma conexao remota em um socket de servidor. */
int socket_server_accept(socket_server_ptr socket_server, socket_conn_ptr* socket_conn);

/* fecha um socket de servidor. */
void socket_server_close(socket_server_ptr socket_server);

/* apaga a estrutura sobre um socket de servidor. */
void socket_server_dispose(socket_server_ptr* socket_server);

/* configura os timeouts da conexao com um socket. */
void socket_conn_configureTimeouts(socket_conn_ptr socket_server, int absolute, int relative);

/* le um bloco de bytes de uma conexao com um socket. */
int socket_conn_read(socket_conn_ptr socket_conn, uint8_t* buffer, int length);

/* verifica se a conexao com um socket esta aberta */
int socket_conn_isAlive(socket_conn_ptr socket_conn);

/* fecha a conexao com um socket. */
void socket_conn_close(socket_conn_ptr socket_conn);

/* apaga a estrutura sobre uma conexao com um socket. */
void socket_conn_dispose(socket_conn_ptr* socket_conn);

#endif /* SOCKET_H_ */
