function prod2type
	lparameter lprod_id,lworkline,ldbf
	if parameters( ) = 1
		lworkline = ''
	endif
	if parameters( ) = 3
		tsele = select()
		sele (ldbf)
		if seek(lworkline + lprod_id)
			lworkline = position
		else
			lworkline = ''
		endif
		sele (tsele)
	endif


	local set_exact,set_select,rt_item_type
	rt_item_type = ''
	set_exact=set('EXACT')
	set exact off
	set_select = select()
	idhead = left(lprod_id,3)

	do case
		case idhead = '1' and isalpha(subs(idhead,2,1)) = .t.	 && 1 + C
			do case
				case  lworkline = '2'
					rt_item_type =    '12.塑胶(喷油/丝印)'
				case  lworkline = '3'
					rt_item_type =    '13.塑胶(电镀)'
				case  lworkline = '4'
					rt_item_type =    '14.塑胶(植毛)'
				otherwise    && ==================== ?????
					rt_item_type =    '11.塑胶(生产部)'
			endcase

		case idhead = '1' and isdigit(subs(idhead,2,1)) = .t.	&& 1 + N
			do case
				case  between(idhead,'171','189')
					rt_item_type =    '22.电镀'
					*case isdigit(subs(idhead,2,1)) = .t.
				otherwise
					rt_item_type =    '21.喷油/丝印'
			endcase
		case idhead = '6'
			rt_item_type =  '9. 包装'
		case idhead = '361' or idhead = '539'
			rt_item_type =  '6. 充电电芯'
		case idhead = '537'
			rt_item_type  = '7. PCB'
		case idhead = '535'
			rt_item_type  = '8. 油樽'
		otherwise
			rt_item_type  =  '0. 其它'
	endcase

	sele (set_select)
	set exact &set_exact.
	retu rt_item_type
endfunc


function prod2grp
	lparameter lprod_id

	local idhead,set_exact
	set_exact=set('EXACT')
	set exact off
	idhead = left(lprod_id,3)
	if empty(idhead)
		retu
	endif

	do case
		case idhead = '1' and isalpha(subs(idhead,2,1)) = .t.	 && 1 + C
			rt_item_type =    '11'
		case idhead = '1' and isdigit(subs(idhead,2,1)) = .t.	&& 1 + N
			do case
				case  between(idhead,'171','180')
					rt_item_type =    '22'&&.电镀'
				otherwise
					rt_item_type =    '21'&&.喷油/丝印'
			endcase

		case idhead = '6'
			rt_item_type =  '23'
			*!*			case idhead = '531'
			*!*				rt_item_type =  '51'  &&6. 磨皮
			*!*			case idhead = '532'
			*!*				rt_item_type  = '52'  &&7. 充电座
			*!*			case idhead = '533'
			*!*				rt_item_type  = '53'
			*!*			case idhead = '534'
			*!*				rt_item_type  = '54'
		case idhead = '535'
			rt_item_type  = '55'
			*!*		case idhead = '536'
			*!*			rt_item_type  = '56'
		case idhead = '537'
			rt_item_type  = '57'
			*!*			case idhead = '538'
			*!*				rt_item_type  = '58'
		case idhead = '539'  or idhead = '361'   &&6. 充电电芯'
			rt_item_type  = '59'
		otherwise
			rt_item_type  =  '99'
	endcase
	set exact &set_exact.
	retu   rt_item_type

function prod2type_cdn
	lparameter lprod_id

	local idhead,set_exact
	set_exact=set('EXACT')
	set exact off

	idhead = left(lprod_id,3)
	if empty(idhead)
		loop
	endif

	do case
		case idhead = '1' and isalpha(subs(idhead,2,1)) = .t.	 && 1 + C
			rt_item_type =    '11'
		case idhead = '1' and isdigit(subs(idhead,2,1)) = .t.	&& 1 + N
			do case
				case  between(idhead,'171','180')
					rt_item_type =    '22'&&.电镀'
				otherwise
					rt_item_type =    '21'&&.喷油/丝印'
			endcase

		case idhead = '6'
			rt_item_type =  '23'
		case idhead = '531'
			rt_item_type = '99'  && '51'  &&6. 磨皮
		case idhead = '532'
			rt_item_type  = '99'  &&    '52'  &&7. 充电座
		case idhead = '533'   && 毛刷放到包装组别
			rt_item_type  = '23'  &&'53'
		case idhead = '534'
			rt_item_type  = '99'  && '54'装饰片 放到其它组别
		case idhead = '535'
			rt_item_type  = '55'
		case idhead = '536'
			rt_item_type  = '99'  &&  '56'
		case idhead = '537'
			rt_item_type  = '57'
		case idhead = '538'
			rt_item_type  =  '99'&& '58'
		case idhead = '539'  or idhead = '361'   &&6. 充电电芯'
			rt_item_type  = '59'
		otherwise  && 充电座\装饰片\五金加工 放到其它组别
			rt_item_type  =  '99'

	endcase

	set exact &set_exact.
	retu   rt_item_type

