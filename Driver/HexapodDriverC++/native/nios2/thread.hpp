/*
 * thread.cpp
 *
 *  Created on: 08/09/2013
 */

#include <FreeRTOS.h>
#include <task.h>

namespace native
{
	namespace niosii
	{
		bool thread_create(xTaskHandle* task, unsigned portSHORT stack_size, pdTASK_CODE function, void* parameter, int desiredPriority)
		{
			// cria a task
			unsigned portBASE_TYPE priority;
			if (desiredPriority > 0)
			{
				priority = (tskIDLE_PRIORITY + 3);
			}
			else if (desiredPriority == 0)
			{
				priority = (tskIDLE_PRIORITY + 2);
			}
			else
			{
				priority = (tskIDLE_PRIORITY + 1);
			}

			portBASE_TYPE result = xTaskCreate(function, NULL, stack_size, parameter, priority, task);
			return result == pdPASS;
		}

		bool thread_destroy(xTaskHandle task)
		{
			if (task != NULL)
			{
				vTaskDelete(task);
				return true;
			}
			else
			{
				return true;
			}
		}

		bool thread_sleep(long millis)
		{
			if (millis < 0)
			{
				return false;
			}
			if (millis == 0)
			{
				return true;
			}
			unsigned long ticks = (unsigned long)millis / portTICK_RATE_MS;
			while (ticks > 0)
			{
				portTickType timeout;
				if (ticks > portMAX_DELAY)
				{
					timeout = portMAX_DELAY;
					ticks -= portMAX_DELAY;
				}
				else
				{
					timeout = (portTickType) ticks;
					ticks = 0;
				}
				vTaskDelay(timeout);
			}
			return true;
		}
	}
}
