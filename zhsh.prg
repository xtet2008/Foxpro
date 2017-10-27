 DEFINE   CLASS   person   AS   CUSTOM   OLEPUBLIC   
 	* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	*  文件名: ROGER.PRG(主文件) <-- 本文件由 UnFoxAll 创建
	* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

	Procedure Lc_Fields
		Lparameter LC_1 , LC_TABLE
		Local TEMP_ALIAS , LC_CONTROL , FIELDS_COUNT , TEMP_FIELD
		If Parameters() < 1
			Return
		Else
			If  .Not. Empty(LC_1) And Upper(Vartype(LC_1)) = 'C'
				LC_1 = Upper(Alltrim(LC_1))
			Else
				Return
			Endif
		Endif
		If Parameters() < 2
			If  .Not. Empty(Alias())
				TEMP_ALIAS = Alias()
			Else
				Return
			Endif
		Else
			TEMP_ALIAS = LC_TABLE
		Endif
		If Select(TEMP_ALIAS) = 0
			If File(TEMP_ALIAS + '.dbf')
				Use In 0 Shared (TEMP_ALIAS) Again
			Else
				Wait Window Nowait 'The ' + TEMP_ALIAS + ' table can not find .'
				Return
			Endif
		Endif
		Select (TEMP_ALIAS)
		FIELDS_COUNT = ''
		For Lc_Fields = 1 To Fcount(TEMP_ALIAS)
			TEMP_FIELD = Field(Lc_Fields,TEMP_ALIAS)
			If LC_1 $ TEMP_FIELD
				If Empty(FIELDS_COUNT)
					FIELDS_COUNT = TEMP_FIELD
				Else
					FIELDS_COUNT = FIELDS_COUNT + ',' + TEMP_FIELD
				Endif
			Endif
		Endfor
		Select (TEMP_ALIAS)
		If  .Not. Empty(FIELDS_COUNT)
			Browse Fields &FIELDS_COUNT. Last Nowait
		Else
	*!*			TEMPVALUE = ALLFIELDS()
	*!*			Browse Fields &TEMPVALUE. Last Nowait
			Wait Window Nowait 'There is no any fields which you want to browse !!'
		Endif
		Return
	Endproc
	*------
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
	*!*			TEMPVALUE = ALLFIELDS()
	*!*			Browse Fields &ALLFIELDS. Last Nowait
			Wait Window Nowait 'There are no any fields empty !'
		Endif
		Return
	Endproc
	*------
	Procedure Lc_Replace
		Lparameter LC_OLD , LC_NEW , LC_DBF , LC_FIELDIN , LC_SCOPE , LC_TYPE , LC_CONDITION
		If Parameters() < 2
			Wait Window Nowait 'Please type the old value and new value !'
			Return 0
		Endif
		If Empty(LC_DBF)
			If Empty(Alias())
				Wait Window Nowait 'No table is open the current work area. '
				Return 0
			Else
				LC_DBF = Alias()
			Endif
		Else
			If Select(LC_DBF) = 0
				If File(LC_DBF + '.dbf')
					Use In 0 Shared (LC_DBF) Again
				Else
					Wait Window Nowait 'The table of ' + LC_DBF + ' not exist !'
					Return 0
				Endif
			Endif
		Endif
		If Empty(LC_TYPE)
			LC_TYPE = 'C'
		Endif
		If Vartype(LC_TYPE) <> 'C'
			Wait Window Nowait  ;
				'You must type the lc_type in' + Chr(13) + Chr(13) + ' C ' + Chr(13) + ' N' +  ;
				CHR(13) + ' L' + Chr(13) + ' M' + Chr(13) + 'D' + Chr(13) + 'T'
			Return 0
		Endif
		LC_TYPE = Upper(Alltrim(LC_TYPE))
		Do Case
			Case Upper(LC_TYPE) == 'C'
				If  .Not. (Vartype(LC_OLD) = 'C' And Vartype(LC_NEW) = 'C')
					Wait Window Nowait 'You amust type the old vaule and new value in character !'
					Return 0
				Endif
			Case Upper(LC_TYPE) == 'N'
				If  .Not. (Vartype(LC_OLD) = 'N' And Vartype(LC_NEW) = 'N')
					Wait Window Nowait 'You must type the old value and new value in number !'
					Return 0
				Endif
			Case Upper(LC_TYPE) == 'L'
				If  .Not. (Vartype(LC_OLD) = 'L' And Vartype(LC_NEW) = 'L')
					Wait Window Nowait 'You must type the old value and new value in logic !'
					Return 0
				Endif
			Case Upper(LC_TYPE) == 'M'
				If  .Not. (Vartype(LC_OLD) = 'M' And Vartype(LC_NEW) = 'M')
					Wait Window Nowait 'You must type the old value and new value in memo !'
					Return 0
				Endif
			Case Upper(LC_TYPE) == 'D'
				If  .Not. (Vartype(LC_OLD) = 'D' And Vartype(LC_NEW) = 'D')
					Wait Window Nowait 'You must type the old value and new value in date !'
					Return 0
				Endif
			Case Upper(LC_TYPE) == 'T'
				If  .Not. ((Vartype(LC_OLD) = 'T' .Or. Vartype(LC_TYPE) = 'C') And  ;
						(Vartype(LC_NEW) = 'C' .Or. Vartype(LC_NEW) = 'C'))
					Wait Window Nowait  ;
						'You must type the old value and new value in Datetime(T) or in character which can convert to datetime !'
					Return 0
				Endif
			Otherwise
				Wait Window Nowait  ;
					'You must type the lc_type in' + Chr(13) + Chr(13) + ' C ' + Chr(13) + ' N' +  ;
					CHR(13) + ' L' + Chr(13) + ' M' + Chr(13) + 'D' + Chr(13) + 'T'
				Return 0
		Endcase
		If  .Not. Empty(LC_FIELDIN)
			If  .Not. LC_FIELDIN(LC_FIELDIN,LC_DBF)
				Wait Window Nowait  ;
					'The field of ' + LC_FIELDIN + ' is not in the ' + LC_DBF + ' table !'
				Return 0
			Endif
			Select (LC_DBF)
			Scan
				If  .Not. Empty(LC_CONDITION)
					If Not &LC_CONDITION. Then
						Loop
					Endif
				Endif
				LC_TEMPVALUE = LC_DBF + '.' + LC_FIELDIN
				Do Case
					Case LC_TYPE = 'C'
						If Vartype(&LC_TEMPVALUE)<>'C' Then
							Loop
						Endif
					Case LC_TYPE = 'N'
						If Vartype(&LC_TEMPVALUE)<>'N' Then
							Loop
						Endif
					Case LC_TYPE = 'M'
						If Vartype(&LC_TEMPVALUE)<>'C' Then
							Loop
						Endif
					Case LC_TYPE = 'L'
						If Vartype(&LC_TEMPVALUE)<>'L' Then
							Loop
						Endif
					Case LC_TYPE = 'D'
						If Vartype(&LC_TEMPVALUE)<>'D' Then
							Loop
						Endif
					Case LC_TYPE = 'T'
						If Vartype(&LC_TEMPVALUE)<>'T' Then
							Loop
						Endif
				Endcase
				If LC_TYPE = 'C' .Or. LC_TYPE = 'M'
					If Upper(LC_OLD) $ Upper(&LC_TEMPVALUE) Then
						If LC_SCOPE
							If LC_OLD==Alltrim(&LC_TEMPVALUE) Then
								Replace &LC_TEMPVALUE. With LC_NEW
							Endif
						Else
							Replace &LC_TEMPVALUE. With Strtran(&LC_TEMPVALUE.,LC_OLD,LC_NEW)
						Endif
					Endif
				Else
					If LC_OLD = &LC_TEMPVALUE Then
						Replace &LC_TEMPVALUE. With LC_NEW
					Endif
				Endif
			Endscan
		Else
			Select (LC_DBF)
			Scan
				If  .Not. Empty(LC_CONDITION)
					If Not &LC_CONDITION. Then
						Loop
					Endif
				Endif
				For LC_CONTROL = 1 To Fcount(LC_DBF)
					LC_TEMPVALUE = LC_DBF + '.' + Field(LC_CONTROL,LC_DBF)
					Do Case
						Case LC_TYPE = 'C'
							If Vartype(&LC_TEMPVALUE)<>'C' Then
								Loop
							Endif
						Case LC_TYPE = 'N'
							If Vartype(&LC_TEMPVALUE)<>'N' Then
								Loop
							Endif
						Case LC_TYPE = 'M'
							If Vartype(&LC_TEMPVALUE)<>'C' Then
								Loop
							Endif
						Case LC_TYPE = 'L'
							If Vartype(&LC_TEMPVALUE)<>'L' Then
								Loop
							Endif
						Case LC_TYPE = 'D'
							If Vartype(&LC_TEMPVALUE)<>'D' Then
								Loop
							Endif
						Case LC_TYPE = 'T'
							If Vartype(&LC_TEMPVALUE)<>'T' Then
								Loop
							Endif
					Endcase
					If LC_TYPE = 'C' .Or. LC_TYPE = 'M'
						If Upper(LC_OLD) $ Upper(&LC_TEMPVALUE.) Then
							If LC_SCOPE
								If LC_OLD==Alltrim(&LC_TEMPVALUE.) Then
									Replace &LC_TEMPVALUE. With LC_NEW
								Endif
							Else
								Replace &LC_TEMPVALUE. With Strtran(Upper(&LC_TEMPVALUE.),Upper(LC_OLD),LC_NEW)
							Endif
						Endif
					Else
						If LC_OLD = &LC_TEMPVALUE. Then
							Replace &LC_TEMPVALUE. With LC_NEW
						Endif
					Endif
				Endfor
			Endscan
		Endif
		Return
	Endproc
	*------
	Procedure LC_FIELDIN
		Lparameter LCFIELDNAME , LC_TABLE , AutoClose
		If Vartype(LCFIELDNAME) <> 'C'
			Wait Window Nowait 'Field name only can type in character !'
			Return .F.
		Else
			If Empty(Alltrim(LCFIELDNAME))
				Wait Window Nowait 'Field name can not empty ! '
				Return .F.
			Endif
		Endif
		If Empty(AutoClose)
			AutoClose = .F.
		Else
			If Vartype(AutoClose) <> 'L'
				Wait Window Nowait ' Autoclose  default value in .F. ! '
				AutoClose = .F.
			Endif
		Endif
		Local LC_CURRENT_DBF
		LC_CURRENT_DBF = Select()
		If Empty(LC_TABLE)
			AutoClose = .F.
			If Empty(Alias())
				Wait Window Nowait 'No table is open in the current area. '
				Return .F.
			Else
				LC_TABLE = Alias()
			Endif
		Else
			If Select(LC_TABLE) = 0
				If File(LC_TABLE + '.dbf')
					Use In 0 Shared (LC_TABLE) Again
				Else
					Wait Window Nowait 'The table of ' + LC_TABLE + ' is not exist !'
					Return .F.
				Endif
			Endif
		Endif
		Local LCCONTROLTEMP2
		For LCCONTROLTEMP2 = 1 To Fcount(LC_TABLE)
			If Alltrim(Upper(LCFIELDNAME)) == Field(LCCONTROLTEMP2,LC_TABLE)
				LCTEMP_VALUE = LC_TABLE + '.' + Field(LCCONTROLTEMP2,LC_TABLE)
				If Vartype(&LCTEMP_VALUE.)<>'U' Then
					If AutoClose
						Use In (LC_TABLE)
					Endif
					If LC_CURRENT_DBF > 0
						Select (LC_CURRENT_DBF)
					Endif
					Return .T.
					Exit
				Endif
			Endif
		Endfor
		If AutoClose
			Use In (LC_TABLE)
		Endif
		If LC_CURRENT_DBF > 0
			Select (LC_CURRENT_DBF)
		Endif
		Return .F.
	Endproc
	*------
	Procedure FileName
		Lparameter NAME1 , NAME2
		If Parameters() < 2
			Return ''
		Endif
		If Vartype(NAME1) <> 'C' .Or. Vartype(NAME2) <> 'C'
			Return ''
		Endif
		If Empty(Alltrim(NAME1)) .Or. Empty(Alltrim(NAME2))
			Return ''
		Endif
		NAME1 = Alltrim(NAME1)
		NAME2 = Alltrim(NAME2)
		Local LCFILENAME , LCTEMPSTART
		LCTEMPSTART = 2
		LCFILENAME = NAME1 + '.' + NAME2
		If File(LCFILENAME)
			LCFILENAME = NAME1 + '_' + Alltrim(Str(LCTEMPSTART)) + '.' + NAME2
			Do While File(LCFILENAME)
				LCTEMPSTART = LCTEMPSTART + 1
				LCFILENAME = NAME1 + '_' + Alltrim(Str(LCTEMPSTART)) + '.' + NAME2
			Enddo
		Endif
		Return LCFILENAME
	Endproc
	*------
	Procedure AliasName
		Lparameter NAME1
		If Parameters() < 1
			Return Sys(2015)
		Endif
		If Vartype(NAME1) <> 'C'
			Return Sys(2015)
		Endif
		NAME1 = Alltrim(NAME1)
		If Used(NAME1)
			Local LCSTART , NEWNAME
			LCSTART = 2
			NEWNAME = NAME1 + Alltrim(Str(LCSTART))
			Do While Used(NEWNAME)
				LCSTART = LCSTART + 1
				NEWNAME = NAME1 + Alltrim(Str(LCSTART))
			Enddo
			Return NEWNAME
		Else
			Return NAME1
		Endif
	Endproc
	*------
	Procedure GbConvert
		Lparameter LCVALUE , LCTYPE
		If Parameters() < 2
			Wait Window Nowait 'Please type the convert value and convert type !'
			Return ''
		Endif
		If Vartype(LCVALUE) <> 'C'
			Wait Window Nowait 'Please sure the convert value in character ! '
			Return ''
		Else
			If Empty(LCVALUE)
				Return ''
			Endif
		Endif
		If Vartype(LCTYPE) <> 'N'
			Wait Window Nowait 'Please sure the convert type in number !'
			Return ''
		Else
			If  .Not. (LCTYPE = 1 .Or. LCTYPE = 2)
				Wait Window Nowait 'Please sure the convert type in 1 or 2 !'
				Return ''
			Endif
		Endif
		Local LCTEMPVALUE
		LCTEMPVALUE = LCVALUE
		Declare Integer GBToBig5 In 'mchset.dll' String @
		Declare Integer Big5ToGB In 'mchset.dll' String @
		If LCTYPE = 1
			GBToBig5(@LCTEMPVALUE)
		Else
			Big5ToGB(@LCTEMPVALUE)
		Endif
		Return LCTEMPVALUE
	Endproc
	*------
	Procedure DbfAlias
		Lparameter LCFILENAME
		If Vartype(LCFILENAME) <> 'C'
			Wait Window Nowait 'Please sure the file name in character !'
			Return ''
		Else
			LCFILENAME = Alltrim(LCFILENAME)
			If Empty(LCFILENAME)
				Wait Window Nowait 'Please sure the file name not empty !'
				Return ''
			Endif
		Endif
		Local LCDBFALIAS
		Do Case
			Case  .Not. ('\' $ LCFILENAME .Or. '.DBF' $ Upper(LCFILENAME))
				LCDBFALIAS = LCFILENAME
			Case '\' $ LCFILENAME And '.DBF' $ Upper(LCFILENAME)
				LCDBFALIAS = Substr(LCFILENAME,Rat('\',LCFILENAME) + 1)
				LCDBFALIAS = Left(LCDBFALIAS,Len(LCDBFALIAS) - 4)
			Case '\' $ LCFILENAME And  .Not. '.DBF' $ Upper(LCFILENAME)
				LCDBFALIAS = Substr(LCFILENAME,Rat('\',LCFILENAME) + 1)
			Case '.DBF' $ Upper(LCFILENAME) And  .Not. '\' $ LCFILENAME
				LCDBFALIAS = Left(LCFILENAME,Len(LCFILENAME) - 4)
			Otherwise
				LCDBFALIAS = LCFILENAME
		Endcase
		Return LCDBFALIAS
	Endproc
	*------
	*------
	Procedure CharactersAdd
		Lparameter LCPLUS , CHARACTER1 , CHARACTER2 , CHARACTER3 , CHARACTER4 , CHARACTER5 ,  ;
			CHARACTER6 , CHARACTER7 , CHARACTER8 , CHARACTER9 , CHARACTER10 ,  ;
			CHARACTER11 , CHARACTER12 , CHARACTER13 , CHARACTER14 , CHARACTER15 ,  ;
			CHARACTER16 , CHARACTER17 , CHARACTER18 , CHARACTER19 , CHARACTER20 ,  ;
			CHARACTER21 , CHARACTER22 , CHARACTER23 , CHARACTER24 , CHARACTER25 ,  ;
			CHARACTER26
		If Pcount() < 3
			Wait Window Nowait 'Please type the add plus and two characters at least !'
			Return ''
		Endif
		If Vartype(LCPLUS) <> 'C'
			LCPLUS = ','
		Endif
		If LCPLUS == ''
			LCPLUS = ','
		Endif
		If Vartype(CHARACTER1) <> 'C' .Or. Empty(CHARACTER1) .Or. Vartype(CHARACTER2) <> 'C' .Or.  ;
				EMPTY(CHARACTER2)
			Wait Window Nowait  ;
				'Please sure the first and second characters are not empty and in characters !'
			Return ''
		Endif
		Local LCRETURNCHARACTERS , LCTEMPVALUE , LCCONTROLTEMP5
		LCRETURNCHARACTERS = CHARACTER1
		For LCCONTROLTEMP5 = 2 To Pcount()
			LCTEMPVALUE = 'Character' + Alltrim(Str(LCCONTROLTEMP5))
			If Vartype(&LCTEMPVALUE.)<>'C' Then
				Exit
			Else
				LCRETURNCHARACTERS=LCRETURNCHARACTERS+LCPLUS+&LCTEMPVALUE.
			Endif
		Endfor
		Return LCRETURNCHARACTERS
	Endproc
	*------
	Procedure LcDbfOpen
		Lparameter LCTEMPDBFNAME , LCTEMPDBFALIAS , LCTEMPEXCLUSIVE , LCTEMPORDER
		If Pcount() < 1
			Return .F.
		Endif
		If Vartype(LCTEMPDBFNAME) <> 'C' .Or. Empty(LCTEMPDBFNAME)
			Return .F.
		Endif
		If Vartype(LCTEMPEXCLUSIVE) <> 'L' .Or. Empty(LCTEMPEXCLUSIVE)
			LCTEMPEXCLUSIVE = .F.
		Endif
		If Pcount() < 2
			LCTEMPDBFALIAS = LCTEMPDBFNAME + 'R'
		Endif
		If Select(LCTEMPDBFALIAS) <> 0
			Return .F.
		Endif
		If  .Not. Upper('.DBF') $ Upper(LCTEMPDBFNAME)
			LCTEMPDBFNAME = LCTEMPDBFNAME + '.Dbf'
		Endif
		If  .Not. File(LCTEMPDBFNAME)
			Return .F.
		Endif
		If Vartype(LCTEMPORDER) = 'C'
			LCTEMPORDER = Alltrim(LCTEMPORDER)
		Else
			LCTEMPORDER = ''
		Endif
		If Empty(LCTEMPORDER)
			LCTEMPORDER = ''
		Endif
		Local LCTEMPSELECT
		LCTEMPSELECT = Select()
		Local TEMP_ONERROR , TEMP_FINDERROR
		TEMP_ONERROR = On('Error')
		TEMP_FINDERROR = .F.
		On Error TEMP_FINDERROR=.T.
		If  .Not. LCTEMPEXCLUSIVE
			Use In 0 Shared (LCTEMPDBFNAME) Again Alias (LCTEMPDBFALIAS)
		Else
			Use In 0 Exclusive (LCTEMPDBFNAME) Alias (LCTEMPDBFALIAS)
		Endif
		If  .Not. Empty(LCTEMPORDER)
			Select (LCTEMPDBFALIAS)
			Set Order To LCTEMPORDER
		Endif
		If LCTEMPSELECT <> 0
			Select (LCTEMPSELECT)
		Endif
		On Error &TEMP_ONERROR.
		If TEMP_FINDERROR
			Return .F.
		Else
			Return .T.
		Endif
	Endproc
	*------
	Procedure LcDbfClose
		Lparameter LCTEMPDBFALIAS , LCALIASADD
		If Pcount() < 1
			Return
		Endif
		If Vartype(LCTEMPDBFALIAS) <> 'C' .Or. Empty(LCTEMPDBFALIAS)
			Return
		Endif
		If Vartype(LCALIASADD) <> 'C' .Or. Empty(LCALIASADD)
			LCALIASADD = ''
		Else
			LCALIASADD = Alltrim(LCALIASADD)
			LCTEMPDBFALIAS = Alltrim(LCTEMPDBFALIAS) + LCALIASADD
		Endif
		Local LCTEMPSELECT
		LCTEMPSELECT = Select()
		If Select(LCTEMPDBFALIAS) = 0
			Return
		Else
			Use In (LCTEMPDBFALIAS)
		Endif
		If LCTEMPSELECT <> 0
			Select (LCTEMPSELECT)
		Endif
	Endproc
	*------
	Procedure LcSetRelation
		Lparameter LCDBF1 , LCDBF2 , LCEXPRESSION , LCDBF2ORDER , LCONOFF , LCNOADDITIVE
		If Parameters() < 3
			Return .F.
		Endif
		If Select(LCDBF1) = 0 .Or. Select(LCDBF2) = 0
			Wait Window Nowait 'Please sure the two tables are opened !'
			Return .F.
		Endif
		If Vartype(LCEXPRESSION) <> 'C' .Or. Empty(LCEXPRESSION)
			Wait Window Nowait 'Please sure the relation expression in right !'
			Return .F.
		Endif
		If Vartype(LCDBF2ORDER) <> 'C' .Or. Empty(LCDBF2ORDER)
			LCDBF2ORDER = ''
		Endif
		If Vartype(LCONOFF) <> 'C' .Or. Empty(LCONOFF)
			LCONOFF = 'ON'
		Else
			LCONOFF = Upper(Alltrim(LCONOFF))
			If LCONOFF <> 'ON' And LCONOFF <> 'OFF'
				LCONOFF = 'ON'
			Endif
		Endif
		If LCONOFF = 'ON'
			LCONOFF = .T.
		Else
			LCONOFF = .F.
		Endif
		If Vartype(LCNOADDITIVE) <> 'L'
			LCNOADDITIVE = .F.
		Endif
		Local LCTEMPSELECT , LCADDITIVE , LCNEEDRELATION , LCTEMPCONTROL , LCRETURNVALUE
		LCADDITIVE =  .Not. LCNOADDITIVE
		LCTEMPSELECT = Select()
		If  .Not. Empty(LCDBF2ORDER)
			Select (LCDBF2)
			Set Order To LCDBF2ORDER
		Endif
		LCNEEDRELATION = .T.
		LCRETURNVALUE = .T.
		LCTEMPCONTROL = 1
		Do While  .Not. Empty(Alltrim(Target(LCTEMPCONTROL,LCDBF1)))
			If Alltrim(Upper(Target(LCTEMPCONTROL,LCDBF1))) == Alltrim(Upper(LCDBF2))
				LCNEEDRELATION = .F.
			Endif
			LCTEMPCONTROL = LCTEMPCONTROL + 1
		Enddo
		If LCONOFF
			If LCNEEDRELATION
				Select (LCDBF1)
				If LCADDITIVE
					Set Relation To &LCEXPRESSION. Into (LCDBF2) Additive
				Else
					Set Relation To &LCEXPRESSION. Into (LCDBF2)
				Endif
			Else
				LCRETURNVALUE = .F.
			Endif
		Else
			Select (LCDBF1)
			Set Relation Off Into (LCDBF2)
		Endif
		If LCTEMPSELECT <> 0
			Select (LCTEMPSELECT)
		Endif
		Return LCRETURNVALUE
	Endproc
	*------
	Procedure CreateExcel
		Lparameter OAPPNAME
		If Pcount() < 1
			Wait Window Nowait  ;
				'Please send the variable that use to remember excel application !'
			Return ''
		Endif
		If Vartype(&OAPPNAME.)<>'U' Then
			Return ''
		Endif
		OAPPNAME = Createobject('Excel.Application')
		Return OAPPNAME
	Endproc
	*------
	Procedure LcPack
		Lparameter LCALIASADD
		If Vartype(LCALIASADD) <> 'C' .Or. Empty(LCALIASADD)
			LCALIASADD = ''
		Else
			LCALIASADD = Alltrim(LCALIASADD)
		Endif
		Local LCTEMPSELECT
		LCTEMPSELECT = Select()
		If Empty(LCALIASADD)
			LCALIASADD = Alias()
		Endif
		If Select(LCALIASADD) = 0
			Wait Window Nowait 'Please sure the alias ' + LCALIASADD + ' had been opened !'
			Return .F.
		Endif
		Select (LCALIASADD)
		Use Exclusive Dbf()
		Pack
		Use Dbf()
		Browse Last Nowait
		If LCTEMPSELECT > 0
			Select (LCTEMPSELECT)
		Endif
		Return .T.
	Endproc
	*------
	Procedure LcZap
		Lparameter LCZAP_ALIAS
		If Vartype(LCZAP_ALIAS) <> 'C' .Or. Empty(LCZAP_ALIAS)
			If Empty(Alias())
				Wait Window Nowait 'Can not find any table !'
				Return .F.
			Else
				LCZAP_ALIAS = Alias()
			Endif
		Else
			If  .Not. LcDbfOpen(LCZAP_ALIAS,LCZAP_ALIAS)
				LcDbfClose(LCZAP_ALIAS)
				Wait Window Nowait 'The table ' + LCZAP_ALIAS + ' can not find '
				Return .F.
			Endif
		Endif
		LcDbfOpen(LCZAP_ALIAS,LCZAP_ALIAS)
		TEMPVALUE = Dbf(LCZAP_ALIAS)
		If  .Not. Empty(TEMPVALUE)
			TEMPVALUE = Substr(TEMPVALUE,Rat('\',TEMPVALUE) + 1)
			TEMPVALUE = Left(TEMPVALUE,Len(TEMPVALUE) - 4)
		Endif
		LcDbfClose(LCZAP_ALIAS)
		If  .Not. LcDbfOpen(TEMPVALUE,LCZAP_ALIAS,.T.)
			Wait Window Nowait 'Because the table ' + LCZAP_ALIAS + ' can not open exclusive '
			Return .F.
		Endif
		Local LCZAP_SAFETY
		LCZAP_SAFETY = Set('Safety')
		Set Safety Off
		Select (LCZAP_ALIAS)
		Zap
		Set Safety &LCZAP_SAFETY.
		LcDbfClose(LCZAP_ALIAS)
		LcDbfOpen(LCZAP_ALIAS,LCZAP_ALIAS)
		Select (LCZAP_ALIAS)
	Endproc
	*------
	Procedure LcDesktop
		Lparameter LCSTATION , LCFIELDNAME
		If Pcount() < 2
			Wait Window Nowait 'Please type the station and field value !'
			Return ''
		Endif
		If Vartype(LCSTATION) = 'C'
			LCSTATION = Alltrim(Upper(LCSTATION))
		Else
			LCSTATION = ''
		Endif
		If Empty(LCSTATION)
			Wait Window Nowait 'Please sure type the company station use the first parameter !'
			Return ''
		Endif
		If Vartype(LCFIELDNAME) = 'C'
			LCFIELDNAME = Alltrim(LCFIELDNAME)
		Else
			LCFIELDNAME = 'Station'
		Endif
		If Empty(LCFIELDNAME)
			LCFIELDNAME = 'Station'
		Endif
		If  .Not. File('Desktop.Dbf')
			Wait Window Nowait 'Please sure the desktop table is exist !'
			Return ''
		Endif
		Local LCDESKTOP_SELECT , LCDESKTOP_DBF , LCDESKTOP_SETDELETED , LCDESKTOP_RETURN
		LCDESKTOP_NODELETED = 0
		LCDESKTOP_SETDELETED = Set('Deleted')
		Set Deleted Off
		LCDESKTOP_SELECT = Select()
		LCDESKTOP_DBF = AliasName()
		LcDbfOpen('Desktop',LCDESKTOP_DBF,.F.,'Station')
		LCDESKTOP_RETURN = LCDESKTOP_DBF + '.' + LCFIELDNAME
		Select (LCDESKTOP_DBF)
		If  .Not. Seek(LCSTATION,LCDESKTOP_DBF)
			Wait Window Nowait  ;
				'The station of ' + LCSTATION + ' can not find in the desktop table !'
			LCRETURNCHARACTERS(LCDESKTOP_SELECT,LCDESKTOP_DBF,'','',LCDESKTOP_SETDELETED)
			Return ''
		Endif
		Set Deleted &LCDESKTOP_SETDELETED.
		If  .Not. LC_FIELDIN(LCFIELDNAME,LCDESKTOP_DBF)
			Wait Window Nowait 'Please sure the field ' + LCFIELDNAME + ' in the desktop.dbf !'
			LCRETURNCHARACTERS(LCDESKTOP_SELECT,LCDESKTOP_DBF,'','',LCDESKTOP_SETDELETED)
			Return ''
		Endif
		If  .Not. Directory(Addbs(Alltrim(CONTROL_PA)))
			Wait Window Nowait  ;
				'Please sure the control_pa of ' + Addbs(Alltrim(CONTROL_PA)) + ' exist !'
			LCRETURNCHARACTERS(LCDESKTOP_SELECT,LCDESKTOP_DBF,'','',LCDESKTOP_SETDELETED)
			Return ''
		Endif
		If  .Not. Directory(Addbs(Alltrim(CONTROL_PU)))
			Wait Window Nowait  ;
				'Please sure the control_pu of ' + Addbs(Alltrim(CONTROL_PU)) + ' exist !'
			LCRETURNCHARACTERS(LCDESKTOP_SELECT,LCDESKTOP_DBF,'','',LCDESKTOP_SETDELETED)
			Return ''
		Endif
		LCDESKTOP_RETURN=&LCDESKTOP_RETURN.
		LCRETURNCHARACTERS(LCDESKTOP_SELECT,LCDESKTOP_DBF,'','',LCDESKTOP_SETDELETED)
		Return LCDESKTOP_RETURN
	Endproc
	*------
	Procedure LCRETURNCHARACTERS
		Lparameter LCRETURNSELECT , LCRETURNDBF1 , LCRETURNDBF2 , LCRETURNDBF3 , LCRETURNSETDELETED
		If  .Not. Empty(LCRETURNSELECT)
			If Vartype(LCRETURNSELECT) = 'C' .Or. Vartype(LCRETURNSELECT) = 'N'
				Select (LCRETURNSELECT)
			Endif
		Endif
		If Vartype(LCRETURNDBF1) = 'C'
			LcDbfClose(LCRETURNDBF1)
		Endif
		If Vartype(LCRETURNDBF2) = 'C'
			LcDbfClose(LCRETURNDBF2)
		Endif
		If Vartype(LCRETURNDBF3) = 'C'
			LcDbfClose(LCRETURNDBF3)
		Endif
		If Vartype(LCRETURNSETDELETED) = 'C'
			LCRETURNSETDELETED = Alltrim(Upper(LCRETURNSETDELETED))
			If LCRETURNSETDELETED = 'ON' .Or. LCRETURNSETDELETED = 'OFF'
				Set Deleted &LCRETURNSETDELETED.
			Endif
		Endif
		Return .T.
	Endproc
	*------
	Procedure LcConvert
		Lparameter LCTYPE , LCVALUE
		If Vartype(LCTYPE) <> 'C'
			LCTYPE = ''
		Else
			LCTYPE = Alltrim(Upper(LCTYPE))
		Endif
		If Empty(LCTYPE)
			Wait Window Nowait 'Please send the variable type first ! '
			Return .Null.
		Endif
		If  .Not. (LCTYPE == 'C' .Or. LCTYPE == 'N' .Or. LCTYPE == 'T' .Or. LCTYPE == 'D' .Or.  ;
				LCTYPE == 'M' .Or. LCTYPE == 'L' .Or. LCTYPE == 'X')
			Return .Null.
		Endif
		Local LCCONVERTRETURN , LCVALUETYPE
		LCVALUETYPE = Vartype(LCVALUE)
		If  .Not. (LCVALUETYPE == 'C' .Or. LCVALUETYPE == 'N' .Or. LCVALUETYPE == 'T' .Or.  ;
				LCVALUETYPE == 'D' .Or. LCVALUETYPE == 'M' .Or. LCVALUETYPE == 'L' .Or. LCTYPE == 'X')
			Return .Null.
		Endif
		LCCONVERTRETURN =''
		Do Case
			Case LCTYPE = 'C'
				Do Case
					Case LCVALUETYPE = 'C'
						LCCONVERTRETURN = Alltrim(LCVALUE)
					Case LCVALUETYPE = 'N'
						LCCONVERTRETURN = Alltrim(Str(LCVALUE))
					Case LCVALUETYPE = 'M'
						LCCONVERTRETURN = Alltrim(LCVALUE)
					Case LCVALUETYPE = 'T'
						LCCONVERTRETURN = Alltrim(Ttoc(LCVALUE))
					Case LCVALUETYPE = 'D'
						LCCONVERTRETURN = Alltrim(Dtoc(LCVALUE))
				Endcase
			Case LCTYPE = 'N'
				Do Case
					Case LCVALUETYPE = 'C'
						LCCONVERTRETURN = Val(LCVALUE)
					Case LCVALUETYPE = 'N'
						LCCONVERTRETURN = LCVALUE
				Endcase
			Case LCTYPE = 'M'
				Do Case
					Case LCVALUETYPE = 'C'
						LCCONVERTRETURN = Alltrim(LCVALUE)
					Case LCVALUETYPE = 'N'
						LCCONVERTRETURN = Alltrim(Str(LCVALUE))
					Case LCVALUETYPE = 'M'
						LCCONVERTRETURN = Alltrim(LCVALUE)
					Case LCVALUETYPE = 'T'
						LCCONVERTRETURN = Alltrim(Ttoc(LCVALUE))
					Case LCVALUETYPE = 'D'
						LCCONVERTRETURN = Alltrim(Dtoc(LCVALUE))
				Endcase
			Case LCTYPE = 'T'
				Do Case
					Case LCVALUETYPE = 'C'
						LCCONVERTRETURN = Ctot(LCVALUE)
					Case LCVALUETYPE = 'M'
						LCCONVERTRETURN = Ctot(Alltrim(LCVALUE))
					Case LCVALUETYPE = 'T'
						LCCONVERTRETURN = LCVALUE
					Case LCVALUETYPE = 'D'
						LCCONVERTRETURN = Dtot(LCVALUE)
				Endcase
			Case LCTYPE = 'D'
				Do Case
					Case LCVALUETYPE = 'C'
						LCCONVERTRETURN = Ctod(LCVALUE)
					Case LCVALUETYPE = 'D'
						LCCONVERTRETURN = LCVALUE
					Case LCVALUETYPE = 'T'
						LCCONVERTRETURN = Ttod(LCVALUE)
				Endcase
			Case LCTYPE = 'L'
				Do Case
					Case LCVALUETYPE = 'L'
						LCCONVERTRETURN = LCVALUE
				Endcase
		Endcase
		Return LCCONVERTRETURN
	Endproc
	*------
	Procedure LcRecordReplace
		Lparameter LCDBF1 , LCDBF1_FIELD , LCNEWVALUE
		If Pcount() < 3
			Return .F.
		Endif
		If Select(LCDBF1) = 0
			Wait Window Nowait 'Please sure the ' + DBF1 + ' hase been opened'
			Return .F.
		Endif
		If  .Not. LC_FIELDIN(LCDBF1_FIELD,LCDBF1)
			Wait Window Nowait  ;
				'Please sure the field of ' + LCDBF1_FIELD + ' in the table ' + LCDBF1
			Return .F.
		Endif
		Local LCRECORDREPLACE_SELECT , LCVALUEONE , LCVALUETWO
		LCRECORDREPLACE_SELECT = Select()
		LCVALUEONE = LCDBF1 + '.' + LCDBF1_FIELD
		LCVALUETWO=LcConvert(Vartype(&LCVALUEONE.),LCNEWVALUE)
		If Isnull(LCVALUETWO)
			Return .F.
		Endif
		Select (LCDBF1)
		Replace &LCVALUEONE. With LCVALUETWO
		If LCRECORDREPLACE_SELECT >= 0
			Select (LCRECORDREPLACE_SELECT)
		Endif
		Return .T.
	Endproc
	*------
	Procedure LcSubstr
		Parameter SUBSTR_VALUE , SUBSTR_PLUS , SUBSTR_INDEX , SUBSTR_TRIM
		If Vartype(SUBSTR_VALUE) <> 'C' .Or. Empty(SUBSTR_VALUE)
			Return ''
		Endif
		If Vartype(SUBSTR_TRIM) <> 'L'
			SUBSTR_TRIM = .F.
		Endif
		If Vartype(SUBSTR_PLUS) <> 'C' .Or. Empty(SUBSTR_PLUS)
			SUBSTR_PLUS = ','
		Endif
		If Vartype(SUBSTR_INDEX) <> 'N'
			SUBSTR_INDEX = 0
		Else
			If SUBSTR_INDEX < 0
				SUBSTR_INDEX = 0
			Endif
		Endif
		If  .Not. (SUBSTR_PLUS $ SUBSTR_VALUE) .Or. SUBSTR_INDEX = 0
			Wait Window Nowait 'Because the plus not in the value or character index is 0 !'
			If SUBSTR_TRIM
				Return Alltrim(SUBSTR_VALUE)
			Else
				Return SUBSTR_VALUE
			Endif
		Endif
		SUBSTR_VALUE = Strtran(SUBSTR_VALUE,SUBSTR_PLUS,Chr(13) + Chr(10))
		If Alines(SUBSTR_ARRAY,SUBSTR_VALUE) < 2
			If SUBSTR_TRIM
				Return Alltrim(SUBSTR_VALUE)
			Else
				Return SUBSTR_VALUE
			Endif
		Else
			If Alen(SUBSTR_ARRAY) >= SUBSTR_INDEX
				If SUBSTR_TRIM
					Return Alltrim(SUBSTR_ARRAY(SUBSTR_INDEX))
				Else
					Return SUBSTR_ARRAY(SUBSTR_INDEX)
				Endif
			Else
				Wait Window Nowait  ;
					'Because the character index large than character counts, Programe will be get the last index of character value !'
				If SUBSTR_TRIM
					Return Alltrim(SUBSTR_ARRAY(Alen(SUBSTR_ARRAY)))
				Else
					Return SUBSTR_ARRAY(Alen(SUBSTR_ARRAY))
				Endif
			Endif
		Endif
	Endproc
	*------
	Procedure Structure_Export
		Lparameter DBF_ALIAS , TXT_FILENAME , DBF_FIELD , DBF_TYPE , DBF_SIZE , TXT_AUTOCLOSE
		If  .Not. (DBF_FIELD .Or. DBF_TYPE .Or. DBF_SIZE)
			DBF_FIELD = .T.
		Endif
		Local DBF_EXPORT_SELECT , EXPORT_VALUE , TEMP_FIELD , TEMP_TYPE , TEMP_SIZE ,  ;
			DBF_EXPORT_CONTROL , SET_SAFETY
		SET_SAFETY = Set('Safety')
		DBF_EXPORT_SELECT = Select()
		If Empty(DBF_ALIAS)
			If  .Not. Empty(Alias())
				DBF_ALIAS = Alias()
			Else
				Wait Window Nowait 'No table opened in current select '
				Return .F.
			Endif
		Else
			If Select(DBF_ALIAS) = 0
				If  .Not. Iif('.DBF' $ Upper(DBF_ALIAS),File(DBF_ALIAS),File(DBF_ALIAS + '.Dbf'))
					Wait Window Nowait 'Can not find the talbe ' + DBF_ALIAS
					Return .F.
				Else
					LcDbfOpen(DBF_ALIAS,DBF_ALIAS)
				Endif
			Endif
		Endif
		Set Safety Off
		If Vartype(TXT_FILENAME) <> 'C' .Or. Empty(TXT_FILENAME)
			TXT_FILENAME =  ;
				IIF('.DBF' $ Upper(DBF_ALIAS),Left(DBF_ALIAS,Len(DBF_ALIAS) - 4),DBF_ALIAS) +  ;
				'_Structure'
		Endif
		TXT_FILENAME =  ;
			IIF('.TXT' $ Upper(TXT_FILENAME),TXT_FILENAME,TXT_FILENAME + '.Txt')
		Select (DBF_ALIAS)
		EXPORT_VALUE = 'Table: ' + Dbf(DBF_ALIAS) + Chr(13)
		EXPORT_VALUE = EXPORT_VALUE + 'Datetime: ' + Alltrim(Ttoc(Datetime())) + Chr(13)
		EXPORT_VALUE =  ;
			EXPORT_VALUE + 'Records: ' + Alltrim(Str(Reccount(DBF_ALIAS))) + Chr(13)
		EXPORT_VALUE =  ;
			EXPORT_VALUE + 'Fields Count: ' + Alltrim(Str(Fcount())) + Chr(13) + Chr(10) +  ;
			CHR(13)
		For DBF_EXPORT_CONTROL = 1 To Fcount(DBF_ALIAS)
			EXPORT_VALUE = EXPORT_VALUE + Space(4)
			TEMP_FIELD = Field(DBF_EXPORT_CONTROL,DBF_ALIAS)
			TEMPVALUE = DBF_ALIAS + '.' + TEMP_FIELD
			TEMP_TYPE=Vartype(&TEMPVALUE.)
			TEMP_SIZE = Alltrim(Str(Fsize(TEMP_FIELD)))
			If DBF_FIELD
				EXPORT_VALUE = EXPORT_VALUE + Padr(TEMP_FIELD,20,' ')
			Endif
			If DBF_TYPE
				EXPORT_VALUE = EXPORT_VALUE + Padr(TEMP_TYPE,3,' ')
			Endif
			If DBF_SIZE
				EXPORT_VALUE = EXPORT_VALUE + Padr(TEMP_SIZE,4,' ')
			Endif
			EXPORT_VALUE = EXPORT_VALUE + Chr(13)
		Endfor
		Strtofile(EXPORT_VALUE,TXT_FILENAME)
		If  .Not. TXT_AUTOCLOSE
			Run/N Write &TXT_FILENAME.
		Endif
		Set Safety &SET_SAFETY.
		If DBF_EXPORT_SELECT >= 0
			Select (DBF_EXPORT_SELECT)
		Endif
		Return .T.
	Endproc
	*------
EndDefine 