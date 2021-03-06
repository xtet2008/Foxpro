* Program Name : ReadingOptions.Prg
* Article No.  : [Win API] - 014
* Illustrate   : ?????? VFP 6.0 ???
* Date / Time  : 2001.09.10
* Writer       : 
* 1st Post     : 
* My Comment   : ??????????????

#Define ERROR_SUCCESS               0
#Define KEY_READ               131097
#Define KEY_ALL_ACCESS         983103
#Define HKEY_CURRENT_USER  2147483649 && 0x80000001

Do decl

hBaseKey = 0
*    lcBaseKey = "Software\Microsoft\VisualFoxPro\3.0\Options"
*    lcBaseKey = "Software\Microsoft\VisualFoxPro\5.0\Options"
*	 lcBaseKey = "Software\Microsoft\VisualFoxPro\6.0\Options"
*    lcBaseKey = "Software\Microsoft\VisualFoxPro\7.0\Options"
lcBaseKey = "Software\Microsoft\VisualFoxPro\9.0\Options"

* try this option too
*    lcBaseKey = "Software\ODBC\ODBC.INI\ODBC Data Sources"

If RegOpenKeyEx (HKEY_CURRENT_USER, lcBaseKey,;
        0, KEY_ALL_ACCESS, @hBaseKey) <> ERROR_SUCCESS
    ? "Error opening registry key"
    Return
Endif

Create CURSOR cs (valuename cs(50), valuevalue cs(200))

dwIndex = 0
Do WHILE .T.
    lnValueLen = 250
    lcValueName = Repli(Chr(0), lnValueLen)
    lnType = 0
    lnDataLen = 250
    lcData = Repli(Chr(0), lnDataLen)

    lnResult = RegEnumValue (hBaseKey, dwIndex,;
        @lcValueName, @lnValueLen, 0,;
        @lnType, @lcData, @lnDataLen)

* for this case on return the type of data (lnType)
* is always equal to 1 (REG_SZ)
* that means null-terminated string

    If lnResult <> ERROR_SUCCESS
        Exit
    Endif

    lcValueName = Left (lcValueName, lnValueLen)
    lcData = Left (lcData, lnDataLen-1)
    Insert INTO cs VALUES (lcValueName, lcData)

    dwIndex = dwIndex + 1
Enddo

= RegCloseKey (hBaseKey)
Select cs
Index ON valuename TAG valuename
Go TOP
Brow NORMAL NOWAIT

Procedure  decl
    Declare INTEGER RegCloseKey IN advapi32 INTEGER hKey

    Declare INTEGER RegOpenKeyEx IN advapi32;
        INTEGER   hKey,;
        STRING    lpSubKey,;
        INTEGER   ulOptions,;
        INTEGER   samDesired,;
        INTEGER @ phkResult

    Declare INTEGER RegEnumValue IN advapi32;
        INTEGER   hKey,;
        INTEGER   dwIndex,;
        STRING  @ lpValueName,;
        INTEGER @ lpcValueName,;
        INTEGER   lpReserved,;
        INTEGER @ lpType,;
        STRING  @ lpData,;
        INTEGER @ lpcbData
