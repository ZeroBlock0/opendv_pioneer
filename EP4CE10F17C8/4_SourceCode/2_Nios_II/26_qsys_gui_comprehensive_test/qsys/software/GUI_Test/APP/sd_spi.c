
#include "system.h" 
#include <stdio.h> 
#include <unistd.h> 
#include "common.h"
#include "sd_spi.h"
#include "delay.h"

alt_u8 spi_speed = 0;	    //the spi speed(0-255),0 is fastest
alt_u8 sd_rd_data[512];		//(读)扇区缓冲数组，512字节数据
alt_u8 sd_wr_data[512];		//(写)扇区缓冲数组，512字节数据

//set CS low
void CS_Enable()
{
	//set CS low
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_SD_CS_BASE, 0x00);
}

//set CS high and send 8 clocks
void CS_Disable()
{
	//set CS high
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_SD_CS_BASE, 0x01);
	//send 8 clocks
	SDWriteByte(0xff);
}

//write a byte
void SDWriteByte(alt_u8 data)
{
	alt_u8 i;

	//write 8 bits(MSB)
	for(i = 0;i < 8;i ++)
	{
		IOWR_ALTERA_AVALON_PIO_DATA(PIO_SD_CLK_BASE, 0x00);
		if(data & 0x80)
			IOWR_ALTERA_AVALON_PIO_DATA(PIO_SD_MOSI_BASE, 0x01);
		else
			IOWR_ALTERA_AVALON_PIO_DATA(PIO_SD_MOSI_BASE, 0x00);
		data <<= 1;
		usleep(spi_speed);
		IOWR_ALTERA_AVALON_PIO_DATA(PIO_SD_CLK_BASE, 0x01);
		usleep(spi_speed);
	}

	//when DI is free,it should be set high
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_SD_MOSI_BASE, 0x01);
}

//read a byte
alt_u8 SDReadByte()
{
	alt_u8 data = 0x00,i;

	//read 8 bit(MSB)
	for(i = 0;i < 8;i ++)
	{
		IOWR_ALTERA_AVALON_PIO_DATA(PIO_SD_CLK_BASE, 0x00);
		usleep(spi_speed);
		IOWR_ALTERA_AVALON_PIO_DATA(PIO_SD_CLK_BASE, 0x01);
		data <<= 1;
		if(IORD_ALTERA_AVALON_PIO_DATA(PIO_SD_MISO_BASE))
			data |= 0x01;
		usleep(spi_speed);
	}

	return data;
}

//send a command and send back the response
alt_u8  SDSendCmd(alt_u8 cmd,alt_u32 arg,alt_u8 crc)
{
	alt_u32 r1,time = 0;

	//send the command,arguments and CRC
	SDWriteByte((cmd & 0x3f) | 0x40);
	SDWriteByte(arg >> 24);
	SDWriteByte(arg >> 16);
	SDWriteByte(arg >> 8);
	SDWriteByte(arg);
	SDWriteByte(crc);

	usleep(1000);
	//read the respond until responds is not '0xff' or timeout
	do{
		r1 = SDReadByte();
		time ++;
		//if time out,return
		if(time > 100) break;
	}while(r1 == 0xff);
	return r1;
}

//reset SD card
alt_u8 SDReset()
{
	alt_u32 i,r1,time = 0;

	//set CS high
	CS_Disable();
	//MOSI set high
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_SD_MOSI_BASE, 0x01);

	//send clocks
	for(i = 0;i < 100;i ++)
	{
		SDWriteByte(0xff);
	}

	//send CMD0 till the response is 0x01
	do{
		//set CS low
		CS_Enable();

		r1 = SDSendCmd(CMD0,0,0x95);
		time ++;
		//if time out,set CS high and return r1
		if(time > 50)
		{
			//set CS high and send 8 clocks
			CS_Disable();
			SDWriteByte(0xff);
			return r1;
		}
		//set CS high and send 8 clocks
		CS_Disable();
		SDWriteByte(0xff);
	}while(r1 != 0x01);
	return 0;
}

