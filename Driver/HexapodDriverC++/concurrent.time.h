/*
 * concurrent.time.h
 *
 *  Created on: 8/12/2012
 */

#ifndef CONCURRENT_TIME_H_
#define CONCURRENT_TIME_H_

#include "base/all.h"

namespace concurrent
{
	namespace time
	{
		class Stoptimer :
			public base::Object
		{
			protected:
				inline Stoptimer();
				inline virtual ~Stoptimer();
			public:
				virtual void reset() = 0;
				virtual unsigned long long getMilliseconds() = 0;
				static Stoptimer* create();
		};
	}
}

#include "./concurrent.time.hpp"

#endif
