Public _Form1
_Form1=CreateObject("Form1")
_Form1.show
RETURN
*-----------------------------------------------------------------*
*-VFP应用程式算法群:12787940 行者孙:310727570-*
*-----------------------------------------------------------------*
DEFINE CLASS Form1 AS form
autocenter=.T.
Height = 125
Width = 400
Caption = "行者示例-简单的星号查看"
BackColor =RGB( 0,0,0)
PROCEDURE Init
    FOR i=1 TO 4
    tempstr="Label"+ALLTRIM(STR(i))
    this.AddObject(tempstr,"label")
    WITH this.&tempstr
    .Visible=.T.
    .AutoSize = .T.
    .FontName = "黑体"
    .FontSize = 12
    .BackStyle = 0
    .Caption = "窗口句柄"
    .Height = 20
    .Left = 10
    .Top = 7+(i-1)*30
    .Width = 66
    .ForeColor =RGB( 0,255,0)
    endwith
    endf
    this.AddObject("Timer1","fresh")
    DECLARE INTEGER WindowFromPoint IN user32 INTEGER,INTEGER 
    DECLARE INTEGER SendMessage IN user32 INTEGER,INTEGER,INTEGER,STRING @
    DECLARE INTEGER GetClassName IN user32 INTEGER,STRING @,INTEGER
    DECLARE SHORT GetCursorPos IN user32 STRING @
    PUBLIC WM_GETTEXT,POINTAPI,curwnd,ClassName,uPassword
    POINTAPI=REPLICATE(CHR(0),8)
    WM_GETTEXT = 0xD
ENDPROC
ENDDEFINE
DEFINE CLASS fresh AS timer
Interval = 50
PROCEDURE Timer
    GetCursorPos(@POINTAPI)
    x=ctobin(SUBSTR(POINTAPI,1,4),'4rs')
    y=ctobin(SUBSTR(POINTAPI,5,4),'4rs')
    thisform.label1.caption='鼠标位置：'+ALLTRIM(STR(x))+','+ALLTRIM(STR(y))
    curwnd = WindowFromPoint(x,y)
    thisform.label2.caption='窗口句柄：'+ALLTRIM(STR(curwnd))
    ClassName=REPLICATE(CHR(0),255)
    GetClassName(curwnd,@ClassName,LEN(ClassName))
    thisform.label3.caption="窗口类型："+TRIM(ClassName)
    uPassword=REPLICATE(CHR(0),255)
    SendMessage(curwnd,WM_GETTEXT,LEN(uPassword),@uPassword)
    thisform.label4.caption='窗口文本：'+TRIM(uPassword)
ENDPROC
ENDDEFINE
