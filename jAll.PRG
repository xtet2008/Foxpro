***************************************
*0 onlyVFPapplication 判断应用程序是否已经打开
***************************************
Procedure onlyVFPapplication
	Local oWbemLocator, oWMIService, oItem, oItems
	oWbemLocator = Createobject("WbemScripting.SWbemLocator")
	oWMIService = oWbemLocator.ConnectServer(".", "root/cimv2")
	oItems = oWMIService.ExecQuery("SELECT * FROM Win32_Process")
	nLcisOnly=0
	For Each oItem In oItems
		If "wonders.exe"==Alltrim(oItem.Name)
			nLcisOnly=nLcisOnly+1
		Endif
		*? oItem.ProcessId,oItem.Name,oItem.ExecutablePath
		*依次是：进程ID，进程Name，进程文件路径
	Endfor
	If nLcisOnly>0
		Quit
	Endif
	Release oWbemLocator, oWMIService, oItems, oItems
Endproc

***************************************
*1  doform 表单只运行一次
***************************************
Procedure doform
	Parameters cFname
	If Pcount()<>1 Or Vartype(cFname)<>"C"
		Messagebox("参数错误!",16,"温馨提示")
		Return
	Endif
	If  .Not. Empty(cFname)
		If Wexist(cFname)

			Activate Window &cFname.
			Return .F.
		Else
			Do Form &cFname.
		Endif
	Endif
Endproc

***************************************
*6  右击弹出式菜单
***************************************
Procedure  RightMemu
	*para oREF
	Define Popup rmemu SHORTCUT Relative From Mrow(),Mcol()
	Define Bar _Med_undo Of rmemu Prompt "撤消"
	Define Bar 3 Of rmemu Prompt "\-"
	Define Bar _Med_cut Of rmemu Prompt "剪切"
	Define Bar _Med_copy Of rmemu Prompt "复制"
	Define Bar _Med_paste Of rmemu Prompt "粘贴"
	Define Bar _Med_clear Of rmemu Prompt "删除"
	Define Bar 8 Of rmemu Prompt "\-"
	Define Bar _Med_slcta Of rmemu Prompt "全选"
	Activate Popup rmemu
Endproc

**********************************
*8调用日期控件
**********************************
Procedure getDate
	Local wdTime,wdCoform
	wdCoform=Createobject("tdate")
	wdCoform.Show()
Endproc
**********************************
*9调用消息
**********************************
Procedure WdMess
	Parameters Emess,Tmess,nPic
	Do Form wdmessbox With Emess,Tmess,nPic
	Return _SWmess
Endproc
**********************************
*10 上传图片到服务器上去
**********************************
Procedure ImageToServer
	mPicture=Getfile("bmp,jpg,gif,ico,png")
	If Empty(mPicture)
		Return ""
	Endif
	Local mPicName
	If .Not.Directory(photo_path)
		WdMess("服务器图片文件夹不存在！","温馨提示",1)
		Return ""
	Endif
	If ' '$mPicture
		mPicture="'"+mPicture+"'"
	Endif
	wondcopy='copy file  '+mPicture +' to '+photo_path
	&wondcopy.
	Return Justfname(mPicture)
	WdMess("图片上传成功!","温馨提示",1)
Endproc
***********************************
*用别名打开表
***********************************
Procedure itusedbf
	Parameters dbfname,DbfAlias,dbfcdx
	&& Eg .  itusedbf(dbfname,dbfalias)
	Local SELECT_WK
	SELECT_WK = Select()
	If !Used(DbfAlias)
		Use (dbfname) In 0 Again Alias (DbfAlias)
	Endif
	Select (DbfAlias)
	If !Empty(dbfcdx)
		Set Order To dbfcdx
	Endif
	Select (SELECT_WK)
Endfunc
***************************************
*清空表
***************************************
Procedure wdZAP
	Lparameter PAULDBF , PAULTYPE  &&PAULDBF 表的名称 、 PAULTYPE清空的类型
	Local PLSELECTWK , PLSETSAFETY
	On Error Return
	PLSELECTWK = Select()
	PLSETSAFETY = Set('SAFETY')
	Set Safety Off
	PAULSTATUS = Used(PAULDBF)
	If  .Not. PAULSTATUS
		Use &PAULDBF. In 0
		Use In &PAULDBF.
		Use &PAULDBF. In 0  Exclusive Again
		Select (PAULDBF)
		If  .Not. Empty(PAULTYPE) And PAULTYPE = 'ZAP'
			Zap
		Else
			Delete All
			Pack
		Endif
	Else
		Select (PAULDBF)
		If  .Not. Empty(PAULTYPE) And PAULTYPE = 'ZAP'
			Zap
		Else
			Delete All
			Pack
		Endif
	Endif
	If  .Not. PAULSTATUS
		Use In &PAULDBF.
	Endif
	Select (PLSELECTWK)
	Set Safety &PLSETSAFETY.
	Return
