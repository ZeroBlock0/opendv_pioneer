说明
本工具实现将Quartus ii编译产生的sof文件和NIOS II EDS编译产生的elf文件合并为jic文件，以方便烧写。
根据测试，本工具使用需要具备以下条件：
1、quartus ii软件版本在13.1及以上
2、默认quartus ii编译生成的sof文件输出目录为根目录下的par/output_files文件夹下。如果不是，需要用户自行修改脚本和cof文件
3、nios ii的软件工程路径为quartus 工程根目录下的qsys/software文件夹下

注意
本工具针对EP4CE10、EPCS16编写，如果为其他器件，需要用户修改（记事本即可打开）generate_jic.cof文件中相应位置。

//*********************************************************************************
//生成jic文件
//*********************************************************************************
使用方法
1、将generate_jic.tcl、generate_jic.sh、generate_jic.cof文件拷贝到nios ii软件工程下。
2、在eclipse中选中应用工程，右键->NIOS II->NIOS command shell。
3、NIOS command shell中输入"./generate_jic.sh"。
（运行完成后，会在Quartus II工程根目录下生成一个jicconv的文件夹，同时将generate_jic.tcl、generate_jic.cof文件拷贝到工程par目录下。）

4、在quartus ii中点击Tools -> Tcl Scripts，选中generate_jic.tcl，点击run，
（运行成功，会在par目录下生成名叫hs_combined.jic的文件）

5、烧写hs_combined.jic到FPGA中，对板卡断电重新上电，新固件就可以开始运行了。
