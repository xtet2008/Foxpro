* Program Name : SetWinRegion.Prg
* Article No.  : [Win API] - 020
* Illustrate   : ?????????
* Date / Time  : 2001.09.10
* Writer       : 
* 1st Post     : 
* My Comment   : ???‘?????????(?????)?????’?
*              : API,?????????,????????,??????
*              : ???,? VFP 7.0 ???,?????

Public frm
frm = CreateObject ("Tform")
frm.Visible = .T.
Return

Define CLASS Tform As Form
    Caption = "Setting the Window Region"
    Width = 600
    Height = 350
    AutoCenter = .T.
    MaxButton = .F.
    MinButton = .F.

    Add OBJECT CmdOn As CommandButton WITH;
        Left=15, Top=7, Width=120, Height=25, FontName = 'System',;
        Caption="Set Region On"

    Add OBJECT CmdOff As CommandButton WITH;
        Left=15, Top=35, Width=120, Height=25, FontName = 'System',;
        Caption="Set Region Off"

    Procedure  Load
        This.decl
    Endproc

    Procedure  CmdOn.Click
        Thisform.regionOn
    Endproc

    Procedure  CmdOff.Click
        Thisform.regionOff
    Endproc

    Procedure  regionOn
        Local hRgn
        hRgn = CreateRectRgn (0, 0, 200, 100)
        = SetWindowRgn (GetFocus(), hRgn, 1)
    Endproc

    Procedure  regionOff
        = SetWindowRgn (GetFocus(), 0, 1)
    Endproc

    Procedure  decl
        Declare INTEGER GetFocus IN user32

        Declare INTEGER CreateRectRgn IN gdi32;
            INTEGER nLeftRect,;
            INTEGER nTopRect,;
            INTEGER nRightRect,;
            INTEGER nBottomRect

        Declare SetWindowRgn IN user32;
            INTEGER hWnd,;
            INTEGER hRgn,;
            SHORT   bRedraw
    Endproc
Enddefine
