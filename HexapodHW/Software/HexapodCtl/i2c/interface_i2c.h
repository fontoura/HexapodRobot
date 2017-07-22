#ifndef INTERFACE_I2C_H
#define INTERFACE_I2C_H

#ifdef __NIOS2__

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#include "alt_types.h"

void i2c_set_clock(alt_u32 system_clock, alt_u32 desired_scl);

int i2c_write_data(unsigned char slave_address, unsigned char data);

int i2c_write_register(unsigned char slave_address, unsigned char memory_address, unsigned char data);

alt_u8 i2c_read_register(unsigned char slave_address, unsigned char memory_address);

void i2c_request_from(unsigned char slave_address, unsigned char byte[], unsigned char byteNumber);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __NIOS2__ */

#endif
