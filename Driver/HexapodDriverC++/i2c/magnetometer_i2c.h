#ifndef COMPASS_I2C_H
#define COMPASS_I2C_H

#ifdef __NIOS2__

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#include "alt_types.h"

/*#define MAGNETOMETER_OFFSET_X -50
#define MAGNETOMETER_OFFSET_Y 106
#define MAGNETOMETER_OFFSET_Z 228*/

#define MAGNETOMETER_OFFSET_X -50
#define MAGNETOMETER_OFFSET_Y (142+75-115)
#define MAGNETOMETER_OFFSET_Z (259-10)

void magnetometer_i2c_init();

void magnetometer_i2c_read(alt_16 szXYZ[3]);

void magnetometer_i2c_compensate_with_accelerometer(alt_16 szXYZ[3], float pitch, float roll);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __NIOS2__ */

#endif