function is_eqitem
	lparameter lprod_id

	local idhead,set_exact
	set_exact=set('EXACT')
	set exact off
	rt_item_type = .f.
	idhead = left(lprod_id,3)
	if empty(idhead)
		retu rt_item_type
	endif

	do case
		case idhead = '534'
			rt_item_type  =  .t.
		case idhead = '531'
			rt_item_type  = .t.
		case idhead = '531'
			rt_item_type  =  .t.
		case idhead = '396'
			rt_item_type =    .t.
		case idhead = '37'
			rt_item_type  = .t.
		case idhead = '36'
			rt_item_type  = .t.
		case idhead = '35'
			rt_item_type  = .t.
		case idhead = '21'
			rt_item_type  = .t.
		otherwise
			rt_item_type  =  .f.

	endcase

	set exact &set_exact.
	retu   rt_item_type


function os_po2sdn
	lparameter lpo_key,ldtldbf,lmastdbf
	** ==============  计算PO 产品/物料未清数量 ============= **
	local set_exact,set_select
	set_exact=set('EXACT')
	set exact off
	set_select = select()
	id_value5 = 0
	id_value6 = 0
	id_value7 = {}  && ============ 排期表中会用到,记录最后收货(齐货)日期
	sele (ldtldbf)
	if seek(lpo_key,ldtldbf,'Po_key')
		sele (ldtldbf)
		set order to po_key
		scan rest while po_id + str(nth_dtl,7,5) = lpo_key
			if !seek(sdn_id,lmastdbf,'sdn_id') or &lmastdbf..status = '9' && Cancel
				loop
			endif
			if &lmastdbf..ship_date > id_value7
				id_value7   = &lmastdbf..ship_date
			endif
			id_value5 = id_value5 + quantity * qty_per
			id_value6 = id_value6 + round(quantity * unit_price * &lmastdbf..pur_exchan,price_decimal)
		endscan
	endif
	sele (set_select)
	set exact &set_exact.
	retu id_value5

function item_os_po2sdn
	lparameter lproduct_id,lpodtl,lpomast,lsdndtl,lsdnmast
	** ==============  计算产品/物料采购未清数量 ============= **
	local set_exact,set_select
	set_exact=set('EXACT')
	set exact off
	set_select = select()
	id_value5 = 0  && OS_quantity
	id_value6 = 0  && OS_amount

	local lpo_qty,lpo_amt,lgrn_qty,lgrn_amt,tmp_product_id,lpo_id,ltag1,ltag2
	store 0 to lpo_qty,lpo_amt,lgrn_qty,lgrn_amt

	sele (lsdndtl)
	ltag1 = tag()
	set order to po_item
	sele (lpodtl)
	ltag2 = tag()
	set order to product_id

	if !seek(lproduct_id,lpodtl)
		sele (lsdndtl)
		set order to (ltag1)
		sele (lpodtl)
		set order to (ltag2)
		sele (set_select)
		set exact &set_exact.
		retu 0
	endif

	sele (lpodtl)
	do while  product_id = lproduct_id and !eof()
		if &lpomast..status = '8' or &lpomast..status = '9'  && Complete or Cancel
			skip
			loop
		endif
		lpo_id = po_id
		scan rest while product_id = lproduct_id and po_id = lpo_id
			lpo_qty = lpo_qty + quantity * qty_per
			lpo_amt = lpo_amt + round(quantity * unit_price * &lpomast..pur_exchan,price_decimal)
		endscan
