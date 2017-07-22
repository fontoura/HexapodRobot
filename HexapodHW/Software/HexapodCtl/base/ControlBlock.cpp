/*
 * ControlBlock.cpp
 *
 *  Created on: 11/09/2013
 */

#include "./ControlBlock.h"

#ifdef __WIN32__
#include "windows.h"
#endif /* __WIN32__ */

#ifdef __NIOS2__
#include <FreeRTOS.h>
#include <portmacro.h>
#endif /* __NIOS2__ */

namespace base
{
#ifdef DEBUG_BASE_CONTROLBLOCK
	ControlBlock::m_lastId = 0;
#endif /* DEBUG_BASE_CONTROLBLOCK */

#ifdef _POOLS_ENABLED
	ControlBlockStack blocks;
#endif /* _POOLS_ENABLED */

#ifdef __WIN32__
	class Win32Lock
	{
		private:
			HANDLE m_handle;
		public:
			Win32Lock()
			{
				m_handle = ::CreateSemaphore(NULL, 1, 1, NULL);
			};

			inline void enterCritical()
			{
				WaitForSingleObject(m_handle, INFINITE);
			};

			inline void exitCritical()
			{
				ReleaseSemaphore(m_handle, 1, NULL);
			};
	};

	Win32Lock win32Lock;
#endif /* __WIN32__ */

	void ControlBlock::enterCritical()
	{
#ifdef __WIN32__
		win32Lock.enterCritical();
#endif /* __WIN32__ */
#ifdef __NIOS2__
		vTaskEnterCritical();
#endif /* __NIOS2__ */
	}

	void ControlBlock::exitCritical()
	{
#ifdef __WIN32__
		win32Lock.exitCritical();
#endif /* __WIN32__ */
#ifdef __NIOS2__
		vTaskExitCritical();
#endif /* __NIOS2__ */

	}
}



