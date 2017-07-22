#ifdef __NIOS2__

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#include "altera_avalon_spi.h"
#include "altera_avalon_spi_regs.h"
#include "altera_avalon_pio_regs.h"
#include "accelerometer_adxl345_spi.h"
#include "terasic_spi.h"
#include "terasic_includes.h"

// g = 9,78760377 m/s2 em Curitiba
#define GSENSOR_SPI_BASE TERASIC_SPI_3WIRE_0_BASE
#define ACCELEROMETER_MG_PER_DIGI 3.9
#define ACCELEROMETER_OFFSET_X -13
#define ACCELEROMETER_OFFSET_Y 4
#define ACCELEROMETER_OFFSET_Z 33

void test_accelerometer();
void accelerometer_init();
void accelerometer_read(alt_16 szXYZ[3]);
void accelerometer_coordinate_conversion(alt_u16 new_szData16[3], alt_u16 old_szData16[3]); //converte para o sistema de coordenadas do IMU

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __NIOS2__ */
