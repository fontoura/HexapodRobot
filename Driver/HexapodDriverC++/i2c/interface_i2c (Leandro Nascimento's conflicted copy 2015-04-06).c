#ifdef __NIOS2__

#include "interface_i2c.h"
#include "system.h"
#include "altera_avalon_pio_regs.h"

#define PRERlo 0x00
#define PRERhi 0x01
#define CTR 0x02
#define TXR 0x03
#define RXR 0x03
#define CR 0x04
#define SR 0x04
#define STA 0x80
#define WR 0x10
#define TIP 0x02
#define IF 0x01
#define RxACK 0x80
#define STO 0x40
#define RD 0x20
#define ACK 0x08
#define EN 0x80

void i2c_set_clock(alt_u32 system_clock, alt_u32 desired_scl){
	int prescale = (system_clock/(5*desired_scl)) - 1;
	alt_u8 prescale_low;
	alt_u8 prescale_high;

	IOWR(I2C_MASTER_BASE, CTR, IORD(I2C_MASTER_BASE, CTR) & ~EN);//disable core to change clock
	prescale_low = prescale & 0x00FF;
	prescale_high = (prescale & 0xFF00) >> 8;
	IOWR(I2C_MASTER_BASE, PRERlo, prescale_low);
	IOWR(I2C_MASTER_BASE, PRERhi, prescale_high);
	IOWR(I2C_MASTER_BASE, CTR, IORD(I2C_MASTER_BASE, CTR) | EN);
	printf("New clock: %x %x\n", IORD(I2C_MASTER_BASE, PRERhi), IORD(I2C_MASTER_BASE, PRERlo));
};

int i2c_write_data(unsigned char slave_address, unsigned char data){
	IOWR(I2C_MASTER_BASE, TXR, slave_address << 1);
	IOWR(I2C_MASTER_BASE, CR, (STA|WR));
	while((IORD(I2C_MASTER_BASE, SR) & TIP) != 0);

	if((IORD(I2C_MASTER_BASE, SR) & RxACK) == 0){
		IOWR(I2C_MASTER_BASE, TXR, data);
		IOWR(I2C_MASTER_BASE, CR, WR);
		while((IORD(I2C_MASTER_BASE, SR) & TIP) != 0);

		if((IORD(I2C_MASTER_BASE, SR) & RxACK) == 0){
			IOWR(I2C_MASTER_BASE, CR, STO);
			return 1;
		}
	}
	return 0;
};

int i2c_write_register(unsigned char slave_address, unsigned char register_address, unsigned char data){
	IOWR(I2C_MASTER_BASE, TXR, slave_address << 1);
	IOWR(I2C_MASTER_BASE, CR, STA|WR);
	while((IORD(I2C_MASTER_BASE, SR) & TIP) != 0);

	if((IORD(I2C_MASTER_BASE, SR) & RxACK) == 0){
		IOWR(I2C_MASTER_BASE, TXR, register_address);
		IOWR(I2C_MASTER_BASE, CR, WR);
		while((IORD(I2C_MASTER_BASE, SR) & TIP) != 0);

		if((IORD(I2C_MASTER_BASE, SR) & RxACK) == 0){
			IOWR(I2C_MASTER_BASE, TXR, data);
			IOWR(I2C_MASTER_BASE, CR, WR);
			while((IORD(I2C_MASTER_BASE, SR) & TIP) != 0);

			if((IORD(I2C_MASTER_BASE, SR) & RxACK) == 0){
				IOWR(I2C_MASTER_BASE, CR, STO);
				return 1;
			}
		}
	}
	IOWR(I2C_MASTER_BASE, CR, STO);
	return 0;
};

alt_u8 i2c_read_register(unsigned char slave_address, unsigned char register_address){
	alt_u8 return_reg = -1;
	IOWR(I2C_MASTER_BASE, TXR, slave_address << 1);
	IOWR(I2C_MASTER_BASE, CR, STA|WR);
	while((IORD(I2C_MASTER_BASE, SR) & TIP) != 0);

	if((IORD(I2C_MASTER_BASE, SR) & RxACK) == 0){
		IOWR(I2C_MASTER_BASE, TXR, register_address);
		IOWR(I2C_MASTER_BASE, CR, WR);
		while((IORD(I2C_MASTER_BASE, SR) & TIP) != 0);

		if((IORD(I2C_MASTER_BASE, SR) & RxACK) == 0){
			IOWR(I2C_MASTER_BASE, TXR, (slave_address << 1) | 0x01);
			IOWR(I2C_MASTER_BASE, CR, STA|WR);
			while((IORD(I2C_MASTER_BASE, SR) & TIP) != 0);

			if((IORD(I2C_MASTER_BASE, SR) & RxACK) == 0){
				IOWR(I2C_MASTER_BASE, CR, RD|ACK|STO);
				while((IORD(I2C_MASTER_BASE, SR) & TIP) != 0);
				return_reg = IORD(I2C_MASTER_BASE, RXR);
			}
		}
	}
	IOWR(I2C_MASTER_BASE, CR, STO);
	return return_reg;
};

void i2c_request_from(unsigned char slave_address, unsigned char byte[], unsigned char byte_number){
	alt_u8 i;
	IOWR(I2C_MASTER_BASE, TXR, (slave_address << 1) | 0x01);
	IOWR(I2C_MASTER_BASE, CR, STA|WR);
	while((IORD(I2C_MASTER_BASE, SR) & TIP) != 0);

	if((IORD(I2C_MASTER_BASE, SR) & RxACK) == 0){ //starts to receive data bytes
		for(i = 0; i<byte_number - 1; i++){
			IOWR(I2C_MASTER_BASE, CR, RD);
			while((IORD(I2C_MASTER_BASE, SR) & TIP) != 0); //wait for byte to be transfered
			byte[i] = IORD(I2C_MASTER_BASE, RXR);
		}
		IOWR(I2C_MASTER_BASE, CR, RD|ACK|STO);
		while((IORD(I2C_MASTER_BASE, SR) & TIP) != 0);
		byte[byte_number] = IORD(I2C_MASTER_BASE, RXR);
	}

	//IOWR(I2C_MASTER_BASE, CR, ACK|STO); //send stop
};

#endif /* __NIOS2__ */
