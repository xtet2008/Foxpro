  *--转自：dkfdtf 大侠


#Define STANDARD_RIGHTS_REQUIRED 0x000F0000
#Define SC_MANAGER_ENUMERATE_SERVICE 0x0004
#Define SERVICE_WIN32 0x00000030
#Define SERVICE_STATE_ALL 0x00000003
#Define SERVICE_STOPPED 0x00000001
#Define SERVICE_START_PENDING 0x00000002
#Define SERVICE_STOP_PENDING 0x00000003
#Define SERVICE_RUNNING 0x00000004
#Define SERVICE_CONTINUE_PENDING 0x00000005
#Define SERVICE_PAUSE_PENDING 0x00000006
#Define SERVICE_PAUSED 0x00000007
Declare Long OpenSCManager In WIN32API ;
    String lpMachineName, ; && pointer to machine name string
    String lpDatabaseName, ; && pointer to database name string
    Long dwDesiredAccess && type of access
Declare Long EnumServicesStatus In WIN32API ;
    Long hSCManager, ; && handle to service control manager database
    Long dwServiceType, ; && type of services to enumerate
    Long dwServiceState, ; && state of services to enumerate
    String @ lpServices, ; && pointer to service status buffer
    Long cbBufSize, ; && size of service status buffer
    Long @ pcbBytesNeeded, ; && pointer to variable for bytes needed
    Long @ lpServicesReturned, ; && pointer to variable for number returned
    Long @ lpResumeHandle && pointer to variable for next entry
Declare Long CloseServiceHandle In WIN32API ;
    Long hSCObject && handle to service or service control manager database
Declare Long GetLastError In WIN32API
Declare Long VarPtr In msvbvm60.Dll String Pstr
 

Create Cursor svclist ( svcname C(20), dispname C(40), state C(8) )
 

m.hScm = OpenSCManager( Null, Null, Bitor( STANDARD_RIGHTS_REQUIRED, SC_MANAGER_ENUMERATE_SERVICE ))
If ( 0 == m.hScm )
    Insert Into svclist( svcname, dispname, state ) Values ( 'Error !', 'Open service control manager', Transform( GetLastError()))
Else
    m.cSSB = Replicate( Chr(0), 64*1024 )
    m.iSvcRet = 0
    If ( 0 == EnumServicesStatus( m.hScm, SERVICE_WIN32, SERVICE_STATE_ALL, @ m.cSSB, Len( m.cSSB), 0, @ m.iSvcRet, 0 ))
        Insert Into svclist( svcname, dispname, state ) Values ( 'Error !', 'Enumerates services', Transform( GetLastError()))
    Else
        *!* typedef struct _ENUM_SERVICE_STATUS { // ess
        *!* LPTSTR lpServiceName;
        *!* LPTSTR lpDisplayName;
        *!* SERVICE_STATUS ServiceStatus;
        *!* } ENUM_SERVICE_STATUS
        *!* typedef struct _SERVICE_STATUS {
        *!* DWORD dwServiceType;
        *!* DWORD dwCurrentState;
        *!* DWORD dwControlsAccepted;
        *!* DWORD dwWin32ExitCode;
        *!* DWORD dwServiceSpecificExitCode;
        *!* DWORD dwCheckPoint;
        *!* DWORD dwWaitHint;
        *!* } SERVICE_STATUS
        For m.ii = 1 To m.iSvcRet
            m.cESS = Substr( m.cSSB, 1+(m.ii-1)*36, 36 )
            m.iState = CToBin( Substr( m.cESS,13,4 ), 'rs' )
            Insert Into svclist ( svcname, dispname, state ) Values ( GetString( Substr( m.cESS,1,4 ) ), GetString( Substr( m.cESS,5,4 ) ), ;
                Icase( SERVICE_STOPPED == m.iState,'已停止', SERVICE_START_PENDING == m.iState,'启动中', SERVICE_STOP_PENDING == m.iState,;
                '已停止', SERVICE_RUNNING == m.iState,'运行中', SERVICE_CONTINUE_PENDING == m.iState, '继续中', ;
                SERVICE_PAUSE_PENDING == m.iState,'暂停中', SERVICE_PAUSED == m.iState, '已暂停', '未知状态' ))
        Endfor
    Endif
CloseServiceHandle( m.hScm )
Endif


Goto Top
Browse Name m.oGrid Nowait
With m.oGrid As Grid
    .ReadOnly = .T.
    .AllowCellSelection = .F.
    .HighlightBackColor = Rgb(0,64,128)
    .HighlightForeColor = Rgb( 255,255,255 )
    .SetAll( 'DynamicBackColor', 'IIF(1==RECNO()%2,RGB(255,243,243),RGB(255,255,255))' )
Endwith


Function GetString( tcPtr )
    Local cString
    Try
        m.cString = Sys( 2600, CToBin( m.tcPtr, 'rs' ),512 )
    Catch
        m.cString=''
    Endtry
    Return Left( m.cString, At( Chr(0), m.cString ) - 1 )
Endfunc
 