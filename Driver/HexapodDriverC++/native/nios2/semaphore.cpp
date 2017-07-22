/*
 * semaphore.cpp
 *
 *  Created on: 23/03/2013
 *      Author: Felipe Michels Fontoura
 */

#ifdef __NIOS2__

#include "semaphore.h"
#include "includes.h"
#include <cstdlib>

#define SEMAQUERYINFOCLASS 0

extern "C"
{
	INT8U OSSemQueryCount(OS_EVENT *pevent, INT16U *pcount)
	{
		OS_SEM_DATA semdata;
		if (OS_NO_ERR == ::OSSemQuery(pevent, &semdata))
		{
			*pcount = semdata.OSCnt;
			return -1;
		}
		else
		{
			return 0;
		}
	}
}

namespace native
{
	namespace niosii
	{
		bool semaphore_create(OS_EVENT*& osEvent, int count)
		{
			OS_EVENT* event = ::OSSemCreate(count);
			osEvent = event;
			return event != NULL;
		}

		bool semaphore_destroy(OS_EVENT*& osEvent)
		{
			INT8U error = OS_NO_ERR;
			OS_EVENT* event = ::OSSemDel(osEvent, OS_DEL_ALWAYS, &error);
			return event != NULL;
		}

		bool semaphore_down(OS_EVENT* osEvent, long millis)
		{
			OS_EVENT* event = osEvent;
			if (event != NULL)
			{
				if (0 == millis)
				{
					return ::OSSemAccept(event) > 0;
				}
				else if (millis < 0)
				{
					INT8U error = OS_NO_ERR;
					::OSSemPend(event, 0, &error);
					return error == OS_NO_ERR;
				}
				else
				{
					INT8U error = OS_NO_ERR;
					long ticks = (OS_TICKS_PER_SEC * (long)millis) / 1000;
					while (ticks > 0)
					{
						INT16U timeout;
						if (ticks > 0xFFFF)
						{
							timeout = 0xFFFF;
							ticks -= 0xFFFF;
						}
						else
						{
							timeout = (INT16U) ticks;
							ticks = 0;
						}
						::OSSemPend(event, timeout, &error);
						ticks -= 0xFFFF;
						if (error == OS_NO_ERR)
						{
							return true;
						}
						else if (error != OS_TIMEOUT)
						{
							return false;
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

		bool semaphore_up(OS_EVENT* osEvent)
		{
			return ::OSSemPost(osEvent) == OS_NO_ERR;
		}

		bool semaphore_query(OS_EVENT* osEvent, int* count)
		{
			if (osEvent != NULL)
			{
				INT16U query = 0;
				if (::OSSemQueryCount(osEvent, &query))
				{
					*count = (int)query;
					return true;
				}
				else
				{
					*count = -1;
					return false;
				}
			}
			else
			{
				*count = 0;
				return false;
			}
		}
	}
}

#endif /* __NIOS2__ */
