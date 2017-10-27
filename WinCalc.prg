* Program Name : WinCalc.Prg
* Article No.  : [Win API] - 027
* Illustrate   : ???
* Date / Time  : 2001.09.27
* Writer       : 
* 1st Post     : 

Private frm
frm = CreateObject ("Tform")
frm.Show (1)

Define CLASS Tform As Form
    Width = 400
    Height = 200
    AutoCenter = .T.
    Caption = "Accessing WinCalc Window"

    Add OBJECT cmdShow As Tbutton
    Add OBJECT cmdHide As Tbutton

    Procedure  Init
        This.cmdShow.caption = "Show Calc"
        This.cmdHide.caption = "Hide Calc"
        This._resize
        This.decl
    Endproc

    Procedure  cmdShow.click
        Thisform._show
    Endproc

    Procedure  cmdHide.click
        Thisform._hide
    Endproc

    Procedure  _resize
        With THIS.cmdHide
            .top = THIS.height - .height - 10
            .left = THIS.width - .width - 10
        Endwith
        With THIS.cmdShow
            .top = THIS.cmdHide.top
            .left = THIS.cmdHide.left - .width - .3
        Endwith
    Endproc

    Protected PROCEDURE  decl
        Declare INTEGER SetForegroundWindow IN "user32" INTEGER hwnd

        Declare INTEGER FindWindow IN user32;
            STRING lpClassName,;
            STRING lpWindowName

        Declare INTEGER WinExec IN kernel32;
            STRING lpCmdLine, INTEGER nCmdShow

        Declare SHORT PostMessage IN user32;
            INTEGER   hWnd,;
            INTEGER   Msg,;
            STRING  @ wParam,;
            INTEGER   lParam
    Endproc

    Procedure _show
        #Define SW_SHOWNORMAL  1
        Local hwnd
        HWnd = FindWindow (.NULL., "Calculator")
        If hwnd = 0
            = WinExec ("calc.exe", SW_SHOWNORMAL)
        Else
            = SetForegroundWindow (hwnd)
        Endif
    Endproc

    Procedure  _hide
        #Define WM_QUIT      18
        Local hwnd
        HWnd = FindWindow (.NULL., "Calculator")
        If hwnd <> 0
            = PostMessage (hwnd, WM_QUIT, 0,0)
        Endif
    Endproc
Enddefine

Define CLASS Tbutton As CommandButton
    FontName = 'System'
    Height = 24
    Width = 100
Enddefine