&& 汇总同一PO中同一物料采购数,处理podtl中有重复的product_id时,与SDNDTL中的对应关系不一致的情况.

&&	lgrn_qty = 0
		if seek(lpo_id + lproduct_id,lsdndtl)
			sele (lsdndtl)
			scan rest while po_id = lpo_id and product_id = lproduct_id
				if &lsdnmast..status = '9'   && Cancel
					loop
				endif
				lgrn_qty  = lgrn_qty + quantity * qty_per
				lgrn_amt  = lgrn_amt + round(quantity * unit_price * &lsdnmast..pur_exchan,price_decimal)
			endscan
		endif
		sele (lpodtl)
	enddo
	id_value5 = lpo_qty - lgrn_qty
	id_value6 = lpo_amt - lgrn_amt

	sele (lsdndtl)
	set order to (ltag1)
	sele (lpodtl)
	set order to (ltag2)
	sele (set_select)
	set exact &set_exact.
	retu lpo_qty - lgrn_qty


	** ========================================================================================================= **
function item_os_pr2sdn
	lparameter lproduct_id,lprpdtl,lprpmast,lsdndtl,lsdnmast
	local set_exact,set_select
	set_exact=set('EXACT')
	set exact off
	set_select = select()
	*!*		id_value5 = 0  && OS_quantity
	*!*		id_value6 = 0  && OS_amount

	local lprp_qty,lprp_amt,lgrn_qty,lgrn_amt,tmp_product_id,lprp_id,ltag1,ltag2
	store 0 to lprp_qty,lprp_amt,lgrn_qty,lgrn_amt

	sele (lsdndtl)
	ltag1 = tag()
	set order to sj_item
	sele (lprpdtl)
	ltag2 = tag()
	set order to product_id

	if !seek(lproduct_id,lprpdtl)
		sele (lsdndtl)
		set order to (ltag1)
		sele (lprpdtl)
		set order to (ltag2)
		sele (set_select)
		set exact &set_exact.
		retu 0
	endif

	sele (lprpdtl)
	do while  product_id = lproduct_id and !eof()
		if &lprpmast..status = '8' or &lprpmast..status = '9'  && Complete or Cancel
			skip
			loop
		endif
		lprp_id = prp_id
		scan rest while product_id = lproduct_id and prp_id = lprp_id
			lprp_qty = lprp_qty + quantity
		endscan
&&	lgrn_qty = 0
		if seek(lprp_id + lproduct_id,lsdndtl)
			sele (lsdndtl)
			scan rest while sj_id = lprp_id and product_id = lproduct_id
				if &lsdnmast..status = '9'   && Cancel
					loop
				endif
				lgrn_qty  = lgrn_qty + quantity * qty_per
			endscan
		endif
		sele (lprpdtl)
	enddo
	*!*		id_value5 = lprp_qty - lgrn_qty
	*!*		id_value6 = lprp_amt - lgrn_amt

	sele (lsdndtl)
	set order to (ltag1)
	sele (lprpdtl)
	set order to (ltag2)
	sele (set_select)
	set exact &set_exact.
	retu lprp_qty - lgrn_qty

	** ========================================================================================================= **

	** ========================================================================================================= **
