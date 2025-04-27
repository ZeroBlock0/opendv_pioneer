/*
 * system.h - SOPC Builder system and BSP software package information
 *
 * Machine generated for CPU 'nios2' in SOPC Builder design 'system_qsys'
 * SOPC Builder design path: F:/project/qsys_gui_comprehensive_test/qsys/hardware/system_qsys.sopcinfo
 *
 * Generated: Thu Apr 11 13:40:26 CST 2019
 */

/*
 * DO NOT MODIFY THIS FILE
 *
 * Changing this file will have subtle consequences
 * which will almost certainly lead to a nonfunctioning
 * system. If you do modify this file, be aware that your
 * changes will be overwritten and lost when this file
 * is generated again.
 *
 * DO NOT MODIFY THIS FILE
 */

/*
 * License Agreement
 *
 * Copyright (c) 2008
 * Altera Corporation, San Jose, California, USA.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * This agreement shall be governed in all respects by the laws of the State
 * of California and by the laws of the United States of America.
 */

#ifndef __SYSTEM_H_
#define __SYSTEM_H_

/* Include definitions from linker script generator */
#include "linker.h"


/*
 * CPU configuration
 *
 */

#define ALT_CPU_ARCHITECTURE "altera_nios2_qsys"
#define ALT_CPU_BIG_ENDIAN 0
#define ALT_CPU_BREAK_ADDR 0x02001820
#define ALT_CPU_CPU_FREQ 100000000u
#define ALT_CPU_CPU_ID_SIZE 1
#define ALT_CPU_CPU_ID_VALUE 0x00000000
#define ALT_CPU_CPU_IMPLEMENTATION "fast"
#define ALT_CPU_DATA_ADDR_WIDTH 0x1a
#define ALT_CPU_DCACHE_LINE_SIZE 32
#define ALT_CPU_DCACHE_LINE_SIZE_LOG2 5
#define ALT_CPU_DCACHE_SIZE 2048
#define ALT_CPU_EXCEPTION_ADDR 0x00000020
#define ALT_CPU_FLUSHDA_SUPPORTED
#define ALT_CPU_FREQ 100000000
#define ALT_CPU_HARDWARE_DIVIDE_PRESENT 0
#define ALT_CPU_HARDWARE_MULTIPLY_PRESENT 1
#define ALT_CPU_HARDWARE_MULX_PRESENT 0
#define ALT_CPU_HAS_DEBUG_CORE 1
#define ALT_CPU_HAS_DEBUG_STUB
#define ALT_CPU_HAS_JMPI_INSTRUCTION
#define ALT_CPU_ICACHE_LINE_SIZE 32
#define ALT_CPU_ICACHE_LINE_SIZE_LOG2 5
#define ALT_CPU_ICACHE_SIZE 4096
#define ALT_CPU_INITDA_SUPPORTED
#define ALT_CPU_INST_ADDR_WIDTH 0x1a
#define ALT_CPU_NAME "nios2"
#define ALT_CPU_NUM_OF_SHADOW_REG_SETS 0
#define ALT_CPU_RESET_ADDR 0x02001000


/*
 * CPU configuration (with legacy prefix - don't use these anymore)
 *
 */

#define NIOS2_BIG_ENDIAN 0
#define NIOS2_BREAK_ADDR 0x02001820
#define NIOS2_CPU_FREQ 100000000u
#define NIOS2_CPU_ID_SIZE 1
#define NIOS2_CPU_ID_VALUE 0x00000000
#define NIOS2_CPU_IMPLEMENTATION "fast"
#define NIOS2_DATA_ADDR_WIDTH 0x1a
#define NIOS2_DCACHE_LINE_SIZE 32
#define NIOS2_DCACHE_LINE_SIZE_LOG2 5
#define NIOS2_DCACHE_SIZE 2048
#define NIOS2_EXCEPTION_ADDR 0x00000020
#define NIOS2_FLUSHDA_SUPPORTED
#define NIOS2_HARDWARE_DIVIDE_PRESENT 0
#define NIOS2_HARDWARE_MULTIPLY_PRESENT 1
#define NIOS2_HARDWARE_MULX_PRESENT 0
#define NIOS2_HAS_DEBUG_CORE 1
#define NIOS2_HAS_DEBUG_STUB
#define NIOS2_HAS_JMPI_INSTRUCTION
#define NIOS2_ICACHE_LINE_SIZE 32
#define NIOS2_ICACHE_LINE_SIZE_LOG2 5
#define NIOS2_ICACHE_SIZE 4096
#define NIOS2_INITDA_SUPPORTED
#define NIOS2_INST_ADDR_WIDTH 0x1a
#define NIOS2_NUM_OF_SHADOW_REG_SETS 0
#define NIOS2_RESET_ADDR 0x02001000


/*
 * Define for each module class mastered by the CPU
 *
 */

#define __ALTERA_AVALON_EPCS_FLASH_CONTROLLER
#define __ALTERA_AVALON_JTAG_UART
#define __ALTERA_AVALON_NEW_SDRAM_CONTROLLER
#define __ALTERA_AVALON_PIO
#define __ALTERA_AVALON_SYSID_QSYS
#define __ALTERA_AVALON_UART
#define __ALTERA_NIOS2_QSYS
#define __ALT_VIP_CL_SCL
#define __AVALON_MM_BRIDGE


/*
 * System configuration
 *
 */

#define ALT_DEVICE_FAMILY "Cyclone IV E"
#define ALT_ENHANCED_INTERRUPT_API_PRESENT
#define ALT_IRQ_BASE NULL
#define ALT_LOG_PORT "/dev/null"
#define ALT_LOG_PORT_BASE 0x0
#define ALT_LOG_PORT_DEV null
#define ALT_LOG_PORT_TYPE ""
#define ALT_NUM_EXTERNAL_INTERRUPT_CONTROLLERS 0
#define ALT_NUM_INTERNAL_INTERRUPT_CONTROLLERS 1
#define ALT_NUM_INTERRUPT_CONTROLLERS 1
#define ALT_STDERR "/dev/jtag_uart"
#define ALT_STDERR_BASE 0x2002478
#define ALT_STDERR_DEV jtag_uart
#define ALT_STDERR_IS_JTAG_UART
#define ALT_STDERR_PRESENT
#define ALT_STDERR_TYPE "altera_avalon_jtag_uart"
#define ALT_STDIN "/dev/jtag_uart"
#define ALT_STDIN_BASE 0x2002478
#define ALT_STDIN_DEV jtag_uart
#define ALT_STDIN_IS_JTAG_UART
#define ALT_STDIN_PRESENT
#define ALT_STDIN_TYPE "altera_avalon_jtag_uart"
#define ALT_STDOUT "/dev/jtag_uart"
#define ALT_STDOUT_BASE 0x2002478
#define ALT_STDOUT_DEV jtag_uart
#define ALT_STDOUT_IS_JTAG_UART
#define ALT_STDOUT_PRESENT
#define ALT_STDOUT_TYPE "altera_avalon_jtag_uart"
#define ALT_SYSTEM_NAME "system_qsys"


