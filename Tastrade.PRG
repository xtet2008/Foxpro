#INCLUDE INCLUDE\TASTRADE.H

FUNCTION UpdateAdatetime()
	If type('glUpdateADateTime')='L'
		IF vartype(adatetime)='T' .AND. glUpdateADateTime
			Repl adatetime with datetime()
		Endif

		IF vartype(adate)='C' .AND. glUpdateADateTime
			IF type('USERID')='C'
				Repl adate with substr(dtos(date()),1,4)+'/'+substr(dtos(date()),5,2)+'/'++substr(dtos(date()),7,2)+' '+left(time(),5)+' '+USERID
			ENDIF
		Endif

	ENDIF
	Retu
ENDFUNC

FUNCTION NewID(tcAlias)
	LOCAL lcAlias, ;
		lcID, ;
		lcOldReprocess, ;
		lnOldArea

	lnOldArea = SELECT()

	IF PARAMETERS() < 1
		lcAlias = UPPER(ALIAS())
	ELSE
		lcAlias = UPPER(tcAlias)
	ENDIF

	lcID = ""
	lcOldReprocess = SET('REPROCESS')

	*-- Lock until user presses Esc
	SET REPROCESS TO AUTOMATIC

	IF !USED("SETUP")
		USE tastrade!setup IN 0
	ENDIF
	SELECT setup

	IF SEEK(lcAlias, "setup", "key_name")
		IF RLOCK()
			lcID = setup.value
			REPLACE setup.value WITH ;
				STR(VAL(ALLT(lcID)) + 1, LEN(setup.value))
			UNLOCK
		ENDIF
	ENDIF

	SELECT (lnOldArea)
	SET REPROCESS TO lcOldReprocess

	RETURN lcID
ENDFUNC

******************
FUNCTION RemainingCredit(tcCustomerID)
	LOCAL lyMaxOrderAmount, ;
		lyTotalOrders, ;
		lcCustomerAlias, ;
		lnOldArea

	IF PARAMETERS() < 1 OR EMPTY(tcCustomerID)
		RETURN 0
	ENDIF

	lnOldArea = SELECT(0)
	lcCustomerAlias = SYS(2015)
	USE tastrade!customer AGAIN IN 0 ALIAS (lcCustomerAlias)
	IF SEEK(orders.customer_id, lcCustomerAlias, "customer_i")
		lyMaxOrderAmount = EVAL(lcCustomerAlias + ".max_order_amt")
	ENDIF
	USE IN (lcCustomerAlias)

	*-- We use the orders table again to avoid "Illegal
	*-- recursion" errors.
	USE tastrade!orders AGAIN ALIAS _orders IN 0

	SELECT SUM((b.unit_price * b.quantity) - ;
		(a.discount * .01) * (b.unit_price * b.quantity)) + a.freight AS totalorder ;
		FROM _orders a, order_line_items b ;
		WHERE a.order_id = b.order_id ;
		AND a.customer_id = tcCustomerID ;
		GROUP by a.order_id ;
		INTO CURSOR orderamounts

	SUM totalorder to lyTotalOrders

	USE IN _orders
	USE IN orderamounts

	SELECT (lnOldArea)

	RETURN lyMaxOrderAmount - lyTotalOrders
ENDFUNC

******************
FUNCTION ValOrder()
	LOCAL llRetVal, ;
		lnAnswer, ;
		llClose, ;
		lnOldRecNo, ;
		lnOrderTotal, ;
		lnOldArea, ;
		lcCustomerAlias, ;
		lyMinOrdAmount

	*-- Don't bother checking if we're deleting the order
	IF DELETED()
		RETURN
	ENDIF

	lnOldArea = SELECT()

	*-- Check if we have at least one line item. Use the current
	*-- table if order_line_items is already opened to include
	*-- buffered records.
	IF !USED("order_line_items")
		USE tastrade!order_line_items AGAIN IN 0
		llClose = .T.
	ENDIF

	lnOldRecNo = IIF(RECCOUNT("order_line_items") > 0, RECNO("order_line_items"), 0)
	llRetVal = (SEEK(orders.order_id, "order_line_items", "order_id") AND ;
		!EMPTY(order_line_items.product_id))
	IF lnOldRecNo <> 0 AND llRetVal
		GO lnOldRecNo IN order_line_items
	ENDIF

	IF !llRetVal
		=MESSAGEBOX(ORDHASITEMS_LOC, ;
			MB_ICONEXCLAMATION, ;
			TASTRADE_LOC)
	ENDIF

	IF llRetVal
		*-- Check if customer is over credit limit. If
		*-- customer id is empty, the order will not be saved
		*-- because customer_id is a required foreign key, enforced
		*-- by the RI triggers, so we don't even bother checking.
		IF !EMPTY(orders.customer_id)
			LOCAL lyRemainingCredit
			lyRemainingCredit = RemainingCredit(orders.customer_id)
			IF lyRemainingCredit < $0
				lnAnswer = ;
					MESSAGEBOX(CUSTOVERMAX_LOC + ;
					CURRENCY + ALLT(STR(ABS(lyRemainingCredit), 15, 2)) + CR + ;
					SAVEANYWAY_LOC, ;
					MB_ICONQUESTION + MB_YESNO, ;
					TASTRADE_LOC)
				llRetVal = (lnAnswer = IDYES)
			ENDIF

			IF llRetVal
				*-- Get the customer's minimum order amount
				lcCustomerAlias = SYS(2015)
				USE tastrade!customer AGAIN IN 0 ALIAS (lcCustomerAlias)
				IF SEEK(orders.customer_id, lcCustomerAlias, "customer_i")
					lyMinOrdAmount = EVAL(lcCustomerAlias + ".min_order_amt")
				ENDIF
				USE IN (lcCustomerAlias)

				IF CalcMinOrdAmount(orders.order_id) < lyMinOrdAmount
					lnAnswer = ;
						MESSAGEBOX(CUSTUNDERMIN_LOC + ;
						CURRENCY + ALLT(STR(lyMinOrdAmount, 15, 2)) + CR + ;
						SAVEANYWAY_LOC, ;
						MB_ICONQUESTION + MB_YESNO, ;
						TASTRADE_LOC)
					llRetVal = (lnAnswer = IDYES)
				ENDIF
			ENDIF
		ENDIF
	ENDIF

	IF llClose
		USE IN order_line_items
	ENDIF

	SELECT (lnOldArea)

	RETURN llRetVal
ENDFUNC

