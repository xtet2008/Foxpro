Declare Integer LoadLibrary In WIN32API String
Declare Integer FreeLibrary In WIN32API Integer
Declare Integer GetProcAddress In WIN32API Integer hModule, String procname
Declare Integer GetProcessHeap In WIN32API
Declare Integer HeapAlloc In WIN32API Integer hHeap, Integer dwFlags, Integer dwBytes
Declare Integer HeapFree In WIN32API Integer hHeap&&, integer dwFlags, integer lpMem
Declare Integer GetWindowText In WIN32API Integer, String @, Integer
Declare Integer GetWindowLong In WIN32API Integer, Integer
Declare Integer EnumChildWindows In WIN32API Integer HWnd, Integer lpEnumProc, Integer Lparam
Declare Integer GetClassName In user32;
	INTEGER   HWnd,;
	STRING @ lpClassName,;
	INTEGER   nMaxCount
Declare Integer GetWindowThreadProcessId In user32;
	INTEGER   HWnd,;
	INTEGER @ lpdwProcId
********
Declare Long OpenProcess In kernel32;
	Long dwDesiredAccessas,;
	Long bInheritHandle,;
	Long dwProcId
Declare Long CloseHandle In kernel32;
	Long hObject
Declare Integer GetWindowThreadProcessId In user32;
	INTEGER   HWnd,;
	INTEGER @ lpdwProcId
Declare Integer FindWindowEx In user32;
	INTEGER hwndParent,;
	INTEGER hwndChildAfter,;
	STRING @ lpszClass,;
	STRING @ lpszWindow
Declare Integer FindWindow In user32;
	STRING lpClassName,;
	STRING lpWindowName
Declare Long VirtualAllocEx In WIN32API ;
	Long hProcess, Long @ lpAddress, Long dwSize, ;
	Long flAllocationType, Long flProtect
Declare Long VirtualFreeEx In WIN32API ;
	Long hProcess, Long lpAddress, Long dwSize, Long dwFreeType
Declare Integer SendMessage In user32;
	INTEGER HWnd,;
	INTEGER Msg,;
	INTEGER wParam,;
	INTEGER Lparam

Declare Integer VirtualQueryEx In kernel32  ;
	Integer hProcess , ;
	Integer lpAddress , ;
	String @lpBuffer , ;
	Integer dwLength

Declare Long ReadProcessMemory In WIN32API ;
	Long hProcess, Long lpBaseAddress, Long lpBuffer, ;
	Long nSize, Long @ lpNumberOfBytesWritten
************

*制作：行者孙（QQ 310727570） VFP应用程式算法群（12787940）
Local cCmd,hProcHeap,cCmdnAddr,hModule,nAddr
Create Cursor WindHwnds (HWnd i,uText CallDllCode1(254))
cCmd=Strconv("INSERT INTO WindHwnds (hWnd) VALUES (%d)"+0h00,5)
hProcHeap = GetProcessHeap()
cCmdnAddr = HeapAlloc(hProcHeap, 0,Len(cCmd))
Sys(2600,cCmdnAddr,Len(cCmd),cCmd)
hModule=LoadLibrary("msvcrt")
nAddr=GetProcAddress(hModule,"swprintf")
CallDllCode1=0hB8+BinToC(nAddr,"4rs")+0hFFD0
FreeLibrary(hModule)
hModule=LoadLibrary("oleaut32")
nAddr=GetProcAddress(hModule,"SysAllocString" )
CallDllCode2=0hB8+BinToC(nAddr,"4rs")+0hFFD0
nAddr=GetProcAddress(hModule,"SysFreeString")
CallDllCode3=0hB8+BinToC(nAddr,"4rs")+0hFFD0
FreeLibrary(hModule)
sCode=0h558BEC81ECD00700008B450850B8+BinToC(cCmdnAddr,"4rs")
sCode=sCode+0h508D45A050+CallDllCode1
sCode=sCode+0h83C40C8D45A050 +CallDllCode2
sCode=sCode+0h8945F050B8+BinToC(Sys(3095,_vfp),"4rs")
sCode=sCode+0h508B000584000000FF1083F800+CallDllCode3
sCode=sCode+0hB8010000008BE55DC20800
AdrCode=HeapAlloc(hProcHeap,0,Len(sCode))
Sys(2600,AdrCode,Len(sCode),sCode)
EnumChildWindows(0,AdrCode,0)
HeapFree(hProcHeap)

For i=1 To Reccount()
	Go i
	nBufsize = 254
	tBuffer = Replicate(Chr(0), nBufsize)
	cBuffer = Replicate(Chr(0), nBufsize)
	nBufsize = GetWindowText(HWnd,@tBuffer, nBufsize)
	GetClassName(HWnd,@cBuffer, nBufsize)
	tBuffer=Strtran(tBuffer,0h00,'')
	cBuffer=Strtran(cBuffer,0h00,'')
	If tBuffer=='QQ2009' And cBuffer=='TXGui'&&&判断是不是QQ主窗口
		lpdwProcId=0
		GetWindowThreadProcessId(HWnd,@lpdwProcId)&&获取进程ID
		***************进程搜索模块
		mi=Replicate(Chr(0),28)
		dwtotalcommit = 0
		paddr = 0
		ret=0
		mem_private = 0x20000
		page_readwrite=0x4
		process_vm_operation = 0x8
		process_vm_read = 0x10
		process_vm_write = 0x20000
		process_query_information = 0x400
		process_all_access = 0x1f0fff
		hProcess = OpenProcess(process_all_access,0,lpdwProcId)&&以查询 读和写的权限打开
		ret = VirtualQueryEx(hProcess,paddr,@mi,Len(mi))
		fxpstr=''
		tempstr=''
		kernel32=0
		Do While ret = 28
			If CToBin(Substr(mi,21,4),'4rs')=page_readwrite .And. CToBin(Substr(mi,25,4),'4rs')=mem_private
				lpBaseAddress=CToBin(Substr(mi,1,4),'4rs')&&基址
				lpRegionSize=CToBin(Substr(mi,13,4),'4rs')&&页面大小
				hProcHeap = GetProcessHeap()
				AdrStr = HeapAlloc(hProcHeap,0,lpRegionSize) &&申请
				lpNumberOfBytesRead=0
				If lpBaseAddress>0x181CC0
					ReadProcessMemory(hProcess,lpBaseAddress,AdrStr,lpRegionSize,@lpNumberOfBytesRead)
					fxpstr=Sys(2600,AdrStr,lpRegionSize)
					If At(Strconv('Msg2.0.db',5),fxpstr)>0
						QQHstr=Substr(fxpstr,At(Strconv('Msg2.0.db',5),fxpstr)-28,28)
						QQHstr=Strcon(QQHstr,6)
						QQHstr=Right( QQHstr,Len(QQHstr)-At('\',QQHstr))
						If Val(QQHstr)>0
							? 'QQ:'+Left(QQHstr,Len(QQHstr)-1)&&显示已登陆的QQ号码
							Exit
						Endi
					Endif
				Endi
			Endif
			paddr = CToBin(Substr(mi,1,4),'4rs') + CToBin(Substr(mi,13,4),'4rs')
			ret = VirtualQueryEx(hProcess,paddr,@mi,Len(mi))
		Enddo
	CloseHandle (hProcess)
	***************进程搜索结束
	Endif
Endfor