/*
 * alt_vip_cl_scl_0 configuration
 *
 */

#define ALT_MODULE_CLASS_alt_vip_cl_scl_0 alt_vip_cl_scl
#define ALT_VIP_CL_SCL_0_BASE 0x2002000
#define ALT_VIP_CL_SCL_0_IRQ -1
#define ALT_VIP_CL_SCL_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define ALT_VIP_CL_SCL_0_NAME "/dev/alt_vip_cl_scl_0"
#define ALT_VIP_CL_SCL_0_SPAN 512
#define ALT_VIP_CL_SCL_0_TYPE "alt_vip_cl_scl"


/*
 * altera_hostfs configuration
 *
 */

#define ALTERA_HOSTFS_NAME "/mnt/host"


/*
 * epcs_flash configuration
 *
 */

#define ALT_MODULE_CLASS_epcs_flash altera_avalon_epcs_flash_controller
#define EPCS_FLASH_BASE 0x2001000
#define EPCS_FLASH_IRQ 1
#define EPCS_FLASH_IRQ_INTERRUPT_CONTROLLER_ID 0
#define EPCS_FLASH_NAME "/dev/epcs_flash"
#define EPCS_FLASH_REGISTER_OFFSET 1024
#define EPCS_FLASH_SPAN 2048
#define EPCS_FLASH_TYPE "altera_avalon_epcs_flash_controller"


/*
 * hal configuration
 *
 */

#define ALT_MAX_FD 32
#define ALT_SYS_CLK none
#define ALT_TIMESTAMP_CLK none


/*
 * i2c_scl configuration
 *
 */

#define ALT_MODULE_CLASS_i2c_scl altera_avalon_pio
#define I2C_SCL_BASE 0x2002460
#define I2C_SCL_BIT_CLEARING_EDGE_REGISTER 0
#define I2C_SCL_BIT_MODIFYING_OUTPUT_REGISTER 0
#define I2C_SCL_CAPTURE 0
#define I2C_SCL_DATA_WIDTH 1
#define I2C_SCL_DO_TEST_BENCH_WIRING 0
#define I2C_SCL_DRIVEN_SIM_VALUE 0
#define I2C_SCL_EDGE_TYPE "NONE"
#define I2C_SCL_FREQ 100000000
#define I2C_SCL_HAS_IN 0
#define I2C_SCL_HAS_OUT 1
#define I2C_SCL_HAS_TRI 0
#define I2C_SCL_IRQ -1
#define I2C_SCL_IRQ_INTERRUPT_CONTROLLER_ID -1
#define I2C_SCL_IRQ_TYPE "NONE"
#define I2C_SCL_NAME "/dev/i2c_scl"
#define I2C_SCL_RESET_VALUE 0
#define I2C_SCL_SPAN 16
#define I2C_SCL_TYPE "altera_avalon_pio"


/*
 * i2c_sda configuration
 *
 */

#define ALT_MODULE_CLASS_i2c_sda altera_avalon_pio
#define I2C_SDA_BASE 0x2002450
#define I2C_SDA_BIT_CLEARING_EDGE_REGISTER 0
#define I2C_SDA_BIT_MODIFYING_OUTPUT_REGISTER 0
#define I2C_SDA_CAPTURE 0
#define I2C_SDA_DATA_WIDTH 1
#define I2C_SDA_DO_TEST_BENCH_WIRING 0
#define I2C_SDA_DRIVEN_SIM_VALUE 0
#define I2C_SDA_EDGE_TYPE "NONE"
#define I2C_SDA_FREQ 100000000
#define I2C_SDA_HAS_IN 0
#define I2C_SDA_HAS_OUT 0
#define I2C_SDA_HAS_TRI 1
#define I2C_SDA_IRQ -1
#define I2C_SDA_IRQ_INTERRUPT_CONTROLLER_ID -1
#define I2C_SDA_IRQ_TYPE "NONE"
#define I2C_SDA_NAME "/dev/i2c_sda"
#define I2C_SDA_RESET_VALUE 0
#define I2C_SDA_SPAN 16
#define I2C_SDA_TYPE "altera_avalon_pio"


/*
 * jtag_uart configuration
 *
 */

#define ALT_MODULE_CLASS_jtag_uart altera_avalon_jtag_uart
#define JTAG_UART_BASE 0x2002478
#define JTAG_UART_IRQ 0
#define JTAG_UART_IRQ_INTERRUPT_CONTROLLER_ID 0
#define JTAG_UART_NAME "/dev/jtag_uart"
#define JTAG_UART_READ_DEPTH 64
#define JTAG_UART_READ_THRESHOLD 8
#define JTAG_UART_SPAN 8
#define JTAG_UART_TYPE "altera_avalon_jtag_uart"
#define JTAG_UART_WRITE_DEPTH 64
#define JTAG_UART_WRITE_THRESHOLD 8


/*
 * mm_bridge_adda configuration
 *
 */

#define ALT_MODULE_CLASS_mm_bridge_adda avalon_mm_bridge
#define MM_BRIDGE_ADDA_BASE 0x2002220
#define MM_BRIDGE_ADDA_IRQ -1
#define MM_BRIDGE_ADDA_IRQ_INTERRUPT_CONTROLLER_ID -1
#define MM_BRIDGE_ADDA_NAME "/dev/mm_bridge_adda"
#define MM_BRIDGE_ADDA_SPAN 32
#define MM_BRIDGE_ADDA_TYPE "avalon_mm_bridge"


/*
 * mm_bridge_remote configuration
 *
 */

#define ALT_MODULE_CLASS_mm_bridge_remote avalon_mm_bridge
#define MM_BRIDGE_REMOTE_BASE 0x2002240
#define MM_BRIDGE_REMOTE_IRQ -1
#define MM_BRIDGE_REMOTE_IRQ_INTERRUPT_CONTROLLER_ID -1
#define MM_BRIDGE_REMOTE_NAME "/dev/mm_bridge_remote"
#define MM_BRIDGE_REMOTE_SPAN 32
#define MM_BRIDGE_REMOTE_TYPE "avalon_mm_bridge"