function item_os_pr2sdn_rec
	lparameter lproduct_id,lprpdtl,lprpmast,lsdndtl,lsdnmast,losprdbf
	local set_exact,set_select
	set_exact=set('EXACT')
	set exact off
	set_select = select()
	id_value5 = 0  && OS_quantity
	*!*		id_value6 = 0  && OS_amount

	local lprp_qty,lprp_amt,lgrn_qty,lgrn_amt,tmp_product_id,lprp_id,ltag1,ltag2
	store 0 to lprp_qty,lprp_amt,lgrn_qty,lgrn_amt

	sele (lsdndtl)
	ltag1 = tag()
	set order to sj_key
	sele (lprpdtl)
	ltag2 = tag()
	set order to product_id

	if !seek(lproduct_id,lprpdtl)
		sele (lsdndtl)
		set order to (ltag1)
		sele (lprpdtl)
		set order to (ltag2)
		sele (set_select)
		set exact &set_exact.
		retu 0
	endif

	sele (lprpdtl)
	do while  product_id = lproduct_id and !eof()
		if &lprpmast..status = '8' or &lprpmast..status = '9'  && Complete or Cancel
			skip
			loop
		endif
		lprp_id  = prp_id
		lnth_dtl = nth_dtl
		lsj_key = lprp_id + str(nth_dtl,7,5)
		lprp_qty = lprp_qty + quantity
		lgrn_qty = 0
		if seek(lsj_key,lsdndtl)
			sele (lsdndtl)
			scan rest while sj_id = lprp_id and sj_nth_dtl = lnth_dtl
				if &lsdnmast..status = '9'   && Cancel
					loop
				endif
				lgrn_qty  = lgrn_qty + quantity * qty_per
			endscan
		endif
		sele (lprpdtl)
		if quantity >  lgrn_qty
			id_value5 =  id_value5 + quantity - lgrn_qty
			sele (losprdbf)
			append blank
			repl product_id with &lprpdtl..product_id
			repl quantity   with &lprpdtl..quantity - lgrn_qty
			repl ship_date  with &lprpdtl..ship_date
			repl jo_id      with &lprpdtl..jo_id
		endif
		sele (lprpdtl)
		skip
	enddo
	*!*		id_value5 = lprp_qty - lgrn_qty
	*!*		id_value6 = lprp_amt - lgrn_amt

	sele (lsdndtl)
	set order to (ltag1)
	sele (lprpdtl)
	set order to (ltag2)
	sele (set_select)
	set exact &set_exact.
	retu id_value5

	** ========================================================================================================= **



function os_jo2sdn
	lparameter ljo_key,ldtldbf,lmastdbf
	** ==============  计算jO 产品/物料未清数量 ============= **
	local set_exact,set_select
	set_exact=set('EXACT')
	set exact off
	set_select = select()
	id_value5 = 0
	id_value6 = 0
	sele (ldtldbf)
	if seek(ljo_key,ldtldbf,'jo_key')
		sele (ldtldbf)
		set order to jo_key
		scan rest while jo_id + str(jo_nth_dtl,7,5) = ljo_key
			if !seek(sdn_id,lmastdbf,'sdn_id') or &lmastdbf..status = '9' && Cancel
				loop
			endif
			id_value5 = id_value5 + quantity
			id_value6 = id_value6 + round(quantity * unit_price * &lmastdbf..pur_exchan,price_decimal)
		endscan
	endif
	sele (set_select)
	set exact &set_exact.
	retu id_value5

function os_jo2cdn
	lparameter ljo_key,ldtldbf,lmastdbf
	** ==============  计算jO 产品/物料未清数量 ============= **
	local set_exact,set_select
	set_exact=set('EXACT')
	set exact off
	set_select = select()
	id_value5 = 0
	id_value6 = 0
	sele (ldtldbf)
	if seek(ljo_key,ldtldbf,'jo_key')
		sele (ldtldbf)
		set order to jo_key
		scan rest while jo_id + str(jo_nth_dtl,7,5) = ljo_key
			if !seek(cdn_id,lmastdbf,'cdn_id') or &lmastdbf..status = '9' && Cancel
				loop
			endif
			id_value5 = id_value5 + quantity  &&  ?????? * qty_per
			id_value6 = id_value6 + round(quantity * unit_price * &lmastdbf..sal_exchan,price_decimal)
		endscan
	endif
	sele (set_select)
	set exact &set_exact.
	retu id_value5


function item_sdn_unpost
	lparameter lproduct_id,lsdndtl,lsdnmast
	** ==============  计算产品/物料采购未清数量 ============= **
	local set_exact,set_select
	set_exact=set('EXACT')
	set exact off
	set_select = select()
	id_value5 = 0  && OS_quantity
	id_value6 = 0  && OS_amount

	local lpo_qty,lpo_amt,lgrn_qty,lgrn_amt,tmp_product_id,lpo_id,ltag1,ltag2
	store 0 to lpo_qty,lpo_amt,lgrn_qty,lgrn_amt

	sele (lsdndtl)
	ltag1 = tag()
	set order to product_id
	if seek(lproduct_id,lsdndtl)
		sele (lsdndtl)
		scan rest while product_id = lproduct_id
			if empty(&lsdnmast..pdate2) or  &lsdnmast..posted = .t. or &lsdnmast..status = '9' && Cancel
				loop
			endif
			id_value5  = id_value5 + quantity * qty_per
			id_value6  = id_value6 + round(quantity * unit_price * &lsdnmast..pur_exchan,price_decimal)
		endscan
	endif

	sele (lsdndtl)
	set order to (ltag1)
	sele (set_select)
	set exact &set_exact.
	retu id_value5


