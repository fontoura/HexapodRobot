/*
 * semaphore.h
 *
 *  Created on: 23/03/2013
 *      Author: Felipe Michels Fontoura
 */

#ifdef __NIOS2__

#ifndef NATIVE_NIOS2_SEMAPHORE_H_
#define NATIVE_NIOS2_SEMAPHORE_H_

#include "defines.h"
#include "includes.h"

namespace native
{
	namespace niosii
	{
		bool semaphore_create(OS_EVENT*& osEvent, int count);
		bool semaphore_destroy(OS_EVENT*& osEvent);
		bool semaphore_down(OS_EVENT* osEvent, long millis);
		bool semaphore_up(OS_EVENT* osEvent);
		bool semaphore_query(OS_EVENT* hSemaphore, int* count);
	}
}


#endif /* NATIVE_NIOS2_SEMAPHORE_H_ */

#endif /* __NIOS2__ */
