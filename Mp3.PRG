Player = NEWOBJECT("player") 
READ EVENTS  
*---- 定义多媒体播放器 
DEFINE CLASS player as Session OLEPUBLIC  
  *----   播放歌曲列表 
  oSongList = .F. 
  *----   播放窗口   
  oSongWindow = .F. 
  *----   控制面板 
  oPanel = .F.   
  *---- 释放变量 
  vReleaseVar = 'Player' 
   
  PROCEDURE Init  
     LPARAMETERS tcReleaseVar     
     *---- 设置释放变量 
     *this.vReleaseVar = tcReleaseVar      
      
     this.oSongWindow = NEWOBJECT("SongShow") 
     this.oSongList = NEWOBJECT("SongList")    
     this.oPanel = NEWOBJECT("PlayerPanel")      
     *----设置根  
     this.oSongList.oRoot = this 
     this.oSongWindow.oRoot = this 
     this.oPanel.oRoot = this 
     *---- 设置播放媒体控件 
     this.oSongList.oPlayer = this.oSongWindow.olePlayer 

     this.oSongList.Show() 
     this.oPanel.Stick() 
     this.oPanel.Show() 
  ENDPROC  
   
  PROCEDURE Release 
     CLEAR EVENTS  
     This.oSongList.oRoot = .F. 
     This.oSongWindow.oRoot = .F. 
     This.oPanel.oRoot = .F. 
      
     vReleaseVar = this.vReleaseVar 
     RELEASE (vReleaseVar) 
      
   ENDPROC  
ENDDEFINE  

*----   播放窗口   
DEFINE CLASS SongShow as BaseForm  
      *---- 引用根对象 
      oRoot = .F. 
       *---- 增加播放控件 ,属于微软的播放控件 
      ADD OBJECT cmdFull As CommandButton WITH Caption = "全屏\<F" ,AutoSize = .T. ,SpecialEffect = 2 
ADD OBJECT olePlayer AS olecontrol WITH oleclass = 'mediaplayer.mediaplayer.1' ,OleLCID = 1033 ,EnableContextMenu = .F. 
*---- 将播放界面设置为独立窗口 
showwindow = 2 
*---- 调整播放器控件的尺寸 
PROCEDURE init 
this.olePlayer.width = this.Width 
this.olePlayer.Top = 20 
this.olePlayer.height = this.Height - this.olePlayer.Top 

this.cmdFull.Left = this.Width - this.cmdFull.Width 
ENDPROC 
*---- 调整播放器控件的尺寸 
PROCEDURE Resize 
this.olePlayer.width = this.Width 
this.olePlayer.height = this.Height - this.olePlayer.Top 

this.cmdFull.Left = this.Width - this.cmdFull.Width 
ENDPROC 

PROCEDURE cmdFull.Click 
ThisForm.oRoot.oPanel.Hide 
ThisForm.olePlayer.DisplaySize = 3 
ENDPROC 
*---- 当每首音乐播放完毕后，自动进入下一首 
*---- 判断播放的状态 
PROCEDURE olePlayer.EndOfStream 
LPARAMETERS Result 
*---- 歌曲播放完毕 
IF RECNO("SongList") # RECCOUNT("SongList") 
SKIP IN SongList 
ELSE 
GO 1 IN SongList 
ENDIF 
this.fileName = ALLTRIM(SongList.FileName) 
ENDPROC 
*---- 设置根对象引用释放 
PROCEDURE Destroy 
this.oRoot = .F. 
ENDPROC 
ENDDEFINE 

主题：MP3 和 VCD 播放器的源代码.这个例子供面向对象编程参考.(二) 
发信人: coolyylu(GoodDay)
整理人: hunter__fox <自由的风>
播放列表对象: 

