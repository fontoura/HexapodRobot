#ifndef ACCELEROMETER_I2C_H
#define ACCELEROMETER_I2C_H

#ifdef __NIOS2__

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#include "alt_types.h"

#define ACCELEROMETER_MG_PER_DIGI 1
#define ACCELEROMETER_OFFSET_X 0
#define ACCELEROMETER_OFFSET_Y 0
#define ACCELEROMETER_OFFSET_Z 0

void accelerometer_i2c_init();

void accelerometer_i2c_read(alt_16 szXYZ[3]);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __NIOS2__ */

#endif
