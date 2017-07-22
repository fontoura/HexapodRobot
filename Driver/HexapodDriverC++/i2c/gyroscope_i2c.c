#ifdef __NIOS2__

#include "gyroscope_i2c.h"
#include "interface_i2c.h"
#include "system.h"

#define L3G4200D_ADDR 0x69
#define WHO_AM_I 0x0F
#define CTRL_REG1 0x20
#define CTRL_REG2 0x21
#define CTRL_REG3 0x22
#define CTRL_REG4 0x23
#define CTRL_REG5 0x24
#define OUT_X_L 0x28
#define OUT_X_H 0x29
#define OUT_Y_L 0x2A
#define OUT_Y_H 0x2B
#define OUT_Z_L 0x2C
#define OUT_Z_H 0x2D

void gyroscope_i2c_init(){
	//From  Jim Lindblom of Sparkfun's code

	// Enable x, y, z and -turn off power down:
	//i2c_write_register(L3G4200D_ADDR, CTRL_REG1, 0x0F);//writeRegister(L3G4200D_Address, CTRL_REG1, 0b00001111); ODR 100Hz
	i2c_write_register(L3G4200D_ADDR, CTRL_REG1, 0xCF); //ODR 400Hz

	// If you'd like to adjust/use the HPF, you can edit the line below to configure CTRL_REG2:
	i2c_write_register(L3G4200D_ADDR, CTRL_REG2, 0x00);//writeRegister(L3G4200D_Address, CTRL_REG2, 0b00000000);

	// Configure CTRL_REG3 to generate data ready interrupt on INT2
	// No interrupts used on INT1, if you'd like to configure INT1
	// or INT2 otherwise, consult the datasheet:
	i2c_write_register(L3G4200D_ADDR, CTRL_REG3, 0x00);

	// CTRL_REG4 controls the full-scale range, among other things:

	/*if(scale == 250){
		writeRegister(L3G4200D_Address, CTRL_REG4, 0b00000000);
	}else if(scale == 500){
		writeRegister(L3G4200D_Address, CTRL_REG4, 0b00010000);
	}else{
		writeRegister(L3G4200D_Address, CTRL_REG4, 0b00110000);
	}*/

	i2c_write_register(L3G4200D_ADDR, CTRL_REG4, 0x30);

	// CTRL_REG5 controls high-pass filtering of outputs, use it
	// if you'd like:
	//writeRegister(L3G4200D_Address, CTRL_REG5, 0b00000000);
};

void gyroscope_i2c_read(alt_16 szXYZ[3]){
	alt_u8 xMSB = i2c_read_register(L3G4200D_ADDR, OUT_X_H);
	alt_u8 xLSB = i2c_read_register(L3G4200D_ADDR, OUT_X_L);
	szXYZ[0] = ((xMSB << 8) | xLSB);

	alt_u8 yMSB = i2c_read_register(L3G4200D_ADDR, OUT_Y_H);
	alt_u8 yLSB = i2c_read_register(L3G4200D_ADDR, OUT_Y_L);
	szXYZ[1] = ((yMSB << 8) | yLSB);

	alt_u8 zMSB = i2c_read_register(L3G4200D_ADDR, OUT_Z_H);
	alt_u8 zLSB = i2c_read_register(L3G4200D_ADDR, OUT_Z_L);
	szXYZ[2] = ((zMSB << 8) | zLSB);
};

#endif /* __NIOS2__ */
