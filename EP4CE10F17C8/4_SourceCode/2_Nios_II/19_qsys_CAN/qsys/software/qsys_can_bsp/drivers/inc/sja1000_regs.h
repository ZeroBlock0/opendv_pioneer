#ifndef __SJA1000_H__
#define __SJA1000_H__

#define SJA_BASE_ADDR     0x0                //SJA1000的基址设为0

//*****************************************************
//定义SJA1000 的两种工作模式的寄存器地址
//*****************************************************
#ifdef BasicCAN                              //BasicCAN模式

/****************************************
控制寄存器地址及其位定义
****************************************/
#define SJA_CR      SJA_BASE_ADDR + 0x00     //控制寄存器
#define RR_BIT            0x01               //复位请求位
#define RIE_BIT           0x02               //接收中断使能位
#define TIE_BIT           0x04               //发送中断使能位
#define EIE_BIT           0x08               //错误中断使能位
#define OIE_BIT           0x10               //溢出中断使能位

/****************************************
命令寄存器及其位定义（写）
****************************************/
#define SJA_CMR     SJA_BASE_ADDR + 0x01
#define TR_BIT            0x01               //发送请求位
#define AT_BIT            0x02               //中止发送位
#define RRB_BIT           0x04               //释放接收缓冲器位
#define CDO_BIT           0x08               //清除数据溢出位
#define GTS_BIT           0x10               //睡眠位

/****************************************
状态寄存器及其位定义（读）
****************************************/
#define SJA_SR      SJA_BASE_ADDR + 0x02
#define RBS_BIT           0x01               //接收缓冲器状态位
#define DOS_BIT           0x02               //数据溢出状态位
#define TBS_BIT           0x04               //发送缓冲器状态位
#define TCS_BIT           0x08               //发送完毕状态位
#define RS_BIT            0x10               //接收状态位
#define TS_BIT            0x20               //发送状态位
#define ES_BIT            0x40               //出错状态位
#define BS_BIT            0x80               //总线状态位

/****************************************
中断寄存器及其位定义（复位模式-读）
****************************************/
#define SJA_IR      SJA_BASE_ADDR + 0x03
#define RI_BIT            0x01               //接收中断位
#define TI_BIT            0x02               //发送中断位
#define EI_BIT            0x04               //错误警告中断位
#define DOI_BIT           0x08               //数据溢出中断位
#define WUI_BIT           0x10               //唤醒中断位

/****************************************
验收滤波器寄存器及其位定义（复位模式）
****************************************/
#define SJA_ACR     SJA_BASE_ADDR + 0x04     //验收代码寄存器
#define SJA_AMR     SJA_BASE_ADDR + 0x05     //验收屏蔽寄存器

/****************************************
总线定时器寄存器及其位定义（复位模式）
****************************************/
#define SJA_BTR0    SJA_BASE_ADDR + 0x06     //总线定时0寄存器
#define SJA_BTR1    SJA_BASE_ADDR + 0x07     //总线定时1寄存器

/****************************************
输出控制寄存器地址（复位模式）
****************************************/
#define SJA_OCR     SJA_BASE_ADDR + 0x08     //输出控制寄存器地址

/****************************************
检测寄存器地址
****************************************/
#define SJA_TEST    SJA_BASE_ADDR + 0x09     //测试寄存器（只用于产品测试）

/****************************************
发送（TX）缓冲器地址（工作模式）
****************************************/
#define SJA_TBR0    SJA_BASE_ADDR + 0x0A     //TX ID(10-3)
#define SJA_TBR1    SJA_BASE_ADDR + 0x0B     //TX ID( 2-0)+RTR+DLC
#define SJA_TBR2    SJA_BASE_ADDR + 0x0C     //TX数据1
#define SJA_TBR3    SJA_BASE_ADDR + 0x0D     //TX数据2
#define SJA_TBR4    SJA_BASE_ADDR + 0x0E     //TX数据3
#define SJA_TBR5    SJA_BASE_ADDR + 0x0F     //TX数据4
#define SJA_TBR6    SJA_BASE_ADDR + 0x10     //TX数据5
#define SJA_TBR7    SJA_BASE_ADDR + 0x11     //TX数据6
#define SJA_TBR8    SJA_BASE_ADDR + 0x12     //TX数据7
#define SJA_TBR9    SJA_BASE_ADDR + 0x13     //TX数据8

