//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           can_controller
// Last modified Date:  2018/08/07 13:57:08
// Last Version:        V1.0
// Descriptions:        CAN驱动头文件
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/08/07 13:57:16
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

#ifndef __CAN_CONTROLLER_H__
#define __CAN_CONTROLLER_H__

#include "system.h"
#include <stdint.h>
#include <io.h>
#include "alt_types.h"
#include "sja1000_regs.h"

#ifdef __cplusplus
extern "C"
{
    #endif /* __cplusplus */

//复位设置结构体
typedef struct{
    uint8_t btr0;           //总线定时器BTR0
    uint8_t btr1;           //总线定时器BTR1
    uint8_t ocr;            //时钟分频寄存器CDR
    uint8_t acr[4];         //验收代码寄存器ACR
    uint8_t amr[4];         //验收屏蔽寄存器AMR
}_rest_val;    

    /* CAN_CONTROLLER function */
void can_brt0(uint8_t val);
void can_brt1(uint8_t val);
void can_ocr(uint8_t val);
void can_acp(const uint8_t *acceptance);
void can_rest(void);
void can_txf(uint8_t tx_data[], uint8_t tx_info);
void can_rxf();
void tx_id_f(uint8_t ff, const uint8_t *id);
void rx_id_f(uint8_t *id);
void rx_data_f(uint8_t *data);

    /* Macros used by alt_sys_init */
#define CAN_CONTROLLER_INSTANCE(name, dev) alt_u32 canbaseaddr = name##_BASE
#define CAN_CONTROLLER_INIT(name, dev)
    #ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __SEGLED_CONTROLLER_H__ */
