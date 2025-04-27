#include "mdio.h"
#include "delay.h"
#include <unistd.h>
#include "system.h"
//////////////////////////////////////////////////////////////////////////////////
//本程序只供学习使用，未经作者许可，不得用于其它任何用途
//ALIENTEK STM32开发板
//IIC 驱动代码
//正点原子@ALIENTEK
//技术论坛:www.openedv.com
//创建日期:2015/12/27
//版本：V1.0
//版权所有，盗版必究。
//Copyright(C) 广州市星翼电子科技有限公司 2014-2024
//All rights reserved
//////////////////////////////////////////////////////////////////////////////////

//IO操作函数
void mdc_wr(u8 mdc){
    IOWR_ALTERA_AVALON_PIO_DATA(PIO_MDC_BASE,mdc);
}

void mdio_wr(u8 mdio){
    IOWR_ALTERA_AVALON_PIO_DATA(PIO_MDIO_BASE,mdio);
}

u8 mdio_rd(void){
u8 read_data;
    read_data = IORD_ALTERA_AVALON_PIO_DATA(PIO_MDIO_BASE);
    return read_data;    
}

/* MDIO发送一个bit的数据，MDIO必须已经被配置为输出 */
void mdio_send_bit(u8 bit){
    mdio_wr(bit);
    usleep(1);
    mdc_wr(0);
    usleep(1);
    mdc_wr(1);
}

/*  MDIO 获取一个bit的数据，MDIO必须已经被配置为输入. */
u8 mdio_get_bit(){
    u8 value;
    usleep(1);
    mdc_wr(0);
    usleep(1);
    mdc_wr(1);
    value = mdio_rd();
    return value;
}

/*  
 *  MDIO发送一个数据,MDIO 必须被配置为输出模式.
 *  value:要发送的数据
 *  bits:数据的位数
 *  
 *  */  
mdio_send_num(u16 value,u8 bits){
    int i;
    MDIO_OUT();
    
    for(i=bits-1;i>=0;i--)
    mdio_send_bit((value>>i) & 1);
}

/*  
  *  MDIO获取一个数据,MDIO 必须被配置为输入模式.
  *  bits:获取数据的位数
  *  
  *  */  
u16 mdio_get_num(u8 bits)
{
    int i;
    u16 ret = 0;
    for(i = bits - 1; i >= 0; i--)
    {
        ret <<= 1;
        ret |= mdio_get_bit();
    }

    return ret;
}

void mdio_set_turnaround(void)
{
    int i = 0;

    MDIO_IN();
    for(i=0;i<2;i++)
    {
        usleep(1);
        mdc_wr(0);
        usleep(1);
        mdc_wr(1);
    }
}

 void mdio_cmd(u8 op,u8 phy,u16 reg)
{
    int i = 0 ;
    MDIO_OUT();  //设置MDIO引脚为输出引脚

    /*发送32bit的1，这个帧前缀域不是必须的，某些物理层芯片的MDIO操作就没有这个域*/
    for(i = 0; i < 32; i++)
        mdio_send_bit(1);


    //发送开始位(01),和读操作码(10),写操作码(01)
    mdio_send_bit(0);
    mdio_send_bit(1);    
    mdio_send_bit((op >> 1) & 1);
    mdio_send_bit((op >> 0) & 1);

    mdio_send_num(phy,5);
    mdio_send_num(reg,5);
}

u16 mdio_read(u8 phy,u16 reg)
{
    int ret,i;
    mdio_cmd(MDIO_READ,phy,reg);
    MDIO_IN();
    //mdio_set_turnaround();
    /*  check the turnaround bit: the PHY should be driving it to zero */ 
    if(mdio_get_bit() != 0)
    {
        /* PHY didn't driver TA low -- flush any bits it may be trying to send*/
        for(i = 0; i < 32; i++)
        	mdio_get_bit();
        return 0xFFFF;
    }    
    ret = mdio_get_num(16);
    mdio_get_bit();
    
    return ret;    
}

u16 mdio_write(u8 phy,u16 reg,u16 val)
{   
    mdio_cmd(MDIO_WRITE,phy,reg);
    /*  send the turnaround (10) */  
    mdio_send_bit(1);
    mdio_send_bit(0);    
    mdio_send_num(val,16);
    
    MDIO_IN();
    //mdio_bb_get_bit();
    return 0;    
}
