/*
 * threads.c
 *
 *  Created on: 05/11/2012
 *      Author: Felipe Michels Fontoura
 */

#include "thread.h"
#include "macros.h"

#include <stdint.h>

#ifdef _WIN32

#include <windows.h>

DWORD WINAPI __INTERNAL__THREADS_THREADSTART(LPVOID lpParameter)
{
	threads_thread_ptr threadInfo = (threads_thread_ptr)lpParameter;
	threadInfo->result = threadInfo->start(threadInfo->params, threadInfo);
	threads_thread_dispose(&threadInfo);
	return EXIT_SUCCESS;
}

#define threads_threadStart __INTERNAL__THREADS_THREADSTART

int threads_init()
{
	return 0;
}

void threads_finalize() { }

int threads_semaphore_create(threads_semaphore_ptr* semaphore, int max, int current)
{
	if (semaphore == NULL)
	{
		return -1;
	}
	threads_semaphore_ptr semaphoreInfo = (threads_semaphore_ptr)malloc(sizeof(threads_semaphore_t));
	semaphoreInfo->max = max;
	semaphoreInfo->referenceCount = 1;
	semaphoreInfo->_win32_referenceMutex = CreateSemaphoreA(NULL, 1, 1, NULL);
	if (semaphoreInfo->_win32_referenceMutex == NULL)
	{
		free((void*)semaphoreInfo);
		return -1;
	}
	semaphoreInfo->_win32_handle = CreateSemaphoreA(NULL, current, max, NULL);
	if (semaphoreInfo->_win32_handle == NULL)
	{
		CloseHandle(semaphoreInfo->_win32_referenceMutex);
		free((void*)semaphoreInfo);
		return -1;
	}
	else
	{
		*semaphore = semaphoreInfo;
		return 0;
	}
}

int threads_semaphore_createReference(threads_semaphore_ptr* new, threads_semaphore_ptr old)
{
	if (old == NULL)
	{
		/* nao ha semaforo de origem. */
		return -1;
	}
	if (new == NULL)
	{
		/* nao ha variavel de destino. */
		return -1;
	}
	int error;
	error = WaitForSingleObject(old->_win32_referenceMutex, INFINITE);
	if (error == WAIT_FAILED)
	{
		/* nao foi possivel esperar no semaforo. */
		return -1;
	}
	if (old->referenceCount == 0)
	{
		/* o objeto ja morreu. */
		return -1;
	}
	old->referenceCount ++;
	error = ReleaseSemaphore(old->_win32_referenceMutex, 1, NULL);
	if (error == 0)
	{
		/* erro inesperado! */
		return -1;
	}
	*new = old;
	return 0;
}

int threads_semaphore_down(threads_semaphore_ptr semaphore)
{
	if (semaphore == NULL)
	{
		/* nao ha semaforo. */
		return -1;
	}
	int error = WaitForSingleObject(semaphore->_win32_handle, INFINITE);
	if (error == WAIT_FAILED)
	{
		/* nao foi possivel esperar no semaforo. */
		return -1;
	}
	return 0;
}

int threads_semaphore_up(threads_semaphore_ptr semaphore)
{
	if (semaphore == NULL)
	{
		/* nao ha semaforo. */
		return -1;
	}
	int error = ReleaseSemaphore(semaphore->_win32_handle, 1, NULL);
	if (error == 0)
	{
		/* nao foi possivel liberar o semaforo. */
		return -1;
	}
	return 0;
}

int threads_semaphore_deleteReference(threads_semaphore_ptr* semaphore)
{
	if (semaphore == NULL)
	{
		/* nao ha variavel. */
		return -1;
	}
	threads_semaphore_ptr semaphoreInfo = *semaphore;
	if (semaphoreInfo == NULL)
	{
		/* nao ha semaforo. */
		return -1;
	}
	int error;
	error = WaitForSingleObject(semaphoreInfo->_win32_referenceMutex, INFINITE);
	if (error == WAIT_FAILED)
	{
		/* nao foi possivel esperar no semaforo. */
		return -1;
	}
	if (semaphoreInfo->referenceCount == 0)
	{
		/* o objeto ja morreu. */
		return -1;
	}
	semaphoreInfo->referenceCount --;
	if (semaphoreInfo->referenceCount == 0)
	{
		/* mata o objeto. */
		CloseHandle(semaphoreInfo->_win32_handle);
		CloseHandle(semaphoreInfo->_win32_referenceMutex);
		free((void*)semaphoreInfo);
		*semaphore = NULL;
		return 0;
	} else {
		/* libera o semaforo. */
		error = ReleaseSemaphore(semaphoreInfo->_win32_referenceMutex, 1, NULL);
		if (error == 0)
		{
			/* erro inesperado! */
			return -1;
		}
		*semaphore = NULL;
		return 0;
	}
}

