/*************************************************************************
* Copyright (c) 2004 Altera Corporation, San Jose, California, USA.      *
* All rights reserved. All use of this software and documentation is     *
* subject to the License Agreement located at the end of this file below.*
**************************************************************************
* Description:                                                           *
* The following is a simple hello world program running MicroC/OS-II.The * 
* purpose of the design is to be a very simple application that just     *
* demonstrates MicroC/OS-II running on NIOS II.The design doesn't account*
* for issues such as checking system call return codes. etc.             *
*                                                                        *
* Requirements:                                                          *
*   -Supported Example Hardware Platforms                                *
*     Standard                                                           *
*     Full Featured                                                      *
*     Low Cost                                                           *
*   -Supported Development Boards                                        *
*     Nios II Development Board, Stratix II Edition                      *
*     Nios Development Board, Stratix Professional Edition               *
*     Nios Development Board, Stratix Edition                            *
*     Nios Development Board, Cyclone Edition                            *
*   -System Library Settings                                             *
*     RTOS Type - MicroC/OS-II                                           *
*     Periodic System Timer                                              *
*   -Know Issues                                                         *
*     If this design is run on the ISS, terminal output will take several*
*     minutes per iteration.                                             *
**************************************************************************/


#include <stdio.h>
#include "includes.h"

void time_task(void* pdata);
void CPUInfo_task(void* pdata);

/* Definition of Task Stacks */
#define   TASK_STACKSIZE       2048
OS_STK    start_stk[TASK_STACKSIZE];
OS_STK    time_stk[TASK_STACKSIZE];
OS_STK    CPUInfo_stk[TASK_STACKSIZE];

/* Definition of Task Priorities */

#define START_PRIORITY     100
#define TIME_PRIORITY      101
#define CPUINFO_PRIORITY   102

//开始任务
void start_task(void* pdata)
{
	  OSTaskCreateExt(time_task,
	                  NULL,
	                  (void *)&time_stk[TASK_STACKSIZE-1],
	                  TIME_PRIORITY,
	                  TIME_PRIORITY,
	                  time_stk,
	                  TASK_STACKSIZE,
	                  NULL,
	                  0);


	  OSTaskCreateExt(CPUInfo_task,
	                  NULL,
	                  (void *)&CPUInfo_stk[TASK_STACKSIZE-1],
	                  CPUINFO_PRIORITY,
	                  CPUINFO_PRIORITY,
	                  CPUInfo_stk,
	                  TASK_STACKSIZE,
	                  NULL,
	                  0);

	  OSTaskDel(START_PRIORITY);
}

/* 获取系统时间 */
void time_task(void* pdata)
{
  while (1)
  { 
    printf("The System Time is %d\n",OSTimeGet());
    OSTimeDlyHMSM(0, 0, 0, 500);
  }
}
/* 获取CPU使用率 */
void CPUInfo_task(void* pdata)
{
  while (1)
  { 
    printf("The CPU Usage is %d\n",OSCPUUsage);
    OSTimeDlyHMSM(0, 0, 1, 0);
  }
}
/* 创建开始任务*/
int main(void)
{
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

/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2004 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
* Altera does not recommend, suggest or require that this reference design    *
* file be used in conjunction or combination with any other product.          *
******************************************************************************/
