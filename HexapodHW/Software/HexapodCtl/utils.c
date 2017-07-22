#include "utils.h"
#include "constants.h"
#include <math.h>

float deg_to_rad(float degree)
{
	return (degree*PI/180.0);
}

float rad_to_deg(float rad)
{
	return rad*(180.0/PI);
}

#ifdef __NIOS2__
//equation from http://www.adafruit.com/datasheets/BMP085_DataSheet_Rev.1.0_01July2008.pdf p13
float calculate_altitude(alt_32 pressure)
{
	return (44330.0 * (1.0 - pow((float)pressure/P_SEA_LEVEL, 1/5.255)));
}

#endif /* __NIOS2__ */
