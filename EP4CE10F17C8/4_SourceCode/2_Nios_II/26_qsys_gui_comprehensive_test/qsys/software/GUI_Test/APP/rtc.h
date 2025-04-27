/*
 * rtc.h
 *
 *  Created on: 2018-8-27
 *      Author: Administrator
 */

#ifndef RTC_H_
#define RTC_H_

#include "common.h"
#define RTC_ADDR  0x51

void RTC_Set_Time(u8 hour,u8 min,u8 sec);
u8 RTC_Write_Time(u8 reg,u8 *buf, u8 len);
void RTC_Get_Time(u8 *hour,u8 *min,u8 *sec);
void RTC_Get_Date(u8 *year,u8 *month,u8 *date,u8 *week);

#endif /* RTC_H_ */
