#ifndef __SD_SPI_H
#define __SD_SPI_H
#include "common.h"

#include<system.h>
#include<alt_types.h>
#include<altera_avalon_pio_regs.h>

#define CMD0 	0	/* GO_IDLE_STATE */
#define CMD55 	55	/* APP_CMD */
#define ACMD41	41	/* SEND_OP_COND (ACMD) */
#define CMD17 	17	/* READ_SINGLE_BLOCK */
#define CMD8	8	/* SEND_IF_COND */
#define CMD24	24	/* WRITE_BLOCK */

//set CS low
void CS_Enable();

//set CS high and send 8 clocks
void CS_Disable();

//write a byte
void SDWriteByte(alt_u8 data);

//read a byte
alt_u8 SDReadByte();

//send a command and send back the response
alt_u8  SDSendCmd(alt_u8 cmd,alt_u32 arg,alt_u8 crc);

//reset SD card
alt_u8 SDReset();

//initial SD card
alt_u8 SDInit();

//read a single sector
alt_u8 SDReadSector(alt_u32 addr,alt_u8 * buffer);

//write a single sector
alt_u8 SDWriteSector(alt_u32 addr,alt_u8 * buffer);

alt_u8 SD_Test(void);

#endif /* SD_SPI_SOLUTION_H_ */
