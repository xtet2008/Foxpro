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

	local lpos,lhead,lweekno,lendsubid,lrt_soid,lnet_id,LcTmpSoid
	lrt_soid = ''
	Do case
		Case Substr(lso_id,3,1)="-"	&& Old SO ID TYPE		&&	KS-0100001/07
			LcTmpSoid = Alltrim(substr(lso_id,1,at("/",lso_id)+2))
		Case Substr(lso_id,5,1)="-"	&& New SO ID TYPE 		&&  KS08-010001
			If IsAlpha(substr(lso_id,12,1))		
				LcTmpSoid = Alltrim(substr(lso_id,1,12))	&& 	KS08-010001A	&& ��ܺ�ͬ��ֺ�ĺ�ͬ��
			Else
				LcTmpSoid = Alltrim(substr(lso_id,1,11))	&&	KS08-010001		&& 
			EndIf 
		Otherwise 			&& Unkown SO ID type, Return original SO ID
			Return Lso_id
	EndCase 
	if !used('somast_gensoid')
		use somast in 0 order so_id alias somast_gensoid again
	endif
	set order to so_id in somast_gensoid
	Lpo_subno = Alltrim(Substr(lso_id,Len(Alltrim(LcTmpSoid))+1))
	if seek(LcTmpSoid,"somast_gensoid")
		*lweekno  = padl(ltrim(str(IIF(year(so_date)=2005,week(so_date)-1,week(so_date)),2)) ,2,'0')
		*lrt_soid =  lhead + lweekno + lnet_id +'/' + right(str(year(so_date),4),2)+'/' + trim(employee_id) + lendsub_id
		If Year(somast_gensoid.so_date)<2008
			lrt_soid = LcTmpSoid + '/' + Alltrim(somast_gensoid.employee_id) + Lpo_subno
		Else
			If somast_gensoid.doc_2="03"	&& ��˰
				lrt_soid = LcTmpSoid + "/"+Alltrim(somast_gensoid.employee_id) + Lpo_subno
			Else
				lrt_soid = LcTmpSoid + "/"+Alltrim(somast_gensoid.employee_id) + Lpo_subno
			EndIf 
		EndIf 
	else
		lrt_soid = lso_id
	endif
	if used("somast_gensoid")
		use in somast_gensoid
	endif
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







