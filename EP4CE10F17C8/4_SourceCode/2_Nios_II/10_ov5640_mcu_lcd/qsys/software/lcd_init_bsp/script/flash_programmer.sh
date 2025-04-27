#!/bin/sh
#
# This file was automatically generated.
#
# It can be overwritten by nios2-flash-programmer-generate or nios2-flash-programmer-gui.
#

#
# Converting SOF File: F:\project\ov5640_mcu_lcd\par\output_files\ov5640_mcu_lcd.sof to: "..\flash/ov5640_mcu_lcd_epcs_flash.flash"
#
sof2flash --input="F:/project/ov5640_mcu_lcd/par/output_files/ov5640_mcu_lcd.sof" --output="../flash/ov5640_mcu_lcd_epcs_flash.flash" --epcs --verbose 

#
# Programming File: "..\flash/ov5640_mcu_lcd_epcs_flash.flash" To Device: epcs_flash
#
nios2-flash-programmer "../flash/ov5640_mcu_lcd_epcs_flash.flash" --base=0x4001000 --epcs --accept-bad-sysid --device=1 --instance=0 '--cable=USB-Blaster on localhost [USB-0]' --program --verbose 

#
# Converting ELF File: F:\project\ov5640_mcu_lcd\qsys\software\lcd_init\lcd_init.elf to: "..\flash/lcd_init_epcs_flash.flash"
#
elf2flash --input="F:/project/ov5640_mcu_lcd/qsys/software/lcd_init/lcd_init.elf" --output="../flash/lcd_init_epcs_flash.flash" --epcs --after="../flash/ov5640_mcu_lcd_epcs_flash.flash" --verbose 

#
# Programming File: "..\flash/lcd_init_epcs_flash.flash" To Device: epcs_flash
#
nios2-flash-programmer "../flash/lcd_init_epcs_flash.flash" --base=0x4001000 --epcs --accept-bad-sysid --device=1 --instance=0 '--cable=USB-Blaster on localhost [USB-0]' --program --verbose 