******************
FUNCTION CalcMinOrdAmount(tcOrderID)
	*-- Returns .T. if customer has ordered the minimum order amount
	*-- Assumes orders table is open and positioned on desired record
	LOCAL lyOrderTotal, ;
		llClose

	IF !USED("order_line_items")
		USE tastrade!order_line_items IN 0
		llClose = .T.
	ENDIF
	SELECT order_line_items

	lnOldRecNo = IIF(EOF(), 0, RECNO())
	SUM (unit_price * quantity) - ;
		(orders.discount * .01) * (unit_price * quantity) ;
		FOR order_id = tcOrderID ;
		TO lyOrderTotal

	IF lnOldRecNo <> 0
		GO lnOldRecNo IN order_line_items
	ENDIF

	IF llClose
		USE IN order_line_items
	ENDIF

	RETURN lyOrderTotal

ENDFUNC

******************
FUNCTION DefaultEmployee()
	LOCAL lcEmployeeID
	*-- An order must have an employee ID associated with it
	*-- For the purposes of this sample application, we will
	*-- attempt to use the employee ID for the currently logged in
	*-- employee. If the oApp object does not exist (i.e., we are not
	*-- running the application), we will attempt to retrieve an arbitrary
	*-- employee ID from the employee file
	lcEmployeeID = ""
	IF TYPE("oApp") == "O"
		lcEmployeeID = oApp.GetEmployeeID()
	ENDIF
	IF EMPTY(lcEmployeeID)
		USE tastrade!employee AGAIN IN 0 ALIAS emp
		lcEmployeeID = emp.employee_id
		USE IN emp
	ENDIF

	RETURN lcEmployeeID
ENDFUNC


*---------------------------------------------------------------------

**__RI_HEADER!@ Do NOT REMOVE or MODIFY this line!!!! @!__RI_HEADER**
procedure RIDELETE
	local llRetVal
	llRetVal=.t.
	IF (ISRLOCKED() and !deleted()) OR !RLOCK()
		llRetVal=.F.
	ELSE
		IF !deleted()
			DELETE
			IF CURSORGETPROP('BUFFERING') > 1
				=TABLEUPDATE()
			ENDIF
			llRetVal=pnerror=0
		ENDIF not already deleted
	ENDIF
	UNLOCK RECORD (RECNO())
	RETURN llRetVal

procedure RIUPDATE
	lparameters tcFieldName,tcNewValue,tcCascadeParent
	local llRetVal
	llRetVal=.t.
	IF ISRLOCKED() OR !RLOCK()
		llRetVal=.F.
	ELSE
		IF EVAL(tcFieldName)<>tcNewValue
			PRIVATE pcCascadeParent
			pcCascadeParent=upper(iif(type("tcCascadeParent")<>"C","",tcCascadeParent))
			REPLACE (tcFieldName) WITH tcNewValue
			IF CURSORGETPROP('BUFFERING') > 1
				=TABLEUPDATE()
			ENDIF
			llRetVal=pnerror=0
		ENDIF values don't already match
	ENDIF it's locked already, or I was able to lock it
	UNLOCK RECORD (RECNO())
	return llRetVal

procedure rierror
	parameters tnErrNo,tcMessage,tcCode,tcProgram
	local lnErrorRows,lnXX
	lnErrorRows=alen(gaErrors,1)
	if type('gaErrors[lnErrorRows,1]')<>"L"
		dimension gaErrors[lnErrorRows+1,alen(gaErrors,2)]
		lnErrorRows=lnErrorRows+1
	endif
	gaErrors[lnErrorRows,1]=tnErrNo
	gaErrors[lnErrorRows,2]=tcMessage
	gaErrors[lnErrorRows,3]=tcCode
	gaErrors[lnErrorRows,4]=""
	lnXX=1
	do while !empty(program(lnXX))
		gaErrors[lnErrorRows,4]=gaErrors[lnErrorRows,4]+","+;
			program(lnXX)
		lnXX=lnXX+1
	enddo
	gaErrors[lnErrorRows,5]=pcParentDBF
	gaErrors[lnErrorRows,6]=pnParentRec
	gaErrors[lnErrorRows,7]=pcParentID
	gaErrors[lnErrorRows,8]=pcParentExpr
	gaErrors[lnErrorRows,9]=pcChildDBF
	gaErrors[lnErrorRows,10]=pnChildRec
	gaErrors[lnErrorRows,11]=pcChildID
	gaErrors[lnErrorRows,12]=pcChildExpr
	return tnErrNo


PROCEDURE riopen
	PARAMETERS tcTable,tcOrder
	local lcCurWkArea,lcNewWkArea,lnInUseSpot
	lnInUseSpot=atc(tcTable+"*",pcRIcursors)
	IF lnInUseSpot=0
		lcCurWkArea=select()
		SELECT 0
		lcNewWkArea=select()
		IF NOT EMPTY(tcOrder)
			USE (tcTable) AGAIN ORDER (tcOrder) ;
				ALIAS ("__ri"+LTRIM(STR(SELECT()))) share
		ELSE
			USE (tcTable) AGAIN ALIAS ("__ri"+LTRIM(STR(SELECT()))) share
		ENDIF
		if pnerror=0
			pcRIcursors=pcRIcursors+upper(tcTable)+"?"+STR(SELECT(),5)
		else
			lcNewWkArea=0
		endif something bad happened while attempting to open the file
	ELSE
		lcNewWkArea=val(substr(pcRIcursors,lnInUseSpot+len(tcTable)+1,5))
		pcRIcursors = strtran(pcRIcursors,upper(tcTable)+"*"+str(lcNewWkArea,5),;
			upper(tcTable)+"?"+str(lcNewWkArea,5))
		IF NOT EMPTY(tcOrder)
			SET ORDER TO (tcOrder) IN (lcNewWkArea)
		ENDIF sent an order
		if pnerror<>0
			lcNewWkArea=0
		endif something bad happened while setting order
	ENDIF
	RETURN (lcNewWkArea)


