*!* vfp9.0通过WebBrowser控件获取QQ新闻标题及链接
*!*  -------------------------------------------
*!*     作者：十豆三
*!*     日期：2011-09-17
*!*  vfp版本：vfp9.0
*!* 控件名称： Microsoft Web Browser(Microsoft Internet Controls)
*!* 控件版本：1.1
*!*   ProgID：Shell.Explorer.2
*!* 文件位置： C:\WINDOWS\system32\ieframe.dll
*!* 文件版本：8.00.6001.19098 (IE8.0)


Public oform1


oform1=Newobject("form1")
oform1.Show
Return
 

Define Class form1 As Form


    Top = 11
    Left = 26
    Height = 600
    Width = 800
    DoCreate = .T.
    Caption = "Form1"
    Name = "Form1"


    Add Object olecontrol1 As OleControl With;
        Top = 0, ;
        Left = 0, ;
        Height = 468, ;
        Width = 800, ;
        Name = "Olecontrol1", ;
        OleClass = "Shell.Explorer.2", ;
        OleLCID = 1033


    Add Object command1 As CommandButton With;
        Top = 521, ;
        Left = 677, ;
        Height = 25, ;
        Width = 121, ;
        Caption = "取得新闻标题和URL", ;
        Name = "Command1"


    Add Object grid1 As Grid With;
        DeleteMark = .F., ;
        Height = 129, ;
        Left = 2, ;
        ReadOnly = .T., ;
        Top = 470, ;
        Visible = .F., ;
        Width = 673, ;
        Name = "Grid1"


    Procedure Load
        _vfp.AutoYield=.F.
    Endproc


    Procedure Unload
        _vfp.AutoYield=.T.
    Endproc
 

    Procedure olecontrol1.Init
        This.Navigate("http://roll.news.qq.com/")
    Endproc
 

    Procedure command1.Click
        lcMyCaption=This.Caption
        This.Caption='正在获取......'
        This.Enabled=.F.
        Create Cursor T1 (类别 C(6),新闻标题 C(254),新闻链接 C(254),时间 C(11))
        Thisform.Olecontrol1.Document.getElementById("auto_refresh").parentNode.className='check checked'
        Thisform.Olecontrol1.Document.parentWindow.Execscript('AutoRefresh()')&& 取消自动刷新
        lnTotalPages=Val(Thisform.Olecontrol1.Document.getElementById("totalPage").Value)&& 取得部页数
        If Messagebox('共有'+Transform(lnTotalPages)+'页新闻，点<是>取得所有页的新闻，点击<否>只取当第1页的新闻。',4+32+256,'信息提示')=7
            lnTotalPages=1
        Endif
        For m.lnJ=1 To lnTotalPages&& 循环所有页，每页50条新闻，如果只需TOP N条，修改此处。
            If m.lnJ>1
                Thisform.Olecontrol1.Document.parentWindow.Execscript('nextPage()')&& 下一页
            Endif
            Do While .T.
                If Thisform.Olecontrol1.Document.getElementById("artContainer").innerhtml<>'<DIV class=loading>正在查询请稍候……</DIV>'
                    Exit
                Endif
                Inkey(0.2,"H") &&防止程序失去响应
            Enddo
            lcListStr=Thisform.Olecontrol1.Document.getElementById("artContainer").innerhtml&& 取得当前页新闻内容
            lnLIs=Occurs('<LI>',lcListStr)
            For m.lnI=1 To lnLIs
                Insert Into T1 Values(Strextract(lcListStr,'t-tit>','</SPAN><A',m.lnI),Strextract(lcListStr,'"undefined">','</A>',m.lnI),;
                                        Strextract(lcListStr,'href="','" target',m.lnI),Strextract(lcListStr,'t-time>','</SPAN><SPAN',m.lnI))
            Endfor
        Endfor
        Locate
        Thisform.Grid1.RecordSource='T1'
        Thisform.Grid1.Visible=.T.
        Thisform.Grid1.AutoFit()
        Thisform.Grid1.Refresh
        This.Caption=lcMyCaption
        This.Enabled=.T.
        Messagebox('取得新闻信息完成！'+Chr(10)+Chr(10)+'共取得'+Transform(Reccount('T1'))+'条新闻',64,'信息提示')
    Endproc
 

    Procedure Grid1.Scrolled
        Lparameters nDirection
        This.AutoFit()
    Endproc
 

Enddefine