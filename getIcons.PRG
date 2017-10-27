Public frm
frm=Createobject ("Tform")
frm.Visible = .T.

Define Class Tform As Form
    Width=650
    Height=400
    BackColor=Rgb(200,255,200)
    AutoCenter=.T.
    Caption="WIN API-VFP提取文件中(图标资源)的图标(exe/dll/cpl/scr/ico/icl/cur/ocx)"

    Add Object lbl As Label With Caption="文件:",Left=15,Top=15,BackStyle=0
    Add Object txt As TextBox With Left=50,Top=8,Height=24,Width=450,Anchor=10
    Add Object cmdFile As CommandButton With Caption="选择文件",Top=8,Left=505,Width=80,Height=24,Anchor=8
    Add Object cmd As CommandButton With Caption="刷新",Width=80,Height=24,Left=300,Top=360,Default=.T.,Anchor=260
    Add Object MyImage As Image With Width=64,Height=64,Left=600,Top=05,BackStyle=0,Visible=.F.,Anchor=8
    Add Object MyList As ListBox With Width=80,Height=350,Left=560,Top=40,Anchor=13
    Add Object MyShape As Shape With Width=Thisform.Width,Height=Thisform.Height,Left=0,Top=0,Visible=.F.,Anchor=15 

Procedure Load
   Set Safety Off
   This.Decl
   If !Directory('c:\icon_tmp')
       Md 'c:\icon_tmp'
   Endif
Endproc 

Procedure Init
   This.txt.Value=This.getVFPmodule()
   This.cmd.SetFocus
   This.cmd.Click
Endproc 

Procedure MyList.InteractiveChange
   lcListValue=This.ListItem(This.ListItemId,2)
   If File(lcListValue)
       Thisform.MyImage.Picture=lcListValue
       Thisform.MyImage.Visible=.T.
   Else
       Thisform.MyImage.Visible=.F.
   Endif
Endproc 

Procedure drawIcons
   This.MyShape.Visible=.T.
   This.MyShape.Visible=.F.
   Set Cursor Off
   Inkey(0.1,'H')
   Set Cursor On
   Local lcExe,hApp,lnIndex,hIcon,X,Y,dX,dY
   lcExe=Alltrim(This.txt.Value)
   If Not File(lcExe)
        Wait Window "文件 "+lcExe+" 不存在" Nowait
   Endif

   hApp=GetModuleHandle(0)
   Store 40 To dX,dY
   Y=56
   X=dX

   lnIndex=0
    Do While .T.
       hIcon=ExtractIcon(hApp,lcExe,lnIndex)
       If hIcon=0
            Exit
       Endif        

       This._draw(hIcon,X,Y)
       lnIndex=lnIndex+1
       This.hIcon2Object(hIcon,lnIndex)
       =DestroyIcon(hIcon)

       X=X+dX
       If X>This.Width-80-dX*2
           X=dX
           Y=Y+dY
       Endif
   Enddo
Endproc


Protected Procedure _draw(hIcon,X,Y)
   Local HWnd,hdc
   HWnd=GetFocus()
   hdc=GetDC(HWnd)    && this form
   DrawIcon(hdc,X,Y,hIcon)
   =ReleaseDC(HWnd,hdc)
Endproc 

Procedure selectFile
   Local lcFile
   lcFile=This._GetFile()
   If Len(lcFile)<>0
       This.txt.Value=lcFile
       This.cmd.Click
   Endif
Endproc