//initial SD card(send CMD55+ACMD41 or CMD1)
alt_u8 SDInit()
{
	alt_u32 time = 0;
	alt_u8 r1=0;
	alt_u8 vol = 0;

	do{
		CS_Enable();
		//check interface operating condition
		r1 = SDSendCmd(CMD8,0x000001aa,0x87);
		//read the other 4 bytes of response(the response of CMD8 is 5 bytes)
		r1=SDReadByte();
		r1=SDReadByte();
		r1=SDReadByte();
		vol = r1 & 0x0f;
		r1=SDReadByte();
		usleep(200);
		CS_Disable();
		SDWriteByte(0xff);

		time ++;
		if(time > 50)
		{
			//set CS high and send 8 clocks
			CS_Disable();
			SDWriteByte(0xff);
			return r1;
		}
	}while(vol != 0x01);

	usleep(1000);
	time = 0;

	do{
		CS_Enable();
		//send CMD55+ACMD41 to initial SD card
		do{
			r1 = SDSendCmd(CMD55,0,0xff);
			time ++;
			//if time out,set CS high and return r1
			if(time > 254)
			{
				//set CS high and send 8 clocks
				CS_Disable();
				SDWriteByte(0xff);
				return r1;
			}
		}while(r1 != 0x01);
		CS_Disable();
		SDWriteByte(0xff);
		usleep(1000);
		CS_Enable();
		r1 = SDSendCmd(ACMD41,0x40000000,0xff);
		SDReadByte();
		SDReadByte();
		SDReadByte();
		SDReadByte();
		time ++;

		//if time out,set CS high and return r1
		if(time > 254)
		{
			//set CS high and send 8 clocks
			CS_Disable();
			SDWriteByte(0xff);
			return r1;
		}
	}while(r1 != 0x00);

	//set CS high and send 8 clocks
	CS_Disable();
	SDWriteByte(0xff);
	return 0;
}

//read a single sector
alt_u8 SDReadSector(alt_u32 addr,alt_u8 * buffer)
{
	alt_u8 r1;
	alt_u32 i,time = 0;

	//set CS low
	CS_Enable();

	//send CMD17 for single block read
	r1 = SDSendCmd(CMD17,addr << 9,0x55);
	//if CMD17 fail,return
	if(r1 != 0x00)
	{
		//set CS high and send 8 clocks
		CS_Disable();
		SDWriteByte(0xff);
		return r1;
	}

	//continually read till get the start byte 0xfe
	do{
		r1 = SDReadByte();
		time ++;
		//if time out,set CS high and return r1
		if(time > 30000)
		{
			//set CS high and send 8 clocks
			CS_Disable();
			return r1;
		}
	}while(r1 != 0xfe);

	//read 512 Bits of data
	for(i = 0;i < 512;i ++)
	{
		buffer[i] = SDReadByte();
	}

	//read two bits of CRC
	SDReadByte();
	SDReadByte();

	//set CS high and send 8 clocks
	CS_Disable();
	SDWriteByte(0xff);
	return 0;
}

//write a single sector
alt_u8 SDWriteSector(alt_u32 addr,alt_u8 * buffer)
{
	alt_u32 i,time = 0;
	alt_u8 r1;

	//set CS low
	CS_Enable();

	do{
		//send CMD24 for single block write
		r1 = SDSendCmd(CMD24,addr << 9,0xff);
		time ++;
		//if time out,set CS high and return r1
		if(time > 254)
		{
			//set CS high and send 8 clocks
			CS_Disable();
			SDWriteByte(0xff);
			return r1;
		}
	}while(r1 != 0x00);
	time = 0;

	//send some dummy clocks
	for(i = 0;i < 5;i ++)
	{
		SDWriteByte(0xff);
	}

	//write start byte
	SDWriteByte(0xfe);

	//write 512 bytes of data
	for(i = 0;i < 512;i ++)
	{
		SDWriteByte(buffer[i]);
	}

	//write 2 bytes of CRC
	SDWriteByte(0xff);
	SDWriteByte(0xff);

	SDReadByte();

	//check busy
	do{
		r1 = SDReadByte();
		time ++;
		//if time out,set CS high and return r1
		if(time > 60000)
		{
			//set CS high and send 8 clocks
			CS_Disable();
			SDWriteByte(0xff);
			return r1;
		}
	}while(r1 != 0xff);

	//set CS high and send 8 clocks
	CS_Disable();
	SDWriteByte(0xff);

	return 0;
}

alt_u8 SD_Test(){
    alt_u32 i;
    alt_u32 time_cnt = 0;
    //SD卡复位
	spi_speed = 10;
    if(SDReset())
    	return 1;
    SDInit();
    spi_speed = 1;

    for(i = 0; i < 512; i++) //初始化写入数据
    {
    	if(i<256)
    		sd_wr_data[i] = i;
    	else
    		sd_wr_data[i] = i-256;
    }

    SDWriteSector(2000, sd_wr_data); //写一个扇区

    SDReadSector(2000,sd_rd_data);   //读一个扇区

    for(i = 0; i < 512; i++) 	 	//读取字节数据
    {
    	if(sd_wr_data[i] != sd_rd_data[i])
    		return 1;
    }
    return 0;
}