function item_cdn_unpost
	lparameter lproduct_id,lcdndtl,lcdnmast
	** ==============  计算产品/物料出库未确认数量 ============= **
	local set_exact,set_select
	set_exact=set('EXACT')
	set exact off
	set_select = select()
	id_value5 = 0  && OS_quantity
	id_value6 = 0  && OS_amount

	local lpo_qty,lpo_amt,lgrn_qty,lgrn_amt,tmp_product_id,lpo_id,ltag1,ltag2
	store 0 to lpo_qty,lpo_amt,lgrn_qty,lgrn_amt

	sele (lcdndtl)
	ltag1 = tag()
	set order to product_id
	if seek(lproduct_id,lcdndtl)
		sele (lcdndtl)
		scan rest while product_id = lproduct_id
			if  empty(&lcdnmast..pdate2) or  &lcdnmast..posted = .t. or &lcdnmast..status = '9'   && Cancel
				loop
			endif

			id_value5  = id_value5 + quantity
			id_value6  = id_value6 + round(quantity * unit_price * &lcdnmast..sal_exchan,price_decimal)
		endscan
	endif

	sele (lcdndtl)
	set order to (ltag1)
	sele (set_select)
	set exact &set_exact.
	retu id_value5



function pr2po
	lparameter lprp_key,ldtldbf,lmastdbf
	** ==============  计算PR - PO 产品/物料未清数量 ============= **
	local set_exact,set_select
	set_exact=set('EXACT')
	set exact off
	set_select = select()
	id_value5 = 0
	id_value6 = 0
	id_value7 = ''

	sele (ldtldbf)
	ltag1 = tag()
	set order to sj_key
	sele (lmastdbf)
	ltag2 = tag()
	set order to po_id

	lfound = .f.

	sele (ldtldbf)
	if seek(lprp_key,ldtldbf)
		sele (ldtldbf)
		scan rest while sj_id + str(sj_nth_dtl,7,5) = lprp_key
			if !seek(po_id,lmastdbf,'po_id') or &lmastdbf..status = '9' && Cancel
				loop
			endif
			id_value7   = po_id
			id_value5 = id_value5 + quantity * qty_per
			id_value6 = id_value6 + round(quantity * unit_price * &lmastdbf..pur_exchan,price_decimal)
		endscan
	endif

	sele (ldtldbf)
	set order to (ltag1)
	sele (lmastdbf)
	set order to (ltag2)
	sele (set_select)
	set exact &set_exact.
	retu id_value5


function pr2sdn
	lparameter lprp_key,ldtldbf,lmastdbf
	** ==============  计算PO 产品/物料未清数量 ============= **
	local set_exact,set_select
	set_exact=set('EXACT')
	set exact off
	set_select = select()
	id_value5 = 0
	id_value6 = 0
	id_value7 = {}  && ============ 排期表中会用到,记录最后收货(齐货)日期
	sele (ldtldbf)
	ltag1 = tag()
	set order to sj_key
	sele (lmastdbf)
	ltag2 = tag()
	set order to sdn_id


	sele (ldtldbf)
	if seek(lprp_key,ldtldbf,'Po_key')
		sele (ldtldbf)
		scan rest while sj_id + str(sj_nth_dtl,7,5) = lprp_key
			if !seek(sdn_id,lmastdbf) or &lmastdbf..status = '9' && Cancel
				loop
			endif
			if &lmastdbf..ship_date > id_value7
				id_value7   = &lmastdbf..ship_date
			endif
			id_value5 = id_value5 + quantity * qty_per
			id_value6 = id_value6 + round(quantity * unit_price * &lmastdbf..pur_exchan,price_decimal)
		endscan
	endif
	sele (ldtldbf)
	set order to (ltag1)
	sele (lmastdbf)
	set order to (ltag2)
	sele (set_select)
	set exact &set_exact.
	retu id_value5

function itceiling
	lparameter nexp
	retu round(nexp+0.4,0)

	*================================================================*