/****************************************
接收（RX）缓冲器地址（工作模式)
****************************************/
#define SJA_RBR1    SJA_BASE_ADDR + 0x14     //RX ID(10-3)
#define SJA_RBR2    SJA_BASE_ADDR + 0x15     //RX ID( 2-0)+RTR+DLC
#define SJA_RBR3    SJA_BASE_ADDR + 0x16     //RX数据1
#define SJA_RBR4    SJA_BASE_ADDR + 0x17     //RX数据2
#define SJA_RBR5    SJA_BASE_ADDR + 0x18     //RX数据3
#define SJA_RBR6    SJA_BASE_ADDR + 0x19     //RX数据4
#define SJA_RBR7    SJA_BASE_ADDR + 0x1A     //RX数据5
#define SJA_RBR8    SJA_BASE_ADDR + 0x1B     //RX数据6
#define SJA_RBR9    SJA_BASE_ADDR + 0x1C     //RX数据7
#define SJA_RBR10   SJA_BASE_ADDR + 0x1D     //RX数据8

/****************************************
时钟分频寄存器地址及其位定义
****************************************/
#define SJA_CDR     SJA_BASE_ADDR + 0x1f     //时钟分频寄存器
#define CLKOff_BIT        0x08               //时钟关闭位，时钟输出管脚控制位
#define RXINTEN_BIT       0x20               //用于接收中断的管脚TX1
#define CBP_BIT           0x40               //CAN比较器旁路控制位
#define CANMODE_BIT       0x80               //CAN模式控制位,0:BasicCAN模式,
                                             //              1:PeliCAN 模式
#else

//SJA1000 PeliCAN寄存器地址分配
/****************************************
模式控制寄存器及其位定义
****************************************/
#define SJA_MOD     SJA_BASE_ADDR + 0x00
#define RM_BIT            0x01               //复位模式位
#define LOM_BIT           0x02               //只听模式位
#define STM_BIT           0x04               //自检模式位
#define AFM_BIT           0x08               //验收滤波器模式位
#define SM_BIT            0x10               //睡眠模式位

/****************************************
命令寄存器及其位定义（写）
****************************************/
#define SJA_CMR     SJA_BASE_ADDR + 0x01
#define TR_BIT            0x01               //发送请求位
#define AT_BIT            0x02               //中止发送位
#define RRB_BIT           0x04               //释放接收缓冲器位
#define CDO_BIT           0x08               //清除数据溢出位
#define SRR_BIT           0x10               //自接收请求位

/****************************************
状态寄存器及其位定义（读）
****************************************/
#define SJA_SR      SJA_BASE_ADDR + 0x02
#define RBS_BIT           0x01               //接收缓冲器状态位
#define DOS_BIT           0x02               //数据溢出状态位
#define TBS_BIT           0x04               //发送缓冲器状态位
#define TCS_BIT           0x08               //发送完毕状态位
#define RS_BIT            0x10               //接收状态位
#define TS_BIT            0x20               //发送状态位
#define ES_BIT            0x40               //错误状态位
#define BS_BIT            0x80               //总线状态位

/****************************************
中断寄存器及其位定义（读）
****************************************/
#define SJA_IR      SJA_BASE_ADDR + 0x03
#define RI_BIT            0x01               //接收中断位
#define TI_BIT            0x02               //发送中断位
#define EI_BIT            0x04               //错误报警中断位
#define DOI_BIT           0x08               //数据溢出中断位
#define WUI_BIT           0x10               //唤醒中断位
#define EPI_BIT           0x20               //错误消极中断位
#define ALI_BIT           0x40               //仲裁丢失中断位
#define BEI_BIT           0x80               //总线错误中断位

