#ifdef __NIOS2__

#include "pressure_i2c.h"
#include "interface_i2c.h"
#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "math.h"
#include "unistd.h"

#define BMP085_ADDR 0x77
#define AC1hi 0xAA
#define AC1lo 0xAB
#define AC2hi 0xAC
#define AC2lo 0xAD
#define AC3hi 0xAE
#define AC3lo 0xAF
#define AC4hi 0xB0
#define AC4lo 0xB1
#define AC5hi 0xB2
#define AC5lo 0xB3
#define AC6hi 0xB4
#define AC6lo 0xB5
#define B1hi 0xB6
#define B1lo 0xB7
#define B2hi 0xB8
#define B2lo 0xB9
#define MBhi 0xBA
#define MBlo 0xBB
#define MChi 0xBC
#define MClo 0xBD
#define MDhi 0xBE
#define MDlo 0xBF

// oversampling setting
// 0 = ultra low power
// 1 = standard
// 2 = high
// 3 = ultra high resolution
#define OVERSAMPLING_SETTING 3
const unsigned char pressure_conversiontime[4] = {5, 8, 14, 26 };

// sensor registers from the BOSCH BMP085 datasheet
alt_16 ac1;
alt_16 ac2;
alt_16 ac3;
alt_u16 ac4;
alt_u16 ac5;
alt_u16 ac6;
alt_16 b1;
alt_16 b2;
alt_16 mb;
alt_16 mc;
alt_16 md;

void pressure_i2c_init(){
	pressure_i2c_get_calibration_data();
};

void pressure_i2c_get_calibration_data(){
	ac1 = (i2c_read_register(BMP085_ADDR, AC1hi) << 8) | i2c_read_register(BMP085_ADDR, AC1lo);
	ac2 = (i2c_read_register(BMP085_ADDR, AC2hi) << 8) | i2c_read_register(BMP085_ADDR, AC2lo);
	ac3 = (i2c_read_register(BMP085_ADDR, AC3hi) << 8) | i2c_read_register(BMP085_ADDR, AC3lo);
	ac4 = (i2c_read_register(BMP085_ADDR, AC4hi) << 8) | i2c_read_register(BMP085_ADDR, AC4lo);
	ac5 = (i2c_read_register(BMP085_ADDR, AC5hi) << 8) | i2c_read_register(BMP085_ADDR, AC5lo);
	ac6 = (i2c_read_register(BMP085_ADDR, AC6hi) << 8) | i2c_read_register(BMP085_ADDR, AC6lo);
	b1 = (i2c_read_register(BMP085_ADDR, B1hi) << 8) | i2c_read_register(BMP085_ADDR, B1lo);
	b2 = (i2c_read_register(BMP085_ADDR, B2hi) << 8) | i2c_read_register(BMP085_ADDR, B2lo);
	mb = (i2c_read_register(BMP085_ADDR, MBhi) << 8) | i2c_read_register(BMP085_ADDR, MBlo);
	mc = (i2c_read_register(BMP085_ADDR, MChi) << 8) | i2c_read_register(BMP085_ADDR, MClo);
	md = (i2c_read_register(BMP085_ADDR, MDhi) << 8) | i2c_read_register(BMP085_ADDR, MDlo);
};

alt_u32 pressure_i2c_read_uncompensated_pressure(){
	alt_u8 msb;
	alt_u8 lsb;
	alt_u8 xlsb;
	alt_u32 return_value;

	i2c_write_register(BMP085_ADDR, 0xF4, 0x34 + (OVERSAMPLING_SETTING<<6));
	usleep(OVERSAMPLING_SETTING*1000);
	msb = i2c_read_register(BMP085_ADDR, 0xF6);
	lsb = i2c_read_register(BMP085_ADDR, 0xF7);
	xlsb = i2c_read_register(BMP085_ADDR, 0xF8);
	return_value = (((msb<<16) | (lsb<<8) | xlsb) >> (8-OVERSAMPLING_SETTING));
	return return_value;
};

alt_u32 pressure_i2c_read_uncompensated_temperature(){
	alt_u8 msb;
	alt_u8 lsb;
	alt_u32 return_value;

	i2c_write_register(BMP085_ADDR, 0xF4, 0x2E);
	usleep(5e3);
	msb = i2c_read_register(BMP085_ADDR, 0xF6);
	lsb = i2c_read_register(BMP085_ADDR, 0xF7);
	return_value = (msb<<8) | lsb;
	return return_value;
};

void pressure_i2c_read(alt_32 press_temp[2]){
	alt_32  tval, pval;
	alt_32  x1, x2, x3, b3, b5, b6, p;
	alt_u32   b4, b7;
	alt_u32 ut = pressure_i2c_read_uncompensated_temperature();
	alt_u32 up = pressure_i2c_read_uncompensated_pressure();

	/*ut = 27898;
	up = 23843;
	ac1 = 408;
	ac2 = -72;
	ac3 = -14383;
	ac4 = 32741;
	ac5 = 32757;
	ac6 = 23153;
	b1 = 6190;
	b2 = 4;
	mb = -32768;
	mc = -8711;
	md = 2868;*/

	x1 = (ut - ac6) * ac5 >> 15;
	x2 = (mc << 11) / (x1 + md);
	b5 = x1 + x2;
	tval = (b5 + 8) >> 4;

	b6 = b5 - 4000;
	x1 = (b2 * (b6 * b6 >> 12)) >> 11;
	x2 = ac2 * b6 >> 11;
	x3 = x1 + x2;
	b3 = (((ac1 * 4 + x3)<<OVERSAMPLING_SETTING) + 2) >> 2; //err
	x1 = ac3 * b6 >> 13;
	x2 = (b1 * (b6 * b6 >> 12)) >> 16;
	x3 = ((x1 + x2) + 2) >> 2;
	b4 = (ac4 * (alt_u32) (x3 + 32768)) >> 15;
	b7 = ((alt_u32)up - b3) * (50000 >> OVERSAMPLING_SETTING);

	if(b7 < 0x80000000){
		p = (b7 * 2) / b4;
	}
	else{
		p = (b7 / b4) * 2;
	}
	//p = b7 < 0x80000000 ? (b7 * 2) / b4 : (b7 / b4) * 2;

	x1 = (p >> 8) * (p >> 8);
	x1 = (x1 * 3038) >> 16;
	x2 = (-7357 * p) >> 16;
	pval = p + ((x1 + x2 + 3791) >> 4);

	press_temp[0] = pval;
	press_temp[1] = tval/10;
};

#endif /* __NIOS2__ */
