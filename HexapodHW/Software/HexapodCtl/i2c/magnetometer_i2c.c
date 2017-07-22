#ifdef __NIOS2__

#include "magnetometer_i2c.h"
#include "interface_i2c.h"
#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "math.h"
#include "unistd.h"

#define HMC5883_ADDR 0x1E
#define CRA 0
#define CRB 1
#define MR 2
#define DXRA 3
#define DXRB 4
#define DYRA 5
#define DYRB 6
#define DZRA 7
#define DZRB 8
#define SR 9
#define IRA 10
#define IRB 11
#define IRC 12
#define GAIN 1024

float self_test_x, self_test_y, self_test_z;
float expected_x, expected_y, expected_z;
float compensation_x, compensation_y, compensation_z;
char flag_first_read = 1;

void compass_i2c_self_test();

void magnetometer_i2c_init(){
	i2c_write_register(HMC5883_ADDR, CRB, 0x01 << 5); //
	//i2c_write_register(HMC5883_ADDR, CRB, 0x60);
	compass_i2c_self_test();
	i2c_write_register(HMC5883_ADDR, MR, 0x00); //continuous measurement mode
	i2c_write_register(HMC5883_ADDR, CRA, /*i2c_read_register(HMC5883_ADDR,CRA) |*/ 0x18); //set 75Hz data output rate
	//i2c_write_register(HMC5883_ADDR, CRB, 0x01 << 5);
};

void compass_i2c_self_test(){
	i2c_write_register(HMC5883_ADDR, CRA, 0x11);
	i2c_write_register(HMC5883_ADDR, MR, 0x01);
	usleep(100e3);
	self_test_x = (i2c_read_register(HMC5883_ADDR, DXRA)<<8) | i2c_read_register(HMC5883_ADDR, DXRB);
	self_test_y = (i2c_read_register(HMC5883_ADDR, DYRA)<<8) | i2c_read_register(HMC5883_ADDR, DYRB);
	self_test_z = (i2c_read_register(HMC5883_ADDR, DZRA)<<8) | i2c_read_register(HMC5883_ADDR, DZRB);
};

void magnetometer_i2c_read(alt_16 szXYZ[3]){
	alt_u8 byte_number = 6;
	//alt_u8 byte[byte_number];
	i2c_write_data(HMC5883_ADDR, DXRA);
	//i2c_request_from(HMC5883_ADDR, byte, byte_number);
	float x, y, z;
	/*szXYZ[0] = (byte[0] << 8) | byte[1]; //x
	szXYZ[2] = (byte[2] << 8) | byte[3]; //z
	szXYZ[1] = (byte[4] << 8) | byte[5]; //y*/

	if(flag_first_read){
		szXYZ[0] = ((i2c_read_register(HMC5883_ADDR, DXRA)<<8) | i2c_read_register(HMC5883_ADDR, DXRB));
		szXYZ[1] = ((i2c_read_register(HMC5883_ADDR, DYRA)<<8) | i2c_read_register(HMC5883_ADDR, DYRB));
		szXYZ[2] = ((i2c_read_register(HMC5883_ADDR, DZRA)<<8) | i2c_read_register(HMC5883_ADDR, DZRB));
		expected_x = GAIN*1.1;
		expected_y = GAIN*1.1;
		expected_z = GAIN*1.1;
		compensation_x = expected_x/self_test_x;
		compensation_y = expected_y/self_test_y;
		compensation_z = expected_z/self_test_z;
		flag_first_read = 0;
	}
	else{
		szXYZ[0] = ((i2c_read_register(HMC5883_ADDR, DXRA)<<8) | i2c_read_register(HMC5883_ADDR, DXRB));
		szXYZ[1] = ((i2c_read_register(HMC5883_ADDR, DYRA)<<8) | i2c_read_register(HMC5883_ADDR, DYRB));
		szXYZ[2] = ((i2c_read_register(HMC5883_ADDR, DZRA)<<8) | i2c_read_register(HMC5883_ADDR, DZRB));
		x = compensation_x*(float)(szXYZ[0]);
		y = compensation_y*(float)(szXYZ[1]);
		z = compensation_z*(float)(szXYZ[2]);
		szXYZ[0] = x;
		szXYZ[1] = y;
		szXYZ[2] = z;
	}
	/*szXYZ[0] = ((i2c_read_register(HMC5883_ADDR, DXRA)<<8) | i2c_read_register(HMC5883_ADDR, DXRB));
	szXYZ[1] = ((i2c_read_register(HMC5883_ADDR, DYRA)<<8) | i2c_read_register(HMC5883_ADDR, DYRB));
	szXYZ[2] = ((i2c_read_register(HMC5883_ADDR, DZRA)<<8) | i2c_read_register(HMC5883_ADDR, DZRB));*/
};

void magnetometer_i2c_compensate_with_accelerometer(alt_16 szXYZ[3], float pitch, float roll){
	alt_16 x;
	alt_16 y_old, y_new;
	alt_16 z_old, z_new;

	y_old = szXYZ[1];
	z_old = szXYZ[2];
	x = szXYZ[0];
	y_new = y_old*cos(pitch) + x*sin(pitch);
	z_new = y_old*sin(roll) + z_old*cos(roll) - x*sin(roll)*cos(pitch);

	szXYZ[1] = y_new;
	szXYZ[2] = z_new;
};

#endif /* __NIOS2__ */
