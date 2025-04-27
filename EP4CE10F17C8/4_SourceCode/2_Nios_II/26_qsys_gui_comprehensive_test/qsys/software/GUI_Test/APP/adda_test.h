/*
 * adda_test.h
 *
 *  Created on: 2018-8-30
 *      Author: Administrator
 */

#ifndef ADDA_TEST_H_
#define ADDA_TEST_H_

#include "common.h"
#include "dac.h"
#include "gui.h"

//数据结构体
typedef struct
{
	u8 da;
	float ad;
}_ad_da;

_ad_da ad_da;	//数据结构体

void ad_da_get(u8 i,_ad_da *ad_dax);
void pcf8591_play();

#endif /* ADDA_TEST_H_ */