/*
 * mm_bridge_seg configuration
 *
 */

#define ALT_MODULE_CLASS_mm_bridge_seg avalon_mm_bridge
#define MM_BRIDGE_SEG_BASE 0x2002260
#define MM_BRIDGE_SEG_IRQ -1
#define MM_BRIDGE_SEG_IRQ_INTERRUPT_CONTROLLER_ID -1
#define MM_BRIDGE_SEG_NAME "/dev/mm_bridge_seg"
#define MM_BRIDGE_SEG_SPAN 32
#define MM_BRIDGE_SEG_TYPE "avalon_mm_bridge"


/*
 * mm_bridge_touch configuration
 *
 */

#define ALT_MODULE_CLASS_mm_bridge_touch avalon_mm_bridge
#define MM_BRIDGE_TOUCH_BASE 0x2002280
#define MM_BRIDGE_TOUCH_IRQ -1
#define MM_BRIDGE_TOUCH_IRQ_INTERRUPT_CONTROLLER_ID -1
#define MM_BRIDGE_TOUCH_NAME "/dev/mm_bridge_touch"
#define MM_BRIDGE_TOUCH_SPAN 32
#define MM_BRIDGE_TOUCH_TYPE "avalon_mm_bridge"


/*
 * pio_audio_sel configuration
 *
 */

#define ALT_MODULE_CLASS_pio_audio_sel altera_avalon_pio
#define PIO_AUDIO_SEL_BASE 0x20022a0
#define PIO_AUDIO_SEL_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_AUDIO_SEL_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_AUDIO_SEL_CAPTURE 0
#define PIO_AUDIO_SEL_DATA_WIDTH 1
#define PIO_AUDIO_SEL_DO_TEST_BENCH_WIRING 0
#define PIO_AUDIO_SEL_DRIVEN_SIM_VALUE 0
#define PIO_AUDIO_SEL_EDGE_TYPE "NONE"
#define PIO_AUDIO_SEL_FREQ 100000000
#define PIO_AUDIO_SEL_HAS_IN 0
#define PIO_AUDIO_SEL_HAS_OUT 1
#define PIO_AUDIO_SEL_HAS_TRI 0
#define PIO_AUDIO_SEL_IRQ -1
#define PIO_AUDIO_SEL_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_AUDIO_SEL_IRQ_TYPE "NONE"
#define PIO_AUDIO_SEL_NAME "/dev/pio_audio_sel"
#define PIO_AUDIO_SEL_RESET_VALUE 0
#define PIO_AUDIO_SEL_SPAN 16
#define PIO_AUDIO_SEL_TYPE "altera_avalon_pio"


/*
 * pio_back configuration
 *
 */

#define ALT_MODULE_CLASS_pio_back altera_avalon_pio
#define PIO_BACK_BASE 0x2002430
#define PIO_BACK_BIT_CLEARING_EDGE_REGISTER 1
#define PIO_BACK_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_BACK_CAPTURE 1
#define PIO_BACK_DATA_WIDTH 1
#define PIO_BACK_DO_TEST_BENCH_WIRING 0
#define PIO_BACK_DRIVEN_SIM_VALUE 0
#define PIO_BACK_EDGE_TYPE "RISING"
#define PIO_BACK_FREQ 100000000
#define PIO_BACK_HAS_IN 1
#define PIO_BACK_HAS_OUT 0
#define PIO_BACK_HAS_TRI 0
#define PIO_BACK_IRQ 3
#define PIO_BACK_IRQ_INTERRUPT_CONTROLLER_ID 0
#define PIO_BACK_IRQ_TYPE "EDGE"
#define PIO_BACK_NAME "/dev/pio_back"
#define PIO_BACK_RESET_VALUE 0
#define PIO_BACK_SPAN 16
#define PIO_BACK_TYPE "altera_avalon_pio"


/*
 * pio_buzzer configuration
 *
 */

#define ALT_MODULE_CLASS_pio_buzzer altera_avalon_pio
#define PIO_BUZZER_BASE 0x2002400
#define PIO_BUZZER_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_BUZZER_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_BUZZER_CAPTURE 0
#define PIO_BUZZER_DATA_WIDTH 1
#define PIO_BUZZER_DO_TEST_BENCH_WIRING 0
#define PIO_BUZZER_DRIVEN_SIM_VALUE 0
#define PIO_BUZZER_EDGE_TYPE "NONE"
#define PIO_BUZZER_FREQ 100000000
#define PIO_BUZZER_HAS_IN 0
#define PIO_BUZZER_HAS_OUT 1
#define PIO_BUZZER_HAS_TRI 0
#define PIO_BUZZER_IRQ -1
#define PIO_BUZZER_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_BUZZER_IRQ_TYPE "NONE"
#define PIO_BUZZER_NAME "/dev/pio_buzzer"
#define PIO_BUZZER_RESET_VALUE 0
#define PIO_BUZZER_SPAN 16
#define PIO_BUZZER_TYPE "altera_avalon_pio"


/*
 * pio_key configuration
 *
 */

#define ALT_MODULE_CLASS_pio_key altera_avalon_pio
#define PIO_KEY_BASE 0x2002420
#define PIO_KEY_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_KEY_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_KEY_CAPTURE 0
#define PIO_KEY_DATA_WIDTH 4
#define PIO_KEY_DO_TEST_BENCH_WIRING 0
#define PIO_KEY_DRIVEN_SIM_VALUE 0
#define PIO_KEY_EDGE_TYPE "NONE"
#define PIO_KEY_FREQ 100000000
#define PIO_KEY_HAS_IN 1
#define PIO_KEY_HAS_OUT 0
#define PIO_KEY_HAS_TRI 0
#define PIO_KEY_IRQ -1
#define PIO_KEY_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_KEY_IRQ_TYPE "NONE"
#define PIO_KEY_NAME "/dev/pio_key"
#define PIO_KEY_RESET_VALUE 0
#define PIO_KEY_SPAN 16
#define PIO_KEY_TYPE "altera_avalon_pio"


/*
 * pio_lcd_data_dir configuration
 *
 */

