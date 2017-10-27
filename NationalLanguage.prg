* Program Name : NationalLanguage.Prg
* Article No.  : [Win API] - 018
* Illustrate   : ??????????
* Date / Time  : 2001.09.10
* Writer       : 
* 1st Post     : 
* My Comment   : ???? LangID = 2052 ???(??),???????
*              : ????????????‘??????’???,???
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

? "ÏµÍ³È±Ê¡ LangID               : ", GetSystemDefaultLangID()
? "ÓÃ»§È±Ê¡ LangID               : ", GetUserDefaultLangID()
? "ÏµÍ³È±Ê¡¾Ö²¿×Ö·û¼¯±êÊ¶·û LCID : ", GetSystemDefaultLCID()
? "ÓÃ»§È±Ê¡¾Ö²¿×Ö·û¼¯±êÊ¶·û LCID : ", GetUserDefaultLCID()
? "Current Thread Locale         : ", GetThreadLocale()
? "OEM ´úÂëÒ³±êÊ¶·û              : ", GetOEMCP()
? "ANSI ´úÂëÒ³±êÊ¶·û             : ", GetACP()
? "Current code page (should be the same as GetOEMCP): ", GetKBCodePage()