*----   定义播放歌曲列表 
DEFINE CLASS SongList as BaseForm  
     oPlayer = .F. 
     cDir = "" 
     oRoot = .F.    
     ShowWindow = 2     
     nDisTitle = 15 
     ADD OBJECT cmdHelp As CommandButton WITH SpecialEffect = 2 ,Caption = '？' ,Width = 15 
     ADD OBJECT PROTECTED lstList as listbox WITH SpecialEffect = 1 
      
     PROCEDURE init  
        this.lstList.width = this.Width  
        this.lstList.height = this.Height - This.nDisTitle 
        this.lstList.Top = This.nDisTitle   
         
        this.cmdHelp.Left = This.Width - this.cmdHelp.Width 
        this.cmdHelp.Height = This.nDisTitle 
        IF NOT FILE("SongList.dbf") 
            CREATE TABLE SongList FREE ( Name C(50) ,FileName C(200) ,Song M) 
         ENDIF  
         IF NOT FILE("Scheme.dbf") 
            CREATE TABLE Scheme FREE (Name c(50) ,FileName c(200))          

   
            IF USED("Scheme") 
               USE IN Scheme  
            ENDIF  
         ENDIF                  
     ENDPROC  
   
     *---- 改变窗口尺寸的时候 
     PROCEDURE Resize  
        this.lstList.width = this.Width  
        this.lstList.height = this.Height - This.nDisTitle 
         
        this.cmdHelp.Left = This.Width - this.cmdHelp.Width 
         
        IF TYPE('This.oRoot.oPanel') = 'O' 
         IF This.oRoot.oPanel.lStick 
            This.oRoot.oPanel.Stick() 
         ENDIF       
      ENDIF 
     ENDPROC  
      
     PROCEDURE LoadSongList 
        LPARAMETERS tcDir 
         IF NOT USED("SongList") 
            USE SongList IN 0 EXCLUSIVE  
         ENDIF    
         SELECT SongList 
         *----获取目录 
         IF EMPTY(tcDir) 
            this.cDir = GETDIR() 
         ELSE  
            this.cDir = tcDir 
         ENDIF  
         *---- 如果目录不存在 
         IF NOT DIRECTORY(this.cDir) 
            RETURN 0 
         ENDIF  
         IF EMPTY(this.cDir) 
            RETURN 0 
         ENDIF  
         IF EMPTY(this.cDir) 
             USE IN SongList          
             RETURN  
         ENDIF   
         this.cDir =  ADDBS(this.cDir) 
         nCount = ADIR(aFile ,this.cDir + "*.mp3","A")          
         FOR i = 1 TO nCount              
            INSERT INTO SongList (Name , FileName ,Song) Values(JUSTSTEM(JUSTFNAME(aFile[i,1])) ,this.cdir + aFile[i,1] ,"") 
         ENDFOR  
          
         nCount = ADIR(aFile ,this.cDir + "*.dat","A") 
          
         FOR i = 1 TO nCount              
            INSERT INTO SongList (Name , FileName ,Song) Values(JUSTSTEM(JUSTFNAME(aFile[i,1])) ,this.cdir + aFile[i,1] ,"") 
         ENDFOR               
         WITH this.lstList 
              .RowSourceType = 6 
              .RowSource = "SongList.Name" 
              .Visible = .T. 
         ENDWITH          
         this.lstList.Refresh() 
     ENDPROC      
     *---- 点击歌曲列表时播放歌曲 
     PROCEDURE lstList.click  
         *---- 播放当前文件  
         thisform.play() 
     ENDPROC  
     *---- 播放文件 
     PROCEDURE Play 
        IF NOT USED("SongList") 
           RETURN 0 
        ENDIF  
        IF NOT FILE(ALLTRIM(SongList.FileName)) 
           MESSAGEBOX("检查路径" + JUSTPATH(ALLTRIM(SongList.FileName)) + ; 
                     "是否存在文件" +  JUSTFNAME(ALLTRIM(SongList.FileName)) ,16 ,"错误") 
           RETURN 0 
        ENDIF  
        thisform.oPlayer.FileName = ALLTRIM(SongList.FileName) 
         DO CASE  
         CASE INLIST(JUSTEXT(ALLTRIM(SongList.FileName)) ,"DAT" ,"MPG") 
              thisform.oPlayer.parent.show() 
         OTHERWISE  
              thisform.oPlayer.parent.hide() 
         ENDCASE       
     ENDPROC  
     *---- 右键歌曲列表框时 
     PROCEDURE lstList.MouseUP 
        LPARAMETERS nButton ,nShift ,nX ,nY 
         IF nButton = 2  
          IF NOT ThisForm.oRoot.oPanel.lStick 
             ThisForm.oRoot.oPanel.Show(thisform.Top + nY ,thisform.Left + nX) 
          ELSE  
             ThisForm.oRoot.oPanel.Show() 
          ENDIF  
         ENDIF  
     ENDPROC  
      
     *---- 帮助按钮 ，简单说明用法 
     PROCEDURE cmdHelp.Click 
          
      
     ENDPROC  
     *---- 删除歌曲 
     PROCEDURE DelSong 
        SELECT SongList 
        DELETE  
        PACK  
     ENDPROC  
        
     PROCEDURE ReName      
        IF NOT USED("SongList") 
           RETURN 0 
        ENDIF  
        This.oRoot.oSongList.Show() 
        oReName = NEWOBJECT("GetName") 
        oReName.SetName(ALLTRIM(SongList.Name)) 
        oReName.Show() 
        IF NOT EMPTY(oReName.NewName) 
           REPLACE Name WITH oReName.NewName 
        ENDIF  
        oReName.Release 
     ENDPROC  
     *---- 加载MTV 或VCD故事片 
     PROCEDURE LoadMTV 
         DIMENSION aCDROM[1] 
          
         nCD = This.GetCDROM(@aCDROM) 
         FOR m.i = 1 TO nCD 
             cMTVDIR = aCDROM[nCD] + 'MPEGAV\' 
             IF DIRECTORY(cMTVDIR) 
                THISFORM.LoadSongList(cMTVDIR) 
             ENDIF  
         ENDFOR  
     ENDPROC  
     *---- 获得CDROM的光驱符号 
     PROCEDURE GetCDROM 
         LPARAMETERS taCDROM 
         nCDROM = 0 
         FOR nDrive = 68 TO 68 + 22  
             IF DRIVETYPE(CHR(nDrive)) = 5 
                nCDROM = nCDROM + 1 
                DIMENSION taCDROM[nCDROM] 
                taCDROM[nCDROM] = CHR(nDrive) + ":\" 
             ENDIF  
         ENDFOR  
         *---- 返回光驱驱动器的个数 
         RETURN nCDROM 
     ENDPROC  
     *---- 设置根对象引用释放 
     PROCEDURE Destroy 
       this.oRoot = .F. 
       IF USED("SongList") 
           SELECT SongList  
           ZAP  
           USE IN SongList 
       ENDIF   
     ENDPROC  
     *---- 当位置改变的时候 ,如果操作面板处于粘附的状态 ,则操作面板随播放列

