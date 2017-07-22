/*
 * concurrent.time.h
 *
 *  Created on: 8/12/2012
 *      Author: Felipe Michels Fontoura
 */

#ifndef CONCURRENT_TIME_H_
#define CONCURRENT_TIME_H_

#include "base.h"

namespace concurrent
{
	namespace time
	{
		class Stoptimer :
			public base::Object
		{
			protected:
				Stoptimer();
				virtual ~Stoptimer();
				virtual void initialize();
				virtual void finalize();
			public:
				virtual void reset() = 0;
				virtual unsigned long long getMilliseconds() = 0;
				static Stoptimer* create();
		};
	}
}

#endif
