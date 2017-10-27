* Program Name : EllipticalForm.Prg
* Article No.  : [Win API] - 028
* Illustrate   : ?????
* Date / Time  : 2001.09.27
* Writer       : Tuberose zyg8108@21cn.com
* 1st Post     : News://news.newsfan.net/???.??.???.Vfp

Public frm
frm = CreateObject ("Tform")
frm.Visible = .T.
Return

Define CLASS Tform As Form
    #Define horizDiameter  400
    #Define vertDiameter   260

    Caption = "?????"
    Width = 600
    Height = 350
    AutoCenter = .T.
    MaxButton = .F.
    MinButton = .F.
    hRgn = 0
    hwind = 0

    Add OBJECT cmd As CommandButton WITH;
        Width=80, Height=25, FontName='System', Caption="??"

    Procedure  Load
        This.decl
    Endproc

    Procedure  Init
        With THIS.cmd
            .Top = THIS.Height - .Height - 15
            .Left = (THIS.Width - .Width)/2
        Endwith
    Endproc

    Procedure  cmd.Click
        Thisform.TimeConsumingProc
    Endproc

    Procedure  TimeConsumingProc
* this is an emulation of a time consuming process
* while it is running the form is limited to an ellipse
        Clear

* limit the form to an ellipse
* defined by a region
        This.regionOn

        ?
        Local ii, jj
        For ii=1 TO 10
            Create CURSOR cs (id N(6), dt decl)

            ? "Inserting records to cursor... "

            For jj=1 TO 100
                Insert INTO cs VALUES (jj, DATE()-jj)
                ?? DATE()-jj, ", "
            Endfor
*        DOEVENTS

            ?? "Indexing cursor... "

            Index ON id TAG id
            Index ON dt TAG dt
*        DOEVENTS

            Use IN cs
            ?? "Ok | "
        Endfor

        This.regionOff   && restore the form to its original state
        This.cmd.Visible = .T.
    Endproc

    Procedure  regionOn
* create an elliptical region and apply it to the form
        Local x0,y0,x1,y1
        x0 = (THIS.Width - horizDiameter)/2
        y0 = (THIS.Height - vertDiameter)/2
        x1 = x0 + horizDiameter
        y1 = y0 + vertDiameter

        This.hwind = GetFocus()
        This.hRgn = CreateEllipticRgn (x0,y0,x1,y1)
        = SetWindowRgn (THIS.hwind, THIS.hRgn, 1)
    Endproc

    Procedure  regionOff
* release a region for this form
        = SetWindowRgn (THIS.hwind, 0, 1)
    Endproc

    Procedure  decl
        Declare INTEGER CreateEllipticRgn IN gdi32;
            INTEGER nLeftRect,;
            INTEGER nTopRect,;
            INTEGER nRightRect,;
            INTEGER nBottomRect

        Declare SetWindowRgn IN user32;
            INTEGER hWnd,;
            INTEGER hRgn,;
            SHORT   bRedraw

        Declare INTEGER GetFocus IN user32
    Endproc
Enddefine