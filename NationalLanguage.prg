* Program Name : NationalLanguage.Prg
* Article No.  : [Win API] - 018
* Illustrate   : ??????????
* Date / Time  : 2001.09.10
* Writer       : 
* 1st Post     : 
* My Comment   : ???? LangID = 2052 ???(??),???????
*              : ????????????�??????�???,???
*              : ???????????????? Windows,??????
*              : ??????????

DECLARE SHORT GetSystemDefaultLangID IN kernel32
DECLARE SHORT GetUserDefaultLangID   IN kernel32
DECLARE SHORT GetSystemDefaultLCID   IN kernel32
DECLARE SHORT GetUserDefaultLCID     IN kernel32
DECLARE SHORT GetThreadLocale        IN kernel32

DECLARE INTEGER GetOEMCP IN kernel32
DECLARE INTEGER GetACP IN kernel32
DECLARE INTEGER GetKBCodePage IN user32

? "ϵͳȱʡ LangID               : ", GetSystemDefaultLangID()
? "�û�ȱʡ LangID               : ", GetUserDefaultLangID()
? "ϵͳȱʡ�ֲ��ַ�����ʶ�� LCID : ", GetSystemDefaultLCID()
? "�û�ȱʡ�ֲ��ַ�����ʶ�� LCID : ", GetUserDefaultLCID()
? "Current Thread Locale         : ", GetThreadLocale()
? "OEM ����ҳ��ʶ��              : ", GetOEMCP()
? "ANSI ����ҳ��ʶ��             : ", GetACP()
? "Current code page (should be the same as GetOEMCP): ", GetKBCodePage()
