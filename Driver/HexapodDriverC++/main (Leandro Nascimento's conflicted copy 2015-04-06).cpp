/*
 * main.cpp
 *
 *  Created on: 14/11/2012
 */

#include "bot/firmware/fw_main.h"

#if defined(__NIOS2__)

#include "includes.h"
#include <iostream>
#define TASK_STACKSIZE 2048

// declara a task principal e a pilha dela.
void MainTask(void*) __attribute__((cdecl));
OS_STK MainTaskStack[TASK_STACKSIZE];

// função inicial.
int main(void)
{
	::printf("Criando MainTask\n");

	// cria a task MainTask.
	::OSTaskCreateExt(MainTask,
			NULL,
#if OS_STK_GROWTH == 1
		(OS_STK *)&MainTaskStack[TASK_STACKSIZE-1],
#else
		(OS_STK *)&MainTaskStack[0],
#endif
		10,
		10,
#if OS_STK_GROWTH == 1
		(OS_STK *)&MainTaskStack[0],
#else
		(OS_STK *)&MainTaskStack[TASK_STACKSIZE-1],
#endif
		TASK_STACKSIZE,
		NULL,
		0);

	::printf("Iniciando RTOS\n");

	// inicia o RTOS.
	::OSStart();
	return 0;
}

void MainTask(void *parameter)
{
	bot::firmware::main(parameter);
	while (true)
	{
		OSTimeDly(100);
	}
}

#elif defined(_WIN32)

#include "concurrent.thread.h"
#include "stream.socket.h"

int main(void)
{
	//stream::socket::finalizeSocket();
	bot::firmware::main((void*)0);

	// entra em loop eterno após iniciar.
	while (true)
	{
		concurrent::thread::Thread::sleep(100);
	}
}

#endif
