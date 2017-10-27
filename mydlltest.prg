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

* Compress/Decompress.ѹ��/��ѹ. ���������ļ�ѹ��/��ѹ��������ɹ����� 0, ���򷵻�һ�������ֵ:
Declare integer compress   in "MYDLL.DLL" String cabfilename,string filetocomp,Integer cabsize
Declare integer decompress in "MYDLL.DLL" String uncompdir,string cabfilename

* ���ܽ���
Declare String encstr           IN "MyDll.dll" String origStr,String cKey
Declare string getcrc           IN "MyDll.dll" String filename
Declare STRING MD5File          IN "mydll.dll" AS MD5FILE STRING filename
Declare STRING MD5String        IN "mydll.dll" AS MD5STRING STRING inputstr, INTEGER strlen
Declare integer InitUser        in "MYDLL.DLL"   && ��һ̨����������ֻ��Ҫ���д˺���һ��,����Ϊ��������ȱʡ����Կ������
Declare integer CAPIDecryptFile in "MYDLL.DLL" String szSource, String szDestination, String szPassword
Declare integer CAPIEncryptFile in "MYDLL.DLL" String szSource, String szDestination, String szPassword

* Ӳ�����
Declare String  getserial     IN "MyDll.dll" Integer DiskNo
Declare String  getmac        IN "MyDll.dll" Integer NetCardNo
Declare String  VolumeNumber  IN "MyDll.dll" String  Driver
Declare integer changeres     IN "MyDll.dll" Integer nWidth, Integer nHeigth         && ���������ֱ�Ϊ ��Ļ�Ŀ�/��
Declare integer IsDiskInDrive IN "MyDll.dll" String  Driver
Declare integer getmetric     IN "MyDll.dll" integer @ nWidth,integer @ nHeight,integer @ nFreq

* ת��
Declare String topy      IN "MyDll.dll" String orgStr
Declare String hzbh      IN "MyDll.dll" String orgStr,Integer nFlag
Declare String num2txt_e IN "MyDll.dll" double orgStr 
Declare String num2txt_c IN "MyDll.dll" double orgStr

*-- ϵͳ���
Declare string getcpuid             in "mydll.dll"
Declare integer exitw               in "mydll.dll" integer flag
Declare long dirsize                IN "mydll.dll" String DirName,Integer Flag
Declare integer vfpbeep             IN "MyDll.dll"
Declare Integer SetTime             in "mydll.dll" String Filename,integer nyear,integer nmonth,integer nday
Declare Integer IsWin2000           IN "MyDll.dll"
Declare Integer DPGetDefaultPrinter IN "MyDll.dll" String @ PrinterName, Integer @ BufferSize
Declare Integer DPSetDefaultPrinter IN "MyDll.dll" String @ PrinterName
Declare integer PrintStringDirect   IN "MyDll.dll" String lcString,String prtname,String DeviceName && ֱ�ӷ���һ��������ӡ��

*-- ����
Declare integer MyInputBox   in "MYDLL.DLL" Integer Whd,String Title,String @,Integer passlen
Declare String LoadIME       IN "mydll.dll" String ImeName
Declare String getallproc    IN "mydll.dll"
Declare integer TerminateApp IN "mydll.dll" double dwPID,double dwTimeout
Declare integer killtask     in "mydll.dll" String cNotKillWinCaption

*-- ����һ���ⲿ���򲢵ȴ�����
Declare INTEGER ShellExecWait IN "MYDLL.DLL" STRING lpProgName,STRING lpParms,SHORT n_ShowWinMode,INTEGER @ExitCode

?getallproc()  && get and display all Proccess

nwidth=0
nheight=0
getbmpdimension("c:\screen.bmp",@nwidth,@nheight) && Get a bmp file's dimensions, after called ,nwidth hold the width and nheight hold the height.

getjpgdimension("c:\screen.jpg",@nwidth,@nheight) && Get a jpg file's dimensions, after called ,nwidth hold the width and nheight hold the height.

