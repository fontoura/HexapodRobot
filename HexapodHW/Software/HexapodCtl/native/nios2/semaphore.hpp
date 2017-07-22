/*
 * semaphore.hpp
 *
 *  Created on: 08/09/2013
 */

#include <FreeRTOS.h>
#include <semphr.h>

namespace native
{
	namespace niosii
	{
		xSemaphoreHandle semaphore_create(int count, int maximum)
		{
			return xSemaphoreCreateCounting((unsigned portBASE_TYPE)maximum, (unsigned portBASE_TYPE)count);
		}

		void semaphore_destroy(xSemaphoreHandle handle)
		{
			vSemaphoreDelete(handle);
		}

		bool semaphore_down(xSemaphoreHandle handle, long millis)
		{
			if (handle != NULL)
			{
				if (0 == millis)
				{
					return  pdTRUE == xSemaphoreTake(handle, 0);
				}
				else if (millis < 0)
				{
					while (pdFALSE == xSemaphoreTake(handle, portMAX_DELAY));
					return true;
				}
				else
				{
					long ticks = millis / portTICK_RATE_MS;
					while (ticks > 0)
					{
						portTickType timeout;
						if (ticks > (signed long)portMAX_DELAY)
						{
							timeout = portMAX_DELAY;
							ticks -= portMAX_DELAY;
						}
						else
						{
							timeout = (portTickType) ticks;
							ticks = 0;
						}
						if (pdTRUE == xSemaphoreTake(handle, timeout)) {
							return true;
						}
					}
					return false;
				}
			}
			else
			{
				return false;
			}
		}

		bool semaphore_up(xSemaphoreHandle handle)
		{
			if (handle != NULL)
			{
				return pdTRUE == xSemaphoreGive(handle);
			} else {
				return false;
			}
		}

		int semaphore_query(xSemaphoreHandle handle)
		{
			if (handle != NULL)
			{
				return uxQueueMessagesWaiting(handle);
			}
			else
			{
				return -1;
			}
		}
	}
}
