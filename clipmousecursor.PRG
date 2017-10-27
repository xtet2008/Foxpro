* Program Name : ClipMouseCursor.Prg
* Article No.  : [Win API] - 006
* Illustrate   : 如何局限鼠标的光标活动区域？
* Date / Time  : 2001.09.10
* Writer       : 
* 1st Post     : 
* My Comment   : 个别用户喜欢做与本工作无关的事情，用此法 Try......
*

PUBLIC frm
frm = CreateObject("TForm")
frm.Visible = .T.

DEFINE CLASS TForm As Form
    PROTECTED mClip
    ADD OBJECT cmdClip As TCommand
    ADD OBJECT cmdRestore As TCommand

PROCEDURE  Load
     THIS.decl    && declare external functions
ENDPROC

PROCEDURE  Init
    STORE .F. TO THIS.MaxButton, THIS.MinButton
    STORE 300 TO THIS.Width, THIS.Height
    THIS.Caption = "Clipping Mouse Cursor Area"
    THIS.BorderStyle = 2
    THIS.AutoCenter = .T.
    THIS.cmdClip.Caption = "Clip"
    THIS.cmdRestore.Caption = "Restore"

    * saving initial clipping area
    lpRect = REPLI (Chr(0), 16)
    = GetClipCursor (@lpRect)
    THIS.mClip = lpRect

    THIS.Resize
ENDPROC

PROCEDURE  Destroy
    THIS.restoreInitStatus
ENDPROC

PROCEDURE  Resize
    lnTop = MAX(5, THIS.Height - THIS.cmdClip.Height - 5)
    STORE lnTop TO THIS.cmdClip.Top, THIS.cmdRestore.Top
    THIS.cmdRestore.Left = THIS.Width - THIS.cmdRestore.Width - 10
    THIS.cmdClip.Left = THIS.cmdRestore.Left - THIS.cmdClip.Width - 2
ENDPROC

PROCEDURE  clip
* lock the mouse cursor within the form area
    MOUSE AT THIS.top, THIS.left PIXELS  && put cursor inside the form
    * give VFP a moment to update mouse position in its internal data
    = INKEY (0.1)

    lpPoint = REPLI (Chr(0), 8)    && buffer for a POINT structure
    = GetCursorPos (@lpPoint)  && retrieve absolute mouse position

    LOCAL absX, absY, lcCaptionHeight, lcFrameWidth,;
        lcFrameHeight, lcRect

    absX = ThisForm.buf2dword (SUBSTR(lpPoint, 1,4))
    absY = ThisForm.buf2dword (SUBSTR(lpPoint, 5,4))

    * retrieve some sizes to be used in calculating the area
    lcCaptionHeight = GetSystemMetrics ( 4)  && size of normal caption area
    lcFrameWidth    = GetSystemMetrics (32)  && resiz.window frame width
    lcFrameHeight   = GetSystemMetrics (33)  && resiz.window frame height

    lcRect = REPLI (Chr(0), 16)        && buffer for RECT structure
    * set the RECT by the form position, and size
    THIS.num2rect (absX, absY,;
        absX + THIS.Width + lcFrameWidth,;
        absY + THIS.Height + lcCaptionHeight + lcFrameHeight,;
        @lcRect)

    = ClipCursor (lcRect)  && locked!
ENDPROC

PROCEDURE  restoreInitStatus
    = ClipCursor (THIS.mClip)
ENDPROC

PROCEDURE  cmdClip.Click
    ThisForm.clip
ENDPROC

PROCEDURE  cmdRestore.Click
    ThisForm.restoreInitStatus
ENDPROC

FUNCTION  buf2dword (lcBuffer)
#DEFINE m0       256
#DEFINE m1     65536
#DEFINE m2  16777216
RETURN;
    Asc(SUBSTR(lcBuffer, 1,1)) + ;
    Asc(SUBSTR(lcBuffer, 2,1)) * m0 +;
    Asc(SUBSTR(lcBuffer, 3,1)) * m1 +;
    Asc(SUBSTR(lcBuffer, 4,1)) * m2
ENDFUNC

FUNCTION  num2buf
PARAMETERS  lnValue
#DEFINE m0       256
#DEFINE m1     65536
#DEFINE m2  16777216
    LOCAL b0, b1, b2, b3
    b3 = Int(lnValue/m2)
    b2 = Int((lnValue - b3 * m2)/m1)
    b1 = Int((lnValue - b3*m2 - b2*m1)/m0)
    b0 = Mod(lnValue, m0)
RETURN Chr(b0)+Chr(b1)+Chr(b2)+Chr(b3)

PROCEDURE  num2rect (lnLeft, lnTop, lnRight, lnBottom, lcBuffer)
    lcBuffer = THIS.num2buf(lnLeft) + THIS.num2buf(lnTop)+;
        THIS.num2buf(lnRight) + THIS.num2buf(lnBottom)
ENDFUNC

PROCEDURE  decl
    DECLARE INTEGER ClipCursor       IN user32   STRING lpRect
    DECLARE INTEGER GetCursorPos     IN user32   STRING @ lpPoint
    DECLARE INTEGER GetClipCursor    IN user32   STRING @ lpRect
    DECLARE INTEGER GetSystemMetrics IN user32   INTEGER nIndex
ENDPROC
ENDDEFINE

DEFINE CLASS TCommand As CommandButton
    Width = 60
    Height = 25
    FontName = 'System'
EndDefine


