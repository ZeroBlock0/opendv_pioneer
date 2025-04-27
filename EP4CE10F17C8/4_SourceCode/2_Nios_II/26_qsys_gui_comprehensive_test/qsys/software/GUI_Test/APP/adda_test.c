/*
 * adda_test.c
 *
 *  Created on: 2018-8-30
 *      Author: Administrator
 */

#include "adda_test.h"

extern _ad_da ad_da;	//数据结构体
//=======================================================
//以下为测试代码
void PCF8591_AD_DA(u8 i,u8 *da, float *ad)
{
	float ad_data;
	PCF8591_Write_Reg(i);
	*da = i;
	delay_ms(200);
	ad_data = PCF8591_Read_Reg();
	ad_data *= 3.3f;
	*ad = ad_data/255;
	delay_ms(300);
}

void ad_da_get(u8 i,_ad_da *ad_dax)
{
	PCF8591_AD_DA(i,&ad_dax->da,&ad_dax->ad);//得到数据
}

void pcf8591_play()
{

}


