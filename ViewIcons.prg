* Program Name : ViewIcons.Prg
* Article No.  : [Win API] - 004
* Illustrate   : ??????????????
* Date / Time  : 2001.09.10
* Writer       : 
* 1st Post     : 
*

PUBLIC frm
    frm = CreateObject ("Tform")
    frm.Visible = .T.

DEFINE CLASS Tform As Form
    Width=600
    Height=400
    AutoCenter = .T.
    Caption = "Display Application Icons"

    ADD OBJECT lbl As Label WITH;
        Caption="App:", Left=15, Top=10
    ADD OBJECT txt As TextBox WITH;
        Left=60, Top=8, Height=24, Width=450
    ADD OBJECT cmdFile As CommandButton WITH;
        Caption="...", Top=8, Left=512,;
        Width=30, Height=24
    ADD OBJECT cmd As CommandButton WITH;
        Caption="Refresh", Width=80, Height=24,;
        Default=.T.

PROCEDURE  Load
    THIS.decl
ENDPROC

PROCEDURE  Init
    THIS.txt.Value = THIS.getVFPmodule()
    THIS.Resize
    THIS.cmd.SetFocus
    THIS.drawIcons
ENDPROC

PROCEDURE  Resize
    WITH THIS.cmd
        .Left = Int((ThisForm.Width - .Width)/2)
        .Top = THIS.Height - .Height - 10
    ENDWITH
ENDPROC

PROCEDURE  drawIcons
    * clear form
    THIS.visible = .F.
    THIS.visible = .T.
    = INKEY (0.1)    && give a break

    LOCAL lcExe, hApp, lnIndex, hIcon, X,Y, dX,dY
    lcExe = ALLTRIM(THIS.txt.Value)
    IF Not FILE (lcExe)
        WAIT WINDOW "File " + lcExe + " not found" NOWAIT
    ENDIF

    hApp = GetModuleHandle(0)
    STORE 40 TO dX,dY
    Y = 56
    X = dX

    lnIndex = 0
    DO WHILE .T.
        hIcon = ExtractIcon (hApp, lcExe, lnIndex)
        IF hIcon = 0
            EXIT
        ENDIF

        THIS._draw (hIcon, X,Y)
        = DestroyIcon (hIcon)

        lnIndex = lnIndex + 1
        X = X + dX
        IF X > THIS.Width-dX*2
            X = dX
            Y = Y + dY
        ENDIF
    ENDDO
ENDPROC

PROTECTED PROCEDURE  _draw (hIcon, X,Y)
    LOCAL hwnd, hdc
    hwnd = GetFocus()
    hdc = GetDC(hwnd) && this form
    = DrawIcon (hdc, X,Y, hIcon)
    = ReleaseDC (hwnd, hdc)
ENDPROC

PROCEDURE  selectFile
    LOCAL lcFile
    lcFile = THIS.getFile()
    IF Len(lcFile) <> 0
        THIS.txt.Value = lcFile
        THIS.drawIcons
    ENDIF
ENDPROC

PROTECTED FUNCTION getFile
    LOCAL lcResult, lcPath, lcStoredPath
    lcPath = SYS(5) + SYS(2003)
    lcStoredPath = FULLPATH (THIS.txt.Value)
    lcStoredPath = SUBSTR (lcStoredPath, 1, RAT(Chr(92),lcStoredPath)-1)

    SET DEFAULT TO (lcStoredPath)
    lcResult = GETFILE("EXE", "Get Executable:", "Open",0)
    SET DEFAULT TO (lcPath)
    RETURN LOWER(lcResult)
ENDFUNC

PROCEDURE  decl
    DECLARE INTEGER GetFocus IN user32
    DECLARE INTEGER GetDC IN user32 INTEGER hwnd
    DECLARE INTEGER GetModuleHandle IN kernel32 INTEGER lpModuleName

    DECLARE INTEGER ReleaseDC IN user32;
        INTEGER hwnd, INTEGER hdc

    DECLARE INTEGER LoadIcon IN user32;
        INTEGER hInstance,;
        INTEGER lpIconName

    DECLARE INTEGER ExtractIcon IN shell32;
        INTEGER hInst,;
        STRING  lpszExeFileName,;
        INTEGER lpiIcon

    DECLARE SHORT DrawIcon IN user32;
        INTEGER hDC,;
        INTEGER X,;
        INTEGER Y,;
        INTEGER hIcon

    DECLARE INTEGER GetModuleFileName IN kernel32;
        INTEGER  hModule,;
        STRING @ lpFilename,;
        INTEGER  nSize

    DECLARE SHORT DestroyIcon IN user32 INTEGER hIcon
ENDPROC

PROTECTED FUNCTION  getVFPmodule
    LOCAL lpFilename
    lpFilename = SPACE(250)
    lnLen = GetModuleFileName (0, @lpFilename, Len(lpFilename))
RETURN Left (lpFilename, lnLen)
ENDFUNC

PROCEDURE  cmd.Click
    ThisForm.drawIcons
ENDPROC
PROCEDURE  cmdFile.Click
    ThisForm.selectFile
ENDPROC
ENDDEFINE