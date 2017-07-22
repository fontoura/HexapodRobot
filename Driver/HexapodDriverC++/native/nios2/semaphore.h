/*
 * semaphore.h
 *
 *  Created on: 08/09/2013
 */

#ifdef __NIOS2__

#ifndef NATIVE_NIOS2_SEMAPHORE_H_
#define NATIVE_NIOS2_SEMAPHORE_H_

#include "./defines.h"

#include <FreeRTOS.h>
#include <semphr.h>

namespace native
{
	namespace niosii
	{
		inline xSemaphoreHandle semaphore_create(int count, int maximum);
		inline void semaphore_destroy(xSemaphoreHandle handle);
		inline bool semaphore_down(xSemaphoreHandle handle, long millis);
		inline bool semaphore_up(xSemaphoreHandle handle);
		inline int semaphore_query(xSemaphoreHandle handle);
	}
}

#include "./semaphore.hpp"

#endif /* NATIVE_NIOS2_SEMAPHORE_H_ */

#endif /* __NIOS2__ */
