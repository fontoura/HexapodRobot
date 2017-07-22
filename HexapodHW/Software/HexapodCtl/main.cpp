/*
 * main.cpp
 *
 *  Created on: 14/11/2012
 */

#include "bot/firmware/fw_main.h"

#ifdef __NIOS2__

#include <FreeRTOS.h>
#include <task.h>

// declara a task principal e a pilha dela.
void mainTask(void*);

// função inicial.
int main(void)
{
	// cria a tarefa principal.
	xTaskCreate(mainTask, NULL, 256, NULL, (tskIDLE_PRIORITY + 2), NULL);

	// inicia o RTOS.
	vTaskStartScheduler();

	return 0;
}

void mainTask(void *parameter)
{
	bot::firmware::main(parameter);
	for (;;)
	{
		vTaskDelay(100);
	}
};

#endif

#ifdef __WIN32__

#include "concurrent.thread.h"

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
