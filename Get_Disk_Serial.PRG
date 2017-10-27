*-----------------------------------------------
* ��ȡӲ�� Ʒ��_�汾_���к�  ����
*-----------------------------------------------
Function HY_GetDiskSerial( tnDisk )
    Local lcGetDiskSerial, hDevice, bIDCmd, lpOutBuffer, lpBytesReturned, bDfpDriveMap
    Local lcƷ��, lc�汾, lc���к�
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
            *-- ������� SMART IOCTL �ľ��
            Do Case
                Case m.dwPlatformId = 1 && ���� Win9x
                    m.hDevice = CreateFile("\\.\SMARTVSD",0,0,0,1,0,0)
                Case m.dwPlatformId = 2 && ���� WinNT
                    m.hDevice = CreateFile("\\.\PhysicalDrive"+Str(tnDisk,1),0xC0000000,3,0,3,0,0)
            Endcase
            If m.hDevice <> -1
                *-- ��� SMART IOCTL �汾��Ϣ
                m.VersionParams = Replicate(Chr(0),24)
                If DeviceIoControl(m.hDevice,0x74080,0,0,@m.VersionParams,Len(m.VersionParams),@m.lpBytesReturned,0) <> 0
                    *-- ����� IDE �������ͷ�������
                    If Bitand(HY_GDS_AscIIToDec(Substr(m.VersionParams,4,1)),1) = 1
                        *-- �������ݽ��ջ�����
                        m.OutCmd = Replicate(Chr(0),4)+Replicate(Chr(0),13)
                        *-- �ж��Ƿ�����ִ�� SMART ����
                        If Bitand(HY_GDS_AscIIToDec(Substr(m.VersionParams,4,1)),0x10) = 0
                            *-- Ϊִ�� SMART �����������ݽṹ
                            m.scip = Replicate(Chr(0),4)+Chr(0xD8)+Chr(0)+Chr(0)+Chr(0x4F)+Chr(0xC2)+Chr(0xA0)+Chr(0xB0)+Chr(0)+Chr(tnDisk)+Replicate(Chr(0),19)
                            *-- ������������ 0xD8 ����
                            If DeviceIoControl(m.hDevice,0x7c084,@m.scip,Len(m.scip),@m.OutCmd,Len(m.OutCmd)-1,@m.lpBytesReturned,0) # 0
                                *-- ����������ӳ���־
                                m.bDfpDriveMap = Bitor(m.bDfpDriveMap,1)
                                *-- ��ñ��� IDE ������������ID��ATAPI ��������ʹ�� 0xA1 �������ʹ�� 0xEC ���
                                m.bIDCmd = Iif(Bitand(HY_GDS_AscIIToDec(Substr(m.VersionParams,4,1)),1)=1,0xEC,0xA1)
                                *-- �������ݽṹ
                                m.scip =HY_GDS_DecToAscII(512,4)+Replicate(Chr(0),5)+Chr(0xA0)+Chr(m.bIDCmd)+Chr(0)+Chr(tnDisk)+Replicate(Chr(0),19)
                                *-- ��ȡ����������
                                m.lpOutBuffer = m.OutCmd + Replicate(Chr(0),512)
                                If DeviceIoControl(m.hDevice,0x7c088,@m.scip,Len(m.scip),@m.lpOutBuffer,Len(m.lpOutBuffer)-1,@m.lpBytesReturned,0) # 0
                                    lcƷ�� = HY_GDS_AscIIToStr(Substr(m.lpOutBuffer,71,40))
                                    lc�汾 = HY_GDS_AscIIToStr(Substr(m.lpOutBuffer,63,08))
                                    lc���к� = HY_GDS_AscIIToStr(Substr(m.lpOutBuffer,37,20))
                                    lcGetDiskSerial = Allt(lcƷ��) +[_]+ Allt(lc�汾) +[_]+ Allt(lc���к�)
                                Endif
                            Endif
                        Endif
                    Endif
                Endif
                = CloseHandle(m.hDevice) && �ر� SMART
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