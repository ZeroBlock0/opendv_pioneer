#include "system.h"
#include <unistd.h>
#include <stdint.h>
#include <stdio.h>
#include "sys/alt_irq.h"
#include "sys/alt_sys_init.h"
#include "altera_avalon_pio_regs.h"            //PIO寄存器文件
#include "can_controller.h"                    //CAN控制器驱动文件
#include "segled_controller_regs.h"                 //数码管驱动文件

#define CanBaseAddr CAN_CONTROLLER_BASE
//帧信息
#define FF          0                          //帧格式: 0:SFF   1:EFF
#define RTR         0                          //0数据帧   1远程帧
#define DLC         3                          //数据长度(0~8)
#define FRM_INFO    (FF<<7) + (RTR<<6) + DLC   //帧信息

const uint8_t id[2]={0x00,0x20};               //发送的ID

uint8_t acceptance[8]={0x00,0x00,0x00,0x00,    //验收代码
                       0xff,0xff,0xff,0xff};   //验收屏蔽
uint8_t rx_data[8];                            //接收的数据
uint8_t rx_flag = 0;                           //接收有效标志

void can_isr(void* context, alt_u32 id);
void delay_ms(uint32_t n);

int main(void)
{
    uint8_t tx_data[8],i;
    uint8_t key;

    printf("Hello from Nios II!\n");
    //需发送数据
    tx_data[0] = 18;
    tx_data[1] = 12;
    tx_data[2] = 25;
    IOWR_AVALON_SEGLED_EN(SEGLED_CONTROLLER_BASE,1);
    alt_ic_isr_register(
        CAN_CONTROLLER_IRQ_INTERRUPT_CONTROLLER_ID,
        CAN_CONTROLLER_IRQ,
        can_isr,
        0,
        0);                                 //注册CAN控制器中断服务
    can_brt0(0x00);                         //设置总线定时器0 sjw=1tscl,  tscl=2tclk
    can_brt1(0x14);                         //设置总线定时器1 位长时间为8tscl
    can_acp(acceptance);                    //设置验收滤波器
    can_rest();                             //复位CAN控制器
    while(1){
        key = IORD_ALTERA_AVALON_PIO_DATA(CAN_TX_EN_BASE);
        if(!key){
            tx_id_f(FF,id);                 //发送ID
            can_txf(tx_data,FRM_INFO);      //发送数据
            delay_ms(500);
        }
        else if(rx_flag){
            rx_data_f(rx_data);
            for(i=0;i<DLC;i++){
                IOWR_AVALON_SEGLED_DATA(SEGLED_CONTROLLER_BASE,rx_data[i]);
                delay_ms(1000);
            }
            rx_flag = 0;
        }
    }
   return 0;
}

/*****************************************************************
函数功能：延时函数
入口参数：n:延时的时间
返回参数：
说明       ：单位ms
******************************************************************/
void delay_ms(uint32_t n)
{
    usleep(n*1000);
}

/*****************************************************************
函数功能：中断服务函数
入口参数：
返回参数：
说明       ：CAN 控制器的中断服务函数
******************************************************************/
void can_isr(void* context, alt_u32 id)
{
    uint8_t status;
    status = IORD_8DIRECT(CanBaseAddr, SJA_IR);
    printf("status:%x\n",status);
    if(status & RI_BIT){            //判断是否是接收中断
        can_rxf();                  //接收数据
        rx_flag = 1;
    }
}
