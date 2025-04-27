#!/bin/sh
#
# This file was automatically generated.
#
# It can be overwritten by nios2-flash-programmer-generate or nios2-flash-programmer-gui.
#

#
# Converting Binary File: F:\Qsys\qsys_webserver\qsys\software\qsys_webserver\system\ro_zipfs.zip to: "..\flash/ro.flashfs_epcs_flash_controller.flash"
#
bin2flash --input="F:/Qsys/qsys_webserver/qsys/software/qsys_webserver/system/ro_zipfs.zip" --output="../flash/ro.flashfs_epcs_flash_controller.flash" --location=0x100 --verbose 

#
# Programming File: "..\flash/ro.flashfs_epcs_flash_controller.flash" To Device: epcs_flash_controller
#
nios2-flash-programmer "../flash/ro.flashfs_epcs_flash_controller.flash" --base=0x0 --epcs --sidp=0x1ED0 --id=0x2 --accept-bad-sysid --device=1 --instance=0 '--cable=USB-Blaster on localhost [USB-0]' --program --verbose 