*!*	表窗口移动 
     PROCEDURE Left_Assign 
        LPARAMETERS nLeft        
        This.Left = nLeft 
         
        IF TYPE('This.oRoot.oPanel') = 'O' 
         IF This.oRoot.oPanel.lStick 
            This.oRoot.oPanel.Stick() 
         ENDIF       
        ENDIF  
     ENDPROC  
     *---- 当位置改变的时候 ,如果操作面板处于粘附的状态 ,则操作面板随播放列

*!*	表窗口移动 
     PROCEDURE Top_Assign 
      LPARAMETERS nTop 
      This.Top = nTop 
       
      IF TYPE('This.oRoot.oPanel') = 'O' 
         IF This.oRoot.oPanel.lStick 
            This.oRoot.oPanel.Stick() 
         ENDIF       
      ENDIF 
     ENDPROC        
     *---- 加载喜爱歌集 
     PROCEDURE LoadFavorSong 
         ThisForm.oRoot.oSongList.Show() 
         oFavorSong = NEWOBJECT("ObjectList") 
         oFavorSong.SetName("Name" ,"FileName" ,"Scheme" ,"选择喜爱歌集") 
         oFavorSong.Show() 
         IF NOT EMPTY(oFavorSong.ListName) 
            IF NOT USED("SongList") 
               USE SongList IN 0 EXCLUSIVE  
            ENDIF  
            SELECT SongList 
            IF FILE(oFavorSong.ListName) 
               APPEND FROM (oFavorSong.ListName)    
               WITH this.lstList 
              .RowSourceType = 6 
              .RowSource = "SongList.Name" 
              .Visible = .T. 
              ENDWITH          
         this.lstList.Refresh()       
            ELSE 
               MESSAGEBOX("歌集不存在" ,"信息") 
            ENDIF  
         ENDIF  
         oFavorSong.Release() 
     ENDPROC  
     *---- 保存喜爱歌集 
     PROCEDURE SaveFavorSong 
         ThisForm.oRoot.oSongList.Show()         
          cFavorDir = "c:\mysong\" 
          *---- 存放喜爱歌曲集的目录           
          IF NOT DIRECTORY(cFavorDir) 
             MD (cFavorDir) 
          ENDIF  
          *---- 让用户输入喜欢的歌曲集的名称 
         
          oSaveFile = NEWOBJECT("GetName") 
          oSaveFile.SetName("喜爱" + TTOC(DATETIME()) ,"保存歌集:") 
          oSaveFile.Show() 
          IF NOT EMPTY(oSaveFile.NewName) 
           IF NOT USED("Scheme") 
             USE Scheme IN 0 EXCLUSIVE  
          ENDIF  
          SELECT Scheme  
          cFileName = cFavorDir + FORCEEXT(SYS(2015) ,"dbf") 
          INSERT INTO SCHEME(Name ,FileName) VALUES(oSaveFile.NewName ,cFileName) 
          USE IN Scheme  
          *---- 拷贝喜爱的歌曲集 
              SELECT SongList  
              COPY TO (cFileName) 
          ENDIF  
          oSaveFile.Release()            
     ENDPROC  
