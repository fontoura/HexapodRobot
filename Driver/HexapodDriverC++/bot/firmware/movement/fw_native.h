/*
 * fw_native.h
 *
 *  Created on: 05/04/2013
 */

#ifndef BOT_FIRMWARE_MOVEMENT_FW_NATIVE_H_
#define BOT_FIRMWARE_MOVEMENT_FW_NATIVE_H_

#include "../../../constants.h"
#include "../../../bot/firmware/LegPositions.h"
#define SET_LEG(a,b,c,d) {a[0]=b;a[1]=c;a[2]=d;}
#define COPY_ALL(A,B) {memcpy(A[0],B[0],3*sizeof(int));memcpy(A[1],B[1],3*sizeof(int));memcpy(A[2],B[2],3*sizeof(int));memcpy(A[3],B[3],3*sizeof(int));memcpy(A[4],B[4],3*sizeof(int));memcpy(A[5],B[5],3*sizeof(int));}

namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			template<int NumInterpol>
			void interpolate(LegPositions* interpol, LegPositions& start, LegPositions& end);

			template<int NumInterpol>
			void move(int delay, LegPositions* interpol, LegPositions& start, LegPositions& end);

			void move(LegPositions& leg, int delayMicros);
		}
	}
}

#include "fw_native.hpp"

#endif /* BOT_FIRMWARE_MOVEMENT_FW_NATIVE_H_ */