?LoadIME("EN") && Enum and Load a Ime
ListMail("njjane","XXXXXXXXXXXXX","pop.21cn.com",110,0) && get pop3 mail server mail list
getcpuid() && get cupid

**nflag=0   && ע��
**nflag=1  && �ر�
**nflag=2  && ����
** nflag=8  && �ص�
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


* �����ǵ���ʾ����
**gnDOSpgmShowWinMode = 0   && SW_HIDE
**gnExitCode = 0
**rc = ShellExecWait("..\ARJ.EXE"+CHR(0),;
"A ..\ARJ\"+c_SEL_DATE+".ARJ"+;
" ..\OUTPUT\"+c_SEL_DATE+"*.*"+CHR(0),;
gnDOSpgmShowWinMode, ;
@gnExitCode)
*������
**IF rc != 0
**    =MSG_ERR("���� ARJ ѹ������! ������:"+ALLTRIM(STR(rc)))
**    RETURN
**ENDIF
**IF gnExitCode != 0
**    =MSG_ERR("ARJ ѹ������! ARJ �˳���:"+ALLTRIM(STR(gnExitCode)))
**    RETURN
**ENDIF


*-- ����һ���ļ���Ŀ¼�Ĵ�������
ret = SetTime("c:\mydll\test\test2.cpp",2005,12,31)
If ret=0
	Messagebox("���óɹ�!")
Else
	Messagebox("����ʧ��!")
Endif


InitUser()  && ��ʼ����Կ
CAPIEncryptFile("C:\���滻.txt","C:\���滻.tx_","abc") && ����һ���ļ�
CAPIDecryptFile("C:\���滻.tx_","c:\���滻2.txt","abc") && �����ļ�

