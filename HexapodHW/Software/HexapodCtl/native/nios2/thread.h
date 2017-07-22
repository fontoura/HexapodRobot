/*
 * thread.h
 *
 *  Created on: 08/09/2013
 */

#ifdef __NIOS2__

#ifndef NATIVE_NIOS2_THREAD_H_
#define NATIVE_NIOS2_THREAD_H_

#include "./defines.h"

#include <FreeRTOS.h>
#include <task.h>

namespace native
{
	namespace niosii
	{
		inline bool thread_create(xTaskHandle* task, unsigned portSHORT stack_size, pdTASK_CODE function, void* parameter, int desiredPriority);
		inline bool thread_destroy(xTaskHandle task);
		inline bool thread_sleep(long millis);
	}
}

#include "./thread.hpp"

#endif /* NATIVE_NIOS2_THREAD_H_ */

#endif /* __NIOS2__ */