ENDDEFINE  
主题：MP3 和 VCD 播放器的源代码.这个例子供面向对象编程参考.(三) 
发信人: coolyylu(GoodDay)
整理人: hunter__fox   <自由的风>
控制面板: 

DEFINE CLASS PlayerPanel as BaseForm  
   *---- 边框 
   BorderStyle = 0 
   BorderColor = RGB(0 ,0 ,255) 
   BorderWidth = 20  
   *---- 根对象 
   oRoot = .F. 
   *---- 是否粘附 
   lStick = .T. 
   *---- 自动居中 
   AutoCenter = .T. 
   *---- 顶层表单 
   ShowWindow = 2 
   AlwaysOnTop = .T. 
   *----增加控件 
   ADD OBJECT cmdStick as CommandButton WITH Caption = ">" ,SpecialEffect = 2 ,Width = 8 ,Height = 9 ,FontSize = 7 ,ToolTipText = '粘附' 
   ADD OBJECT cmdHide as CommandButton WITH Caption = "-" ,SpecialEffect = 2 ,Width = 8 ,Height = 9 ,FontSize = 7 
   ADD OBJECT cmdOpen as CommandButton WITH Caption = "增加" ,SpecialEffect = 2 ,AutoSize = .T.  
   ADD OBJECT cmdDel as CommandButton WITH Caption = "删除" ,SpecialEffect = 2 ,AutoSize = .T.  
   ADD OBJECT cmdPlay as CommandButton WITH Caption = "播放" ,SpecialEffect = 2 ,AutoSize = .T.  
   ADD OBJECT cmdMTV as CommandButton WITH Caption = "MTVP" ,SpecialEffect = 2 ,AutoSize = .T.  
   ADD OBJECT cmdLoadSongList as CommandButton WITH Caption = "加载" ,SpecialEffect = 2 ,AutoSize = .T.  
   ADD OBJECT cmdSave as CommandButton WITH Caption = "保存" ,SpecialEffect = 2 ,AutoSize = .T.  
   ADD OBJECT cmdReName as CommandButton WITH Caption = "改名" ,SpecialEffect = 2 ,AutoSize = .T.  
   ADD OBJECT cmdExit as CommandButton WITH Caption = "退出" ,SpecialEffect = 2 ,AutoSize = .T.  
    
   *---- 添加歌曲列表 
   PROCEDURE cmdOpen.Click 
      IF NOT  THISFORM.lStick 
       thisform.Hide() 
      ENDIF  
       thisform.oRoot.oSongList.LoadSongList() 
   ENDPROC  
   *---- 删除歌曲 
   PROCEDURE cmdDel.Click 
      IF NOT  THISFORM.lStick 
       thisform.Hide() 
      ENDIF  
      thisform.oRoot.oSongList.DelSong() 
   ENDPROC  
   *---- 播放歌曲 
   PROCEDURE cmdPlay.Click 
      IF NOT  THISFORM.lStick 
       thisform.Hide() 
      ENDIF  
      thisform.oRoot.oSongList.Play() 
   ENDPROC  
    
   *---- 退出系统 
   PROCEDURE cmdExit.Click 
       thisform.oRoot.Release        
   ENDPROC  
    
   PROCEDURE cmdReName.Click 
       thisform.oRoot.oSongList.ReName() 
   ENDPROC  
    
   PROCEDURE cmdHide.Click 
       ThisForm.Hide() 
   ENDPROC  
   *---- 粘贴在歌曲列表的底端 
   PROCEDURE cmdStick.Click 
       IF this.Caption = '>' 
          this.Caption = '<' 
