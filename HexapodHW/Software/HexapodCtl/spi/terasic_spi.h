#ifndef TERASIC_SPI_H_
#define TERASIC_SPI_H_

#ifdef __NIOS2__

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#include "terasic_includes.h"

void SPI_Init(alt_u32 spi_base);
bool SPI_MultipleWrite(alt_u32 spi_base, alt_u8 RegIndex, alt_u8 szData[], alt_u8 nByteNum);
bool SPI_Write(alt_u32 spi_base, alt_u8 RegIndex, alt_u8 Value);
bool SPI_MultipleRead(alt_u32 spi_base, alt_u8 RegIndex, alt_u8 szBuf[], alt_u8 nByteNum);
bool SPI_Read(alt_u32 spi_base, alt_u8 RegIndex, alt_u8 *pBuf);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __NIOS2__ */

#endif /*TERASIC_SPI_H_*/
