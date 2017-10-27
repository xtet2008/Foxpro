*-- (c) Microsoft Corporation 1995

*-- Common include file
#INCLUDE "INCLUDE\FOXPRO.H"
#INCLUDE "INCLUDE\STRINGS.H"

#DEFINE DEBUGMODE .F.
#DEFINE INIFILE  "TASTRADE.INI"
#DEFINE CRLF  CHR(13) + CHR(10)
#DEFINE CR    CHR(13)
#DEFINE TAB    CHR(9)

#DEFINE CURRENCY  "$"
#DEFINE AERRORARRAY  7

*-- These constants are used in tsbaseform to 
*-- indicate the status of the current alias
#DEFINE FILE_OK    0
#DEFINE FILE_BOF  1
#DEFINE FILE_EOF  2
#DEFINE FILE_CANCEL  3

*-- Constants to identify which trigger failed
*-- using element 5 of the array returned by 
*-- AERROR(), as well as to reference the appropriate
*-- array element in the error message array: aErrorMsg[]
#DEFINE INSERTTRIG  1
#DEFINE UPDATETRIG  2
#DEFINE DELETETRIG  3

*-- Constants used to read the system registry
#DEFINE HKEY_LOCAL_MACHINE      -2147483646  
#DEFINE KEY_SHARED_TOOLS_LOCATION  "Software\Microsoft\Shared Tools Location"
#DEFINE KEY_NTCURRENTVERSION    "Software\Microsoft\Windows NT\CurrentVersion"
#DEFINE KEY_WIN4CURRENTVERSION    "Software\Microsoft\Windows\CurrentVersion"
#DEFINE KEY_QUERY_VALUE        1
#DEFINE ERROR_SUCCESS        0

