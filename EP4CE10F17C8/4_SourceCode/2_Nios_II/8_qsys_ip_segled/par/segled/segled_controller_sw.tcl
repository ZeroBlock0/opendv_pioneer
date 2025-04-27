#
# segled_controller_driver.tcl
#

# Create a new driver
create_driver segled_controller_driver

# Associate it with some hardware known as "segled_controller"
set_sw_property hw_class_name segled_controller

# The version of this driver
set_sw_property version 13.1

# This driver may be incompatible with versions of hardware less
# than specified below. Updates to hardware and device drivers
# rendering the driver incompatible with older versions of
# hardware are noted with this property assignment.
#
# Multiple-Version compatibility was introduced in version 7.1;
# prior versions are therefore excluded.
set_sw_property min_compatible_hw_version 13.1

# Initialize the driver in alt_sys_init()
set_sw_property auto_initialize true

# Location in generated BSP that above sources will be copied into
set_sw_property bsp_subdirectory drivers


#
# Source file listings...
#

# Include files
add_sw_property include_source inc/segled_controller_regs.h

# This driver supports HAL & UCOSII BSP (OS) types
add_sw_property supported_bsp_type HAL
add_sw_property supported_bsp_type UCOSII
add_sw_property supported_bsp_type BML

# End of file
