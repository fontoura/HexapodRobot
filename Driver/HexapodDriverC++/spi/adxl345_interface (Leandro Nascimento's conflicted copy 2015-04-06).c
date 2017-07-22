#ifdef __NIOS2__

#include "adxl345_interface.h"

void test_accelerometer(){
	bool bSuccess;
	alt_16 szXYZ[3];
	alt_u8 id;
	const int mg_per_digi = 4;

	// release i2c pio pin
	//IOWR_ALTERA_AVALON_PIO_DIRECTION(I2C_SCL_BASE, ALTERA_AVALON_PIO_DIRECTION_OUTPUT);
	//IOWR_ALTERA_AVALON_PIO_DIRECTION(I2C_SDA_BASE, ALTERA_AVALON_PIO_DIRECTION_INPUT);
	//IOWR(SELECT_I2C_CLK_BASE, 0, 0x00);

	// configure accelerometer as +-2g and start measure
	bSuccess = ADXL345_SPI_Init(GSENSOR_SPI_BASE);
	if (bSuccess){
		// dump chip id
		bSuccess = ADXL345_SPI_IdRead(GSENSOR_SPI_BASE, &id);
		if (bSuccess)
			printf("id=%02Xh\r\n", id);
	}

	if (bSuccess)
		printf("Monitor Accerometer Value. Press KEY0 or KEY1 to terminal the monitor process.\r\n");

	while(bSuccess){// && !bKeyPressed){
		if (ADXL345_SPI_IsDataReady(GSENSOR_SPI_BASE)){
			bSuccess = ADXL345_SPI_XYZ_Read(GSENSOR_SPI_BASE, szXYZ);
			if (bSuccess){
				printf("X=%d mg, Y=%d mg, Z=%d mg\r\n", szXYZ[0]*mg_per_digi, szXYZ[1]*mg_per_digi, szXYZ[2]*mg_per_digi);
				// show raw data,
				//printf("X=%04x, Y=%04x, Z=%04x\r\n", (alt_u16)szXYZ[0], (alt_u16)szXYZ[1],(alt_u16)szXYZ[2]);
				//usleep(1000*1000);
			}
		}
	}

	if (!bSuccess)
		printf("Failed to access accelerometer\r\n");
};

void accelerometer_init(){
	ADXL345_SPI_Init(GSENSOR_SPI_BASE);
};

void accelerometer_read(alt_16 szXYZ[3]){
	ADXL345_SPI_XYZ_Read(GSENSOR_SPI_BASE, szXYZ);
}

void accelerometer_coordinate_conversion(alt_u16 new_szData16[3], alt_u16 old_szData16[3]){
	new_szData16[0] = -old_szData16[2];
	new_szData16[1] = old_szData16[0];
	new_szData16[2] = -old_szData16[1];
}

#endif /* __NIOS2__ */
