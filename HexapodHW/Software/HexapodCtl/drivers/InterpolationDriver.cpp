/*
 * InterpolationDriver.cpp
 *
 *  Created on: 09/09/2013
 */

#include "InterpolationDriver.h"
#include "../globaldefs.h"
#include "../base/all.h"
#include "../concurrent/managed/all.h"
#include "LegsDriver.h"
#include <unistd.h>

#ifdef __WIN32__
#include <windows.h>
#include <winbase.h>
inline void usleep(int waitTime) {
	__int64 time1 = 0, time2 = 0, freq = 0;
	QueryPerformanceCounter((LARGE_INTEGER *) &time1);
	QueryPerformanceFrequency((LARGE_INTEGER *)&freq);

	do {
		QueryPerformanceCounter((LARGE_INTEGER *) &time2);
	} while((time2-time1) < waitTime);
}
#endif

#define MAX_INTERPOL 2048
#define ENLARGE(x) ((x)<<12)
#define REDUCE(x) ((x)>>12)

namespace drivers
{
	class InterpolationDriverImpl :
		public InterpolationDriver
	{
		friend class InterpolationDriver;
		_pool_decl(InterpolationDriverImpl, 1)

		private:
			_strong(LegsDriver) m_legsDriver;
			struct { int x, y, z; } m_interpol[MAX_INTERPOL][6];

		protected:
			InterpolationDriverImpl();
			virtual ~InterpolationDriverImpl();
			virtual void initialize();
			virtual void finalize();

		public:
			bool move(int time, int steps);
	};

	_pool_inst(InterpolationDriverImpl, 1)

	InterpolationDriver* InterpolationDriver::create()
	{
		_new_inst(InterpolationDriverImpl, driver);
		driver->initialize();
		return driver;
	}

	InterpolationDriverImpl::InterpolationDriverImpl()
	{
	}

	InterpolationDriverImpl::~InterpolationDriverImpl()
	{
	}

	void InterpolationDriverImpl::initialize()
	{
		m_legsDriver = LegsDriver::create();
	}

	void InterpolationDriverImpl::finalize()
	{
		m_legsDriver = NULL;
		_del_inst(InterpolationDriverImpl);
	}

	bool InterpolationDriverImpl::move(int time, int steps)
	{
		if (time > 0 && steps > 0)
		{
			int delay = time/steps;

			struct { int x, y, z; } initial[6], delta[6];

			if (steps > MAX_INTERPOL)
			{
				// TODO segmenta o movimento em vários sub-movimentos.
				steps = MAX_INTERPOL;
			}

			// faz a interpolação.
			for (int l = 0; l < 6; l++)
			{
				initial[l].x = ENLARGE(m_legsDriver->getX(l));
				initial[l].y = ENLARGE(m_legsDriver->getY(l));
				initial[l].z = ENLARGE(m_legsDriver->getZ(l));
				delta[l].x = (ENLARGE(m_xyz[l].x) - initial[l].x)/steps;
				delta[l].y = (ENLARGE(m_xyz[l].y) - initial[l].y)/steps;
				delta[l].z = (ENLARGE(m_xyz[l].z) - initial[l].z)/steps;
			}
			for (int s = 0; s < steps; s++)
			{
				for (int l = 0; l < 6; l ++)
				{
					m_interpol[s][l].x = REDUCE(initial[l].x + s*delta[l].x);
					m_interpol[s][l].y = REDUCE(initial[l].y + s*delta[l].y);
					m_interpol[s][l].z = REDUCE(initial[l].z + s*delta[l].z);
				}
			}

			// realiza o movimento.
			for (int s = 0; s < steps; s++)
			{
				for (int l = 0; l < 6; l ++)
				{
					m_legsDriver->setPosition(l, m_interpol[s][l].x, m_interpol[s][l].y, m_interpol[s][l].z);
				}
				m_legsDriver->flush();
				usleep(delay);
			}
		}

		// termina o movimento.
		for (int l = 0; l < 6; l ++)
		{
			m_legsDriver->setPosition(l, m_xyz[l].x, m_xyz[l].y, m_xyz[l].z);
		}
		m_legsDriver->flush();

		return true;
	}

}
