***************************************
*0 onlyVFPapplication �ж�Ӧ�ó����Ƿ��Ѿ���
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
		*�����ǣ�����ID������Name�������ļ�·��
	Endfor
	If nLcisOnly>0
		Quit
	Endif
	Release oWbemLocator, oWMIService, oItems, oItems
Endproc

***************************************
*1  doform ����ֻ����һ��
***************************************
Procedure doform
	Parameters cFname
	If Pcount()<>1 Or Vartype(cFname)<>"C"
		Messagebox("��������!",16,"��ܰ��ʾ")
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
*6  �һ�����ʽ�˵�
***************************************
Procedure  RightMemu
	*para oREF
	Define Popup rmemu SHORTCUT Relative From Mrow(),Mcol()
	Define Bar _Med_undo Of rmemu Prompt "����"
	Define Bar 3 Of rmemu Prompt "\-"
	Define Bar _Med_cut Of rmemu Prompt "����"
	Define Bar _Med_copy Of rmemu Prompt "����"
	Define Bar _Med_paste Of rmemu Prompt "ճ��"
	Define Bar _Med_clear Of rmemu Prompt "ɾ��"
	Define Bar 8 Of rmemu Prompt "\-"
	Define Bar _Med_slcta Of rmemu Prompt "ȫѡ"
	Activate Popup rmemu
Endproc

**********************************
*8�������ڿؼ�
**********************************
Procedure getDate
	Local wdTime,wdCoform
	wdCoform=Createobject("tdate")
	wdCoform.Show()
Endproc
**********************************
*9������Ϣ
**********************************
Procedure WdMess
	Parameters Emess,Tmess,nPic
	Do Form wdmessbox With Emess,Tmess,nPic
	Return _SWmess
Endproc
**********************************
*10 �ϴ�ͼƬ����������ȥ
**********************************
Procedure ImageToServer
	mPicture=Getfile("bmp,jpg,gif,ico,png")
	If Empty(mPicture)
		Return ""
	Endif
	Local mPicName
	If .Not.Directory(photo_path)
		WdMess("������ͼƬ�ļ��в����ڣ�","��ܰ��ʾ",1)
		Return ""
	Endif
	If ' '$mPicture
		mPicture="'"+mPicture+"'"
	Endif
	wondcopy='copy file  '+mPicture +' to '+photo_path
	&wondcopy.
	Return Justfname(mPicture)
	WdMess("ͼƬ�ϴ��ɹ�!","��ܰ��ʾ",1)
Endproc
***********************************
*�ñ����򿪱�
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
*��ձ�
***************************************
Procedure wdZAP
	Lparameter PAULDBF , PAULTYPE  &&PAULDBF �������� �� PAULTYPE��յ�����
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
*������ʱ��
*********************************
Procedure wdD2C
	Parameters dbfTable,cdbfTable
	On Error
	&& �ӱ�dbfTable �Ѽ�¼���Ƶ���cdbfTable
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
		WdMess("������Ŀ����!","��ܰ��ʾ",1)
	Endif
Endproc
*********************************
*������ʱ��DTL
*********************************
Procedure DTLwdD2C
	Parameters dbfTable,cdbfTable,vFIELDS,vSetvalue
	On Error
	&& �ӱ�dbfTable �Ѽ�¼���Ƶ���cdbfTable
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
		WdMess("������Ŀ����!","��ܰ��ʾ",1)
	Endif
Endproc
**********************************
*
**********************************

