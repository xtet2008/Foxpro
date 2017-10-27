*--VFP调用API：使用Iphlpapi.dll获取网络信息、网络流量（即发送字节和接收字节）等。
*--效果等同于DOS命令netstat -e
Clear
#Define ERROR_INSUFFICIENT_BUFFER 122
Declare Integer GetIfTable In iphlpapi String @pIfTable,Long @pdwSize,Long Border
Declare String inet_ntoa In wsock32 Long inn
m.pIfTable=''
m.pdwSize=0
m.iResult=GetIfTable(@m.pIfTable,@m.pdwSize,1)
If (m.iResult<>ERROR_INSUFFICIENT_BUFFER)
    ?'错误,Windows 错误代码:',m.iResult
    Return
Endif
m.pIfTable=Replicate(Chr(0),m.pdwSize)
m.iResult=GetIfTable(@m.pIfTable,@m.pdwSize,1)
If (m.iResult<>0)
    ?'错误,Windows 错误代码:',m.iResult
    Return
Endif
lnCount=CToBin(Left(m.pIfTable,4),'rs')     &&网络连接总数
m.pIfTable=Substr(m.pIfTable,5)
lnReceived=0
lnSent=0
For I=1 To lnCount
    lcMIB_IFROW=Substr(m.pIfTable,(I-1)*860+1,860)
    *lcWszName=LEFT(lcMIB_IFROW,512)
    lnIndex=CToBin(Substr(lcMIB_IFROW,513,4),'rs')
    lcType=MyGetType(CToBin(Substr(lcMIB_IFROW,517,4),'rs'))
    lnMtu=CToBin(Substr(lcMIB_IFROW,521,4),'rs')
    lnSpeed=CToBin(Substr(lcMIB_IFROW,525,4),'rs')
    lnPhysAddrLen=CToBin(Substr(lcMIB_IFROW,529,4),'rs')
    lcPhysAddr=Substr(lcMIB_IFROW,533,8)
    lcMacAddr = ''
    For ii=1 To lnPhysAddrLen
        lcMacAddr=lcMacAddr+Iif(ii>1,'-','')+Right(Transform(Asc(Substr(lcPhysAddr,ii,1)),'@0'),2)
    Endfor
    lnAdminStatus=CToBin(Substr(lcMIB_IFROW,541,4),'rs')
    lnOperStatus=MyGetState(CToBin(Substr(lcMIB_IFROW,545,4),'rs'))
    lnLastChange=CToBin(Substr(lcMIB_IFROW,549,4),'rs')
    lnInOctets=CToBin(Substr(lcMIB_IFROW,553,4),'rs')
    lnInUcastPkts=CToBin(Substr(lcMIB_IFROW,557,4),'rs')
    lnInNUcastPkts=CToBin(Substr(lcMIB_IFROW,561,4),'rs')
    lnInDiscards=CToBin(Substr(lcMIB_IFROW,565,4),'rs')
    lnInErrors=CToBin(Substr(lcMIB_IFROW,569,4),'rs')
    lnInUnknownProtos=CToBin(Substr(lcMIB_IFROW,573,4),'rs')
    lnOutOctets=CToBin(Substr(lcMIB_IFROW,577,4),'rs')
    lnOutUcastPkts=CToBin(Substr(lcMIB_IFROW,581,4),'rs')
    lnOutNUcastPkts=CToBin(Substr(lcMIB_IFROW,585,4),'rs')
    lnOutDiscards=CToBin(Substr(lcMIB_IFROW,589,4),'rs')
    lnOutErrors=CToBin(Substr(lcMIB_IFROW,593,4),'rs')
    lnOutQLen=CToBin(Substr(lcMIB_IFROW,597,4),'rs')
    lnDescrLen=CToBin(Substr(lcMIB_IFROW,601,4),'rs')
    lnDescr=Substr(lcMIB_IFROW,605,256)
    lnReceived=lnReceived+lnInOctets
    lnSent=lnSent+lnOutOctets
    ?'lnIndex',lnIndex                     &&接口编号
    ?'lcType',lcType                       &&接口类型
    ?'lnMtu',lnMtu                         &&最大传输单元
    ?'lnSpeed',lnSpeed                     &&接口速度(字节)
    ?'lnPhysAddrLen',lnPhysAddrLen         &&由bPhysAddr获得的物理地址有效长度
    ?'lcMacAddr',lcMacAddr                 &&物理地址
    ?'lnAdminStatus',lnAdminStatus         &&接口管理状态
    ?'lnOperStatus',lnOperStatus           &&操作状态
    ?'lnLastChange',lnLastChange           &&操作状态最后改变的时间
    ?'lnInOctets',lnInOctets               &&总共收到(字节)
    ?'lnInUcastPkts',lnInUcastPkts         &&总共收到(unicast包)
    ?'lnInNUcastPkts',lnInNUcastPkts       &&总共收到(non-unicast包)，包括广播包和多点传送包
    ?'lnInDiscards',lnInDiscards           &&收到后丢弃包总数(即使没有错误)
    ?'lnInErrors',lnInErrors               &&收到出错包总数
    ?'lnInUnknownProtos',lnInUnknownProtos &&收到后因协议不明而丢弃的包总数
    ?'lnOutOctets',lnOutOctets             &&总共发送(字节)
    ?'lnOutUcastPkts',lnOutUcastPkts       &&总共发送(unicast包)
    ?'lnOutNUcastPkts',lnOutNUcastPkts     &&总共发送(non-unicast包)，包括广播包和多点传送包
    ?'lnOutDiscards',lnOutDiscards         &&发送丢弃包总数(即使没有错误)
    ?'lnOutErrors',lnOutErrors             &&发送出错包总数
    ?'lnOutQLen',lnOutQLen                 &&发送队列长度
    ?'lnDescrLen',lnDescrLen               &&bDescr部分有效长度
    ?'lnDescr',lnDescr                     &&接口描述
Endfor
?'-------------------------'
?'Received:'+Transform(lnReceived)
?' Sent:'+Transform(lnSent)
?'-------------------------'
Clear Dlls


Function MyGetType     &&“接口类型”定义函数
    Parameters tnType
    Do Case
        Case tnType=1
            lcType="Other"
        Case tnType=6
            lcType="Ethernet"
        Case tnType=9
            lcType="Tokenring"
        Case tnType=15
            lcType="FDDI"
        Case tnType=23
            lcType="PPP"
        Case tnType=24
            lcType="Loopback"
        Case tnType=28
            lcType="Loopback"
        Otherwise
            lcType="UNKNOW"
    Endcase
    Return lcType
Endfunc


Function MyGetState     &&“操作状态”定义函数
    Parameters tnState
    Do Case
        Case tnState=0
            lcState="Not operational"
        Case tnState=1
            lcState="Operational"
        Case tnState=2
            lcState="Disconnected"
        Case tnState=3
            lcState="Connecting"
        Case tnState=4
            lcState="Connected"
        Case tnState=5
            lcState="Unreachable"
        Otherwise
            lcState="UNKNOW"
    Endcase
    Return lcState
Endfunc