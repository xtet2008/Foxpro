*-----------------------------------------------
* 获取硬盘 品牌_版本_序列号  红雨
*-----------------------------------------------
Function HY_GetDiskSerial( tnDisk )
    Local lcGetDiskSerial, hDevice, bIDCmd, lpOutBuffer, lpBytesReturned, bDfpDriveMap
    Local lc品牌, lc版本, lc序列号
    lcGetDiskSerial = []
    tnDisk = Iif(Type([tnDisk])=[N],Int(tnDisk),0)
    Declare Integer GetVersionEx In kernel32.Dll String
    Declare Integer CreateFile In kernel32.Dll String,Integer,Integer,String,Integer,Integer,Integer
    Declare Integer CloseHandle In kernel32.Dll Integer
    Declare Integer DeviceIoControl In Kernel32.Dll Integer,Integer,String,Integer,String @,Integer,Integer @,Integer
    Local lpVersionInformation, dwPlatformId
    m.lpVersionInformation = HY_GDS_DecToAscII(148,4)+Replicate(Chr(0),144)
    If GetVersionEx(@m.lpVersionInformation) <> 0
        m.dwPlatformId = HY_GDS_AscIIToDec(Substr(m.lpVersionInformation,17,4))
        If Inlist(m.dwPlatformId,1,2)
            Store 0 To m.hDevice,m.bDfpDriveMap
            *-- 获得用于 SMART IOCTL 的句柄
            Do Case
                Case m.dwPlatformId = 1 && 环境 Win9x
                    m.hDevice = CreateFile("\\.\SMARTVSD",0,0,0,1,0,0)
                Case m.dwPlatformId = 2 && 环境 WinNT
                    m.hDevice = CreateFile("\\.\PhysicalDrive"+Str(tnDisk,1),0xC0000000,3,0,3,0,0)
            Endcase
            If m.hDevice <> -1
                *-- 获得 SMART IOCTL 版本信息
                m.VersionParams = Replicate(Chr(0),24)
                If DeviceIoControl(m.hDevice,0x74080,0,0,@m.VersionParams,Len(m.VersionParams),@m.lpBytesReturned,0) <> 0
                    *-- 如果是 IDE 驱动器就发出命令
                    If Bitand(HY_GDS_AscIIToDec(Substr(m.VersionParams,4,1)),1) = 1
                        *-- 定义数据接收缓冲区
                        m.OutCmd = Replicate(Chr(0),4)+Replicate(Chr(0),13)
                        *-- 判断是否允许执行 SMART 命令
                        If Bitand(HY_GDS_AscIIToDec(Substr(m.VersionParams,4,1)),0x10) = 0
                            *-- 为执行 SMART 命令设置数据结构
                            m.scip = Replicate(Chr(0),4)+Chr(0xD8)+Chr(0)+Chr(0)+Chr(0x4F)+Chr(0xC2)+Chr(0xA0)+Chr(0xB0)+Chr(0)+Chr(tnDisk)+Replicate(Chr(0),19)
                            *-- 向驱动器发送 0xD8 命令
                            If DeviceIoControl(m.hDevice,0x7c084,@m.scip,Len(m.scip),@m.OutCmd,Len(m.OutCmd)-1,@m.lpBytesReturned,0) # 0
                                *-- 设置驱动器映射标志
                                m.bDfpDriveMap = Bitor(m.bDfpDriveMap,1)
                                *-- 获得本机 IDE 驱动器的扇区ID。ATAPI 驱动器则使用 0xA1 命令，其余使用 0xEC 命令。
                                m.bIDCmd = Iif(Bitand(HY_GDS_AscIIToDec(Substr(m.VersionParams,4,1)),1)=1,0xEC,0xA1)
                                *-- 设置数据结构
                                m.scip =HY_GDS_DecToAscII(512,4)+Replicate(Chr(0),5)+Chr(0xA0)+Chr(m.bIDCmd)+Chr(0)+Chr(tnDisk)+Replicate(Chr(0),19)
                                *-- 读取驱动器参数
                                m.lpOutBuffer = m.OutCmd + Replicate(Chr(0),512)
                                If DeviceIoControl(m.hDevice,0x7c088,@m.scip,Len(m.scip),@m.lpOutBuffer,Len(m.lpOutBuffer)-1,@m.lpBytesReturned,0) # 0
                                    lc品牌 = HY_GDS_AscIIToStr(Substr(m.lpOutBuffer,71,40))
                                    lc版本 = HY_GDS_AscIIToStr(Substr(m.lpOutBuffer,63,08))
                                    lc序列号 = HY_GDS_AscIIToStr(Substr(m.lpOutBuffer,37,20))
                                    lcGetDiskSerial = Allt(lc品牌) +[_]+ Allt(lc版本) +[_]+ Allt(lc序列号)
                                Endif
                            Endif
                        Endif
                    Endif
                Endif
                = CloseHandle(m.hDevice) && 关闭 SMART
            Endif
        Endif
    Endif
    Return lcGetDiskSerial
Endfunc

Function HY_GDS_AscIIToDec
    Lparameter Bytes
    Local ln_i,ln_j
    m.ln_j = 0
    For m.ln_i = Len(m.Bytes) To 1 Step -1
        m.ln_j = m.ln_j * 256 + Asc(Subs(m.Bytes,m.ln_i,1))
    Endfor
    Return m.ln_j
Endfunc

Function HY_GDS_DecToAscII
    Lparameter tn_i,tn_j
    Local lc_i,ln_i
    m.lc_i = ''
    For m.ln_i = 1 To m.tn_j
        m.lc_i = m.lc_i + Chr(Mod(m.tn_i,256))
        m.tn_i = Int(m.tn_i / 256)
    Endfor
    Return m.lc_i
Endfunc

Function HY_GDS_AscIIToStr
    Lparameter tc_i
    Local lc_i,ln_i
    m.lc_i = ''
    For m.ln_i = 1 To Len(m.tc_i) Step 2
        m.lc_i = m.lc_i + Subs(m.tc_i,m.ln_i+1,1) + Subs(m.tc_i,m.ln_i,1)
    Endfor
    Return m.lc_i
Endfunc
