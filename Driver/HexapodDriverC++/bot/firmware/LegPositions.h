/*
 * LegPositions.h
 *
 *  Created on: 05/04/2013
 */

#ifndef BOT_FIRMWARE_LEGPOSITIONS_H_
#define BOT_FIRMWARE_LEGPOSITIONS_H_

#include "../../globaldefs.h"
#include "../../base.h"
#include "../../concurrent.managed.h"

#include <stdint.h>

namespace bot
{
	namespace firmware
	{
		/**
		 * Estrutura com a posição de uma pata.
		 */
		struct LegPositions {
			int xyz[6][3];
		};
	}
}

#endif /* BOT_FIRMWARE_LEGPOSITIONS_H_ */