#define ALT_MODULE_CLASS_pio_lcd_data_dir altera_avalon_pio
#define PIO_LCD_DATA_DIR_BASE 0x2002340
#define PIO_LCD_DATA_DIR_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_LCD_DATA_DIR_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_LCD_DATA_DIR_CAPTURE 0
#define PIO_LCD_DATA_DIR_DATA_WIDTH 1
#define PIO_LCD_DATA_DIR_DO_TEST_BENCH_WIRING 0
#define PIO_LCD_DATA_DIR_DRIVEN_SIM_VALUE 0
#define PIO_LCD_DATA_DIR_EDGE_TYPE "NONE"
#define PIO_LCD_DATA_DIR_FREQ 100000000
#define PIO_LCD_DATA_DIR_HAS_IN 0
#define PIO_LCD_DATA_DIR_HAS_OUT 1
#define PIO_LCD_DATA_DIR_HAS_TRI 0
#define PIO_LCD_DATA_DIR_IRQ -1
#define PIO_LCD_DATA_DIR_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_LCD_DATA_DIR_IRQ_TYPE "NONE"
#define PIO_LCD_DATA_DIR_NAME "/dev/pio_lcd_data_dir"
#define PIO_LCD_DATA_DIR_RESET_VALUE 0
#define PIO_LCD_DATA_DIR_SPAN 16
#define PIO_LCD_DATA_DIR_TYPE "altera_avalon_pio"


/*
 * pio_lcd_data_in configuration
 *
 */

#define ALT_MODULE_CLASS_pio_lcd_data_in altera_avalon_pio
#define PIO_LCD_DATA_IN_BASE 0x2002360
#define PIO_LCD_DATA_IN_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_LCD_DATA_IN_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_LCD_DATA_IN_CAPTURE 0
#define PIO_LCD_DATA_IN_DATA_WIDTH 16
#define PIO_LCD_DATA_IN_DO_TEST_BENCH_WIRING 0
#define PIO_LCD_DATA_IN_DRIVEN_SIM_VALUE 0
#define PIO_LCD_DATA_IN_EDGE_TYPE "NONE"
#define PIO_LCD_DATA_IN_FREQ 100000000
#define PIO_LCD_DATA_IN_HAS_IN 1
#define PIO_LCD_DATA_IN_HAS_OUT 0
#define PIO_LCD_DATA_IN_HAS_TRI 0
#define PIO_LCD_DATA_IN_IRQ -1
#define PIO_LCD_DATA_IN_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_LCD_DATA_IN_IRQ_TYPE "NONE"
#define PIO_LCD_DATA_IN_NAME "/dev/pio_lcd_data_in"
#define PIO_LCD_DATA_IN_RESET_VALUE 0
#define PIO_LCD_DATA_IN_SPAN 16
#define PIO_LCD_DATA_IN_TYPE "altera_avalon_pio"


/*
 * pio_lcd_data_out configuration
 *
 */

#define ALT_MODULE_CLASS_pio_lcd_data_out altera_avalon_pio
#define PIO_LCD_DATA_OUT_BASE 0x2002350
#define PIO_LCD_DATA_OUT_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_LCD_DATA_OUT_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_LCD_DATA_OUT_CAPTURE 0
#define PIO_LCD_DATA_OUT_DATA_WIDTH 16
#define PIO_LCD_DATA_OUT_DO_TEST_BENCH_WIRING 0
#define PIO_LCD_DATA_OUT_DRIVEN_SIM_VALUE 0
#define PIO_LCD_DATA_OUT_EDGE_TYPE "NONE"
#define PIO_LCD_DATA_OUT_FREQ 100000000
#define PIO_LCD_DATA_OUT_HAS_IN 0
#define PIO_LCD_DATA_OUT_HAS_OUT 1
#define PIO_LCD_DATA_OUT_HAS_TRI 0
#define PIO_LCD_DATA_OUT_IRQ -1
#define PIO_LCD_DATA_OUT_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_LCD_DATA_OUT_IRQ_TYPE "NONE"
#define PIO_LCD_DATA_OUT_NAME "/dev/pio_lcd_data_out"
#define PIO_LCD_DATA_OUT_RESET_VALUE 0
#define PIO_LCD_DATA_OUT_SPAN 16
#define PIO_LCD_DATA_OUT_TYPE "altera_avalon_pio"


/*
 * pio_lcd_id configuration
 *
 */

#define ALT_MODULE_CLASS_pio_lcd_id altera_avalon_pio
#define PIO_LCD_ID_BASE 0x2002320
#define PIO_LCD_ID_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_LCD_ID_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_LCD_ID_CAPTURE 0
#define PIO_LCD_ID_DATA_WIDTH 16
#define PIO_LCD_ID_DO_TEST_BENCH_WIRING 0
#define PIO_LCD_ID_DRIVEN_SIM_VALUE 0
#define PIO_LCD_ID_EDGE_TYPE "NONE"
#define PIO_LCD_ID_FREQ 100000000
#define PIO_LCD_ID_HAS_IN 0
#define PIO_LCD_ID_HAS_OUT 1
#define PIO_LCD_ID_HAS_TRI 0
#define PIO_LCD_ID_IRQ -1
#define PIO_LCD_ID_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_LCD_ID_IRQ_TYPE "NONE"
#define PIO_LCD_ID_NAME "/dev/pio_lcd_id"
#define PIO_LCD_ID_RESET_VALUE 0
#define PIO_LCD_ID_SPAN 16
#define PIO_LCD_ID_TYPE "altera_avalon_pio"


/*
 * pio_lcd_init_done configuration
 *
 */

#define ALT_MODULE_CLASS_pio_lcd_init_done altera_avalon_pio
#define PIO_LCD_INIT_DONE_BASE 0x2002330
#define PIO_LCD_INIT_DONE_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_LCD_INIT_DONE_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_LCD_INIT_DONE_CAPTURE 0
#define PIO_LCD_INIT_DONE_DATA_WIDTH 1
#define PIO_LCD_INIT_DONE_DO_TEST_BENCH_WIRING 0
#define PIO_LCD_INIT_DONE_DRIVEN_SIM_VALUE 0
#define PIO_LCD_INIT_DONE_EDGE_TYPE "NONE"
#define PIO_LCD_INIT_DONE_FREQ 100000000
#define PIO_LCD_INIT_DONE_HAS_IN 0
#define PIO_LCD_INIT_DONE_HAS_OUT 1
#define PIO_LCD_INIT_DONE_HAS_TRI 0
#define PIO_LCD_INIT_DONE_IRQ -1
#define PIO_LCD_INIT_DONE_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_LCD_INIT_DONE_IRQ_TYPE "NONE"
#define PIO_LCD_INIT_DONE_NAME "/dev/pio_lcd_init_done"
#define PIO_LCD_INIT_DONE_RESET_VALUE 0
#define PIO_LCD_INIT_DONE_SPAN 16
#define PIO_LCD_INIT_DONE_TYPE "altera_avalon_pio"


