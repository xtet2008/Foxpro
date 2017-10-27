*!*		PaulACCT_IDDEBIT('ACCT_CAJV',JVMAST.PERIOD,JVDTL.ACCT_ID,ROUND(JVDTL.DEBIT*JVDTL.EXCHAN-JVDTL.CREDIT*JVDTL.EXCHAN,ac_decimal),JVMAST.VOUCH_DATE,;
*!*	              ACCT_DEFJV.OPENDATEFR,ACCT_DEFJV.OPENDATETO,JVDTL.DEBIT-JVDTL.CREDIT,'ACCT_DEFJV',JVDTL.CCY,acct_curr)

procedure SZPaulacct_iddebit
	lparameter pauldbf , paulperiod , paulacct_id , Pldebit,Plcredit ,pauldate ,;
		paulopendatefr , paulopendateto , plthis_ccy , plccydbf , plccy , plac_curr , plforward

	local paulselect , paulseek , paulperiodn , plcount , plv1 , plv2,paulvalue
	if paulperiod > 24 .or. paulperiod < 1
		return
	endif

	plcount = 2
	paulselect = select()
	select (pauldbf)
	paulperiodn = 'PERIOD' + alltrim(str(paulperiod,3))
	pauldebit  = 'debit' + alltrim(str(paulperiod,3))
	paulcredit = 'credit' + alltrim(str(paulperiod,3))
	paulvalue  =  Pldebit - Plcredit
	seek order acct_id paulacct_id
	if found()
		if pauldate < paulopendatefr .or. pauldate > paulopendateto
			if pauldate > paulopendateto and empty(plforward)  && ��һ���ƾ֤
				replace forward_bal with forward_bal + paulvalue
			endif
			if pauldate < paulopendatefr and empty(plforward) && ��һ���ƾ֤
				replace backward_bal with backward_bal + paulvalue
			endif

			if pauldate > paulopendateto and  .not. empty(plforward)
				replace forward_ba with forward_ba + paulvalue    && No this field
			endif
			if pauldate < paulopendatefr and  .not. empty(plforward)
				replace backward_b with backward_b + paulvalue    && No this field
			endif
		else
			replace &paulperiodn. with &paulperiodn. + paulvalue
			&& һ����Ŀ�������������ʾ������N����� �� �ڳ� �� ��period1��period2������ �� periodN��
			&& ������Ŀ�����ͳһ��������ʾ����N����� �� �ڳ� �� ��period1��period2������ �� periodN����iif���跽��Ŀ��1����1��
			replace balance with balance + paulvalue
			if vartype(debit1) <> 'U'
				replace &pauldebit.  with &pauldebit. + Pldebit  &&  &pauldebit.+paulvalue
				replace &paulcredit. with &paulcredit.+ Plcredit &&  &paulcredit.+paulvalue
			endif
		endif

		if paulvalue >= 0
			replace debit with debit + paulvalue
		else
			replace credit with credit + abs(paulvalue)
		endif

		replace lastupdate with date()
		if  .not. empty(plccy)
			if plccy = plac_curr
				replace this_ccy1 with this_ccy1 + plthis_ccy
			else
				do while plcount <= 10
					plv1 = alltrim(plccydbf) + '.ccy' + alltrim(str(plcount,2))
					plv2 = 'this_ccy' + alltrim(str(plcount,2))
					if plccy=&plv1.
						replace &plv2. with &plv2.+plthis_ccy
						exit
					endif
					plcount = plcount + 1
				enddo
				plcount = 2
			endif
		endif
	endif
	select (paulselect)
	return .t.
endproc


procedure SZPaulunacct_iddebit
	lparameter pauldbf , paulperiod , paulacct_id , Pldebit,Plcredit ,pauldate ,;
		paulopendatefr , paulopendateto , plthis_ccy , plccydbf , plccy , plac_curr , plforward

	local paulselect , paulseek , paulperiodn , plcount , plv1 , plv2,paulvalue
	if paulperiod > 24 .or. paulperiod < 1
		return
	endif

	plcount = 2
	paulselect = select()
	select (pauldbf)
	paulperiodn = 'PERIOD' + alltrim(str(paulperiod,3))
	pauldebit  = 'debit' + alltrim(str(paulperiod,3))
	paulcredit = 'credit' + alltrim(str(paulperiod,3))
	paulvalue  =  Pldebit - Plcredit
	seek order acct_id paulacct_id
	if found()
		if pauldate < paulopendatefr .or. pauldate > paulopendateto
			if pauldate > paulopendateto and empty(plforward)  && ��һ���ƾ֤
				replace forward_bal with forward_bal - paulvalue
			endif
			if pauldate < paulopendatefr and empty(plforward) && ��һ���ƾ֤
				replace backward_bal with backward_bal - paulvalue
			endif

			if pauldate > paulopendateto and  .not. empty(plforward)
				replace forward_ba with forward_ba - paulvalue    && No this field
			endif
			if pauldate < paulopendatefr and  .not. empty(plforward)
				replace backward_b with backward_b - paulvalue    && No this field
			endif
		else
			replace &paulperiodn. with &paulperiodn. - paulvalue
			&& һ����Ŀ�������������ʾ������N����� �� �ڳ� �� ��period1��period2������ �� periodN��
			&& ������Ŀ�����ͳһ��������ʾ����N����� �� �ڳ� �� ��period1��period2������ �� periodN����iif���跽��Ŀ��1����1��
			replace balance with balance - paulvalue
			if vartype(debit1) <> 'U'
				replace &pauldebit.  with &pauldebit. - Pldebit  &&  &pauldebit.+paulvalue
				replace &paulcredit. with &paulcredit.- Plcredit &&  &paulcredit.+paulvalue
			endif
		endif

		if paulvalue >= 0
			replace debit with debit - paulvalue
		else
			replace credit with credit - abs(paulvalue)
		endif

		replace lastupdate with date()
		if  .not. empty(plccy)
			if plccy = plac_curr
				replace this_ccy1 with this_ccy1 - plthis_ccy
			else
				do while plcount <= 10
					plv1 = alltrim(plccydbf) + '.ccy' + alltrim(str(plcount,2))
					plv2 = 'this_ccy' + alltrim(str(plcount,2))
					if plccy=&plv1.
						replace &plv2. with &plv2.- plthis_ccy
						exit
					endif
					plcount = plcount + 1
				enddo
				plcount = 2
			endif
		endif
	endif
	select (paulselect)
	return .t.
endproc



FUNCTION SZGetacFld
	PARAMETERS L_acct_id,L_FieldName,L_TableName
	local L_recno,L_return,lworkarea
	lworkarea= select()
	L_return = 0
	sele (L_TableName)
	L_recno = iif(eof() or bof(),0,recno())
	if seek(L_acct_id)
		scan rest while acct_id = L_acct_id
			L_return = L_return + &L_FieldName. * iif(ac_paren ='C' ,-1,1)
		endscan
	endif
	if L_recno <> 0
		go L_recno
	endif

	select (lworkarea)
	retu  L_return


procedure ksgensoid
	para lso_id
	if vartype(lso_id) <> 'C'
		retu ''
	endif

	if empty(lso_id)
		retu ''
	endif

	local lpos ,lhead,lweekno,lendsubid,lrt_soid,lnet_id
	lrt_soid = ''
	if !used('somast_gensoid')
		use somast in 0 order so_id alias somast_gensoid again
	endif
	lworkarea= select()
	sele somast_gensoid
	set order to so_id
	lpos       = at('-',lso_id)
	lhead      = left(lso_id,lpos)
	lnet_id    = subs(lso_id,lpos + 1,sys_soidlen)
	lendsub_id = trim(subs(lso_id,lpos + sys_soidlen + 1))
	lso_id     = lhead + lnet_id

	*!*		    ? lhead
	*!*		    ? lnet_id
	*!*		    ? 'end id '+ lendsub_id
	*!*		    ?
	if seek(lso_id)
		*lweekno  = padl(ltrim(str(IIF(year(so_date)=2005,week(so_date)-1,week(so_date)),2)) ,2,'0')
		*lrt_soid =  lhead + lweekno + lnet_id +'/' + right(str(year(so_date),4),2)+'/' + trim(employee_id) + lendsub_id
		lrt_soid = lso_id + '/' + trim(employee_id) + lendsub_id
	else
		lrt_soid = lso_id + lendsub_id
	endif
	if used("somast_gensoid")
		use in somast_gensoid
	endif
	select (lworkarea)
	retu  lrt_soid
endproc


*================================================================*
function  tonylinkccyamt
	parameter lrt_type,lccy1,lamt1,lccy2,lamt2,lccy3,lamt3,lccy4,lamt4,lccy5,lamt5
	if vartype(lccy5) <>  'C'
		lamt5 = 0
	endif
	if vartype(lccy4) <> 'C'
		lamt4 = 0
	endif

	local lworkarea,lretuvalue
	lretuvalue = ''

	local tmpchg,ln
	lcounter = 0
	if lamt1 <> 0
		lcounter = lcounter + 1
		dime tmpchg[Lcounter,2]
		tmpchg[Lcounter,1] = lccy1
		tmpchg[Lcounter,2] = lamt1
	endif
	if lamt2 <> 0
		ln = ascan(tmpchg,lccy2)
		if ln = 0
			lcounter = 1 + lcounter
			dime tmpchg[Lcounter,2]
			tmpchg[Lcounter,1] = lccy2
			tmpchg[Lcounter,2] = lamt2
		else
			tmpchg[(Ln+1)/2,2] =  tmpchg[(Ln+1)/2,2] + lamt2
		endif
	endif

	if lamt3 <> 0
		ln = ascan(tmpchg,lccy3)
		if ln = 0
			lcounter = 1 + lcounter
			dime tmpchg[Lcounter,2]
			tmpchg[Lcounter,1] = lccy3
			tmpchg[Lcounter,2] = lamt3
		else
			tmpchg[(Ln+1)/2,2] =  tmpchg[(Ln+1)/2,2] +lamt3
		endif
	endif
	if lamt4 <> 0
		ln = ascan(tmpchg,lccy4)
		if ln = 0
			lcounter = 1 + lcounter
			dime tmpchg[Lcounter,2]
			tmpchg[Lcounter,1] = lccy4
			tmpchg[Lcounter,2] = lamt4
		else
			tmpchg[(Ln+1)/2,2] =  tmpchg[(Ln+1)/2,2] + lamt4
		endif
	endif

	if lamt5 <> 0
		ln = ascan(tmpchg,lccy5)
		if ln = 0
			lcounter = 1 + lcounter
			dime tmpchg[Lcounter,2]
			tmpchg[Lcounter,1] = lccy5
			tmpchg[Lcounter,2] = lamt5
		else
			&&	wait wind 'LN:' +str(ln)+ 'Lcounter:'+str(lcounter)
			&&	? tmpchg[(Ln+1)/2,2]
			tmpchg[(Ln+1)/2,2] =  tmpchg[(Ln+1)/2,2] + lamt5
		endif
	endif

	lccy = ''
	lamt = ''
	for ln =1 to lcounter
		if tmpchg[ln,2] <> 0
			lccy = lccy + iif(empty(lccy),'',chr(13)) + tmpchg[ln,1]
			lamt = lamt + iif(empty(lamt),'',chr(13)) + trans(tmpchg[ln,2],total_pic)
		endif
	endfor
	retu iif(upper(lrt_type) = 'C',lccy,lamt)


