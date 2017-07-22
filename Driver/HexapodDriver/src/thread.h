/*
 * thread.h
 *
 *  Created on: 05/11/2012
 *      Author: Felipe Michels Fontoura
 */

#ifndef THREAD_H_
#define THREAD_H_

#ifdef _WIN32
#include <windows.h>
#endif

/* estrutura com dados de uma thread. */
typedef struct THREADS_THREAD
{
	void* params;
	void*(*start)(void* params, struct THREADS_THREAD* currentThread);
	void* result;
	int referenceCount;
#ifdef _WIN32
	HANDLE _win32_referenceMutex;
	HANDLE _win32_handle;
#endif /* _WIN32 */
} threads_thread_t, *threads_thread_ptr;

/* estrutura com dados de um semaforo. */
typedef struct
{
	int max;
	int referenceCount;
#ifdef _WIN32
	HANDLE _win32_referenceMutex;
	HANDLE _win32_handle;
#endif /* _WIN32 */
} threads_semaphore_t, *threads_semaphore_ptr;

/* ponteiro de função de inicio de thread. */
typedef void*(*threads_threadStart_ptr)(void* params, threads_thread_ptr currentThread);

/* inicializa o sistema de threads e semaforos. */
int threads_init();

/* finaliza o sistema de threads e semaforos. */
void threads_finalize();

/* cria um semaforo. */
int threads_semaphore_create(threads_semaphore_ptr* semaphore, int max, int current);

/* cria outra referencia a um semaforo.*/
int threads_semaphore_createReference(threads_semaphore_ptr* new, threads_semaphore_ptr old);

/* apaga uma referencia a um semaforo (apagar a ultima libera os dados). */
int threads_semaphore_deleteReference(threads_semaphore_ptr* semaphore);

/* realiza operacao de down (espera) em um semaforo.*/
int threads_semaphore_down(threads_semaphore_ptr semaphore);

/* realiza operacao de up (liberacao) em um semaforo.*/
int threads_semaphore_up(threads_semaphore_ptr semaphore);

/* cria uma thread. */
int threads_thread_create(threads_thread_ptr* thread, void* params, threads_threadStart_ptr start);

/* cria outra referencia a uma thread.*/
int threads_thread_createReference(threads_thread_ptr* new, threads_thread_ptr old);

/* inicia uma thread parada. */
int threads_thread_start(threads_thread_ptr thread);

/* espera uma thread terminar. */
int threads_thread_join(threads_thread_ptr thread, void** result);

/* verifica se uma thread esta em execucao. */
int threads_thread_isRunning(threads_thread_ptr thread);

/* apaga uma referencia a uma thread (apagar a ultima libera os dados). */
int threads_thread_dispose(threads_thread_ptr* thread);

/* libera a execucao da thread atual ate o proximo ciclo de execucao. */
int threads_currentThread_yield();

/* suspende a thread atual por um tempo pre-determinado. */
int threads_currentThread_sleep(int miliseconds);

#endif /* THREAD_H_ */