/*
 * pio_led configuration
 *
 */

#define ALT_MODULE_CLASS_pio_led altera_avalon_pio
#define PIO_LED_BASE 0x2002410
#define PIO_LED_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_LED_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_LED_CAPTURE 0
#define PIO_LED_DATA_WIDTH 4
#define PIO_LED_DO_TEST_BENCH_WIRING 0
#define PIO_LED_DRIVEN_SIM_VALUE 0
#define PIO_LED_EDGE_TYPE "NONE"
#define PIO_LED_FREQ 100000000
#define PIO_LED_HAS_IN 0
#define PIO_LED_HAS_OUT 1
#define PIO_LED_HAS_TRI 0
#define PIO_LED_IRQ -1
#define PIO_LED_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_LED_IRQ_TYPE "NONE"
#define PIO_LED_NAME "/dev/pio_led"
#define PIO_LED_RESET_VALUE 0
#define PIO_LED_SPAN 16
#define PIO_LED_TYPE "altera_avalon_pio"


/*
 * pio_mdc configuration
 *
 */

#define ALT_MODULE_CLASS_pio_mdc altera_avalon_pio
#define PIO_MDC_BASE 0x2002310
#define PIO_MDC_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_MDC_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_MDC_CAPTURE 0
#define PIO_MDC_DATA_WIDTH 1
#define PIO_MDC_DO_TEST_BENCH_WIRING 0
#define PIO_MDC_DRIVEN_SIM_VALUE 0
#define PIO_MDC_EDGE_TYPE "NONE"
#define PIO_MDC_FREQ 100000000
#define PIO_MDC_HAS_IN 0
#define PIO_MDC_HAS_OUT 1
#define PIO_MDC_HAS_TRI 0
#define PIO_MDC_IRQ -1
#define PIO_MDC_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_MDC_IRQ_TYPE "NONE"
#define PIO_MDC_NAME "/dev/pio_mdc"
#define PIO_MDC_RESET_VALUE 0
#define PIO_MDC_SPAN 16
#define PIO_MDC_TYPE "altera_avalon_pio"


/*
 * pio_mdio configuration
 *
 */

#define ALT_MODULE_CLASS_pio_mdio altera_avalon_pio
#define PIO_MDIO_BASE 0x2002300
#define PIO_MDIO_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_MDIO_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_MDIO_CAPTURE 0
#define PIO_MDIO_DATA_WIDTH 1
#define PIO_MDIO_DO_TEST_BENCH_WIRING 0
#define PIO_MDIO_DRIVEN_SIM_VALUE 0
#define PIO_MDIO_EDGE_TYPE "NONE"
#define PIO_MDIO_FREQ 100000000
#define PIO_MDIO_HAS_IN 0
#define PIO_MDIO_HAS_OUT 0
#define PIO_MDIO_HAS_TRI 1
#define PIO_MDIO_IRQ -1
#define PIO_MDIO_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_MDIO_IRQ_TYPE "NONE"
#define PIO_MDIO_NAME "/dev/pio_mdio"
#define PIO_MDIO_RESET_VALUE 0
#define PIO_MDIO_SPAN 16
#define PIO_MDIO_TYPE "altera_avalon_pio"


/*
 * pio_mlcd_bl configuration
 *
 */

#define ALT_MODULE_CLASS_pio_mlcd_bl altera_avalon_pio
#define PIO_MLCD_BL_BASE 0x2002370
#define PIO_MLCD_BL_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_MLCD_BL_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_MLCD_BL_CAPTURE 0
#define PIO_MLCD_BL_DATA_WIDTH 1
#define PIO_MLCD_BL_DO_TEST_BENCH_WIRING 0
#define PIO_MLCD_BL_DRIVEN_SIM_VALUE 0
#define PIO_MLCD_BL_EDGE_TYPE "NONE"
#define PIO_MLCD_BL_FREQ 100000000
#define PIO_MLCD_BL_HAS_IN 0
#define PIO_MLCD_BL_HAS_OUT 1
#define PIO_MLCD_BL_HAS_TRI 0
#define PIO_MLCD_BL_IRQ -1
#define PIO_MLCD_BL_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_MLCD_BL_IRQ_TYPE "NONE"
#define PIO_MLCD_BL_NAME "/dev/pio_mlcd_bl"
#define PIO_MLCD_BL_RESET_VALUE 0
#define PIO_MLCD_BL_SPAN 16
#define PIO_MLCD_BL_TYPE "altera_avalon_pio"


/*
 * pio_mlcd_cs_n configuration
 *
 */

#define ALT_MODULE_CLASS_pio_mlcd_cs_n altera_avalon_pio
#define PIO_MLCD_CS_N_BASE 0x20023c0
#define PIO_MLCD_CS_N_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_MLCD_CS_N_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_MLCD_CS_N_CAPTURE 0
#define PIO_MLCD_CS_N_DATA_WIDTH 1
#define PIO_MLCD_CS_N_DO_TEST_BENCH_WIRING 0
#define PIO_MLCD_CS_N_DRIVEN_SIM_VALUE 0
#define PIO_MLCD_CS_N_EDGE_TYPE "NONE"
#define PIO_MLCD_CS_N_FREQ 100000000
#define PIO_MLCD_CS_N_HAS_IN 0
#define PIO_MLCD_CS_N_HAS_OUT 1
#define PIO_MLCD_CS_N_HAS_TRI 0
#define PIO_MLCD_CS_N_IRQ -1
#define PIO_MLCD_CS_N_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_MLCD_CS_N_IRQ_TYPE "NONE"
#define PIO_MLCD_CS_N_NAME "/dev/pio_mlcd_cs_n"
#define PIO_MLCD_CS_N_RESET_VALUE 0
#define PIO_MLCD_CS_N_SPAN 16
#define PIO_MLCD_CS_N_TYPE "altera_avalon_pio"


/*
 * pio_mlcd_rd_n configuration
 *
 */