Procedure wdC2D
	Parameters dbfTable,cdbfTable,vSetvalue ,vSetKey
	On Error
	&& �ӱ�dbfTable �Ѽ�¼���Ƶ���cdbfTable
	&&vSetValue ����ֵ,vSetKey����
	If Pcount()<>4
		WdMess("������Ŀ����!","��ܰ��ʾ",1)
		Return
	Endif
	If Empty(vSetvalue ) Or Empty(vSetKey)
		WdMess("������Ϣ��������Ϊ��!","��ܰ��ʾ",1)
		Return
	Endif
	Select &cdbfTable
	Scatter Memo To Memvar
	Select &dbfTable
	Set Order To &vSetKey
	If Empty(vSetvalue )
		WdMess("������ϢΪ��!","��ܰ��ʾ",1)
		Retu
	Endif
	Seek (vSetvalue )
	If Found()
		*	If WdMess("��¼��"+vSetValue +"���Ѿ������Ƿ�Ҫ����?","��ܰ��ʾ",3)
		Gather Memo From Memvar
		=Tableupdate(.T.)
		*	Else
		*		Return
		*	ENDIF
	Else
		Append Blank
		Gather Memo  From Memvar
		=Tableupdate(.T.)
		WdMess("��¼��"+vSetvalue +"�����ӳɹ�!","��ܰ��ʾ",1)
	Endif
Endproc
****************************************
*���ƷŴ�
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
	*�жϳ����Ƿ��
	If File("wdopen.dll")
		Quit
	Else
		Strtofile("ʱ�䣺"+Ttoc(Datetime())+Chr(13)+Chr(10)+"�û���"+wduser,"wdopen.dll")
	ENDIF
	*****�ж��ܷ�ʹ��
	IF FILE("wduseYN.dll")
		QUIT
	ENDIF


	*DOFORM("UPDATE")
Endproc

*****************
*close wonder
*****************
Procedure closeWonder
	*��������ʱ������������
	If File("wdopen.dll")
		Delete File wdopen.Dll
	Endif
	If Vartype(wduser)<>"C"
		WdMess("�û�ID�����ڣ�","��ܰ��ʾ",3)
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
		Replace  on_type With "����"
	Endif
	Use In longo_no
Endproc
********************************
*�ж��ֶ��Ƿ���ڡ�
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
* WdOrder �ֶ�����
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
*getHttpTxt ��ȡ��ҳ����
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
	If "�Ҳ���"$cALLTEXT
		Return ""
	Endif
	Return  cALLTEXT
ENDPROC

Procedure NtoS
	Parameters Pvnum
	Local LCpNUM,Gnum,Gunit &&Ҫ���ص��ַ���
	If .Not.Pcount()=1
		Messagebox("��һ�������Ͳ���",16,"ϵͳ��ʾ")
		Return
	Endif
	If .Not.Vartype(Pvnum)="N"
		Messagebox("����Ϊ��ֵ��",16,"ϵͳ��ʾ")
		Return
	Endif
	If Pvnum>99
		Messagebox("ֻ��ת��һ�����ڵ�����",16,"ϵͳ��ʾ")
		Return
	Endif
	Gnum="һ�����������߰˾�"
	If Len(Alltrim(Str(Pvnum)))=1
		LCpNUM=Substr(Gnum,2*Pvnum-1,2)
	Else
		pvtem1=Int(Val(Substr(Alltrim(Str(Pvnum)),1,1)))
		pvtem2=Int(Val(Substr(Alltrim(Str(Pvnum)),2,1)))
		If pvtem1=1
			LCpNUM="ʮ"+Substr(Gnum,2*pvtem2-1,2)
		Else
			LCpNUM=Substr(Gnum,2*pvtem1-1,2)+"ʮ"+Substr(Gnum,2*pvtem2-1,2)
		Endif
	Endif
	Return LCpNUM
Endproc

*************************************************************
*LCBROW������ֶ�
*************************************************************
Procedure LCBROW&&����ֶεı�ʶ
	Parameters FieldSame
	If !Pcount()=1
		Messagebox("һ��������������������ֶ�",16,"ϵͳ��ʾ")
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
		Messagebox("û���ҵ�����[ "+Upper(Alltrim(FieldSame))+" ]���ֶΡ�",16,"ϵͳ��ʾ")
		Return
	Endif
	Browse Fields &Ftotal.
Endproc


proc ksupdate
	para Lcfile

	if pcoun()<>1 or empty(Lcfile)
		messagebox("��������",16)
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
************32*******��ȡEXCEL����************
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