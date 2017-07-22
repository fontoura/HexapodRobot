/*
 * concurrent.time.cpp
 *
 *  Created on: 8/12/2012
 *      Author: Felipe Michels Fontoura
 */

#include "globaldefs.h"
#include "concurrent.time.h"

#ifdef _WIN32
#define WINVER 0x0501
#define _WIN32_WINNT 0x0501
#include "windows.h"
#endif /* _WIN32 */

#ifdef __NIOS2__
#include <cstdlib>
#include "includes.h"
#endif /* __NIOS2__ */

namespace concurrent
{
	namespace time
	{
		Stoptimer::Stoptimer()
		{
		}

		Stoptimer::~Stoptimer()
		{
		}

		void Stoptimer::initialize()
		{
		}

#ifdef _WIN32

#define StoptimerImpl Win32Stoptimer

		class StoptimerImpl :
			public Stoptimer
		{
#ifdef _POOLS_ENABLED
				friend class base::ObjectPool<StoptimerImpl, _POOL_SIZE_FOR_STOPTIMERS>;
				static base::ObjectPool<StoptimerImpl, _POOL_SIZE_FOR_STOPTIMERS> m_pool;
#endif /* _POOLS_ENABLED */
				friend class Stoptimer;
			private:
				unsigned long m_base;
			protected:
				StoptimerImpl();
				~StoptimerImpl();
				void initialize();
				void finalize();
			public:
				void reset();
				unsigned long long getMilliseconds();
		};

		StoptimerImpl::StoptimerImpl()
		{
			m_base = 0;
		}

		StoptimerImpl::~StoptimerImpl()
		{
		}

		void StoptimerImpl::initialize()
		{
			Stoptimer::initialize();
			this->reset();
		}

		void StoptimerImpl::finalize()
		{
			Stoptimer::finalize();
		}

		void StoptimerImpl::reset()
		{
			m_base = 0xFFFFFFFF & ::GetTickCount();
		}

		unsigned long long StoptimerImpl::getMilliseconds()
		{
			unsigned long long ticks = 0xFFFFFFFF & ::GetTickCount();
			if (ticks < m_base)
			{
				ticks += 0x100000000ll;
			}
			return ticks - m_base;
		}

#endif /* _WIN32 */

#ifdef __NIOS2__

#define StoptimerImpl NiosStoptimer

		class StoptimerImpl :
			public Stoptimer
		{
				friend class Stoptimer;
			private:
#ifdef _POOLS_ENABLED
				friend class base::ObjectPool<StoptimerImpl, _POOL_SIZE_FOR_STOPTIMERS>;
				static base::ObjectPool<StoptimerImpl, _POOL_SIZE_FOR_STOPTIMERS> m_pool;
#endif /* _POOLS_ENABLED */
				unsigned long long m_base;
			protected:
				StoptimerImpl();
				~StoptimerImpl();
				void initialize();
				void finalize();
			public:
				void reset();
				unsigned long long getMilliseconds();
				static Stoptimer* create();
		};

		StoptimerImpl::StoptimerImpl()
		{
			m_base = 0;
		}

		StoptimerImpl::~StoptimerImpl()
		{
		}

		void StoptimerImpl::initialize()
		{
			Stoptimer::initialize();
			this->reset();
		}

		void StoptimerImpl::finalize()
		{
			Stoptimer::finalize();
		}

		void StoptimerImpl::reset()
		{
			unsigned long ticks = ::OSTimeGet() & 0xFFFFFFFF;
			m_base = (1000l * ticks) / OS_TICKS_PER_SEC;
		}

		unsigned long long StoptimerImpl::getMilliseconds()
		{
			unsigned long long ticks = 0xFFFFFFFF & ::OSTimeGet();
			unsigned long long millis = (1000l * ticks) / OS_TICKS_PER_SEC;
			if (millis < m_base)
			{
				millis += 0x100000000ll;
			}
			return millis - m_base;
		}

#endif /* __NIOS2__ */

#ifdef _POOLS_ENABLED

		base::ObjectPool<StoptimerImpl, _POOL_SIZE_FOR_STOPTIMERS> StoptimerImpl::m_pool;

		void Stoptimer::finalize()
		{
			Object::beforeRecycle();
			StoptimerImpl::m_pool.recycle(static_cast<StoptimerImpl*>(this));
		}

		Stoptimer* Stoptimer::create()
		{
			StoptimerImpl* stoptimer = StoptimerImpl::m_pool.obtain();
			stoptimer->initialize();
			return stoptimer;
		}

#else /* ifndef _POOLS_ENABLED */

		void Stoptimer::finalize()
		{
			Object::finalize();
		}

		Stoptimer* Stoptimer::create()
		{
#ifdef StoptimerImpl
			StoptimerImpl* stoptimer = new StoptimerImpl();
			stoptimer->initialize();
			return stoptimer;
#else /* ifndef StoptimerImpl */
			return NULL;
#endif /* StoptimerImpl */
		}

#endif /* _POOLS_ENABLED */
	}
}
