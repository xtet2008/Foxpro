*--首先感谢网友dkfdtf对GetTcpTable方法的编写，才使我轻意的写成了GetExtendedTcpTable
*--API-GetTcpTable：结果含有远程地址为空的记录，但不含有PID(进程ID)


Clear
#Define ERROR_INSUFFICIENT_BUFFER 122
Declare Long GetTcpTable In Iphlpapi String @pTcpTable,Long @pdwSize,Long Border
Declare String inet_ntoa In wsock32 Long inn
m.pTcpTable=''
m.pdwSize=0
m.iResult=GetTcpTable(@m.pTcpTable,@m.pdwSize,1)
If (ERROR_INSUFFICIENT_BUFFER!=m.iResult)
    ?'错误,Windows 错误代码:',m.iResult
    Return
Endif
m.pTcpTable=Replicate(Chr(0),m.pdwSize)
m.iResult=GetTcpTable(@m.pTcpTable,@m.pdwSize,1)
If (0!=m.iResult)
    ?'错误,Windows 错误代码:',m.iResult
    Return
Endif
m.iCount=CToBin(Left(m.pTcpTable,4),'rs')
m.pTcpTable=Substr(m.pTcpTable,5)
?"API-GetTcpTable：结果含有远程地址为空的记录，但不含有PID(进程ID)"
?Padr('LocalAddr',18)+Padr('LocalPort',15)+Padr('RemoteAddr',18)+Padr('RemotePort',15),'State'
?'------------------------------------------------------------------------'
For m.ii=1 To m.iCount
    m.cMIB_TCPROW=Substr(m.pTcpTable,1+(m.ii-1)*20,20)
    m.iState=CToBin(Substr(m.cMIB_TCPROW,1,4),'rs')
    m.iLocalAddr=CToBin(Substr(m.cMIB_TCPROW,5,4),'rs')
    m.iLocalPort=CToBin(Substr(m.cMIB_TCPROW,9,4),'rs')
    m.iRemoteAddr=CToBin(Substr(m.cMIB_TCPROW,13,4),'rs')
    m.iRemotePort=CToBin(Substr(m.cMIB_TCPROW,17,4),'rs')
    ?Padr(inet_ntoa(m.iLocalAddr),18);
        +Padr(Int(m.iLocalPort/256+(m.iLocalPort%256)*256),15);
        +Padr(inet_ntoa(m.iRemoteAddr),18);
        +Padr(Int(m.iRemotePort/256+(m.iRemotePort%256)*256),15),;
        Icase(m.iState=1,'CLOSED',m.iState=2,'LISTENING',m.iState=3,'SYN-SENT',m.iState=4,'SYN-RECEIVED',m.iState=5,'ESTABLISHED',m.iState=6,'FIN-WAIT-1',;
        m.iState=7,'FIN-WAIT-2',m.iState=8,'CLOSE-WAIT',m.iState=9,'CLOSING',m.iState=10,'LAST-ACK',m.iState=11,'TIME-WAIT',m.iState=12,'DELETE-TCB','UNKNOWN')
Endfor
Clear Dlls

*--API-GetExtendedTcpTable：结果含有PID(进程ID)，但不含有远程地址为空的记录。
*Clear
?'--------------------------------------------------------------------------------------'
#Define ERROR_INSUFFICIENT_BUFFER 122
#Define AF_INET 2
#Define TCP_TABLE_OWNER_PID_ALL 4
Declare Long GetExtendedTcpTable In Iphlpapi String @pTcpTable,Long @pdwSize,Long Border,Long ByVal,Long TableClass,Long ByVal
Declare String inet_ntoa In wsock32 Long inn
m.pTcpTable=''
m.pdwSize=0
m.iResult=GetExtendedTcpTable(@m.pTcpTable,@m.pdwSize,1,AF_INET,TCP_TABLE_OWNER_PID_ALL,0)
If (ERROR_INSUFFICIENT_BUFFER!=m.iResult)
    ?'错误,Windows 错误代码:',m.iResult
    Return
