#include "system.h"
#include <stdio.h>
#include "io.h"
#include "segled_controller_regs.h"
#include "unistd.h"

int main()
{
	int cnt;	//计数器

	IOWR_AVALON_SEGLED_DOT(SEGLED_CONTROLLER_BASE, 0x4);		//设置小数点位置
	IOWR_AVALON_SEGLED_EN(SEGLED_CONTROLLER_BASE,1);			//打开数码管使能

	IOWR_AVALON_SEGLED_SIGN(SEGLED_CONTROLLER_BASE,1);			//显示负号
	for(cnt=999;cnt>=0;cnt--){
		IOWR_AVALON_SEGLED_DATA	(SEGLED_CONTROLLER_BASE,cnt);	//指定显示数值
		usleep(10000);
	}

	IOWR_AVALON_SEGLED_SIGN(SEGLED_CONTROLLER_BASE,0);			//取消显示负号
	for(cnt=0;cnt<=999;cnt++){
		IOWR_AVALON_SEGLED_DATA	(SEGLED_CONTROLLER_BASE,cnt);	//指定显示数值
		usleep(10000);
	}

  return 0;
}
