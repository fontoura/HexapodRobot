#ifdef __NIOS2__

#include "terasic_includes.h"
#include "terasic_spi.h"


typedef enum{
        SPI_REG_DATA = 0,
        SPI_REG_CTRL_STATUS = 1,
        SPI_REG_INDEX = 2,
        SPI_REG_READ_NUM = 3
}SPI_REG_ID;

typedef enum{
        SPI_FLAG_STATR = 0x01,
        SPI_FLGA_REG_READ = 0x02,
        SPI_FLAG_CLEAR_FIFO = 0x04
}SPI_CTRL_FLAG;

typedef enum{
        SPI_STATUS_FLAG_DONE = 0x01
}SPI_STATUS_FLAG;

void SPI_Init(alt_u32 spi_base){
    // clear fifo
    IOWR(spi_base, SPI_REG_CTRL_STATUS, 0);
    IOWR(spi_base, SPI_REG_CTRL_STATUS, SPI_FLAG_CLEAR_FIFO);
    IOWR(spi_base, SPI_REG_CTRL_STATUS, 0);

}


bool SPI_MultipleWrite(alt_u32 spi_base, alt_u8 RegIndex, alt_u8 szData[], alt_u8 nByteNum){
    alt_u8 Status;
    const int nMaxTry = 100;
    int nTryCnt = 0;
    int i;

    // make sure processs is stoped, and set write flag
    IOWR(spi_base, SPI_REG_CTRL_STATUS, 0);

    // set register index
    IOWR(spi_base, SPI_REG_INDEX, RegIndex);

    // write data to fifo
    for(i=0;i<nByteNum;i++)
        IOWR(spi_base, SPI_REG_DATA, szData[i]);

    // start
    IOWR(spi_base, SPI_REG_CTRL_STATUS, SPI_FLAG_STATR);

    // check status
    usleep(10);
    do{
        Status = IORD(spi_base, SPI_REG_CTRL_STATUS);
    }while (!(Status & SPI_STATUS_FLAG_DONE) && (nTryCnt++ < nMaxTry));

    IOWR(spi_base, SPI_REG_CTRL_STATUS, 0);  //stop

    if (Status & SPI_STATUS_FLAG_DONE)
        return TRUE;

    return FALSE;
}

bool SPI_Write(alt_u32 spi_base, alt_u8 RegIndex, alt_u8 Value){
    return SPI_MultipleWrite(spi_base, RegIndex, &Value, 1);
}

bool SPI_MultipleRead(alt_u32 spi_base, alt_u8 RegIndex, alt_u8 szBuf[], alt_u8 nByteNum){
    alt_u8 Status, Value8;
    const int nMaxTry = 100;
    int nTryCnt = 0;
    int i;

    // make sure processs is stoped, and set read flag
    IOWR(spi_base, SPI_REG_CTRL_STATUS, SPI_FLGA_REG_READ);


    // set register index
    IOWR(spi_base, SPI_REG_INDEX, RegIndex);

    // set read byte count
    IOWR(spi_base, SPI_REG_READ_NUM, nByteNum-1);

    // start
    IOWR(spi_base, SPI_REG_CTRL_STATUS, SPI_FLAG_STATR | SPI_FLGA_REG_READ);

    // check status
    usleep(10);
    do{
        Status = IORD(spi_base, SPI_REG_CTRL_STATUS);
    }while (!(Status & SPI_STATUS_FLAG_DONE) && (nTryCnt++ < nMaxTry));

    IOWR(spi_base, SPI_REG_CTRL_STATUS, 0);  //stop

    if (Status & SPI_STATUS_FLAG_DONE){
        for(i=0;i<nByteNum;i++){
            Value8 = IORD(spi_base, SPI_REG_DATA);
            szBuf[i] = Value8;
        }
        return TRUE;
    }
    return FALSE;
}

bool SPI_Read(alt_u32 spi_base, alt_u8 RegIndex, alt_u8 *pBuf){
    return SPI_MultipleRead(spi_base, RegIndex, pBuf, 1);
}

#endif /* __NIOS2__ */
