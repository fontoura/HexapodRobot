#ifndef GYROSCOPE_I2C_H
#define GYROSCOPE_I2C_H

#ifdef __NIOS2__

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#include "alt_types.h"

void gyroscope_i2c_init();

void gyroscope_i2c_read(alt_16 szXYZ[3]);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __NIOS2__ */

#endif
