/*
 * serial.h
 *
 *  Created on: 22/10/2012
 *      Author: Felipe Michels Fontoura
 */

#ifndef SERIAL_H_
#define SERIAL_H_

#include "version.h"
#include <stdint.h>

#ifdef _WIN32
#include <windows.h>
#endif

/* enumeracao de possiveis tipos de stop bits. */
typedef enum
{
	RS232_STOPBITS_ONE = 0,
	RS232_STOPBITS_ONE_DOT_FIVE = 1,
	RS232_STOPBITS_TWO = 2
} rs232_stopBits;

/* enumeracao de possiveis tipos da paridade. */
typedef enum
{
	RS232_PARITY_NONE = 0,
	RS232_PARITY_EVEN = 1,
	RS232_PARITY_ODD = 2
} rs232_parity;

/* estrutura que define um iterador de conexoes RS232. */
typedef struct RS232_ITERATOR
{
	/* nome da porta. */
	char* port;
	/* se a porta e valida. */
	int valid;
	/* proxima porta da lista. */
	struct RS232_ITERATOR* next;
} rs232_iterator_t, *rs232_iterator_ptr;


/* estrutura que define uma conexao RS232. */
typedef struct
{
	int baudRate;
	int byteSize;
	rs232_stopBits stopBits;
	rs232_parity parity;
	int absoluteTimeout;
	int relativeTimeout;
#ifdef _WIN32
	HANDLE _win32_handle;
#endif
} rs232_conn_t, *rs232_conn_ptr;


/* inicializa o sistema de acesso as portas RS232. */
int rs232_init();

/* finaliza o sistema de acesso as portas RS232. */
void rs232_finalize();

/* atualiza a lista de portas RS232. */
void rs232_refreshPorts();

/* itera sobre a lista de portas RS232. */
void rs232_iterate(rs232_iterator_ptr* rs232_iterator);

/* abre a conexao com uma porta RS232. */
int rs232_conn_open(rs232_conn_ptr* rs232_conn, char* port, int baudRate, int byteSize, rs232_stopBits stopBits, rs232_parity parity);

/* configura os timeouts da conexao com uma porta RS232. */
int rs232_conn_configureTimeouts(rs232_conn_ptr rs232_conn, int absolute, int relative);

/* le um bloco de bytes de uma conexao com porta RS232. */
int rs232_conn_read(rs232_conn_ptr rs232_conn, uint8_t* buffer, int length);

/* escreve um bloco de bytes de uma conexao com porta RS232. */
int rs232_conn_write(rs232_conn_ptr rs232_conn, uint8_t* buffer, int length);

/* fecha a conexao com uma porta RS232. */
void rs232_conn_close(rs232_conn_ptr rs232_conn);

/* apaga a estrutura sobre uma conexao com uma porta RS232. */
void rs232_conn_dispose(rs232_conn_ptr* rs232_conn);

#endif /* SERIAL_H_ */