#define ALT_MODULE_CLASS_pio_mlcd_rd_n altera_avalon_pio
#define PIO_MLCD_RD_N_BASE 0x20023a0
#define PIO_MLCD_RD_N_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_MLCD_RD_N_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_MLCD_RD_N_CAPTURE 0
#define PIO_MLCD_RD_N_DATA_WIDTH 1
#define PIO_MLCD_RD_N_DO_TEST_BENCH_WIRING 0
#define PIO_MLCD_RD_N_DRIVEN_SIM_VALUE 0
#define PIO_MLCD_RD_N_EDGE_TYPE "NONE"
#define PIO_MLCD_RD_N_FREQ 100000000
#define PIO_MLCD_RD_N_HAS_IN 0
#define PIO_MLCD_RD_N_HAS_OUT 1
#define PIO_MLCD_RD_N_HAS_TRI 0
#define PIO_MLCD_RD_N_IRQ -1
#define PIO_MLCD_RD_N_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_MLCD_RD_N_IRQ_TYPE "NONE"
#define PIO_MLCD_RD_N_NAME "/dev/pio_mlcd_rd_n"
#define PIO_MLCD_RD_N_RESET_VALUE 0
#define PIO_MLCD_RD_N_SPAN 16
#define PIO_MLCD_RD_N_TYPE "altera_avalon_pio"


/*
 * pio_mlcd_rs configuration
 *
 */

#define ALT_MODULE_CLASS_pio_mlcd_rs altera_avalon_pio
#define PIO_MLCD_RS_BASE 0x2002380
#define PIO_MLCD_RS_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_MLCD_RS_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_MLCD_RS_CAPTURE 0
#define PIO_MLCD_RS_DATA_WIDTH 1
#define PIO_MLCD_RS_DO_TEST_BENCH_WIRING 0
#define PIO_MLCD_RS_DRIVEN_SIM_VALUE 0
#define PIO_MLCD_RS_EDGE_TYPE "NONE"
#define PIO_MLCD_RS_FREQ 100000000
#define PIO_MLCD_RS_HAS_IN 0
#define PIO_MLCD_RS_HAS_OUT 1
#define PIO_MLCD_RS_HAS_TRI 0
#define PIO_MLCD_RS_IRQ -1
#define PIO_MLCD_RS_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_MLCD_RS_IRQ_TYPE "NONE"
#define PIO_MLCD_RS_NAME "/dev/pio_mlcd_rs"
#define PIO_MLCD_RS_RESET_VALUE 0
#define PIO_MLCD_RS_SPAN 16
#define PIO_MLCD_RS_TYPE "altera_avalon_pio"


/*
 * pio_mlcd_rst_n configuration
 *
 */

#define ALT_MODULE_CLASS_pio_mlcd_rst_n altera_avalon_pio
#define PIO_MLCD_RST_N_BASE 0x2002390
#define PIO_MLCD_RST_N_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_MLCD_RST_N_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_MLCD_RST_N_CAPTURE 0
#define PIO_MLCD_RST_N_DATA_WIDTH 1
#define PIO_MLCD_RST_N_DO_TEST_BENCH_WIRING 0
#define PIO_MLCD_RST_N_DRIVEN_SIM_VALUE 0
#define PIO_MLCD_RST_N_EDGE_TYPE "NONE"
#define PIO_MLCD_RST_N_FREQ 100000000
#define PIO_MLCD_RST_N_HAS_IN 0
#define PIO_MLCD_RST_N_HAS_OUT 1
#define PIO_MLCD_RST_N_HAS_TRI 0
#define PIO_MLCD_RST_N_IRQ -1
#define PIO_MLCD_RST_N_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_MLCD_RST_N_IRQ_TYPE "NONE"
#define PIO_MLCD_RST_N_NAME "/dev/pio_mlcd_rst_n"
#define PIO_MLCD_RST_N_RESET_VALUE 0
#define PIO_MLCD_RST_N_SPAN 16
#define PIO_MLCD_RST_N_TYPE "altera_avalon_pio"


/*
 * pio_mlcd_wr_n configuration
 *
 */

#define ALT_MODULE_CLASS_pio_mlcd_wr_n altera_avalon_pio
#define PIO_MLCD_WR_N_BASE 0x20023b0
#define PIO_MLCD_WR_N_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_MLCD_WR_N_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_MLCD_WR_N_CAPTURE 0
#define PIO_MLCD_WR_N_DATA_WIDTH 1
#define PIO_MLCD_WR_N_DO_TEST_BENCH_WIRING 0
#define PIO_MLCD_WR_N_DRIVEN_SIM_VALUE 0
#define PIO_MLCD_WR_N_EDGE_TYPE "NONE"
#define PIO_MLCD_WR_N_FREQ 100000000
#define PIO_MLCD_WR_N_HAS_IN 0
#define PIO_MLCD_WR_N_HAS_OUT 1
#define PIO_MLCD_WR_N_HAS_TRI 0
#define PIO_MLCD_WR_N_IRQ -1
#define PIO_MLCD_WR_N_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_MLCD_WR_N_IRQ_TYPE "NONE"
#define PIO_MLCD_WR_N_NAME "/dev/pio_mlcd_wr_n"
#define PIO_MLCD_WR_N_RESET_VALUE 0
#define PIO_MLCD_WR_N_SPAN 16
#define PIO_MLCD_WR_N_TYPE "altera_avalon_pio"


/*
 * pio_ov5640_en configuration
 *
 */

#define ALT_MODULE_CLASS_pio_ov5640_en altera_avalon_pio
#define PIO_OV5640_EN_BASE 0x20023e0
#define PIO_OV5640_EN_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_OV5640_EN_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_OV5640_EN_CAPTURE 0
#define PIO_OV5640_EN_DATA_WIDTH 1
#define PIO_OV5640_EN_DO_TEST_BENCH_WIRING 0
#define PIO_OV5640_EN_DRIVEN_SIM_VALUE 0
#define PIO_OV5640_EN_EDGE_TYPE "NONE"
#define PIO_OV5640_EN_FREQ 100000000
#define PIO_OV5640_EN_HAS_IN 0
#define PIO_OV5640_EN_HAS_OUT 1
#define PIO_OV5640_EN_HAS_TRI 0
#define PIO_OV5640_EN_IRQ -1
#define PIO_OV5640_EN_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_OV5640_EN_IRQ_TYPE "NONE"
#define PIO_OV5640_EN_NAME "/dev/pio_ov5640_en"
#define PIO_OV5640_EN_RESET_VALUE 0
#define PIO_OV5640_EN_SPAN 16
#define PIO_OV5640_EN_TYPE "altera_avalon_pio"


/*
 * pio_ov5640_id configuration
 *
 */