procedure isaccesscmd
	lparameter tcscreen_key,tcsecurity_id ,tcfield
	local tcscreen_key , tcsecurity_id , vpaulprogram
	licon_access = .f.
	select_wk = select()
	*!*		if  .not. used('security_setcmd')
	*!*			use in 0 security alias security_setcmd order id again
	*!*		endif
	select security_setcmd
	if seek(upper(tcsecurity_id + tcscreen_key))
		licon_access = security_setcmd.icon_access
		if  .not. empty(tcfield)
			licon_access = &tcfield.
		endif
	endif
	if trade_mark
		licon_access = .t.
	endif

	select (select_wk)
	if trade_mark .or. licon_access
		return .t.
	else
		return .f.
	endif
endproc


function  begday
	parameter ldate
	if vartype(ldate) <>  'D'
		ldate = date()
	endif

	retu ldate - day(ldate) + 1

function  endday
	parameter ldate
	if vartype(ldate) <>  'D'
		ldate = date()
	endif

	retu gomonth(ldate,1) - day(ldate)

function  linkperiod
	parameter lyear,lperiod
	if vartype(lyear) <>  'N' or vartype(lperiod) <>  'N'
		wait wind 'Link period Error!!'
		retu '000000'
	endif

	retu str(lyear,4) + strt(str(Lperiod,2),' ','0')

	*!*	*********************��Сдת��***************
	*!*	PROCEDURE changex
	*!*	PARAMETERS mmje  &&��������������ͣ�С��9����,����-9����
	*!*	PRIVATE dx,aa,i
	*!*	dx=IIF(mmje<0,'��','')
	*!*	aa=ROUND(ABS(mmje)*100,0)
	*!*	FOR i=LEN(ALLTRIM(STR(aa,15)))-1 to 0 STEP -1
	*!*	   dx=dx+SUBS('��Ҽ��������½��ƾ�',INT(ROUND(aa/10^i,10))*2+1,2)+SUBS('�ֽ�Ԫʰ��Ǫ��ʰ��Ǫ��ʰ��Ǫ��',i*2+1,2)
	*!*	   aa=MOD(aa,10^i)
	*!*	endf
	*!*	dx=STRTRAN(STRTRAN(STRTRAN(STRTRAN(STRTRAN(dx,'��Ǫ','��'),'���','��'),'��ʰ','��'),'���','��'),'���','��')
	*!*	dx=STRTRAN(STRTRAN(STRTRAN(STRTRAN(STRTRAN(dx,'����','��'),'����','��'),'����','��'),'����','��'),'��Ԫ','Ԫ')
	*!*	RETURN IIF(dx='��','��Ԫ��',STRTRAN(STRTRAN(dx,'����','��'),'����','��'))

	*********************** &&�������ں���*********************
FUNCTION chndate
	PARAMETERS mdate
	SET century on
	DIMENSION mmonth(13)
	mmonth(1)=""
	mmonth(2)="Ҽ"
	mmonth(3)="��"
	mmonth(4)="��"
	mmonth(5)="��"
	mmonth(6)="��"
	mmonth(7)="½"
	mmonth(8)="��"
	mmonth(9)="��"
	mmonth(10)="��"
	mmonth(11)="ʰ"
	mmonth(12)="ʰҼ"
	mmonth(13)="ʰ��"
	m_year=""
	FOR i=1 to 4
		m=IIF(VAL(SUBSTR(STR(YEAR(mdate),4),i,1))+1=1,"��",mmonth(VAL(SUBSTR(STR(YEAR(mdate),4),i,1))+1))
		m_year=m_year+m
	ENDFOR
	m_year=m_year
	*********************��**************
	if month(mdate)<10
		m_month="��"+mmonth(MONTH(mdate)+1)
	else
		if month(mdate)=10
			m_month="��Ҽ"+mmonth(MONTH(mdate)+1)
		else
			m_month="Ҽ"+mmonth(MONTH(mdate)+1)
		endif
	endif
	*******************��****************
	if DAY(mdate)<=10
		if DAY(mdate)=10
			m_day="��Ҽ"+mmonth(DAY(mdate)+1)
		else
			m_day="��"+mmonth(DAY(mdate)+1)
		endif
	else
		n=IIF(VAL(SUBSTR(STR(DAY(mdate),2),1,1))+1=2,1,VAL(SUBSTR(STR(DAY(mdate),2),1,1))+1)
		m=IIF(VAL(SUBSTR(STR(DAY(mdate),2),2,1))+1=0,10,VAL(SUBSTR(STR(DAY(mdate),2),2,1))+1)
		m_day=mmonth(n)+"ʰ"+mmonth(m)
		if len(allt(m_day))=4
			if subs(allt(m_day),1,2)="ʰ"
				m_day="Ҽ"+m_day
			else
				m_day="��"+m_day
			endif
		endif
	ENDIF
	RETURN m_year+space(10)+m_month+space(8)+m_day
	*****************ʡ����/��*************

FUNCTION stt
	PARAMETERS Sextra
	if !empty(Sextra)
		for i=1 to len(allt(Sextra))
			if subs(allt(Sextra),i,2)="ʡ"
				stt1=subs(allt(Sextra),1,i-1)
				BL=i+2
			endif
			if subs(allt(Sextra),i,5)="��/��"
				xss1=subs(allt(Sextra),BL,i-BL)
			endif
		endfor
	endif
	return  stt1

FUNCTION xss
	PARAMETERS Sextra
	if !empty(Sextra)
		for i=1 to len(allt(Sextra))
			if subs(allt(Sextra),i,2)="ʡ"
				stt2=subs(allt(Sextra),1,i-1)
				BL=i+2
			endif
			if subs(allt(Sextra),i,5)="��/��"
				xss2=subs(allt(Sextra),BL,i-BL)
			endif
		endfor
	endif
	return xss2
	*******************���ǰ�ӷ���********
FUNCTION Ramount
	PARAMETERS Ramt,Rccy
	Camt=ALLT(STR(Ramt,LEN(STR(Ramt))+2,2))
	do case
		case len(camt)<7
			Tamount=camt
		case len(camt)>=7 and len(camt)<10
			Tamount=left(camt,len(camt)-6)+","+right(camt,6)
		case len(camt)>=10
			Tamount=left(camt,len(camt)-9)+","+subs(camt,len(camt)-9+1,3)+","+right(camt,6)
	endcase
	if allt(Rccy)="RMB"
		Tamount="��"+Tamount
	endif
	if allt(Rccy)="USD"
		Tamount="USD"+Tamount
	endif
	if allt(Rccy)="HKD"
		Tamount="HKD"+Tamount
	endif
	return Tamount
	*************************���ǡ������**********
FUNCTION Dzamount
	PARAMETERS Ramt,Rccy
	Dx_amount=allt(cn_amt(Ramt))
	if right(Dx_amount,2)="��"
		Dx_amount=Dx_amount+"��"
	endif
	if allt(upper(Rccy))="USD"
		Dx_amount="��Ԫ��"+Dx_amount
	endif
	if allt(upper(Rccy))="HKD"
		Dx_amount="�۱ң�"+Dx_amount
	endif
	return Dx_amount





Function VCopyFile
	Lparameters LcSourceFile,LcDestFile,LtTure
	&&  �����ļ�		Դ�ļ�,Ŀ���ļ�(Ŀ¼),�Ƿ񸲸�	�ɹ�,����.T.,ʧ��,����.F.
	&& This Function copy file to specify
	&& ?vcopyfile("D:\itrader\orders.exe","C:\dos\orders.exe",.T.)
	Local _isError,Error_wk
	Error_wk = On("Error")

	If Empty(LcSourceFile) Or Empty(LcDestFile)
		Return .F.			&& Key parameters missed.
	Endif
	If !File(LcSourceFile)
		Return .F.			&& Soucre File not exist.
	Endif
	If Pcount()<3 Or Vartype(LtTure)<>"L"
		LtTure = .F.
	Endif
	IF !File(LcDestFile)
		IF Directory(LcDestFile)		&& LcDestFile is a directory,  Add Source file name.
			LcDestFile = addbs(LcDestFile)+JustFname(LcSourceFile)
		Endif
	Endif
	If File(LcDestFile) And !LtTure
		Return .F.			&& Destination file exist, but not allowed to cover it.
	Endif
	LtTure = Iif(LtTure,0,1)
	*On Error _isError=.T.

	Declare Integer CopyFile In Kernel32 As CopyFileA String lpExistingFileName , String lpNewFileName, Integer bFailIfExists
	&& IF bFailIfExists=0  , Cover the exist file.
	Local nReturn
	nReturn = CopyFileA(LcSourceFile,LcDestFile,LtTure)
	On Error &Error_wk.
	If nReturn=0
		Return .F.
	Else
		Return .T.
	Endif
Endfunc

Function VCopyFolder
	Lparameters LcSourceFolder,LcDestFolder,LtTure
	&&	�����ļ���	Դ�ļ���,Ŀ���ļ���,�Ƿ񸲸�		�ɹ�,����.T.,ʧ��,����.F.
	&& ?vcopyfolder("D:\DOS","C:\DOS",.T.)
	Local _isError,Error_wk
	Error_wk = On("Error")
	If Pcount()<2
		Return .F.
	Endif
	LcSourceFolder = Addbs(Allt(LcSourceFolder))
	LcSourceFolder = Left(LcSourceFolder,Len(LcSourceFolder)-1)
	LcDestFolder = Addbs(Allt(LcDestFolder))
	LcDestFolder = Left(LcDestFolder,Len(LcDestFolder)-1)
	If !Directory(LcSourceFolder)
		Return .F.
	Endif
	If Pcount()<3 Or Vartype(LtTure)<>"L"
		LcTure = .F.
	Endif
	If Directory(LcDestFolder) And !LtTure
		Return .F.
	Endif
	On Error _isError=.T.

	loFso= Createobject("Scripting.FileSystemObject")
	If Vartype(loFso)#"O"
		On Error &Error_wk.
		Return .F.
	Endif
	loFso.CopyFolder(LcSourceFolder,LcDestFolder,LtTure)
	On Error &Error_wk.
	If _isError
		Return .F.
	Else
		Return .T.
	Endif
Endfunc

Function VDeleteFolder
	Lparameters LcFolderName,LtTure
	&&	ɾ��һ���ļ���,		�ļ�����,�Ƿ�ǿ��ɾ��		�ɹ�,����.T.,ʧ��,����.F.
	If Empty(LcFolderName) Or !Directory(LcFolderName)
		Return .F.
	Endif
	If Pcount()<2 Or Vartype(LtTure)<>"L"
		LtTure = .F.
	Endif
	Local _isError,loFso,Error_wk
	Error_wk = On("Error")
	On Error _isError=.T.
	loFso= Createobject("Scripting.FileSystemObject")
	LoFso.DeleteFolder(LcFolderName,LtTure)
	On Error &Error_wk.
	If _isError
		Return .F.
	Else
		Return .T.
	Endif