Protected Function _GetFile
   Local lcResult,lcPath, lcStoredPath
   lcPath=Sys(5)+Sys(2003)
   lcStoredPath=Fullpath(This.txt.Value)
   lcStoredPath=Substr(lcStoredPath,1,Rat(Chr(92),lcStoredPath)-1)
   Set Default To (lcStoredPath)
   *lcResult=Getfile("exe,dll,cpl,scr,ico,icl,cur,ocx:exe,dll,cpl,scr,ico,icl,cur,ocx;可执行文件(*.exe):exe;动态链接库(*.dll):dll;控制面板扩展项(*.cpl):cpl;屏幕保护程序(*.scr):scr;图标文件(*.ico):ico;图标文件库(*.icl):icl;光标文件(*.cur):cur;控件(*.ocx):ocx","","",0,"请选择exe/dll/cpl/scr/ico/icl/cur/ocx文件")
   lcResult=Getfile("exe,dll,cpl,scr,ico,icl,cur,ocx:exe,dll,cpl,scr,ico,icl,cur,ocx;*.exe:exe;*.dll:dll;*.cpl:cpl;*.scr:scr;*.ico:ico;*.icl:icl;*.cur:cur;*.ocx:ocx","","",0,"请选择exe/dll/cpl/scr/ico/icl/cur/ocx文件")
   If Inlist(Justext(lcResult),"EXE","DLL","CPL","SCR","ICO","ICL","CUR","OCX")
       Set Default To (lcPath)
       Return Lower(lcResult)
   Else
       Set Default To (lcPath)
       Return ""
   Endif
Endfunc

Procedure Decl
    Declare Integer GetFocus In user32
    Declare Integer GetDC In user32 Integer HWnd
    Declare Integer GetModuleHandle In kernel32 Integer lpModuleName
    Declare Integer ReleaseDC In user32 Integer HWnd,Integer hdc
    Declare Integer LoadIcon In user32 Integer hInstance,IntegerlpIconName
    Declare Integer ExtractIcon In shell32 Integer hInst,String lpszExeFileName,Integer lpiIcon
    Declare Short DrawIcon In user32 Integer hDC,Integer X,Integer Y,Integer hIcon
    Declare Integer GetModuleFileName In kernel32 Integer hModule,String @lpFilename,Integer nSize
    Declare Short DestroyIcon In user32 Integer hIcon
    Declare Integer OleCreatePictureIndirect In oleaut32 String @lpPictDesc,String @riid,Long fOwn,Object @lplpvObj
Endproc

Protected Function getVFPmodule
    Local lpFilename
    lpFilename=Space(250)
    lnLen=GetModuleFileName(0,@lpFilename,Len(lpFilename))
    Return Left (lpFilename,lnLen)
Endfunc 

Procedure hIcon2Object(lhIcon,lnIcoNum)
   #Define PICTYPE_ICON 3
   #Define GUID_Icon 0h8109F87B32BF1A108BBB00AA00300CAB    && 0h0004020000000000C000000000000046

   Local lcPictDesc,lqGuid,loIconObj
   lcPictDesc=BinToC(16,"4RS")+;    && Size of Structure
   BinToC(PICTYPE_ICON,"4RS")+;     && Type of Image
   BinToC(lhIcon,"4RS")+;           && Image Handle
   BinToC(0,"4RS") 

   lqGuid=GUID_Icon
   loIconObj=0
   OleCreatePictureIndirect(@lcPictDesc,@lqGuid,1,@loIconObj) 

    If Vartype(loIconObj)='O'
       lcIconFile="c:\icon_tmp\"+Transform(lnIcoNum)+".ico"&& 生成 ico 文件到 c:\icon_tmp\,但是生成的 .ico 文件是16色
       * 现在的 Exe 所带图标一般都是标准图标组，就是16x16、32x32、48x48三组，每组又分为16色、256色、32位色三种。
       * 用这种方法是有局限性的，就是不能指定到底要提取哪个色深的图标。完美解决方案：请参考 dkfdtf 版主的博客：提取可执行文件中图标
       If SavePicture(loIconObj,lcIconFile)
           This.MyList.AddListItem(Transform(lnIcoNum)+".ico",lnIcoNum,1)
           This.MyList.AddListItem(lcIconFile,lnIcoNum,2)
       Endif
   Endif
Endfunc 

Procedure cmd.Click
   Clear Resources
   Thisform.MyList.Clear
   Erase "c:\icon_tmp\*.*"
   Thisform.drawIcons
   Thisform.MyList.ListItemId=1
   Thisform.MyList.InteractiveChange()
Endproc

Procedure cmdFile.Click
   Thisform.selectFile
Endproc

Enddefine