int threads_thread_create(threads_thread_ptr* thread, void* params, threads_threadStart_ptr start)
{
	threads_thread_ptr threadInfo = (threads_thread_ptr)malloc(sizeof(threads_thread_t));
	threadInfo->params = params;
	threadInfo->start = start;
	threadInfo->result = NULL;
	if (thread == NULL)
	{
		threadInfo->referenceCount = 1;
	}
	else
	{
		threadInfo->referenceCount = 2;
	}
	threadInfo->_win32_referenceMutex = CreateSemaphoreA(NULL, 1, 1, NULL);
	if (threadInfo->_win32_referenceMutex == NULL)
	{
		free((void*)threadInfo);
		return -1;
	}
	threadInfo->_win32_handle = CreateThread(NULL, 0, threads_threadStart, (void*)threadInfo, CREATE_SUSPENDED, NULL);
	if (threadInfo->_win32_handle == NULL)
	{
		CloseHandle(threadInfo->_win32_referenceMutex);
		free((void*)threadInfo);
		return -1;
	}
	else
	{
		if (thread != NULL)
		{
			*thread = threadInfo;
		}
		return 0;
	}
}

int threads_thread_createReference(threads_thread_ptr* new, threads_thread_ptr old)
{
	if (old == NULL)
	{
		/* nao ha thread de origem. */
		return -1;
	}
	if (new == NULL)
	{
		/* nao ha variavel de destino. */
		return -1;
	}
	int error;
	error = WaitForSingleObject(old->_win32_referenceMutex, INFINITE);
	if (error == WAIT_FAILED)
	{
		/* nao foi possivel esperar no semaforo. */
		return -1;
	}
	if (old->referenceCount == 0)
	{
		/* o objeto ja morreu. */
		return -1;
	}
	old->referenceCount ++;
	error = ReleaseSemaphore(old->_win32_referenceMutex, 1, NULL);
	if (error == 0)
	{
		/* erro inesperado! */
		return -1;
	}
	*new = old;
	return 0;
}

int threads_thread_start(threads_thread_ptr thread)
{
	if (thread == NULL)
	{
		/* nao ha thread. */
		return -1;
	}
	if (-1 == ResumeThread(thread->_win32_handle))
	{
		return -1;
	}
	else
	{
		return 0;
	}
}

int threads_thread_join(threads_thread_ptr thread, void** result)
{
	if (thread == NULL)
	{
		/* nao ha thread. */
		return -1;
	}
	int error = WaitForSingleObject(thread->_win32_handle, INFINITE);
	if (error == WAIT_FAILED)
	{
		/* nao foi possivel esperar pela thread. */
		return -1;
	}
	if (result != NULL)
	{
		*result = thread->result;
	}
	return 0;
}

/* verifica se uma thread esta em execucao. */
int threads_thread_isRunning(threads_thread_ptr thread)
{
	if (thread == NULL)
	{
		/* nao ha thread. */
		return 0;
	}
	if (WaitForSingleObject(thread->_win32_handle, 0) == WAIT_OBJECT_0)
	{
		return 0;
	}
	else
	{
		return -1;
	}
}

/* apaga uma referencia uma thread (apagar a ultima apaga a tread). */
int threads_thread_dispose(threads_thread_ptr* thread)
{
	if (thread == NULL)
	{
		/* nao ha variavel. */
		return -1;
	}
	threads_thread_ptr threadInfo = *thread;
	if (threadInfo == NULL)
	{
		/* nao ha thread. */
		return -1;
	}
	int error;
	error = WaitForSingleObject(threadInfo->_win32_referenceMutex, INFINITE);
	if (error == WAIT_FAILED)
	{
		/* nao foi possivel esperar no semaforo. */
		return -1;
	}
	if (threadInfo->referenceCount == 0)
	{
		/* o objeto ja morreu. */
		return -1;
	}
	threadInfo->referenceCount --;
	if (threadInfo->referenceCount == 0)
	{
		/* mata o objeto. */
		CloseHandle(threadInfo->_win32_handle);
		CloseHandle(threadInfo->_win32_referenceMutex);
		free((void*)threadInfo);
		*thread = NULL;
		return 0;
	} else {
		/* libera o semaforo. */
		error = ReleaseSemaphore(threadInfo->_win32_referenceMutex, 1, NULL);
		if (error == 0)
		{
			/* erro inesperado! */
			return -1;
		}
		*thread = NULL;
		return 0;
	}
}

int threads_currentThread_yield()
{
	SwitchToThread();
	return 0;
}

int threads_currentThread_sleep(int miliseconds)
{
	Sleep(miliseconds);
	return 0;
}

#endif
