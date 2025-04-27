#!/bin/sh
rm -rf flashconv
mkdir flashconv
cp ../../../par/output_files/*.sof ./flashconv/hwimage.sof
cp *.elf ./flashconv/swimage.elf
cd flashconv
chmod 777 swimage.elf
chmod 777 hwimage.sof
sof2flash --input=hwimage.sof  --output=hwimage.flash --epcs --verbose
elf2flash --input=swimage.elf --output=swimage.flash --epcs --after=hwimage.flash  --verbose
nios2-elf-objcopy --input-target srec --output-target ihex swimage.flash  swimage.hex
rm -rf ../../../../jicconv
mkdir ../../../../jicconv
cp swimage.hex ../../../../jicconv/swimage.hex
cp hwimage.sof ../../../../jicconv/hwimage.sof
cp ../generate_jic.cof ../../../../par/generate_jic.cof
cp ../generate_jic.tcl ../../../../par/generate_jic.tcl
cd ../