Endproc
*------

*********************************
*更新临时表
*********************************
Procedure wdD2C
	Parameters dbfTable,cdbfTable
	On Error
	&& 从表dbfTable 把记录复制到表cdbfTable
	If Pcount()=2
		Set Exclusive On
		Select &cdbfTable
		wdZAP(cdbfTable,"ZAP")
		Select &dbfTable.
		Select &dbfTable
		Scatter  Memo To Memvar
		Select &cdbfTable
		Append Blank
		Gather Memo  From Memvar
	Else
		WdMess("参数数目错误!","温馨提示",1)
	Endif
Endproc
*********************************
*更新临时表DTL
*********************************
Procedure DTLwdD2C
	Parameters dbfTable,cdbfTable,vFIELDS,vSetvalue
	On Error
	&& 从表dbfTable 把记录复制到表cdbfTable
	If Pcount()=4
		Set Exclusive On
		Select &cdbfTable
		wdZAP(cdbfTable,"ZAP")
		Select &dbfTable
		Go Top
		Scan Rest While !Eof() And Inkey()<>27
			If Alltrim(&vFIELDS.)==Alltrim(vSetvalue)
				Scatter  Memo To Memvar
				Select &cdbfTable
				Append Blank
				Gather Memo  From Memvar
				=Tableupdate(.T.)
			Endif
		Endscan
	Else
		WdMess("参数数目错误!","温馨提示",1)
	Endif
Endproc
**********************************
*
**********************************

Procedure wdC2D
	Parameters dbfTable,cdbfTable,vSetvalue ,vSetKey
	On Error
	&& 从表dbfTable 把记录复制到表cdbfTable
	&&vSetValue 查找值,vSetKey索引
	If Pcount()<>4
		WdMess("参数数目错误!","温馨提示",1)
		Return
	Endif
	If Empty(vSetvalue ) Or Empty(vSetKey)
		WdMess("查找信息或者索引为空!","温馨提示",1)
		Return
	Endif
	Select &cdbfTable
	Scatter Memo To Memvar
	Select &dbfTable
	Set Order To &vSetKey
	If Empty(vSetvalue )
		WdMess("查找信息为空!","温馨提示",1)
		Retu
	Endif
	Seek (vSetvalue )
	If Found()
		*	If WdMess("记录［"+vSetValue +"］已经存在是否要更新?","温馨提示",3)
		Gather Memo From Memvar
		=Tableupdate(.T.)
		*	Else
		*		Return
		*	ENDIF
	Else
		Append Blank
		Gather Memo  From Memvar
		=Tableupdate(.T.)
		WdMess("记录［"+vSetvalue +"］添加成功!","温馨提示",1)
	Endif
Endproc
****************************************
*限制放大
****************************************
Procedure SizeChang
	If .Not.File("wdSetVar.txt")
		Return
	Endif
	LcYnFileStr=Filetostr("wdSetVar.txt")
	If Empty(LcYnFileStr)
		Return
	Endif
	If Memlines(LcYnFileStr)<5
		Return
	Endif
	If 'type0'$ Mline(LcYnFileStr,1)
		Return
	Endif

	nLeft=Val(Substr(Mline(LcYnFileStr,2),15))
	nTop =Val(Substr(Mline(LcYnFileStr,3),15))
	nWidth=Val(Substr(Mline(LcYnFileStr,4),15))
	nHeigth=Val(Substr(Mline(LcYnFileStr,5),15))
	If _Screen.ActiveForm.formsize=nHeigth
		_Screen.ActiveForm.formsize=_Screen.ActiveForm.formsize1
		_Screen.ActiveForm.Width=581
		_Screen.ActiveForm.Height=474
		_Screen.ActiveForm.Height=474
		_Screen.ActiveForm.AutoCenter=.T.
		Retu
	Endif
	_Screen.ActiveForm.formsize=nHeigth
	_Screen.ActiveForm.Left=nLeft
	_Screen.ActiveForm.Top=nTop
	_Screen.ActiveForm.Width=nWidth
	_Screen.ActiveForm.Height=nHeigth
	Return