PROCEDURE riend
	PARAMETERS tlSuccess
	local lnXX,lnSpot,lcWorkArea
	IF tlSuccess
		END TRANSACTION
	ELSE
		SET DELETED OFF
		ROLLBACK
		SET DELETED ON
	ENDIF
	IF EMPTY(pcRIolderror)
		ON ERROR
	ELSE
		ON ERROR &pcRIolderror.
	ENDIF
	FOR lnXX=1 TO occurs("*",pcRIcursors)
		lnSpot=atc("*",pcRIcursors,lnXX)+1
		USE IN (VAL(substr(pcRIcursors,lnSpot,5)))
	ENDFOR
	IF pcOldCompat = "ON"
		SET COMPATIBLE ON
	ENDIF
	IF pcOldDele="OFF"
		SET DELETED OFF
	ENDIF
	IF pcOldExact="ON"
		SET EXACT ON
	ENDIF
	IF pcOldTalk="ON"
		SET TALK ON
	ENDIF
	do case
		case empty(pcOldDBC)
			set data to
		case pcOldDBC<>DBC()
			set data to (pcOldDBC)
	endcase
	RETURN .T.


PROCEDURE rireuse
	* rireuse.prg
	PARAMETERS tcTableName,tcWkArea
	pcRIcursors = strtran(pcRIcursors,upper(tcTableName)+"?"+str(tcWkArea,5),;
		upper(tcTableName)+"*"+str(tcWkArea,5))
	RETURN .t.

	********************************************************************************
	** "Referential integrity delete trigger for" apabmast