#define ALT_MODULE_CLASS_pio_ov5640_id altera_avalon_pio
#define PIO_OV5640_ID_BASE 0x20023d0
#define PIO_OV5640_ID_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_OV5640_ID_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_OV5640_ID_CAPTURE 0
#define PIO_OV5640_ID_DATA_WIDTH 1
#define PIO_OV5640_ID_DO_TEST_BENCH_WIRING 0
#define PIO_OV5640_ID_DRIVEN_SIM_VALUE 0
#define PIO_OV5640_ID_EDGE_TYPE "NONE"
#define PIO_OV5640_ID_FREQ 100000000
#define PIO_OV5640_ID_HAS_IN 1
#define PIO_OV5640_ID_HAS_OUT 0
#define PIO_OV5640_ID_HAS_TRI 0
#define PIO_OV5640_ID_IRQ -1
#define PIO_OV5640_ID_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_OV5640_ID_IRQ_TYPE "NONE"
#define PIO_OV5640_ID_NAME "/dev/pio_ov5640_id"
#define PIO_OV5640_ID_RESET_VALUE 0
#define PIO_OV5640_ID_SPAN 16
#define PIO_OV5640_ID_TYPE "altera_avalon_pio"


/*
 * pio_page_paint_flag configuration
 *
 */

#define ALT_MODULE_CLASS_pio_page_paint_flag altera_avalon_pio
#define PIO_PAGE_PAINT_FLAG_BASE 0x20022b0
#define PIO_PAGE_PAINT_FLAG_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_PAGE_PAINT_FLAG_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_PAGE_PAINT_FLAG_CAPTURE 0
#define PIO_PAGE_PAINT_FLAG_DATA_WIDTH 1
#define PIO_PAGE_PAINT_FLAG_DO_TEST_BENCH_WIRING 0
#define PIO_PAGE_PAINT_FLAG_DRIVEN_SIM_VALUE 0
#define PIO_PAGE_PAINT_FLAG_EDGE_TYPE "NONE"
#define PIO_PAGE_PAINT_FLAG_FREQ 100000000
#define PIO_PAGE_PAINT_FLAG_HAS_IN 0
#define PIO_PAGE_PAINT_FLAG_HAS_OUT 1
#define PIO_PAGE_PAINT_FLAG_HAS_TRI 0
#define PIO_PAGE_PAINT_FLAG_IRQ -1
#define PIO_PAGE_PAINT_FLAG_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_PAGE_PAINT_FLAG_IRQ_TYPE "NONE"
#define PIO_PAGE_PAINT_FLAG_NAME "/dev/pio_page_paint_flag"
#define PIO_PAGE_PAINT_FLAG_RESET_VALUE 0
#define PIO_PAGE_PAINT_FLAG_SPAN 16
#define PIO_PAGE_PAINT_FLAG_TYPE "altera_avalon_pio"


/*
 * pio_paint configuration
 *
 */

#define ALT_MODULE_CLASS_pio_paint altera_avalon_pio
#define PIO_PAINT_BASE 0x20023f0
#define PIO_PAINT_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_PAINT_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_PAINT_CAPTURE 1
#define PIO_PAINT_DATA_WIDTH 1
#define PIO_PAINT_DO_TEST_BENCH_WIRING 0
#define PIO_PAINT_DRIVEN_SIM_VALUE 0
#define PIO_PAINT_EDGE_TYPE "FALLING"
#define PIO_PAINT_FREQ 100000000
#define PIO_PAINT_HAS_IN 1
#define PIO_PAINT_HAS_OUT 0
#define PIO_PAINT_HAS_TRI 0
#define PIO_PAINT_IRQ 5
#define PIO_PAINT_IRQ_INTERRUPT_CONTROLLER_ID 0
#define PIO_PAINT_IRQ_TYPE "EDGE"
#define PIO_PAINT_NAME "/dev/pio_paint"
#define PIO_PAINT_RESET_VALUE 0
#define PIO_PAINT_SPAN 16
#define PIO_PAINT_TYPE "altera_avalon_pio"


/*
 * pio_sd_clk configuration
 *
 */

#define ALT_MODULE_CLASS_pio_sd_clk altera_avalon_pio
#define PIO_SD_CLK_BASE 0x20022e0
#define PIO_SD_CLK_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_SD_CLK_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_SD_CLK_CAPTURE 0
#define PIO_SD_CLK_DATA_WIDTH 1
#define PIO_SD_CLK_DO_TEST_BENCH_WIRING 0
#define PIO_SD_CLK_DRIVEN_SIM_VALUE 0
#define PIO_SD_CLK_EDGE_TYPE "NONE"
#define PIO_SD_CLK_FREQ 100000000
#define PIO_SD_CLK_HAS_IN 0
#define PIO_SD_CLK_HAS_OUT 1
#define PIO_SD_CLK_HAS_TRI 0
#define PIO_SD_CLK_IRQ -1
#define PIO_SD_CLK_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_SD_CLK_IRQ_TYPE "NONE"
#define PIO_SD_CLK_NAME "/dev/pio_sd_clk"
#define PIO_SD_CLK_RESET_VALUE 1
#define PIO_SD_CLK_SPAN 16
#define PIO_SD_CLK_TYPE "altera_avalon_pio"


/*
 * pio_sd_cs configuration
 *
 */

#define ALT_MODULE_CLASS_pio_sd_cs altera_avalon_pio
#define PIO_SD_CS_BASE 0x20022f0
#define PIO_SD_CS_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_SD_CS_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_SD_CS_CAPTURE 0
#define PIO_SD_CS_DATA_WIDTH 1
#define PIO_SD_CS_DO_TEST_BENCH_WIRING 0
#define PIO_SD_CS_DRIVEN_SIM_VALUE 0
#define PIO_SD_CS_EDGE_TYPE "NONE"
#define PIO_SD_CS_FREQ 100000000
#define PIO_SD_CS_HAS_IN 0
#define PIO_SD_CS_HAS_OUT 1
#define PIO_SD_CS_HAS_TRI 0
#define PIO_SD_CS_IRQ -1
#define PIO_SD_CS_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_SD_CS_IRQ_TYPE "NONE"
#define PIO_SD_CS_NAME "/dev/pio_sd_cs"
#define PIO_SD_CS_RESET_VALUE 1
#define PIO_SD_CS_SPAN 16
#define PIO_SD_CS_TYPE "altera_avalon_pio"


/*
 * pio_sd_miso configuration
 *
 */

