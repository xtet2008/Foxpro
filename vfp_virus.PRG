*!*     step:
*!*     1.execute hookexample.scx
*!*     2.click load libraries button
*!*     3.double click user32.dll libraried used item.
*!*     4.select messageboxA item in function used listbox
*!*     5.click hook api   button
*!*     6.click testMessageBox button

*!*     luyis(coolyylu)
*!*     qq:95865818
*!*     mail:95865818@qq.com
*!*     date:2009-02-10

PUBLIC oform1

oform1=NEWOBJECT("hookexample")
oform1.Show
RETURN


*set procedure to (sys(16)) additive 
#define IMAGE_DOS_SIGNATURE 0x5A4D
#define IMAGE_NT_SIGNATURE 0x00004550
#define IMAGE_DIRECTORY_ENTRY_IMPORT     1+1 &&c语言的数组索引1就等于vfp的2
#define IMAGE_NUMBEROF_DIRECTORY_ENTRIES 16
#define IMAGE_ORDINAL_FLAG 0x80000000
#define PAGE_READWRITE     0x0004
#define BYTE replicate(chr(0) ,1)
#define WORD replicate(chr(0) ,2)
#define DWORD replicate(chr(0) ,4)
#define PVOID replicate(chr(0) ,4)

#define BUILDTYPE_STRUCT 0
#define BUILDTYPE_UNION   1
#define GETTYPE_ALL 0
#define GETTYPE_ONE 1

