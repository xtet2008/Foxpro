Clear
Clear dlls
Set DEFAULT TO (SUBSTR(SYS(16,1),AT(":",SYS(16,1)) - 1, RAT("\", SYS(16,1)) - (AT(":",SYS(16,1)) - 1)))

Declare String num2txt_c IN "MyDll.dll" double orgStr

?num2txt_c(12345.09)

clear dlls
return
*-- Graphics
********************************************************************************
*-- capture window or screen image into a bitmap file
Declare Integer formtobmp       IN "mydll.dll" integer hwnd,String bmpFileName
* Parameters:
*   hwnd 
*     Handle to the window to be saves to a bitmap file. if this parameter is zero, then saves desktop to a bitmap file.
*
*   bmpFileName
*     The bitmap filename to be save. must include full path name.
*
* Note   
* if success, return value 0, else return 1.
*
* Sample:
*
retVal = formtobmp(0,"c:\screen.bmp")  && Save screen to file c:\screen.bmp
if retval = 0
   messagebox("Capture screen ok!")
endif
********************************************************************************


********************************************************************************
*-- Convert a bmp file to jpg file
Declare Integer tojpeg          IN "mydll.dll" String bmpfilename, String jpgfilename
retval = tojpeg("c:\screen.bmp","c:\screen.jpg")
* Parameters:
*   bmpfilename
*     origin bitmap filename.
*
*   jpgfilename
*     destination jpeg filename.
*
* Note   
* if success, return value 0, else return 1.
*
* Sample:
*
if retval = 0
   messagebox("Convert bitmap to jpeg ok!")
endif
********************************************************************************



********************************************************************************
*-- Convert a jpg file to bmp file
Declare Integer tobmp           IN "mydll.dll" String jpgfilename, String bmpfilename
retval = tobmp("c:\screen.jpg","c:\screen2.bmp")
* Parameters:
*   jpgfilename
*     origin jpeg filename.
*
*   bmpfilename
*     destination bitmap filename.
*
* Note   
* if success, return value 0, else return 1.
*
* Sample:
*
if retval = 0
   messagebox("Convert jpeg to bitmap success!")
endif
********************************************************************************



********************************************************************************
*-- Retrieves the width and height of a bmpfile
Declare Integer getbmpdimension IN "mydll.dll" string bmpfilename, integer @ nwidth,integer @ nheight
* Parameters:
*   bmpfilename
*     origin bitmap filename.
*
*   nwidth
*     bitmap's width measured in pixels.
*
*   nheight
*     bitmap's height measured in pixels.
*
* Note   
* if success, return value 0, else return 1.
* if success, variable nwidth hold the bitmap's width ,variable nheight hold the bitmap's height.
*
* Sample:
*
nwidth=0
nheight=0
retval = getbmpdimension("c:\screen.bmp",@ nwidth, @ nheight)
if retval = 0
   messagebox("Width:"+str(nwidth)+chr(13)+"Height:"+str(nheight))
endif
********************************************************************************



********************************************************************************
*-- Retrieves the width and height of a jpg file
Declare Integer getjpgdimension IN "mydll.dll" string jpgfilename, integer @ nwidth,integer @ nheight
* Parameters:
*   jpgfilename
*     origin jpeg filename.
*
*   nwidth
*     jpeg's width measured in pixels.
*
*   nheight
*     jpeg's height measured in pixels.
*
* Note   
* if success, return value 0, else return 1.
* if success, variable nwidth hold the jpeg's width ,variable nheight hold the jpeg's height.
*
* Sample:
*
nwidth=0
nheight=0
retval = getjpgdimension("c:\screen.jpg",@ nwidth, @ nheight)
if retval = 0
   messagebox("Width:"+str(nwidth)+chr(13)+"Height:"+str(nheight))
endif
********************************************************************************



********************************************************************************
clear dlls
return

*-- internet
Declare string pinghost       IN "MyDll.dll" String cHostName
*-- if success, return host's ip adress,else return a empty string.
Declare integer myftpputfile  IN "MyDll.dll" string host, string remotefile,string localfile, string username,string pa
Declare integer myftpgetfile  IN "MyDll.dll" string host, string localfile,string remotefile, string username,string pa
Declare integer httpdownload  IN "MyDll.dll" string host, string remotefile,string localfile
Declare integer DialUp        IN "MyDll.dll" String UserName,String Pas,String PhoneNumberToDial
Declare integer DisconnectRas IN "MyDll.dll"
Declare integer smail         IN "MyDll.dll" String smtpsrvname,String username,String pas,String sender,String frommail,;
	String tomail,String sub,String mes,String atta1,String atta2,String atta3,String atta4
Declare integer sendmail      IN "MyDll.dll" String recipient,String subject,String sub,String Attachment
Declare string ListMail       in "mydll.dll" string user,string pass,string svr,integer po,integer DeleteMail

* intranet
Declare String  getname       IN "MyDll.dll"
Declare String  getip         IN "MyDll.dll"
Declare integer sharedel         in "MYDLL.DLL" String Sharename
Declare integer shareadd         in "MYDLL.DLL" String Localdir, String Sharename,String comment, integer bReadOnly,String password
Declare integer cancelconnect    IN "MyDll.dll" String
Declare integer connecttonetwork IN "MyDll.dll" String remotname,String Localname,String username,String pas
Declare integer shareadd         IN "MyDll.dll" String DirToShare,String ShareName,String CommentStr,Integer iReadOnly,String PasswordStr
Declare integer sharedel         IN "MyDll.dll" String sharename

* Compress/Decompress.压缩/解压. 以下两个文件压缩/解压函数如果成功返回 0, 否则返回一个非零的值:
Declare integer compress   in "MYDLL.DLL" String cabfilename,string filetocomp,Integer cabsize
Declare integer decompress in "MYDLL.DLL" String uncompdir,string cabfilename

* 加密解密
Declare String encstr           IN "MyDll.dll" String origStr,String cKey
Declare string getcrc           IN "MyDll.dll" String filename
Declare STRING MD5File          IN "mydll.dll" AS MD5FILE STRING filename
Declare STRING MD5String        IN "mydll.dll" AS MD5STRING STRING inputstr, INTEGER strlen
Declare integer InitUser        in "MYDLL.DLL"   && 在一台计算机上最多只需要运行此函数一次,用于为机器创建缺省的密钥容器。
Declare integer CAPIDecryptFile in "MYDLL.DLL" String szSource, String szDestination, String szPassword
Declare integer CAPIEncryptFile in "MYDLL.DLL" String szSource, String szDestination, String szPassword

* 硬件相关
Declare String  getserial     IN "MyDll.dll" Integer DiskNo
Declare String  getmac        IN "MyDll.dll" Integer NetCardNo
Declare String  VolumeNumber  IN "MyDll.dll" String  Driver
Declare integer changeres     IN "MyDll.dll" Integer nWidth, Integer nHeigth         && 两个参数分别为 屏幕的宽/高
Declare integer IsDiskInDrive IN "MyDll.dll" String  Driver
Declare integer getmetric     IN "MyDll.dll" integer @ nWidth,integer @ nHeight,integer @ nFreq

* 转换
Declare String topy      IN "MyDll.dll" String orgStr
Declare String hzbh      IN "MyDll.dll" String orgStr,Integer nFlag
Declare String num2txt_e IN "MyDll.dll" double orgStr 
Declare String num2txt_c IN "MyDll.dll" double orgStr

*-- 系统相关
Declare string getcpuid             in "mydll.dll"
Declare integer exitw               in "mydll.dll" integer flag
Declare long dirsize                IN "mydll.dll" String DirName,Integer Flag
Declare integer vfpbeep             IN "MyDll.dll"
Declare Integer SetTime             in "mydll.dll" String Filename,integer nyear,integer nmonth,integer nday
Declare Integer IsWin2000           IN "MyDll.dll"
Declare Integer DPGetDefaultPrinter IN "MyDll.dll" String @ PrinterName, Integer @ BufferSize
Declare Integer DPSetDefaultPrinter IN "MyDll.dll" String @ PrinterName
Declare integer PrintStringDirect   IN "MyDll.dll" String lcString,String prtname,String DeviceName && 直接发送一个串到打印机

*-- 杂项
Declare integer MyInputBox   in "MYDLL.DLL" Integer Whd,String Title,String @,Integer passlen
Declare String LoadIME       IN "mydll.dll" String ImeName
Declare String getallproc    IN "mydll.dll"
Declare integer TerminateApp IN "mydll.dll" double dwPID,double dwTimeout
Declare integer killtask     in "mydll.dll" String cNotKillWinCaption

*-- 调用一个外部程序并等待结束
Declare INTEGER ShellExecWait IN "MYDLL.DLL" STRING lpProgName,STRING lpParms,SHORT n_ShowWinMode,INTEGER @ExitCode

?getallproc()  && get and display all Proccess

nwidth=0
nheight=0
getbmpdimension("c:\screen.bmp",@nwidth,@nheight) && Get a bmp file's dimensions, after called ,nwidth hold the width and nheight hold the height.

getjpgdimension("c:\screen.jpg",@nwidth,@nheight) && Get a jpg file's dimensions, after called ,nwidth hold the width and nheight hold the height.

?LoadIME("EN") && Enum and Load a Ime
ListMail("njjane","XXXXXXXXXXXXX","pop.21cn.com",110,0) && get pop3 mail server mail list
getcpuid() && get cupid

**nflag=0   && 注销
**nflag=1  && 关闭
**nflag=2  && 重启
** nflag=8  && 关电
**exitw(nflag)  && Loggoff or Close system

?dirsize("C:\books\*.cdx",1)+;
	dirsize("C:\books\*.dbf",1)+;
	dirsize("C:\books\*.fpt",1)+;
	dirsize("C:\books\*.dbc",1)+;
	dirsize("C:\books\*.dcx",1)+;
	dirsize("C:\books\*.dct",1)  && get all files size in a directory

**?dirsize("C:\MultiUser",1)


*-- beep with PC speaker
vfpbeep()

* send mail via smtp mail server
smail("your smtp server name","your mail username","your password","sender","your email address","destinate mail address","mail contents","subject!","c:\title.jpg","c:\dtest.rar","c:\hz.txt","c:\test1.txt")


*-- a dialog to input password
Pas=SPACE(50)
MyInputBox(0,"input your password",@PAS,50)
Pas=ALLTRIM(PAS)
??left(alltrim(Pas),len(alltrim(Pas))-1)


* 以下是调用示例：
**gnDOSpgmShowWinMode = 0   && SW_HIDE
**gnExitCode = 0
**rc = ShellExecWait("..\ARJ.EXE"+CHR(0),;
"A ..\ARJ\"+c_SEL_DATE+".ARJ"+;
" ..\OUTPUT\"+c_SEL_DATE+"*.*"+CHR(0),;
gnDOSpgmShowWinMode, ;
@gnExitCode)
*出错处理
**IF rc != 0
**    =MSG_ERR("调用 ARJ 压缩出错! 出错码:"+ALLTRIM(STR(rc)))
**    RETURN
**ENDIF
**IF gnExitCode != 0
**    =MSG_ERR("ARJ 压缩出错! ARJ 退出码:"+ALLTRIM(STR(gnExitCode)))
**    RETURN
**ENDIF


*-- 设置一个文件或目录的创建日期
ret = SetTime("c:\mydll\test\test2.cpp",2005,12,31)
If ret=0
	Messagebox("设置成功!")
Else
	Messagebox("设置失败!")
Endif


InitUser()  && 初始化密钥
CAPIEncryptFile("C:\块替换.txt","C:\块替换.tx_","abc") && 加密一个文件
CAPIDecryptFile("C:\块替换.tx_","c:\块替换2.txt","abc") && 解密文件

?compress("c:\Acme", "C:\Acme\*.*",0) && 最后一个参数值为 0 则意味着压缩所有的文件到一个单一的 cab 文件中.否则，该值为多卷压缩中的每一个卷的大小(以 K 为单位)
?decompress("C:\001\","C:\Acme1.CAB")

*-- 直接发送一个串到当前打印机,打印后不会回车，也不会进纸
?PrintStringDirect("要打印的串", "Star AR-3200+","LPT1:")

*-- 握号与断开
?DialUp("163","163","163")
?DisconnectRas()

?getip()
?getname()

? MD5STRING("message digest",len("message digest"))
?"================"
? MD5FILE("F:\mydll\mydll.dll")

* 获取网卡 MAC
?"网卡 MAC:" + getmac(1)
?"网卡 MAC:" + getmac(2)
?"网卡 MAC:" + getmac(3)

* 汉字转拼音
?"拼音转换:开放 客户 款项 空间"+topy("开放 客户 款项 空间")

* 数值转金额
?num2txt_c(1234567.89)
?num2txt_c(-1234567.89)

*-- 添加和删除共享
If shareadd("C:\","MYSHARE","我的共享盘",1,"")=1
	Messagebox("共享成功")
Else
	Messagebox("共享失败")
Endif

If sharedel("MYSHARE")=1
	Messagebox("删除共享成功")
Else
	Messagebox("删除共享失败")
Endif

* 映射/断开映射网络驱动器
ret=connecttonetwork("\\legend4-1\档案备份文件","P:","legend4-1","legend41")
If ret=0   && 映射网络资源为一个本地驱动器, 封装了 WNetUseConnection API
	Messagebox("已经将 \\legend4-1\档案备份文件 映射为本地盘 P:")
Else
	Messagebox("映射 \\legend4-1\档案备份文件 为本地盘 P: 操作失败,错误码:"+str(ret))
Endif

If cancelconnect("P:")=1            && 断开一个已经映射的网络资源  , 封装了 WNetCancelConnection2 API
	Messagebox("已经将映射 P: 断开")
Else
	Messagebox("断开 P: 映射的操作失败")
Endif

*-- 通过 MAPI 发送带附近件的邮件
If sendmail("icoico@21cn.com","test","this is a sendmail test","c:\winzip.log")=0
	Messagebox("sendmail 发送成功")
Else
	Messagebox("sendmail 发送失败")
Endif

lcWidth=0
lcHeigth=0
lcFreq=0
getmetric(@lcWidth,@lcHeigth,@lcFreq)
?lcWidth,lcHeigth,lcFreq
?getip()
myftpgetfile("61.133.63.168", "skin.txt","C:\skin.txt", "fox","fox")
myftpputfile("61.133.63.168", "C:\dtest.rar","dtest.rar", "fox","fox")
httpdownload("http://www.myf1.net/","http://www.myf1.net/temp/mydlltest.rar","C:\dtest.rar")
atfile=sys(5)+curdir()+"readme.txt"
sendmail("njjane@21cn.com","该信息用于测试","你好！"+chr(13)+"    如有打扰，多加原谅",sys(5)+curdir()+"readme.txt")
sendmail("njjane@21cn.com","该信息用于测试","你好！"+chr(13)+"    如有打扰，多加原谅","")
?num2txt_c(0.12)
?num2txt_c(1.23)
?num2txt_c(123.09)
?num2txt_c(1234567.89)


If IsDiskInDrive("A:\") = 0
	? "No disk in driver"
Else
	? "disk is in driver"
Endif

?"==========测试开始=============="
?"串加密测试:"
a="1 2 3 1 23abc中国人民解放军是人民的军队123123abc   "
?"          原串:"+a,len(a)

b=alltrim(getserial(0))  && 加密用的密钥,这里使用的是第一个硬盘的出厂序列号
c=encstr(a,b)
?"    加密后的串:"+c,len(c)

d=encstr(c,b)  && 解密的密钥必须与加密时的密钥相同
?"解密加密后的串:"+d,len(d)
?
?"检测硬盘序列号:"
?"硬盘序列号1:"+alltrim(getserial(0))
?"硬盘序列号2:"+alltrim(getserial(1))
?
op=IsWin2000()
If op=1
	?"你的操作系统 Windows 2000 或 NT"
Else
	?"你的操作系统 Windows 9x"
Endif
?
PrinterName=space(250) &&replicate(chr(0),250)
NameSpace=250
DPGetDefaultPrinter(@PrinterName,@NameSpace)
?"默认打印机:"+left(PrinterName,NameSpace-1)
?
*-- 修改以下行以适应你的系统
NewPrint="Star AR-3200+"
DPSetDefaultPrinter(@NewPrint)
?"新设置的默认打印机:"+NewPrint
?
?"本机机器名:"+getname()
?"本机 IP:"+getip()
?
?"拼音转换:朱镕彭珮云牛犇 = "+topy("朱镕彭珮云牛犇")

?"C:盘卷:" + VolumeNumber("C:\")
?
?"文件"+sys(5)+curdir()+"MyDll.dll 的 CRC 值为:" + getcrc(sys(5)+curdir()+"mydll.dll")
?getcrc("")   && 检测无效的文件名
?"网卡 MAC:" + getmac(1)
?

*?"改变屏幕分辩率为:1024*768  "
*changeres(1024,768)

?"Ping   www.myf1.net   的结果："+pinghost("www.myf1.net")
?"Ping   一个不存在的网址的结果："+pinghost("www.naughter.com")

?num2txt_c(123.09)
?num2txt_c(1234567.89)

* FTP 下载
myftpgetfile("61.133.63.168", "VFP7亮丽_输入法排序.zip","C:\VFP7亮丽_输入法排序.zip", "fox","fox")


*?"改变屏幕分辩率为:800*600  "
changeres(800,600)

?"==========测试结束=============="
Clear dlls
Return
