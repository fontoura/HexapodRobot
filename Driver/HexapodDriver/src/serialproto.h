/*
 * serialproto.h
 *
 *  Created on: 05/11/2012
 *      Author: Felipe Michels Fontoura
 */

#ifndef SERIALPROTO_H_
#define SERIALPROTO_H_

#include "serial.h"
#include "thread.h"

typedef struct
{
	uint32_t type;
	uint32_t length;
	uint8_t* buffer;
}
serialproto_message_t, *serialproto_message_ptr;

typedef struct SERIALPROTO_JOB
{
	struct SERIALPROTO_JOB* next;
	void (*action)(void*);
	void* param;
}
serialproto_job_t, *serialproto_job_ptr;

typedef struct
{
	threads_thread_ptr jobListThread;
	threads_semaphore_ptr jobListMutex;
	serialproto_job_ptr jobList_first;
	serialproto_job_ptr jobList_last;

	rs232_conn_ptr connection;
}
serialproto_comm_t, *serialproto_comm_ptr;

/* callback disparado assim que a resposta a uma mensagem for recebida pela serial. */
typedef void(*serialproto_replyCallback_ptr)(serialproto_message_ptr reply, int success, void* params);

/* inicializa o sistema de protocolo serial. */
int serialproto_init();

/* finaliza o sistema de protocolo serial. */
void serialproto_finalize();

/* inicializa uma conexao com o protocolo serial. */
void serialproto_comm_open(serialproto_comm_ptr* comm, char* portName);

/* envia uma mensagem pelo protocolo serial (espera pela resposta). */
void serialproto_comm_send(serialproto_comm_ptr* comm, serialproto_message_ptr* message, void* params, serialproto_replyCallback_ptr* callback);

/* cria uma mensagem vazia do protocolo serial. */
void serialproto_message_new(serialproto_message_ptr* message, int length);

/* apaga uma mensagem do protocolo serial. */
void serialproto_message_dispose(serialproto_message_ptr* message);

void serialproto_comm_close(serialproto_comm_ptr* comm);

void serialproto_comm_dispose(serialproto_comm_ptr* comm);

#endif /* SERIALPROTO_H_ */
