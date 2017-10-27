Procedure Paulscantable
	Lparameter Plfromdbf , Pltempdbf , Plusedbf , Plseek , Plfield , Plstart , Plend ,  ;
		Plcondition , Plno_rec , Paulorder , Paulaorb , Plzap , Plsecurity
	Local Paulset_near , Paulset_exact , Plfilter , Paulorder , Paulaorb , Pltempindex
	On Error Return
	If  .not. Empty(plsecurity)
		If Upper(plsecurity) = 's' And Id_value <> 'alerteml' And  ;
				.not. (security_id = 'super' .or. Security_id = 'bos' .or. Security_id = 'admin')
			Plcondition =  ;
				' .and. ' +  ;
				'(security_id=sec_grp .or. Security_id2=sec_grp .or. Security_id3=sec_grp .or. Security_id4=sec_grp .or. Security_id5=sec_grp)'
		Endif
	Endif
	Plfilter = Plfield + ' >= ' + Plstart + ' .and. ' + Plfield + ' <= ' + Plend
	Paulalias = Alltrim(plfromdbf) + 'sql'
	Paulaliasold = Alltrim(pltempdbf) + 'old'
	Paultemp = Curdir() + 'tempdbc\' + Alltrim(pltempdbf)
	Pltempindex = '_tmp' + Alltrim(plfromdbf)
	If Used(paulaliasold)
		Use In (paulaliasold)
	Endif
	If Used(paulalias)
		Use In (paulalias)
	Endif
	If Used(plusedbf)
		Use In (plusedbf)
	Endif
	If Empty(pltempdbf)
		Use In 0 (plfromdbf) Again Alias (plusedbf)
		Select (plusedbf)
		If  .not. Empty(paulorder)
			If  .not. Empty(paulaorb)
				If At('+',paulorder) > 0
					Wait Window Nowait 'sorting On :' + Substr(paulorder,1,20) + '...'
					Index On &paulorder. To &pltempindex. &paulaorb.
				Else
					Set Order To &paulorder. &paulaorb.
				Endif
			Else
				If At('+',paulorder) > 0
					Wait Window Nowait 'sorting On :' + Substr(paulorder,1,20) + '...'
					Index On &paulorder. To &pltempindex.
				Else
					Set Order To &paulorder.
				Endif
			Endif
		Endif
		Return .t.
	Endif
	Use In 0 (paultemp) Again Alias (paulaliasold)
	Use In (paulaliasold)
	Use In 0 Exclusive (paultemp) Again Alias (paulaliasold)
	Select (paulaliasold)
	If At('tempdbc',paultemp) > 0
		If Empty(plzap)
			Zap
		Endif
	Endif
	Use In 0 (plfromdbf) Again Alias (paulalias) Order (plseek)
	Select (paulalias)
	Paulset_near = Set('near')
	Set Near On
	Go Top
	Seek &plstart.
	Set Near &paulset_near.
	If Eof()
		Use In (paulalias)
		Use In (paulaliasold)
		Use In 0 (paultemp) Again Alias (plusedbf)
		Select (plusedbf)
		If Id_value <> 'alerteml'
			= Paulmessage('nothing To Print !','warning')
		Endif
		Lrprint = 999
		Return .t.
	Endif
	Paulretrive = 1
	Do While Macros  ???fun[ca] ('.not. Eof(paulalias) .and. &plfilter.  ')
		If &plcondition.
			Scatter Memo Memvar
			Select (paulaliasold)
			Insert Into (paulaliasold) From Memvar
			Paulretrive = Paulretrive + 1
		Endif
		Select (paulalias)
		If  .not. Eof()
			Skip
		Endif
		Wait Window Nowait 'scanning Records : ' + Alltrim(str(paulretrive - 1,7))
		If Paulretrive / Plno_rec = Int(paulretrive / Plno_rec)
			If  .not. Paulask_yn(alltrim(str(paulretrive - 1,7)) + ' Record(s) Retrived !  Continue... ? ','warning')
				Exit
			Endif
		Endif
	Enddo
	Use In (paulalias)
	Use In (paulaliasold)
	Use In 0 (paultemp) Again Alias (plusedbf)
	Select (plusedbf)
	If  .not. Empty(paulorder)
		If  .not. Empty(paulaorb)
			If At('+',paulorder) > 0
				Wait Window Nowait 'sorting On :' + Substr(paulorder,1,20) + '...'
				Index On &paulorder. To &pltempindex. &paulaorb.
			Else
				Set Order To &paulorder. &paulaorb.
			Endif
		Else
			If At('+',paulorder) > 0
				Wait Window Nowait 'sorting On :' + Substr(paulorder,1,20) + '...'
				Index On &paulorder. To &pltempindex.
			Else
				Set Order To &paulorder.
			Endif
		Endif
	Endif
	Return .t.
Endproc