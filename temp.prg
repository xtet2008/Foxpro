DECLARE integer LoadLibrary IN WIN32API string
DECLARE integer FreeLibrary IN WIN32API integer
DECLARE integer GetProcAddress IN WIN32API integer hModule, string procname
DECLARE integer GetProcessHeap IN WIN32API
DECLARE integer HeapAlloc IN WIN32API integer hHeap, integer dwFlags, integer dwBytes
DECLARE integer HeapFree IN WIN32API integer hHeap&&, integer dwFlags, integer lpMem
DECLARE integer GetWindowText IN WIN32API integer, string @, integer
DECLARE integer GetWindowLong IN WIN32API integer, integer
DECLARE integer EnumChildWindows IN WIN32API integer hWnd, integer lpEnumProc, integer lParam
*??:???(QQ 310727570) VFP???????(12787940)
LOCAL cCmd,hProcHeap,cCmdnAddr,hModule,nAddr
CREATE cursor WindHwnds (hWnd i)
cCmd=STRCONV("INSERT INTO WindHwnds (hWnd) VALUES (%d)"+0h00,5)
hProcHeap = GetProcessHeap()
cCmdnAddr = HeapAlloc(hProcHeap, 0,LEN(cCmd)) 
SYS(2600,cCmdnAddr,LEN(cCmd),cCmd)         
hModule=LoadLibrary("msvcrt")
nAddr=GetProcAddress(hModule,"swprintf")
CallDllCode1=0hB8+BINTOC(nAddr,"4rs")+0hFFD0
FreeLibrary(hModule)
hModule=LoadLibrary("oleaut32")
nAddr=GetProcAddress(hModule,"SysAllocString" )
CallDllCode2=0hB8+BINTOC(nAddr,"4rs")+0hFFD0
nAddr=GetProcAddress(hModule,"SysFreeString")
CallDllCode3=0hB8+BINTOC(nAddr,"4rs")+0hFFD0
FreeLibrary(hModule)
sCode=0h558BEC81ECD00700008B450850B8+BINTOC(cCmdnAddr,"4rs")
sCode=sCode+0h508D45A050+CallDllCode1
sCode=sCode+0h83C40C8D45A050 +CallDllCode2
sCode=sCode+0h8945F050B8+BINTOC(SYS(3095,_vfp),"4rs")
sCode=sCode+0h508B000584000000FF1083F800+CallDllCode3
sCode=sCode+0hB8010000008BE55DC20800
AdrCode=HeapAlloc(hProcHeap,0,LEN(sCode))
SYS(2600,AdrCode,LEN(sCode),sCode)
EnumChildWindows(0,AdrCode,0)
HeapFree(hProcHeap)
BROWSE &&??????????????