/*
 * fw_native.cpp
 *
 *  Created on: 05/04/2013
 */

#include "../../../bot/firmware/movement/fw_native.h"
#include "../../../bot/firmware/LegPositions.h"

extern "C"
{

#include "../../../constants.h"
#include <string.h>

#define SET_LEG(a,b,c,d) {a[0]=b;a[1]=c;a[2]=d;}
#define COPY_ALL(A,B) {memcpy(A[0],B[0],3*sizeof(int));memcpy(A[1],B[1],3*sizeof(int));memcpy(A[2],B[2],3*sizeof(int));memcpy(A[3],B[3],3*sizeof(int));memcpy(A[4],B[4],3*sizeof(int));memcpy(A[5],B[5],3*sizeof(int));}


void movement_interpolation(int num_interpol, int delay,
		int xm[6][NUM_INTERPOL], int ym[6][NUM_INTERPOL], int zm[6][NUM_INTERPOL],
		int start_xyz[6][3],
		int end_xyz[6][3]);

void update_outputs();

void write_coord(unsigned char a, short b, short c, short d);

}

namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			void move(LegPositions& leg, int delayMicros)
			{
#ifdef __NIOS2__
				for(int i = 0; i < 6; i++)
				{
					write_coord(i, leg.xyz[i][0], leg.xyz[i][1], leg.xyz[i][2]);
				}
				update_outputs();
				usleep(delayMicros);
#endif /* __NIOS2__ */
			}
		}
	}
}
using namespace bot::firmware;

#ifdef __NIOS2__

