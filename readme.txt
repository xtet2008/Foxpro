本文档为 MYDLL.DLL 说明文档
***********************************************************
本程序以 AS IS 方式分发，使用该程序是你自已愿冒的风险。
因使用该程序而造成的损失本人概不负责。
你可以免费使用，分发，传递使用该程序，在分发和传递时请包含未经修改的本文档。
***********************************************************
MYDLL.DLL 中包含以下函数

1  encstr               串加密/解密
2  getserial            获取硬盘出厂序列号  
3  IsWin2000            当前机器的操作系统
4  DPGetDefaultPrinter  获取当前默认打印机
5  DPSetDefaultPrinter  设置当前默认打印机
6  getname              获取当前用户名
7  getip                获取本机 IP
8  topy                 汉字转拼音头 
9  getmac               获取机器 MAC
10 VolumeNumber         获取磁盘格式化时的卷标
11 changeres            改变显示分辩率
12 getcrc               取得一个文件的 CRC 校验值 
13 IsConnected          判断本机是否连接到 Internet
14 IsDiskInDrive        判断软盘驱动器中是否插有软盘
15 num2txt_e            转换一个数值型为大写的金额串(英文)
16 num2txt_c            转换一个数值型为大写的金额串(中文)
17 pinghost             Ping 一个主机地址
18 connecttonetwork     映射网络资源为一个本地驱动器, 封装了 WNetUseConnection API
19 cancelconnect        断开一个已经映射的网络资源  , 封装了 WNetCancelConnection2 API
20 myftpputfile         从传一个文件到指定的 ftp 
21 myftpgetfile         从指定的 ftp 下载一个文件
22 httpdownload         从指定的 http 下载一个文件
23 getmetric            获取系统显示器当前的分辩率
24 sendmail             发送一个 email (可带一个附件)
25 smail                通过 smtp 邮件服务器发送一个 email (不需要本地的 OUTLOOK 等邮件程序,最多可带四个附件)
26 PrintStringDirect    直接发送一个串到指定打印机，打印完后不会走纸
27 DialUp               拨号上网
28 DisconnectRas        断开拨号
29 MD5File              用 md5 算法求一个文件的 16 位检查和       ( 感谢网友 goodfrd 提供源代码 )
30 MD5String            用 md5 算法求一个串的 16 位检查和         ( 感谢网友 goodfrd 提供源代码 )
31 compress             压缩一个目录中的所有文件到一个卷或多个卷中(不包括子目录中的内容)
32 decompress           解压一个经 compress 函数压缩的文件中的所有内容到一个指定目录中
33 MyInputBox           一个简单的口令输入框
34 InitUser             用于创建缺省的密钥容器，在一台机器上只需运行一次，以为下面两个函数作准备的函数
35 CAPIEncryptFile      加密一个文件
36 CAPIDecryptFile      解密一个文件
37 sharedel             设置一个本地驱动器或目录为共享
38 shareadd             删除共享
39 ShellExecWait        执行一个 DOS 命令                          ( 感谢网友 goodfrd 提供源代码 )
40 SetTime              设置一个目录或文件的日期  
41 vfpbeep              让系统发出 "嘟" 声
42 hzbh                 获取汉字笔划 
43 exitw                注销/关闭/重启系统
44 dirsize              获取一个目录的大小
45 getcpuid             获取当前机器的 CPUID
46 tojpeg               转换一个 BMP 文件到 JPG 文件
47 tobmp                转换一个 JPG 文件到 BMP 文件
48 formtobmp            将表单或屏幕内容保存为一个位图
49 getbmpdemension      获取一个 BMP 文件的大小
50 getjpgdimension      获取一个 JPG 文件的大小
51 LoadIME              设置特定的输入法
52 getallproc           获取当前系统中的所有进程
53 TerminateApp         终止一个 32 位进程
54 ListMail             列出 POP 3 邮件服务器上的邮件 


调用以上函数的具体参数及使用方法请参见随附的示例程序 mydlltest.prg。
任何建议，BUG 报告请到 http://www.myf1.net/bbs/list.asp?boardid=1 提出。
四川，内江，电建三公司，物资管理部 任明汉
njjane@21cn.com

vfp精英站
www.foxer.net