/****************************************
中断使能寄存器及其位定义
****************************************/
#define SJA_IER     SJA_BASE_ADDR + 0x04
#define RIE_BIT           0x01               //接收中断使能位
#define TIE_BIT           0x02               //发送中断使能位
#define EIE_BIT           0x04               //错误报警中断使能位
#define DOIE_BIT          0x08               //数据溢出中断使能位
#define WUIE_BIT          0x10               //唤醒中断使能位
#define EPIE_BIT          0x20               //错误消极中断使能位
#define ALIE_BIT          0x40               //仲裁丢失中断使能位
#define BEIE_BIT          0x80               //总线错误中断使能位

/****************************************
总线定时寄存器地址
****************************************/
#define SJA_BTR0    SJA_BASE_ADDR + 0x06     //总线定时0寄存器
#define SJA_BTR1    SJA_BASE_ADDR + 0x07     //总线定时1寄存器
#define SAM_BIT           0x80               //采样模式位；0总线采样1次,1:总线采样3次

/****************************************
输出控制寄存器地址（复位模式）
****************************************/
#define SJA_OCR     SJA_BASE_ADDR + 0x08     //输出控制寄存器地址

/****************************************
检测寄存器地址
****************************************/
#define SJA_TEST     SJA_BASE_ADDR + 0x09    //检测寄存器地址

/****************************************
仲裁丢失捕捉寄存器地址（读）
****************************************/
#define SJA_ALC      SJA_BASE_ADDR + 0x0b    //仲裁丢失捕捉寄存器

/****************************************
错误代码捕捉寄存器地址
****************************************/
#define SJA_ECC      SJA_BASE_ADDR + 0x0c    //错误代码捕捉寄存器
#define ERRC_BITS         0xC0               //错误事件位
#define DIR_BIT           0x20               //错误方向位
#define SEG_BITS          0x1F               //错误发生段位

/****************************************
错误报警限制寄存器地址
****************************************/
#define SJA_EWLR     SJA_BASE_ADDR + 0x0d    //错误报警限制寄存器

/****************************************
RX错误计数器寄存器地址
****************************************/
#define SJA_RXERR    SJA_BASE_ADDR + 0x0e    //RX错误计数器寄存器

/****************************************
TX错误计数器寄存器地址
****************************************/
#define SJA_TXERR    SJA_BASE_ADDR + 0x0f    //TX错误计数器寄存器

/****************************************
验收滤波器寄存器地址（复位模式）
****************************************/
#define SJA_ACR0     SJA_BASE_ADDR + 0x10    //验收代码0寄存器
#define SJA_ACR1     SJA_BASE_ADDR + 0x11    //验收代码1寄存器
#define SJA_ACR2     SJA_BASE_ADDR + 0x12    //验收代码2寄存器
#define SJA_ACR3     SJA_BASE_ADDR + 0x13    //验收代码3寄存器

#define SJA_AMR0     SJA_BASE_ADDR + 0x14    //验收屏蔽0寄存器
#define SJA_AMR1     SJA_BASE_ADDR + 0x15    //验收屏蔽1寄存器
#define SJA_AMR2     SJA_BASE_ADDR + 0x16    //验收屏蔽2寄存器
#define SJA_AMR3     SJA_BASE_ADDR + 0x17    //验收屏蔽3寄存器