PROCEDURE __RI_DELETE_apabmast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(VOUCHER_NO) TO lcParentID,pcParentID
	pcParentExpr="UPPER(VOUCHER_NO)"
	lcChildWkArea=riopen("apabdtl","voucher_no")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(VOUCHER_NO)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(VOUCHER_NO)
		pcChildExpr="UPPER(VOUCHER_NO)"
		llRetVal=ridelete()
	ENDSCAN get all of the apabdtl records
	=rireuse("apabdtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" apabmast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" apmast
PROCEDURE __RI_DELETE_apmast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(VOUCHER_NO) TO lcParentID,pcParentID
	pcParentExpr="UPPER(VOUCHER_NO)"
	lcChildWkArea=riopen("apdtl","voucher_no")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(VOUCHER_NO)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(VOUCHER_NO)
		pcChildExpr="UPPER(VOUCHER_NO)"
		llRetVal=ridelete()
	ENDSCAN get all of the apdtl records
	=rireuse("apdtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" apmast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" arabmast
PROCEDURE __RI_DELETE_arabmast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(VOUCHER_NO) TO lcParentID,pcParentID
	pcParentExpr="UPPER(VOUCHER_NO)"
	lcChildWkArea=riopen("arabdtl","voucher_no")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(VOUCHER_NO)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(VOUCHER_NO)
		pcChildExpr="UPPER(VOUCHER_NO)"
		llRetVal=ridelete()
	ENDSCAN get all of the arabdtl records
	=rireuse("arabdtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" arabmast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" armast
PROCEDURE __RI_DELETE_armast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(VOUCHER_NO) TO lcParentID,pcParentID
	pcParentExpr="UPPER(VOUCHER_NO)"
	lcChildWkArea=riopen("ardtl","voucher_no")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(VOUCHER_NO)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(VOUCHER_NO)
		pcChildExpr="UPPER(VOUCHER_NO)"
		llRetVal=ridelete()
	ENDSCAN get all of the ardtl records
	=rireuse("ardtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" armast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" barmast
PROCEDURE __RI_DELETE_barmast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(BATCH_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(BATCH_ID)"
	lcChildWkArea=riopen("bardtl","batch_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(BATCH_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(BATCH_ID)
		pcChildExpr="UPPER(BATCH_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the bardtl records
	=rireuse("bardtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" barmast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" cdndtl
PROCEDURE __RI_DELETE_cdndtl
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(CDN_ID)+STR(CDN_NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(CDN_ID)+STR(CDN_NTH_DTL,7,5)"
	lcChildWkArea=riopen("cdngrn","cdn_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(CDN_ID)+STR(NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(CDN_ID)+STR(NTH_DTL,7,5)
		pcChildExpr="UPPER(CDN_ID)+STR(NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the cdngrn records
	=rireuse("cdngrn",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(CDN_ID)+STR(CDN_NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(CDN_ID)+STR(CDN_NTH_DTL,7,5)"
	lcChildWkArea=riopen("rfcgrn","cdn_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(CDN_ID)+STR(CDN_NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(CDN_ID)+STR(CDN_NTH_DTL,7,5)
		pcChildExpr="UPPER(CDN_ID)+STR(CDN_NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the rfcgrn records
	=rireuse("rfcgrn",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(CDN_ID)+STR(CDN_NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(CDN_ID)+STR(CDN_NTH_DTL,7,5)"
	lcChildWkArea=riopen("cdnbom","cdn_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(CDN_ID)+STR(NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(CDN_ID)+STR(NTH_DTL,7,5)
		pcChildExpr="UPPER(CDN_ID)+STR(NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the cdnbom records
	=rireuse("cdnbom",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(CDN_ID)+STR(CDN_NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(CDN_ID)+STR(CDN_NTH_DTL,7,5)"
	lcChildWkArea=riopen("cdnsnc","cdn_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(CDN_ID)+STR(CDN_NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(CDN_ID)+STR(CDN_NTH_DTL,7,5)
		pcChildExpr="UPPER(CDN_ID)+STR(CDN_NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the cdnsnc records
	=rireuse("cdnsnc",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" cdndtl
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" cdnmast
PROCEDURE __RI_DELETE_cdnmast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(CDN_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(CDN_ID)"
	lcChildWkArea=riopen("cdndtl","cdn_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(CDN_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(CDN_ID)
		pcChildExpr="UPPER(CDN_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the cdndtl records
	=rireuse("cdndtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" cdnmast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" cinmast
PROCEDURE __RI_DELETE_cinmast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(CIN_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(CIN_ID)"
	lcChildWkArea=riopen("cindtl","cin_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(CIN_ID)+STR(CIN_NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(CIN_ID)+STR(CIN_NTH_DTL,7,5)
		pcChildExpr="UPPER(CIN_ID)+STR(CIN_NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the cindtl records
	=rireuse("cindtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" cinmast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" cmimast
PROCEDURE __RI_DELETE_cmimast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(CMI_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(CMI_ID)"
	lcChildWkArea=riopen("cmidtl","cmi_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(CMI_ID)+STR(CMI_NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(CMI_ID)+STR(CMI_NTH_DTL,7,5)
		pcChildExpr="UPPER(CMI_ID)+STR(CMI_NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the cmidtl records
	=rireuse("cmidtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" cmimast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" crnmast
PROCEDURE __RI_DELETE_crnmast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(CRN_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(CRN_ID)"
	lcChildWkArea=riopen("crndtl","crn_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(CRN_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(CRN_ID)
		pcChildExpr="UPPER(CRN_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the crndtl records
	=rireuse("crndtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" crnmast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" customer
PROCEDURE __RI_DELETE_customer
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(LTRIM(CUSTOMER_ID)) TO lcParentID,pcParentID
	pcParentExpr="UPPER(LTRIM(CUSTOMER_ID))"
	lcChildWkArea=riopen("custattn","customer_i")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(CUSTOMER_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(CUSTOMER_ID)
		pcChildExpr="UPPER(CUSTOMER_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the custattn records
	=rireuse("custattn",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" customer
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" dbnmast
PROCEDURE __RI_DELETE_dbnmast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(DBN_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(DBN_ID)"
	lcChildWkArea=riopen("dbndtl","dbn_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(DBN_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(DBN_ID)
		pcChildExpr="UPPER(DBN_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the dbndtl records
	=rireuse("dbndtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" dbnmast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" glmast
PROCEDURE __RI_DELETE_glmast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(VOUCHER_NO) TO lcParentID,pcParentID
	pcParentExpr="UPPER(VOUCHER_NO)"
	lcChildWkArea=riopen("gldtl","voucher_no")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(VOUCHER_NO)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(VOUCHER_NO)
		pcChildExpr="UPPER(VOUCHER_NO)"
		llRetVal=ridelete()
	ENDSCAN get all of the gldtl records
	=rireuse("gldtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" glmast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" invdtl
PROCEDURE __RI_DELETE_invdtl
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(INV_ID)+STR(INV_NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(INV_ID)+STR(INV_NTH_DTL,7,5)"
	lcChildWkArea=riopen("invsnc","inv_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(INV_ID)+STR(INV_NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(INV_ID)+STR(INV_NTH_DTL,7,5)
		pcChildExpr="UPPER(INV_ID)+STR(INV_NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the invsnc records
	=rireuse("invsnc",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(INV_ID)+STR(INV_NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(INV_ID)+STR(INV_NTH_DTL,7,5)"
	lcChildWkArea=riopen("invbar","inv_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(INV_ID)+STR(INV_NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(INV_ID)+STR(INV_NTH_DTL,7,5)
		pcChildExpr="UPPER(INV_ID)+STR(INV_NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the invbar records
	=rireuse("invbar",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(INV_ID)+STR(INV_NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(INV_ID)+STR(INV_NTH_DTL,7,5)"
	lcChildWkArea=riopen("invbom","inv_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(INV_ID)+STR(INV_NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(INV_ID)+STR(INV_NTH_DTL,7,5)
		pcChildExpr="UPPER(INV_ID)+STR(INV_NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the invbom records
	=rireuse("invbom",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" invdtl
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" invmast
PROCEDURE __RI_DELETE_invmast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(INV_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(INV_ID)"
	lcChildWkArea=riopen("invtask","inv_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(INV_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(INV_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)
		pcChildExpr="UPPER(INV_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)"
		llRetVal=ridelete()
	ENDSCAN get all of the invtask records
	=rireuse("invtask",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(INV_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(INV_ID)"
	lcChildWkArea=riopen("invdtl","inv_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(INV_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(INV_ID)
		pcChildExpr="UPPER(INV_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the invdtl records
	=rireuse("invdtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(INV_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(INV_ID)"
	lcChildWkArea=riopen("packlst","inv_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(INV_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(INV_ID)
		pcChildExpr="UPPER(INV_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the packlst records
	=rireuse("packlst",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(INV_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(INV_ID)"
	lcChildWkArea=riopen("invcharg","inv_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(INV_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(INV_ID)
		pcChildExpr="UPPER(INV_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the invcharg records
	=rireuse("invcharg",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(INV_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(INV_ID)"
	lcChildWkArea=riopen("packsnc","inv_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(INV_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(INV_ID)
		pcChildExpr="UPPER(INV_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the packsnc records
	=rireuse("packsnc",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" invmast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" iqcdtl
PROCEDURE __RI_DELETE_iqcdtl
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(IQC_ID)+STR(IQC_NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(IQC_ID)+STR(IQC_NTH_DTL,7,5)"
	lcChildWkArea=riopen("iqcsnc","iqc_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(IQC_ID)+STR(IQC_NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(IQC_ID)+STR(IQC_NTH_DTL,7,5)
		pcChildExpr="UPPER(IQC_ID)+STR(IQC_NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the iqcsnc records
	=rireuse("iqcsnc",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" iqcdtl
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" iqcmast
PROCEDURE __RI_DELETE_iqcmast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(IQC_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(IQC_ID)"
	lcChildWkArea=riopen("iqcdtl","iqc_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(IQC_ID)+STR(IQC_NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(IQC_ID)+STR(IQC_NTH_DTL,7,5)
		pcChildExpr="UPPER(IQC_ID)+STR(IQC_NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the iqcdtl records
	=rireuse("iqcdtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" iqcmast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" jodtl
PROCEDURE __RI_DELETE_jodtl
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(JO_ID)+STR(NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(JO_ID)+STR(NTH_DTL,7,5)"
	lcChildWkArea=riopen("jomeas","jo_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(JO_ID)+STR(NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(JO_ID)+STR(NTH_DTL,7,5)
		pcChildExpr="UPPER(JO_ID)+STR(NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the jomeas records
	=rireuse("jomeas",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(JO_ID)+STR(NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(JO_ID)+STR(NTH_DTL,7,5)"
	lcChildWkArea=riopen("josch","jo_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(JO_ID)+STR(NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(JO_ID)+STR(NTH_DTL,7,5)
		pcChildExpr="UPPER(JO_ID)+STR(NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the josch records
	=rireuse("josch",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(JO_ID)+STR(NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(JO_ID)+STR(NTH_DTL,7,5)"
	lcChildWkArea=riopen("jobom","jo_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(JO_ID)+STR(NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(JO_ID)+STR(NTH_DTL,7,5)
		pcChildExpr="UPPER(JO_ID)+STR(NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the jobom records
	=rireuse("jobom",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" jodtl
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" jomast
PROCEDURE __RI_DELETE_jomast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(JO_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(JO_ID)"
	lcChildWkArea=riopen("jotask","jo_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(JO_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(JO_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)
		pcChildExpr="UPPER(JO_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)"
		llRetVal=ridelete()
	ENDSCAN get all of the jotask records
	=rireuse("jotask",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(JO_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(JO_ID)"
	lcChildWkArea=riopen("jomrp","jo_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(JO_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(JO_ID)
		pcChildExpr="UPPER(JO_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the jomrp records
	=rireuse("jomrp",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(JO_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(JO_ID)"
	lcChildWkArea=riopen("jodtl","jo_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(JO_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(JO_ID)
		pcChildExpr="UPPER(JO_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the jodtl records
	=rireuse("jodtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(JO_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(JO_ID)"
	lcChildWkArea=riopen("jocrp","jo_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(JO_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(JO_ID)
		pcChildExpr="UPPER(JO_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the jocrp records
	=rireuse("jocrp",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" jomast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" jvmast
PROCEDURE __RI_DELETE_jvmast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(VOUCHER_NO) TO lcParentID,pcParentID
	pcParentExpr="UPPER(VOUCHER_NO)"
	lcChildWkArea=riopen("jvdtl","voucher_no")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(VOUCHER_NO)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(VOUCHER_NO)
		pcChildExpr="UPPER(VOUCHER_NO)"
		llRetVal=ridelete()
	ENDSCAN get all of the jvdtl records
	=rireuse("jvdtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" jvmast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" lcmast
PROCEDURE __RI_DELETE_lcmast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE TRIM(UPPER(LC_NO)) TO lcParentID,pcParentID
	pcParentExpr="TRIM(UPPER(LC_NO))"
	lcChildWkArea=riopen("lcinv","lc_no")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE TRIM(UPPER(LC_NO))=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=TRIM(UPPER(LC_NO))
		pcChildExpr="TRIM(UPPER(LC_NO))"
		llRetVal=ridelete()
	ENDSCAN get all of the lcinv records
	=rireuse("lcinv",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE TRIM(UPPER(LC_NO)) TO lcParentID,pcParentID
	pcParentExpr="TRIM(UPPER(LC_NO))"
	lcChildWkArea=riopen("lcso","lc_no")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE TRIM(UPPER(LC_NO))=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=TRIM(UPPER(LC_NO))
		pcChildExpr="TRIM(UPPER(LC_NO))"
		llRetVal=ridelete()
	ENDSCAN get all of the lcso records
	=rireuse("lcso",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE TRIM(UPPER(LC_NO)) TO lcParentID,pcParentID
	pcParentExpr="TRIM(UPPER(LC_NO))"
	lcChildWkArea=riopen("lcpo","lc_no")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE TRIM(UPPER(LC_NO))=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=TRIM(UPPER(LC_NO))
		pcChildExpr="TRIM(UPPER(LC_NO))"
		llRetVal=ridelete()
	ENDSCAN get all of the lcpo records
	=rireuse("lcpo",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE TRIM(UPPER(LC_NO)) TO lcParentID,pcParentID
	pcParentExpr="TRIM(UPPER(LC_NO))"
	lcChildWkArea=riopen("lcsdn","lc_no")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE TRIM(UPPER(LC_NO))=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=TRIM(UPPER(LC_NO))
		pcChildExpr="TRIM(UPPER(LC_NO))"
		llRetVal=ridelete()
	ENDSCAN get all of the lcsdn records
	=rireuse("lcsdn",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" lcmast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" pidtl
PROCEDURE __RI_DELETE_pidtl
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(PI_ID)+STR(PI_NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(PI_ID)+STR(PI_NTH_DTL,7,5)"
	lcChildWkArea=riopen("pibom","pi_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(PI_ID)+STR(PI_NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(PI_ID)+STR(PI_NTH_DTL,7,5)
		pcChildExpr="UPPER(PI_ID)+STR(PI_NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the pibom records
	=rireuse("pibom",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(PI_ID)+STR(PI_NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(PI_ID)+STR(PI_NTH_DTL,7,5)"
	lcChildWkArea=riopen("pisnc","pi_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(PI_ID)+STR(PI_NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(PI_ID)+STR(PI_NTH_DTL,7,5)
		pcChildExpr="UPPER(PI_ID)+STR(PI_NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the pisnc records
	=rireuse("pisnc",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" pidtl
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" pimast
PROCEDURE __RI_DELETE_pimast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(PI_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(PI_ID)"
	lcChildWkArea=riopen("pidtl","pi_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(PI_ID)+STR(PI_NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(PI_ID)+STR(PI_NTH_DTL,7,5)
		pcChildExpr="UPPER(PI_ID)+STR(PI_NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the pidtl records
	=rireuse("pidtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(PI_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(PI_ID)"
	lcChildWkArea=riopen("pitask","pi_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(PI_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(PI_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)
		pcChildExpr="UPPER(PI_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)"
		llRetVal=ridelete()
	ENDSCAN get all of the pitask records
	=rireuse("pitask",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" pimast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" pinvmast
PROCEDURE __RI_DELETE_pinvmast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(PINV_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(PINV_ID)"
	lcChildWkArea=riopen("pinvdtl","pinv_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(PINV_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(PINV_ID)
		pcChildExpr="UPPER(PINV_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the pinvdtl records
	=rireuse("pinvdtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" pinvmast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" podtl
PROCEDURE __RI_DELETE_podtl
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(PO_ID)+STR(NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(PO_ID)+STR(NTH_DTL,7,5)"
	lcChildWkArea=riopen("posch","posch")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(PO_ID)+STR(NTH_DTL,7,5)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(PO_ID)+STR(NTH_DTL,7,5)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)
		pcChildExpr="UPPER(PO_ID)+STR(NTH_DTL,7,5)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)"
		llRetVal=ridelete()
	ENDSCAN get all of the posch records
	=rireuse("posch",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(PO_ID)+STR(NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(PO_ID)+STR(NTH_DTL,7,5)"
	lcChildWkArea=riopen("posnc","po_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(PO_ID)+STR(NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(PO_ID)+STR(NTH_DTL,7,5)
		pcChildExpr="UPPER(PO_ID)+STR(NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the posnc records
	=rireuse("posnc",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(PO_ID)+STR(NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(PO_ID)+STR(NTH_DTL,7,5)"
	lcChildWkArea=riopen("pomeas","po_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(PO_ID)+STR(NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(PO_ID)+STR(NTH_DTL,7,5)
		pcChildExpr="UPPER(PO_ID)+STR(NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the pomeas records
	=rireuse("pomeas",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(PO_ID)+STR(NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(PO_ID)+STR(NTH_DTL,7,5)"
	lcChildWkArea=riopen("pobom","po_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(PO_ID)+STR(NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(PO_ID)+STR(NTH_DTL,7,5)
		pcChildExpr="UPPER(PO_ID)+STR(NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the pobom records
	=rireuse("pobom",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(PO_ID)+STR(NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(PO_ID)+STR(NTH_DTL,7,5)"
	lcChildWkArea=riopen("pomrp","po_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(PO_ID)+STR(NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(PO_ID)+STR(NTH_DTL,7,5)
		pcChildExpr="UPPER(PO_ID)+STR(NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the pomrp records
	=rireuse("pomrp",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" podtl
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" pomast
PROCEDURE __RI_DELETE_pomast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(PO_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(PO_ID)"
	lcChildWkArea=riopen("potask","po_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(PO_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(PO_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)
		pcChildExpr="UPPER(PO_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)"
		llRetVal=ridelete()
	ENDSCAN get all of the potask records
	=rireuse("potask",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(PO_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(PO_ID)"
	lcChildWkArea=riopen("podtl","po_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(PO_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(PO_ID)
		pcChildExpr="UPPER(PO_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the podtl records
	=rireuse("podtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(PO_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(PO_ID)"
	lcChildWkArea=riopen("pocharg","po_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(PO_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(PO_ID)
		pcChildExpr="UPPER(PO_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the pocharg records
	=rireuse("pocharg",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" pomast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" products
PROCEDURE __RI_DELETE_products
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(PRODUCT_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(PRODUCT_ID)"
	lcChildWkArea=riopen("custref","product_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(PRODUCT_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(PRODUCT_ID)
		pcChildExpr="UPPER(PRODUCT_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the custref records
	=rireuse("custref",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(PRODUCT_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(PRODUCT_ID)"
	lcChildWkArea=riopen("suppref","product_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(PRODUCT_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(PRODUCT_ID)
		pcChildExpr="UPPER(PRODUCT_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the suppref records
	=rireuse("suppref",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(PRODUCT_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(PRODUCT_ID)"
	lcChildWkArea=riopen("photos","product_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(PRODUCT_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(PRODUCT_ID)
		pcChildExpr="UPPER(PRODUCT_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the photos records
	=rireuse("photos",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(PRODUCT_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(PRODUCT_ID)"
	lcChildWkArea=riopen("payt","product_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(PRODUCT_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(PRODUCT_ID)
		pcChildExpr="UPPER(PRODUCT_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the payt records
	=rireuse("payt",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(PRODUCT_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(PRODUCT_ID)"
	lcChildWkArea=riopen("prodsub","product_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(PRODUCT_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(PRODUCT_ID)
		pcChildExpr="UPPER(PRODUCT_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the prodsub records
	=rireuse("prodsub",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(PRODUCT_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(PRODUCT_ID)"
	lcChildWkArea=riopen("prodmeas","product_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE PRODUCT_ID=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=PRODUCT_ID
		pcChildExpr="PRODUCT_ID"
		llRetVal=ridelete()
	ENDSCAN get all of the prodmeas records
	=rireuse("prodmeas",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(PRODUCT_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(PRODUCT_ID)"
	lcChildWkArea=riopen("bomdtl","bom_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(BOM_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(BOM_ID)
		pcChildExpr="UPPER(BOM_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the bomdtl records
	=rireuse("bomdtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" products
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" projmast
PROCEDURE __RI_DELETE_projmast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(PROJ_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(PROJ_ID)"
	lcChildWkArea=riopen("projdtl","proj_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(PROJ_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(PROJ_ID)
		pcChildExpr="UPPER(PROJ_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the projdtl records
	=rireuse("projdtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(PROJ_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(PROJ_ID)"
	lcChildWkArea=riopen("projsch","proj_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(PROJ_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(PROJ_ID)
		pcChildExpr="UPPER(PROJ_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the projsch records
	=rireuse("projsch",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(PROJ_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(PROJ_ID)"
	lcChildWkArea=riopen("projtask","proj_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(PROJ_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(PROJ_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)
		pcChildExpr="UPPER(PROJ_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)"
		llRetVal=ridelete()
	ENDSCAN get all of the projtask records
	=rireuse("projtask",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" projmast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" prpmast
PROCEDURE __RI_DELETE_prpmast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE PRP_ID TO lcParentID,pcParentID
	pcParentExpr="PRP_ID"
	lcChildWkArea=riopen("prpdtl","prp_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE PRP_ID=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=PRP_ID
		pcChildExpr="PRP_ID"
		llRetVal=ridelete()
	ENDSCAN get all of the prpdtl records
	=rireuse("prpdtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" prpmast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" psdnmast
PROCEDURE __RI_DELETE_psdnmast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(PSDN_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(PSDN_ID)"
	lcChildWkArea=riopen("psdndtl","psdn_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(PSDN_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(PSDN_ID)
		pcChildExpr="UPPER(PSDN_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the psdndtl records
	=rireuse("psdndtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" psdnmast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" qtamast
PROCEDURE __RI_DELETE_qtamast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE TRIM(UPPER(QTA_NO)) TO lcParentID,pcParentID
	pcParentExpr="TRIM(UPPER(QTA_NO))"
	lcChildWkArea=riopen("qtadtl","qta_no")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE TRIM(UPPER(QTA_NO))=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=TRIM(UPPER(QTA_NO))
		pcChildExpr="TRIM(UPPER(QTA_NO))"
		llRetVal=ridelete()
	ENDSCAN get all of the qtadtl records
	=rireuse("qtadtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" qtamast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" quotdtl
PROCEDURE __RI_DELETE_quotdtl
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(QUOT_ID)+STR(NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(QUOT_ID)+STR(NTH_DTL,7,5)"
	lcChildWkArea=riopen("quotbom","quot_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(QUOT_ID)+STR(NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(QUOT_ID)+STR(NTH_DTL,7,5)
		pcChildExpr="UPPER(QUOT_ID)+STR(NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the quotbom records
	=rireuse("quotbom",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" quotdtl
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" quotmast
PROCEDURE __RI_DELETE_quotmast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(QUOT_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(QUOT_ID)"
	lcChildWkArea=riopen("quotdtl","quot_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(QUOT_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(QUOT_ID)
		pcChildExpr="UPPER(QUOT_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the quotdtl records
	=rireuse("quotdtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(QUOT_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(QUOT_ID)"
	lcChildWkArea=riopen("quottask","quot_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(QUOT_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(QUOT_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)
		pcChildExpr="UPPER(QUOT_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)"
		llRetVal=ridelete()
	ENDSCAN get all of the quottask records
	=rireuse("quottask",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" quotmast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" rfcmast
PROCEDURE __RI_DELETE_rfcmast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(RFC_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(RFC_ID)"
	lcChildWkArea=riopen("rfcdtl","rfc_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(RFC_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(RFC_ID)
		pcChildExpr="UPPER(RFC_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the rfcdtl records
	=rireuse("rfcdtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" rfcmast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" rfsmast
PROCEDURE __RI_DELETE_rfsmast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(RFS_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(RFS_ID)"
	lcChildWkArea=riopen("rfsdtl","rfs_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(RFS_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(RFS_ID)
		pcChildExpr="UPPER(RFS_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the rfsdtl records
	=rireuse("rfsdtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" rfsmast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" sdndtl
PROCEDURE __RI_DELETE_sdndtl
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(SDN_ID)+STR(SDN_NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(SDN_ID)+STR(SDN_NTH_DTL,7,5)"
	lcChildWkArea=riopen("rfsgrn","sdn_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(SDN_ID)+STR(SDN_NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(SDN_ID)+STR(SDN_NTH_DTL,7,5)
		pcChildExpr="UPPER(SDN_ID)+STR(SDN_NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the rfsgrn records
	=rireuse("rfsgrn",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(SDN_ID)+STR(SDN_NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(SDN_ID)+STR(SDN_NTH_DTL,7,5)"
	lcChildWkArea=riopen("sdnbar","sdn_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(SDN_ID)+STR(SDN_NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(SDN_ID)+STR(SDN_NTH_DTL,7,5)
		pcChildExpr="UPPER(SDN_ID)+STR(SDN_NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the sdnbar records
	=rireuse("sdnbar",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(SDN_ID)+STR(SDN_NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(SDN_ID)+STR(SDN_NTH_DTL,7,5)"
	lcChildWkArea=riopen("sdnbom","sdn_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(SDN_ID)+STR(SDN_NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(SDN_ID)+STR(SDN_NTH_DTL,7,5)
		pcChildExpr="UPPER(SDN_ID)+STR(SDN_NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the sdnbom records
	=rireuse("sdnbom",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(SDN_ID)+STR(SDN_NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(SDN_ID)+STR(SDN_NTH_DTL,7,5)"
	lcChildWkArea=riopen("sdnsnc","sdn_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(SDN_ID)+STR(SDN_NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(SDN_ID)+STR(SDN_NTH_DTL,7,5)
		pcChildExpr="UPPER(SDN_ID)+STR(SDN_NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the sdnsnc records
	=rireuse("sdnsnc",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" sdndtl
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" sdnmast
PROCEDURE __RI_DELETE_sdnmast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(SDN_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(SDN_ID)"
	lcChildWkArea=riopen("sdndtl","sdn_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(SDN_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(SDN_ID)
		pcChildExpr="UPPER(SDN_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the sdndtl records
	=rireuse("sdndtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" sdnmast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" sec_grp
PROCEDURE __RI_DELETE_sec_grp
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(CODE) TO lcParentID,pcParentID
	pcParentExpr="UPPER(CODE)"
	lcChildWkArea=riopen("security","code")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(CODE)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(CODE)
		pcChildExpr="UPPER(CODE)"
		llRetVal=ridelete()
	ENDSCAN get all of the security records
	=rireuse("security",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" sec_grp
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" sjdtl
PROCEDURE __RI_DELETE_sjdtl
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(SJ_ID)+STR(NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(SJ_ID)+STR(NTH_DTL,7,5)"
	lcChildWkArea=riopen("sjmeas","sj_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(SJ_ID)+STR(NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(SJ_ID)+STR(NTH_DTL,7,5)
		pcChildExpr="UPPER(SJ_ID)+STR(NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the sjmeas records
	=rireuse("sjmeas",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(SJ_ID)+STR(NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(SJ_ID)+STR(NTH_DTL,7,5)"
	lcChildWkArea=riopen("sjsch","sj_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(SJ_ID)+STR(NTH_DTL,7,5)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(SJ_ID)+STR(NTH_DTL,7,5)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)
		pcChildExpr="UPPER(SJ_ID)+STR(NTH_DTL,7,5)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)"
		llRetVal=ridelete()
	ENDSCAN get all of the sjsch records
	=rireuse("sjsch",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(SJ_ID)+STR(NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(SJ_ID)+STR(NTH_DTL,7,5)"
	lcChildWkArea=riopen("sjbom","sj_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(SJ_ID)+STR(NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(SJ_ID)+STR(NTH_DTL,7,5)
		pcChildExpr="UPPER(SJ_ID)+STR(NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the sjbom records
	=rireuse("sjbom",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(SJ_ID)+STR(NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(SJ_ID)+STR(NTH_DTL,7,5)"
	lcChildWkArea=riopen("sjsnc","sj_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(SJ_ID)+STR(NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(SJ_ID)+STR(NTH_DTL,7,5)
		pcChildExpr="UPPER(SJ_ID)+STR(NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the sjsnc records
	=rireuse("sjsnc",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" sjdtl
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" sjmast
PROCEDURE __RI_DELETE_sjmast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(SJ_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(SJ_ID)"
	lcChildWkArea=riopen("sjdtl","sj_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(SJ_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(SJ_ID)
		pcChildExpr="UPPER(SJ_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the sjdtl records
	=rireuse("sjdtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(SJ_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(SJ_ID)"
	lcChildWkArea=riopen("sjmrp","sj_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(SJ_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(SJ_ID)
		pcChildExpr="UPPER(SJ_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the sjmrp records
	=rireuse("sjmrp",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(SJ_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(SJ_ID)"
	lcChildWkArea=riopen("sjtask","sj_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(SJ_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(SJ_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)
		pcChildExpr="UPPER(SJ_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)"
		llRetVal=ridelete()
	ENDSCAN get all of the sjtask records
	=rireuse("sjtask",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" sjmast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" sodtl
PROCEDURE __RI_DELETE_sodtl
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(SO_ID)+STR(NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(SO_ID)+STR(NTH_DTL,7,5)"
	lcChildWkArea=riopen("sosch","sosch")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(SO_ID)+STR(NTH_DTL,7,5)+UPPER(PRODUCT_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(SO_ID)+STR(NTH_DTL,7,5)+UPPER(PRODUCT_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)
		pcChildExpr="UPPER(SO_ID)+STR(NTH_DTL,7,5)+UPPER(PRODUCT_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)"
		llRetVal=ridelete()
	ENDSCAN get all of the sosch records
	=rireuse("sosch",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(SO_ID)+STR(NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(SO_ID)+STR(NTH_DTL,7,5)"
	lcChildWkArea=riopen("sobom","so_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(SO_ID)+STR(NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(SO_ID)+STR(NTH_DTL,7,5)
		pcChildExpr="UPPER(SO_ID)+STR(NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the sobom records
	=rireuse("sobom",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(SO_ID)+STR(NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(SO_ID)+STR(NTH_DTL,7,5)"
	lcChildWkArea=riopen("sosnc","so_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(SO_ID)+STR(NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(SO_ID)+STR(NTH_DTL,7,5)
		pcChildExpr="UPPER(SO_ID)+STR(NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the sosnc records
	=rireuse("sosnc",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(SO_ID)+STR(NTH_DTL,7,5) TO lcParentID,pcParentID
	pcParentExpr="UPPER(SO_ID)+STR(NTH_DTL,7,5)"
	lcChildWkArea=riopen("someas","so_key")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(SO_ID)+STR(NTH_DTL,7,5)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(SO_ID)+STR(NTH_DTL,7,5)
		pcChildExpr="UPPER(SO_ID)+STR(NTH_DTL,7,5)"
		llRetVal=ridelete()
	ENDSCAN get all of the someas records
	=rireuse("someas",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" sodtl
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" somast
PROCEDURE __RI_DELETE_somast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(SO_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(SO_ID)"
	lcChildWkArea=riopen("sotask","so_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(SO_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(SO_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)
		pcChildExpr="UPPER(SO_ID)+STR(YEAR(DATE),4,2)+STR(MONTH(DATE),2)+STR(DAY(DATE),2)"
		llRetVal=ridelete()
	ENDSCAN get all of the sotask records
	=rireuse("sotask",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(SO_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(SO_ID)"
	lcChildWkArea=riopen("sodtl","so_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(SO_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(SO_ID)
		pcChildExpr="UPPER(SO_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the sodtl records
	=rireuse("sodtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(SO_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(SO_ID)"
	lcChildWkArea=riopen("socharg","so_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(SO_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(SO_ID)
		pcChildExpr="UPPER(SO_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the socharg records
	=rireuse("socharg",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(SO_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(SO_ID)"
	lcChildWkArea=riopen("soiqc","so_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(SO_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(SO_ID)
		pcChildExpr="UPPER(SO_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the soiqc records
	=rireuse("soiqc",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" somast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" sqtmast
PROCEDURE __RI_DELETE_sqtmast
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(SQT_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(SQT_ID)"
	lcChildWkArea=riopen("sqtdtl","sqt_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(SQT_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(SQT_ID)
		pcChildExpr="UPPER(SQT_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the sqtdtl records
	=rireuse("sqtdtl",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(SQT_ID) TO lcParentID,pcParentID
	pcParentExpr="UPPER(SQT_ID)"
	lcChildWkArea=riopen("sqtsupp","sqt_id")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(SQT_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(SQT_ID)
		pcChildExpr="UPPER(SQT_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the sqtsupp records
	=rireuse("sqtsupp",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" sqtmast
	********************************************************************************

	********************************************************************************
	** "Referential integrity delete trigger for" supplier
PROCEDURE __RI_DELETE_supplier
	LOCAL llRetVal
	llRetVal = .t.
	PRIVATE pcParentDBF,pnParentRec,pcChildDBF,pnChildRec,pcParentID,pcChildID
	PRIVATE pcParentExpr,pcChildExpr
	STORE "" TO pcParentDBF,pcChildDBF,pcParentID,pcChildID,pcParentExpr,pcChildExpr
	STORE 0 TO pnParentRec,pnChildRec
	IF _triggerlevel=1
		BEGIN TRANSACTION
		PRIVATE pcRIcursors,pcRIwkareas,pcRIolderror,pnerror,;
			pcOldDele,pcOldExact,pcOldTalk,pcOldCompat,PcOldDBC
		pcOldTalk=SET("TALK")
		SET TALK OFF
		pcOldDele=SET("DELETED")
		pcOldExact=SET("EXACT")
		pcOldCompat=SET("COMPATIBLE")
		SET COMPATIBLE OFF
		SET DELETED ON
		SET EXACT OFF
		pcRIcursors=""
		pcRIwkareas=""
		pcRIolderror=ON("error")
		pnerror=0
		ON ERROR pnerror=rierror(ERROR(),message(),message(1),program())
		IF TYPE('gaErrors(1)')<>"U"
			release gaErrors
		ENDIF
		PUBLIC gaErrors(1,12)
		pcOldDBC=DBC()
		SET DATA TO ("TASTRADE")
	ENDIF first trigger
	LOCAL lcParentID && parent's value to be sought in child
	LOCAL lcChildWkArea && child work area handle returned by riopen
	LOCAL lcParentWkArea
	LOCAL llDelHeaderarea
	LOCAL lcStartArea
	lcStartArea=select()
	llRetVal=.t.
	lcParentWkArea=select()
	SELECT (lcParentWkArea)
	pcParentDBF=dbf()
	pnParentRec=recno()
	STORE UPPER(LTRIM(SUPPLIER_ID)) TO lcParentID,pcParentID
	pcParentExpr="UPPER(LTRIM(SUPPLIER_ID))"
	lcChildWkArea=riopen("suppattn","supplier_i")
	IF lcChildWkArea<=0
		IF _triggerlevel=1
			DO riend WITH .F.
		ENDIF at the end of the highest trigger level
		RETURN .F.
	ENDIF not able to open the child work area
	pcChildDBF=dbf(lcChildWkArea)
	SELECT (lcChildWkArea)
	SEEK lcParentID
	SCAN WHILE UPPER(SUPPLIER_ID)=lcParentID AND llRetVal
		pnChildRec=recno()
		pcChildID=UPPER(SUPPLIER_ID)
		pcChildExpr="UPPER(SUPPLIER_ID)"
		llRetVal=ridelete()
	ENDSCAN get all of the suppattn records
	=rireuse("suppattn",lcChildWkArea)
	IF NOT llRetVal
		IF _triggerlevel=1
			DO riend WITH llRetVal
		ENDIF at the end of the highest trigger level
		SELECT (lcStartArea)
		RETURN llRetVal
	ENDIF
	IF _triggerlevel=1
		do riend with llRetVal
	ENDIF at the end of the highest trigger level
	SELECT (lcStartArea)
	RETURN llRetVal
	** "End of Referential integrity Delete trigger for" supplier
	********************************************************************************
	**__RI_FOOTER!@ Do NOT REMOVE or MODIFY this line!!!! @!__RI_FOOTER**
