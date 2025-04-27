//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           ucosii_sem
// Last modified Date:  2018/11/20 15:12:09
// Last Version:        V1.0
// Descriptions:
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/11/20 15:12:09
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

#include <stdio.h>
#include "includes.h"

//定义堆栈大小
#define   TASK_STACKSIZE       2048

//定义任务堆栈
OS_STK    start_stk[TASK_STACKSIZE];
OS_STK    task1_stk[TASK_STACKSIZE];
OS_STK    task2_stk[TASK_STACKSIZE];

//定义任务优先级
#define START_PRIORITY      4
#define TASK1_PRIORITY      5
#define TASK2_PRIORITY      6

//定义信号量 ,用作共享资源访问的信号量
OS_EVENT *shared_sem;

//共享内存单元
char shared_memory[40];

//任务1 打印字符
void task1(void* pdata)
{
	INT8U return_code = OS_NO_ERR; //系统调用的返回状态
	INT8U task1_str[] = "First Task Running";
	while (1)
	{

		printf("task1:\n");
		OSSemPend(shared_sem, 0, &return_code);
		memcpy(shared_memory,task1_str,sizeof(task1_str));
		usleep(200000);
		printf("%s\r\n",shared_memory);
		OSSemPost(shared_sem);
		OSTimeDlyHMSM(0, 0, 2, 0);
	}
}

//任务2 打印字符
void task2(void* pdata)
{
	INT8U return_code = OS_NO_ERR; //系统调用的返回状态
	INT8U task2_str[] = "Second Task Running";
	while (1)
	{
		printf("task2:\n");
		OSSemPend(shared_sem, 0, &return_code);
		memcpy(shared_memory,task2_str,sizeof(task2_str));
		usleep(200000);
		printf("%s\r\n",shared_memory);
		OSSemPost(shared_sem);
		OSTimeDlyHMSM(0, 0, 2, 0);
	}
}

//开始任务
void start_task(void* pdata)
{
	initOSsemaphore();
	initCreateTasks();
	//任务自我删除
	OSTaskDel(OS_PRIO_SELF);
	while(1);
}

//初始化信号量
int initOSsemaphore(void)
{ 	//用作二值信号量时,信号量初始化为1
	shared_sem = OSSemCreate(1);
	return 0;
}

//初始化任务函数
void initCreateTasks()
{
	//创建任务1
	OSTaskCreateExt(task1,
				  NULL,
				  (void *)&task1_stk[TASK_STACKSIZE-1],
				  TASK1_PRIORITY,
				  TASK1_PRIORITY,
				  task1_stk,
				  TASK_STACKSIZE,
				  NULL,
				  0);

	//创建任务2
	OSTaskCreateExt(task2,
				  NULL,
				  (void *)&task2_stk[TASK_STACKSIZE-1],
				  TASK2_PRIORITY,
				  TASK2_PRIORITY,
				  task2_stk,
				  TASK_STACKSIZE,
				  NULL,
				  0);
}

//主函数
int main(void)
{
  //创建开始任务
	OSTaskCreateExt(start_task,
				  NULL,
				  (void *)&start_stk[TASK_STACKSIZE-1],
				  START_PRIORITY,
				  START_PRIORITY,
				  start_stk,
				  TASK_STACKSIZE,
				  NULL,
				  0);

	OSStart();
	return 0;
}
