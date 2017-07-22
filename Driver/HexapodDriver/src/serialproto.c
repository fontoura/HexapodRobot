/*
 * serialproto.c
 *
 *  Created on: 05/11/2012
 *      Author: Felipe Michels Fontoura
 */

#include "serialproto.h"

void* __SERIALPROTO_THREAD_BODY(void* genericParams)
{
	serialproto_comm_ptr params = (serialproto_comm_ptr)genericParams;

	threads_semaphore_down(params->jobListMutex);
	serialproto_job_ptr nextJob = params->jobList_first;
	if (nextJob != NULL)
	{
		params->jobList_first = nextJob->next;
		if (params->jobList_last == nextJob)
		{
			params->jobList_last = NULL;
		}
	}
	threads_semaphore_up(params->jobListMutex);

	while (nextJob != NULL)
	{
		nextJob->action(nextJob->param);
		threads_semaphore_down(params->jobListMutex);
		serialproto_job_ptr nextJob = params->jobList_first;
		if (nextJob != NULL)
		{
			params->jobList_first = nextJob->next;
			if (params->jobList_last == nextJob)
			{
				params->jobList_last = NULL;
			}
		}
		threads_semaphore_up(params->jobListMutex);
	}
}

int serialproto_init()
{
	return 0;
}

void serialproto_finalize() { }