ThisForm.lStick = .F. 
This.ToolTipText = '粘附' 
ELSE 
this.Caption = '>' 
          ThisForm.lStick = .T.     
          This.ToolTipText = '离开'          
       ENDIF  
       IF ThisForm.lStick = .T.              
          ThisForm.Stick() 
       ENDIF  
   ENDPROC  
   *---- 加载歌曲 
   PROCEDURE cmdLoadSongList.Click 
       ThisForm.oRoot.oSongList.LoadFavorSong() 
   ENDPROC  
   PROCEDURE cmdSave.Click 
       ThisForm.oRoot.oSongList.SaveFavorSong()           
   ENDPROC  
   *---- 播放MTV 
   PROCEDURE cmdMTV.Click 
       ThisForm.oRoot.oSongList.LoadMTV()    
       ThisForm.cmdPlay.Click() 
   ENDPROC  
    
   PROCEDURE init  
       this.Position() 
   ENDPROC  
   *---- 调整位置 
   PROCEDURE Position        
        
       this.cmdOpen.Left = 0  
       this.cmdOpen.Top = this.cmdHide.Top + this.cmdHide.Height 
        
       this.cmdDel.Left = this.cmdOpen.Width 
       this.cmdDel.Top = this.cmdOpen.Top 
        
       this.cmdPlay.Left = 0 
       this.cmdPlay.Top =  this.cmdOpen.Top + this.cmdOpen.Height  
        
       this.cmdMTV.Top =  this.cmdOpen.Top + this.cmdOpen.Height  
       this.cmdMTV.Left = this.cmdPlay.Width  
        
       this.cmdLoadSongList.Top = this.cmdMTV.Top + this.cmdMTV.Height 
       this.cmdLoadSongList.Left = 0 
        
       this.cmdSave.Top = this.cmdLoadSongList.Top 
       this.cmdSave.Left = this.cmdLoadSongList.Width 
        
       this.cmdReName.Top = this.cmdLoadSongList.Top + this.cmdLoadSongList.Height 
       this.cmdReName.Left = 0 
        
       this.cmdExit.Top = this.cmdReName.Top  
       this.cmdExit.Left = this.cmdReName.Width 
        
       this.Width = this.cmdOpen.Width  + this.cmdDel.Width 
       this.Height = this.cmdHide.Height + this.cmdOpen.Height  + this.cmdPlay.Height + this.cmdLoadSongList.Height + this.cmdReName.Height 
        
       this.cmdHide.Left = This.Width - This.cmdHide.Width 
   ENDPROC  
    
   PROCEDURE SHOW 
       LPARAMETERS nTop ,nLeft 
       IF VARTYPE(nTop) = 'N' 
       this.Left = nLeft 
       this.Top = nTop        
       ENDIF  
   ENDPROC  
    
    
   *---- 设置根对象引用释放 
   PROCEDURE Destroy 
       this.oRoot = .F. 
   ENDPROC  
      
   *---- 粘附 
   PROCEDURE Stick 
       This.Top = This.oRoot.oSongList.Height + This.oRoot.oSongList.Top - This.Height  
       This.Left = This.oRoot.oSongList.Width + This.oRoot.oSongList.Left - This.Width - 15          
   ENDPROC   
