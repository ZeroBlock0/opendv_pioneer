
#ifndef __SEGLED_CONTROLLER_REGS_H__
#define __SEGLED_CONTROLLER_REGS_H__

#include <io.h>

#define IOWR_AVALON_SEGLED_DATA(base, data)     IOWR(base, 0, data)
#define IOWR_AVALON_SEGLED_DOT(base, data)      IOWR(base, 1, data) 
#define IOWR_AVALON_SEGLED_SIGN(base, data)     IOWR(base, 2, data)
#define IOWR_AVALON_SEGLED_EN(base, data)       IOWR(base, 3, data)

#endif /* __SEGLED_CONTROLLER_REGS_H__ */
