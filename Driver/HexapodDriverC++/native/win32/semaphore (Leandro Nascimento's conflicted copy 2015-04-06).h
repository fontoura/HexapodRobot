/*
 * semaphore.h
 *
 *  Created on: 23/03/2013
 *      Author: Felipe Michels Fontoura
 */

#ifdef _WIN32

#ifndef NATIVE_WIN32_SEMAPHORE_H_
#define NATIVE_WIN32_SEMAPHORE_H_

#include "defines.h"
#include <windows.h>

namespace native
{
	namespace win32
	{
		bool semaphore_create(HANDLE& hSemaphore, int count, int maximum);
		bool semaphore_destroy(HANDLE& hSemaphore);
		bool semaphore_down(HANDLE hSemaphore, long millis);
		bool semaphore_up(HANDLE hSemaphore);
		bool semaphore_query(HANDLE hSemaphore, int* count);
	}
}


#endif /* NATIVE_WIN32_SEMAPHORE_H_ */

#endif /* _WIN32 */
