/*
 * thread.h
 *
 *  Created on: 25/03/2013
 *      Author: Felipe Michels Fontoura
 */

#ifdef __NIOS2__

#ifndef NATIVE_NIOS2_THREAD_H_
#define NATIVE_NIOS2_THREAD_H_

#include "defines.h"
#include "includes.h"

namespace native
{
	namespace niosii
	{
		bool thread_create(INT8U& priority, OS_STK* stack, INT16U stack_size, void(*function)(void*), void* parameter, int desiredPriority);
		bool thread_destroy(INT8U& priority);
		bool thread_sleep(long millis);
	}
}

#endif /* NATIVE_NIOS2_THREAD_H_ */

#endif /* __NIOS2__ */