Endfunc

Function VAddSysFont
	Lparameters LcFileName
	&&	��Ӹ���һ�������ļ���ϵͳĿ¼����װ����.		�����ļ���	�ɹ�,����.T.,ʧ��,����.F.
	&& This Function install a Font into system.
	If Empty(LcFileName)
		Return .F.
	Endif
	If !File(LcFileName)
		Return .F.
	Endif
	Local LcFontName
	LcFontName = Justfname(LcFileName)
	Local LcSystemFld
	LcSystemFld = VGetSystemFolder()
	Local LcSystemFont
	LcSystemFont = Left(LcSystemFld,At("\",LcSystemFld,2))+"Fonts\"+LcFontName
	VCopyFile(LcFileName,LcSystemFont,.T.)
	Declare Integer AddFontResource In "gdi32" As AddFontResourceA String lpFileName
	*!* Add Font
	Local nReturn
	nReturn = AddFontResourcea(LcSystemFont)
	If nReturn=0
		Return .F.
	Else
		Return .T.
	Endif
Endfunc

Function VGetSystemFolder		&& Get System Folder.
	&&	����ϵͳĿ¼.
	Declare Integer GetSystemDirectory In kernel32 String @ lpBuffer, Integer nSize
	lpBuffer = Space (250)
	nSizeRet = GetSystemDirectory (@lpBuffer, Len(lpBuffer))
	If nSizeRet <> 0
		lpBuffer = Substr (lpBuffer, 1, nSizeRet)
		Return lpBuffer
	Else
		Return ""
	Endif
Endfunc

Function VOpenFolder
	&& ��ʾ���ļ��жԻ���		�����ļ���·��
	Declare Integer FindWindow In WIN32API String,String
	Declare Integer SHBrowseForFolder In "shell32.dll" Integer @
	cTitle = _Screen.Caption
	Declare Integer SHGetPathFromIDList In "shell32.dll" Integer,String @cTitle
	hOwner=FindWindow(0,cTitle)
	pidl = SHBrowseForFolder(hOwner)
	If Not Isnull(pidl)
		getpath=Spac(512)
		SHGetPathFromIDList(pidl,@getpath)
		Return Left(getpath,At(Chr(0),getpath)-1)
	Endif
	Return ""
Endfunc

Function ReadIniFile
	Parameters lpFileName,lpApplicationName,lpKeyName
	&&  ��ȡ INI �ļ�ָ���ڵ�,ָ����Ŀ��ֵ.	�������ļ���,�ڵ���,��Ŀ��	���� �ַ���
	&&  Read ini file		Eg. readinifile("include\privSetting.ini","�ڵ�","��Ŀ")
	If Empty(lpFileName)
		Return ""
	Endif
	Declare Integer GetPrivateProfileString In Win32API As GetPrivStr  String , String , String , String @ , Integer , String
	Local lpReturnedString , nSize , LcString
	lpReturnedString = Space(200)
	nSize = 200
	*lpApplicationName -  String���������в�����Ŀ��С�����ơ�����ִ������ִ�Сд������ΪvbNullString������lpReturnedString��������װ�����ini�ļ�����С�ڵ��б�
	*lpKeyName ------  String������ȡ����������Ŀ��������ִ������ִ�Сд������ΪvbNullString������lpReturnedString��������װ��ָ��С����������б�
	*lpDefault ------  String��ָ������Ŀû���ҵ�ʱ���ص�Ĭ��ֵ������Ϊ�գ�""��
	*lpReturnedString -  String��ָ��һ���ִ�����������������ΪnSize
	*nSize ----------  Long��ָ��װ�ص�lpReturnedString������������ַ�����
	*lpFileName -----  String����ʼ���ļ������֡���û��ָ��һ������·������windows����WindowsĿ¼�в����ļ�
	= GetPrivStr(lpApplicationName , lpKeyName , '', @ lpReturnedString, nSize , lpFileName)
	LcString = KillPrivNullChar(Alltrim(lpReturnedString))
	Return LcString
Endfunc

Function WriteIniFile
	Parameters lpFileName,lpApplicationName,lpKeyName,lpKeyValue
	&&	дһ��ֵ��INI�ļ�.		������ �ļ���,�ڵ���,��Ŀ��,��Ŀֵ	���أ��ɹ�.T., ʧ��.F.
	&&  Write ini file			Eg. Writeinifile("include\privSetting.ini","�ڵ�","��Ŀ","ֵ")
	If Empty(lpFileName) Or Empty(lpApplicationName) Or Empty(lpKeyValue)
		Return .F.
	Endif
	Local nReturnValue
	Declare Integer WritePrivateProfileString In Win32API As WritePrivStr String , String , String , String
	*lpApplicationName -  String��Ҫ������д�����ִ���С�����ơ�����ִ������ִ�Сд
	*lpKeyName ------  Any��Ҫ���õ���������Ŀ��������ִ������ִ�Сд����vbNullString��ɾ�����С�ڵ�����������
	*lpString -------  String��ָ��Ϊ�����д����ִ�ֵ����vbNullString��ʾɾ����������е��ִ�
	*lpFileName -----  String����ʼ���ļ������֡����û��ָ������·��������windows����windowsĿ¼�����ļ�������ļ�û���ҵ��������ᴴ����
	nReturnValue = WritePrivStr(lpApplicationName, lpKeyName, lpkeyValue, lpFileName)
	If nReturnValue=0
		Return .F.
	Else
		Return .T.
	Endif
Endfunc

Function KillPrivNullChar
	Lparameters sPSW
	* �����ַ����еķǴ�ӡ�ַ�
	Local Lnlength, LcString
	Lnlength = Len(sPSW)
	LcString = Strtran(sPSW, Chr(0), "")
	Return LcString
Endfunc

*================================================================*
Function  UseDbfExcl		&&...�жϱ��Ƿ���Դ�     0�����ɴ�; 1 - �ɶ�ռʹ��;  2 - �ɹ����ܶ�ռ; 3 - ������
	*================================================================*
	Parameter  ltmpfile
	Local  lerrorprocess , _iserr , retuvalue
	lerrorprocess = On('ERROR')
	On Error _iserr = .T.
	_iserr = .F.
	If !File(Alltrim(ltmpfile)+'.dbf')
		retuvalue = 0
	Else
		Use (ltmpfile) In 0 Alias lopenvouc Exclusive
		If _iserr     &&��ʧ��
			_iserr = .F.
			Use (ltmpfile) In 0 Alias lopenvouc Share
			If _iserr     &&��ʧ��
				retuvalue = 0		&& ��ʱӦ��ֹ��һ������
			Else
				Use In lopenvouc
				retuvalue = 2
			Endif
		Else
			retuvalue = 1
			Use In lopenvouc
		Endif
	Endif
	On Error &lerrorprocess
	Retu  retuvalue
Endfunc

PROCEDURE DllRegister
	LPARAMETER LPLIBFILENAME , ISREG
	&&	ע��һ��DLl��OCX�ؼ�.
	&&  Eg. LCLIBFILENAME2 = SYS(5) + SYS(2003) + '\' + 'Command.ocx'
	&&	 DLLREGISTER(LCLIBFILENAME2,.T.)
	LcDestFile = Justfname(LPLIBFILENAME )
	LcDestfile = addbs(VGetSystemFolder())+LcDestFile
	IF !File(LcDestfile)
		VCopyFile(LPLIBFILENAME,lcDestFile,.T.)
	Endif
	IF !File(lcDestFile)
		Return .F.
	Endif
	ISREG = IIF(TYPE('isReg') = 'U',.T.,ISREG)
	LPPROCNAME = IIF(ISREG,'DllRegisterServer','DllUnregisterServer')
	DECLARE INTEGER GetLastError IN kernel32
	DECLARE INTEGER LoadLibrary IN kernel32 STRING
	DECLARE INTEGER FreeLibrary IN kernel32 INTEGER
	DECLARE INTEGER GetProcAddress IN kernel32 INTEGER , STRING
	DECLARE INTEGER CallWindowProc IN user32 INTEGER , INTEGER , INTEGER , INTEGER , INTEGER
	HLIBMODULE = LOADLIBRARY(LPLIBFILENAME)
	IF HLIBMODULE <> 0
		LNADDRESS = GETPROCADDRESS(HLIBMODULE,LPPROCNAME)
		IF LNADDRESS <> 0
			IF CALLWINDOWPROC(LNADDRESS,0,0,0,0) = 0
				= FREELIBRARY(HLIBMODULE)
				*RETURN '�ɹ�: ' + LPPROCNAME + ' ��ַ: ' + ALLTRIM(STR(LNADDRESS,12))
				RETURN .T.
			ELSE
				LNERROR = GETLASTERROR()
			ENDIF
		ELSE
			LNERROR = GETLASTERROR()
		ENDIF
		= FREELIBRARY(HLIBMODULE)
	ELSE
		LNERROR = GETLASTERROR()
	ENDIF
	*RETURN '����: (' + ALLTRIM(STR(LNERROR)) + ')' + GETERRORSTR(LNERROR)
	RETURN .F.
ENDPROC
*------
PROCEDURE GetErrorStr
	LPARAMETER LPNERROR
	DECLARE INTEGER FormatMessage IN kernel32 INTEGER , INTEGER , INTEGER , INTEGER ,  ;
		INTEGER @ , INTEGER , INTEGER
	DECLARE RtlMoveMemory IN kernel32 AS CopyMemory STRING @ , INTEGER , INTEGER
	DWFLAGS = 4864
	LPBUFFER = 0
	LNLENGTH = FORMATMESSAGE(DWFLAGS,0,LPNERROR,0,@LPBUFFER,0,0)
	IF LNLENGTH <> 0
		LPRESULT = REPLICATE(CHR(0),500)
		= COPYMEMORY(@LPRESULT,LPBUFFER,LNLENGTH)
		RETURN STRTRAN(LEFT(LPRESULT,LNLENGTH),CHR(13) + CHR(10),'')
	ELSE
		RETURN '#<δ֪����>#'
	ENDIF
ENDPROC
*------*
Function IsNotEmptyData
	Parameters LcDBFFile,LcDbfAlias,LcCondition,LcCondition2,LcCondition3
	&&  ����Ҫ��ӡ�ı�����ָ������1���Ƿ�����м�¼ �� �Ƿ��м�¼����������(2,3)
	IF Empty(LcDbfFile)
		Return .F.
	Endif
	IF Empty(LcDbfAlias)
		LcDbfAlias = LcDbfFile
	Endif
	Local _isOpenDbf,Error_wk,_isError
	Error_wk = On("Error")
	_isError = .F.
	*On Error _isError=.T.
	IF !used(LcDbfAlias)
		use (LcDbfFile) in 0 again alias &LcDbfAlias.
		_isOpenDbf = .T.
	Endif
	Local Select_wk
	Select_wk = Select()
	Select (LcDbfAlias)
	IF !Empty(LcCondition)
		set filter to &LcCondition.
	Endif
	On error &Error_wk.
	IF _isError
		IF _isOpenDbf
			use in (LcDbfAlias)
		Endif
		Select (Select_wk)
		Return .F.
	Endif
	Go top
	IF EOF()
		IF _isOpenDbf
			use in (LcDbfAlias)
		Endif
		Select (Select_wk)
		Return .F.
	Else
		Select (LcDbfAlias)
		Go top
		Scan rest
			IF TRADE_MARK .OR. ALLT(SECURITY_ID) == 'SUPERVISOR' .OR. DEPARTHEAD == 'SUPERVISOR' .OR. SUBSTR(SECURITY_ID,1,3) == 'BOS' or ALLT(SECURITY_ID)=='SD'
				_isError = .F.
				Exit
			Endif
			IF !Empty(LcCondition2) and !Evaluate(LcCondition2)
				_isError = .T.
				Exit
			Endif
			IF !Empty(LcCondition3) and !Evaluate(LcCondition3)
				_isError = .T.
				Exit
			Endif
		Endscan
		IF _isOpenDbf
			use in (LcDbfAlias)
		Endif
		IF _isError
			Select (Select_wk)
			Return .F.
		Endif
		Select (Select_wk)
		Return .T.
	Endif
EndFunc

Function FinaChgCcy
	parameters SourceCcy, DestCcy, nAmt,LaDbnmast
	&&   Source Ccy ,  destination Ccy,   Amount  , Dbnmast alias
	*!*		Local select_wk,Recno_wk
	*!*		select_wk = Select()
	*!*		Recno_wk = Iif(Eof() or Bof(),0,Recno())
	IF pcount()<2
		Return -1
	Endif
	IF pCount()<3 or VarType(nAmt)<>"N"
		nAmt = -9999999999
	EndIf
	If nAmt = 0
		Return 0
	EndIf
	SourceCcy = Allt(SourceCcy)
	DestCcy = Allt(DestCcy)
	Local USD2RMB,HKD2RMB,USD2RM1,USD2HKD
	USD2RMB =-9999999999
	HKD2RMB=-9999999999
	USD2RM1 =-9999999999
	USD2HKD =-9999999999
	If Empty(LaDbnmast)
		IF !Used("dbnexch_Fina")
			use dbnexch in 0 again alias dbnexch_Fina
		Endif
		Seek "USDRMB" in dbnexch_Fina order CODE_KEY
		IF Found("dbnexch_Fina")			&&  USD  >  RMB
			USD2RMB = dbnexch_Fina.rate
		Endif
		Seek "USDRM1" in dbnexch_Fina order CODE_KEY		&& RMB ��˰����
		IF Found("dbnexch_Fina")			&&	USD  > RM1
			USD2RM1 = dbnexch_Fina.Rate
		Endif
		Seek "USDHKD" in dbnexch_Fina order CODE_KEY
		IF Found("dbnexch_Fina")			&&  USD  >  HKD
			USD2HKD = dbnexch_Fina.Rate
		Endif
		Seek "USDRM2" in dbnexch_Fina order CODE_KEY		&& KS�ڲ�USD>RMB����
		IF Found("dbnexch_Fina")			&&  USD  >  RM2
			USD2RM2 = dbnexch_Fina.Rate
		Endif
		Seek "HKDRMB" in dbnexch_Fina order CODE_KEY
		IF Found("dbnexch_Fina")			&&   HKD  >  RMB
			HKD2RMB = dbnexch_Fina.Rate
		Endif
		Use in dbnexch_Fina
	Else
		If !Used(LaDbnmast)
			Return -9999999999
		Endif
		*Select (LaDbnmast)
		If Type('&Ladbnmast..USDHKD')='N'
			USD2HKD = &LaDbnmast..USDHKD
		EndIf
		If Type('&LaDbnmast..USDRMB')='N'
			USD2RMB = &LaDbnmast..USDRMB
		EndIf
		If Type('&LaDbnmast..USDRM1')='N'			&& RBM��˰����ֵ
			USD2RM1 = &LaDbnmast..USDRM1
		EndIf
		If Type('&LaDbnmast..USDRM2')='N'			&& KS�ڲ� USD>RMB ����
			USD2RM2 = &LaDbnmast..USDRM2
		EndIf
		If Type('&LaDbnmast..HKDRMB')='N'
			HKD2RMB = &LaDbnmast..HKDRMB
		EndIf
	Endif
	*!*		Select (select_wk)
	*!*		If recno_wk>0
	*!*			Go recno_wk
	*!*		EndIf
	Do case
		Case SourceCcy="USD" and DestCcy="USD"
			IF nAmt = -9999999999
				Return 1
			Else
				Return nAmt
			Endif
		Case SourceCcy="RMB" and DestCcy="RMB"
			IF nAmt = -9999999999
				Return 1
			Else
				Return nAmt
			Endif
		Case SourceCcy="HKD" and DestCcy="HKD"
			IF nAmt = -9999999999
				Return 1
			Else
				Return nAmt
			Endif
		Case SourceCcy="RM1" and DestCcy="RM1"
			IF nAmt = -9999999999
				Return 1
			Else
				Return nAmt
			Endif
		Case SourceCcy="USD" and DestCcy="RMB"
			IF nAmt = -9999999999
				Return USD2RMB
			Else
				Return nAmt*USD2RMB
			Endif
		Case SourceCcy="USD" and DestCcy="RM1"
			IF nAmt = -9999999999
				Return USD2RM1
			Else
				Return nAmt*USD2RM1
			EndIf
		Case SourceCcy="USD" and DestCcy="RM2"
			IF nAmt = -9999999999
				Return USD2RM2
			Else
				Return nAmt*USD2RM2
			EndIf
		Case SourceCcy="USD" and DestCcy="HKD"
			IF nAmt = -9999999999
				Return USD2HKD
			Else
				Return nAmt*USD2HKD
			Endif
		Case SourceCcy="HKD" and DestCcy="RMB"
			IF nAmt = -9999999999
				Return HKD2RMB
			Else
				Return nAmt*HKD2RMB
			Endif
		Case SourceCcy="RMB" and DestCcy="USD"
			IF nAmt = -9999999999
				Return 1/USD2RMB
			Else
				Return nAmt/USD2RMB
			Endif
		Case SourceCcy="RM1" and DestCcy="USD"
			IF nAmt = -9999999999
				Return 1/USD2RM1
			Else
				Return nAmt/USD2RM1
			Endif
		Case SourceCcy="RM2" and DestCcy="USD"
			IF nAmt = -9999999999
				Return 1/USD2RM2
			Else
				Return nAmt/USD2RM2
			Endif
		Case SourceCcy="HKD" and DestCcy="USD"
			IF nAmt = -9999999999
				Return 1/USD2HKD
			Else
				Return nAmt/USD2HKD
			Endif
		Case SourceCcy="RMB" and DestCcy="HKD"
			IF nAmt = -9999999999
				Return 1/HKD2RMB
			Else
				Return nAmt/HKD2RMB
			Endif
		otherwise
			Return -9999999999
			*!*				Seek SourceCcy+DestCcy in dbnexchR order Code_key
			*!*				IF Found("dbnexchR")
			*!*					Return dbnexchR.Rate
			*!*				Else
			*!*					Return -1
			*!*				Endif
	Endcase
EndFunc

Function itusedbf
	parameters dbfname,dbfalias,dbfcdx
	&& Eg .  itusedbf(dbfname,dbfalias)
	Local select_wk
	select_wk = select()
	IF !used(dbfalias)
		use (dbfname) in 0 again alias (dbfalias)
	Endif
	select (dbfalias)
	IF !Empty(dbfcdx)
		set order to dbfcdx
	Endif
	Select (Select_wk)
Endfunc


*!* && =============================================================== && *!*
Function Myreturn		&& Use this function to restore all environment setting
	parameters para1,para2,para3,para4,para5,para6,para7,para8,para9,para10
	&& Eg. Myreturn('error='+error_wk,'exact='+exact_wk)
	if pcount()<=0
		return .F.
	Endif
	local i
	for i=1 to pcount()
		parastring = 'para' + alltrim(str(i))
		if Empty(evaluate(parastring))
			Loop
		Endif
		parastring = lower(evaluate(parastring))
		paravalue = ''
		do case
			case 'error' $ parastring
				paravalue = alltrim(substr(parastring,at('=',parastring)+1))
				on error &paravalue.
			case 'near' $ parastring
				paravalue = alltrim(substr(parastring,at('=',parastring)+1))
				set near &paravalue.
			case 'exact' $ parastring
				paravalue = alltrim(substr(parastring,at('=',parastring)+1))
				set exact &paravalue.
			case 'safety' $ parastring
				paravalue = alltrim(substr(parastring,at('=',parastring)+1))
				set safety &paravalue.
			case 'udfparms' $ parastring
				paravalue = alltrim(substr(parastring,at('=',parastring)+1))
				set udfparms to &paravalue.
			case 'escape' $ parastring
				paravalue = alltrim(substr(parastring,at('=',parastring)+1))
				set escape &paravalue.
			case 'delete' $ parastring
				paravalue = alltrim(substr(parastring,at('=',parastring)+1))
				set delete &paravalue.
			case 'talk' $ parastring
				paravalue = alltrim(substr(parastring,at('=',parastring)+1))
				set talk &paravalue.
			case 'select' $ parastring
				paravalue = Int(Val(alltrim(substr(parastring,at('=',parastring)+1))))
				select (paravalue)
		Endcase
	endfor
	Return .T.
Endfunc
*!* && =============================================================== && *!*
Function EscToQuit		&& Check if the user pressed the Escape Key, and ask for continute.	, Return .T. means to quit the process.
	parameters LcWarnMsg,LcWarnTtl
	IF Empty(Def_lang)
		Def_lang = 'ENG'
	Endif
	if Empty(LcWarnMsg)
		LcWarnMsg = Iif(Def_lang='CHS','��ֹ�������еĲ���,��ȷ��Ҫ������?','This will cancel the running process, Are you sure?')
	Endif
	If Empty(LcWarnTtl)
		LcWarnTtl = IIF(Def_lang='CHS','��ʾ','Message')
	Endif
	if inkey()<>27
		return .F.
	Else
		if 1=messagebox(LcWarnMsg,33+256,LcWarnTtl)
			Return .T.
		Else
			Return .F.
		Endif
	Endif
	Return .F.
EndFunc

*!* && =============================================================== && *!*
Function RunDos
	PARAMETER doscmd
	DECLARE INTEGER WinExec IN win32api STRING command, INTEGER param
	*cmdstart = fullpath("FOXRUN.PIF")+" /C"+space(1)
	fullcmd=doscmd
	*fullcmd = cmdstart + doscmd
	&& ��ע�͵��������Կ���VFP��FoxRun����,������ܻ����һ��PIF�ļ�,������������Ҫ�����ڴ��DOS����.
	retval = WinExec(fullcmd, 0)
	clear dlls WinExec
	RETURN retval

	*!* && =============================================================== && *!*
Function XlsFillSelect
	parameters LoExcel,DestValue, HorizontalAlignment,VerticalAlignment,LcFont,LnFontSize,LtBold,LtItalic, LnWidth,LcFormart,LcForceColor,LcBackColor
	&&  ������ѡ��ĵ�Ԫ��ֵ����ʽ.
	&&  ����	Excel ����, ֵ,ˮƽ���뷽ʽ,��ֱ���뷽ʽ , ����, �����С, �Ƿ����,�Ƿ�б��, ��Ԫ����, ��Ԫ���ʽ,������ɫ,��Ӱ��ɫ
	&&	Eg.		XlsFillSelect(Loexcl,MyValue,"Center","Center","Arial Narrow",9,.F.,.F.,5.63,"#,##0.00_ ",'blue','yellow')
	IF vartype(LoExcel) # 'O'
		Return -1
	Endif
	IF Empty(DestValue)
		DestValue = ""
	Endif
	Loexcel.selection.value = DestValue
	if !Empty(HorizontalAlignment)
		Do case
			case lower(HorizontalAlignment)="left"
				HorizontalAlignment = -4130
			case lower(HorizontalAlignment)="center"
				HorizontalAlignment = -4108
			case lower(HorizontalAlignment)="right"
				HorizontalAlignment = -4152
		Endcase
		Loexcel.selection.HorizontalAlignment=HorizontalAlignment
	Endif
	If !Empty(VerticalAlignment)
		Do case
			Case lower(VerticalAlignment)="top"
				VerticalAlignment=-4160
			Case lower(VerticalAlignment)="center"
				VerticalAlignment=-4108
			case lower(VerticalAlignment)="buttom"
				VerticalAlignment=-4107
		Endcase
		Loexcel.selection.VerticalAlignment=VerticalAlignment
	Endif
	IF !Empty(LcFont)
		Loexcel.selection.Font.name=LcFont
	Endif
	IF !empty(LnFontSize)
		loexcel.selection.Font.size = LnFontSize
	Endif
	If !empty(LtBold)
		Loexcel.selection.Font.Bold = LtBold
	Endif
	if !Empty(LtItalic)
		Loexcel.selection.Font.Italic=LtItalic
	Endif
	If !Empty(LnWidth)
		If LnWidth = -1
			*Loexcel.selection.columns.autofit
			Loexcel.selection.EntireColumn.autofit
		Else
			Loexcel.selection.ColumnWidth = LnWidth
		Endif
	Endif
	If !Empty(LcFormart)
		Loexcel.selection.NumberFormatLocal=LcFormart
	EndIf
	If !Empty(LcForceColor) or !Empty(LcBackColor)
		Dimension laColorindex(30,2)
		LaColorindex(1,1)='nofull'
		LaColorindex(1,2)=-4142
		LaColorindex(2,1)='auto'
		LaColorindex(2,2)=0
		LaColorindex(3,1)='white'
		LaColorindex(3,2)=2
		LaColorindex(4,1)='black'
		LaColorindex(4,2)=1
		LaColorindex(5,1)='darkred'
		LaColorindex(5,2)=9
		LaColorindex(6,1)='brown'
		LaColorindex(6,2)=53
		LaColorindex(7,1)='red'
		LaColorindex(7,2)=3
		LaColorindex(8,1)='pink'
		LaColorindex(8,2)=7
		LaColorindex(9,1)='rose'
		LaColorindex(9,2)=38
		LaColorindex(10,1)='gold'
		LaColorindex(10,2)=44
		LaColorindex(11,1)='orange'
		LaColorindex(11,2)=46
		LaColorindex(12,1)='lightorange'
		LaColorindex(12,2)=45
		LaColorindex(13,1)='lime'
		LaColorindex(13,2)=43
		LaColorindex(14,1)='tan'
		LaColorindex(14,2)=40
		LaColorindex(15,1)='yellow'
		LaColorindex(15,2)=6
		LaColorindex(16,1)='lightyellow'
		LaColorindex(16,2)=36
		LaColorindex(17,1)='seagreen'
		LaColorindex(17,2)=50
		LaColorindex(18,1)='brightgreen'
		LaColorindex(18,2)=4
		LaColorindex(19,1)='lightgreen'
		LaColorindex(19,2)=35
		LaColorindex(20,1)='teal'
		LaColorindex(20,2)=14
		LaColorindex(21,1)='aqua'
		LaColorindex(21,2)=42
		LaColorindex(22,1)='turquoise'
		LaColorindex(22,2)=8
		LaColorindex(23,1)='blue'
		LaColorindex(23,2)=5
		LaColorindex(24,1)='lightblue'
		LaColorindex(24,2)=41
		LaColorindex(25,1)='paleblue'
		LaColorindex(25,2)=37
		LaColorindex(26,1)='blue-gray'
		LaColorindex(26,2)=47
		LaColorindex(27,1)='violet'
		LaColorindex(27,2)=13
		LaColorindex(28,1)='lavender'
		LaColorindex(28,2)=39
		LaColorindex(29,1)='gray40%'
		LaColorindex(29,2)=48
		LaColorindex(30,1)='gray25%'
		LaColorindex(30,2)=15
		Local nColoerIndex,nFind
		nColoerIndex = 0
		nFind=0
		If !Empty(LcForceColor)
			nFind=Ascan(LaColorindex,Lower(LcForceColor))
			If nFind>0
				nColorIndex = LaColorindex(Asubscript(LaColorindex,nFind,1),2)
			Else
				nColorIndex=0
			EndIf
			Loexcel.selection.Font.ColorIndex = nColorIndex
		EndIf
		nFind=0
		If !Empty(LcBackColor)
			nFind=Ascan(LaColorindex,Lower(LcForceColor))
			If nFind>0
				nColorIndex = LaColorindex(Asubscript(LaColorindex,nFind,1),2)
			Else
				nColorIndex=-4142
			EndIf
			Loexcel.selection.Interior.ColorIndex = nColorIndex
		Endif
	Endif
	Return 0
EndFunc
*!* && =============================================================== && *!*
Function fixtemp
	parameters dbfpath,dbfname,copyrange,ClearHis
	&& Eg.  fixtemp(set_newincl,"qryso",.T.,.T.)	&& copy all the file who named ysfso.* to include folder.  .T. means copy all the file who named "qryso", Default is .F., only copy one file.
	&& ClearHis Means to ZAP this temp file.
	if Empty(dbfpath) or Empty(dbfname) or vartype(dbfpath)<>'C' or vartype(dbfname)<>'C'
		Return .F.
	Endif
	if !directory(dbfpath)
		return .F.
	Endif
	Local set_safety,Error_wk,_isError,select_wk
	Select_wk = Alltrim(Str(select()))
	set_safety = set('safety')
	set safety off
	error_wk= on('error')
	On error _isError=.T.
	if Empty(Justext(dbfname))
		dbfname = dbfname + ".dbf"
	Endif
	local plsourcefile,pllocalpath,pllocalfile
	pllocalpath = addbs(SET('directory'))+'include'
	if !directory(pllocalpath)
		=Myreturn('error='+error_wk,'safety='+set_safety,'Select='+Select_wk)
		return .F.
	Endif
	plsourcefile = addbs(dbfpath)+dbfname
	pldestfile = addbs(pllocalpath)+dbfname
	if Empty(copyrange)  or vartype(copyrange)<>'L'		&& Copyrange is false, only copy specify file.
		if !File(plsourcefile)
			=Myreturn('error='+error_wk,'safety='+set_safety,'Select='+Select_wk)
			return .F.				&& Source file does not exist.
		Endif
		dbfname = juststem(pldestfile)
		if used(dbfname)
			use in &dbfname.
		Endif
		*delete file &pldestfile.
		Copy file &plsourcefile. to &pllocalpath.
		If file(pldestfile)
			=Myreturn('error='+error_wk,'safety='+set_safety,'Select='+Select_wk)
			Return .T.
		Else
			=Myreturn('error='+error_wk,'safety='+set_safety,'Select='+Select_wk)
			Return .F.
		Endif
		if !Empty(ClearHis)
			on error _isError= .T.
			use (addbs(pllocalpath)+dbfname) in 0 again alias _ClearTempHis exclusive
			if upper(alias())=='_CLEARTEMPHIS'
				zap
			Endif
			use in _ClearTempHis
		Endif
	Endif
	Local Lcfilename			&&		Begain to copy all file
	LcFilename = juststem(dbfname)+'.*'
	local cur_defa
	cur_defa=sys(5)+sys(2003)
	cd &dbfpath.
	nFile = adir(lcarray,Lcfilename)
	cd &cur_defa.
	if nFile=0
		=Myreturn('error='+error_wk,'safety='+set_safety,'Select='+Select_wk)
		Return .F.
	Endif
	for i=1 to nFile
		plsourcefile = addbs(dbfpath) + lcarray(i,1)
		pldestfile = addbs(pllocalpath) + lcarray(i,1)
		dbfname = juststem(lcarray(i,1))
		if used(dbfname)
			use in &dbfname.
		Endif
		*delete file &pldestfile.
		copy file &plsourcefile. to &pllocalpath.
		if !file(pldestfile)
			=Myreturn('error='+error_wk,'safety='+set_safety,'Select='+Select_wk)
			return .F.
		Endif
		if !Empty(ClearHis) and Upper(justext(dbfname))='DBF'
			on error _isError= .T.
			use (addbs(pllocalpath)+dbfname) in 0 again alias _ClearTempHis exclusive
			if upper(alias())=='_CLEARTEMPHIS'
				zap
			Endif
			use in _ClearTempHis
		Endif
	Endfor
	if _isError
		=Myreturn('error='+error_wk,'safety='+set_safety,'Select='+Select_wk)
		return .F.
	Else
		return .T.
	Endif
Endfunc
*!* && =============================================================== && *!*
Function itMonth
	Parameters Currdate
	If Empty(Currdate)
		Currdate = Date()
	EndIf
	Do case
		Case Vartype(Currdate)='N' and Currdate>=1 and Currdate<=12
			Return nTocMonth(Currdate)
		Case Vartype(Currdate)='D' or Vartype(Currdate)='T'
			Return nTocMonth(Month(Currdate))
		Otherwise
			Return '#Non#'
	Endcase
EndFunc
Function nTocMonth
	Parameters nMonth
	If Vartype(nMonth)<>'N' or !(nMonth>=1 and nMonth<=12)
		Return '#Non#'
	Endif
	Do case
		Case nMonth = 1
			Return 'Jan'
		Case nMonth = 2
			Return 'Feb'
		Case nMonth = 3
			Return 'Mar'
		Case nMonth = 4
			Return 'Apr'
		Case nMonth = 5
			Return 'May'
		Case nMonth = 6
			Return 'Jun'
		Case nMonth = 7
			Return 'Jul'
		Case nMonth = 8
			Return 'Aug'
		Case nMonth = 9
			Return 'Sep'
		Case nMonth = 10
			Return 'Oct'
		Case nMonth = 11
			Return 'Nov'
		Case nMonth = 12
			Return 'Dec'
		Otherwise
			Return '#Non#'
	Endcase
EndFunc

Function XlsFillPic
	Parameters Loexcel,Pic_path,LnPicHight,LnPicWidth,LnRightoffset,LnBottomOffset
	&& Excel����,ͼƬ·��,�߶�,���,����ƫ��λ��,����ƫ��λ�� (�԰�һ�η����*0.75��)
	IF vartype(LoExcel) # 'O'
		Return .F.
	Endif
	IF Empty(Pic_Path) or !File(Pic_path)
		Pic_Path = ''
		Return .F.
	Endif
	LoExcel.ActiveSheet.Pictures.Insert(Pic_path).Select
	LoExcel.Selection.ShapeRange.LockAspectRatio = -1	&& ����������
	LnOrgHight = LoExcel.Selection.ShapeRange.Height	&& ԭʼ�߶�
	LnOrgWidth = LoExcel.Selection.ShapeRange.Width	&& ԭʼ���
	If !Empty(LnRightoffset) and vartype(LnRightoffset)='N'
		LoExcel.Selection.ShapeRange.IncrementLeft(LnRightoffset * 0.75)
	Endif
	If !Empty(LnBottomOffset) and vartype(LnBottomOffset)='N'
		LoExcel.Selection.ShapeRange.IncrementTop(LnBottomOffset * 0.75)
	Endif
	Do case
		Case Empty(LnPicHight) and Empty(LnPicWidth)
			Return .T.
		Case !Empty(LnPicHight) and Empty(LnPicWidth)
			LnRate = LnPicHight/LnOrgHight
			LnPicWidth = LnRate * LnOrgWidth
		Case Empty(LnPicHight) and !Empty(LnPicWidth)
			LnRate = LnPicWidth/LnOrgWidth
			LnPicHight = LnRate * LnOrgHight
	EndCase
	LoExcel.Selection.ShapeRange.Height =LnPicHight
	LoExcel.Selection.ShapeRange.Width =LnPicWidth
	Return .T.
Endfunc

******************
*!*	��������:getPict_File(�ϴ����,Դ�ļ���,�ļ�����,�ļ����[,ͼƬ��ʽ][,ͼƬ��С])
*!*	�ϴ����;<PROD,FILE,OTHER>
*!*	Դ�ļ���:������Դ�ļ���·��
*!*	�ļ�����:���ݲ�Ʒ�ķ��ഴ���ļ���
*!*	�ļ����:��Ʒ�ı�Ż��ͬ���
*!*	ͼƬ��ʽ:��Ҫ������ͼƬ������,����.....
*!* ͼƬ��С:Ϊ��ʱ������ͼƬ�Ĵ�С����֮��ͼƬ��С��������
*!*	��:getPict_File('PROD','d:\aa\bb.jpeg','TY','TY-001','0','1')
******************
FUNCTION getpict_file
	PARAMETER ftptype,LcSourceFile,LcProdClass,LcProdName,PicSide,PicSizeCtro
	&& �ϴ����,Դ�ļ���,�ļ�����,�ļ����,ͼƬ����,ͼƬ��С
	&& GetPict_File('PROD','d:\aa\bb.jpeg','TY','TY-001','0','1')
	&& ͼƬ��ʽ,��,��ʾ����,2,����,3,���,4,�ұ�,5,�Ϸ�,6,�·�,7,��ͼ
	LOCAL lname,lpath,fname,lLcProdName,filesize
	fname=UPPER(SUBSTR(LcSourceFile,RAT("\",LcSourceFile)+1))
	LcProdClass =UPPER(CHRTRAN(ALLT(LcProdClass),'\/|*?','-----'))
	lLcProdName =UPPER(CHRTRAN(ALLT(LcProdName),'\/|*?','-----'))
	DO CASE
		CASE UPPER(ALLT(ftptype))='PROD'
			If !File(LcSourceFile) or "["$LcSourceFile or "]"$LcSourceFile
				MessageBox("�ļ������Ϸ�!        ",16,"Error")
				Return ""
			EndIf
			IF EMPTY(PicSizeCtro)	&& δָ��ͼƬ��С
				If !Empty(security_id) and (Alltrim(security_id)=='SUPERVISOR' or Alltrim(security_id)="BOS")
				Else
					SET COMPATIBLE ON
					filesize=FSIZE(LcSourceFile)
					IF filesize>512000
						MESSAGEBOX('ѡȡ��ͼƬ������ѡ��һ��500KB֮�ڵ�ͼƬ',16,'����ʧ��')
						SET COMPATIBLE OFF
						Return ""
					ENDIF
					SET COMPATIBLE OFF
				EndIf
			ENDIF
			IF !EMPTY(PicSide)	&& ͼƬ����,��(Ĭ��),��ʾ����,2,����,3,���,4,�ұ�,5,�Ϸ�,6,�·�,7,��ͼ
				lname=lLcProdName+'.'+ALLT(PicSide)+'.'+JUSTEXT(fname)
			ELSE
				lname=lLcProdName+'.'+JUSTEXT(fname)
			ENDIF
			IF !DIRECTORY(ADDBS(set_photos)+'products')
				MKDIR ADDBS(set_photos)+'PRODUCTS'
			ENDIF
			IF !DIRECTORY(ADDBS(set_photos)+'products\'+UPPER(ALLT(LcProdClass)))
				MKDIR ADDBS(set_photos)+'PRODUCTS\'+UPPER(ALLT(LcProdClass))
			ENDIF
			lpath=UPPER(ADDBS(set_photos)+'products\'+UPPER(ALLT(LcProdClass))+'\'+lname)
		CASE UPPER(ALLT(ftptype))='FILE'
			&& ��Ftptype=FILEʱ, LcProdClass Ϊ��ͬ��,PicSide Ϊ�ļ�����,����ͬ�Ž�Ŀ¼,�ļ�(��Ʒ)��+�������ļ�
			&& ͬ��ͬ�йص�ͼƬʱ,ȡ�ļ���Ϊ ��ͬ��\Product_id+nth_dtl, ��ʱ���� LcProdName Ϊ ��Ʒ��
			&& ����Ǻ�ͬ����ļ�,ȡ�ļ���Ϊ ��ͬ��\�ļ���+����(1,2,3,...),	��ʱ���� LcProdName Ϊ�ļ���
			If !File(LcSourceFile) or "["$LcSourceFile or "]"$LcSourceFile
				MessageBox("�ļ������Ϸ�!        ",16,"Error")
				Return ""
			EndIf
			IF !DIRECTORY(ADDBS(set_photos)+'file')
				MKDIR ADDBS(set_photos)+'FILE'
			ENDIF
			IF !DIRECTORY(ADDBS(set_photos)+'file\'+UPPER(ALLT(LcProdClass)))
				MKDIR ADDBS(set_photos)+'file\'+UPPER(ALLT(LcProdClass))
			EndIf
			IF !EMPTY(PicSide)
				lname=lLcProdName+'.'+ALLT(PicSide)+'.'+JUSTEXT(fname)
			ELSE
				lname=lLcProdName+'.'+JUSTEXT(fname)
			EndIf
			lpath=UPPER(ADDBS(set_photos)+'file\'+UPPER(ALLT(LcProdClass))+'\'+lname)
		OTHERWISE
			If !File(LcSourceFile) or "["$LcSourceFile or "]"$LcSourceFile
				MessageBox("�ļ������Ϸ�!        ",16,"Error")
				Return ""
			EndIf
			IF !DIRECTORY(ADDBS(set_photos)+'other')
				MKDIR ADDBS(set_photos)+'OTHER'
			ENDIF
			IF !DIRECTORY(ADDBS(set_photos)+'other\'+UPPER(ALLT(LcProdClass)))
				MKDIR ADDBS(set_photos)+'other\'+UPPER(ALLT(LcProdClass))
			ENDIF
			IF !EMPTY(PicSide)
				lname=lLcProdName+'.'+ALLT(PicSide)+'.'+JUSTEXT(fname)
			ELSE
				lname=lLcProdName+'.'+JUSTEXT(fname)
			EndIf
			lpath=UPPER(ADDBS(set_photos)+'other\'+UPPER(ALLT(LcProdClass))+'\'+lname)
	ENDCASE
	IF FILE(lpath)
		yn=MESSAGEBOX('�ļ��Ѵ��ڣ��Ƿ񸲸ǣ�',4+32+256,'��ʾ��Ϣ')
		IF yn<>6
			Return ""
		ENDIF
	EndIf
	Wait window "�����ϴ��ļ�,���Ե� ..." nowait
	IF FILE(LcSourceFile)
		COPY FILE [&LcSourceFile.] TO [&lpath.]
	EndIf
	SET COMPATIBLE ON
	LnFileSize1 = Fsize(LcSourceFile)
	LnFileSize2 = Fsize(lpath)
	If !File(lpath) or LnFileSize1<>LnFileSize2
		MessageBox("�ϴ��ļ�ʧ��,�������Ƿ���Ȩ�޸ķ������ļ�,��������ʾ��������,����ϵͳ����Ա��ϵ.",16,"iTrader")
		SET COMPATIBLE OFF
		Return ""
	EndIf
	SET COMPATIBLE OFF
	Wait clear
	RETURN  UPPER(lpath)
ENDFUN

FUNCTION  registry
	PARAMETERS    nReg_code,;&&�������룬0-�����Ӽ���1-дע���2-��ע���3-ɾ��ע�����
	cReg_MainKey,;              &&ע�������
	cReg_skey,;                        &&�Ӽ�
	cReg_skey_New,;                &&�贴�����Ӽ�
	cReg_skeyname,;                &&ע�����
	cReg_keyvalue,;                &&ע������ֵ
	nReg_ValueType                  &&ע������ֵ������,1-���ݴ�,2-Unicode  ��,3-������,4-32-λ��ֵ

	*����ע���
	*�﷨��
	*�����Ӽ���registry(0,����ֵ,�Ӽ���,�½��Ӽ���)
	*дע���registry(1,����ֵ,�Ӽ���,,ע����,��Ŀֵ)
	*��ע���registry(2,����ֵ,�Ӽ���,,ע����)
	*ɾ���Ӽ���registry(3,����ֵ,�Ӽ���)
	&& registry(2,"HKCU","Software",,"YYYY")

	Local Error_wk,_isError
	ON  ERROR  _isError = .T.
	LOCAL  nDisposition,;
		lnResult,;            &&Ҫȡ��ֵ��ע�������ĵ�ַ
	nResult,;
		ReturnValue,;      &&���ص�ע���ֵ
	nKeyLength,;        &&Ҫд��ֵ�ĳ���
	BUFFER,;                &&����ע�����ֵ
	BufferSize,;        &&����ֵ�ĳ���
	lnError,;              &&����ע������Ĵ������
	nError,;                &&���صĴ������
	skey1,skey2

	Do case
		Case Upper(cReg_MainKey)='HKEY_CLASSES_ROOT' or Upper(cReg_MainKey)='HKCR'
			nReg_MainKeyNo = bitset(0,31) &&-2147483648
		Case Upper(cReg_MainKey)='HKEY_CURRENT_USER' or Upper(cReg_MainKey)='HKCU'
			nReg_MainKeyNo = bitset(0,31)+1 &&-2147483647
		Case Upper(cReg_MainKey)='HKEY_LOCAL_MACHINE' or Upper(cReg_MainKey)='HKLM'
			nReg_MainKeyNo = bitset(0,31)+2 &&-2147483646
		Case Upper(cReg_MainKey)='HKEY_USER' or Upper(cReg_MainKey)='HKUR'
			nReg_MainKeyNo = bitset(0,31)+3 &&-2147483645
		Case Upper(cReg_MainKey)='HKEY_CURRENT_CONFIG' or Upper(cReg_MainKey)='HKCC'
			nReg_MainKeyNo = bitset(0,31)+5 &&-2147483643
		Case Upper(cReg_MainKey)='HKEY_DYN_DATA' or Upper(cReg_MainKey)='HKDD'
			nReg_MainKeyNo = bitset(0,31)+6 &&-2147483642
		Otherwise
			On Error &Error_wk.
			Return .F.
	EndCase

	IF  nReg_code=1  AND  !BETWEEN(nReg_ValueType,1,4)
		RETURN  .F.
	ENDIF
	*nReg_MainKeyNo=nReg_MainKeyNo-2147483649
	*ע����ֵ����Ȩ��
	#DEFINE  KEY_ALL_ACCESS                          983103                    &&����Ȩ��

	DECLARE  INTEGER  RegOpenKeyEx  IN  Win32API  ;
		INTEGER  nKey,;
		STRING  @cSubKey,  ;
		INTEGER  nReserved,;
		INTEGER  nAccessMask,;
		INTEGER  @nResult

	DECLARE  INTEGER  RegQueryValueEx  IN  Win32API;
		INTEGER  nKey,  ;
		STRING  cValueName,  ;
		INTEGER  nReserved,;
		INTEGER  @nType,  ;
		STRING  @cBuffer,  ;
		INTEGER  @nBufferSize

	DECLARE  RegCreateKeyEx  IN  WIN32API;
		INTEGER  hKey,;                                &&һ������ľ��������һ����׼����
	STRING  lpSubKey,;                          &&�������������������
	INTEGER  Reserved,;                        &&��Ϊ��
	STRING  lpClass,;                            &&�������
	INTEGER  dwOptions,;                      &&��,������ʽ����������ϵͳ�������������ʧ
	INTEGER  samDesired,;                    &&����Ȩ��
	INTEGER  lpSecurityAttributes,;	   &&�������İ�ȫ���Խ���������һ���ṹ,��
	INTEGER  @phkResult,;                    &&ָ������װ������������һ������
	INTEGER  @lpdwDisposition            &&�������½�����,���Ǵ�����(����½����������)

	DECLARE  RegDeleteKey  IN  WIN32API;
		INTEGER  hKey,;
		STRING  lpSubKey

	DECLARE  INTEGER  RegCloseKey  IN  Win32API  INTEGER  nKey

	DECLARE  INTEGER  RegSetValueEx  IN  Win32API;
		INTEGER  hKey,;
		STRING  lpValueName,;
		INTEGER  Reserved,;
		INTEGER  dwType,;
		STRING    lpData,;
		INTEGER  cbData

	DO CASE
		CASE  nReg_code=0          &&�����ӽ�
			nResult=  0
			nDisposition  =  0
			nError  =  RegOpenKeyEx(nReg_MainKeyNo,cReg_sKey,0,  KEY_ALL_ACCESS,  @nResult)
			IF  nError#0
				MESSAGEBOX('Can`t  open  the  sub_key!',0+48,'INF')
				RETURN  .F.
			ENDIF
			nError=RegCreateKeyEx(nResult,cReg_sKey_New,0,'nReg_ValueType',0,KEY_ALL_ACCESS,0,@lnResult,@nDisposition)
			=RegCloseKey(nResult)
			RETURN  nError
			***********************************
		CASE  nReg_code=1    &&дע���
			nError=0
			nError  =RegOpenKeyEx(nReg_MainKeyNo,cReg_sKey,  0,KEY_ALL_ACCESS,  @lnResult)
			IF  nError#0
				MESSAGEBOX('Can`t  write  the  sub_key!',0+48,'INF')
				RETURN  .F.
			ENDIF
			nKeyLength=LEN(cReg_KeyValue)
			nError=RegSetValueEx(lnResult,cReg_sKeyName,0,nReg_ValueType,  @cReg_KeyValue,  @nKeyLength)
			=RegCloseKey(lnResult)
			RETURN  nError=0
			***********************************
		CASE  nReg_code=2              &&��ע���
			ReturnValue  =  ""
			lnResult  =  0
			BUFFER  =  SPACE(128)
			BufferSize  =  128
			lnError  =  RegOpenKeyEx(nReg_MainKeyNo,cReg_sKey,  0,  KEY_ALL_ACCESS,  @lnResult)
			IF  lnError  =  0
				lnType  =  0
				lnError  =  RegQueryValueEx(lnResult,  cReg_skeyname,  0,  @lnType,  @BUFFER,  @BufferSize)
				IF  lnError  =  0  AND  BUFFER  <>  CHR(0)                        &&���������Ϊ  0,  ����������ȡֵ.
					ReturnValue  =  LEFT(BUFFER,  BufferSize  -  1)  &&ȡ�÷���ֵ
				ENDIF
			ENDIF
			=RegCloseKey(lnResult)
			RETURN  ReturnValue
			***********************************
		CASE  nReg_code=3                &&ɾ��ע�����
			skey1=LEFT(cReg_sKey,AT('\',cReg_sKey,OCCURS('\',cReg_sKey))-1)
			skey2=SUBST(cReg_sKey,AT('\',cReg_sKey,OCCURS('\',cReg_sKey))+1)
			nError  =RegOpenKeyEx(nReg_MainKeyNo,sKey1,  0,KEY_ALL_ACCESS,  @lnResult)
			IF  nError#0
				MESSAGEBOX('Can`t  delete  the  sub_key!',0+48,'INF')
				RETURN  .F.
			ELSE
				nError=RegDeleteKey(lnResult,sKey2)
			ENDIF
			RETURN  nError
	ENDCASE
ENDFUNC

*!* && =============================================================== && *!*
Function ShellAndWait( tcDosCommand, IsDos, IsShow )
	&& = ShellAndWait("Notepad.exe")							&&  �����ⲿ���������ʱ�ȴ����
	&& = ShellAndWait( [Ping 127.0.0.1 > D:\TestPing.txt], .T., .F. )
	IsDos = Iif(Parameters()>=2 And Type([IsDos])=[L], IsDos, .F.)
	IsShow = Iif(Parameters()>=3 And Type([IsShow])=[L], IsShow, !IsDos)
	Local lcCmdStr
	If IsDos
		If Empty(Getenv([OS]))
			lcCmdStr = [Command.com /C ] + tcDosCommand + Chr(0)
		Else
			lcCmdStr = [Cmd.exe /C ] + tcDosCommand + Chr(0)
		Endif
	Else
		lcCmdStr = tcDosCommand + Chr(0)
	Endif

	#Define NORMAL_PRIORITY_CLASS     32
	#Define IDLE_PRIORITY_CLASS       64
	#Define HIGH_PRIORITY_CLASS      128
	#Define INFINITE                  -1
	#Define REALTIME_PRIORITY_CLASS 1600

	Declare Integer CloseHandle In kernel32 Long hObject
	Declare Integer WaitForSingleObject In kernel32 Long hHandle, Long dwMilliseconds
	Declare Integer CreateProcessA In kernel32 ;
		Long lpApplicationName, ;
		String lpCommandLine, ;
		Long lpProcessAttributes, ;
		Long lpThreadAttributes, ;
		Long bInheritHandles, ;
		Long dwCreationFlags, ;
		Long lpEnvironment, ;
		Long lpCurrentDirectory, ;
		String @lpStartupInfo, ;
		String @lpProcessInformation

	Local lcStartupInfo, lcProcessInformation, RetCode, hProcess
	lcStartupInfo = Long2Str(68) + Replicate(Chr(0), 40) + Chr(Iif(IsShow,0,1)) + Replicate(Chr(0), 23)
	lcProcessInformation = Replicate(Chr(0), 16)

	RetCode = CreateProcessA(0, lcCmdStr, 0, 0, 1, NORMAL_PRIORITY_CLASS, 0, 0, @lcStartupInfo, @lcProcessInformation )
	hProcess = Str2Long(Substr(lcProcessInformation, 1, 4))
	RetCode = WaitForSingleObject(hProcess, INFINITE)
	RetCode = CloseHandle(hProcess)

	Return RetCode
Endfunc

Function Long2Str( lnLongVal )
	Private i, retustr
	retustr = []
	For i = 24 To 0 Step -8
		retustr = Chr(Int(lnLongVal/(2^i))) + retustr
		lnLongVal = Mod(lnLongVal, (2^i))
	Next
	Return retustr
Endfunc

Function Str2Long( tcLongStr )
	Private i, RetuVal
	RetuVal = 0
	For i = 0 To 24 Step 8
		RetuVal = RetuVal + (Asc(tcLongStr) * (2^i))
		tcLongStr = Right(tcLongStr, Len(tcLongStr) - 1)
	Next
	Return RetuVal
Endfunc

*!* && =============================================================== && *!*
Function XlsFillCells
	parameters LoExcel,LRowNo,LColNo,DestValue, HorizontalAlignment,VerticalAlignment,LcFont,LnFontSize,LtBold,LtItalic, LnWidth,LcFormart,LcForceColor,LcBackColor
	&&  ������ѡ��ĵ�Ԫ��ֵ����ʽ. ԭ XlsFillSelect ������,��Ϊֱ���� Cells ��ֵ,�������ٶ�.
	&&  ����	Excel ����,��,��,ֵ,ˮƽ���뷽ʽ,��ֱ���뷽ʽ , ����, �����С, �Ƿ����,�Ƿ�б��, ��Ԫ����, ��Ԫ���ʽ,������ɫ,��Ӱ��ɫ
	&&	Eg.		XlsFillCells(Loexcl,3,2,MyValue,"Center","Center","Arial Narrow",9,.F.,.F.,5.63,"#,##0.00_ ",'blue','yellow')
	IF vartype(LoExcel) # 'O'
		Return -1
	EndIf
	If Empty(LRowNo) or Empty(LColNo) or Vartype(LRowNo)<>"N" or Vartype(LColNo)<>"N"
		Return -1
	EndIf
	IF Empty(DestValue)
		DestValue = ""
	Endif
	Loexcel.Cells(LRowNo,LColNo).value = DestValue
	if !Empty(HorizontalAlignment)
		Do case
			case lower(HorizontalAlignment)="left"
				HorizontalAlignment = -4130
			case lower(HorizontalAlignment)="center"
				HorizontalAlignment = -4108
			case lower(HorizontalAlignment)="right"
				HorizontalAlignment = -4152
		Endcase
		Loexcel.Cells(LRowNo,LColNo).HorizontalAlignment=HorizontalAlignment
	Endif
	If !Empty(VerticalAlignment)
		Do case
			Case lower(VerticalAlignment)="top"
				VerticalAlignment=-4160
			Case lower(VerticalAlignment)="center"
				VerticalAlignment=-4108
			case lower(VerticalAlignment)="buttom"
				VerticalAlignment=-4107
		Endcase
		Loexcel.Cells(LRowNo,LColNo).VerticalAlignment=VerticalAlignment
	Endif
	IF !Empty(LcFont)
		Loexcel.Cells(LRowNo,LColNo).Font.name=LcFont
	Endif
	IF !empty(LnFontSize)
		loexcel.Cells(LRowNo,LColNo).Font.size = LnFontSize
	Endif
	If !empty(LtBold)
		Loexcel.Cells(LRowNo,LColNo).Font.Bold = LtBold
	Endif
	if !Empty(LtItalic)
		Loexcel.Cells(LRowNo,LColNo).Font.Italic=LtItalic
	Endif
	If !Empty(LnWidth)
		If LnWidth = -1
			*Loexcel.selection.columns.autofit
			Loexcel.Cells(LRowNo,LColNo).EntireColumn.autofit
		Else
			Loexcel.Cells(LRowNo,LColNo).ColumnWidth = LnWidth
		Endif
	Endif
	If !Empty(LcFormart)
		Loexcel.Cells(LRowNo,LColNo).NumberFormatLocal=LcFormart
	EndIf
	If !Empty(LcForceColor) or !Empty(LcBackColor)
		Dimension laColorindex(30,2)
		LaColorindex(1,1)='nofull'
		LaColorindex(1,2)=-4142
		LaColorindex(2,1)='auto'
		LaColorindex(2,2)=0
		LaColorindex(3,1)='white'
		LaColorindex(3,2)=2
		LaColorindex(4,1)='black'
		LaColorindex(4,2)=1
		LaColorindex(5,1)='darkred'
		LaColorindex(5,2)=9
		LaColorindex(6,1)='brown'
		LaColorindex(6,2)=53
		LaColorindex(7,1)='red'
		LaColorindex(7,2)=3
		LaColorindex(8,1)='pink'
		LaColorindex(8,2)=7
		LaColorindex(9,1)='rose'
		LaColorindex(9,2)=38
		LaColorindex(10,1)='gold'
		LaColorindex(10,2)=44
		LaColorindex(11,1)='orange'
		LaColorindex(11,2)=46
		LaColorindex(12,1)='lightorange'
		LaColorindex(12,2)=45
		LaColorindex(13,1)='lime'
		LaColorindex(13,2)=43
		LaColorindex(14,1)='tan'
		LaColorindex(14,2)=40
		LaColorindex(15,1)='yellow'
		LaColorindex(15,2)=6
		LaColorindex(16,1)='lightyellow'
		LaColorindex(16,2)=36
		LaColorindex(17,1)='seagreen'
		LaColorindex(17,2)=50
		LaColorindex(18,1)='brightgreen'
		LaColorindex(18,2)=4
		LaColorindex(19,1)='lightgreen'
		LaColorindex(19,2)=35
		LaColorindex(20,1)='teal'
		LaColorindex(20,2)=14
		LaColorindex(21,1)='aqua'
		LaColorindex(21,2)=42
		LaColorindex(22,1)='turquoise'
		LaColorindex(22,2)=8
		LaColorindex(23,1)='blue'
		LaColorindex(23,2)=5
		LaColorindex(24,1)='lightblue'
		LaColorindex(24,2)=41
		LaColorindex(25,1)='paleblue'
		LaColorindex(25,2)=37
		LaColorindex(26,1)='blue-gray'
		LaColorindex(26,2)=47
		LaColorindex(27,1)='violet'
		LaColorindex(27,2)=13
		LaColorindex(28,1)='lavender'
		LaColorindex(28,2)=39
		LaColorindex(29,1)='gray40%'
		LaColorindex(29,2)=48
		LaColorindex(30,1)='gray25%'
		LaColorindex(30,2)=15
		Local nColoerIndex,nFind
		nColoerIndex = 0
		nFind=0
		If !Empty(LcForceColor)
			nFind=Ascan(LaColorindex,Lower(LcForceColor))
			If nFind>0
				nColorIndex = LaColorindex(Asubscript(LaColorindex,nFind,1),2)
			Else
				nColorIndex=0
			EndIf
			Loexcel.Cells(LRowNo,LColNo).Font.ColorIndex = nColorIndex
		EndIf
		nFind=0
		If !Empty(LcBackColor)
			nFind=Ascan(LaColorindex,Lower(LcBackColor))
			If nFind>0
				nColorIndex = LaColorindex(Asubscript(LaColorindex,nFind,1),2)
			Else
				nColorIndex=-4142
			EndIf
			Loexcel.Cells(LRowNo,LColNo).Interior.ColorIndex = nColorIndex
			Loexcel.Cells(LRowNo,LColNo).Interior.Pattern = 1
		Endif
	EndIf
	Return 0
EndFunc

*!* && =============================================================== && *!*
Function EnCodingPrice
	Parameters LcNPrice,LcTerm,LcCcy
	Local PriceCode,isDrowback
	IF Empty(LcNprice)
		LcNprice =0
	Endif
	IF Empty(LcTerm)
		LcTerm =""
	Endif
	IF Empty(LcCcy)
		Return ""
	Endif
	IF Occurs("����˰",LcTerm)=0 and Occurs("��˰",LcTerm)>0
		isDrowBack = .T.
	Endif
	Lcprice = Allt(Str(LcNprice,12,4))
	For i=(Len(Lcprice)-at(".",lcprice)-2) to 1 step -1
		IF right(LcPrice,1)="0"
			Lcprice = Left(Lcprice,Len(Lcprice)-1)
		Else
			exit
		Endif
	EndFor
	PriceCode = ""
	Do case
		case Left(LcCcy,2)="RM"
			PriceCode = "R/"
		Case Allt(LcCcy)="HKD"
			PriceCode = "H/"
		Case Allt(Lcccy)="USD"
			PriceCode = "U/"
		Otherwise
			PriceCode = "X/"
	EndCase
	For i=1 to Len(Lcprice)
		Do case
			case Substr(Lcprice,i,1)="1"
				PriceCode = PriceCode + "Y"
			case Substr(Lcprice,i,1)="2"
				PriceCode = PriceCode + "E"
			case Substr(Lcprice,i,1)="3"
				PriceCode = PriceCode + "S"
			case Substr(Lcprice,i,1)="4"
				PriceCode = PriceCode + "F"
			case Substr(Lcprice,i,1)="5"
				PriceCode = PriceCode + "W"
			case Substr(Lcprice,i,1)="6"
				PriceCode = PriceCode + "L"
			case Substr(Lcprice,i,1)="7"
				PriceCode = PriceCode + "Q"
			case Substr(Lcprice,i,1)="8"
				PriceCode = PriceCode + "B"
			case Substr(Lcprice,i,1)="9"
				PriceCode = PriceCode + "J"
			case Substr(Lcprice,i,1)="0"
				PriceCode = PriceCode + "Z"
			case Substr(LcPrice,i,1)="."
				PriceCode = PriceCode + "D"
		Endcase
	EndFor
	Return PriceCode
EndFunc


*!* && =============================================================== && *!*


***********************************************************************
&&		Function List
&&		1.  VCopyFile(LcSourceFile,LcDestFile,LtTure)					Copy a file
&&		2.  VCopyFolder(LcSourceFolder,LcDestFolder,LtTure)			Copy folder
&&		3.  VDeleteFolder(LcFolderName,LtTure)						Delete a folder
&&		4.  VAddSysFont(LcFileName)									Add a font to system
&&		5.  VGetSystemFolder()											Get system folder
&&		6.  VOpenFolder()												Show Open folder form (With my near computer)
&&		7.  ReadIniFile(lpFileName,lpApplicationName,lpKeyName)	Read a ini file
&&		8.  WriteIniFile(lpFileName,lpApplicationName,lpKeyName,lpKeyValue)		Write a value to a ini file
&&		9.  KillPrivNullChar(sPSW)										Clear Str(0) in string
&&		10.  UseDbfExcl(DBFFilename)									Test if a dbf file can open exclusive.
&&		11.  DllRegister(LPLIBFILENAME , ISREG)					Register or Remove a DLL or OCX file
&&		12.  itusedbf(dbfname,dbfalias)									Try to use a dbf file as dbfalias in a new workgroud
&&		13.  Myreturn('error='+error_wk,'exact='+exact_wk)				Use this function to restore all environment setting
&&		14.  EscToQuit(LcWarnMsg, LcWarnTtl)						Check if the user pressed the Escape Key, and ask for continute.	, Return .T. means to quit the process.
&&		15.  RunDos(doscommand)										Run a Dos Command
&&		16.  XlsFillSelect(Loexcl,MyValue,"Center","Center","Arial Narrow",9,.F.,.F.,5.63,"#,##0.00_ ",'blue','yellow')
&&		&& Excel ����, ֵ,ˮƽ���뷽ʽ,��ֱ���뷽ʽ , ����, �����С, �Ƿ����,�Ƿ�б��, ��Ԫ����, ��Ԫ���ʽ,������ɫ,��Ӱ��ɫ
&&		17.  fixtemp(set_newincl,"qryso",.T.,.T.)							Copy one or more temp dbf file to specify folder, and zap the destination dbf file. 1 .T. Means wildcard character used, 2 .T. , zap temp file.
&&		18.  itMonth(Currdate)											Return a short month, Currdate can be a number or a date&datetime variable.
&&		19.  FinaChgCcy(SourceCcy, DestCcy, nAmt)					Change a Amount to be another Ccy.  retuen exchange rate when ignore amount.
&&		20.  XlsFillPic(Loexcel,Pic_path,LnPicHight,LnPicWidth,LnRightoffset,LnBottomOffset)
&&		&& Insert a picture to Excel,    && Excel����,ͼƬ·��[,ͼƬ�߶�][,ͼƬ���][,����ƫ��λ��][,����ƫ��λ��] (�԰�һ�η����*0.75��)
&&		21.  getpict_file(ftptype,LcSourceFile,LcProdClass,LcProdName,PicSide,PicSizeCtro)	&& �ļ��ϴ�����  �ϴ����,Դ�ļ���,�ļ�����,�ļ����,ͼƬ��ʽ,ͼƬ��С,
&&																	&& GetPict_File('PROD','d:\aa\bb.jpeg','TY','TY-001','0','1')
&&		22.	 registry()					 							&& ע����������
&&		*�����Ӽ���registry(0,����ֵ,�Ӽ���,�½��Ӽ���)
&&		*дע���registry(1,����ֵ,�Ӽ���,,ע����,��Ŀֵ)
&&		*��ע���registry(2,����ֵ,�Ӽ���,,ע����)
&&		*ɾ���Ӽ���registry(3,����ֵ,�Ӽ���)
&&		ShellAndWait( tcDosCommand, IsDos, IsShow )		&& ����һ������ȴ���ִ����ɺ������һ��ָ��	= ShellAndWait("Notepad.exe")	    = ShellAndWait( [Ping 127.0.0.1 > D:\TestPing.txt], .T., .F. )
&&
&&



&&		Other not common functions:
&&
&&
************************************************************************