/*void singleStepBackward(LegPositions& start){
	int xm[6][NUM_INTERPOL];
	int ym[6][NUM_INTERPOL];
	int zm[6][NUM_INTERPOL];

	int delay_movimentacao = 10e3; //em ms
	int delay_posicao = 5e3;

	int delta_x = 75;
	int delta_y = 25;
	int delta_z = 10;
	int centro_offset_x = 0;

	int y_base = 30;
	int z_chao = 60;

	int angle_setpoint = 90;
	int angle_measurement = 0;
	int alpha = 0;
	int beta = 0;
	int offset_l = 0;
	int offset_r = 0;

	LegPositions end;

	SET_LEG(end.xyz[0], delta_x, y_base + delta_y - offset_r, z_chao - delta_z);
	SET_LEG(end.xyz[1], delta_x - centro_offset_x, -delta_y, z_chao);
	SET_LEG(end.xyz[2], delta_x, -y_base, z_chao - delta_z);
	SET_LEG(end.xyz[3], -delta_x, -y_base - delta_y + offset_l, z_chao);
	SET_LEG(end.xyz[4], -delta_x + centro_offset_x, delta_y, z_chao - delta_z);
	SET_LEG(end.xyz[5], -delta_x, y_base, z_chao);
	movement_interpolation(NUM_INTERPOL, delay_movimentacao/NUM_INTERPOL, xm, ym, zm, start.xyz, end.xyz);

	COPY_ALL(start.xyz, end.xyz);
	SET_LEG(end.xyz[0], delta_x, y_base, z_chao - delta_z);
	SET_LEG(end.xyz[1], delta_x - centro_offset_x, delta_y, z_chao);
	SET_LEG(end.xyz[2], delta_x, -y_base - delta_y + offset_r, z_chao - delta_z);
	SET_LEG(end.xyz[3], -delta_x, -y_base, z_chao);
	SET_LEG(end.xyz[4], -delta_x + centro_offset_x, -delta_y, z_chao - delta_z);
	SET_LEG(end.xyz[5], -delta_x, y_base + delta_y - offset_l, z_chao);
	movement_interpolation(NUM_INTERPOL, delay_movimentacao/NUM_INTERPOL, xm, ym, zm, start.xyz, end.xyz);

	COPY_ALL(start.xyz, end.xyz);
	SET_LEG(end.xyz[0], delta_x, y_base, z_chao);
	SET_LEG(end.xyz[1], delta_x - centro_offset_x, delta_y, z_chao - delta_z);
	SET_LEG(end.xyz[2], delta_x, -y_base - delta_y + offset_r, z_chao);
	SET_LEG(end.xyz[3], -delta_x, -y_base, z_chao - delta_z);
	SET_LEG(end.xyz[4], -delta_x + centro_offset_x, -delta_y, z_chao);
	SET_LEG(end.xyz[5], -delta_x, y_base + delta_y - offset_l, z_chao - delta_z);
	movement_interpolation(NUM_INTERPOL, delay_movimentacao/NUM_INTERPOL, xm, ym, zm, start.xyz, end.xyz);

};

void bambole(LegPositions& start){
	int xm[6][NUM_INTERPOL];
	int ym[6][NUM_INTERPOL];
	int zm[6][NUM_INTERPOL];

	int delay_movimentacao = 10e3; //em ms

	int delta_x = 75;
	int delta_y = 25;
	int centro_offset_x = 50;

	int y_base = 75;
	int z_chao = 60;

	int z_very_high = 80;
	int z_high = 60;
	int z_low = 40;
	int z_very_low = 20;
	int offset_l = 0;
	int offset_r = 0;

	LegPositions end;

	// pata 0 no nivel mais alto e pata 3 no mais baixo
	SET_LEG(end.xyz[0], delta_x, y_base, z_very_high);
	SET_LEG(end.xyz[1], delta_x + centro_offset_x, 0, z_high);
	SET_LEG(end.xyz[2], delta_x, -y_base, z_low);
	SET_LEG(end.xyz[3], -delta_x, -y_base, z_very_low);
	SET_LEG(end.xyz[4], -delta_x - centro_offset_x, 0, z_low);
	SET_LEG(end.xyz[5], -delta_x, y_base, z_high);
	movement_interpolation(NUM_INTERPOL, delay_movimentacao/NUM_INTERPOL, xm, ym, zm, start.xyz, end.xyz);

	// pata 1 no nivel mais alto e pata 4 no mais baixo
	COPY_ALL(start.xyz, end.xyz);
	SET_LEG(end.xyz[0], delta_x, y_base, z_high);
	SET_LEG(end.xyz[1], delta_x + centro_offset_x, 0, z_very_high);
	SET_LEG(end.xyz[2], delta_x, -y_base, z_high);
	SET_LEG(end.xyz[3], -delta_x, -y_base, z_low);
	SET_LEG(end.xyz[4], -delta_x - centro_offset_x, 0, z_very_low);
	SET_LEG(end.xyz[5], -delta_x, y_base, z_low);
	movement_interpolation(NUM_INTERPOL, delay_movimentacao/NUM_INTERPOL, xm, ym, zm, start.xyz, end.xyz);

	// pata 2 no nivel mais alto e pata 5 no mais baixo
	COPY_ALL(start.xyz, end.xyz);
	SET_LEG(end.xyz[0], delta_x, y_base, z_low);
	SET_LEG(end.xyz[1], delta_x + centro_offset_x, 0, z_high);
	SET_LEG(end.xyz[2], delta_x, -y_base, z_very_high);
	SET_LEG(end.xyz[3], -delta_x, -y_base, z_high);
	SET_LEG(end.xyz[4], -delta_x - centro_offset_x, 0, z_low);
	SET_LEG(end.xyz[5], -delta_x, y_base, z_very_low);
	movement_interpolation(NUM_INTERPOL, delay_movimentacao/NUM_INTERPOL, xm, ym, zm, start.xyz, end.xyz);

	// pata 3 no nivel mais alto e pata 0 no mais baixo
	COPY_ALL(start.xyz, end.xyz);
	SET_LEG(end.xyz[0], delta_x, y_base, z_very_low);
	SET_LEG(end.xyz[1], delta_x + centro_offset_x, 0, z_low);
	SET_LEG(end.xyz[2], delta_x, -y_base, z_high);
	SET_LEG(end.xyz[3], -delta_x, -y_base, z_very_high);
	SET_LEG(end.xyz[4], -delta_x - centro_offset_x, 0, z_high);
	SET_LEG(end.xyz[5], -delta_x, y_base, z_low);
	movement_interpolation(NUM_INTERPOL, delay_movimentacao/NUM_INTERPOL, xm, ym, zm, start.xyz, end.xyz);

	// pata 4 no nivel mais alto e pata 1 no mais baixo
	COPY_ALL(start.xyz, end.xyz);
	SET_LEG(end.xyz[0], delta_x, y_base, z_low);
	SET_LEG(end.xyz[1], delta_x + centro_offset_x, 0, z_very_low);
	SET_LEG(end.xyz[2], delta_x, -y_base, z_low);
	SET_LEG(end.xyz[3], -delta_x, -y_base, z_high);
	SET_LEG(end.xyz[4], -delta_x - centro_offset_x, 0, z_very_high);
	SET_LEG(end.xyz[5], -delta_x, y_base, z_high);
	movement_interpolation(NUM_INTERPOL, delay_movimentacao/NUM_INTERPOL, xm, ym, zm, start.xyz, end.xyz);

	// pata 5 no nivel mais alto e pata 2 no mais baixo
	COPY_ALL(start.xyz, end.xyz);
	SET_LEG(end.xyz[0], delta_x, y_base, z_high);
	SET_LEG(end.xyz[1], delta_x + centro_offset_x, 0, z_low);
	SET_LEG(end.xyz[2], delta_x, -y_base, z_very_low);
	SET_LEG(end.xyz[3], -delta_x, -y_base, z_low);
	SET_LEG(end.xyz[4], -delta_x - centro_offset_x, 0, z_high);
	SET_LEG(end.xyz[5], -delta_x, y_base, z_very_high);
	movement_interpolation(NUM_INTERPOL, delay_movimentacao/NUM_INTERPOL, xm, ym, zm, start.xyz, end.xyz);
};

void initPosition(LegPositions& start0){
	int xm[6][NUM_INTERPOL];
	int ym[6][NUM_INTERPOL];
	int zm[6][NUM_INTERPOL];

	int delta_x = 75;
	int delay_movimentacao = 10e3; //em ms

	int y_base = 30;

	int z_very_high = 30;
	int z_high = 45;
	int z_low = 60;
	int z_very_low = 75;

	LegPositions start;
	LegPositions end;

	// Ajusta todas as patas para posicao inicial
	SET_LEG(end.xyz[0], delta_x, y_base, z_high);
	SET_LEG(end.xyz[1], delta_x, 0, z_low);
	SET_LEG(end.xyz[2], delta_x, -y_base, z_very_low);
	SET_LEG(end.xyz[3], -delta_x, -y_base, z_low);
	SET_LEG(end.xyz[4], -delta_x, 0, z_high);
	SET_LEG(end.xyz[5], -delta_x, y_base, z_very_high);
	COPY_ALL(start.xyz, end.xyz);
	movement_interpolation(NUM_INTERPOL, delay_movimentacao/NUM_INTERPOL, xm, ym, zm, start.xyz, end.xyz);
};*/

#endif