Function LookupIAT
    lparameters hModule As long ,sImportCall As String ,tlGetAll As Integer 
    local pDosHeader ,pNTHeader ,pImportDesc ,sCurrMod
     pDosHeader = PIMAGE_DOS_HEADER(GetModuleHandle(0))
     gn = pDosHeader 
    if pDOSHeader.e_magic # IMAGE_DOS_SIGNATURE &&如果不是dos exe
        return NULL
    endif
     pNTHeader = PIMAGE_NT_HEADERS(hModule ,pDosHeader)
    if pNTHeader.Signature # IMAGE_NT_SIGNATURE &&如果不是window exe
        return NULL
    endif

    if pNTHeader.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress = 0
        return NULL
    endif
        
     * pImportDesc.Name 是地址偏移量
    local pImportDescIndex 
     pImportDescIndex = 0
     pImportDesc = PIMAGE_IMPORT_DESCRIPTOR(hModule ,pNTHeader ,pImportDescIndex   )
    
    do while pImportDesc.Name>0
            
         sCurrMod = sys(2600 ,hModule + pImportDesc.Name ,250)
         sCurrMod = left(sCurrMod ,at(chr(0) ,sCurrMod)-1)
        if tlGetAll = GETTYPE_ALL
            evaluate(sImportCall+[(']+lower(sCurrMod)+[','] + ;
            transform(hModule + pImportDesc.Name ,[@0]) + [')])
        else
            if lower(sImportCall)==lower(sCurrMod)            
                exit
            endif
        endif
         pImportDescIndex = pImportDescIndex + 1 
         pImportDesc = PIMAGE_IMPORT_DESCRIPTOR(hModule ,pNTHeader ,pImportDescIndex )
    enddo    

    if pImportDesc.Name = 0
        return NULL
    endif
    return pImportDesc
EndFunc

function HookAPIByName
    lparameters hModule As Integer, sImportMod As String ,;
                  pHookApi As Object ,tlGetAll As Integer 
    local pImportDesc 
    local pOrigThunk ,pRealThunk ,nThunkIndex
    local pByName ,lcName
    local mbi_thunk ,idata ,iProtect
    
     pImportDesc = LookupIAT(hModule, sImportMod ,GETTYPE_ONE)
        
    if isnull(pImportDesc)
        return .f.
    endif
     iProtect     = 0
     nThunkIndex = 0
     pOrigThunk   = PIMAGE_THUNK_DATA(hModule ,pImportDesc.u.OriginalFirstThunk ,nThunkIndex )
     pRealThunk   = PIMAGE_THUNK_DATA(hModule ,pImportDesc.FirstThunk ,nThunkIndex )
    
    do while pOrigThunk.u1.Function > 0
        if bitand(pOrigThunk.u1.Ordinal ,IMAGE_ORDINAL_FLAG) # IMAGE_ORDINAL_FLAG
             pByName = PIMAGE_IMPORT_BY_NAME(hModule ,pOrigThunk.u1.AddressOfData)
            if pByName.Name[1] = 0
                return false
            endif    
             lcName = sys(2600 ,pByName.__addr + pByName.__Size([Hint]) ,250) &&pByName.Name            
             lcName = left(lcName ,at(chr(0) ,lcName)-1)        
            if tlGetAll = GETTYPE_ALL
                evaluate(pHookApi+[(']+lcName+[','] + ;
                transform(pRealThunk.u1.Function ,[@0]) + [')])                
            else    
                if lower(pHookApi.sFunc) == lower(lcName)         
                    
                     mbi_thunk = MEMORY_BASIC_INFORMATION()
                     idata = replicate(chr(0) ,SizeOf(mbi_thunk))
                        VirtualQuery(pRealThunk.__addr, @idata , SizeOf(mbi_thunk))
                        WriteToObj(mbi_thunk ,@idata)
                        iProtect = mbi_thunk.Protect
                     VirtualProtect(mbi_thunk.BaseAddress ,mbi_thunk.RegionSize , PAGE_READWRITE ,@iProtect)
                     mbi_thunk.Protect = iProtect 
                    if pHookApi.pOldProc = 0
                         pHookApi.pOldProc = pRealThunk.u1.Function &&设置新的

                         *?'新函数',transform(pHookApi.pNewProc ,[@0]) ,'原函数:'+transform(pRealThunk.u1.Function ,[@0])
                         *pRealThunk.u1.Function = pHookApi.pNewProc
                         WriteToObj(pRealThunk.u1 ,bintoc(pHookApi.pNewProc ,[4rs]))
                    else
                         *pRealThunk.u1.Function = pHookApi.pOldProc &&恢复原                        
                         WriteToObj(pRealThunk.u1 ,bintoc(pHookApi.pOldProc ,[4rs]))    
                         pHookApi.pOldProc = 0            
                    endif                                    
                     WriteObjToMemory(pRealThunk) &&写入更新
                     iProtect     = 0        
                     VirtualProtect(mbi_thunk.BaseAddress, mbi_thunk.RegionSize, mbi_thunk.Protect, @iProtect)
                endif
            endif 
        endif 
         nThunkIndex = nThunkIndex + 1         
         pOrigThunk   = PIMAGE_THUNK_DATA(hModule ,pImportDesc.u.OriginalFirstThunk ,nThunkIndex )
         pRealThunk   = PIMAGE_THUNK_DATA(hModule ,pImportDesc.FirstThunk ,nThunkIndex )
    enddo    
            
endfunc

function MEMORY_BASIC_INFORMATION
    local lp As Empty ,addr ,lphead
     lp = BuildType(BUILDTYPE_STRUCT)    
    addItem(lp ,[BaseAddress]         ,PVOID)    
    addItem(lp ,[AllocationBase]     ,PVOID)
    addItem(lp ,[AllocationProtect]     ,DWORD)
    addItem(lp ,[RegionSize]         ,DWORD)
    addItem(lp ,[State]                 ,DWORD)
    addItem(lp ,[Protect]             ,DWORD)
    addItem(lp ,[Type]                 ,DWORD)
    return lp
endfunc
function PIMAGE_IMPORT_BY_NAME
    lparameters hModule ,pData
     local lp As Empty ,addr ,lphead
     lp = BuildType(BUILDTYPE_STRUCT)    
    addItem(lp ,[Hint]     ,WORD)    
    addItem(lp ,[Name(1)]     ,[BYTE] ,1)
     addr = hModule + pData
     lp.__addr = addr
     lphead = sys(2600 ,addr ,Sizeof(lp))
     WriteToObj(lp ,@lphead)
    return lp    
endfunc
Function PIMAGE_THUNK_DATA
    Lparameters hModule ,pThunkAddr ,nIndex

     local lp As Empty ,addr ,lphead
     lp = BuildType(BUILDTYPE_STRUCT)    
    addItem(lp ,[u1]     ,U1())
     addr = hModule + pThunkAddr + nIndex*Sizeof(lp)
     lp.__addr = addr
     lphead = sys(2600 ,addr ,Sizeof(lp))
     WriteToObj(lp ,@lphead)    
    return lp    
EndFunc 
Function U1
     local lp 
     lp = BuildType(BUILDTYPE_UNION)    
    addItem(lp ,[ForwarderString]     ,DWORD)
    addItem(lp ,[Function]             ,DWORD)
    addItem(lp ,[Ordinal]             ,DWORD)
    addItem(lp ,[AddressOfData]         ,DWORD)
    Return lp         
EndFunc 

Function PIMAGE_IMPORT_DESCRIPTOR
    lparameter hModule ,lpNT As PIMAGE_NT_HEADERS ,nIndex
     local lp As Empty ,addr ,lphead
     lp = BuildType(BUILDTYPE_STRUCT)    
    addItem(lp ,[u],DUMMYUNIONNAME())    
    addItem(lp ,[TimeDateStamp]     ,DWORD)    
    addItem(lp ,[ForwarderChain],DWORD)    
    addItem(lp ,[Name]             ,DWORD)    
    addItem(lp ,[FirstThunk]     ,DWORD)        
     addr =      hModule + ;
             lpNT.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress + ;
             SizeOf(lp)*nIndex    
    
     lphead = sys(2600 ,addr ,Sizeof(lp))    
     WriteToObj(lp ,@lphead)    
    return lp
EndFunc
Function DUMMYUNIONNAME
    local lp As Empty 
     lp = BuildType(BUILDTYPE_UNION)
    addItem(lp ,[Characteristics]         ,DWORD)
    addItem(lp ,[OriginalFirstThunk]     ,DWORD)
    return lp
EndFunc
Function PIMAGE_NT_HEADERS 
    lparameter hModule ,lpDos As PIMAGE_DOS_HEADER
    local lp As Empty ,addr ,lphead
     lp = BuildType(BUILDTYPE_STRUCT)    
    addItem(lp ,[Signature]         ,DWORD)    
    addItem(lp ,[FileHeader]     ,IMAGE_FILE_HEADER())    
    addItem(lp ,[OptionalHeader],IMAGE_OPTIONAL_HEADER())
     addr = hModule + lpDos.e_lfanew
     lphead = sys(2600 ,addr ,Sizeof(lp))
     WriteToObj(lp ,@lphead)    
    return lp
EndFunc

Function IMAGE_OPTIONAL_HEADER
    local lp As Empty ,lphead
     lp = BuildType(BUILDTYPE_STRUCT)
    
    addItem(lp ,[Magic]                         ,WORD)    
    addItem(lp ,[MajorLinkerVersion]         ,BYTE)
    addItem(lp ,[MinorLinkerVersion]         ,BYTE)
    addItem(lp ,[SizeOfCode]                 ,DWORD)
    addItem(lp ,[SizeOfInitializedData]         ,DWORD)
    addItem(lp ,[SizeOfUninitializedData]     ,DWORD)
    addItem(lp ,[AddressOfEntryPoint]         ,DWORD)
    addItem(lp ,[BaseOfCode]                 ,DWORD)
    addItem(lp ,[BaseOfData]                 ,DWORD)
    addItem(lp ,[ImageBase]                     ,DWORD)
    addItem(lp ,[SectionAlignment]             ,DWORD)
    addItem(lp ,[FileAlignment]                 ,DWORD)
    addItem(lp ,[MajorOperatingSystemVersion],WORD)
    addItem(lp ,[MinorOperatingSystemVersion],WORD)
    addItem(lp ,[MajorImageVersion]             ,WORD)
    addItem(lp ,[MinorImageVersion]             ,WORD)
    addItem(lp ,[MajorSubsystemVersion]         ,WORD)
    addItem(lp ,[MinorSubsystemVersion]         ,WORD)
    addItem(lp ,[Win32VersionValue]             ,DWORD)
    addItem(lp ,[SizeOfImage]                 ,DWORD)
    addItem(lp ,[SizeOfHeaders]                 ,DWORD)
    addItem(lp ,[CheckSum]                     ,DWORD)
    addItem(lp ,[Subsystem]                     ,WORD)
    addItem(lp ,[DllCharacteristics]         ,WORD)
    addItem(lp ,[SizeOfStackReserve]         ,DWORD)
    addItem(lp ,[SizeOfStackCommit]             ,DWORD)
    addItem(lp ,[SizeOfHeapReserve]             ,DWORD)
    addItem(lp ,[SizeOfHeapCommit]             ,DWORD)
    addItem(lp ,[LoaderFlags]                 ,DWORD)
    addItem(lp ,[NumberOfRvaAndSizes]         ,DWORD)            
    addItem(lp ,[DataDirectory(1)] ,[IMAGE_DATA_DIRECTORY()] ,IMAGE_NUMBEROF_DIRECTORY_ENTRIES)    
    return lp
EndFunc



Function IMAGE_DATA_DIRECTORY
    local lp As Empty ,lphead
     lp = BuildType(BUILDTYPE_STRUCT)
    addItem(lp ,[VirtualAddress]     ,DWORD)        
    addItem(lp ,[Size]                 ,DWORD)        
    return lp
EndFunc
Function IMAGE_FILE_HEADER
    local lp As Empty ,lphead
     lp = BuildType(BUILDTYPE_STRUCT)
    addItem(lp ,[Machine]                 ,WORD)
    addItem(lp ,[NumberOfSections]         ,WORD)
    addItem(lp ,[TimeDateStamp]             ,DWORD)
    addItem(lp ,[PointerToSymbolTable]     ,DWORD)
    addItem(lp ,[NumberOfSymbols]         ,DWORD)
    addItem(lp ,[SizeOfOptionalHeader]     ,WORD)
    addItem(lp ,[Characteristics]         ,WORD)    
    return lp
EndFunc
Function PIMAGE_DOS_HEADER
    lparameter hModule    
    local lp As Empty ,lphead
     lp = BuildType(BUILDTYPE_STRUCT)
    addItem(lp ,[e_magic]          ,WORD)
    addItem(lp ,[e_cblp]          ,WORD)
    addItem(lp ,[e_cp]              ,WORD)
    addItem(lp ,[e_crlc]          ,WORD)
    addItem(lp ,[e_cparhdr]          ,WORD)
    addItem(lp ,[e_minalloc]      ,WORD)
    addItem(lp ,[e_maxalloc]      ,WORD)
    addItem(lp ,[e_ss]              ,WORD)
    addItem(lp ,[e_sp]              ,WORD)
    addItem(lp ,[e_csum]          ,WORD)
    addItem(lp ,[e_ip]              ,WORD)
    addItem(lp ,[e_cs]              ,WORD)
    addItem(lp ,[e_lfarlc]          ,WORD)
    addItem(lp ,[e_ovno]          ,WORD)
    addItem(lp ,[e_res(4)]          ,[WORD] ,4) &&     WORD e_res[4]
    addItem(lp ,[e_oemid]          ,WORD)
    addItem(lp ,[e_oeminfo]          ,WORD)
    addItem(lp ,[e_res2(10)]      ,[WORD] ,10) &&     WORD e_res2[10] 
    addItem(lp ,[e_lfanew]          ,DWORD) && LONG e_lfanew    
     lphead = sys(2600 ,hModule ,Sizeof(lp))        
     lp.__addr = hModule    
     WriteToObj(lp ,@lphead)    
    return lp
EndFunc

*以下是Struct相关函数
Function addItem
    lparameter lp ,cprop ,idata ,nsize  &&array size
    local ll ,i ,nlen
     nlen = 0
     ll = '('$cprop
    addProperty(lp ,cprop ,idata)
     *处理数组属性
    if ll
         cprop = left(cprop ,at('(' ,cprop)-1)
        dimension lp.&cprop[nsize]
        for i=1 to nsize
             lp.&cprop[m.i] = evaluate(idata)
             nlen = nlen + SizeOf(lp.&cprop[m.i])            
        next
    else
         nlen = SizeOf(idata)     
    endif    
     lp.__size.add(nlen ,cprop)
     lp.__nameitems.add(cprop)
Endfunc

function SizeOf
    lparameters lp
    local ns    
    if vartype(lp) = [O]
        do case
        case lp.__type = BUILDTYPE_STRUCT
             ns = SizeofStruct(lp)
        case lp.__type = BUILDTYPE_UNION
             ns = SizeofUnion(lp)
        endcase
    else
         ns = len(lp)
    endif
    return ns
endfunc

function SizeofUnion
    lparameter lpU
    local i , nlen ,cprop    
     nlen = 0    
    for i=1 to lpU.__nameitems.count            
         cprop   = lpU.__nameitems(m.i)
         nlen = max(nlen , lpU.__size(cprop))        
    next
    return nlen    
endfunc
Function SizeofStruct
    lparameter lpStruct 
    local i , nlen ,cprop
     nlen = 0    
    for i=1 to lpStruct.__nameitems.count            
         cprop = lpStruct.__nameitems(m.i)
         nlen = nlen + lpStruct.__size(cprop)
    next
    return nlen
EndFunc
Function BuildType
    lparameters nType
    local ls
    if empty(nType)
         nType = BUILDTYPE_STRUCT 
    endif
     ls = createobject([empty])
    addProperty(ls ,[__nameitems] ,createobject([collection]))
    addProperty(ls ,[__size] ,createobject([collection]))
    addProperty(ls ,[__type] ,nType)
    addProperty(ls ,[__addr] ,0)
    return ls
EndFunc
function WriteToObj
    lparameters lp ,lpStr
    do case
    case lp.__type = BUILDTYPE_STRUCT
         = WriteToStruct(lp ,lpStr)
    case lp.__type = BUILDTYPE_UNION
         = WriteToUnion(lp ,lpStr)
    endcase    
endfunc

Function WriteToUnion
    lparameter lpUnion ,lpStr
    local i   ,nl ,cprop ,cpname ,nsize
    local j ,n ,ctype
        
    for i=1 to lpUnion.__nameitems.count
         cpname = lpUnion.__nameitems(m.i)
         cprop   = forceext([lpUnion.] ,cpname )
        if type(cprop ,1) = [A] &&如果属性是数组        
            n = Alen(&cprop ,1)            
             * 判断元素类型和尺寸                                    
             ctype = vartype(&cprop[1])
            if ctype = [O]    
                 nsize = SizeOf(&cprop[1])
            else
                 nsize = len(&cprop[1])
            endif
             nl = 1            
            for j=1 To n                
                if ctype = [O]                    
                     WriteToObj( &cprop[m.j] ,substr(lpStr ,nl ,nsize) )
                else
                     &cprop[m.j] = ctobin(substr(lpStr ,nl ,nsize) ,transform(nsize)+[rs])
                endif    
                 nl = nl + nsize
            next
        else
            if vartype(&cprop) = [O]
                 nsize = SizeOf(&cprop)
                 WriteToObj( &cprop ,substr(lpStr ,1 ,nsize ) )
            else
                 nsize = lpUnion.__size(cpname)    
                 &cprop = ctobin(substr(lpStr ,1 ,nsize ) ,transform(nsize)+[rs])
            endif            
        endif        
    next    
endfunc

* 将二进制数据读入结构对象
* 结构对象对象中可能包含结构对象
* 结构对象中可能出现数组
Function WriteToStruct
    lparameter lpStruct ,lpStr
    local i   ,nl ,cprop ,nsize
    local j ,n ,ctype
     nl = 1
    
    for i=1 to lpStruct.__nameitems.count
         cprop = forceext([lpStruct.] ,lpStruct.__nameitems(m.i))
        if type(cprop ,1) = [A] &&如果属性是数组        
            n = Alen(&cprop ,1)            
             * 判断元素类型和尺寸                                    
             ctype = vartype(&cprop[1])
            if ctype = [O]    
                 nsize = SizeOf(&cprop[1])
            else
                 nsize = len(&cprop[1])
            endif            
            for j=1 To n                
                if ctype = [O]                    
                     WriteToObj( &cprop[m.j] ,substr(lpStr ,nl ,nsize) )
                else
                     &cprop[m.j] = ctobin(substr(lpStr ,nl ,nsize) ,transform(nsize)+[rs])
                endif    
                 nl = nl + nsize
            next
        else
            if vartype(&cprop) = [O]
                 nsize = SizeOf(&cprop)
                 WriteToObj( &cprop ,substr(lpStr ,nl ,nsize ) )
            else
                 nsize = len(&cprop)        
                 &cprop = ctobin(substr(lpStr ,nl ,nsize ) ,transform(nsize)+[rs])
            endif
             nl = nl + nsize
        endif        
    next    
endfunc


function WriteObjToMemory
    lparameters lp
    if type([lp.__addr])=[U] or lp.__addr = 0
        messagebox("无地址可写" ,16 ,"")
        return .f.
    endif
     *?'写入' ,transform(lp.__addr ,[@0]) ,transform(ctobin(ReadFromObj(lp) ,[4rs]) ,[@0]) ,
    sys(2600 ,lp.__addr ,SizeOf(lp) ,ReadFromObj(lp))
    return .t.
endfunc

function ReadFromObj
    lparameters lp    
    do case
    case lp.__type = BUILDTYPE_STRUCT
        return ReadFromStruct(lp)
    case lp.__type = BUILDTYPE_UNION
        return ReadFromUnion(lp)
    endcase    
endfunc

function ReadFromUnion
    lparameter lpUnion ,lpStr
    local i   , cprop ,cpname ,nsize
    local j ,n ,ctype ,idata
     nsize       = 0
     idata       = []
     *计算获取的项
    for i=1 to lpUnion.__nameitems.count
         cpname = lpUnion.__nameitems(m.i)
        
        if lpUnion.__size(cpname) > nsize
             nsize = lpUnion.__size(cpname) 
             cprop   = forceext([lpUnion.] ,cpname)
        endif
    next
    
    if type(cprop ,1) = [A] &&如果属性是数组        
        n = alen(&cprop ,1)            
         * 判断元素类型和尺寸                                    
         ctype = vartype(&cprop[1])
         nsize = nsize/n        
        for j=1 To n                
            if ctype = [O]                    
                 idata = idata + ReadFromObj(&cprop[m.j])
            else
                 idata = idata + bintoc(&cprop[m.j] ,transform(nsize)+[rs])
            endif                
        next
    else
        if vartype(&cprop) = [O]
             idata = ReadFromObj(&cprop)
        else            
             idata = bintoc(&cprop ,transform(nsize)+[rs])    
        endif            
    endif        
    return idata        
endfunc
function ReadFromStruct
    lparameter lpStruct ,lpStr
    local i   ,cprop ,cpname ,nsize
    local j ,n ,ctype
    local idata
     nl = 1
     idata = []
    
    for i=1 to lpStruct.__nameitems.count
         cpname = lpStruct.__nameitems(m.i)
         cprop   = forceext([lpStruct.] ,cpname )
        if type(cprop ,1) = [A] &&如果属性是数组        
            n = Alen(&cprop ,1)            
             * 判断元素类型和尺寸                                    
             ctype = vartype(&cprop[1])
             *计算单个元素的尺寸
             nsize = lpStruct.__size(cpname)/n
            for j=1 To n                
                if ctype = [O]                    
                     idata = idata + ReadFromObj(&cprop[m.j])
                else
                     idata = idata + bintoc(&cprop[m.j] ,transform(nsize)+[rs])                                        
                endif                    
            next
        else
            if vartype(&cprop) = [O]                
                 idata = idata + ReadFromObj(&cprop)
            else
                 nsize = lpStruct.__size(cpname)
                 idata = idata + bintoc(&cprop ,transform(nsize)+[rs])                
            endif
        endif        
    next
    return idata    
endfunc


procedure DeclareDLL
    declare integer VirtualProtect in kernel32 long ,long , long ,long @
    declare integer VirtualQuery in kernel32 long ,string @ ,long 
    declare integer GetModuleHandle in kernel32  long LPCWSTR        
    Declare Long LoadLibrary In Kernel32 ;
        String lpszLibFile
    Declare Long FreeLibrary In Kernel32 ;
        Long hLibModule
    Declare Long GetProcAddress In Kernel32 ;
        Long hModule, String lpProcName
    Declare Long GetProcessHeap In Kernel32

    Declare Long HeapCreate In Kernel32 ;
        Long flOptions, Long dwInitialSize, Long dwMaximumSize
    Declare Long HeapDestroy In Kernel32 ;
        Long hHeap
    Declare Long HeapAlloc In Kernel32 ;
        Long hHeap, Long dwFlags, Long dwBytes
    Declare Long HeapFree In Kernel32 ;
        Long hHeap, Long dwFlags, Long dwBytes
endproc 
procedure UnDeclareDLL
    Clear Dlls ;
        "LoadLibrary" ,"FreeLibrary" ,"GetProcAddress" ,"VirtualProtect" ,;
        "GetProcessHeap" ,"HeapCreate" ,"HeapDestroy" ,"HeapAlloc" ,;
        "HeapFree" ,"VirtualQuery" ,"GetModuleHandle"
endproc 

define class HookInfo as Collection
         
     sLib   = []
     sFunc = []
     pNewProc = 0
     pOldProc = 0
     hModule   = 0
     sCallBackFunction = []
    protected hPrcAddr 
     hPrcAddr = 0
    Protected hadr
     hadr = 0 &&function heap address
    protected Name
    procedure Init    
        This.name = [ohexx]&&sys(2015)
    endproc     
    procedure AddParams
        lparameters tcType As String ,tnLen As Integer         
        local lp 
         lp = createobject([empty])
        addproperty(lp ,[type] ,tcType)
        addproperty(lp ,[len] ,tnLen)        
        with This
             .Add(lp)
        endwith        
    endproc 
    procedure Hook
        This.SetRef()
        This.AddHookPrc()
         HookAPIByName(This.hModule ,This.sLib ,This ,GETTYPE_ONE)
    endproc 
    procedure UnHook
        if This.pOldProc#0
            set message to [Removing function '] + this.sFunc    + ;
            [' of lib '] + This.sLib   + [' ...]
             HookAPIByName(This.hModule ,This.sLib ,This ,GETTYPE_ONE)
            This.RemovePrc()
            set message to [Compelted!]
        endif    
        This.DelRef()
    endproc 
    protected procedure SetRef
        local lc
         lc = This.name
        public &lc
         &lc = This        
    endproc 
    protected procedure DelRef
        local lc
         lc = This.Name 
         &lc = NULL
        release &lc        
    endproc 
    
    protected function BuildHookCMD
        local lc
         lc = replicate([%d,] ,this.count)
         lc = left(lc ,len(lc)-1)                    
        return forceext(This.Name ,[FuncDelegate]) + [(] + lc + [)]        
    endfunc
    protected function GetParamBin
        local lc ,i
         lc = []
        for i=this.count to 1 step -1
             lc = lc + 0h8B45 + evaluate([0h]+right(transform(4+i*4 ,[@0]) ,2)) + 0h50
        next        
        return lc
    endfunc
    protected function GetStackESP
        return evaluate([0h]+right(transform((this.count+2)*4 ,[@0]) ,2))
    endfunc
    function FuncDelegate
        lparameters p1 ,p2 ,p3 ,p4 ,p5 ,p6 ,p7 ,p8 ,p9 ,p10 ,p11 ,p12 ,p13
        
        if     this.count # pcount()
            messagebox([Parameters count is wrong] ,16 ,[Error])
            return
        endif
        
        local i ,cvar ,ccmd
         ccmd = This.sCallBackFunction + [(]
        for i=1 to this.count
             cvar   = [p] + transform(i)
            do case
            case inlist(this.Item(m.i).type ,[long] ,[integer])
                 ccmd = ccmd + transform(&cvar) + [,]                
            case inlist(this.Item(m.i).type ,[string])
                 &cvar = sys(2600 ,&cvar ,250)
                 &cvar = left(&cvar ,at(chr(0) ,&cvar)-1)
                 ccmd = ccmd + ['] + &cvar + [',]
            endcase
        next
        if this.Count > 0
             ccmd = left(ccmd ,len(ccmd)-1)
        endif
         ccmd = ccmd + [)]                
         &ccmd
    endfunc    
    protected Procedure AddHookPrc        
         #Define HEAP_NO_SERIALIZE             0x01
         #Define HEAP_GENERATE_EXCEPTIONS     0x04
         #Define HEAP_ZERO_MEMORY              0x08

        Local lcHookCmd, lpHookCmd, lhHeap, lhModule
        Local lpSwprintf, lpSysAlloc, lpSysFree ,lpCallNext
        Local lcHookBinCode, lpHookAddress
        
         lcHookCmd =  Strconv(This.BuildHookCMD() + Chr(0), 5)
         lhHeap = GetProcessHeap()
        This.hadr = lhHeap
         *lhHeap = HeapCreate(HEAP_ZERO_MEMORY, 512*8, 512*8)
         lpHookCmd = HeapAlloc(m.lhHeap, HEAP_ZERO_MEMORY, Len(m.lcHookCmd))
        Sys(2600, m.lpHookCmd, Len(m.lcHookCmd), m.lcHookCmd)

         lhModule = LoadLibrary("msvcrt")
         lpSwprintf = GetProcAddress(m.lhModule, "swprintf")
         FreeLibrary(m.lhModule)

         lhModule = LoadLibrary("oleaut32")
         lpSysAlloc = GetProcAddress(m.lhModule, "SysAllocString" )
         lpSysFree = GetProcAddress(m.lhModule, "SysFreeString")
         FreeLibrary(m.lhModule)

         lcHookBinCode ;
         = 0h55 ;                                    && PUSH     EBP
         + 0h8BEC ;                                    && MOV      EBP,ESP
         + 0h81EC + 0h60000000;                        && SUB      ESP,00000060h
         + This.GetParamBin() ;                        &&paramaters
         + 0hB8 + BinToC(m.lpHookCmd, "4rs") ;        && MOV      EAX,[lpHookCmd]参数2
         + 0h50 ;                                    && PUSH     EAX
         + 0h8D45A0 ;                                && LEA      EAX,[EBP-60h] 参数1
         + 0h50 ;                                    && PUSH     EAX
         + 0hB8 + BinToC(m.lpSwprintf, "4rs") ;        && MOV      EAX,[lpSwprintf]
         + 0hFFD0 ;                                    && CALL     EAX
         + 0h83C4 + This.GetStackESP() ;                && ADD      ESP,18h      -- 调用 swfprintf 不会自动恢复堆栈指针
         + 0h8D45A0 ;                                && LEA      EAX,[EBP-60h]
         + 0h50 ;                                    && PUSH     EAX
         + 0hB8 + BinToC(m.lpSysAlloc, "4rs") ;        && MOV      EAX,[lpSysAlloc]
         + 0hFFD0 ;                                    && CALL     EAX
         + 0h8945F0 ;                                && MOV      [EBP-10h],EAX
         + 0h50 ;                                    && PUSH     EAX
         + 0hB8 + BinToC(Sys(3095, _vfp), "4rs") ;    && MOV      EAX,[Sys(3095, _vfp)]
         + 0h50 ;                                    && PUSH     EAX
         + 0h8B00 ;                                    && MOV      EAX,[EAX]
         + 0h0584000000 ;                            && ADD      EAX,00000084h
         + 0hFF10 ;                                    && CALL     [EAX]
         + 0h83F800 ;                                && CMP      EAX,00h
         + 0hB8 + BinToC(m.lpSysFree, "4rs") ;        && MOV      EAX,[lpSysFree]
         + 0hFFD0 ;                                    && CALL     EAX                         && MOV      EAX,00000000h
         + 0hB800000000 ;    
         + 0h8BE5 ;                                    && MOV      ESP,EBP
         + 0h5D ;                                    && POP      EBP
         + 0hC21000                                    && RET      000Ch

         lpHookAddress = HeapAlloc(m.lhHeap, HEAP_ZERO_MEMORY, Len(m.lcHookBinCode))
        Sys(2600, m.lpHookAddress, Len(m.lcHookBinCode), m.lcHookBinCode)
         *_cliptext = transform(m.lcHookBinCode)
        store lpHookAddress to This.hPrcAddr ,This.pNewProc 
        
        Return This.pNewProc
    Endproc

    protected Procedure RemovePrc        
         HeapFree(This.hadr ,0 ,0)
        Store 0 To     This.hadr 
    endproc
    Procedure Destroy    
        If This.hadr # 0
            This.UnHook()
        endif
    endproc 
enddefine 

Define Class HookManager As Session
    DataSession = 1
    protected HIFS as Collection&&hook info for api functions
     hModule   = 0
    procedure Init                
        This.HIFS = createobject([collection])
        This.hModule = GetModuleHandle(0)
    endproc 
    function AddHookInfo
        lparameters tsLib ,tsFunc ,tsCallBackFunction 
        
        local i ,ll ,ckey
         ckey = forceext(tsLib ,tsFunc)
        with this.HIFS 
            for i=1 to .count
                if .GetKey(m.i)==ckey
                     ll = .T.
                    exit
                endif
            next
            if !ll                
                 .add(createobject([HookInfo]) ,ckey)
                with .Item(ckey)
                     .sLib   = tsLib 
                     .sFunc = tsFunc
                     .sCallBackFunction = tsCallBackFunction 
                     .hModule   = This.hModule  
                endwith
            endif
        endwith
        return this.HIFS(ckey)
    endfunc 
    procedure RemoveHookInfo
        lparameters tsLib ,tsFunc        
        local ckey
         ckey = forceext(tsLib ,tsFunc)
        with This.HIFS
             .Item(ckey).UnHook()
             .Remove(ckey)
        endwith                
    endproc 
    procedure RemoveAllHookInfo
        local i ,ckey
        
        with This.HIFS        
            for i=1 to .count 
                 ckey = .GetKey(m.i)
                 .Item(ckey).UnHook()
                 .Remove(ckey)
            next
        endwith                
    endproc     

    Procedure Destroy
        This.RemoveAllHookInfo()    
    Endproc

Enddefine



Function HookFunc
        lparameters t1 ,t2 ,t3 ,t4 ,t5        
                    
         ?replicate('-' ,50)
         ?'调用窗口句柄:         ' + transform(t1,[@0]) 
         ?'调用窗口标题:         ' + getwcaption(t1)
         ?'MessageBox信息:     ' + t2
         ?'MessageBox标题:     ' + t3
         ?'MessageBox类型:     ' + transform(t4)
        declare integer MessageBoxA in user32 long ,string ,string ,long
         MessageBoxA(t1 ,"执行时间:" + ttoc(datetime()) + chr(13) + t2 ,t3 ,t4)
        clear dlls "MessageBoxA"
endfunc 

* by window handle
function getwcaption
    lparameters hwnd
    declare long GetWindowTextLength in   user32 long hwnd
    declare integer GetWindowText in user32 ;
    integer hwnd, ;
    string @lpString, ;
    integer cch    
    local nl as long ,s as string
     nl = GetWindowTextLength(hwnd) + 1
     s = replicate(chr(0) ,nl)
     GetWindowText(hwnd,@s,nl)
     s = lower(alltrim(s ,1,chr(0)))
    clear dlls "GetWindowText" ,"GetWindowTextLength"
    return s
endfunc



 **************************************************
*-- Form:          form1 (d:\editplus\vfptool\hookexample.scx)
*-- ParentClass:   form
*-- BaseClass:     form
*-- Time Stamp:    02/10/09 02:37:14 PM
*
DEFINE CLASS hookexample AS form


    Height = 510
    Width = 631
    ShowWindow = 2
    DoCreate = .T.
    AutoCenter = .T.
    Caption = "Example of API Hook in Visual Foxpro 9"
    AllowOutput = .F.
     hm = .F.


    ADD OBJECT command1 AS commandbutton WITH ;
        Top = 209, ;
        Left = 474, ;
        Height = 27, ;
        Width = 120, ;
        Anchor = 8, ;
        Caption = "TestMessageBox", ;
        Name = "Command1"


    ADD OBJECT command2 AS commandbutton WITH ;
        Top = 165, ;
        Left = 474, ;
        Height = 27, ;
        Width = 120, ;
        Anchor = 8, ;
        Caption = "Start   API Hook", ;
        Name = "Command2"


    ADD OBJECT command3 AS commandbutton WITH ;
        Top = 255, ;
        Left = 474, ;
        Height = 27, ;
        Width = 120, ;
        Anchor = 8, ;
        Caption = "Cancel API Hook", ;
        Name = "Command3"


    ADD OBJECT label1 AS label WITH ;
        AutoSize = .T., ;
        Caption = "Libraries Used:", ;
        Height = 17, ;
        Left = 4, ;
        Top = 8, ;
        Width = 87, ;
        Name = "Label1"


    ADD OBJECT lstlib AS listbox WITH ;
        Anchor = 10, ;
        BoundColumn = 1, ;
        ColumnCount = 2, ;
        ColumnWidths = "240,120", ;
        Height = 105, ;
        ColumnLines = .T., ;
        Left = 0, ;
        Sorted = .T., ;
        Top = 30, ;
        Width = 443, ;
        BoundTo = .F., ;
        Name = "lstlib"


    ADD OBJECT label2 AS label WITH ;
        AutoSize = .T., ;
        Caption = "Funtions Used:", ;
        Height = 17, ;
        Left = 7, ;
        Top = 141, ;
        Width = 86, ;
        Name = "Label2"


    ADD OBJECT lstfunc AS listbox WITH ;
        Anchor = 15, ;
        BoundColumn = 1, ;
        ColumnCount = 2, ;
        ColumnWidths = "240,120", ;
        Height = 326, ;
        ColumnLines = .T., ;
        Left = 0, ;
        Sorted = .T., ;
        Top = 162, ;
        Width = 443, ;
        BoundTo = .F., ;
        Name = "lstfunc"


    ADD OBJECT command4 AS commandbutton WITH ;
        Top = 299, ;
        Left = 474, ;
        Height = 27, ;
        Width = 120, ;
        Anchor = 8, ;
        Caption = "E\<xit Example", ;
        Name = "Command4"


    ADD OBJECT command5 AS commandbutton WITH ;
        Top = 48, ;
        Left = 468, ;
        Height = 27, ;
        Width = 120, ;
        Anchor = 8, ;
        Caption = "List Libraries", ;
        Name = "Command5"


    ADD OBJECT text1 AS textbox WITH ;
        Anchor = 8, ;
        Value = [messagebox("my first time hook" ,16 ,"caption me")], ;
        Height = 84, ;
        Left = 456, ;
        Top = 359, ;
        Width = 156, ;
        Name = "Text1"


    ADD OBJECT label3 AS label WITH ;
        AutoSize = .T., ;
        Caption = "Test Code:", ;
        Height = 17, ;
        Left = 456, ;
        Top = 336, ;
        Width = 62, ;
        Name = "Label3", ;
        Anchor = 8


    PROCEDURE libcallback
        lparameters tcName ,tcAddr

        with This.lstlib
             .AddItem(tcName)
              .List[.NewIndex, 2] = tcAddr
        endwith
    ENDPROC


    PROCEDURE functioncallback
        lparameters tcName ,tcAddr

        with This.lstfunc 
             .AddItem(tcName)
              .List[.NewIndex, 2] = tcAddr
        endwith
    ENDPROC


    PROCEDURE Init
        set procedure to hookapiinvfp.prg additive 
         =declaredll()
    ENDPROC


    PROCEDURE command1.Click

         *messagebox([my first time hook] ,16 ,"caption me")
        local lc
         lc = alltrim(thisform.text1.Value )
         &lc
    ENDPROC


    PROCEDURE command2.Click

        local hi as hookinfo of hookapiinvfp.prg
        local lc
         lc = seconds()
        set message to [Hooking function '] + thisform.lstfunc.DisplayValue    + ;
            [' of lib '] + thisform.lstlib.DisplayValue   + [' ...]
            
            
         hi = thisform.hm.addhookinfo(thisform.lstlib.DisplayValue ,;
                                    thisform.lstfunc.DisplayValue ,"HookFunc")

         hi.addparams("long" ,4)
         hi.addparams("string" ,4)
         hi.addparams("string" ,4)
         hi.addparams("long" ,4)
         hi.hook()
        set message to [Compelted!]
         ?'Executed time:'+transform(seconds()-lc)+'sec'
    ENDPROC


    PROCEDURE command3.Click

        thisform.hm.removehookinfo(thisform.lstlib.DisplayValue ,;
                                    thisform.lstfunc.DisplayValue)
    ENDPROC


    PROCEDURE lstlib.DblClick
         #define GETTYPE_ALL 0
        public _ofc 
         _ofc = thisform 
        thisform.lstfunc.Clear()
        Thisform.FunctionCallBack("\ Function Name" ,"\   Function Address")
         HookAPIByName(thisform.hm.hMODULE ,This.DisplayValue ,"_ofc.functioncallback" ,GETTYPE_ALL)
         _ofc = null
        release _ofc 
    ENDPROC


    PROCEDURE lstlib.Init
        Thisform.libcallback("\ Library Name" ,"\   Library Address" )
    ENDPROC


    PROCEDURE lstfunc.Click
        _cliptext = this.DisplayValue 
    ENDPROC


    PROCEDURE lstfunc.Init
        Thisform.FunctionCallBack("\ Function Name" ,"\   Function Address")
    ENDPROC


    PROCEDURE lstfunc.DblClick
        messagebox(this.DisplayValue)
    ENDPROC


    PROCEDURE command4.Click
        if vartype(thisform.hm)=[O] and !isnull(thisform.hm)
            thisform.hm.RemoveAllHookInfo()
        endif
         UnDeclareDLL()
        ThisForm.Release 
    ENDPROC


    PROCEDURE command5.Click
         #define GETTYPE_ALL 0
        local hm as HookManager of hookapiinvfp.prg
         hm = createobject([HookManager])
        thisform.hm = hm

        public ohex
         ohex = thisform
         LookupIAT(hm.hMODULE ,[ohex.libcallback] ,GETTYPE_ALL)
         ohex = NULL
        release ohex
    ENDPROC


ENDDEFINE
*
*-- EndDefine: form1
************************************************** 