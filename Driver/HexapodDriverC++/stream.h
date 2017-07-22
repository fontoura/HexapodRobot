/*
 * stream.h
 *
 *  Created on: 03/12/2012
 */

#ifndef STREAM_H_
#define STREAM_H_

#include <stdint.h>
#include "base/all.h"

namespace stream
{
	/**
	 * Class defining an generic stream.
	 */
	class Stream :
		public virtual base::Object
	{
		public:
			Stream()
			{
			}

			virtual ~Stream()
			{
			}

			virtual bool open() = 0;
			virtual bool close() = 0;
			virtual bool isOpen() = 0;
			virtual bool setTimeouts(int absolute, int relative) = 0;
			virtual void getTimeouts(int* absolute, int* relative) = 0;
			virtual int read(uint8_t* buffer, int offset, int length) = 0;
			virtual int write(uint8_t* buffer, int offset, int length) = 0;
	};

}

#endif /* STREAM_H_ */
