#ifdef __NIOS2__

#include "pio_control.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"

void write_coord(unsigned char leg, short x, short y, short z){
	if(leg >= 3){
		x = -x;
		y = -y;
	}

	IOWR_ALTERA_AVALON_PIO_DATA(PIO_BOT_UPDATEFLAG_BASE, 0);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_BOT_WRCOORD_BASE, 0);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_BOT_RESET_BASE, 1);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_BOT_LEGSELECT_BASE, leg);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_BOT_X_BASE, x);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_BOT_Y_BASE, y);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_BOT_Z_BASE, z);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_BOT_RESET_BASE, 0);
	//printf("waiting for calculation to be complete...\n");
	//printf("%i\n", read_end_calc()&1);
	while(read_end_calc()&0x01!=1);
	//printf("recording calculated coordinates...\n");
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_BOT_WRCOORD_BASE, 1);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_BOT_WRCOORD_BASE, 0);
};

unsigned short read_end_calc(){
	return IORD_ALTERA_AVALON_PIO_DATA(PIO_BOT_ENDCALC_BASE);
};

void update_outputs(){
	//printf("updating outputs...\n");
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_BOT_UPDATEFLAG_BASE, 1);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_BOT_UPDATEFLAG_BASE, 0);
	//printf("outputs updated\n");
};

#endif /* __NIOS2__ */
