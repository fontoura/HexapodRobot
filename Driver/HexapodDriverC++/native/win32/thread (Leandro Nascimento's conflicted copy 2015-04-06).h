/*
 * thread.h
 *
 *  Created on: 25/03/2013
 *      Author: Felipe Michels Fontoura
 */

#ifdef _WIN32

#ifndef NATIVE_WIN32_THREAD_H_
#define NATIVE_WIN32_THREAD_H_

#include "defines.h"
#include <windows.h>

namespace native
{
	namespace win32
	{
		/* cria uma thread Win32 */
		bool thread_create(HANDLE& hThread, DWORD WINAPI (*function)(LPVOID), void* parameter);

		/* destrói o handle para uma thread Win32 */
		bool thread_destroy(HANDLE& hThread);

		/* acorda uma thread Win32 */
		bool thread_resume(HANDLE nThread);

		/* espera o término de uma thread Win32 */
		bool thread_join(HANDLE hThread, long millis);

		/* espera um certo tempo */
		bool thread_sleep(long millis);
	}
}


#endif /* NATIVE_WIN32_THREAD_H_ */

#endif /* _WIN32 */