#define ALT_MODULE_CLASS_pio_sd_miso altera_avalon_pio
#define PIO_SD_MISO_BASE 0x20022c0
#define PIO_SD_MISO_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_SD_MISO_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_SD_MISO_CAPTURE 0
#define PIO_SD_MISO_DATA_WIDTH 1
#define PIO_SD_MISO_DO_TEST_BENCH_WIRING 0
#define PIO_SD_MISO_DRIVEN_SIM_VALUE 0
#define PIO_SD_MISO_EDGE_TYPE "NONE"
#define PIO_SD_MISO_FREQ 100000000
#define PIO_SD_MISO_HAS_IN 1
#define PIO_SD_MISO_HAS_OUT 0
#define PIO_SD_MISO_HAS_TRI 0
#define PIO_SD_MISO_IRQ -1
#define PIO_SD_MISO_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_SD_MISO_IRQ_TYPE "NONE"
#define PIO_SD_MISO_NAME "/dev/pio_sd_miso"
#define PIO_SD_MISO_RESET_VALUE 0
#define PIO_SD_MISO_SPAN 16
#define PIO_SD_MISO_TYPE "altera_avalon_pio"


/*
 * pio_sd_mosi configuration
 *
 */

#define ALT_MODULE_CLASS_pio_sd_mosi altera_avalon_pio
#define PIO_SD_MOSI_BASE 0x20022d0
#define PIO_SD_MOSI_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_SD_MOSI_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_SD_MOSI_CAPTURE 0
#define PIO_SD_MOSI_DATA_WIDTH 1
#define PIO_SD_MOSI_DO_TEST_BENCH_WIRING 0
#define PIO_SD_MOSI_DRIVEN_SIM_VALUE 0
#define PIO_SD_MOSI_EDGE_TYPE "NONE"
#define PIO_SD_MOSI_FREQ 100000000
#define PIO_SD_MOSI_HAS_IN 0
#define PIO_SD_MOSI_HAS_OUT 1
#define PIO_SD_MOSI_HAS_TRI 0
#define PIO_SD_MOSI_IRQ -1
#define PIO_SD_MOSI_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_SD_MOSI_IRQ_TYPE "NONE"
#define PIO_SD_MOSI_NAME "/dev/pio_sd_mosi"
#define PIO_SD_MOSI_RESET_VALUE 1
#define PIO_SD_MOSI_SPAN 16
#define PIO_SD_MOSI_TYPE "altera_avalon_pio"


/*
 * pio_touch_int configuration
 *
 */

#define ALT_MODULE_CLASS_pio_touch_int altera_avalon_pio
#define PIO_TOUCH_INT_BASE 0x2002440
#define PIO_TOUCH_INT_BIT_CLEARING_EDGE_REGISTER 1
#define PIO_TOUCH_INT_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_TOUCH_INT_CAPTURE 1
#define PIO_TOUCH_INT_DATA_WIDTH 1
#define PIO_TOUCH_INT_DO_TEST_BENCH_WIRING 0
#define PIO_TOUCH_INT_DRIVEN_SIM_VALUE 0
#define PIO_TOUCH_INT_EDGE_TYPE "FALLING"
#define PIO_TOUCH_INT_FREQ 100000000
#define PIO_TOUCH_INT_HAS_IN 1
#define PIO_TOUCH_INT_HAS_OUT 0
#define PIO_TOUCH_INT_HAS_TRI 0
#define PIO_TOUCH_INT_IRQ 2
#define PIO_TOUCH_INT_IRQ_INTERRUPT_CONTROLLER_ID 0
#define PIO_TOUCH_INT_IRQ_TYPE "EDGE"
#define PIO_TOUCH_INT_NAME "/dev/pio_touch_int"
#define PIO_TOUCH_INT_RESET_VALUE 0
#define PIO_TOUCH_INT_SPAN 16
#define PIO_TOUCH_INT_TYPE "altera_avalon_pio"


/*
 * sdram configuration
 *
 */

#define ALT_MODULE_CLASS_sdram altera_avalon_new_sdram_controller
#define SDRAM_BASE 0x0
#define SDRAM_CAS_LATENCY 2
#define SDRAM_CONTENTS_INFO
#define SDRAM_INIT_NOP_DELAY 0.0
#define SDRAM_INIT_REFRESH_COMMANDS 8
#define SDRAM_IRQ -1
#define SDRAM_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SDRAM_IS_INITIALIZED 1
#define SDRAM_NAME "/dev/sdram"
#define SDRAM_POWERUP_DELAY 200.0
#define SDRAM_REFRESH_PERIOD 7.8125
#define SDRAM_REGISTER_DATA_IN 1
#define SDRAM_SDRAM_ADDR_WIDTH 0x18
#define SDRAM_SDRAM_BANK_WIDTH 2
#define SDRAM_SDRAM_COL_WIDTH 9
#define SDRAM_SDRAM_DATA_WIDTH 16
#define SDRAM_SDRAM_NUM_BANKS 4
#define SDRAM_SDRAM_NUM_CHIPSELECTS 1
#define SDRAM_SDRAM_ROW_WIDTH 13
#define SDRAM_SHARED_DATA 0
#define SDRAM_SIM_MODEL_BASE 0
#define SDRAM_SPAN 33554432
#define SDRAM_STARVATION_INDICATOR 0
#define SDRAM_TRISTATE_BRIDGE_SLAVE ""
#define SDRAM_TYPE "altera_avalon_new_sdram_controller"
#define SDRAM_T_AC 6.0
#define SDRAM_T_MRD 3
#define SDRAM_T_RCD 15.0
#define SDRAM_T_RFC 60.0
#define SDRAM_T_RP 15.0
#define SDRAM_T_WR 20.0


/*
 * sysid configuration
 *
 */

#define ALT_MODULE_CLASS_sysid altera_avalon_sysid_qsys
#define SYSID_BASE 0x2002470
#define SYSID_ID 0
#define SYSID_IRQ -1
#define SYSID_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SYSID_NAME "/dev/sysid"
#define SYSID_SPAN 8
#define SYSID_TIMESTAMP 1554196137
#define SYSID_TYPE "altera_avalon_sysid_qsys"


/*
 * uart configuration
 *
 */

#define ALT_MODULE_CLASS_uart altera_avalon_uart
#define UART_BASE 0x2002200
#define UART_BAUD 115200
#define UART_DATA_BITS 8
#define UART_FIXED_BAUD 1
#define UART_FREQ 100000000
#define UART_IRQ 4
#define UART_IRQ_INTERRUPT_CONTROLLER_ID 0
#define UART_NAME "/dev/uart"
#define UART_PARITY 'N'
#define UART_SIM_CHAR_STREAM ""
#define UART_SIM_TRUE_BAUD 0
#define UART_SPAN 32
#define UART_STOP_BITS 1
#define UART_SYNC_REG_DEPTH 2
#define UART_TYPE "altera_avalon_uart"
#define UART_USE_CTS_RTS 0
#define UART_USE_EOP_REGISTER 0

#endif /* __SYSTEM_H_ */
