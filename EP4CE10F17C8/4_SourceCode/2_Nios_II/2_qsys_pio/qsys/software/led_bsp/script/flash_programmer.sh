#!/bin/sh
#
# This file was automatically generated.
#
# It can be overwritten by nios2-flash-programmer-generate or nios2-flash-programmer-gui.
#

#
# Converting SOF File: D:\work\Pio_led\par\output_files\Pio_led.sof to: "..\flash/Pio_led_epcs_flash.flash"
#
sof2flash --input="D:/work/Pio_led/par/output_files/Pio_led.sof" --output="../flash/Pio_led_epcs_flash.flash" --epcs --verbose 

#
# Programming File: "..\flash/Pio_led_epcs_flash.flash" To Device: epcs_flash
#
nios2-flash-programmer "../flash/Pio_led_epcs_flash.flash" --base=0x11000 --epcs --sidp=0x11820 --id=0x0 --timestamp=1531920027 --device=1 --instance=0 '--cable=USB-Blaster on localhost [USB-0]' --program --verbose 

#
# Converting ELF File: D:\work\Pio_led\qsys\software\led\led.elf to: "..\flash/led_epcs_flash.flash"
#
elf2flash --input="D:/work/Pio_led/qsys/software/led/led.elf" --output="../flash/led_epcs_flash.flash" --epcs --after="../flash/Pio_led_epcs_flash.flash" --verbose 

#
# Programming File: "..\flash/led_epcs_flash.flash" To Device: epcs_flash
#
nios2-flash-programmer "../flash/led_epcs_flash.flash" --base=0x11000 --epcs --sidp=0x11820 --id=0x0 --timestamp=1531920027 --device=1 --instance=0 '--cable=USB-Blaster on localhost [USB-0]' --program --verbose 