function  usedbfexcl		&&...判断表是否可以打开     0—不可打开; 1 - 可独占使用;  2 - 可共享不能独占; 3 - 表不存在
	*================================================================*
	parameter  ltmpfile
	local  lerrorprocess , _iserr , retuvalue

	lerrorprocess = on('ERROR')
	on error _iserr = .t.
	_iserr = .f.
	if !file(alltrim(ltmpfile)+'.dbf')
		retuvalue = 0
	else
		use (ltmpfile) in 0 alias lopenvouc exclusive
		if _iserr     &&打开失败
			_iserr = .f.
			use (ltmpfile) in 0 alias lopenvouc share
			if _iserr     &&打开失败
				retuvalue = 0
			else
				use in lopenvouc
				retuvalue = 2
			endif
		else
			retuvalue = 1
			use in lopenvouc
		endif
	endif
	on error &lerrorprocess
	retu  retuvalue



	*================================================================*
function  sz_updstockout		&&...
	*================================================================*
	para ldoc_id,lin_out

	local set_locks,lselect,re_value
	set_locks = set('multilocks')
	set multilocks on
	lselect = select()
	re_value = .t.


	if used('cdnmast_updstock')
		use in cdnmast_updstock
	endif
	use cdnmast alias cdnmast_updstock order cdn_id in 0 again
	=cursorsetprop("Buffering", 3, "cdnmast_updstock")

	if used('cdndtl_updstock')
		use in cdndtl_updstock
	endif
	use cdndtl in 0 order cdn_id again alias cdndtl_updstock
	= cursorsetprop("Buffering", 3, "cdndtl_updstock")


	*set  relation to cdn_id into  cdnmast_updstock

	if used('products_updstock')
		use in products_updstock
	endif
	use products in 0 alias products_updstock order product_id again
	=cursorsetprop("Buffering", 5, "products_updstock")

	sele cdndtl_updstock
	if !seek(ldoc_id)
		wait wind 'No found!'
		use in cdndtl_updstock
		use in cdnmast_updstock
		use in products_updstock
		set multilocks &set_lock.
		retu .f.
	endif

*	begin transaction

	sele cdndtl_updstock
	scan rest while cdn_id = ldoc_id
		wait window tb_item_id + ':' + product_id  nowait
		if quantity = 0
			loop
		endif
		if seek(product_id,'products_updstock')
			sele products_updstock
			replace stock_out with stock_out + cdndtl_updstock.quantity * lin_out
		else
			messagebox('Item No error！【' + trim(product_id) + '】' , 48, 'System Infomation')
			loop
		endif
		sele cdndtl_updstock
	endscan

	sele products_updstock
	if !tableupdate(.t.,.t.)
		re_value = .f.
		= tablerevert(.t.)
	else
	*	end transaction
	endif

	*!*	    if  re_value = .T.
	*!*	        sele cdnmast_updstock
	*!*	        replace adatetime with datetime()
	*!*	        replace adate with pauluser_create()
	*!*	        if lin_out = 1
	*!*			    replace posted with .T.
	*!*				replace status with  '8'
	*!*				replace pdate with pauluser_create()
	*!*	       else
	*!*	          	replace posted with .F.
	*!*				replace status with '2'
	*!*				replace pdate with ""
	*!*	       endif
	*!*	    endif

	use in cdndtl_updstock
	use in cdnmast_updstock
	use in products_updstock
	set multilocks &set_locks.

	sele (lselect)

	retu re_value

	*================================================================*
