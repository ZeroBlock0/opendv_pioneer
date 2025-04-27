Readme - Web Server Software Example

DESCRIPTION:	
A Web Server running from a file system in flash memory.

PERIPHERALS USED:
This example exercises the following peripherals:
- Ethernet MAC (External "lan91c111" or Altera Triple Speed Ethernet MAC)
- STDOUT device (UART or JTAG UART)
- LCD Display (named "lcd_display" in SOPC Builder)

SOFTWARE SOURCE FILES:
This example includes the following software source files:

- web_server.c: Contains the bulk of the code, including main(), the
  networking initialization routines, the web server task (WSTask), and all of
  board control utilities/tasks.  

- http.c: Implementation of an HTTP server including all necessary sockets
  calls to handle a multiple connections and parsing basic HTTP commands to 
  handle GET and POST requests. Requests for files via HTTP GET requests direct
  the server to fetch the file, if available, from the flash file system and 
  send it to the client requesting it.

- http.h: Header information defining HTTP server implementation and common
  HTTP server strings & constants.

- web_server.h: Definitions for the entire example application.

- network_utilities.c: Contains MAC address, IP address, and DHCP routines to
  manage addressing. These are used by NicheStack during initialization, but are
  implementation-specific (for any implementation of this example not an Altera 
  Nios development board, Stratix, Stratix Professional, or Cyclone edition, 
  this file will need to be modified to control addressing in your system).

- alt_error_handler.[ch]: Contains a simple error handler for MicroC/OS-II
  errors.

- srec_flash.c: Contain the SREC parsing and flash programming routines needed   
  for remote configuration.

BOARD/HOST REQUIREMENTS:
This example requires an Ethernet cable connected to the development board's 
RJ-45 jack, and a JTAG connection with the development board. If the host 
communication settings are changed from JTAG UART (default) to use a
conventional UART, a serial cable between board DB-9 connector  and the host is
required. 

If DHCP is available, the application will attempt to obtain an IP
address from a DHCP server. Otherwise, a static IP address (defined in
web_server.h) will be assigned after a timeout. 

KNOWN ISSUES/LIMITATIONS
The read-only zip filesystem must be set to a flash memory device whose base
address is 0x0 (note that you may place read-only zip file system contents 
at any offset within the flash memory device). 

ADDITIONAL INFORMATION:
Not all characters will display as typed on the LCD display.  This is because
HTML forms send unicode, for some characters, and standard ASCII for others.
This HTTP server will "translate" unicode (%20) spaces, but any other charac-
ters sent with leading spaces will pass through to the LCD.

This is an example HTTP server using NichStack on MicroC/OS-II. The server can
process basic requests to serve HTML, JPEG, and GIF files from the Altera 
read-only zip file system. It is in no way a complete implementation of a 
full-featured HTTP server.

This example uses the sockets interface. A good introduction to sockets 
programming is the book Unix Network Programming by Richard Stevens. 
Additionally, the text "Sockets in C", by Donahoo & Calvert, is a concise & 
inexpensive text for getting started with sockets programming.

To run the HTTP server, you must first program the file system using the 
Nios II Flash Programmer. The read-only zip file system contents come from a 
.zip file ("ro_zipfs.zip") located in the "system" subdirectory of the web
server application project. When the web-server application is built, the 
contents of this zip file are extracted and converted into a flash programming 
file. This file must be programmed into flash allowing the HTTP server to 
fetch content at runtime. 

To build & run the web-server application, perform the following steps in 
Nios II Software Build Tools for Eclipse:

   === I.  BUILD PROJECT ===
1. After creating a new "Web Server" software example application and 
   associated BSP, build it by choosing "Build All" from the "Project" menu.
  
2. Wait for the build process to complete. 

   === II. PROGRAM FLASH ===
1. Be sure that your development board is programmed with the .sof file
   corresponding to the Quartus (hardware) project that your web
   server application targets.
   
2. Select the web-server application project.
   
3. From the "Nios II" menu, select "Flash Programmer".

4. Select "File" menu --> "New" and specify the path to the settings.bsp file
   in the BSP directory your application linked against (the BSP is located
   adjacent to your application directory by default), and press OK.
   
5. Select the "Flash: ext_flash" tab to direct the flash programmer to target
   the CFI flash device on your development board.

6. Press "Add..." to add files to program to flash. Navigate to the web server 
   application directory and locate "ro_zipfs.zip" in the "system" 
   sub-directory. You may also select the application .elf and FPGA 
   configuration .sof files, but these are optional (they allow the software 
   and hardware design to boot from flash automatically). 
   
7. In "flash files for flash conversion", edit the flash offset for 
   ro_zipfs.zip and set it to 0x100000 (this offset should match the
   ro_zipfs_offset BSP setting that specifies where the read-only 
   zip filesystem software should be located in flash memory).

8. Press "Start" to program flash.

   Flash on your development board will now be programmed with the read-only 
   zip file system contents. When your board is programmed with an appropriate 
   .sof file, and the web server application is downloaded to the board, 
   it will serve pages from flash in the read-only zip file system.


=== Remote Configuration ===
Basic remote configuration features are included with this webserver.  The
methodology chosen uses multipart forms (HTML standard) to upload the hardware
or software images and then a series of additional web pages to control the
flow.

The basic steps are:

1.  Fill out the multipart-form.
    - Choose the flash for your image when doing this.
    NOTE:  Only the Develop Kit flash names are currently supported.
           - ext_flash(CFI)
           - epcs_controller(EPCS)
           If you have differing flash names, you'll need to change the web
           content to reflect these names.
    - Select the image you'd like to upload
           - This is usually a .flash file produced (and tested) using
             the flash programmer.
2.  Upload your selected image.
    - This could take a while, depending on the size of your image.
    - On completion, a new page will load giving you a new form for programming
      the flash.
3.  Program the Flash
    - Click the button in the form located on the Remote Configuration section
      of this page and the flash will start programming.
    - Again, this could take a while...
    - Upon completion, you'll see a "reset system" option in the Remote
      Configuration section.
4.  Reset the System
    - If this is the only image you need to update, then reset your system to 
      see if it functions.
    - If you need to update more images (hardware or software) click the main
      hyperlink (takes you back to the main/index page) and repeat steps
      1-3 as necessary.
