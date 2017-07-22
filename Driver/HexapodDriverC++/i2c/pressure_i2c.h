#ifndef PRESSURE_I2C_H
#define PRESSURE_I2C_H

#ifdef __NIOS2__

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#include "alt_types.h"

void pressure_i2c_init();

void pressure_i2c_read(alt_32 press_temp[2]);

//void pressure_i2c_get_calibration_data();

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __NIOS2__ */

#endif