function  sz_updstockin		&&...
	*================================================================*
	para ldoc_id,lin_out

	local set_locks,lselect,re_value
	set_locks = set('multilocks')
	set multilocks on
	lselect = select()
	re_value = .t.


	if used('sdnmast_updstock')
		use in sdnmast_updstock
	endif
	use sdnmast alias sdnmast_updstock order sdn_id in 0 again
	=cursorsetprop("Buffering", 3, "sdnmast_updstock")

	if used('sdndtl_updstock')
		use in sdndtl_updstock
	endif
	use sdndtl in 0 order sdn_id again alias sdndtl_updstock
	= cursorsetprop("Buffering", 3, "sdndtl_updstock")


	*set  relation to sdn_id into  sdnmast_updstock

	if used('products_updstock')
		use in products_updstock
	endif
	use products in 0 alias products_updstock order product_id again
	=cursorsetprop("Buffering", 5, "products_updstock")

	sele sdndtl_updstock
	if !seek(ldoc_id)
		wait wind 'No found!'
		use in sdndtl_updstock
		use in sdnmast_updstock
		use in products_updstock
		set multilocks &set_lock.
		retu .f.
	endif

	*!*		begin transaction

	sele sdndtl_updstock
	scan rest while sdn_id = ldoc_id
		wait window tb_item_id + ':' + product_id  nowait
		if quantity = 0
			loop
		endif
		if seek(product_id,'products_updstock')
			sele products_updstock
			replace stock_in with stock_in + sdndtl_updstock.quantity * lin_out
		else
			messagebox('Item No error！【' + trim(product_id) + '】' , 48, 'System Infomation')
			loop
		endif
		sele sdndtl_updstock
	endscan

	sele products_updstock
	if !tableupdate(.t.,.t.)
		re_value = .f.
		= tablerevert(.t.)
		*!*		   	rollback
	else
		*!*		   end transaction
	endif

	*!*	    if  re_value = .T.
	*!*	        sele sdnmast_updstock
	*!*	        replace adatetime with datetime()
	*!*	        replace adate with pauluser_create()
	*!*	        if lin_out = 1
	*!*			    replace posted with .T.
	*!*				replace status with  '8'
	*!*				replace pdate with pauluser_create()
	*!*	       else
	*!*	          	replace posted with .F.
	*!*				replace status with '2'
	*!*				replace pdate with ""
	*!*	       endif
	*!*	    endif

	use in sdndtl_updstock
	use in sdnmast_updstock
	use in products_updstock
	set multilocks &set_locks.

	sele (lselect)

	retu re_value


PROCEDURE findw
 PARAMETER IDE
 DECLARE LONG FindWindowA IN WIN32API STRING , STRING 
 HG = FINDWINDOWA(0,IDE)
 IF HG > 0
    CLEAR DLLS FindWindowA
    RETURN .T.
 ELSE 
    CLEAR DLLS FindWindowA
    RETURN .F.
 ENDIF 
 RETURN 
ENDPROC


PROCEDURE ontop
PARAMETERS jia
DECLARE LONG SetForegroundWindow IN 'USER32' LONG
=SetForegroundWindow(jia)
CLEAR DLLS SetForegroundWindow
retu

******错误捕捉*********
PROCEDURE error1
PARAMETERS errorid,messageid,linenoid,programid
MESSAGEBOX('程序在运行过程中出现错误！'+CHR(13)+REPLICATE('-',50)+CHR(13)+'错误号：'+ALLTRIM(STR(errorid))+CHR(13)+'错误信息：'+messageid+CHR(13)+'出错行号：'+STR(linenoid)+CHR(13)+'出错模块：'+programid,+256+16,'出错提示')
RETURN

Function XlsFillPic
Parameters Loexcel,Pic_path,LnPicHight,LnPicWidth,LnRightoffset,LnBottomOffset
&& 参数说明: Excel对象,图像路径[,高度][,宽度]	&& 可以任意指定高度或宽度中间的一个,另一个则按比例计算出来.
&& Excel对象,图片路径,高度,宽度,向右偏移位数,向下偏移位数 (位数以按一次方向键*0.75计,填4就差不多了)
IF vartype(LoExcel) # 'O'
	Return .F.
Endif
IF Empty(Pic_Path) or !File(Pic_path)
	Pic_Path = ''
	Return .F.
Endif
LoExcel.ActiveSheet.Pictures.Insert(Pic_path).Select
LoExcel.Selection.ShapeRange.LockAspectRatio = -1     && 按比例缩放
LnOrgHight = LoExcel.Selection.ShapeRange.Height       && 原始高度
LnOrgWidth = LoExcel.Selection.ShapeRange.Width        && 原始宽度
If !Empty(LnRightoffset) and vartype(LnRightoffset)='N'
	LoExcel.Selection.ShapeRange.IncrementLeft(LnRightoffset * 0.75)
Endif

If !Empty(LnBottomOffset) and vartype(LnBottomOffset)='N'
	LoExcel.Selection.ShapeRange.IncrementTop(LnRightoffset * 0.75)
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

