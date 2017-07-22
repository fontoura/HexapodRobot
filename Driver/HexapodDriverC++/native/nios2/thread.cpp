/*
 * thread.cpp
 *
 *  Created on: 25/03/2013
 *      Author: Felipe Michels Fontoura
 */

#ifdef __NIOS2__

#include "thread.h"

namespace native
{
	namespace niosii
	{
		bool thread_create(INT8U& priority, OS_STK* stack, INT16U stack_size, void(*function)(void*), void* parameter, int desiredPriority)
		{

#if OS_STK_GROWTH == 1
// se a stack cresce para baixo
#define PTOS_VALUE &(stack[stack_size-1])
#define PBOS_VALUE &(stack[0])
#else
// se a stack cresce para cima
#define PTOS_VALUE &(stack[0])
#define PBOS_VALUE &(stack[stack_size-1])
#endif
#define LOWEST_PRIO_TASK (0xFF&(OS_LOWEST_PRIO-4))
#define HIGHEST_PRIO_TASK (4)
#define MEDIUM_LOW_PRIO_TASK ((2*LOWEST_PRIO_TASK+HIGHEST_PRIO_TASK)/3)
#define MEDIUM_HIGH_PRIO_TASK ((LOWEST_PRIO_TASK+2*HIGHEST_PRIO_TASK)/3)

			// cria a task
			int start, end;
			if (desiredPriority > 0)
			{
				start = MEDIUM_HIGH_PRIO_TASK;
				end = HIGHEST_PRIO_TASK;
			}
			else if (desiredPriority == 0)
			{
				start = MEDIUM_LOW_PRIO_TASK;
				end = MEDIUM_HIGH_PRIO_TASK;
			}
			else
			{
				start = LOWEST_PRIO_TASK;
				end = MEDIUM_LOW_PRIO_TASK;
			}
			for (int i = start; i >= end; i--)
			{
				INT8U result = ::OSTaskCreateExt(
					function,
					parameter,
					PTOS_VALUE,
					i,
					i,
					PBOS_VALUE,
					stack_size,
					(void*)0,
					OS_TASK_OPT_STK_CHK | OS_TASK_OPT_STK_CLR);
				if (OS_NO_ERR == result)
				{
					priority = i;
					return true;
				}
			}

			priority = 0;
			return false;
		}

		bool thread_destroy(INT8U& priority)
		{
			if (priority != 0)
			{
				if (OS_NO_ERR == ::OSTaskDel(priority))
				{
					priority = 0;
					return true;
				}
				else
				{
					return false;
				}
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
			long ticks = (OS_TICKS_PER_SEC * (long) millis) / 1000;
			if (ticks < 1) ticks = 1;
			while (ticks > 0)
			{
				if (ticks > 0xFFFF)
				{
					::OSTimeDly(0xFFFF);
					ticks -= 0xFFFF;
				}
				else
				{
					::OSTimeDly(ticks);
					ticks = 0;
				}
			}
			return true;

		}
	}
}

#endif /* __NIOS2__ */
