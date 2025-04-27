#!/bin/sh
#
# This file was automatically generated.
#
# It can be overwritten by nios2-flash-programmer-generate or nios2-flash-programmer-gui.
#

#
# Converting SOF File: D:\project\qsys_gui_oscp\par\output_files\qsys_gui_oscp.sof to: "..\flash/qsys_gui_oscp_epcs_flash.flash"
#
sof2flash --input="D:/project/qsys_gui_oscp/par/output_files/qsys_gui_oscp.sof" --output="../flash/qsys_gui_oscp_epcs_flash.flash" --epcs --verbose 

#
# Programming File: "..\flash/qsys_gui_oscp_epcs_flash.flash" To Device: epcs_flash
#
nios2-flash-programmer "../flash/qsys_gui_oscp_epcs_flash.flash" --base=0x4002000 --epcs --sidp=0x4003040 --id=0x0 --timestamp=1552895859 --device=1 --instance=0 '--cable=USB-Blaster on localhost [USB-0]' --program --verbose 

#
# Converting ELF File: D:\project\qsys_gui_oscp\qsys\software\qsys_gui\qsys_gui.elf to: "..\flash/qsys_gui_epcs_flash.flash"
#
elf2flash --input="D:/project/qsys_gui_oscp/qsys/software/qsys_gui/qsys_gui.elf" --output="../flash/qsys_gui_epcs_flash.flash" --epcs --after="../flash/qsys_gui_oscp_epcs_flash.flash" --verbose 

#
# Programming File: "..\flash/qsys_gui_epcs_flash.flash" To Device: epcs_flash
#
nios2-flash-programmer "../flash/qsys_gui_epcs_flash.flash" --base=0x4002000 --epcs --sidp=0x4003040 --id=0x0 --timestamp=1552895859 --device=1 --instance=0 '--cable=USB-Blaster on localhost [USB-0]' --program --verbose 