Endproc
*****************
*openWonder
*****************
Procedure openWonder
	*判断程序是否打开
	If File("wdopen.dll")
		Quit
	Else
		Strtofile("时间："+Ttoc(Datetime())+Chr(13)+Chr(10)+"用户："+wduser,"wdopen.dll")
	ENDIF
	*****判断能否使用
	IF FILE("wduseYN.dll")
		QUIT
	ENDIF


	*DOFORM("UPDATE")
Endproc

*****************
*close wonder
*****************
Procedure closeWonder
	*结束程序时所有做的任务
	If File("wdopen.dll")
		Delete File wdopen.Dll
	Endif
	If Vartype(wduser)<>"C"
		WdMess("用户ID不存在！","温馨提示",3)
	Endif
	If Used("longo_no")
		Select longo_no
	Else
		Use longo  In 0 Alias longo_no Again
	Endif
	Select longo_no
	Set Order To lon_id
	Seek wduser
	If Found()
		Replace  on_type With "离线"
	Endif
	Use In longo_no
Endproc
********************************
*判断字段是否存在。
********************************
Procedure  FieldsIsEmpty
	Parameter Fields_name
	Fields_name= Upper(Alltrim(Fields_name))
	nFieldsCount = Fcount()
	For nFcount = 1 To nFieldsCount
		If Field(nFcount ) == Fields_name
			Return .T.
		Endif
	Endfor
	Return .F.
ENDPROC
*****************************************
* WdOrder 字段排序
*****************************************
PROCEDURE WdOrder
	PARAMETERS LcParen
	vplindex=LcParen.ControlSource
	tmpindex="_tmp"+Alltrim(Substr('abcdefg',1,4))
	Index On &vplindex. To &tmpindex.
	LcParen.Parent.Refresh
	LcParen.SetFocus()
ENDPROC

*****************************************
*getHttpTxt 获取网页内容
*****************************************

Procedure getHttpTxt
	Parameters cURLstr
	If Pcount()<>1 Or Empty(cURLstr)
		Return
	Endif
	oIE = Createobject("InternetExplorer.application")
	*oie.Visible=.T.
	oIE.Navigate(cURLstr)
	N=0
	Do While oIE.ReadyState<>4 And N<20
		Inkey(1)
	Enddo
	cALLTEXT	= oIE.Document.body.innerText
	Release oIE
	If "找不到"$cALLTEXT
		Return ""
	Endif
	Return  cALLTEXT
ENDPROC

Procedure NtoS
	Parameters Pvnum
	Local LCpNUM,Gnum,Gunit &&要返回的字符型
	If .Not.Pcount()=1
		Messagebox("有一个数字型参数",16,"系统提示")
		Return
	Endif
	If .Not.Vartype(Pvnum)="N"
		Messagebox("参数为数值型",16,"系统提示")
		Return
	Endif
	If Pvnum>99
		Messagebox("只能转换一百以内的数字",16,"系统提示")
		Return
	Endif
	Gnum="一二三四五六七八九"
	If Len(Alltrim(Str(Pvnum)))=1
		LCpNUM=Substr(Gnum,2*Pvnum-1,2)
	Else
		pvtem1=Int(Val(Substr(Alltrim(Str(Pvnum)),1,1)))
		pvtem2=Int(Val(Substr(Alltrim(Str(Pvnum)),2,1)))
		If pvtem1=1
			LCpNUM="十"+Substr(Gnum,2*pvtem2-1,2)
		Else
			LCpNUM=Substr(Gnum,2*pvtem1-1,2)+"十"+Substr(Gnum,2*pvtem2-1,2)
		Endif
	Endif
	Return LCpNUM
Endproc

*************************************************************
*LCBROW找相近字段
*************************************************************
Procedure LCBROW&&相近字段的标识
	Parameters FieldSame
	If !Pcount()=1
		Messagebox("一个参数，请输入相近的字段",16,"系统提示")
		Return
	Endif
	FieldSame=Upper(FieldSame)
	Local Ftotal
	Ftotal=""
	Select Alias()
	For Ftempstr=1 To Fcount()
		If FieldSame$Fields(Ftempstr)
			Ftotal=Ftotal+","+Fields(Ftempstr)
		Endif
	Endfor
	Ftotal=Substr(Alltrim(Ftotal),2)
	If Empty(Ftotal)
		Messagebox("没有找到包含[ "+Upper(Alltrim(FieldSame))+" ]的字段。",16,"系统提示")
		Return
	Endif
	Browse Fields &Ftotal.
Endproc


