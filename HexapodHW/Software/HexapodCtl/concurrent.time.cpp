/*
 * concurrent.time.cpp
 *
 *  Created on: 8/12/2012
 */

#include "globaldefs.h"
#include "concurrent.time.h"

#ifdef __WIN32__
#define WINVER 0x0501
#define _WIN32_WINNT 0x0501
#include "windows.h"
#endif /* __WIN32__ */

#ifdef __NIOS2__
#include <cstdlib>
#include <FreeRTOS.h>
#include <task.h>
#endif /* __NIOS2__ */

namespace concurrent
{
	namespace time
	{
		class StoptimerImpl :
			public Stoptimer
		{
			friend class Stoptimer;
			_pool_decl(StoptimerImpl, _POOL_SIZE_FOR_STOPTIMERS)

			private:
#ifdef __WIN32__
				unsigned long m_base;
#endif /* __WIN32__ */
#ifdef __NIOS2__
				portTickType m_base;
#endif /* __NIOS2__ */

			protected:
				StoptimerImpl();
				~StoptimerImpl();
				void initialize();
				void finalize();
			public:
				void reset();
				unsigned long long getMilliseconds();
		};

		_pool_inst(StoptimerImpl, _POOL_SIZE_FOR_STOPTIMERS)

		Stoptimer* Stoptimer::create()
		{
			_new_inst(StoptimerImpl, stoptimer);
			stoptimer->initialize();
			return stoptimer;
		}

		StoptimerImpl::StoptimerImpl()
		{
		}

		StoptimerImpl::~StoptimerImpl()
		{
		}

		void StoptimerImpl::initialize()
		{
			this->reset();
		}

		void StoptimerImpl::finalize()
		{
			_del_inst(StoptimerImpl);
		}

		void StoptimerImpl::reset()
		{
#ifdef __WIN32__
			m_base = 0xFFFFFFFF & ::GetTickCount();
#endif /* __WIN32__ */
#ifdef __NIOS2__
			m_base = xTaskGetTickCount();
#endif /* __NIOS2__ */
		}

		unsigned long long StoptimerImpl::getMilliseconds()
		{
			unsigned long long millis = 0;
#ifdef __WIN32__
			millis = (0xFFFFFFFF & ::GetTickCount()) - m_base;
			if (millis < 0)
			{
				millis = millis + 0x100000000ll;
			}
#endif /* __WIN32__ */
#ifdef __NIOS2__
			millis = (xTaskGetTickCount() - m_base) * portTICK_RATE_MS;
#endif /* __NIOS2__ */
			return millis;
		}
	}
}
