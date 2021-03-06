*--VFP调用Windows Media Player控件播放音乐、视频等 
*--控件名称：Windows Media Player
*--控件文件名：wmp.dll
*--控件ProgID：WMPlayer.OCX
*--运行环境：VFP8及以上


*MyPlayer("F:/test.mp3")
 

*MyPlayer("D:/test.rmvb")

*MyPlayer("E:\Media\Music\故乡_李玉刚.mp3")

Procedure MyPlayer(tcURL, tnDrive)
    Local loError, loCD
    If Vartype(tcURL)#"C" Or Empty(tcURL)
        * Sample URL
        tcURL = "http://radio.livephish.com:8000"
    Endif
    If Type("_SCREEN.oWMP")#"O"
        _Screen.AddObject("oWMP","WMPContainer")
        With _Screen.oWMP
            .Height = _Screen.Height
            .Width = _Screen.Width
            .Visible=.T.
        Endwith
    Endif
    If Upper(tcURL)=="CD"
        If tnDrive = -1
            Return
        Endif
        loCD = _Screen.oWMP.oleWMP.cdromCollection.Item(tnDrive)
        _Screen.oWMP.oleWMP.currentPlaylist = loCD.Playlist
    Else
        _Screen.oWMP.oleWMP.url = tcURL
    Endif
Endproc


*---------- CLASSES ----------------------------------
Define Class WMPContainer As Container
    oWMPToolBar = Null
    Add Object oleWMP As OleControl With OleClass = 'WMPlayer.OCX' &&用到的文件为wmp.dll，名称Windows Media Player（C:/WINDOWS/system32/）
    Add Object tmrWMP1 As tmrWMP
    Procedure Init
        This.oleWMP.Width = This.Width+400
        This.oleWMP.Height = This.Height+300
        This.oWMPToolBar = Newobject('WMPToolBar', Sys(16), Null, This)
        This.oWMPToolBar.Visible = .T.
    Endproc
    Procedure Release
        _Screen.LockScreen = .T.
        This.RemoveObject('oleWMP')
        Release This
        _Screen.LockScreen = .F.
    Endproc
    Procedure oleWMP.DoubleClick(p1,p2,p3,p4)
        This.Visible = .F.
        This.Parent.Visible = .F.
        This.Parent.oWMPToolBar = Null
        This.Parent.tmrWMP1.Enabled = .T.
    Endproc
Enddefine
*--------------------------------------------
Define Class WMPToolBar As Toolbar
    ShowTips = .T.
    Caption = 'Fox Media Player'
    WMPContainer = Null
    Add Object CmdClose As CommandButton With ToolTipText = 'Close Fox Media Player',;
        Picture = Home() + 'tools/test/close.bmp', SpecialEffect = 2, Height = 22, Width = 140
    Procedure Init(WMPContainer As Object)
        This.WMPContainer = WMPContainer
    Endproc
    Procedure CmdClose.Click
        This.Parent.WMPContainer.oleWMP.DoubleClick()
    Endproc
Enddefine
*--------------------------------------------
Define Class tmrWMP As Timer
    Interval = 500
    Enabled = .F.
    Procedure Timer
        This.Parent.Release()
    Endproc
Enddefine