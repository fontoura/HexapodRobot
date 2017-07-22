#include <stdio.h>
#include <stdlib.h>
#include "serial.h"
#include "socket.h"
#include "thread.h"

/* teste de RS232 */
/* envia caracteres e espera pela resposta. */
int RS232Test(void)
{
	int error;

	error = rs232_init();
	if (error != 0) {
		printf("ERRO AO INICIALIZAR O SUBSISTEMA RS232!\n");
		return EXIT_SUCCESS;
	}

	rs232_refreshPorts();

	rs232_iterator_ptr iter;
	rs232_iterate(&iter);
	while (iter != NULL)
	{
		printf("Porta %s\n", iter->port);
		fflush(stdout);
		rs232_conn_ptr conn;

		error = rs232_conn_open(&conn, iter->port, 9600, 8, RS232_STOPBITS_ONE, RS232_PARITY_NONE);
		if (error) continue;

		rs232_conn_configureTimeouts(conn, 1000, 500);
		int8_t buffer[16];
		char c;
		for (c = 'a'; c <= 'z'; c ++) {
			int length = rs232_conn_write(conn, &c, 1);
			if (length == 0) printf("\tEscritos 0 bytes:\n");
			else printf("\tEscritos 1 bytes: %c\n", c);
			fflush(stdout);

			int read = rs232_conn_read(conn, buffer, 16);
			printf("\tLidos %d bytes:", read);
			int j;
			for (j = 0; j < read; j++)
			{
				printf(" %c", (char)buffer[j]);
			}
			printf("\n");
			fflush(stdout);
		}
		rs232_conn_close(conn);
		rs232_conn_dispose(&conn);
		iter = iter->next;
	}

	rs232_finalize();
	return EXIT_SUCCESS;
}

/* teste de sockets */
/* recebe mensagens pela porta 3344 no formato #0000#mensagem#, onde 0000 e o tamanho. */
int SocketTest(void)
{
	typedef struct
	{
		int length;
		char* body;
	} string_message_t, *string_message_ptr;

	string_message_ptr read_message(socket_conn_ptr socketConn)
	{
		char header[6];
		int read;

		/* le o cabecalho */
		socket_conn_configureTimeouts(socketConn, -1, 50);
		read = socket_conn_read(socketConn, header, 6);
		if (read < 6) return NULL;

		int length;
		if (header[0] == '#' && header[5] == '#') {
			header[5] = 0;
			length = atoi(&(header[1]));
		} else return NULL;

		char* body = malloc(length + 1);
		socket_conn_configureTimeouts(socketConn, 0, 50);
		read = socket_conn_read(socketConn, body, length + 1);
		if (read == length + 1)
		{
			string_message_ptr message = (string_message_ptr)malloc(sizeof(string_message_t));
			body[length] = 0;
			message->length = length;
			message->body = body;
			return message;
		}
		else
		{
			fflush(stdout);
			free(body);
			return NULL;
		}
	}

	int error;

	/* incializa o sitema de sockets. */
	error = socket_init();
	if (error != 0) {
		printf("ERRO AO INICIALIZAR O SUBSISTEMA DE SOCKETS!\n");
		return EXIT_SUCCESS;
	}

	/* cria um socket de servidor. */
	socket_server_ptr info;
	error = socket_server_open(&info, 3344);
	if (error != 0) {
		printf("ERRO AO CRIAR UM SOCKET DE SERVIDOR!\n");
		socket_finalize();
		return EXIT_SUCCESS;
	}

	/* espera por uma conexao remota. */
	socket_conn_ptr conn;
	error = socket_server_accept(info, &conn);
	if (error != 0) {
		printf("ERRO AO ACEITAR A CONEXAO REMOTA!\n");
		socket_finalize();
		return EXIT_SUCCESS;
	}

	while (socket_conn_isAlive(conn))
	{
		string_message_ptr message = read_message(conn);
		if (message != NULL) {
			printf("MSG: %s\n", message->body);
			fflush(stdout);
		}
	}

	socket_conn_close(conn);
	socket_conn_dispose(&conn);
	socket_server_close(info);
	socket_server_dispose(&info);

	socket_finalize();
	return EXIT_SUCCESS;
}

/* teste de threads */
int ThreadTest(void)
{
	struct ThreadParams
	{
		threads_semaphore_ptr semaphore;
		char* message;
		int* counter;
	};
	void* pingThread(void* genericParams, threads_thread_ptr thread)
	{
		int i;
		struct ThreadParams* params = (struct ThreadParams*)genericParams;
		threads_semaphore_ptr semaphore;
		threads_semaphore_createReference(&semaphore, params->semaphore);
		for (i = 0; i < 100000; i ++)
		{
			threads_semaphore_down(semaphore);
			(* params->counter) ++;
			threads_semaphore_up(semaphore);
		}
		threads_semaphore_deleteReference(&semaphore);
		return NULL;
	}
	void* pongThread(void* genericParams, threads_thread_ptr thread)
	{
		int i;
		struct ThreadParams* params = (struct ThreadParams*)genericParams;
		threads_semaphore_ptr semaphore;
		threads_semaphore_createReference(&semaphore, params->semaphore);
		for (i = 0; i < 100000; i ++)
		{
			threads_semaphore_down(semaphore);
			(* params->counter) --;
			threads_semaphore_up(semaphore);
		}
		threads_semaphore_deleteReference(&semaphore);
		return NULL;
	}

	printf("CRIANDO SEMAFORO...\n");
	fflush(stdout);
	threads_semaphore_ptr mutex;
	int counter = 0;
	threads_semaphore_create(&mutex, 1, 1);

	printf("CRIANDO THEADS...\n");
	fflush(stdout);
	struct ThreadParams paramsPing;
	struct ThreadParams paramsPong;
	threads_thread_ptr threadPing = NULL;
	threads_thread_ptr threadPong = NULL;
	paramsPing.message = "mensagem do ping";
	paramsPong.message = "mensagem do pong";
	paramsPing.semaphore = mutex;
	paramsPong.semaphore = mutex;
	paramsPing.counter = &counter;
	paramsPong.counter = &counter;
	threads_thread_create(&threadPing, (void*)&paramsPing, pingThread);
	threads_thread_create(&threadPong, (void*)&paramsPong, pongThread);

	printf("INICIANDO THEADS...\n");
	fflush(stdout);
	threads_thread_start(threadPing);
	threads_thread_start(threadPong);
	threads_thread_join(threadPing, NULL);
	threads_thread_join(threadPong, NULL);

	printf("CONTADOR VALE %i\n", counter);

	threads_thread_dispose(&threadPing);
	threads_thread_dispose(&threadPong);
	threads_semaphore_deleteReference(&mutex);

	return EXIT_SUCCESS;
}

int main(void)
{
	return ThreadTest();
}
