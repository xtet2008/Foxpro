*--ǰ�᣺VFP7.0����;Windows 2K������


*--���壺һ��ŵ�����������(��)��Load�¼���
Public WM_CAP_DRIVER_DISCONNECT
Public hwndc,WM_CAP_SAVEDIB,WM_CAP_FILE_SET_CAPTURE_FILEA,WM_CAP_SEQUENCE,WM_CAP_STOP
Declare Integer capCreateCaptureWindowA In "AVICAP32.DLL" String lpszWindowName ,Integer dwStyle ,;
    Integer x, Integer Y, Integer nWidth ,Integer nHeight,Integer ParentWin,Integer nId
Declare Integer SendMessage In "user32" Integer HWnd, Integer wmsg,Integer wpar1, Integer wpar2
Declare Integer SendMessage In "user32" As SendMessageA Integer HWnd, Integer wmsg,Integer wpar1, String wpar2
 

*--��ʾ�����Էŵ���ť�����(��)��Init�¼���
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
*��3��4�������Ƕ�����ʾλ��,��5��6�������Ƕ�����ʾ��С��
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
 

*--�ر���ʾ��
SendMessage(hWndC,WM_CAP_DRIVER_DISCONNECT, 0, 0)
hWndC=0
 

*--����ͼ��
*--�޷��������ɵ��ļ��ߴ磬��Ϊ��������ͷ����Ĭ�ϵģ���������Image�ؼ���ʾʱ���еȱ���С�ġ�
ss=Getfile("bmp;Jpg")
If !Empty(ss)
    SendMessageA(hWndC,WM_CAP_SAVEDIB,0,SS)
Endif
 

*--¼��
ss = Getfile("avi")
If !Empty(ss)
    SendMessageA(hWndC,WM_CAP_FILE_SET_CAPTURE_FILEA,0,ss)
    SendMessageA(hWndC, WM_CAP_SEQUENCE, 0, 0)
    This.Enabled=.F.
    Thisform.MousePointer= 0
    Thisform.ֹͣ¼��ť.Enabled=.T.
Endif
 

*--ֹͣ¼��
SendMessage(hWndC, WM_CAP_STOP, 0, 0)
Thisform.��ʼ¼��ť.Enabled=.T.
This.Enabled=.F.