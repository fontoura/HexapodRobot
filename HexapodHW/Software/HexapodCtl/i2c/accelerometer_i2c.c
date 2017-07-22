#ifdef __NIOS2__

#include "accelerometer_i2c.h"
#include "interface_i2c.h"
#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "math.h"
#include "unistd.h"

#define ADXL345_ADDR 0x53
#define BW_RATE 0x2C
#define POWER_CTL 0x2D
#define DATA_FORMAT 0x31
#define DATAX0 0x32
#define DATAX1 0x33
#define DATAY0 0x34
#define DATAY1 0x35
#define DATAZ0 0x36
#define DATAZ1 0x37

void accelerometer_i2c_init(){
	i2c_write_register(ADXL345_ADDR, DATA_FORMAT, (1 << 3) || 0x10); //full_res mode
	//i2c_write_register(ADXL345_ADDR, DATA_FORMAT, (1 << 3) || 0x03); //full_res mode
	i2c_write_register(ADXL345_ADDR, BW_RATE, 0xC); //400Hz rate
	i2c_write_register(ADXL345_ADDR, POWER_CTL, 0); //standby
	i2c_write_register(ADXL345_ADDR, POWER_CTL, 1 << 3); //start measure
};

void accelerometer_i2c_read(alt_16 szXYZ[3]){
	szXYZ[0] = ((i2c_read_register(ADXL345_ADDR, DATAX1)<<8) | i2c_read_register(ADXL345_ADDR, DATAX0));
	szXYZ[1] = ((i2c_read_register(ADXL345_ADDR, DATAY1)<<8) | i2c_read_register(ADXL345_ADDR, DATAY0));
	szXYZ[2] = ((i2c_read_register(ADXL345_ADDR, DATAZ1)<<8) | i2c_read_register(ADXL345_ADDR, DATAZ0));
};

#endif /* __NIOS2__ */