?compress("c:\Acme", "C:\Acme\*.*",0) && ���һ������ֵΪ 0 ����ζ��ѹ�����е��ļ���һ����һ�� cab �ļ���.���򣬸�ֵΪ���ѹ���е�ÿһ����Ĵ�С(�� K Ϊ��λ)
?decompress("C:\001\","C:\Acme1.CAB")

*-- ֱ�ӷ���һ��������ǰ��ӡ��,��ӡ�󲻻�س���Ҳ�����ֽ
?PrintStringDirect("Ҫ��ӡ�Ĵ�", "Star AR-3200+","LPT1:")

*-- �պ���Ͽ�
?DialUp("163","163","163")
?DisconnectRas()

?getip()
?getname()

? MD5STRING("message digest",len("message digest"))
?"================"
? MD5FILE("F:\mydll\mydll.dll")

* ��ȡ���� MAC
?"���� MAC:" + getmac(1)
?"���� MAC:" + getmac(2)
?"���� MAC:" + getmac(3)

* ����תƴ��
?"ƴ��ת��:���� �ͻ� ���� �ռ�"+topy("���� �ͻ� ���� �ռ�")

* ��ֵת���
?num2txt_c(1234567.89)
?num2txt_c(-1234567.89)

*-- ��Ӻ�ɾ������
If shareadd("C:\","MYSHARE","�ҵĹ�����",1,"")=1
	Messagebox("����ɹ�")
Else
	Messagebox("����ʧ��")
Endif

If sharedel("MYSHARE")=1
	Messagebox("ɾ������ɹ�")
Else
	Messagebox("ɾ������ʧ��")
Endif

* ӳ��/�Ͽ�ӳ������������
ret=connecttonetwork("\\legend4-1\���������ļ�","P:","legend4-1","legend41")
If ret=0   && ӳ��������ԴΪһ������������, ��װ�� WNetUseConnection API
	Messagebox("�Ѿ��� \\legend4-1\���������ļ� ӳ��Ϊ������ P:")
Else
	Messagebox("ӳ�� \\legend4-1\���������ļ� Ϊ������ P: ����ʧ��,������:"+str(ret))
Endif

If cancelconnect("P:")=1            && �Ͽ�һ���Ѿ�ӳ���������Դ  , ��װ�� WNetCancelConnection2 API
	Messagebox("�Ѿ���ӳ�� P: �Ͽ�")
Else
	Messagebox("�Ͽ� P: ӳ��Ĳ���ʧ��")
Endif

*-- ͨ�� MAPI ���ʹ����������ʼ�
If sendmail("icoico@21cn.com","test","this is a sendmail test","c:\winzip.log")=0
	Messagebox("sendmail ���ͳɹ�")
Else
	Messagebox("sendmail ����ʧ��")
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
sendmail("njjane@21cn.com","����Ϣ���ڲ���","��ã�"+chr(13)+"    ���д��ţ����ԭ��",sys(5)+curdir()+"readme.txt")
sendmail("njjane@21cn.com","����Ϣ���ڲ���","��ã�"+chr(13)+"    ���д��ţ����ԭ��","")
?num2txt_c(0.12)
?num2txt_c(1.23)
?num2txt_c(123.09)
?num2txt_c(1234567.89)


If IsDiskInDrive("A:\") = 0
	? "No disk in driver"
Else
	? "disk is in driver"
Endif

?"==========���Կ�ʼ=============="
?"�����ܲ���:"
a="1 2 3 1 23abc�й������ž�������ľ���123123abc   "
?"          ԭ��:"+a,len(a)

b=alltrim(getserial(0))  && �����õ���Կ,����ʹ�õ��ǵ�һ��Ӳ�̵ĳ������к�
c=encstr(a,b)
?"    ���ܺ�Ĵ�:"+c,len(c)

d=encstr(c,b)  && ���ܵ���Կ���������ʱ����Կ��ͬ
?"���ܼ��ܺ�Ĵ�:"+d,len(d)
?
?"���Ӳ�����к�:"
?"Ӳ�����к�1:"+alltrim(getserial(0))
?"Ӳ�����к�2:"+alltrim(getserial(1))
?
op=IsWin2000()
If op=1
	?"��Ĳ���ϵͳ Windows 2000 �� NT"
Else
	?"��Ĳ���ϵͳ Windows 9x"
Endif
?
PrinterName=space(250) &&replicate(chr(0),250)
NameSpace=250
DPGetDefaultPrinter(@PrinterName,@NameSpace)
?"Ĭ�ϴ�ӡ��:"+left(PrinterName,NameSpace-1)
?
*-- �޸�����������Ӧ���ϵͳ
NewPrint="Star AR-3200+"
DPSetDefaultPrinter(@NewPrint)
?"�����õ�Ĭ�ϴ�ӡ��:"+NewPrint
?
?"����������:"+getname()
?"���� IP:"+getip()
?
?"ƴ��ת��:���F����ţ�� = "+topy("���F����ţ��")

?"C:�̾�:" + VolumeNumber("C:\")
?
?"�ļ�"+sys(5)+curdir()+"MyDll.dll �� CRC ֵΪ:" + getcrc(sys(5)+curdir()+"mydll.dll")
?getcrc("")   && �����Ч���ļ���
?"���� MAC:" + getmac(1)
?

*?"�ı���Ļ�ֱ���Ϊ:1024*768  "
*changeres(1024,768)

?"Ping   www.myf1.net   �Ľ����"+pinghost("www.myf1.net")
?"Ping   һ�������ڵ���ַ�Ľ����"+pinghost("www.naughter.com")

?num2txt_c(123.09)
?num2txt_c(1234567.89)

* FTP ����
myftpgetfile("61.133.63.168", "VFP7����_���뷨����.zip","C:\VFP7����_���뷨����.zip", "fox","fox")


*?"�ı���Ļ�ֱ���Ϊ:800*600  "
changeres(800,600)

?"==========���Խ���=============="
Clear dlls
Return
