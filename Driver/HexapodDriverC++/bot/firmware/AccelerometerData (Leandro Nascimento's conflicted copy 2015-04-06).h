/*
 * AccelerometerData
 *
 *  Created on: 13/04/2013
 */

#ifndef BOT_FIRMWARE_ACCELEROMETERDATA_H_
#define BOT_FIRMWARE_ACCELEROMETERDATA_H_

#include "../../globaldefs.h"
#include "../../base.h"
#include "../../concurrent.managed.h"

#include <stdint.h>

namespace bot
{
	namespace firmware
	{
		/**
		 * Estrutura com medidas do magnetômetro.
		 */
		struct AccelerometerData
		{
			float xyz[3];
		};
	}
}

#endif /* BOT_FIRMWARE_ACCELEROMETERDATA_H_ */
