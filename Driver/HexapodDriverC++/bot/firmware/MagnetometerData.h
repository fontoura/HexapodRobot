/*
 * MagnetometerData.h
 *
 *  Created on: 06/04/2013
 */

#ifndef BOT_FIRMWARE_MAGNETOMETERDATA_H_
#define BOT_FIRMWARE_MAGNETOMETERDATA_H_

#include "../../globaldefs.h"
#include "../../base/all.h"
#include "../../concurrent/managed/all.h"

#include <stdint.h>

namespace bot
{
	namespace firmware
	{
		/**
		 * Estrutura com medidas do magnetômetro.
		 */
		struct MagnetometerData
		{
			int16_t xyz[3];
			float heading;
		};
	}
}

#endif /* BOT_FIRMWARE_MAGNETOMETERDATA_H_ */
