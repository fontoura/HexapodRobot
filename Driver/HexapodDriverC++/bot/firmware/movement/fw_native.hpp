/*
 * fw_native.hpp
 *
 *  Created on: 05/04/2013
 *      Author: Felipe
 */

#include <unistd.h>

namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			template<int NumInterpol>
			void interpolate(LegPositions* legm, LegPositions& leg0, LegPositions& leg1)
			{
				for (int l = 0; l < 6; l ++)
				{
					int delta_x = 100*(leg1.xyz[l][0] - leg0.xyz[l][0])/NumInterpol;
					int delta_y = 100*(leg1.xyz[l][1] - leg0.xyz[l][1])/NumInterpol;
					int delta_z = 100*(leg1.xyz[l][2] - leg0.xyz[l][2])/NumInterpol;
					for(int i = 0; i < NumInterpol; i++)
					{
						legm[i].xyz[l][0] = (100*leg0.xyz[l][0] + i*delta_x)/100;
						legm[i].xyz[l][1] = (100*leg0.xyz[l][1] + i*delta_y)/100;
						legm[i].xyz[l][2] = (100*leg0.xyz[l][2] + i*delta_z)/100;
					}
				}
			}

			template<int NumInterpol>
			void move(int delay, LegPositions* legsm, LegPositions& start, LegPositions& end)
			{
				interpolate<NumInterpol>(legsm, start, end);
				for (int j = 0; j < NumInterpol; j++)
				{
					move(legsm[j], delay);
				}
			};
		}
	}
}