proc ksupdate
	para Lcfile

	if pcoun()<>1 or empty(Lcfile)
		messagebox("参数错误！",16)
		retu
	endif
	Lcstrfod='\\erp\Erp_File\update\'+alltr(str(year(date())))+padl(alltrim(str(month(date()))),2,'0')+padl(alltrim(str(day(date()))),2,'0')
	IF .not.DIRECTORY(Lcstrfod)
		lcmd='md '+Lcstrfod
		&lcmd.
	Endif
	lccopy=' copy file  '+sys(5)+curdir()+'include\'+Lcfile+'.* to ' + Lcstrfod
	&lccopy.
	use v:\update\autoupdate again
	go bottom
	if upper(alltr(sourcepath))=upper(alltr(Lcstrfod))
		repl newtime with datet()
	else
		appen  blank
		repl newtime  with datet()
		repl sourcepath with Lcstrfod
		repl  destpath with 'include'
		repl forceclose  with .f.
	endif
	if used("autoupdate")
		use in autoupdate
	endif
endproc

Procedure Lc_Empty
	Lparameter LC_1 , LC_TABLE , LC_SIZE
	Local TEMP_ALIAS , LC_CONTROL , FIELDS_COUNT , TEMP_FIELD , LC_CURR , IS_EMPTY
	LC_CURR = Select()
	If Parameters() < 2
		If  .Not. Empty(Alias())
			TEMP_ALIAS = Alias()
		Else
			Wait Window Nowait 'There is no any table opened !'
			Return
		Endif
	Else
		TEMP_ALIAS = LC_TABLE
	Endif
	If Select(TEMP_ALIAS) = 0
		If File(TEMP_ALIAS + '.dbf')
			Use In 0 Shared (TEMP_ALIAS) Again
		Else
			Wait Window Nowait 'The talbe ' + TEMP_ALIAS + ' can not find !'
			Return
		Endif
	Endif
	If Upper(Vartype(LC_SIZE)) = 'N'
		If LC_SIZE <= 1
			LC_SIZE = 1
		Endif
	Else
		If Upper(Vartype(LC_SIZE)) = 'C'
			If Val(LC_SIZE) <= 1
				LC_SIZE = 1
			Else
				LC_SIZE = Val(LC_SIZE)
			Endif
		Else
			LC_SIZE = 1
		Endif
	Endif
	Select (TEMP_ALIAS)
	Local LCCONTROLTEMP1
	For LCCONTROLTEMP1 = 1 To Fcount(TEMP_ALIAS)
		Select (TEMP_ALIAS)
		IS_EMPTY = .T.
		TEMP_FIELD = Field(LCCONTROLTEMP1,TEMP_ALIAS)
		Scan
			If Fsize(TEMP_FIELD,TEMP_ALIAS) < LC_SIZE
				IS_EMPTY = .F.
				Exit
			Endif
			If Upper(Vartype(&TEMP_FIELD.))='L' Then
				IS_EMPTY = .F.
				Exit
			Endif
			If Not Empty(&TEMP_FIELD.) Then
				IS_EMPTY = .F.
				Exit
			Endif
		Endscan
		If IS_EMPTY
			If Empty(FIELDS_COUNT)
				FIELDS_COUNT = Field(LCCONTROLTEMP1,TEMP_ALIAS)
			Else
				FIELDS_COUNT = FIELDS_COUNT + ',' + Field(LCCONTROLTEMP1,TEMP_ALIAS)
			Endif
		Endif
	Endfor
	Select (TEMP_ALIAS)
	If  .Not. Empty(FIELDS_COUNT)
		Browse Fields &FIELDS_COUNT. Last Nowait
	Else
		TEMPVALUE = ALLFIELDS()
		Browse Fields &ALLFIELDS. Last Nowait
		Wait Window Nowait 'There are no any fields empty !'
	Endif
	Return
Endproc
************32*******获取EXCEL的列************
**********************************************
Procedure XlsColumn
	Lparameters cColumn_No
	HeaderChr=''
	HeaderFirst=Int(cColumn_No/26)
	HeaderSecord=Mod(cColumn_No,26)
	If HeaderFirst=0 Then
		HeaderChr=Chr(64+HeaderSecord)
	Else
		If HeaderSecord=0 Then
			If HeaderFirst=1 Then
				HeaderChr='Z'
			Else
				HeaderChr=Chr(63+HeaderFirst)+'Z'
			EndIf
		Else
			HeaderChr=Chr(64+HeaderFirst)+Chr(64+HeaderSecord)
		EndIf
	EndIf
	Return HeaderChr
EndProc