ENDDEFINE  
 
主题：MP3 和 VCD 播放器的源代码.这个例子供面向对象编程参考(四) 
发信人: coolyylu(GoodDay)
整理人: hunter__fox    <自由的风> 

*---- 定义修改歌曲名称表单 
DEFINE CLASS GetName as BaseForm  
    NewName = '' 
    BorderStyle = 1 
    *---- 模式     
    DeskTop = .F. 
    WindowType = 1 
    ShowWindow = 1 
    MinButton = .F. 
    MaxButton = .F. 
    *---- 标题宽度 
    nDisTitle = 15 
    ADD OBJECT shpBelow As Shape 
    ADD OBJECT PROTECTED txtNewName As TextBox WITH Width = 150 ,SpecialEffect = 1 
    ADD OBJECT cmdOk As CommandButton WITH Caption = "修改" ,AutoSize = .T. ,SpecialEffect = 2 
    ADD OBJECT cmdCancel As CommandButton WITH Caption = "取消" ,AutoSize = .T. ,Cancel = .T. ,SpecialEffect = 2 
    PROCEDURE Init 
       This.Position() 
    ENDPROC  
     
    PROCEDURE SetName 
       LPARAMETERS tcName ,tcCaption 
       IF EMPTY(tcCaption) 
          tcCaption = "ReName the song: " 
       ENDIF  
       ThisForm.txtNewName.Value = tcName 
       ThisForm.Caption = tcCaption +  tcName 
       ThisForm.Print(ThisForm.Caption) 
    ENDPROC  
    PROCEDURE cmdOk.Click 
        ThisForm.NewName = ALLTRIM(thisform.txtNewName.Value) 
        thisform.Hide()        
    ENDPROC  
     
    PROCEDURE cmdCancel.Click 
        ThisForm.NewName = "" 
        ThisForm.Hide() 
    ENDPROC  
    PROCEDURE Position 
       ThisForm.txtNewName.Top = ThisForm.nDisTitle 
       ThisForm.cmdOk.Top = ThisForm.txtNewName.Top + ThisForm.txtNewName.Height + 10 
       ThisForm.cmdCancel.Top = ThisForm.txtNewName.Top + ThisForm.txtNewName.Height + 10 
        
       ThisForm.Width = this.txtNewName.Width  
       ThisForm.Height = ThisForm.txtNewName.Top + ThisForm.txtNewName.Height + 10 + ThisForm.cmdOk.Height + 10 
       ThisForm.cmdOk.Left = ThisForm.Width - ThisForm.cmdOk.Width - 10 
       ThisForm.cmdCancel.Left = 10 
        
       This.shpBelow.Top = ThisForm.txtNewName.Top + ThisForm.txtNewName.Height 
       This.shpBelow.Height = This.Height - This.shpBelow.Top 
       This.shpBelow.Width = This.Width  
    ENDPROC      
