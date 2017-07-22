#ifndef PIO_CONTROL_H
#define PIO_CONTROL_H

void write_coord(unsigned char leg, short x, short y, short z);

unsigned short read_end_calc();

void update_outputs();

#endif