Endif
m.pTcpTable=Replicate(Chr(0),m.pdwSize)
m.iResult=GetExtendedTcpTable(@m.pTcpTable,@m.pdwSize,1,AF_INET,TCP_TABLE_OWNER_PID_ALL,0)
If (0!=m.iResult)
    ?'错误,Windows 错误代码:',m.iResult
    Return
Endif
m.iCount=CToBin(Left(m.pTcpTable,4),'rs')
m.pTcpTable=Substr(m.pTcpTable,5)
?"API-GetExtendedTcpTable：结果含有PID(进程ID)，但不含有远程地址为空的记录。"
?Padr('LocalAddr',18)+Padr('LocalPort',15)+Padr('RemoteAddr',18)+Padr('RemotePort',15),Padr('State',15),'PID'
?'--------------------------------------------------------------------------------------'
For m.ii=1 To m.iCount
    m.cMIB_TCPROW=Substr(m.pTcpTable,1+(m.ii-1)*24,24)
    m.iState=CToBin(Substr(m.cMIB_TCPROW,1,4),'rs')
    m.iLocalAddr=CToBin(Substr(m.cMIB_TCPROW,5,4),'rs')
    m.iLocalPort=CToBin(Substr(m.cMIB_TCPROW,9,4),'rs')
    m.iRemoteAddr=CToBin(Substr(m.cMIB_TCPROW,13,4),'rs')
    m.iRemotePort=CToBin(Substr(m.cMIB_TCPROW,17,4),'rs')
    m.iPID=CToBin(Substr(m.cMIB_TCPROW,21,4),'rs')
    ?Padr(inet_ntoa(m.iLocalAddr),18);
        +Padr(Int(m.iLocalPort/256+(m.iLocalPort%256)*256),15);
        +Padr(inet_ntoa(m.iRemoteAddr),18);
        +Padr(Int(m.iRemotePort/256+(m.iRemotePort%256)*256),15),;
        Padr(Icase(m.iState=1,'CLOSED',m.iState=2,'LISTENING',m.iState=3,'SYN-SENT',m.iState=4,'SYN-RECEIVED',m.iState=5,'ESTABLISHED',m.iState=6,'FIN-WAIT-1',;
        m.iState=7,'FIN-WAIT-2',m.iState=8,'CLOSE-WAIT',m.iState=9,'CLOSING',m.iState=10,'LAST-ACK',m.iState=11,'TIME-WAIT',m.iState=12,'DELETE-TCB','UNKNOWN'),15);
        +Transform(m.iPID)
Endfor
Clear Dlls
*!* 在这里我们详细介绍一下state的四种监听方式:
*!* 第一个是listening:监听
*!* 第二个是Estalished:已连接
*!* 第三个是Close_wait:连接已结束
*!* 以上三个是经常出现的,下面的这两个一般情况下是不会出现的:
*!* Fin_Wait_1:是等待对方的fin报文
*!* Syn_sent:是客户端已发送SYN报文
*!* LAST_ACK:这个有时也会出现。
*!* 有的地方介绍的不一样，平时在这们电脑是不会出现这么多选项的：
*!* LISTEN：侦听来自远方的TCp端口的连接请求
*!* SYN-SENT：再发送连接请求后等待匹配的连接请求
*!* SYN-RECEIVED：再收到和发送一个连接请求后等待对方对连接请求的确认
*!* ESTAbLISHED：代表一个打开的连接
*!* FIN-WAIT-1：等待远程TCp连接中断请求，或先前的连接中断请求的确认
*!* FIN-WAIT-2：从远程TCp等待连接中断请求
*!* CLOSE-WAIT：等待从本地用户发来的连接中断请求
*!* CLOSING：等待远程TCp对连接中断的确认
*!* LAST-ACK：等待原来的发向远程TCp的连接中断请求的确认
*!* TIME-WAIT：等待足够的时间以确保远程TCp接收到连接中断请求的确认
*!* CLOSED：没有任何连接状态