/****************************************
发送（TX）缓冲器地址（工作模式-写）
****************************************/
#define SJA_TBR0     SJA_BASE_ADDR + 0x10    //TX帧报文SFF| EFF (FF+RTR+00+DLC[3:0])
#define SJA_TBR1     SJA_BASE_ADDR + 0x11    //TX识别码1    TX识别码1
#define SJA_TBR2     SJA_BASE_ADDR + 0x12    //TX识别码2    TX识别码2
#define SJA_TBR3     SJA_BASE_ADDR + 0x13    //TX数据1      TX识别码3
#define SJA_TBR4     SJA_BASE_ADDR + 0x14    //TX数据2      TX识别码4
#define SJA_TBR5     SJA_BASE_ADDR + 0x15    //TX数据3      TX数据1
#define SJA_TBR6     SJA_BASE_ADDR + 0x16    //TX数据4      TX数据2
#define SJA_TBR7     SJA_BASE_ADDR + 0x17    //TX数据5      TX数据3
#define SJA_TBR8     SJA_BASE_ADDR + 0x18    //TX数据6      TX数据4
#define SJA_TBR9     SJA_BASE_ADDR + 0x19    //TX数据7      TX数据5
#define SJA_TBR10    SJA_BASE_ADDR + 0x1a    //TX数据8      TX数据6
#define SJA_TBR11    SJA_BASE_ADDR + 0x1b    //             TX数据7
#define SJA_TBR12    SJA_BASE_ADDR + 0x1c    //             TX数据8

/****************************************
接收（RX）缓冲器地址（工作模式-读）
****************************************/
#define SJA_RBR0     SJA_BASE_ADDR + 0x10    //RX帧报文SFF| EFF (FF+RTR+00+DLC[3:0]
#define SJA_RBR1     SJA_BASE_ADDR + 0x11    //RX识别码1    RX识别码1
#define SJA_RBR2     SJA_BASE_ADDR + 0x12    //RX识别码2    RX识别码2
#define SJA_RBR3     SJA_BASE_ADDR + 0x13    //RX数据1      RX识别码3
#define SJA_RBR4     SJA_BASE_ADDR + 0x14    //RX数据2      RX识别码4
#define SJA_RBR5     SJA_BASE_ADDR + 0x15    //RX数据3      RX数据1
#define SJA_RBR6     SJA_BASE_ADDR + 0x16    //RX数据4      RX数据2
#define SJA_RBR7     SJA_BASE_ADDR + 0x17    //RX数据5      RX数据3
#define SJA_RBR8     SJA_BASE_ADDR + 0x18    //RX数据6      RX数据4
#define SJA_RBR9     SJA_BASE_ADDR + 0x19    //RX数据7      RX数据5
#define SJA_RBR10    SJA_BASE_ADDR + 0x1a    //RX数据8      RX数据6
#define SJA_RBR11    SJA_BASE_ADDR + 0x1b    //(FIFORAM)    RX数据7
#define SJA_RBR12    SJA_BASE_ADDR + 0x1c    //(FIFORAM)    RX数据8

/****************************************
RX信息计数器寄存器地址（读）
****************************************/
#define SJA_RMC      SJA_BASE_ADDR + 0x1d    //RX报文计数器寄存器

/****************************************
RX缓冲器起始地址寄存器地址
****************************************/
#define SJA_RBSA     SJA_BASE_ADDR + 0x1e    //RX缓冲区起始地址寄存器

/****************************************
时钟分频寄存器地址及其位定义
****************************************/
#define SJA_CDR      SJA_BASE_ADDR + 0x1f    //时钟分频寄存器
#define CLKOFF_BIT        0x08               //时钟关闭位，禁能CLKOUT引脚
#define CANMODE_BIT       0x80               //CAN模式控制位(0:BasicCAN，1：PeliCAN)

/****************************************
内部RAM地址0-63（FIFO）
****************************************/
#define SJA_RAM_FIFO SJA_BASE_ADDR + 0x20    //内部RAM地址（FIFO）

/****************************************
内部RAM地址64-76（TX缓冲器）
****************************************/
#define SJA_RAM_TX   SJA_BASE_ADDR + 0x60    //内部RAM地址（TX缓冲器）

/****************************************
暂未分配功能的保留寄存器
****************************************/
#define SJA_05       SJA_BASE_ADDR + 0x05
#define SJA_0a       SJA_BASE_ADDR + 0x0a

#endif /* Peli_CAN */

#endif /* SJA1000_H_ */
