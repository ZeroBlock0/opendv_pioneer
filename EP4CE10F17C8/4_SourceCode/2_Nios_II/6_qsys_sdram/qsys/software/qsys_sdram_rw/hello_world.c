//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           hello_world
// Last modified Date:  2018/10/15 15:44:58
// Last Version:        V1.0
// Descriptions:        SDRAM读写实验
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/10/15 15:45:13
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

#include <stdio.h>     //标准输入输出头文件
#include "system.h"    //系统头文件
#include "alt_types.h" //数据类型头文件
#include "string.h"

//SDRAM地址
alt_u8 * ram = (alt_u8 *)(SDRAM_BASE+0x10000);

int main(void){
    int i;
    memset(ram,0,100);
    //向ram中写数据，当ram写完以后，ram的地址已经变为(SDRAM_BASE+0x10000+200)
    for(i=0;i<100;i++){
        *(ram++) = i;
    }
    //逆向读取ram中的数据
    for(i=0;i<100;i++){
        printf("%d ",*(--ram));
    }
    return 0;
}
