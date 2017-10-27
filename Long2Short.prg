* Program Name : Long2Short.Prg
* Article No.  : [Win API] - 019
* Illustrate   : ?????/???????/???
* Date / Time  : 2001.09.10
* Writer       : 
* 1st Post     : 
* My Comment   : FoxPro ?????/?????? 8/3 ??????/???,
*              : ?? GetShortPathName API ??,?????......
* Usage        : ? ShortPath("C:\Program Files\Microsoft Visual
*              : Studio\Vfp98")
?ShortPath(GetFile())
************************************************************************
Function ShortPath
******************
*** Function: Converts a Long Windows filename into a short
*** 8.3 compliant path/filename
*** Pass: lcPath - Path to check
*** Return: lcShortFileName
*************************************************************************
    Lparameter lcPath

    Declare INTEGER GetShortPathName IN "kernel32";
        STRING  @ lpszLongPath,;
        STRING  @ lpszShortPath,;
        INTEGER   cchBuffer

    lcPath = lcPath
    lcShortName = SPACE(260)
    lnLength = LEN(lcShortName)
    lnResult = GetShortPathName(@lcPath, @lcShortName, lnLength)

    If lnResult = 0
        Return ""
    Endif
    Return  LEFT(lcShortName,lnResult)
