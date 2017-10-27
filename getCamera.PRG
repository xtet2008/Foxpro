*--前提：VFP7.0以上;Windows 2K及以上


*--定义：一般放到主程序或表单(集)的Load事件中
Public WM_CAP_DRIVER_DISCONNECT
Public hwndc,WM_CAP_SAVEDIB,WM_CAP_FILE_SET_CAPTURE_FILEA,WM_CAP_SEQUENCE,WM_CAP_STOP
Declare Integer capCreateCaptureWindowA In "AVICAP32.DLL" String lpszWindowName ,Integer dwStyle ,;
    Integer x, Integer Y, Integer nWidth ,Integer nHeight,Integer ParentWin,Integer nId
Declare Integer SendMessage In "user32" Integer HWnd, Integer wmsg,Integer wpar1, Integer wpar2
Declare Integer SendMessage In "user32" As SendMessageA Integer HWnd, Integer wmsg,Integer wpar1, String wpar2
 

*--显示：可以放到按钮或表单(集)的Init事件中
WM_USER = 1024
WM_CAP_START = WM_USER
WM_CAP_STOP = WM_CAP_START + 68
WM_CAP_DRIVER_CONNECT = WM_CAP_START + 10
WM_CAP_DRIVER_DISCONNECT = WM_CAP_START + 11
WM_CAP_SAVEDIB = WM_CAP_START + 25
WM_CAP_GRAB_FRAME = WM_CAP_START + 60
WM_CAP_SEQUENCE = WM_CAP_START + 62
WM_CAP_FILE_SET_CAPTURE_FILEA = WM_CAP_START + 20
WM_CAP_SEQUENCE_NOFILE =WM_CAP_START+ 63
WM_CAP_SET_OVERLAY =WM_CAP_START+ 51
WM_CAP_SET_PREVIEW =WM_CAP_START+ 50
WM_CAP_SET_CALLBACK_VIDEOSTREAM = WM_CAP_START +6
WM_CAP_SET_CALLBACK_ERROR=WM_CAP_START +2
WM_CAP_SET_CALLBACK_STATUSA= WM_CAP_START +3
WM_CAP_SET_CALLBACK_FRAME= WM_CAP_START +5
WM_CAP_SET_SCALE=WM_CAP_START+ 53
WM_CAP_SET_PREVIEWRATE=WM_CAP_START+ 52
*第3、4个参数是定义显示位置,第5、6个参数是定义显示大小。
hWndC = capCreateCaptureWindowA('My Own Capture Window',1342177280,0,0,320,240,Thisform.HWnd ,0)
If hWndC <> 0
    SendMessage(hWndC, WM_CAP_SET_CALLBACK_VIDEOSTREAM, 0, 0)
    SendMessage(hWndC, WM_CAP_SET_CALLBACK_ERROR, 0, 0)
    SendMessage(hWndC, WM_CAP_SET_CALLBACK_STATUSA, 0, 0)
    SendMessage(hWndC, WM_CAP_DRIVER_CONNECT, 0, 0)
    SendMessage(hWndC, WM_CAP_SET_SCALE, 1, 0)
    SendMessage(hWndC, WM_CAP_SET_PREVIEWRATE, 66, 0)
    SendMessage(hWndC, WM_CAP_SET_OVERLAY, 1, 0)
    SendMessage(hWndC, WM_CAP_SET_PREVIEW, 1, 0)
    * THISFORM.ACTIVATE
Endif
 

*--关闭显示：
SendMessage(hWndC,WM_CAP_DRIVER_DISCONNECT, 0, 0)
hWndC=0
 

*--保存图像：
*--无法控制生成的文件尺寸，因为是由摄像头本身默认的，不过可用Image控件显示时进行等比缩小的。
ss=Getfile("bmp;Jpg")
If !Empty(ss)
    SendMessageA(hWndC,WM_CAP_SAVEDIB,0,SS)
Endif
 

*--录像：
ss = Getfile("avi")
If !Empty(ss)
    SendMessageA(hWndC,WM_CAP_FILE_SET_CAPTURE_FILEA,0,ss)
    SendMessageA(hWndC, WM_CAP_SEQUENCE, 0, 0)
    This.Enabled=.F.
    Thisform.MousePointer= 0
    Thisform.停止录像按钮.Enabled=.T.
Endif
 

*--停止录像：
SendMessage(hWndC, WM_CAP_STOP, 0, 0)
Thisform.开始录像按钮.Enabled=.T.
This.Enabled=.F.