ENDDEFINE  
*---- 定义列表 
DEFINE CLASS ObjectList as BaseForm  
    *---- 返回的内容 
    ListName = '' 
    *---- 对应的表 
    ListTable = '' 
    *---- 选择内容的字段 
    FieldName = '' 
    *---- 返回内容的字段 
    ReturnFieldName = '' 
    BorderStyle = 1 
    *---- 模式     
    DeskTop = .F. 
    WindowType = 1 
    ShowWindow = 1 
    MinButton = .F. 
    MaxButton = .F. 
     
    *----标题距离 
    nDisTitle = 15 
    ADD OBJECT shpBelow As Shape 
    ADD OBJECT PROTECTED lstSelect As ListBox WITH Width = 150 ,SpecialEffect = 1 ,RowSourceType = 6 
    ADD OBJECT cmdOk As CommandButton WITH Caption = "确定" ,AutoSize = .T. ,SpecialEffect = 2 
    ADD OBJECT cmdCancel As CommandButton WITH Caption = "取消" ,AutoSize = .T. ,Cancel = .T. ,SpecialEffect = 2 
     
    PROCEDURE Init 
       This.Position() 
    ENDPROC  
     
    PROCEDURE SetName 
       LPARAMETERS tcFieldName ,tcReturnFieldName ,tcTable ,tcCaption 
        
       IF NOT USED(tcTable) 
          USE (tcTable) IN 0 
       ENDIF  
       SELECT (tcTable)        
        
       *---- 设置参数 
       This.ReturnFieldName = tcReturnFieldName  
       This.FieldName = tcFieldName  
       This.ListTable = tcTable 
        
       IF EMPTY(tcCaption) 
          tcCaption = "Select the your favorite song album:" 
       ENDIF  
       ThisForm.lstSelect.RowSource = FORCEEXT(ThisForm.ListTable ,ThisForm.FieldName) 
       ThisForm.lstSelect.Refresh()       
       ThisForm.Caption = tcCaption 
       ThisForm.Print(ThisForm.Caption) 
    ENDPROC  
    PROCEDURE cmdOk.Click 
        ThisForm.ListName = EVALUATE(FORCEEXT(ThisForm.ListTable ,ThisForm.ReturnFieldName)) 
        thisform.Hide()        
    ENDPROC  
     
    PROCEDURE cmdCancel.Click 
        ThisForm.ListName = "" 
        ThisForm.Hide() 
    ENDPROC  
    PROCEDURE Position 
       ThisForm.lstSelect.Top = ThisForm.nDisTitle 
       ThisForm.cmdOk.Top = ThisForm.lstSelect.Top + ThisForm.lstSelect.Height + 10 
       ThisForm.cmdCancel.Top = ThisForm.lstSelect.Top + ThisForm.lstSelect.Height + 10 
        
       ThisForm.Width = this.lstSelect.Width  
       ThisForm.Height = ThisForm.lstSelect.Top + ThisForm.lstSelect.Height + 10 + ThisForm.cmdOk.Height + 10 
       ThisForm.cmdOk.Left = ThisForm.Width - ThisForm.cmdOk.Width - 10 
       ThisForm.cmdCancel.Left = 10 
        
       This.shpBelow.Width = This.Width  
       This.shpBelow.Top = ThisForm.lstSelect.Top + ThisForm.lstSelect.Height 
       This.shpBelow.Height = This.Height - This.shpBelow.Top 
                
    ENDPROC      
     
    PROCEDURE Destroy 
       IF USED(This.ListTable) 
          USE IN (This.ListTable) 
       ENDIF  
    ENDPROC  
ENDDEFINE  
*---- 基类表单 
DEFINE CLASS BaseForm as Form  
     TitleBar = 0 
     DeskTop  = .T.      
     ForeColor = RGB(255 ,255 ,255) 
     BackColor = RGB(0 ,0 ,255) 
     nDisTitle = 20 
      *---- 鼠标移动 
   PROCEDURE MouseDown 
     LPARAMETERS nButton ,nShift ,nXCoord ,nYCoord 
    vOp1 = 274 
vOp2 = 0xF012 
DECLARE INTEGER ReleaseCapture IN WIN32API 
DECLARE INTEGER SendMessage IN WIN32API INTEGER, INTEGER, INTEGER, INTEGER 
vRes = ReleaseCapture() 
vRes = SendMessage(thisform.HWnd, vOp1, vOp2,0) 
CLEAR DLLS  
   ENDPROC 
ENDDEFINE  
 

