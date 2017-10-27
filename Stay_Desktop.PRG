Public _Form1
_Form1=CreateObject("Form1")
_Form1.show
RETURN
DEFINE CLASS Form1 AS form
Height = 32
Width = 297
ShowWindow = 2
ShowInTaskBar = .T.
DoCreate = .T.
Caption = "行者示例-悬停窗体"
MaxButton = .F.
MinButton = .F.
TitleBar = 1
WindowState = 0
BackColor =RGB( 221,177,226)
PROCEDURE Init
this.AddObject("Label1","Classname")
DECLARE INTEGER FindWindow IN user32;
    STRING lpClassName,;
    STRING lpWindowName
DECLARE INTEGER GetWindow IN user32;
    INTEGER hwnd,;
    INTEGER wFlag
DECLARE INTEGER SetWindowPos IN user32;
    INTEGER hwnd,;
    INTEGER hWndInsertAfter,;
    INTEGER x,;
    INTEGER y,;
    INTEGER cx,;
    INTEGER cy,;
    INTEGER wFlags
Declare integer SetParent in user32 integer hWndChild , integer hWndNewParent
*-----------------------------------------------------------------*
*-VFP应用程式算法群:12787940 行者孙:310727570-*
*-----------------------------------------------------------------*
uHwnd = FindWindow('ProgMan',NULL)
fHwnd = getWindow(_screen.hwnd,5)
SetParent(fHwnd,uHwnd)
SetWindowPos(this.hwnd, -1, 0, 0, 0,0, 1)
ENDPROC
PROCEDURE Unload
quit
ENDPROC
ENDDEFINE
DEFINE CLASS Classname AS label
Visible=.T.
AutoSize = .T.
FontSize = 14
BackStyle = 0
Caption = "我就停在这里了，怎么着吧你？！"
Height = 24
Left = 16
Top = 6
Width = 287
ForeColor =RGB( 255,0,0)
ENDDEFINE