/*
 * delay.c
 *
 *  Created on: 2018-8-27
 *      Author: Administrator
 */
#include "delay.h"
#include <unistd.h>

//LCD延迟函数，单位毫秒
void delay_ms(u32 n)
{
     usleep(n*1000);
}

void delay_us(u32 n)
{
     usleep(n);
}
