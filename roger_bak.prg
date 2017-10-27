* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
*  文件名: ROGER.PRG(主文件)
* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

* --------------Description----------------------------------------
* Question		Some questions in procedures.
* UnFinished	The procedure not finished.
* Test			The procedure has been finished but not tested.
* Pause			Some line code need to debug
* --------------EndDescription-------------------------------------

*!*	Define Class Function as Custom olepublic
Procedure ItBrowse
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
			Wait Window Nowait 'The ' +"'"+TEMP_ALIAS+"'"+ ' table can not find .'
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
		TEMPVALUE = ALLFIELDS()
		Browse Fields &TEMPVALUE. Last Nowait
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
			Wait Window Nowait 'The talbe ' + "'"+TEMP_ALIAS+"'" + ' can not find !'
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
		Browse Fields &TempValue. Last Nowait
		Wait Window Nowait 'There are no any fields empty !'
	Endif
	Return
Endproc
*------
Procedure BlankFields && UnFinished
	Lparameters cFieldType,cFieldLength,cAlias
	
EndProc
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
				Wait Window Nowait 'The table of ' +"'"+ LC_DBF +"'"+ ' not exist !'
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
		If  .Not. IsFieldExist(LC_FIELDIN,LC_DBF)
			Wait Window Nowait  ;
				'The field of ' + "'"+LC_FIELDIN+"'" + ' is not in the ' + LC_DBF + ' table !'
			Return 0
		Endif
		Select (LC_DBF)
		Scan
			If  .Not. Empty(LC_CONDITION)
				If Not (&LC_CONDITION.) Then
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
				If Not (&LC_CONDITION.) Then
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
Procedure IsFieldExist
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
	If Not IsValidStr(Lc_Table) Then
		AutoClose = .F.
	EndIf
	Lc_Table=GetAlias(Lc_Table)
	If Empty(Lc_Table) Then
		WaitWindow('Could not found any table to dispose now.',Sys(16))
		Select (Lc_Current_Dbf)
		Return .F.
	EndIf
	Local nTag
	For nTag = 1 To Fcount(LC_TABLE)
		If Alltrim(Upper(LCFIELDNAME)) == Field(nTag,LC_TABLE)
			LCTEMP_VALUE = LC_TABLE + '.' + Field(nTag,LC_TABLE)
			If Vartype(&LCTEMP_VALUE.)<>'U' Then
				If AutoClose
					LcDbfClose(Lc_Table)
				Endif
				Select (LC_CURRENT_DBF)
				Return .T.
				Exit
			Endif
		Endif
	Endfor
	If AutoClose
		LcDbfClose(Lc_Table)
	Endif
	Select (LC_CURRENT_DBF)
	Return .F.
Endproc
*------
Procedure FileName && Return a new file name which did not existed.
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
	Local cOnError,lErrored
	cOnError=On('Error')
	On Error lErrored=.T.
	Declare Integer GBToBig5 In 'mchset.dll' String @
	Declare Integer Big5ToGB In 'mchset.dll' String @
	On Error &cOnError.
	If lErrored Then
		Wait Window 'Can not found mchset.dll .' nowait
		Return LcValue
	EndIf
	If LCTYPE = 1
		GBToBig5(@LcValue)
	Else
		Big5ToGB(@LcValue)
	Endif
	Return LcValue
Endproc
*----简－繁－假繁　之间的转换
* ? cConvert(HzStr,HzType)其他HzType有６个类型
* HzType为 1简－》假繁 ；２简－》真繁 ；３真繁－》简 ；4真繁－》假繁 ；５假繁->真繁 ；6假繁->简体
* 例如：wait window  HztoFt("弃1(A]* 钱",1)    结果：棄1(A]*　錢
Procedure cConvert
	Lparameters HzStr,HzType,lToDouble
	If Pcount()<>2
		Wait window nowait "有两个参数前一个为传递的字符"+Chr(13)+"后一个为变换的类型"
		Return HzStr
	Endif
	If Vartype(HzType)<>Upper('N') Or Not Inlist(HzType,1,2,3,4,5,6) Then
		Return HzStr
	EndIf
	If Vartype(lToDouble)<>Upper('L') Then
		lToDouble=.F.
	Endif
	If Not lToDouble Then
		HzStr=Strconv(HzStr,2) && DBCS in cExpression to single_byte
	EndIf

	Local nSelect,cReturnValue,EndChar,TempStr
	cReturnValue=''
	EndChar=""
	TempStr=''
	nSelect=Select()
	If Used('Hanzi') Then
		Use In Hanzi
	Endif
	If Not LcDbfOpen('Hanzi','Hanzi') Then
		Select (nSelect)
		Wait Window 'Can not open '+"'"+'hanzi'+"'"+' table .' nowait
		Return HzStr
	EndIf
	If Not Used('Hanzi') Then
		Use in 0 HanZi
	EndIf
	Select HANZI
	Do Case
		Case HzType=1&&简－>假繁
			Set Order To GB2312   && JTZI
			For HzLenStr=1 To Lenc(HzStr)
				TempStr=Substrc(HzStr,HzLenStr,1)
				IF InList(TempStr,Chr(9),Chr(10),Chr(13),Chr(32)) or TempStr$" ,.，。;；<>()*$@!0123456789=/\#&-[]{}?+abcdefghigklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
					EndChar=EndChar+TempStr
				else
					If Seek(TempStr)
						EndChar=EndChar+Alltrim(jft)
					ELSE
						EndChar=EndChar+TempStr
					ENDIF
				endif
			ENDFOR
			cReturnValue=EndChar
		Case HzType=2&&简－>真繁
			Set Order To GB2312   && JTZI
			For HzLenStr=1 To Lenc(HzStr)
				TempStr=Substrc(HzStr,HzLenStr,1)
				IF InList(TempStr,Chr(9),Chr(10),Chr(13),Chr(32)) or TempStr$" ,.，。;；<>()*$@!0123456789=/\#&-[]{}?+abcdefghigklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
					EndChar=EndChar+TempStr
				else
					If Seek(TempStr)
						EndChar=EndChar+Alltrim(zft)
					ELSE
						EndChar=EndChar+TempStr
					ENDIF
				endif
			ENDFOR
			cReturnValue=EndChar
		Case HzType=3&&真繁->简
			Set Order To BIG5   && ZFT
			For HzLenStr=1 To Lenc(HzStr)
				TempStr=Substrc(HzStr,HzLenStr,1)
				IF InList(TempStr,Chr(9),Chr(10),Chr(13),Chr(32)) or TempStr$" ,.，。;；<>()*$@!0123456789[]{}?+=/\#&-abcdefghigklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
					EndChar=EndChar+TempStr
				else
					If Seek(TempStr)
						EndChar=EndChar+Alltrim(jtzi)
					ELSE
						EndChar=EndChar+TempStr
					ENDIF
				endif
			ENDFOR
			cReturnValue=EndChar
		Case HzType=4&&真繁->假繁
			Set Order To BIG5   && ZFT
			For HzLenStr=1 To Lenc(HzStr)
				IF InList(TempStr,Chr(9),Chr(10),Chr(13),Chr(32)) or TempStr$" ,.，。;；<>()*$@!0123456789=/\#&-a[]{}?+bcdefghigklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
					EndChar=EndChar+TempStr
					EndChar=EndChar+" "
				else
					If Seek(TempStr)
						EndChar=EndChar+Alltrim(jft)
					ELSE
						EndChar=EndChar+TempStr
					ENDIF
				endif
			ENDFOR
			cReturnValue=EndChar
		Case HzType=5&&假繁->真繁
			Set Order To GBK   && JFT
			For HzLenStr=1 To Lenc(HzStr)
				TempStr=Substrc(HzStr,HzLenStr,1)
				IF InList(TempStr,Chr(9),Chr(10),Chr(13),Chr(32)) or TempStr$" ,.，。;；<>()*$@!0123456789=/\#&-a[]{}?+bcdefghigklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
					EndChar=EndChar+TempStr
				else
					If Seek(TempStr)
						EndChar=EndChar+Alltrim(zft)
					ELSE
						EndChar=EndChar+TempStr
					ENDIF
				endif
			ENDFOR
			cReturnValue=EndChar
		Case HzType=6&&假繁->简体
			Set Order To GBK   && JFT
			For HzLenStr=1 To Lenc(HzStr)
				TempStr=Substrc(HzStr,HzLenStr,1)
				IF InList(TempStr,Chr(9),Chr(10),Chr(13),Chr(32)) or TempStr$" ,.，。;；<>()*$@!0123456789=/\#&-[]{}?+abcdefghigklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
					EndChar=EndChar+TempStr
				else
					If Seek(TempStr)
						EndChar=EndChar+Alltrim(jtzi)
					ELSE
						EndChar=EndChar+TempStr
					ENDIF
				endif
			ENDFOR
			cReturnValue=EndChar
	EndCase
	Select (nSelect)
	If Used('Hanzi') Then
		Use in Hanzi
	EndIf
	Return cReturnValue
EndProc
*------
Procedure DbfAlias
	Lparameter LcFileName
	&& It will just return file name not include extension name,Just the same as JustStem()
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
Procedure RecordConvert
	Lparameter LCTABLE , LCTYPE
	If Empty(LCTABLE)
		Wait Window Nowait 'Please sure the table name not empty !'
		Return .F.
	Else
		If Select(LCTABLE) = 0
			Wait Window Nowait 'Please sure the table alias of ' +"'"+ LCTABLE +"'"+ ' is opened !'
			Return .F.
		Endif
	Endif
	If Vartype(LCTYPE) <> 'N'
		Wait Window Nowait 'Please sure the convert type in number !'
		Return .F.
	Else
		If  .Not. (LCTYPE = 1 .Or. LCTYPE = 2)
			Wait Window Nowait 'Please sure the convert type value in 1 or 2 !'
			Return .F.
		Endif
	Endif
	Local LCCURRENTSELECT , LCCONTROLTEMP3 , LCFIELDNAME
	LCCURRENTSELECT = Select()
	Select (LCTABLE)
	For LCCONTROLTEMP3 = 1 To Fcount(LCTABLE)
		LCFIELDNAME = LCTABLE + '.' + Field(LCCONTROLTEMP3,LCTABLE)
		If Vartype(&LCFIELDNAME)='C' Or Vartype(&LCFIELDNAME)='M' Then
			Replace &LCFIELDNAME. With GbConvert(&LCFIELDNAME.,LCTYPE)
		Else
			Loop
		Endif
	Endfor
	If CursorGetProp('Buffering',LCTABLE) = 3 .Or. CursorGetProp('Buffering',LCTABLE) = 5
		Select (LCTABLE)
		Tableupdate(.T.)
	Endif
	If LCCURRENTSELECT > 0
		Select (LCCURRENTSELECT)
	Endif
	Return .T.
Endproc
*------
Procedure RecordReplace
	Lparameter LCTABLEONE , LCTABLETWO , EXCEPTFIELDS , LCPLUS
	If Vartype(LCTABLEONE) <> 'C' .Or. Empty(LCTABLEONE) .Or. Vartype(LCTABLETWO) <> 'C' .Or.  ;
			EMPTY(LCTABLETWO)
		Wait Window Nowait 'Please sure the two tables name not empty !'
		Return .F.
	Endif
	If Select(LCTABLEONE) = 0 .Or. Select(LCTABLETWO) = 0
		Wait Window Nowait 'Please sure the two tables name are opened !'
		Return .F.
	Endif
	If Upper(Alltrim(LCTABLEONE)) == Upper(Alltrim(LCTABLETWO))
		Wait Window Nowait 'Please sure the two tables are not different !'
		Return .F.
	Endif
	Local LCGATHER , LCTEMPSELECT , LCFIELDSTOTAL , RECORDREPLACETABLEONEVALUE ,  ;
		RECORDREPLACETABLETWOVALUE , LCOUTFOR
	LCGATHER = .T.
	LCTEMPSELECT = Select()
	If Vartype(EXCEPTFIELDS) <> 'C' .Or. Empty(EXCEPTFIELDS)
		EXCEPTFIELDS = ''
	Else
		EXCEPTFIELDS = Alltrim(EXCEPTFIELDS)
	Endif
	If  .Not. Empty(EXCEPTFIELDS)
		LCGATHER = .F.
	Endif
	If Vartype(LCPLUS) <> 'C' .Or. Empty(LCPLUS)
		LCPLUS = ','
	Endif
	If LCGATHER
		Select (LCTABLETWO)
		Scatter Memo Memvar
		Select (LCTABLEONE)
		Gather Memo Memvar
	Else
		EXCEPTFIELDS = Alltrim(Upper(EXCEPTFIELDS))
		EXCEPTFIELDS = Strtran(EXCEPTFIELDS,LCPLUS,Chr(13) + Chr(10))
		LCFIELDSTOTAL = Alines(LCTEMPARRAY,EXCEPTFIELDS)
		LCOUTFOR = .T.
		Local LCCONTROLTEMP4
		For LCCONTROLTEMP4 = 1 To Fcount(LCTABLEONE)
			If  .Not. IsFieldExist(Field(LCCONTROLTEMP4,LCTABLEONE),LCTABLETWO)
				Loop
			Endif
			If Alen(LCTEMPARRAY) = 1
				If Field(LCCONTROLTEMP4,LCTABLEONE) = EXCEPTFIELDS And  ;
						IsFieldExist(EXCEPTFIELDS,LCTABLEONE)
					Loop
				Endif
			Else
				For LCARRAYCONTROL = 1 To Alen(LCTEMPARRAY)
					If Field(LCCONTROLTEMP4,LCTABLEONE) = LCTEMPARRAY(LCARRAYCONTROL) And  ;
							IsFieldExist(LCTEMPARRAY(LCARRAYCONTROL),LCTABLEONE)
						LCOUTFOR = .F.
						Exit
					Endif
				Endfor
				If  .Not. LCOUTFOR
					LCOUTFOR = .T.
					Loop
				Endif
			Endif
			RECORDREPLACETABLEONEVALUE = LCTABLEONE + '.' + Field(LCCONTROLTEMP4,LCTABLEONE)
			RECORDREPLACETABLETWOVALUE = LCTABLETWO + '.' + Field(LCCONTROLTEMP4,LCTABLEONE)
			Replace &RECORDREPLACETABLEONEVALUE. With &RECORDREPLACETABLETWOVALUE.
		Endfor
	Endif
	If CursorGetProp('Buffering',LCTABLEONE) = 3 .Or.  ;
			CURSORGETPROP('Buffering',LCTABLEONE) = 5
		Select (LCTABLEONE)
		Tableupdate(.T.)
	Endif
	If LCTEMPSELECT > 0
		Select (LCTEMPSELECT)
	Endif
	Return .T.
Endproc
*------
Procedure TwoUpdate
	Lparameter TABLEONEVALUE , TABLETWOVALUE , INDEXONE , INDEXTWO , SEEKEXPRESSION1 ,  ;
		SEEKEXPRESSION2 , TABLEGOOD , RECORDCONVERTTYPE , RECORDNEWVALUE ,  ;
		UPDATEEXCEPTFIELDS , FORCEUPDATE
	If Parameters() < 2
		Wait Window Nowait  ;
			'Please send two Tables in parameters with the first table and second table !'
		Return .F.
	Endif
	If Empty(TABLEONEVALUE) .Or. Empty(TABLETWOVALUE)
		Wait Window Nowait 'Please send the two tables name !'
		Return .F.
	Endif
	If Vartype(TABLEONEVALUE) <> 'C' .Or. Vartype(TABLETWOVALUE) <> 'C'
		Wait Window Nowait 'Please send the two tables name in charecter !'
		Return .F.
	Endif
	If  .Not. (Upper('.Dbf') $ Upper(TABLEONEVALUE))
		TABLEONEVALUE = Alltrim(TABLEONEVALUE) + '.Dbf'
	Endif
	If  .Not. (Upper('.Dbf') $ Upper(TABLETWOVALUE))
		TABLETWOVALUE = Alltrim(TABLETWOVALUE) + '.Dbf'
	Endif
	If Upper(TABLEONEVALUE) == Upper(TABLETWOVALUE)
		Wait Window Nowait 'Please type the two table names in difference !'
		Return .F.
	Endif
	If  .Not. File(TABLEONEVALUE)
		Wait Window Nowait 'Please sure the Table of ' +"'"+ TABLEONEVALUE+"'" + ' is exist !'
		Return .F.
	Endif
	If  .Not. File(TABLETWOVALUE)
		Wait Window Nowait 'Please sure the Table of ' +"'"+TABLETWOVALUE+"'" + ' is exist !'
		Return .F.
	Endif
	If Empty(INDEXONE) .Or. Empty(INDEXTWO)
		Wait Window Nowait  ;
			'Please sure the table one index and table two index are not empty !'
		Return .F.
	Endif
	If Vartype(INDEXONE) <> 'C' .Or. Vartype(INDEXTWO) <> 'C'
		Wait Window Nowait 'Please sure the two tables SeekExpression1 Index In correct !'
		Return .F.
	Endif
	If Empty(SEEKEXPRESSION1) .Or. Empty(SEEKEXPRESSION2) .Or.  ;
			VARTYPE(SEEKEXPRESSION1) <> 'C' .Or. Vartype(SEEKEXPRESSION2) <> 'C'
		Wait Window Nowait 'Please sure the the fields in correct !'
		Return .F.
	Endif
	If Empty(TABLEGOOD) .Or. Vartype(TABLEGOOD) <> 'N'
		TABLEGOOD = 0
	Else
		If  .Not. (TABLEGOOD = 1 .Or. TABLEGOOD = 2)
			TABLEGOOD = 0
		Endif
	Endif
	If Vartype(RECORDCONVERTTYPE) <> 'N'
		RECORDCONVERTTYPE = 0
	Else
		If  .Not. (RECORDCONVERTTYPE = 1 .Or. RECORDCONVERTTYPE = 2)
			RECORDCONVERTTYPE = 0
		Endif
	Endif
	If Vartype(UPDATEEXCEPTFIELDS) <> 'C' .Or. Empty(UPDATEEXCEPTFIELDS)
		UPDATEEXCEPTFIELDS = ''
	Endif
	If Vartype(FORCEUPDATE) <> 'L'
		FORCEUPDATE = .F.
	Else
		If TABLEGOOD = 0
			FORCEUPDATE = .F.
		Endif
	Endif
	Local TABLE1 , TABLE2 , TABLE1UPDATE , TABLE2UPDATE , SEEKVALUE , ADATETIME1 ,  ;
		ADDATETIME2 , LCAMENDDATETIME1 , LCAMENDDATETIME2 , LCCURRENTSELECT ,  ;
		LASTRETURN , LCSETDELETED , RECNOTABLE1 , RECNOTABLE2 , RECORDTABLE1 ,  ;
		RECORDTABLE2 , TEMPUPDATESUCCESSED
	LCSETDELETED = Set('Deleted')
	LASTRETURN = 0
	LCCURRENTSELECT = Select()
	TABLE1 = AliasName()
	TABLE2 = AliasName()
	TABLE1UPDATE = AliasName()
	TABLE2UPDATE = AliasName()
	LCAMENDDATETIME1 = Fdate(TABLEONEVALUE,1)
	LCAMENDDATETIME2 = Fdate(TABLETWOVALUE,1)
	Use In 0 Shared (TABLEONEVALUE) Again Alias (TABLE1)
	Select (TABLE1)
	Set Order To INDEXONE
	CursorSetProp('Buffering',5)
	If Reccount() > 0 And Recno() <= Reccount()
		RECNOTABLE1 = Recno()
	Else
		RECNOTABLE1 = 0
	Endif
	RECORDTABLE1=&SEEKEXPRESSION1.
	Use In 0 Shared (TABLEONEVALUE) Again Alias (TABLE1UPDATE)
	Select (TABLE1UPDATE)
	Set Order To INDEXONE
	Use In 0 Shared (TABLETWOVALUE) Again Alias (TABLE2)
	Select (TABLE2)
	Set Order To INDEXTWO
	CursorSetProp('Buffering',5)
	If Reccount() > 0 And Recno() <= Reccount()
		RECNOTABLE2 = Recno()
	Else
		RECNOTABLE2 = 0
	Endif
	RECORDTABLE2=&SEEKEXPRESSION2.
	Use In 0 Shared (TABLETWOVALUE) Again Alias (TABLE2UPDATE)
	Select (TABLE2UPDATE)
	Set Order To INDEXTWO
	If TABLEGOOD = 0
		Select (TABLE1)
		Set Deleted On
		Scan
			If Empty(&SEEKEXPRESSION1.) Then
				Loop
			Endif
			Set Deleted Off
			If Not Seek (&SEEKEXPRESSION1.,TABLE2) Then
				Select (TABLE2)
				Append Blank
				= RecordReplace(TABLE2,TABLE1,UPDATEEXCEPTFIELDS)
				If Deleted()
					Recall
				Endif
				If RECORDCONVERTTYPE <> 0
					RecordConvert(Alias(),Iif(RECORDCONVERTTYPE = 1,Iif(Alias() = TABLE1,2,1),Iif(Alias() = TABLE1,1,2)))
				Endif
				LASTRETURN = LASTRETURN + 1
			Else
				Select (TABLE2)
				If FORCEUPDATE .Or. Deleted()
					= RecordReplace(TABLE2,TABLE1,UPDATEEXCEPTFIELDS)
					If Deleted()
						Recall
					Endif
					If RECORDCONVERTTYPE <> 0
						RecordConvert(Alias(),Iif(RECORDCONVERTTYPE = 1,Iif(Alias() = TABLE1,2,1),Iif(Alias() = TABLE1,1,2)))
					Endif
					LASTRETURN = LASTRETURN + 1
				Else
					If IsFieldExist('Adatetime',DbfAlias(TABLE1UPDATE),.F.) And  ;
							IsFieldExist('Adatetime',DbfAlias(TABLE2UPDATE),.F.)
						ADATETIME1 = TABLE1 + '.Adatetime'
						ADATETIME2 = TABLE2 + '.AdateTime'
						If &ADATETIME1.<>&ADATETIME2. And &ADATETIME1.>&ADATETIME2. Then
							= RecordReplace(TABLE2,TABLE1,UPDATEEXCEPTFIELDS)
							If Deleted()
								Recall
							Endif
							If RECORDCONVERTTYPE <> 0
								RecordConvert(Alias(),Iif(RECORDCONVERTTYPE = 1,Iif(Alias() = TABLE1,2,1),Iif(Alias() = TABLE1,1,2)))
							Endif
							LASTRETURN = LASTRETURN + 1
						Endif
					Else
						If LCAMENDDATETIME1 > LCAMENDDATETIME2
							= RecordReplace(TABLE2,TABLE1,UPDATEEXCEPTFIELDS)
							If Deleted()
								Recall
							Endif
							If RECORDCONVERTTYPE <> 0
								RecordConvert(Alias(),Iif(RECORDCONVERTTYPE = 1,Iif(Alias() = TABLE1,2,1),Iif(Alias() = TABLE1,1,2)))
							Endif
							LASTRETURN = LASTRETURN + 1
						Endif
					Endif
				Endif
			Endif
			Select (TABLE1)
			Set Deleted On
		Endscan
		Select (TABLE2)
		Set Deleted On
		Scan
			If Empty(&SEEKEXPRESSION2.) Then
				Loop
			Endif
			Set Deleted Off
			If Not Seek(&SEEKEXPRESSION2.,TABLE1) Then
				Select (TABLE1)
				Append Blank
				= RecordReplace(TABLE1,TABLE2,UPDATEEXCEPTFIELDS)
				If Deleted()
					Recall
				Endif
				If RECORDCONVERTTYPE <> 0
					RecordConvert(Alias(),Iif(RECORDCONVERTTYPE = 1,Iif(Alias() = TABLE1,2,1),Iif(Alias() = TABLE1,1,2)))
				Endif
				LASTRETURN = LASTRETURN + 1
			Else
				Select (TABLE1)
				If FORCEUPDATE .Or. Deleted()
					= RecordReplace(TABLE1,TABLE2,UPDATEEXCEPTFIELDS)
					If Deleted()
						Recall
					Endif
					If RECORDCONVERTTYPE <> 0
						RecordConvert(Alias(),Iif(RECORDCONVERTTYPE = 1,Iif(Alias() = TABLE1,2,1),Iif(Alias() = TABLE1,1,2)))
					Endif
					LASTRETURN = LASTRETURN + 1
				Else
					If IsFieldExist('Adatetime',DbfAlias(TABLE1UPDATE),.F.) And  ;
							IsFieldExist('Adatetime',DbfAlias(TABLE2UPDATE),.F.)
						ADATETIME1 = TABLE1 + '.AdateTime'
						ADATETIME2 = TABLE2 + '.AdateTime'
						If &ADATETIME1.<>&ADATETIME2. And &ADATETIME1.<&ADATETIME2. Then
							= RecordReplace(TABLE1,TABLE2,UPDATEEXCEPTFIELDS)
							If Deleted()
								Recall
							Endif
							If RECORDCONVERTTYPE <> 0
								RecordConvert(Alias(),Iif(RECORDCONVERTTYPE = 1,Iif(Alias() = TABLE1,2,1),Iif(Alias() = TABLE1,1,2)))
							Endif
							LASTRETURN = LASTRETURN + 1
						Endif
					Else
						If LCAMENDDATETIME1 < LCAMENDDATETIME2
							= RecordReplace(TABLE1,TABLE2,UPDATEEXCEPTFIELDS)
							If Deleted()
								Recall
							Endif
							If RECORDCONVERTTYPE <> 0
								RecordConvert(Alias(),Iif(RECORDCONVERTTYPE = 1,Iif(Alias() = TABLE1,2,1),Iif(Alias() = TABLE1,1,2)))
							Endif
							LASTRETURN = LASTRETURN + 1
						Endif
					Endif
				Endif
			Endif
			Select (TABLE2)
			Set Deleted On
		Endscan
	Else
		If Empty(RECORDNEWVALUE)
			If TABLEGOOD = 1
				Select (TABLE1)
				Set Deleted On
				Scan
					If Empty(&SEEKEXPRESSION1.) Then
						Loop
					Endif
					Set Deleted Off
					If Not Seek (&SEEKEXPRESSION1.,TABLE2) Then
						Select (TABLE2)
						Append Blank
						= RecordReplace(TABLE2,TABLE1,UPDATEEXCEPTFIELDS)
						If Deleted()
							Recall
						Endif
						If RECORDCONVERTTYPE <> 0
							RecordConvert(Alias(),Iif(RECORDCONVERTTYPE = 1,Iif(Alias() = TABLE1,2,1),Iif(Alias() = TABLE1,1,2)))
						Endif
						LASTRETURN = LASTRETURN + 1
					Else
						Select (TABLE2)
						If FORCEUPDATE .Or. Deleted()
							= RecordReplace(TABLE2,TABLE1,UPDATEEXCEPTFIELDS)
							If Deleted()
								Recall
							Endif
							If RECORDCONVERTTYPE <> 0
								RecordConvert(Alias(),Iif(RECORDCONVERTTYPE = 1,Iif(Alias() = TABLE1,2,1),Iif(Alias() = TABLE1,1,2)))
							Endif
							LASTRETURN = LASTRETURN + 1
						Else
							If IsFieldExist('Adatetime',DbfAlias(TABLE1UPDATE),.F.) And  ;
									IsFieldExist('Adatetime',DbfAlias(TABLE2UPDATE),.F.)
								ADATETIME1 = TABLE1 + '.Adatetime'
								ADATETIME2 = TABLE2 + '.AdateTime'
								If &ADATETIME1.<>&ADATETIME2. And &ADATETIME1.>&ADATETIME2. Then
									= RecordReplace(TABLE2,TABLE1,UPDATEEXCEPTFIELDS)
									If Deleted()
										Recall
									Endif
									If RECORDCONVERTTYPE <> 0
										RecordConvert(Alias(),Iif(RECORDCONVERTTYPE = 1,Iif(Alias() = TABLE1,2,1),Iif(Alias() = TABLE1,1,2)))
									Endif
									LASTRETURN = LASTRETURN + 1
								Endif
							Else
								If LCAMENDDATETIME1 > LCAMENDDATETIME2
									= RecordReplace(TABLE2,TABLE1,UPDATEEXCEPTFIELDS)
									If Deleted()
										Recall
									Endif
									If RECORDCONVERTTYPE <> 0
										RecordConvert(Alias(),Iif(RECORDCONVERTTYPE = 1,Iif(Alias() = TABLE1,2,1),Iif(Alias() = TABLE1,1,2)))
									Endif
									LASTRETURN = LASTRETURN + 1
								Endif
							Endif
						Endif
					Endif
					Select (TABLE1)
					Set Deleted On
				Endscan
			Else
				Select (TABLE2)
				Set Deleted On
				Scan
					If Empty(&SEEKEXPRESSION2.) Then
						Loop
					Endif
					Set Deleted Off
					If Not Seek(&SEEKEXPRESSION2.,TABLE1) Then
						Select (TABLE1)
						Append Blank
						= RecordReplace(TABLE1,TABLE2,UPDATEEXCEPTFIELDS)
						If Deleted()
							Recall
						Endif
						If RECORDCONVERTTYPE <> 0
							RecordConvert(Alias(),Iif(RECORDCONVERTTYPE = 1,Iif(Alias() = TABLE1,2,1),Iif(Alias() = TABLE1,1,2)))
						Endif
						LASTRETURN = LASTRETURN + 1
					Else
						Select (TABLE1)
						If FORCEUPDATE .Or. Deleted()
							= RecordReplace(TABLE1,TABLE2,UPDATEEXCEPTFIELDS)
							If Deleted()
								Recall
							Endif
							If RECORDCONVERTTYPE <> 0
								RecordConvert(Alias(),Iif(RECORDCONVERTTYPE = 1,Iif(Alias() = TABLE1,2,1),Iif(Alias() = TABLE1,1,2)))
							Endif
							LASTRETURN = LASTRETURN + 1
						Else
							If IsFieldExist('Adatetime',DbfAlias(TABLE1UPDATE),.F.) And  ;
									IsFieldExist('Adatetime',DbfAlias(TABLE2UPDATE),.F.)
								ADATETIME1 = TABLE1 + '.AdateTime'
								ADATETIME2 = TABLE2 + '.AdateTime'
								If &ADATETIME1.<>&ADATETIME2. And &ADATETIME1.<&ADATETIME2. Then
									= RecordReplace(TABLE1,TABLE2,UPDATEEXCEPTFIELDS)
									If Deleted()
										Recall
									Endif
									If RECORDCONVERTTYPE <> 0
										RecordConvert(Alias(),Iif(RECORDCONVERTTYPE = 1,Iif(Alias() = TABLE1,2,1),Iif(Alias() = TABLE1,1,2)))
									Endif
									LASTRETURN = LASTRETURN + 1
								Endif
							Else
								If LCAMENDDATETIME1 < LCAMENDDATETIME2
									= RecordReplace(TABLE1,TABLE2,UPDATEEXCEPTFIELDS)
									If Deleted()
										Recall
									Endif
									If RECORDCONVERTTYPE <> 0
										RecordConvert(Alias(),Iif(RECORDCONVERTTYPE = 1,Iif(Alias() = TABLE1,2,1),Iif(Alias() = TABLE1,1,2)))
									Endif
									LASTRETURN = LASTRETURN + 1
								Endif
							Endif
						Endif
					Endif
					Select (TABLE2)
					Set Deleted On
				Endscan
			Endif
		Else
			If TABLEGOOD = 1
				Select (TABLE1)
				Set Deleted On
				If Seek(RECORDNEWVALUE,TABLE1)
					Set Deleted Off
					If  .Not. Seek(RECORDNEWVALUE,TABLE2)
						Select (TABLE2)
						Append Blank
						= RecordReplace(TABLE2,TABLE1,UPDATEEXCEPTFIELDS)
						If Deleted()
							Recall
						Endif
						If RECORDCONVERTTYPE <> 0
							RecordConvert(Alias(),Iif(RECORDCONVERTTYPE = 1,Iif(Alias() = TABLE1,2,1),Iif(Alias() = TABLE1,1,2)))
						Endif
						LASTRETURN = LASTRETURN + 1
					Else
						Select (TABLE2)
						If FORCEUPDATE .Or. Deleted()
							= RecordReplace(TABLE2,TABLE1,UPDATEEXCEPTFIELDS)
							If Deleted()
								Recall
							Endif
							If RECORDCONVERTTYPE <> 0
								RecordConvert(Alias(),Iif(RECORDCONVERTTYPE = 1,Iif(Alias() = TABLE1,2,1),Iif(Alias() = TABLE1,1,2)))
							Endif
							LASTRETURN = LASTRETURN + 1
						Else
							If IsFieldExist('Adatetime',DbfAlias(TABLE1UPDATE),.F.) And  ;
									IsFieldExist('Adatetime',DbfAlias(TABLE2UPDATE),.F.)
								ADATETIME1 = TABLE1 + '.Adatetime'
								ADATETIME2 = TABLE2 + '.AdateTime'
								If &ADATETIME1.<>&ADATETIME2. And &ADATETIME1.>&ADATETIME2. Then
									= RecordReplace(TABLE2,TABLE1,UPDATEEXCEPTFIELDS)
									If Deleted()
										Recall
									Endif
									If RECORDCONVERTTYPE <> 0
										RecordConvert(Alias(),Iif(RECORDCONVERTTYPE = 1,Iif(Alias() = TABLE1,2,1),Iif(Alias() = TABLE1,1,2)))
									Endif
									LASTRETURN = LASTRETURN + 1
								Endif
							Else
								If LCAMENDDATETIME1 > LCAMENDDATETIME2
									= RecordReplace(TABLE2,TABLE1,UPDATEEXCEPTFIELDS)
									If Deleted()
										Recall
									Endif
									If RECORDCONVERTTYPE <> 0
										RecordConvert(Alias(),Iif(RECORDCONVERTTYPE = 1,Iif(Alias() = TABLE1,2,1),Iif(Alias() = TABLE1,1,2)))
									Endif
									LASTRETURN = LASTRETURN + 1
								Endif
							Endif
						Endif
					Endif
					Select (TABLE1)
				Endif
			Else
				Select (TABLE2)
				Set Deleted On
				If Seek(RECORDNEWVALUE,TABLE2)
					Set Deleted Off
					If  .Not. Seek(RECORDNEWVALUE,TABLE1)
						Select (TABLE1)
						Append Blank
						= RecordReplace(TABLE1,TABLE2,UPDATEEXCEPTFIELDS)
						If Deleted()
							Recall
						Endif
						If RECORDCONVERTTYPE <> 0
							RecordConvert(Alias(),Iif(RECORDCONVERTTYPE = 1,Iif(Alias() = TABLE1,2,1),Iif(Alias() = TABLE1,1,2)))
						Endif
						LASTRETURN = LASTRETURN + 1
					Else
						Select (TABLE1)
						If FORCEUPDATE .Or. Deleted()
							= RecordReplace(TABLE1,TABLE2,UPDATEEXCEPTFIELDS)
							If Deleted()
								Recall
							Endif
							If RECORDCONVERTTYPE <> 0
								RecordConvert(Alias(),Iif(RECORDCONVERTTYPE = 1,Iif(Alias() = TABLE1,2,1),Iif(Alias() = TABLE1,1,2)))
							Endif
							LASTRETURN = LASTRETURN + 1
						Else
							If IsFieldExist('Adatetime',DbfAlias(TABLE1UPDATE),.F.) And  ;
									IsFieldExist('Adatetime',DbfAlias(TABLE2UPDATE),.F.)
								ADATETIME1 = TABLE1 + '.AdateTime'
								ADATETIME2 = TABLE2 + '.AdateTime'
								If &ADATETIME1.<>&ADATETIME2. And &ADATETIME1.<&ADATETIME2. Then
									= RecordReplace(TABLE1,TABLE2,UPDATEEXCEPTFIELDS)
									If Deleted()
										Recall
									Endif
									If RECORDCONVERTTYPE <> 0
										RecordConvert(Alias(),Iif(RECORDCONVERTTYPE = 1,Iif(Alias() = TABLE1,2,1),Iif(Alias() = TABLE1,1,2)))
									Endif
									LASTRETURN = LASTRETURN + 1
								Endif
							Else
								If LCAMENDDATETIME1 < LCAMENDDATETIME2
									= RecordReplace(TABLE1,TABLE2,UPDATEEXCEPTFIELDS)
									If Deleted()
										Recall
									Endif
									If RECORDCONVERTTYPE <> 0
										RecordConvert(Alias(),Iif(RECORDCONVERTTYPE = 1,Iif(Alias() = TABLE1,2,1),Iif(Alias() = TABLE1,1,2)))
									Endif
									LASTRETURN = LASTRETURN + 1
								Endif
							Endif
						Endif
					Endif
					Select (TABLE2)
				Endif
			Endif
		Endif
	Endif
	If Used(TABLE1UPDATE)
		Use In (TABLE1UPDATE)
	Endif
	If Used(TABLE2UPDATE)
		Use In (TABLE2UPDATE)
	Endif
	If  .Not. Seek(RECORDTABLE1,TABLE1)
		If RECNOTABLE1 > 0
			Go RECNOTABLE1 In (TABLE1)
		Endif
	Endif
	If  .Not. Seek(RECORDTABLE2,TABLE2)
		If RECNOTABLE2 > 0
			Go RECNOTABLE2 In (TABLE2)
		Endif
	Endif
	If Used(TABLE1)
		Use In (TABLE1)
	Endif
	If Used(TABLE2)
		Use In (TABLE2)
	Endif
	If LCCURRENTSELECT > 0
		Select (LCCURRENTSELECT)
	Endif
	Set Deleted &LCSETDELETED.
	Return LASTRETURN
Endproc
*------
Procedure CharactersAdd
	Lparameter LCPLUS ,LRemoveEmpty,CHARACTER1 , CHARACTER2 , CHARACTER3 , CHARACTER4 , CHARACTER5 ,  ;
		CHARACTER6 , CHARACTER7 , CHARACTER8 , CHARACTER9 , CHARACTER10 ,  ;
		CHARACTER11 , CHARACTER12 , CHARACTER13 , CHARACTER14 , CHARACTER15 ,  ;
		CHARACTER16 , CHARACTER17 , CHARACTER18 , CHARACTER19 , CHARACTER20 ,  ;
		CHARACTER21 , CHARACTER22 , CHARACTER23 , CHARACTER24 , CHARACTER25
	
	If Pcount() < 3
		Wait Window 'Please at least send one or two string which need to integrated.' nowait
		Return ''
	EndIf
	LcPlus = DefCharacters(LcPlus,',',.T.)
	lRemoveEmpty = DefLogic(lRemoveEmpty)
	
	Local cReturnValue , LCTEMPVALUE , LCCONTROLTEMP5
	cReturnValue = ''
	For LCCONTROLTEMP5 = 1 To Pcount() - 2
		LCTEMPVALUE = 'Character' + Alltrim(Str(LCCONTROLTEMP5))
		If Vartype(&LCTEMPVALUE.)<>'C' Then
			Exit
		Else
			If IsValidStr(&LcTempValue.) or LRemoveEmpty Then && No need add LcPlus if empty the stringX
				cReturnValue=cReturnValue+&LCTEMPVALUE.+LCPLUS
			EndIf
		Endif
	EndFor
	If !Empty(cReturnValue) and Occurs(LcPlus,cReturnValue)>0 Then
		cReturnValue=Strtran(cReturnValue,LcPlus,'',Occurs(LcPlus,cReturnValue)) && Remove the last LcPlus
	EndIf
	Return cReturnValue
Endproc
*------
Procedure LcDbfOpen
	Lparameter LCTEMPDBFNAME , LCTEMPDBFALIAS , LCTEMPEXCLUSIVE , LCTEMPORDER
	
	If Pcount() < 1
		Return .F.
	EndIf
	If IsValidStr(LcTempDbfName) Then
		If Empty(JustExt(LcTempDbfName)) Then
			LcTempDbfName=ForceExt(LcTempDbfName,'Dbf')
		EndIf
		If Not File(LcTempDbfName) Then
			Return .F.
		EndIf
	Else
		Return .F.
	EndIf
	LcTempExclusive=DefLogic(LcTempExclusive)
	If IsValidStr(LcTempDbfAlias) Then
		LcTempDbfAlias=JustStem(LcTempDbfAlias) && Only get the fname not include the extend name , ? JustStem('ABC.TXT') && ABC
	Else
		LcTempDbfAlias=JustStem(LcTempDbfName)+'R'
		If IsDigit(LcTempDbfAlias) Then
			LcTempDbfAlias='_'+LcTempDbfAlias
		EndIf
		If Select(LcTempDbfAlias)>0 Then && It have been opened, No need open now.
			Return .F.
		EndIf
	EndIf

	Local LCTEMPSELECT
	LCTEMPSELECT = Select()
	Local TEMP_ONERROR , TEMP_FINDERROR
	TEMP_ONERROR = On('Error')
	TEMP_FINDERROR = .F.
	On Error TEMP_FINDERROR=.T.
	If  .Not. LcTempExclusive
		Use In 0 Shared (LcTempDbfName) Again Alias (LcTempDbfAlias)
	Else
		Use In 0 Exclusive (LcTempDbfName) Alias (LcTempDbfAlias)
	Endif
	If IsValidStr(LcTempOrder)
		Set Order To LcTempOrder in (LcTempDbfAlias)
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
	lParameter oAppName
	oAppName = Createobject('Excel.Application')
	Return oAppName
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
		Wait Window Nowait 'Please sure the alias ' +"'"+ LCALIASADD+"'" + ' had been opened !'
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
			Wait Window Nowait 'The table ' +"'"+ LCZAP_ALIAS+"'" + ' can not find '
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
		Wait Window Nowait 'Because the table ' +"'"+ LCZAP_ALIAS+"'" + ' can not open exclusive '
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
			'The station of ' +"'"+ LCSTATION+"'" + ' can not find in the desktop table !'
		LCRETURNCHARACTERS(LCDESKTOP_SELECT,LCDESKTOP_DBF,'','',LCDESKTOP_SETDELETED)
		Return ''
	Endif
	Set Deleted &LCDESKTOP_SETDELETED.
	If  .Not. IsFieldExist(LCFIELDNAME,LCDESKTOP_DBF)
		Wait Window Nowait 'Please sure the field ' + LCFIELDNAME + ' in the desktop.dbf !'
		LCRETURNCHARACTERS(LCDESKTOP_SELECT,LCDESKTOP_DBF,'','',LCDESKTOP_SETDELETED)
		Return ''
	Endif
	If  .Not. Directory(Addbs(Alltrim(CONTROL_PA)))
		Wait Window Nowait  ;
			'Please sure the control_pa of ' +"'"+ Addbs(Alltrim(CONTROL_PA))+"'" + ' exist !'
		LCRETURNCHARACTERS(LCDESKTOP_SELECT,LCDESKTOP_DBF,'','',LCDESKTOP_SETDELETED)
		Return ''
	Endif
	If  .Not. Directory(Addbs(Alltrim(CONTROL_PU)))
		Wait Window Nowait  ;
			'Please sure the control_pu of ' +"'"+ Addbs(Alltrim(CONTROL_PU))+"'" + ' exist !'
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
Procedure ItConvert && Convert any value to any type. UnTest
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
		Wait Window Nowait 'Please sure the ' +"'"+ DBF1+"'" + ' hase been opened'
		Return .F.
	Endif
	If  .Not. IsFieldExist(LCDBF1_FIELD,LCDBF1)
		Wait Window Nowait  ;
			'Please sure the field of ' +"'"+ LCDBF1_FIELD+"'" + ' in the table ' + LCDBF1
		Return .F.
	Endif
	Local LCRECORDREPLACE_SELECT , LCVALUEONE , LCVALUETWO
	LCRECORDREPLACE_SELECT = Select()
	LCVALUEONE = LCDBF1 + '.' + LCDBF1_FIELD
	LCVALUETWO=ItConvert(Vartype(&LCVALUEONE.),LCNEWVALUE)
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
*!*	Procedure LcSubstr
*!*		Parameter SUBSTR_VALUE , SUBSTR_PLUS , SUBSTR_INDEX , SUBSTR_TRIM
*!*		If Vartype(SUBSTR_VALUE) <> 'C' .Or. Empty(SUBSTR_VALUE)
*!*			Return ''
*!*		Endif
*!*		If Vartype(SUBSTR_TRIM) <> 'L'
*!*			SUBSTR_TRIM = .F.
*!*		EndIf
*!*		If Vartype(SUBSTR_PLUS) <> 'C' .Or. Asc(SUBSTR_PLUS)=0 && no any character
*!*			SUBSTR_PLUS = ','
*!*		Endif
*!*		If Vartype(SUBSTR_INDEX) <> 'N'
*!*			SUBSTR_INDEX = 0
*!*		Else
*!*			If SUBSTR_INDEX < 0
*!*				SUBSTR_INDEX = 0
*!*			Endif
*!*		Endif
*!*		If  .Not. (SUBSTR_PLUS $ SUBSTR_VALUE) .Or. SUBSTR_INDEX = 0
*!*			If SUBSTR_TRIM
*!*				Return Alltrim(SUBSTR_VALUE)
*!*			Else
*!*				Return SUBSTR_VALUE
*!*			Endif
*!*		Endif
*!*		SUBSTR_VALUE = Strtran(SUBSTR_VALUE,SUBSTR_PLUS,Chr(13) + Chr(10))
*!*		If Alines(SUBSTR_ARRAY,SUBSTR_VALUE) < 2
*!*			If SUBSTR_TRIM
*!*				Return Alltrim(SUBSTR_VALUE)
*!*			Else
*!*				Return SUBSTR_VALUE
*!*			Endif
*!*		Else
*!*			If Alen(SUBSTR_ARRAY) >= SUBSTR_INDEX
*!*				If SUBSTR_TRIM
*!*					Return Alltrim(SUBSTR_ARRAY(SUBSTR_INDEX))
*!*				Else
*!*					Return SUBSTR_ARRAY(SUBSTR_INDEX)
*!*				Endif
*!*			Else
*!*				Wait Window Nowait  ;
*!*					'Because the character index '+"'"+Alltrim(Str(Substr_Index))+"'"+' is larger than character counts '+Alltrim(Str(Alen(SUBSTR_ARRAY)))+' , Program will be get the last index of character value !'
*!*				If SUBSTR_TRIM
*!*					Return Alltrim(SUBSTR_ARRAY(Alen(SUBSTR_ARRAY)))
*!*				Else
*!*					Return SUBSTR_ARRAY(Alen(SUBSTR_ARRAY))
*!*				Endif
*!*			Endif
*!*		Endif
*!*	Endproc
*------
Procedure ItSubstr
	lParameter cString ,cDelimiter ,nOccurrence
	
	* Defalut the return value as string
	Local cReturnValue
	cReturnValue = ''
	Local Array cTmpArray(1)
	
	* Check the parameters
	If Vartype(cString) <> 'C'
		Return cReturnValue
	EndIf
	cDelimiter = DefCharacters(cDelimiter,Space(1),.T.) && Default value is space ,That's means split by space.
	nOccurrence = Abs(Int(DefNumber(nOccurrence,1))) && Default value is 1 ,Get the first occurrence string split by cDelimiter.	
	If  !cDelimiter $ cString .Or. nOccurrence = 0
		* The cString not include cDelimiter or nOccurrence = 0 (That's mean not need get value)
		Return cReturnValue
	EndIf
	
	* Get the return value as string
	cString = Strtran(cString,cDelimiter,Chr(13)+Chr(10))
	* It will using Chr(13) + Chr(10) instead of cDelimiter ,
	* That can use the Alines command to split the cString by Chr(13)+Chr(10)	
	If Alines('cTmpArray',cString) >= 2
		If Alen(cTmpArray) >= nOccurrence
			cReturnValue = cTmpArray(nOccurrence)
		Else
			cReturnValue = ''
			* Because the parameter nOccurrence is larger than cString nOccurrence counts.
		Endif
	EndIf
	
	* Return value 
	Return cReturnValue
EndProc
*------
*!*	Procedure ItSubstr_old && Can not run in vfp6
*!*		Parameter SUBSTR_VALUE , SUBSTR_PLUS , SUBSTR_INDEX , SUBSTR_TRIM
*!*		If Vartype(SUBSTR_VALUE) <> 'C' .Or. Empty(SUBSTR_VALUE)
*!*			Return ''
*!*		Endif
*!*		If Vartype(SUBSTR_TRIM) <> 'L'
*!*			SUBSTR_TRIM = .F.
*!*		EndIf
*!*		If Vartype(SUBSTR_PLUS) <> 'C' .Or. Asc(SUBSTR_PLUS)=0 && no any character
*!*			SUBSTR_PLUS = ','
*!*		Endif
*!*		If Vartype(SUBSTR_INDEX) <> 'N'
*!*			SUBSTR_INDEX = 0
*!*		Else
*!*			If SUBSTR_INDEX < 0
*!*				SUBSTR_INDEX = 0
*!*			Endif
*!*		Endif
*!*		If  .Not. (SUBSTR_PLUS $ SUBSTR_VALUE) .Or. SUBSTR_INDEX = 0
*!*			If SUBSTR_TRIM
*!*				Return Alltrim(SUBSTR_VALUE)
*!*			Else
*!*				Return SUBSTR_VALUE
*!*			Endif
*!*		Endif
*!*	*!*		SUBSTR_VALUE = Strtran(SUBSTR_VALUE,SUBSTR_PLUS,Chr(13) + Chr(10)) && Noted by roger at 2010-05-22 14:44
*!*		If Alines(SUBSTR_ARRAY,SUBSTR_VALUE,SUBSTR_PLUS) < 2
*!*			If SUBSTR_TRIM
*!*				Return Alltrim(SUBSTR_VALUE)
*!*			Else
*!*				Return SUBSTR_VALUE
*!*			Endif
*!*		Else
*!*			If Alen(SUBSTR_ARRAY) >= SUBSTR_INDEX
*!*				If SUBSTR_TRIM
*!*					Return Alltrim(SUBSTR_ARRAY(SUBSTR_INDEX))
*!*				Else
*!*					Return SUBSTR_ARRAY(SUBSTR_INDEX)
*!*				Endif
*!*			Else
*!*				Return ''
*!*			Endif
*!*		Endif
*!*	Endproc
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
				Wait Window Nowait 'Can not find the talbe ' + "'"+DBF_ALIAS+"'"
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
Procedure Sp_Export
	Lparameter NHAND , CDBFTABLE , CDBFPRIMARY , CDBFPRIMARYFIELD , CDBFSECOND , CSQLTABLE ,  ;
		CSQLPRIMARYFIELD , CSQLSECOND , CFIELDSEXPRESSION , CPLUS , LLOCALUPDATE ,  ;
		LFORCE , CFILTER , LNOCHECKPRIMARY , LUPDATEPRIMARY , CFIELDPLUS
	If  .Not. IS_CHARACTER(CFIELDPLUS)
		CFIELDPLUS = '.'
	Endif
	If Vartype(LLOCALUPDATE) <> 'L'
		LLOCALUPDATE = .F.
	Endif
	If Empty(CFILTER)
		CFILTER = '.T.'
	Endif
	If  .Not. (Iif('.DBF' $ Upper(CDBFTABLE),File(CDBFTABLE),File(CDBFTABLE + '.Dbf')))
		Wait Window Nowait  ;
			'Can not find the table ' + "'"+CDBFTABLE+"'" +  ;
			' ,Please change the directory and try again !'
		Return .F.
	Endif
	If Vartype(CFIELDSEXPRESSION) <> 'C' .Or. Empty(CFIELDSEXPRESSION)
		Wait Window Nowait 'Please sure the FieldsExpression in characters and not empty !'
		Return .F.
	Endif
	If  .Not. (CFIELDPLUS $ CFIELDSEXPRESSION)
		EXPORT_MESSAGE =  ;
			'Please sure the FieldsExpression font in User_ID.Code_ID,User_Name.XM .' + Chr(13) +  ;
			CHR(10) + Chr(13) + '----------------------------------------------' +  ;
			CHR(13) + 'Replace DbfTable.User_ID with SqlTable.Code_ID' + Chr(13) +  ;
			'Replace DbfTable.User_Name with SqlTable.XM'
		Wait Window Nowait EXPORT_MESSAGE
		Return .F.
	Endif
	If Vartype(CPLUS) <> 'C' .Or. Empty(CPLUS)
		CPLUS = ','
	Endif
	If Right(CFIELDSEXPRESSION,1) == CPLUS
		CFIELDSEXPRESSION = Left(CFIELDSEXPRESSION,Len(CFIELDSEXPRESSION) - 1)
	Endif
	If Vartype(LFORCE) <> 'L'
		LFORCE = .T.
	Endif
	Local EXPORT_SELECT , LCDBFALIAS , LCSQLALIAS , LCEXPORT , LCSETDELETED , LCNEEDUPDATE ,  ;
		LCRECALL , LCADDTOTAL , LCUPDATETOTAL , EXPORT_REPLACE , EXPORT_OLD ,  ;
		EXPORT_NEW , EXPORT_LOG , LCSETMULTILOCKS , CREPLACEEXPRESSION
	LCSETMULTILOCKS = Set('Multilocks')
	Set Multilocks On
	LCSETDELETED = Set('Deleted')
	Set Deleted Off
	LCSQLALIAS = AliasName()
	LCDBFALIAS = AliasName()
	LCRECALL = 0
	LCADDTOTAL = 0
	LCUPDATETOTAL = 0
	LCNONEEDUPDATE = 0
	EXPORT_LOG = ''
	EXPORT_LOG =  ;
		'----------------------------------------------------------------------------------------------------' +  ;
		CHR(13)
	EXPORT_SELECT = Select()
	If LLOCALUPDATE
		If  .Not. LcDbfOpen(CSQLTABLE,LCSQLALIAS)
			Set Path To  ;
				GETDIR('',Iif('.DBF' $ Upper(CSQLTABLE),CSQLTABLE,CSQLTABLE + '.Dbf'),'Get directory')
			LcDbfClose(LCSQLALIAS)
			If  .Not. LcDbfOpen(CSQLTABLE,LCSQLALIAS)
				Wait Window Nowait  ;
					'Because can not find the table ' +"'"+ CSQLTABLE +"'"+  ;
					',Please reset the directory and try again !'
				If EXPORT_SELECT >= 0
					Select (EXPORT_SELECT)
				Endif
				Set Deleted &LCSETDELETED.
				Set Multilocks &LCSETMULTILOCKS.
				Return .F.
			Endif
		Endif
	Else
		Wait Window Nowait 'Checking the Sql nHand …………'
		If Vartype(NHAND) <> 'N'
			NHAND = 0
		Else
			If NHAND < 0
				NHAND = 0
			Endif
		Endif
		*!*			If NHAND <= 0
		*!*				NHAND = SQL_CONNECT()
		*!*			Else
		*!*				NHAND = CHECK_SQL(NHAND)
		*!*			Endif
		If NHAND <= 0
			Wait Window Nowait 'Please sure the connect Sql Success first! '
			If EXPORT_SELECT >= 0
				Select (EXPORT_SELECT)
			Endif
			Set Deleted &LCSETDELETED.
			Set Multilocks &LCSETMULTILOCKS
			Return .F.
		Endif
		Wait Window Nowait 'Get the table ' +"'"+ CSQLTABLE+"'" + ' from the SQL server ……'
		LCEXPORT = SQLExec(NHAND,'Select * from dbo.' + CSQLTABLE,LCSQLALIAS)
		If LCEXPORT <> 1
			Wait Window Nowait 'Select table failed ,Connect again ……'
			NHAND = SQL_CONNECT()
			LCEXPORT = SQLExec(NHAND,'Select * from dbo.' + CSQLTABLE,LCSQLALIAS)
			If LCEXPORT <> 1
				Wait Window Nowait 'Export table of ' +"'"+ CDBFTABLE+"'" + ' failed '
				LcDbfClose(LCSQLALIAS)
				If EXPORT_SELECT >= 0
					Select (EXPORT_SELECT)
				Endif
				Set Deleted &LCSETDELETED.
				Set Multilocks &LCSETMULTILOCKS
				Return .F.
			Endif
		Endif
		Wait Window Nowait 'Get the table successed from the SQL server ……'
	Endif
	LcDbfOpen(CDBFTABLE,LCDBFALIAS,.F.,CDBFPRIMARY)
	EXPORT_LOG =  ;
		EXPORT_LOG + 'Update table ' + CDBFTABLE + ' from ' + CSQLTABLE + '---------Begain' +  ;
		CHR(13)
	EXPORT_LOG = EXPORT_LOG + 'Beg Time: ' + Alltrim(Ttoc(Datetime())) + Chr(13)
	Select (LCDBFALIAS)
	= CursorSetProp('Buffering',3)
	If  .Not. IsFieldExist(CSQLPRIMARYFIELD,LCSQLALIAS) .Or.  ;
			.Not. IsFieldExist(CSQLSECOND,LCSQLALIAS) .Or.  .Not. IsFieldExist(CDBFSECOND,LCDBFALIAS)
		Wait Window Nowait "Please sure the dbf and sql tabls's primary field in right !"
		LcDbfClose(LCDBFALIAS)
		LcDbfClose(LCSQLALIAS)
		Set Deleted &LCSETDELETED.
		If EXPORT_SELECT >= 0
			Select (EXPORT_SELECT)
		Endif
		Set Multilocks &LCSETMULTILOCKS
		Return .F.
	Endif
	If Vartype(LNOCHECKPRIMARY) <> 'L'
		LNOCHECKPRIMARY = .F.
	Endif
	If LNOCHECKPRIMARY = .F.
		If Vartype(LUPDATEPRIMARY) <> 'L'
			LUPDATEPRIMARY = .F.
		Endif
		If Fsize(CSQLPRIMARYFIELD,LCSQLALIAS) > Fsize(CDBFPRIMARYFIELD,LCDBFALIAS)
			If LUPDATEPRIMARY
				Wait Window Nowait  ;
					'Because the sql table primary field size ' +"'"+ CSQLPRIMARYFIELD+"'" +  ;
					' length larger than dbf primary field ' + "'"+CDBFPRIMARYFIELD+"'"
				LCTEMPVALUE =  ;
					SPACE(4) + 'Because the sql table primary field size ' + CSQLPRIMARYFIELD +  ;
					' length larger than dbf primary field ' + CDBFPRIMARYFIELD + Chr(13)
				EXPORT_LOG = EXPORT_LOG + LCTEMPVALUE
				LcDbfClose(LCDBFALIAS)
				If LcDbfOpen(CDBFTABLE,CDBFTABLE,.T.)
					Select (CDBFTABLE)
					TEMPFTYPE = LCSQLALIAS + '.' + CSQLPRIMARYFIELD
					TEMPFSIZE = Fsize(CSQLPRIMARYFIELD,LCSQLALIAS)
					LCTEMPVALUE='Alter table '+CDBFTABLE+' alter column '+CDBFPRIMARYFIELD+' '+Vartype(&TEMPFTYPE)+'('+Alltrim(Str(TEMPFSIZE))+')'
					EXPORT_LOG = EXPORT_LOG + Space(4) + LCTEMPVALUE + Chr(13)
					&LCTEMPVALUE.
					LcDbfClose(CDBFTABLE)
					LcDbfOpen(CDBFTABLE,LCDBFALIAS,.F.,CDBFPRIMARY)
					Select (LCDBFALIAS)
					= CursorSetProp('Buffering',3)
				Else
					Wait Window Nowait  ;
						'Because can not alter the table ' +"'"+ CDBFTABLE+"'" + ' of field ' + CDBFPRIMARYFIELD +  ;
						' field size,Close the ' +"'"+ CDBFTABLE+"'" + ' in other select first!'
					LcDbfClose(LCSQLALIAS)
					Set Deleted &LCSETDELETED.
					If EXPORT_SELECT >= 0
						Select (EXPORT_SELECT)
					Endif
					Set Multilocks &LCSETMULTILOCKS
					Return .F.
				Endif
			Else
				Wait Window Nowait  ;
					'Because the Sql table primary field size ' + "'"+CSQLPRIMARYFIELD+"'" +  ;
					' field size larger than dbf primary field ' +"'"+ CDBFPRIMARY+"'"
				LcDbfClose(LCSQLALIAS)
				LcDbfClose(LCDBFALIAS)
				Set Deleted &LCSETDELETED.
				If EXPORT_SELECT >= 0
					Select (EXPORT_SELECT)
				Endif
				Set Multilocks &LCSETMULTILOCKS
				Return .F.
			Endif
		Endif
	Endif
	CSQLPRIMARYFIELD = LCSQLALIAS + '.' + CSQLPRIMARYFIELD
	CSQLSECOND = LCSQLALIAS + '.' + CSQLSECOND
	CDBFSECOND = LCDBFALIAS + '.' + CDBFSECOND
	Set Collate To 'MACHINE'
	CFIELDSEXPRESSION = Strtran(CFIELDSEXPRESSION,CPLUS,Chr(13) + Chr(10))
	CHECKFIELDS = ''
	CFIELDSEXCL = ''
	For EXPORT_CONTROL = 1 To Alines(EXPORT_ARRAY,CFIELDSEXPRESSION)
		EXPORT_REPLACE = EXPORT_ARRAY(EXPORT_CONTROL)
		EXPORT_OLD = ItSubstr(EXPORT_REPLACE,CFIELDPLUS,1)
		EXPORT_NEW = ItSubstr(EXPORT_REPLACE,CFIELDPLUS,2)
		If  .Not. IsFieldExist(EXPORT_OLD,LCDBFALIAS)
			CHECKFIELDS =  ;
				CHECKFIELDS + 'Field ' + EXPORT_OLD + ' not in table ' + CDBFTABLE + Chr(13) +  ;
				CHR(10)
		Endif
		If  .Not. '|' $ EXPORT_NEW
			If  .Not. IsFieldExist(EXPORT_NEW,LCSQLALIAS)
				CHECKFIELDS =  ;
					CHECKFIELDS + 'Field ' + EXPORT_NEW + ' not in table ' + CSQLTABLE + Chr(13) +  ;
					CHR(10)
			Endif
			EXPORT_NEW = LCSQLALIAS + '.' + EXPORT_NEW
		Else
			EXPORT_NEW = Left(EXPORT_NEW,Len(EXPORT_NEW) - 1)
		Endif
		EXPORT_OLD = LCDBFALIAS + '.' + EXPORT_OLD
		If Empty(CFIELDSEXCL)
			CFIELDSEXCL = 'Replace ' + EXPORT_OLD + ' with ' + EXPORT_NEW
		Else
			If  .Not. '|' $ EXPORT_NEW
				CFIELDSEXCL=CFIELDSEXCL+','+EXPORT_OLD+' with '+[Iif(IsNull(ItConvert(Vartype(&Export_Old.),&Export_New.)),&Export_Old.,ItConvert(Vartype(&Export_Old.),&Export_New.))]
			Else
				CFIELDSEXCL = CFIELDSEXCL + ',' + EXPORT_OLD + ' with ' + EXPORT_NEW
			Endif
		Endif
	Endfor
	If  .Not. Empty(CHECKFIELDS)
		Messagebox(CHECKFIELDS,32,'Error')
		LcDbfClose(LCSQLALIAS)
		LcDbfClose(LCDBFALIAS)
		Set Deleted &LCSETDELETED.
		If EXPORT_SELECT >= 0
			Select (EXPORT_SELECT)
		Endif
		Set Multilocks &LCSETMULTILOCKS
		Return .F.
	Endif
	CDBFPRIMARYFIELDSIZE = Fsize(CDBFPRIMARYFIELD,LCDBFALIAS)
	Select (LCSQLALIAS)
	Scan
		Wait Window Nowait  ;
			'Deal with the record from ' + "'"+LCSQLALIAS+"'" + ' tables ……' + '  ' +  ;
			ALLTRIM(Str(Recno())) + '/' + Alltrim(Str(Reccount()))
		If !Evaluate(CFILTER) Then
			Loop
		Endif
		LCNEEDUPDATE = .F.
		Select (LCDBFALIAS)
		If Not Seek(Padr(Alltrim(Upper(&CSQLPRIMARYFIELD.)),CDBFPRIMARYFIELDSIZE,' ')) Then
			LCNEEDUPDATE = .T.
			Append Blank
			&CFIELDSEXCL.
			LCADDTOTAL = LCADDTOTAL + 1
		Else
			Select (LCDBFALIAS)
			TEMP_RECALL = .F.
			If Deleted()
				LCNEEDUPDATE = .T.
				Recall
				TEMPRECALL = .T.
				LCRECALL = LCRECALL + 1
			Endif
			If Not(Alltrim(Upper(&CSQLSECOND.))==Alltrim(Upper(&CDBFSECOND.))) Or LFORCE Then
				&CFIELDSEXCL.
				LCNEEDUPDATE = .T.
				If  .Not. TEMP_RECALL
					LCUPDATETOTAL = LCUPDATETOTAL + 1
				Endif
			Endif
		Endif
		If LCNEEDUPDATE
			= Tableupdate(.T.,.T.,LCDBFALIAS)
		Else
			LCNONEEDUPDATE = LCNONEEDUPDATE + 1
		Endif
	Endscan
	EXPORT_LOG = EXPORT_LOG + 'End Time: ' + Ttoc(Datetime()) + Chr(13)
	EXPORT_LOG =  ;
		EXPORT_LOG + 'Update table ' + CDBFTABLE + ' -----------------------End !' +  ;
		CHR(13)
	EXPORT_LOG =  ;
		EXPORT_LOG + 'Total add records: ' + Alltrim(Str(LCADDTOTAL)) + Chr(13)
	EXPORT_LOG =  ;
		EXPORT_LOG + 'Total update records: ' + Alltrim(Str(LCUPDATETOTAL)) + Chr(13)
	EXPORT_LOG =  ;
		EXPORT_LOG + 'Total recall records: ' + Alltrim(Str(LCRECALL)) + Chr(13)
	EXPORT_LOG =  ;
		EXPORT_LOG + 'Total no need update records:' + Alltrim(Str(LCNONEEDUPDATE)) +  ;
		CHR(13)
	EXPORT_LOG =  ;
		EXPORT_LOG +  ;
		'----------------------------------------------------------------------------------------------------'
	EXPORT_LOG =  ;
		EXPORT_LOG + Chr(13) + Chr(10) + Chr(13) + Chr(10) + Chr(13) + Chr(10) + Chr(13) +  ;
		CHR(10) + Chr(13) + Chr(10) + Chr(13) + Chr(10)
	= Strtofile(EXPORT_LOG,'Export_Log.Txt',1)
	LcDbfClose(LCDBFALIAS)
	LcDbfClose(LCSQLALIAS)
	If LCUPDATETOTAL > 0
		Wait Window Nowait  ;
			'Table ' + "'"+CDBFTABLE+"'" + ' update successed ,Press any key to continue !'
	Else
		Wait Window Nowait 'Check all record successed,But no need to update !'
	Endif
	If EXPORT_SELECT >= 0
		Select (EXPORT_SELECT)
	Endif
	Set Deleted &LCSETDELETED.
	Set Multilocks &LCSETMULTILOCKS
	Return .T.
Endproc
*------
*!*	Procedure CHECK_SQL
*!*		Lparameter SQL_NHANDLE
*!*		Local CHECK_SQL_CONTROL
*!*		If Vartype(SQL_NHANDLE) <> 'N' .Or. Empty(SQL_NHANDLE)
*!*			Return SQL_CONNECT()
*!*		Else
*!*			If Access(TEMPARRAY) = 0
*!*				Return SQL_CONNECT()
*!*			Else
*!*				For CHECK_SQL_CONTROL = 1 To Alen(TEMPARRAY)
*!*					If SQL_NHANDLE = TEMPARRAY(CHECK_SQL_CONTROL)
*!*						Return SQL_NHANDLE
*!*					Endif
*!*				Endfor
*!*				Wait Window Nowait 'Sql handle not used, Connect again ……'
*!*				Return SQL_CONNECT()
*!*			Endif
*!*		Endif
*!*	Endproc
*------
Procedure SQL_CONNECT
	Lparameter LCSERVER , LCUID , LCPWD , LCDATABASE
	If Vartype(LCSERVER) <> 'C' .Or. Empty(LCSERVER)
		LCSERVER = 'itotal'
	Endif
	If Vartype(LCUID) <> 'C' .Or. Empty(LCUID)
		LCUID = 'itrader'
	Endif
	If Vartype(LCPWD) <> 'C' .Or. Empty(LCPWD)
		LCPWD = 'szitrader'
	Endif
	If Vartype(LCDATABASE) <> 'C' .Or. Empty(LCDATABASE)
		LCDATABASE = 'bag_db'
	Endif
	*!*		Set Procedure To DBF_ALIAS:\Spark\Spark Additive
	Local LCCONNECTEXPRESSION , LCTEMPCONNECTHANDLE
	LCCONNECTEXPRESSION =  ;
		'driver=SQL Server;' + 'Server=' + LCSERVER + ';' + 'Uid=' + LCUID + ';' + 'pwd=' +  ;
		LCPWD + ';' + 'database=' + LCDATABASE
	LCTEMPCONNECTHANDLE = SQLSTRINGCONNEC(LCCONNECTEXPRESSION)
	If LCTEMPCONNECTHANDLE > 0
		Wait Window Nowait 'SQL connect success ……'
		Return LCTEMPCONNECTHANDLE
	Else
		Wait Window Nowait 'Sql connect failed ……'
		Return 0
	Endif
Endproc
*------
Procedure SqlDisconnectAll
	Lparameters nStatementHandle
	If IsNumber(nStatementHandle) Then
		Return SQLDisconnect(nStatementHandle)
	Else
		Local Array cTmpSqlHandle(1)
		Local nDisconnectCount
		nDisconnectCount=0
		If ASQLHandles(cTmpSqlHandle)>0 Then
			Local nSqlHandleCount,nTag,nTmpStatementHandle
			nSqlHandleCount=Alen(cTmpSqlHandle,1)
			For nTag=1 to nSqlHandleCount
				nTmpStatementHandle=cTmpSqlHandle(nTag,1)
				If SQLDisconnect(nTmpStatementHandle)>0 Then && Disconnect successful
					nDisconnectCount=nDisconnectCount+1
				EndIf
			EndFor
		EndIf
		Release cTmpSqlHandle
	EndIf
	Return nDisconnectCount
EndProc 
*------
Procedure SqlStrConnect
	Lparameter LcServer , LcDatabase , LcUserID , LcPassword
	LcServer=DefCharacters(LcServer,GetComputerName())
	LcDatabase=DefCharacters(LcDatabase,'master')
	LcUserId=DefCharacters(LcUserID,'sa')
	LcPassword=DefCharacters(LcPassword,'',.T.)
	Local LcConnectExpression,LcTempConnectHandle
	LcConnectExpression=	"driver=SQL Server;" + 	;
							"Server=&LcServer;"+ 	;
							"database=&LcDatabase;"+;						
							"Uid=&LcUserID;"+		;
							"pwd=&LcPassword"
	LcTempConnectHandle= SqlStringConnect(LcConnectExpression)
	Return LcTempConnectHandle
Endproc
*------
Procedure SqlGetObject && UnFinished
	Lparameters nSqlHandle && SqlServer,Database,Table,Column
	If Int(nSqlHandle)<=0 Then
		WaitWindow('Please make sure the sql handle is valid.',Sys(16))
		Return ''
	EndIf
	Local oSqlDmo,cError,cReturnValue
	cReturnValue=''
	cError=''
	Try
		oSqlDmo=CreateObject("SQLDMO.SQLServer")
	Catch
		cError=null
	EndTry
	If IsNull(cError) Then
		WaitWindow('Please correct configuration SQL dmo server first.',Sys(16))
		Return  cReturnValue
	EndIf
	
	Waitwindow('The procedure not finished')	
	&& Pause
EndProc
*------
Procedure AccessStrConnect
	Lparameter LcDatabase , LcUserID , LcPassword
	
	LcDatabase=DefCharacters(LcDatabase)
	LcUserId=DefCharacters(LcUserId)
	LcPassword=DefCharacters(LcPassword)
	
	Local LcConnectExpression,LcTempConnectHandle
	LcConnectExpression=	"driver={Microsoft Access Driver (*.mdb)};"+;
							"Dbq=&LcDatabase;"+;
							"Uid=&LcUserID;"+;
							"Pwd=&LcPassword"
	LcTempConnectHandle= SQLStringConnect(LcConnectExpression)
	Return LcTempConnectHandle
EndProc
*------
Procedure AccessToVfp && Unfinished
 * SqlTables(nHandle,cType{Table,View},cCursorName)
 * http://bbs.bccn.net/thread-50076-1-1.html
EndProc
*------
Procedure DbfStrConnect && Question: How to connect a remote dbf with using account.
	Lparameter LcDbfPath , LcUserID , LcPassword
	
	LcDbfPath=DefCharacters(LcDbfPath)
	LcUserId=DefCharacters(LcUserId)
	LcPassword=DefCharacters(LcPassword)
	
	Local LcConnectExpression,LcTempConnectHandle
	LcConnectExpression=	"driver={Microsoft Visual FoxPro Driver};"+;
							"SourceType=DBF;"+;
							"Exclusive=No;"+;
							"Collate=Machine;"+;
							"NULL=NO;"+;
							"DELETED=NO;"+;
							"BACKGROUNDFETCH=NO;"+;
							"SourceDB=&LcDbfPath;"+;
							"Uid=&LcUserID;"+;
							"Pwd=&LcPassword"
	LcTempConnectHandle= SQLStringConnect(LcConnectExpression)
	Return LcTempConnectHandle
EndProc
*------
Procedure ExcelConnect
	Lparameters LcFileName
	If IsValidStr(LcFileName) Then
		LcFileName=Alltrim(LcFileName)
		If Empty(JustExt(LcFileName)) Then
			LcFileName=ForceExt(LcFileName,'xls')
		EndIf
		If Empty(JustPath(LcFileName)) Then
			LcFileName=Addbs(Set('Directory'))+LcFileName
		EndIf
		If Not File(LcFileName) Then
			WaitWindow("The excel file '"+Alltrim(LcFileName)+"' not exist.",Sys(16))
			Return -1
		Endif
	Else
		LcFileName=Getfile('XLS','Excel file path','&Select')
		If Not IsValidStr(LcFileName) Then
			Return -1
		Endif
	Endif
	
	Local LcConnectionExpression,LcTempConnectHandle
	LcConnectionExpression=		"Driver={Microsoft Excel Driver (*.xls)};"+	;
								"DriverID=790;"+	;
								"Dbq=&LcFileName"
	LcTempConnectHandle=Sqlstringconnect(LcConnectionExpression)
	Return LcTempConnectHandle
EndProc	
*------
Procedure ExcelGetSheets && UnFinished
	Lparameters nExcel_Handle
	nExcel_Handle=Int(DefNumber(nExcel_Handle))
	Local nReturnValue,cExcelFilePath
	nReturnValue=-1
	cExcelFilePath=''
	If DefNumber(nExcel_Handle)>0 Then
		Local cConnectString
		cConnectString=''
		Try
			cConnectString=Sqlgetprop(nExcel_Handle,"ConnectString")
		Catch
			cConnectString=.NULL.
		Finally
			If Not Isnull(cConnectString) Then
				cExcelFilePath=Alltrim(Strextract(cConnectString,'DBQ=',';',1,1))
			EndIf
		Endtry
	Endif
	If Not IsValidStr(cExcelFilePath) Then
		WaitWindow('Can not found any excel file path from handle of '+Alltrim(Str(nExcel_Handle)),Sys(16))
		Return nReturnValue
	EndIf
	
	Local oExcel
	Try
		oExcel=Createobject('Excel.Application')
	Catch
		oExcel=.Null.
	Finally
		If Isnull(oExcel) Then
			WaitWindow('Please make sure Microsoft Excel Application have been installed.',Sys(16))
		Else
			oExcel.WorkBooks.Open(cExcelFilePath,,.T.) && ReadOnly
		Endif
	Endtry

	Create Cursor Sqlresult;
		(;
			Table_Cat c (128),;
			Table_Schem c (128),;
			Table_Name c (128),;
			Table_Type c (32),;
			Remarks c (254);
		)
	
	Local nTag,nSheetCount
	nSheetCount=oExcel.Sheets.Count
	nReturnValue=nSheetCount
	For nTag=1 To nSheetCount
		Insert Into Sqlresult (Table_Name) Values (oExcel.Sheets(nTag).name)
	EndFor
	oExcel.WorkBooks.Close()
	oExcel.Quit()
	Goto Top In Sqlresult
	Return nReturnValue
EndProc
*------
Procedure ExcelMergeSheets
	Lparameters nExcel_Handle	
	nExcel_Handle=Int(DefNumber(nExcel_Handle))
	If ExcelGetSheets(nExcel_Handle)<=0 Then
		Return 0
	EndIf	
	
	Local nReturnValue,cConnectString,cExcelFilePath,cCursorName,cCommand
	Store 0 To nReturnValue
	cConnectString=Sqlgetprop(nExcel_Handle,"ConnectString")
	cExcelFilePath=Alltrim(Strextract(cConnectString,'DBQ=',';',1,1))
	cCursorName=StrRecombile(JustStem(cExcelFilePath),' ','_')
	Sqldisconnect(nExcel_Handle) && We must disconnect the handle, or it's can not run append from or import from command in vfp
	If Select(cCursorName)>0 Then
		WaitWindow('The file was opened of "'+Alltrim(cCursorName)+'"',Sys(16))
		Return 0
	Endif
	
	Select SqlResult
	Scan
		nReturnValue=nReturnValue+1
		If nReturnValue=1 Then
			Select 0
			cCommand="Import from [" +cExcelFilePath+"] Type Xl8 sheet["+Alltrim(sqlresult.table_name)+"]"
			&cCommand.
			If Select(cCursorName)<=0 Then && Not append successful
				Exit
*!*					Return 0
			EndIf
		Else
			Select (cCursorName)
			cCommand="Append From [" +cExcelFilePath+"] Type Xl8 sheet["+Alltrim(sqlresult.Table_name)+"]"
			&cCommand.
		Endif
		Select SqlResult
	Endscan
*!*		If File(cExcelFilePath) Then
*!*			nExcel_Handle=ExcelConnect(cExcelFilePath)
*!*		EndIf
	Select (cCursorName)
	If nReturnValue>0 Then
		Goto Top 
		Browse nowait
	EndIf
	Return nReturnValue		
Endproc
*------
Procedure ExcelToDbf
	Lparameters nExcel_Handle	
	Local nSelect
	nSelect=Select()
	nExcel_Handle=Int(DefNumber(nExcel_Handle))
	If ExcelGetSheets(nExcel_Handle)<=0 Then
		Return 0
	EndIf	
	
	Local nReturnValue,cConnectString,cExcelFilePath,cExcelFname,cSheetName,cDbfName,cCommand,cTmpAlias
	Store 0 To nReturnValue
	cConnectString=Sqlgetprop(nExcel_Handle,"ConnectString")
	cExcelFilePath=Alltrim(Strextract(cConnectString,'DBQ=',';',1,1))
	cExcelFname=StrRecombile(JustStem(cExcelFilePath),' ','_')
	
	Select SqlResult
	Scan
		cSheetName='__'+String_DelSpecial(Alltrim(SqlResult.Table_Name),'\/:*?"<>|')
		cDbfName=cExcelFname+cSheetName
		cTmpAlias=AliasName()
		cCommand='Select * from ['+Alltrim(SqlResult.Table_Name)+'$]'
		If SqlExec(nExcel_Handle,cCommand,cTmpAlias)>0 Then
			If Not IsNullTable(cTmpAlias) Then
				cDbfName=CursorToDbf(cTmpAlias,cDbfName)
				If Not Empty(cDbfName) Then
					nReturnValue=nReturnValue+1
					LcStructure(cDbfName)
					cBakFile=Addbs(Set('Directory'))+cDbfName+'.Bak'
					If File(cBakFile) Then
						Delete File (cBakFile)
					EndIf
					cTbkFile=Addbs(Set('Directory'))+cDbfName+'.Tbk'
					If File(cTbkFile) Then
						Delete File (cTbkFile)
					EndIf
				EndIf
			EndIf
			LcDbfClose(cTmpAlias)
		EndIf
		Select SqlResult
	EndScan
	If nReturnValue>0 Then
		LcDbfClose('SqlResult')
	EndIf
	If nSelect>0 Then
		Select (nSelect)
	EndIf
	Return nReturnValue
Endproc
*------
Procedure CursorToDbf
	Lparameters cCursorName,cDbfName
	If IsValidStr(cCursorName) Then
		If Select(cCursorName)<0 Then
			cCursorName=''
		EndIf
	Else
		cCursorName=GetAlias()
	EndIf
	If Empty(cCursorName) Then
		Return .F. && Can not found any cursor to dispose now
	EndIf
	cDbfName=DefCharacters(cDbfName,cCursorName)
	Local nSelect,cSet_Safety,cErrorMsg,cReturnValue
	cSet_Safety=Set("Safety")
	Set Safety off
	nSelect=Select()
	Select (cCursorName)
	cErrorMsg=.Null.
	cReturnValue=''
	Try
		Copy To (cDbfName)
	Catch to cErrorMsg
		&& If error has be found, it will run this code
	Finally
		If IsNull(cErrorMsg) Then
			cReturnValue=cDbfName
		EndIf
	EndTry
	Set Safety &cSet_Safety.
	If Select(nSelect)>0 Then
		Select (nSelect)
	EndIf
	Return cReturnValue	
EndProc
*------
Procedure IsNullRecord
	Lparameters cAlias
	If IsValidStr(cAlias) Then
		If Select(cAlias)<=0 Then
			cAlias=''
		EndIf
	Else
		cAlias=GetAlias()
	EndIf
	If Empty(cAlias) or Eof(cAlias) or Bof(cAlias) Then
		Return .F. && Can not found any table to dispose now
	EndIf
	Local nSelect,nFcount,nTag,cFieldName,lFoundNull
	nSelect=Select()
	Select (cAlias)
	nFcount=Fcount(cAlias)
	lFoundNull=.T.
	For nTag=1 to nFcount
		cFieldName=Field(nTag,cAlias)
		If Not IsNull(&cFieldName.) Then
			lFoundNull=.F.
			Exit
		EndIf
	EndFor
	If Select(nSelect)>0 Then
		Select (nSelect)
	EndIf
	Return lFoundNull
EndProc
*------
Procedure IsNullTable
	Lparameters cAlias,lRestoreRecord
	If IsValidStr(cAlias) Then
		If Select(cAlias)<=0 Then
			cAlias=''
		EndIf
	Else
		cAlias=GetAlias()
	EndIf
	If Empty(cAlias) Then 
		Return .F. && Can not found any table to dispose now
	EndIf
	lRestoreRecord=DefLogic(lRestoreRecord)
	Local nSelect,nRecord,lNotNullRecord
	nSelect=Select()
	nRecord=Iif(Eof(cAlias),0,Recno(cAlias))
	lNotNullRecord=.T.
	Select (cAlias)
	Scan
		If Not IsNullRecord(cAlias) Then
			lNotNullRecord=.F.
			Exit
		EndIf
	EndScan
	If lRestoreRecord and Not Empty(nRecord) Then
		Goto nRecord in (cAlias)
	EndIf
	If Select(nSelect)>0 Then
		Select (nSelect)
	EndIf
	Return lNotNullRecord
EndProc
*------
Procedure IsEmptyRecord && Test
	Lparameters cAlias
	If IsValidStr(cAlias) Then
		If Select(cAlias)<=0 Then
			cAlias=''
		EndIf
	Else
		cAlias=GetAlias()
	EndIf
	If Empty(cAlias) or Eof(cAlias) or Bof(cAlias) Then
		Return .F. && Can not found any table to dispose now
	EndIf
	Local nSelect,nFcount,nTag,cFieldName,lEmptyFieldValue
	nSelect=Select()
	Select (cAlias)
	nFcount=Fcount(cAlias)
	lEmptyFieldValue=.T.
	For nTag=1 to nFcount
		cFieldName=Field(nTag,cAlias)
		If InList(Type(cFieldName),Upper('C'),Upper('M')) Then
			If Empty(Alltrim(&cFieldName.)) or IsNull(&cFieldName.) or IsBlank(&cFieldName.) Then && Empty
				Loop
			Else
				lEmptyFieldValue=.F.
				Exit
			EndIf
		Else
			If IsBlank(&cFieldName.) Then
				Loop
			Else
				lEmptyFieldValue=.F.
				Exit
			EndIf
		EndIf
	EndFor
	If Select(nSelect)>0 Then
		Select (nSelect)
	EndIf
	Return lEmptyFieldValue
EndProc
*------
Procedure Get_Fields
	Lparameter GET_TYPE,GET_SIZE,GET_ALIAS,GET_AUTOCLOSE,lReturnEmpty
	lReturnEmpty=DefLogic(lReturnEmpty)
	Local GET_SELECT , GET_RETURN , TEMP_FIELD , TEMP_FIELDVALUE , TEMP_TYPEEXPRESSION ,  ;
		TEMP_SIZEEXPRESSION , GET_CONTROL
	GET_SELECT = Select()
	If Vartype(GET_ALIAS) <> 'C' .Or. Empty(GET_ALIAS)
		If Empty(Alias())
			Wait Window Nowait 'Please sure the table opened in current select !'
			Return ''
		Else
			GET_ALIAS = Alias()
		Endif
	Else
		If Select(GET_ALIAS) = 0
			If Iif('.DBF' $ Upper(GET_ALIAS),File(GET_ALIAS),File(GET_ALIAS + '.DBF'))
				LcDbfOpen(GET_ALIAS,GET_ALIAS)
			Else
				Wait Window Nowait 'Can not find the table ' + "'"+GET_ALIAS+"'"
				Return ''
			Endif
		Endif
	Endif
	Select (GET_ALIAS)
	Local GET_PLUS
	GET_PLUS=','
	If  .Not. IS_CHARACTER(GET_TYPE)
		GET_TYPE = 'A'
	Else
		GET_TYPE = UTRIM(GET_TYPE)
	Endif
	GET_SIZE = UTRIM(GET_SIZE)
	If  .Not. (Left(UTRIM(GET_SIZE),1) $ '=><') And IS_CHARACTER(GET_SIZE)
		GET_SIZE = '=' + UTRIM(GET_SIZE)
	Endif
	GET_RETURN = ''
	For GET_CONTROL = 1 To Afields(TEMPARRAY,GET_ALIAS)
		TEMP_FIELD = TEMPARRAY(GET_CONTROL,1)
		TEMP_FIELDTYPE = TEMPARRAY(GET_CONTROL,2)
		TEMP_TYPEEXPRESSION = "'" + GET_TYPE + "'" + '==' + "'" + TEMP_FIELDTYPE + "'"
		TEMP_SIZEEXPRESSION = UTRIM(Str(TEMPARRAY(GET_CONTROL,3))) + UTRIM(GET_SIZE)
		If 'AND' $ TEMP_SIZEEXPRESSION
			TEMP_SIZEEXPRESSION =  ;
				STRTRAN(TEMP_SIZEEXPRESSION,'AND','AND ' + UTRIM(Str(TEMPARRAY(GET_CONTROL,3))))
		Endif
		If 'OR' $ TEMP_SIZEEXPRESSION
			TEMP_SIZEEXPRESSION =  ;
				STRTRAN(TEMP_SIZEEXPRESSION,'OR','OR ' + UTRIM(Str(TEMPARRAY(GET_CONTROL,3))))
		Endif
		If  .Not. GET_TYPE == 'A'
			If Not (&TEMP_TYPEEXPRESSION.) Then
				Loop
			Endif
		Endif
		If  .Not. Empty(GET_SIZE)
			If Not (&TEMP_SIZEEXPRESSION.)
				Loop
			Endif
		Endif
		If Empty(GET_RETURN)
			GET_RETURN = TEMP_FIELD
		Else
			GET_RETURN = GET_RETURN + GET_PLUS + TEMP_FIELD
		Endif
	Endfor
	If Vartype(GET_AUTOCLOSE) <> 'L'
		GET_AUTOCLOSE = .F.
	Endif
	If GET_AUTOCLOSE
		LcDbfClose(GET_ALIAS)
	EndIf
	
	If Empty(GET_RETURN)
		If lReturnEmpty Then
			Return ''
		Else
			Return ALLFIELDS(GET_PLUS) && The default value
		EndIf
	Else
		Return GET_RETURN
	Endif
Endproc
*------
Procedure ALLFIELDS
	Lparameter ALLFIELDS_PLUS , ALLFIELDS_ALIAS
	Local ALLFIELDS_SELECT , ALLFIELDS_CONTROL , ALLFIELDS_RETURN
	ALLFIELDS_SELECT = Select()
	ALLFIELDS_ALIAS = LC_ALIAS(ALLFIELDS_ALIAS)
	If  .Not. IS_CHARACTER(ALLFIELDS_ALIAS)
		Return ''
	Endif
	If Vartype(ALLFIELDS_PLUS) <> 'C'
		ALLFIELDS_PLUS = ','
	Endif
	ALLFIELDS_RETURN = Field(1,ALLFIELDS_ALIAS)
	For ALLFIELDS_CONTROL = 2 To Fcount(ALLFIELDS_ALIAS)
		ALLFIELDS_RETURN =  ;
			ALLFIELDS_RETURN + ALLFIELDS_PLUS + Field(ALLFIELDS_CONTROL,ALLFIELDS_ALIAS)
	Endfor
	If ALLFIELDS_SELECT > 0
		Select (ALLFIELDS_SELECT)
	Endif
	Return ALLFIELDS_RETURN
Endproc
*------
Procedure LC_ALIAS
	Lparameter LC_ALIAS_DBF
	Local LC_ALIAS_SELECT
	LC_ALIAS_SELECT = Select()
	If Vartype(LC_ALIAS_DBF) = 'C' And IS_CHARACTER(LC_ALIAS_DBF)
		If Select(LC_ALIAS_DBF) > 0
			Return LC_ALIAS_DBF
		Else
			If Iif('.DBF' $ Upper(LC_ALIAS_DBF),File(LC_ALIAS_DBF),File(LC_ALIAS_DBF + '.Dbf')) And  ;
					LcDbfOpen(LC_ALIAS_DBF,LC_ALIAS_DBF)
				If LC_ALIAS_SELECT > 0
					Select (LC_ALIAS_SELECT)
				Endif
				Return LC_ALIAS_DBF
			Else
				If LC_ALIAS_SELECT > 0
					Select (LC_ALIAS_SELECT)
				Endif
				Return ''
			Endif
		Endif
	Else
		If Empty(Alias())
			Return ''
		Else
			Return Alias()
		Endif
	Endif
Endproc
*------
Procedure IS_CHARACTER
	Lparameter CHARACTER_VALUE
	If Vartype(CHARACTER_VALUE) <> 'C'
		CHARACTER_VALUE = ''
	Endif
	If Chr(10) $ CHARACTER_VALUE .Or. Chr(13) $ CHARACTER_VALUE
		Return .T.
	Else
		If Vartype(CHARACTER_VALUE) = 'C' And  .Not. Empty(CHARACTER_VALUE)
			Return .T.
		Else
			Return .F.
		Endif
	Endif
Endproc
*------
Procedure UTRIM
	Lparameter UTRIM_VALUE
	If Vartype(UTRIM_VALUE) = 'C' And  .Not. Empty(UTRIM_VALUE)
		Return Alltrim(Upper(UTRIM_VALUE))
	Else
		Return ''
	Endif
Endproc
&& Spark Finished


&& Roger Start
*------
Procedure LcGetValue
	Lparameter CTEMPVALUE , CTEMPFIELD , CTEMPORDER , CTEMPDBF , LAUTOCLOSE , lMessage_Off
	
	If Vartype(CTEMPVALUE) = Upper('C') and Empty(CTEMPVALUE) Then
		Return ''
	EndIf
	
	If Empty(CTEMPORDER)
		Wait Window Nowait 'Please set the order value first!'
		Return .F.
	Endif
	If Empty(CTEMPFIELD)
		Wait Window Nowait  ;
			'Please set the field name which field value do you want to return first!'
		Return .F.
	EndIf
	lMessage_Off = DefLogic(lMessage_Off)
	
	Local CRETURNVALUE , CCURRENTSELECT , CTEMPALIAS , LUSECURRENTDBF
	LUSECURRENTDBF = .F.
	CRETURNVALUE = ''
	CCURRENTSELECT = Select()
	If Empty(CTEMPDBF) .Or. Vartype(CTEMPDBF) <> 'C'
		If Empty(Alias())
			Messagebox('There is no table opened !',48,'Warning')
			Return .F.
		Else
			LUSECURRENTDBF = .T.
			CTEMPALIAS = Alias()
		Endif
	Else
		If  .Not. Upper('.Dbf') $ Upper(CTEMPDBF)
			CTEMPDBF = CTEMPDBF + '.Dbf'
			If  .Not. File(CTEMPDBF)
				If Messagebox('Can not find the table ' + CTEMPDBF + ' ,Do you want to select it by yourself !',180,'Warning') =  ;
						6
					CTEMPDBF = Getfile('DBF')
					If Empty(CTEMPDBF)
						Return .F.
					Endif
				Endif
			Endif
		Endif
		CTEMPALIAS = AliasName()
		If  .Not. LcDbfOpen(CTEMPDBF,CTEMPALIAS,.F.)
			Wait Window Nowait 'The file of ' +"'"+ CTEMPDBF+"'" + ' can not be opened !'
			Return .F.
		Endif
	Endif
	If  .Not. Indexseek(CTEMPVALUE,.T.,CTEMPALIAS,CTEMPORDER)
		If Not lMessage_Off Then
			Wait Window Nowait  ;
				'Can not found the value ' + CTEMPVALUE + ' in table ' + "'"+Dbf(CTEMPALIAS)+"'" +  ;
				' order by ' + CTEMPORDER
		EndIf
	Else
		CRETURNVALUE = CTEMPALIAS + '.' + CTEMPFIELD
		CRETURNVALUE=&CRETURNVALUE.
	Endif
	If LAUTOCLOSE
		LcDbfClose(CTEMPALIAS)
	Endif
	If CCURRENTSELECT > 0
		Select (CCURRENTSELECT)
	Endif
	Return CRETURNVALUE
Endproc
*------
Procedure GenNth_Dtl
	Lparameter CTEMPVALUE , CORDER , CTABLE , CPRODUCT_ID , CTABLEDTL , CRETURNFIELD
	If Empty(CTEMPVALUE) .Or. Empty(CORDER) .Or. Empty(CTABLE) .Or. Empty(CPRODUCT_ID) .Or.  ;
			EMPTY(CTABLEDTL) .Or. Empty(CRETURNFIELD)
		Return 0
	EndIf
	Local CCURRENTSELECT , NRETURNVALUE , CTEMPALIAS , CTEMPDTLALIAS , CSETDELETED
	CSETDELETED = Set('Deleted')
	Set Deleted On
	CCURRENTSELECT = Select()
	NRETURNVALUE = 0
	CTEMPALIAS = AliasName()
	CTEMPDTLALIAS = AliasName()
	LcDbfOpen(CTABLEDTL,CTEMPDTLALIAS,.F.)
	If LcDbfOpen(CTABLE,CTEMPALIAS,.F.)
		Select &CTEMPALIAS.
		Set Order To &CORDER.
		Select (CCURRENTSELECT)
		If  .Not. Seek(CTEMPVALUE,CTEMPALIAS)
			Wait Window  ;
				'Can not found the value ' + CTEMPVALUE + ' in table ' +"'"+ Dbf(CTEMPALIAS)+"'" +  ;
				' order by ' + CORDER
		Else
			*!*				If  .Not. Seek(Upper(Alltrim(CTEMPVALUE) + CPRODUCT_ID),CTEMPDTLALIAS,'Item_Code')
			Select &CTEMPALIAS.
			Replace ITEMS With ITEMS + 0.001
			NRETURNVALUE = ITEMS
			*!*				Else
			*!*					Select &CTEMPDTLALIAS.
			*!*					NRETURNVALUE=&CRETURNFIELD.
			*!*				Endif
		Endif
		LcDbfClose(CTEMPALIAS)
	Else
		Wait Window Nowait 'Can not open table ' + "'"+CTABLE+"'"
	Endif
	LcDbfClose(CTEMPDTLALIAS)
	If CCURRENTSELECT > 0
		Select (CCURRENTSELECT)
	Endif
	Set Deleted &CSETDELETED.
	Return NRETURNVALUE
Endproc
*------
Procedure LcStructure
	Lparameters cTable
	cTable=DefCharacters(cTable,GetAlias())
	Local LcTempAlias,nSelect,LcControl,cFcount,TempCmd
	nSelect=Select()
	LcTempAlias=AliasName()
	If  Not IsValidStr(cTable) or Not LcDbfOpen(cTable,LcTempAlias,.T.) Then
		Waitwindow ('Please sure the table of '+"'"+cTable+"'"+' exist and can open exclusive !',Sys(16))
		Return .F.
	EndIf
		
	Select (LcTempAlias)
	cFcount=Fcount(LcTempAlias)
	For LcControl=1 to cFcount
		Select (LcTempAlias)
		TempFieldName=Field(LcControl,LcTempAlias)
		If InList(Type(TempFieldName),Upper('C'),Upper('M')) Then
			Select Max(Len(Alltrim(&TempFieldName))) from (LcTempAlias) into Array TempArray
			If IsNull(TempArray) or Empty(TempArray) Then
				TempCmd='Alter table (LcTempAlias) drop '+TempFieldName
				Local lErrorFound
				lErrorFound=.F.
				Try 
					&TempCmd.
				Catch
					lErrorFound=.T.
				EndTry
				If Not lErrorFound Then && There have been remove a field
					LcControl=LcControl-1
					cFcount=cFcount-1
				EndIf
			Else
				If TempArray>254 Then
					Loop
				Else
					If TempArray<254 Then
						TempArray=TempArray+1
					EndIf && If =254 ,No need any dispose
				EndIf
				TempCmd=[Alter Table (LcTempAlias) Alter Column &TempFieldName.]+Space(1)+'C('+Alltrim(Str(TempArray))+')'
				&TempCmd.			
			EndIf
		Else
			If Type(TempFieldName)=Upper('N') Then
*!*					Alter Table (LcTempAlias) Alter Column &TempFieldName. N (20,4)
			EndIf
		EndIf
	EndFor
	LcDbfClose(LcTempAlias)
	If nSelect>0 Then
		Select (nSelect)
	EndIf
	Return .T.
EndProc
*------
Procedure Gb2Convert()
	Lparameters cText,nConvert,lRelease
	&& if nConvert=1 then convert GbK to GbW, else if nConvert=0 or 2 then gb2 to GbK
	Local cReturnValue
	cReturnValue=''
	If Vartype(cText)<>'C' OR Empty(cText) Then
		Return ''
	EndIf
	If Vartype(nConvert)<>'N' Then
		Return ''
	Else
		If nConvert>=0 and nConvert<=2 Then
			If Abs(nConvert)<>1 Then
				nConvert=0
			Else
				nConvert=1
			EndIf
		Else
			Return ''
		EndIf
	EndIf

	If nConvert=1 Then
		nConvert=0
	Else
		nConvert=1
	EndIf

	If Vartype(oWord)='U' Then
		Public oWord
		oWord=CreateObject('Word.Application')
	EndIf
	*!*	oWord.Visible=.T.
	TempCount=oWord.Documents.Count
	If TempCount=0 Then && No Document added
		oWord.Documents.Add()
	EndIf


	oWord.Selection.Text=cText
	oWord.Selection.Range.TcscConverter(nConvert,.T.,.T.)
	cReturnValue=oWord.Selection.Text
	If lRelease Then
		oWord.ActiveWindow.Close(0) && No ask you if do you want to save it before close
		Release oWord
	EndIf
	Return cReturnValue
EndProc
*------
Procedure OpenFolder
	Lparameters cPath
	If Vartype(cPath)<>'C' or Not Directory(cPath)Then
		cPath=Set('Directory')
	EndIf
	Run/n Explorer &cPath
EndProc
*------
Procedure CompileMenus
	TempMenu=Set('Directory')+'\Menus\Main.Mpr'
	If File(TempMenu) Then
		Compile &TempMenu.
	EndIf

	TempMenu=Set('Directory')+'\Menus\MainChi.Mpr'
	If File(TempMenu) Then
		Compile &TempMenu.
	EndIf

	TempMenu=Set('Directory')+'\Menus\MainChs.Mpr'
	If File(TempMenu) Then
		Compile &TempMenu.
	EndIf
EndProc
*------
Procedure LcAddExt()
	Lparameters cFileName,cExtension
	If Vartype(cFileName)<>'C' OR Empty(Alltrim(cFileName)) Then
		Wait window 'Please sure the filename not empty and in characters !' nowait
		Return ''
	EndIf
	If Vartype(cExtension)<>'C' OR Empty(Alltrim(cExtension)) Then
		Wait window 'Please sure the cExtension expression not not empty and in characters ! ' nowait
		Return cFileName
	EndIf
	Return ForceExt(Alltrim(cFileName),Alltrim(cExtension))
EndProc
*------
Procedure LcFind()
	Lparameters cTempValue,cTempTable,lForce,lFoundOnce
	Local cTempAlias,nTempSelect,cListValue
	nTempSelect=Select()
	If Vartype(cTempValue)<>'C' Then
		Wait window 'Please send the value can as type as memo or character!' nowait
		Return .F.
	EndIf
	If Vartype(lForce)<>'L' Then
		Wait window 'Please send the if ignore lower or upper characte value in logic!' nowait
		Return .F.
	EndIf
	If Vartype(cTempTable)<>'C' Or Empty(Alltrim(cTempTable)) Then
		If Empty(Alias()) Then
			Wait window 'There is no table select !' nowait
			Return .F.
		Else
			cTempAlias=Alias()
		EndIf
	Else
		cTempAlias=JustStem(cTempTable)
		If Select(Alltrim(cTempAlias))=0 Then
			If Not LcDbfOpen(cTempTable,cTempAlias) Then
				Wait window 'Can not open table '+"'"+cTempTable+"'" nowait
				Return .F.
			EndIf
		EndIf
	EndIf
	If Vartype(lFoundOnce)<>'L' Then
		lFoundOnce=.F.
	EndIf
	cListValue=''
	Select (cTempAlias)
	Set Filter To
	If Not lFoundOnce Then
		Scan
			For LcControl=1 to Fcount(cTempAlias)
				cTempField=Field(LcControl,cTempAlias)
				If Not InList(Vartype(&cTempField.),'C','M')Then
					Loop
				EndIf
				lTempFound=.F.
				If lForce Then
					If cTempValue $ &cTempField. Then
						lTempFound=.T.
					EndIf
				Else
					If Upper(Alltrim(cTempValue)) $ Upper(Alltrim(&cTempField.)) Then
						lTempFound=.T.
					EndIf
				EndIf
				If lTempFound Then
					If 'RECNO()='+Alltrim(Str(Recno()))$Upper(cListValue) Then
						cListValue=cListValue+','+Left(cTempField,1)+Lower(Right(cTempField,Len(cTempField)-1))
					Else
						If Empty(cListValue) Then
							cListValue='Recno()='+Alltrim(Str(Recno()))+','+Left(cTempField,1)+Lower(Right(cTempField,Len(cTempField)-1))
						Else
							cListValue=cListValue+Chr(10)+'Recno()='+Alltrim(Str(Recno()))+','+Left(cTempField,1)+Lower(Right(cTempField,Len(cTempField)-1))
						EndIf
					EndIf
				EndIf
			EndFor
		EndScan
	Else
		Scan
			lTempExit=.F.
			For LcControl=1 to Fcount(cTempAlias)
				cTempField=Field(LcControl,cTempAlias)
				If Not InList(Vartype(&cTempField.),'C','M')Then
					Loop
				EndIf
				lTempFound=.F.
				If lForce Then
					If cTempValue $ &cTempField. Then
						lTempFound=.T.
					EndIf
				Else
					If Upper(Alltrim(cTempValue)) $ Upper(Alltrim(&cTempField.)) Then
						lTempFound=.T.
					EndIf
				EndIf
				If lTempFound Then
					If 'RECNO()='+Alltrim(Str(Recno()))$Upper(cListValue) Then
						cListValue=cListValue+','+Left(cTempField,1)+Lower(Right(cTempField,Len(cTempField)-1))
					Else
						If Empty(cListValue) Then
							cListValue='Recno()='+Alltrim(Str(Recno()))+','+Left(cTempField,1)+Lower(Right(cTempField,Len(cTempField)-1))
						Else
							cListValue=cListValue+Chr(10)+'Recno()='+Alltrim(Str(Recno()))+','+Left(cTempField,1)+Lower(Right(cTempField,Len(cTempField)-1))
						EndIf
					EndIf
					lTempExit=.T.
					Exit
				EndIf
			EndFor
			If lTempExit Then
				Exit
			EndIf
		EndScan
	EndIf
	cListValue=cListValue
	If Not Empty(cListValue) Then
		Local cFilter,cFields,cRowExpression
		For LcControl=1 to Occurs(Chr(10),cListValue)+1
			cRowExpression=ItSubstr(cListValue,Chr(10),LcControl)
			If Empty(cFilter) Then
				cFilter=ItSubstr(cRowExpression,',',1)
			Else
				cTempFilter=cFilter+'.or.'+ItSubstr(cRowExpression,',',1)
				If Len(cTempFilter)<550 Then
					cFilter=cFilter+'.or.'+ItSubstr(cRowExpression,',',1)
				EndIf
			EndIf
			If Empty(cFields) Then
				cFields=Right(cRowExpression,Len(cRowExpression)-Len(ItSubstr(cRowExpression,',',1))-1)
			Else
				cFields=cFields+Right(cRowExpression,Len(cRowExpression)-Len(ItSubstr(cRowExpression,',',1)))
			EndIf
		EndFor
		?cListValue+Chr(10)
		cFields=Field(1)+','+cFields
		Set Filter To &cFilter.
		Goto Top
		Wait Clear
		Browse Fields &cFields. Nowait
		Return .T.
	Else
		Return .F.
	EndIf
EndProc
*------
Procedure TwoDelete()
	Lparameters cKey,cTable,cIndexKey,llike,lDeleteAll
	If Vartype(cIndexKey)<>'C' Or Empty(Alltrim(cIndexKey)) Then
		Wait window 'Please sure the index expression in character and not empty !' nowait
		Return .F.
	EndIf
	Local cAlias,nSelect,lReturn,cFieldValue,cSetDeleted
	cSetDeleted=Set("Deleted")
	nSelect=Select()
	If Empty(cTable) Then
		If Not Empty(Alias()) Then
			cAlias=Alias()
			cTable=cAlias
		Else
			Wait window 'Please sure there have table opened !' nowait
			Return .F.
		EndIf
	Else
		If Select(cTable)=0 Then
			cAlias=AliasName()
			If Not LcDbfOpen(cTable,cAlias,cIndexKey) Then
				Wait window 'Can not open the table '+"'"+cTable+"'" nowait
				Return .F.
			EndIf
		Else
			cAlias=JustStem(cTable)
			cTable=cAlias
		EndIf
	EndIf
	If Vartype(lDeleteAll)<>'L' Then
		lDeleteAll=.F.
	EndIf
	If Vartype(lLike)<>'L' Then
		lLike=.F.
	EndIf
	lReturn=.F.

	Set Deleted on
	Select (cAlias)
	If Not Tagno(cIndexKey)=0 Then
		Set Order To &cIndexKey.
		If lLike Then && 'a'='b'
			Seek(cKey)
			Do while Found() and Not Eof()
				lReturn=.T.
				Delete
				If Not lDeleteAll Then
					Exit
				EndIf
				Skip
				Seek(cKey)
			EndDo
		Else && 'a'=='b'
			cFieldValue=Sys(14,Tagno(cIndexKey))
			Seek(cKey)
			Do while Found() and cKey==&cFieldValue. and Not Eof()
				lReturn=.T.
				Delete
				If Not lDeleteAll Then
					Exit
				EndIf
				Skip
				Seek(cKey)
			EndDo
		EndIf
	EndIf
	If cAlias<>cTable Then
		LcDbfClose(cAlias)
	EndIf
	Select (nSelect)
	Set Deleted &cSetDeleted.
	Return lReturn
EndProc
*------
Procedure LcStockMessage()
	Lparameters cTempValue,cType,cCondition,cExpr
	If Vartype(cTempValue)<>'C' or Empty(Alltrim(cTempValue)) Then
		Return ''
	EndIf
	If Vartype(cType)<>'C' or Not InList(Upper(Alltrim(cType)),'SDN','CDN') Then
		cType='CDN' && Default
	EndIf
	cType=Upper(Alltrim(cType))
	If Vartype(cCondition)<>'C' Then
		cCondition='1<2' && Default value is .T.
	EndIf
	Local cAlias,cReturn,cOrder,nSelect,cTempFieldValue,cTagExp
	If cType='CDN' Then
		cOrder='CDN_Key'
	Else
		cOrder='Sdn_Key'
	EndIf

	If Vartype(cExpr)<>'C' Or Empty(cExpr) Then
		cExpr=''
	EndIf

	cReturn=''
	cTempFieldValue=''
	cAlias=AliasName()
	nSelect=Select()
	If Not LcDbfOpen('CdnGrn',cAlias,.F.,cOrder) or Not Seek(cTempValue,cAlias) or Not (&cCondition.) Then
		LcDbfClose(cAlias)
		Select (nSelect)
		Return ''
	EndIf
	Select (cAlias)
	cTagExp=Sys(14,Tagno(Order()))
	Scan Rest For &cTagExp.=cTempValue and &cCondition. and Not Eof()
		If Empty(cExpr) Then
			If cType='CDN' Then
				cTempFieldValue=PadR(Sdn_ID,21,' ')+PadR(ItTransFormCurr(Quantity,0),15,' ')+Padr(Lot_NO,21,' ')
			Else
				cTempFieldValue=PadR(Cdn_ID,21,' ')+PadR(ItTransFormCurr(Quantity,0),15,' ')+Padr(Lot_NO,21,' ')
			EndIf
			If Empty(cReturn) Then
				cReturn=cTempFieldValue
			Else
				cReturn=cReturn+Chr(13)+Chr(10)+cTempFieldValue
			EndIf
		Else
			cTempFieldValue=&cExpr.
			If Empty(cReturn) Then
				cReturn=&cExpr.
			Else
				cReturn=cReturn+Chr(13)+Chr(10)+&cExpr.
			EndIf
		EndIf
	EndScan
	LcDbfClose(cAlias)
	Select (nSelect)
	Return cReturn
EndProc
*------
Procedure LcReport
	Lparameters cName,cType,lClose
	If Vartype(cName)<>'C' Or Empty(cName)  Then
		Wait window 'Please type the report name first!' nowait
		Return .F.
	EndIf
	If Vartype(cType)<>'N' Or Empty(cType) or Not InList(cType,1,2) Then
		Wait WINDOW 'Please type the value in 1 or 2 !' nowait
		Return .F.
	EndIf
	If Vartype(lClose)<>'L' Then
		lClose=.F.
	EndIf
	Local nSelect,cAlias
	nSelect=Select()
	cName=ForceExt(cName,'Frx')
	cAlias=JustStem(cName)
	If Not LcDbfOpen(cName,cAlias) Then
		Wait window 'Can not open the report of '+"'"+cName+"'" nowait
		Select (nSelect)
		Return .F.
	EndIf
	Select (cAlias)

	Set Filter To Not IsAlpha(Alltrim(Expr)) And ; && The first value not in (a,b,c,d,e……z)
	Not IsDigit(Alltrim(Expr)) And ; && The first value not in (0,1,2,3,4……9)
	InList(Asc(Alltrim(Expr)),34,39,91) Or; && The first asc in 34("),39('),91([)
	IsLeadByte(Alltrim(Expr))

	Replace Expr with GbConvert(Expr,cType) All

	If lClose Then
		LcDbfClose(cAlias)
	Else
		Browse Fields Expr nowait
	EndIf
	Return .T.
EndProc
*------
Procedure LcFieldLink		&&...
	lPARAMETERS vKeyValue,vTable,vTag,vKeyField,vLinkField,vSeparate,vOnlyType
	&& Get Container No from Packlst
	&& For  RJS
	&& SZFieldLink(invmastR.inv_id,'Packlst_ctnNo','inv_id','inv_id','container',' / ',.t.)
	LOCAL RTvalue,lselectdbf,ltag,cTableAlias
	cTableAlias=AliasName()
	lselectdbf = SELECT()
	RTvalue= ''
	If Not LcDbfOpen(vTable,cTableAlias) Then
		Return ''
	EndIf
	SELECT (cTableAlias)
	SET ORDER TO vTag
	IF !SEEK(vKeyValue,cTableAlias)
		LcDbfClose(cTableAlias)
		SELECT (lselectdbf )
		RETURN  RTvalue
	ENDIF
	SCAN REST WHILE &vKeyField. == vKeyValue
		IF EMPTY(&vLinkField.)
			LOOP
		ENDIF
		IF ALLTRIM(&vLinkField.) $ RTvalue AND vOnlytype
			LOOP
		ENDIF
		RTvalue = RtValue +IIF(EMPTY(RtValue),'', vSeparate)+ALLTRIM(&vLinkField.)
	ENDSCAN
	LcDbfClose(cTableAlias)
	SELECT (lselectdbf )
	RETURN  RTvalue
EndProc
*------
Procedure DbfGb2
	Lparameters cTable,nType
	Local cAlias,nControl,cFieldName,nSelect
	nSelect=Select()
	cAlias=AliasName()
	If Not LcDbfOpen(cTable,cAlias) Then
		Return .F.
	EndIf
	Select (cAlias)
	For nControl=1 to Fcount(cAlias)
		cFieldName=Field(nControl,cAlias)
		If Not InList(Vartype(Evaluate(cFieldName)),'C','M') Then
			Loop
		EndIf
		Replace (cFieldName) with Gb2Convert(Evaluate(cFieldName),nType) All
	EndFor
	Gb2Convert('a',2,.T.) && Skill the winword.exe process
	LcDbfClose(cAlias)
	Select (nSelect)
	Return .T.
EndProc
*------
Procedure DbfGb
	Lparameters cTable,nType
	Local cAlias,nControl,cFieldName,nSelect
	nSelect=Select()
	cAlias=AliasName()
	If Not LcDbfOpen(cTable,cAlias) Then
		Return .F.
	EndIf
	Select (cAlias)
	For nControl=1 to Fcount(cAlias)
		cFieldName=Field(nControl,cAlias)
		If Not InList(Vartype(Evaluate(cFieldName)),'C','M') Then
			Loop
		EndIf
		Replace (cFieldName) with GbConvert(Evaluate(cFieldName),nType) All
	EndFor
	Gb2Convert('a',2,.T.) && Skill the winword.exe process
	LcDbfClose(cAlias)
	Select (nSelect)
	Return .T.
EndProc
*------
Procedure GetPrimaryKey
	Lparameters cTable,lAutoClose
	If Vartype(lAutoClose)<>Upper('L') Then
		lAutoClose=.F. && The default value
	EndIf
	Local cAlias,lFound,cReturn,nSelect
	nSelect=Select()
	cReturn=''
	lFound=.F.
	cAlias=GetAlias(cTable)
	If Not Empty(cAlias) Then
		Select (cAlias)
	Else
		Return ''
	EndIf
	For LcControl=1 to Tagcount()
		If Primary(LcControl) Then
			lFound=.T.
			Exit
		EndIf
	EndFor
	If lFound Then
		cReturn=Tag(LcControl)
	EndIf
	Select (nSelect)
	If lAutoClose Then
		LcDbfClose(cAlias)
	EndIf
	Return cReturn
EndProc
*------
Procedure IntColumn_ToStr && Error: IntColumn_ToStr(703) && \C , The right return value mould must be in "ABC",16384 should be "XFD"
	Lparameters nColumn_no
	
	* Question: Maybe this can 10进制 -> 26进制，26进制 -> 10进制
	HeaderChr=''
	Set Step On  && Test
	HeaderFirst=Int(nColumn_no/26)
	HeaderSecord=Mod(nColumn_no,26)
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
*------
Procedure StrColumn_ToInt
	Lparameters cColumn_no
	If Not IsValidStr(cColumn_no) Then
		Return 0
	Else
		cColumn_no=Upper(Alltrim(cColumn_no))
	EndIf
	Local nTag,nReturnValue,cTmpBitValue,nTmpBitValue
	nReturnValue=0
	For nTag=Lenc(cColumn_no) to 1 Step -1
		cTmpBitValue=Substrc(cColumn_no,nTag,1)
		If Between(Asc(cTmpBitValue),Asc(Upper('A')),Asc(Upper('Z'))) Then 
			nTmpBitValue=Asc(cTmpBitValue)-Asc(Upper('A'))+1
		Else
			nTmpBitValue=0 && If it is empty value or not between in A to Z
		EndIf
		nReturnValue=nReturnValue+nTmpBitValue*26^(Lenc(cColumn_no)-nTag)
	EndFor
	Return Int(nReturnValue)
EndProc
*------
Procedure LcKeyBoard
	On Key Label F2 wait window 'Alias()='+"'"+Alias()+"'"+Chr(13)+Chr(10)+'Dbf()='+Dbf() nowait
	On key Label F3 Do Form vin
EndProc
*------
Procedure LcHtmlAll
	Lparameters cSource,cTarget,cFileType
	If Vartype(cSource)<>'C' Or Empty(Alltrim(cSource)) Or Not Directory(cSource) Then
		cSource=Addbs(GetDir('','Source Dir'))
	EndIf
	If Empty(cSource) or Not Directory(cSource) Then
		Return .F. && If the end user can select directory or input a error directory
	Endif
	If Vartype(cTarget)<>'C' Or Empty(Alltrim(cTarget)) Or Not Directory(cTarget) Then
		cTarget=Addbs(GetDir('','Target Dir'))
	EndIf
	If Empty(cTarget) or Not Directory(cTarget) Then
		cTarget=cSource && It will get the source directory in target directory if the target directory is empty.
	EndIf
	If Vartype(cFileType)<>'C' Or Empty(Alltrim(cFileType)) Then
		cFileType='*.html' && Default file type
	EndIf

	Local _Directory
	_Directory=Set('Directory')
	Set Default To (cSource)
	Local nTotalFiles
	*!*		nTotalFiles=ADir(aTempFiles,'*.Html')
	nTotalFiles=ADir(aTempFiles,cFileType)
	If nTotalFiles=0 Then
		Set Default To &_Directory.
		Return .F. && No any html files in the source directory
	EndIf
	For LcControl=1 to nTotalFiles
		Wait window 'Processing file of '+"'"+aTempFiles(LcControl,1)+"'"+' '+Str(LcControl)+' / '+Str(nTotalFiles) Nowait
		=LHtmlToTxt(Addbs(cSource)+aTempFiles(LcControl,1),Addbs(cTarget)+ForceExt(aTempFiles(LcControl,1),''))
	EndFor
	Wait window 'Process all finished of '+Str(nTotalFiles) Nowait
	Set Default To &_Directory.
EndProc
*------
Procedure LHtmlToTxt
	Lparameters cHtml,cTxt,lAutoOpen
	If IsValidStr(cHtml) Then
		cHtml=Alltrim(cHtml)
		If Empty(JustPath(cHtml)) or Not Directory(JustPath(cHtml)) Then && Check the directory
			cHtml=Addbs(Set('Directory'))+JustFname(cHtml)
		EndIf
		If Empty(JustExt(cHtml)) Then
			cHtml=ForceExt(cHtml,'Html') && Default extension name
		EndIf
		If Not File(cHtml) Then
			Wait window 'Can not found the html file: '+"'"+cHtml+"'" nowait
			Return .F.
		EndIf
	Else
		Wait window 'Please send the html file path first !' nowait
		Return .F.
	EndIf
	If IsValidStr(cTxt) Then
		cTxt=Alltrim(cTxt)
	Else
		cTxt=DefCharacters(cTxt)
	EndIf
	If Empty(JustPath(cTxt)) or Not Directory(JustPath(cTxt)) Then
		cTxt=Addbs(JustPath(cHtml))+JustFname(cTxt)
	EndIf
	If Empty(JustStem(cTxt)) Then
		cTxt=Addbs(JustPath(cTxt))+JustStem(cHtml)
	EndIf
	If Empty(JustExt(cTxt)) Then
		cTxt=ForceExt(cTxt,'Txt') && The default extension name
	EndIf
	lAutoOpen=DefLogic(lAutoOpen)
	If Vartype(oIE)#Upper('O') Then
		Public oIE
		oIE=CreateObject('InternetExplorer.Application')
	EndIf
	Local _Error_Handle,_Errored,cReturnValue
	_Error_Handle=On('Error')
	_Errored=.F.
	On Error _Errored=.T.
	oIE.Navigate(cHtml)
	If _Errored Then && Maybe the IE has been closed
		Release oIE && Release IE and Recreate it now
		Public oIE
		oIE=CreateObject('InternetExplorer.Application')
		oIE.Navigate(cHtml)
	EndIf
	On Error &_Error_Handle.
	Do while oIE.ReadyState # 4
		Wait window 'Loading …… '+"'"+cHtml+"'" nowait
	EndDo
	cReturnValue=oIE.Document.body.InnerText
	Local _Safety
	_Safety=Set("Safety")
	Set Safety off
	StrToFile(cReturnValue,cTxt)
	Set Safety &_Safety.
	Wait window 'Processing finished …… '+"'"+JustFname(cHtml)+"'" nowait
	Return .T.
EndProc
*!*	Procedure LHtmlToTxt
*!*		Lparameters cHtml,cTxt,lAutoOpen
*!*		If Vartype(cHtml)<>'C' or Empty(Alltrim(cHtml)) Then
*!*			Wait window 'Please send the html file path first!' nowait
*!*			Return .F.
*!*		EndIf
*!*		If Vartype(cTxt)<>'C' Or Empty(Alltrim(cTxt)) Then
*!*			cTxt=JustFname(ForceExt(cHtml,'Txt'))
*!*		EndIf
*!*		If Vartype(lAutoOpen)<>'L' Then
*!*			lAutoOpen=.F.
*!*		EndIf
*!*		If Vartype(oWord_Txt)<>'O' Then
*!*			Public oWord_Txt
*!*			oWord_Txt=CreateObject('Word.Application')
*!*		EndIf
*!*		*!*			On Error Return .F.
*!*		oWord_Txt.Documents.Open(cHtml)
*!*		oWord_Txt.Selection.WholeStory && Select all
*!*		oWord_Txt.Selection.Copy
*!*		=StrToFile(Strtran(_Cliptext,Chr(13),Chr(13)+Chr(10)),cTxt)
*!*		oWord_Txt.Documents.Close
*!*		*!*			oWord_Txt.Visible=.F.
*!*		Return .T.
*!*		If Not lAutoOpen Then
*!*			oWord_Txt.Quit
*!*			Release oWord_Txt
*!*		EndIf
*!*	EndProc
*------
Procedure GetTagWord && GetTagWord('Iloveyou!','love') && Iloveyou! ; GetTagWord('I love you!','love') && love usualy we can use this function to get email address
	Lparameters cString,cTag,nIndex,cDelimiters
	Local cReturnValue
	cReturnValue=''
	If Not IsValidStr(cString) Then
		Wait window 'Please sure the search string is not empty!' nowait
		Return cReturnValue
	EndIf
	If Not IsValidStr(cTag) Then
		Wait window 'Please input a valid string which you want to search tag .' nowait
		Return cReturnValue
	EndIf
	nIndex=DefNumber(nIndex,1)
	If nIndex=0 Then
		nIndex=1 && Default value
	EndIf
	If IsValidStr(cDelimiters,.T.) Then && Ignore cDelimiters is a empty character && If transfer a valid character
		cDelimiters=DefCharacters(cDelimiters,' ',.T.) && The default value is space, Allow you transfer a empty character instead of space
		If Atcc(cTag,cString,nIndex)>0 Then 	&& Not found
			Local cDelimiters_Start,cDelimiters_End,nStartTag,nEndTag,lStart_Found,lEnd_Found
			cDelimiters_Start = 1
			cDelimiters_End   = Lenc(cString)
			&& Calculation the delimiters start position
			For nStartTag=Atcc(cTag,cString,nIndex)-1 to 1 step -1
				cDelimiters_Start=nStartTag
				If Substrc(cString,nStartTag,1)==cDelimiters Then
					lStart_Found=.T.
					Exit
				EndIf
			EndFor
			If Not lStart_Found Then
				cDelimiters_Start=cDelimiters_Start-1 && Because the cDelimiters_start need to move left 1 bytes
			EndIf

			&& Calculation the delimiters end position
			For nEndTag=Atcc(cTag,cString,nIndex)+Lenc(cTag) to Lenc(cString)
				cDelimiters_End=nEndTag
				If Substrc(cString,nEndTag,1)==cDelimiters Then
					lEnd_Found=.T.
					Exit
				EndIf
			EndFor
			If Not lEnd_Found Then
				cDelimiters_End=cDelimiters_End+1 && Because the cDelimiters_end need to move right 1 bytes
			EndIf

			cReturnValue=Substrc(cString,cDelimiters_Start+1,((cDelimiters_End-1)-(cDelimiters_Start+1)+1))
		EndIf
	Else
		cDelimiters=DefCharacters(cDelimiters,' ',.T.) && The default value is space, Allow you transfer a empty character instead of space
		If Atcc(cTag,cString,nIndex)>0 Then 	&& Not found
			Local cDelimiters_Start,cDelimiters_End,nStartTag,nEndTag,lStart_Found,lEnd_Found
			cDelimiters_Start = 1
			cDelimiters_End   = Lenc(cString)
			&& Calculation the delimiters start position
			For nStartTag=Atcc(cTag,cString,nIndex)-1 to 1 step -1
				cDelimiters_Start=nStartTag
				If InList(Asc(Substrc(cString,nStartTag,1)),32,9,13,10) Then && SPACE,TAB,ENTER,New_Line
					lStart_Found=.T.
					Exit
				EndIf
			EndFor
			If Not lStart_Found Then
				cDelimiters_Start=cDelimiters_Start-1 && Because the cDelimiters_start need to move left 1 bytes
			EndIf

			&& Calculation the delimiters end position
			For nEndTag=Atcc(cTag,cString,nIndex)+Lenc(cTag) to Lenc(cString)
				cDelimiters_End=nEndTag
				If InList(Asc(Substrc(cString,nEndTag,1)),32,9,13,10) Then && SPACE,TAB,ENTER,New_Line
					lEnd_Found=.T.
					Exit
				EndIf
			EndFor
			If Not lEnd_Found Then
				cDelimiters_End=cDelimiters_End+1 && Because the cDelimiters_end need to move right 1 bytes
			EndIf
			cReturnValue=Substrc(cString,cDelimiters_Start+1,((cDelimiters_End-1)-(cDelimiters_Start+1)+1))
		EndIf
	EndIf
	Return cReturnValue
EndProc
*------
Procedure GetWidthWords(cString,nSize_Period,nIndex,cTag,lAddLastP) && Parts write Unfinished.
	If Not IsValidStr(cString) Then
		Wait window 'Please input the string first !' nowait
		Return ''
	Else
		cString=Rtrim(cString)
		If Empty(cString) Then
			Return cString
		EndIf
	EndIf
	If Vartype(nSize_Period)<>'N' or nSize_Period<=0 Then
		Wait window nowait 'Please input the periods count or period size as number !'
		Return cString
	EndIf
	If Vartype(nIndex)<>'N' && Not input this value or input a ineficacy value
		nIndex=1 && The default value is the least period
	Else
		If nIndex=0 Then && The least period
			nIndex=1
		EndIf
	EndIf
	If Not IsValidStr(cTag,.T.) Then && Not a characters value , Deal with include the empty string such as chr(13),space
		cTag=' ' && The default value is space
	EndIf
	If Occurs(cTag,cString)=0 Then
		Return cString
	EndIf
	If Vartype(LAddLastP)<>'L' Then
		LAddLastP=.F. && Default the period index large than period count return '' else return the last period value
	EndIf
	Local nPeriodSize,nPeridCount,nControl,cTempValue,nSubTag,cSubText,lLastPeriod,nPeriodLast
	If nSize_Period >= Len(cString) Then
		*!*				Wait window nowait 'Please type the period size length less '+Alltrim(Str(Len(cString)))
		If nIndex=1 or lAddLastP Then
			Return cString
		Else
			Return ''
		EndIf
	Endif
	nPeriodCount=0
	cTempValue=''
	nPeriodLast=0
	For nControl=1 to Occurs(cTag,cString)+1
		nPeriodLast=nPeriodLast+1
		If Empty(cTempValue) Then
			cTempValue=ItSubstr(cString,cTag,nControl)
		Else
			cTempValue=cTempValue+cTag+ItSubstr(cString,cTag,nControl)
		EndIf
		If Len(cTempValue)>nSize_Period Then
			nPeriodCount=nPeriodCount+1 && Found a period,And it's will be added
			nControl=nControl-1
			nPeriodLast=nPeriodLast-1
			If nPeriodCount=nIndex Then
				Return LcSubLeft(cTempValue,nPeriodLast,cTag)
			Else
				If IsLastPeriod(cString,nSize_Period,nControl+1,cTag) Then && If the next string is the last period
					cSubText=''
					For nSubTag=nControl+1 to Occurs(cTag,cString)+1
						If Empty(cSubText) Then
							cSubText=ItSubstr(cString,cTag,nSubTag)
						Else
							cSubText=cSubText+cTag+ItSubstr(cString,cTag,nSubTag)
						EndIf
					EndFor
					If nPeriodCount+1=nIndex Then && If the next period is the last period
						Return cSubText
					Else
						If lAddLastP Then && Return last period if last peroid index large than period count
							Return cSubText
						Else
							Return '' && Because current string is the last period
						EndIf
					EndIf
				EndIf
			EndIf
			cTempValue=''
			nPeriodLast=0
		EndIf
	EndFor
	
	Return cTempValue
EndProc
*------
Procedure IsLastPeriod(cString,nPeriodSize,nStartP,cTag)
	If Not IsValidStr(cString) Then
		Wait window 'Please type the string first!' nowait
		Return ''
	EndIf
	If Vartype(nPeriodSize)<>'N' Or nPeriodSize<=0 Then
		Wait window 'Please type the period size as number and larger than 0!' nowait
		Return cString
	EndIf
	If Not IsValidStr(cTag,.T.) Then
		cTag=' '
	EndIf
	If Vartype(nStartP)<>'N' Or nStartp<=0 Or nStartp>Occurs(cTag,cString)+1 Then
		Wait window 'Please type the start period as number and less than Occurs(cTag,cString) larger than 0' nowait
		Return cString
	EndIf
	Local nTag,cTempText,lLargePSize
	For nTag=nStartp to Occurs(cTag,cString)+1
		If Empty(cTempText) Then
			cTempText=ItSubstr(cString,cTag,nTag)
		Else
			cTempText=cTempText+cTag+ItSubstr(cString,cTag,nTag)
		EndIf
		If Len(cTempText)>nPeriodSize
			Return .F. && Not the last period
		EndIf
		If Len(cTempText)=nPeriodSize
			If nTag=Occurs(cTag,cString)+1 Then
				Return .T. && It's the last period ,Because there is no string in the last
			Else
				Return .F. && Not the last period
			EndIf
		EndIf
	EndFor
	Return .T. && If can't return in that for language, Than the len(cTempText)<nPeriodSize
EndProc
*------
Procedure LcSubLeft(cString,nCount,cTag,cTagAdd)
	If Not IsValidStr(cString) Then
		Return ''
	EndIf
	If Vartype(nCount)<>'N' Then
		Wait window 'Please input the add count as number first !' nowait
		Return cString
	EndIf
	If Not IsValidStr(cTag,.T.) Then
		cTag=' ' && The default tag is space
	EndIf
	If Not IsValidStr(cTagAdd,.T.) Then
		cTagAdd=cTag
	EndIf
	If Occurs(cTag,cString)=0 Then
		Return cString
	EndIf
	If nCount<=0 or nCount>Occurs(cTag,cString)+1 Then
		nCount=Occurs(cTag,cString)+1
	EndIf
	Local nControl,cReturnValue
	cReturnValue=''
	For nControl=1 to nCount
		If Empty(cReturnValue) Then
			cReturnValue=ItSubstr(cString,cTag,nControl)
		Else
			cReturnValue=cReturnValue+cTagAdd+ItSubstr(cString,cTag,nControl)
		EndIf
	EndFor
	Return cReturnValue
EndProc
*------
Procedure IsValidStr
	Lparameters pcString,plIgnoreEmptyCharacters
	plIgnoreEmptyCharacters=DefLogic(plIgnoreEmptyCharacters)
	If plIgnoreEmptyCharacters Then
		If Vartype(pcString)==Upper('C') Then
			Return .T.
		Else
			Return .F.
		EndIf
	Else && Need to check the empty characters
		If Vartype(pcString)==Upper('C') and Not Empty(Alltrim(pcString)) Then
			Return .T.
		Else
			Return .F.
		EndIf
	EndIf
EndProc
*------
Procedure IsNumber
	Lparameters nNumber
	If Vartype(nNumber)<>Upper('N') Then
		Return .F.
	Else
		Return .T.
	EndIf
Endproc
*------
Procedure IsInclude
	Lparameters cString,cSub,cTag,lForce
	If Not IsValidStr(cString,.T.) or Not IsValidStr(cTag,.T.) or Not IsValidStr(cSub,.T.) Then
		Return .F.
	EndIf
	*!*		If Occurs(cTag,cString)=0 Then
	*!*			Return .F.
	*!*		EndIf
	lForce=DefLogic(lForce)
	Local nTag
	For nTag=1 to Occurs(cTag,cString)+1
		If lForce Then
			If ItSubstr(cString,cTag,nTag)==cSub Then
				Return .T.
			EndIf
		Else
			If uTrim(ItSubstr(cString,cTag,nTag))=uTrim(cSub) Then
				Return .T.
			EndIf
		EndIf
	EndFor
	Return .F. && Default value is .F.
EndProc
*------
Procedure IsIndexExist
	Lparameters cIndex_TagName,cDbfAlias
	
	If !IsValidStr(cIndex_TagName) Then
		Return .F.
	EndIf
	
	Local lReturnValue,nSelect,cAlias,lNeedOpen
	lReturnValue = .F.
	nSelect = Select()

	* Check the table if need to open .	
	If IsValidStr(cDbfAlias) Then && If the parameter cDbfAlias is a vaild string.
		If Select(cDbfAlias)>0 and IsValidStr(GetAlias(cDbfAlias)) Then && If cDbfAlias exist opened and no need to open again
			lNeedOpen = .F.
			cAlias = GetAlias(cDbfAlias)
		Else
			* Need to open the table base on cDbfAlias, That's mean not found a table to dispose
			lNeedOpen = .T.
			cAlias = AliasName()
			If !LcDbfOpen(cDbfAlias,cAlias) tHEN
				Wait window "File '"+ForcePath(ForceExt(cDbfAlias,'dbf'),Set('directory')) + "' does not exist ." nowait
				Return lReturnValue
			EndIf
		EndIf
	Else
		If IsValidStr(GetAlias()) Then && If there is a table opened in the current select
			cAlias = GetAlias()
			lNeedOpen = .F.
		Else
			Wait window 'No table is opened in the current work area .' nowait
			Return lReturnValue
		EndIf
	EndIf
	
	* Get the return value
	Select (cAlias)
	If Tagno(cIndex_TagName) > 0 Then
		lReturnValue = .T.
	Else
		lReturnValue = .F.
	EndIf
	
	* Restore the data environment. That's means if need to close the table
	If lNeedOpen Then
		LcDbfClose(cAlias)
	EndIf
	Select (nSelect)
	
	* Return value 
	Return lReturnValue	
EndProc
*------
Procedure IndexToExp
	Lparameters cIndex_TagName,cDbfAlias
	
	cIndex_TagName = DefCharacters(cIndex_TagName)
	
	Local cReturnValue,nSelect,cAlias,lNeedOpen
	cReturnValue = ''
	nSelect = Select()
	
	* Check the table if need to open .	
	If IsValidStr(cDbfAlias) Then && If the parameter cDbfAlias is a vaild string.
		If Select(cDbfAlias)>0 and IsValidStr(GetAlias(cDbfAlias)) Then && If cDbfAlias exist opened and no need to open again
			lNeedOpen = .F.
			cAlias = GetAlias(cDbfAlias)
		Else
			* Need to open the table base on cDbfAlias, That's mean not found a table to dispose
			lNeedOpen = .T.
			cAlias = AliasName()
			If !LcDbfOpen(cDbfAlias,cAlias) tHEN
				Wait window "File '"+ForcePath(ForceExt(cDbfAlias,'dbf'),Set('directory')) + "' does not exist ." nowait
				Return cReturnValue
			EndIf
		EndIf
	Else
		If IsValidStr(GetAlias()) Then && If there is a table opened in the current select
			cAlias = GetAlias()
			lNeedOpen = .F.
		Else
			Wait window 'No table is opened in the current work area .' nowait
			Return cReturnValue
		EndIf
	EndIf
	
	* Get the return value
	Select (cAlias)
	If IsValidStr(cIndex_TagName) and Tagno(cIndex_TagName)>0 Then
		cReturnValue = Sys(14,Tagno(cIndex_TagName),cAlias)
	Else
		If Tagno() > 0 Then
			* Get the default index expression if the TableAlias has index order set.
			cReturnValue = Sys(14,Tagno(),cAlias)
			*Else
				* TableAlias has no index order set.
				* cReturnValue = ''
		EndIf
	EndIf
	
	* Restore the data environment. That's means if need to close the table
	If lNeedOpen Then
		LcDbfClose(cAlias)
	EndIf
	Select (nSelect)
	
	* Return value 
	Return cReturnValue	
EndProc
*------
Procedure ExpToIndex
	Lparameters cExpression,cDbfAlias
	
	If !IsValidStr(cExpression) Then
		Return ''
	Else
		cExpression = Alltrim(Upper(cExpression))
	EndIf
	
	Local cReturnValue,nSelect,cAlias,lNeedOpen
	cReturnValue = ''
	nSelect = Select()
	
	* Check the table if need to open .	
	If IsValidStr(cDbfAlias) Then && If the parameter cDbfAlias is a vaild string.
		If Select(cDbfAlias)>0 and IsValidStr(GetAlias(cDbfAlias)) Then && If cDbfAlias exist opened and no need to open again
			lNeedOpen = .F.
			cAlias = GetAlias(cDbfAlias)
		Else
			* Need to open the table base on cDbfAlias, That's mean not found a table to dispose
			lNeedOpen = .T.
			cAlias = AliasName()
			If !LcDbfOpen(cDbfAlias,cAlias) tHEN
				Wait window "File '"+ForcePath(ForceExt(cDbfAlias,'dbf'),Set('directory')) + "' does not exist ." nowait
				Return cReturnValue
			EndIf
		EndIf
	Else
		If IsValidStr(GetAlias()) Then && If there is a table opened in the current select
			cAlias = GetAlias()
			lNeedOpen = .F.
		Else
			Wait window 'No table is opened in the current work area .' nowait
			Return cReturnValue
		EndIf
	EndIf
	
	* Get the return value
	Local nTag
	Select (cAlias)
	For nTag = 1 to Tagcount()
		If Sys(14,nTag,cAlias) == cExpression  Then
			cReturnValue = Tag(nTag)
			Exit
		EndIf			
	EndFor
	
	* Restore the data environment. That's means if need to close the table
	If lNeedOpen Then
		LcDbfClose(cAlias)
	EndIf
	Select (nSelect)
	
	* Return value 
	Return cReturnValue	
EndProc
*------
Procedure SearchIndex
	Lparameters cSearch_Keyword,cDbfAlias
	
	If !IsValidStr(cSearch_Keyword) Then
		Return ''
	Else
		cSearch_Keyword = Alltrim(Upper(cSearch_Keyword))
	EndIf
	
	Local cReturnValue,nSelect,cAlias,lNeedOpen
	cReturnValue = ''
	nSelect = Select()
	
	* Check the table if need to open .	
	If IsValidStr(cDbfAlias) Then && If the parameter cDbfAlias is a vaild string.
		If Select(cDbfAlias)>0 and IsValidStr(GetAlias(cDbfAlias)) Then && If cDbfAlias exist opened and no need to open again
			lNeedOpen = .F.
			cAlias = GetAlias(cDbfAlias)
		Else
			* Need to open the table base on cDbfAlias, That's mean not found a table to dispose
			lNeedOpen = .T.
			cAlias = AliasName()
			If !LcDbfOpen(cDbfAlias,cAlias) tHEN
				Wait window "File '"+ForcePath(ForceExt(cDbfAlias,'dbf'),Set('directory')) + "' does not exist ." nowait
				Return cReturnValue
			EndIf
		EndIf
	Else
		If IsValidStr(GetAlias()) Then && If there is a table opened in the current select
			cAlias = GetAlias()
			lNeedOpen = .F.
		Else
			Wait window 'No table is opened in the current work area .' nowait
			Return cReturnValue
		EndIf
	EndIf
	
	* Get the return value
	Local nTag
	Select (cAlias)
	For nTag = 1 to Tagcount()
		If cSearch_Keyword $ Sys(14,nTag) Then
			If Empty(cReturnValue) Then
				cReturnValue = Tag(nTag)+Space(3)+Replicate(Chr(38),2)+Space(1)+Sys(14,nTag)
			Else
				cReturnValue = cReturnValue + Chr(13)+Chr(10) +;
							   Tag(nTag)+Space(3)+Replicate(Chr(38),2)+Space(1)+Sys(14,nTag)
			EndIf
		EndIf 
	EndFor
		
	* Restore the data environment. That's means if need to close the table
	If lNeedOpen Then
		LcDbfClose(cAlias)
	EndIf
	Select (nSelect)
	
	* Return value 
	Return cReturnValue	
EndProc
*------
Procedure ListIndex
	Lparameters cDbfAlias

	Local cReturnValue,nSelect,cAlias,lNeedOpen
	cReturnValue = ''
	nSelect = Select()
	
	* Check the table if need to open .	
	If IsValidStr(cDbfAlias) Then && If the parameter cDbfAlias is a vaild string.
		If Select(cDbfAlias)>0 and IsValidStr(GetAlias(cDbfAlias)) Then && If cDbfAlias exist opened and no need to open again
			lNeedOpen = .F.
			cAlias = GetAlias(cDbfAlias)
		Else
			* Need to open the table base on cDbfAlias, That's mean not found a table to dispose
			lNeedOpen = .T.
			cAlias = AliasName()
			If !LcDbfOpen(cDbfAlias,cAlias) tHEN
				Wait window "File '"+ForcePath(ForceExt(cDbfAlias,'dbf'),Set('directory')) + "' does not exist ." nowait
				Return cReturnValue
			EndIf
		EndIf
	Else
		If IsValidStr(GetAlias()) Then && If there is a table opened in the current select
			cAlias = GetAlias()
			lNeedOpen = .F.
		Else
			Wait window 'No table is opened in the current work area .' nowait
			Return cReturnValue
		EndIf
	EndIf
	
	* Get the return value and show information in the screen 
	Local cArrayCursorAlias
	cArrayCursorAlias = 'csIndex'
	Dimension TempArray(1)
	
	* Note :
	* Please note the function ATagInfo can not support TableAlias or CursorAlias ,
	* So please make sure select (Target Alias) first and no need to set alias for the function in the next.
	Select (cAlias)
	If ATagInfo('TempArray') > 0 and ArrayToCursor('TempArray',cArrayCursorAlias,.T.) > 0 Then
		cReturnValue = cArrayCursorAlias
		Select (cArrayCursorAlias)
		List
		Goto Top
	EndIf
		
	* Restore the data environment. That's means if need to close the table
	If lNeedOpen Then
		LcDbfClose(cAlias)
	EndIf
	Select (nSelect)
	
	* Return value 
	Return cReturnValue	
EndProc
*------
Procedure GetQtyTotal
	Lparameters cDocID,cDbf,cOrder,nType,cFilter,cField_N,cField_C,cFieldFormat,lDel_needlessly_decimal
	If Not IsValidStr(cDocId) or Not IsValidStr(cOrder) or Not IsValidStr(cDbf) Then
		Return ''
	Endif
	If Vartype(nType)<>'N' Then
		nType=0
	Else
		If Not InList(nType,0,1,2) Then
			nType=0
		EndIf
	EndIf
	If Not IsValidStr(cFilter) Then
		cFilter='.T.' && It's mean no need to filter 
	EndIf
	If Not IsValidStr(cField_N) Then
		cField_N='Quantity' && The default field
	EndIf
	If Not IsValidStr(cField_C,.T.) Then
		cField_C='Ctn_unit' && The default field
	EndIf
	If Not IsValidStr(cFieldFormat) Then
		If Vartype(qty_Pict)=Upper('U') Then && Undefine
			cFieldFormat='99,999,999.99'
		Else
			cFieldFormat=qty_pict && The default value format is the quantity in the itrader enviroment
		EndIf
	Endif
	lDel_needlessly_decimal=DefLogic(lDel_needlessly_decimal)		
	Local cReturnValue,nSelect,cAlias,cOrderExp,nTag,lFoundUnit,cTmpValue
	Local Array TmpUnitArray(1,2)
	If nType=2 Then && Get the unit
		cReturnValue=''
	Else
		cReturnValue='0'
	EndIf
	
	nSelect=Select()
	cAlias=AliasName()
	If Not LcDbfOpen(cDbf,cAlias,.F.,cOrder) Then
		Return cReturnValue
	EndIf
*!*		If Not Lc_FieldIn(cField_N,cAlias) Then
*!*			WaitWindow('The field '+cField_N+' not in table '+Proper(JustStem(Dbf(cAlias))),Sys(16))
*!*			LcDbfClose(cAlias)
*!*			Select (nSelect)
*!*			Return cReturnValue
*!*		EndIf
	cOrderExp=IndexToExp(cOrder,cAlias)
	If Empty(cOrderExp) or Not Seek(cDocID,cAlias) Then
		LcDbfClose(cAlias)
		Select (nSelect)
		Return cReturnValue
	EndIf
	Select (cAlias)
	Scan rest while &cOrderExp.==cDocId
		If Empty(&cField_N.) or !Evaluate(cFilter) Then
			Loop
		EndIf
		If Vartype(TmpUnitArray)=Upper('L') Then
			Dimension TmpUnitArray(1,2)
			If IsValidStr(cField_C) Then
				TmpUnitArray(1,1)=Alltrim(&cField_C.)
			Else
				TmpUnitArray(1,1)=Alltrim(cField_C)
			EndIf
			TmpUnitArray(1,2)=0 && Store the number use to count the quantity
		Else
			lFoundUnit=.F.
			For nTag=1 to Alen(TmpUnitArray,1)
				If IsValidStr(cField_C) Then
					If TmpUnitArray(nTag,1)==Alltrim(&cField_C.) Then
						lFoundUnit=.T.
						Exit
					EndIf
				Else
					If TmpUnitArray(nTag,1)==Alltrim(cField_C) Then
						lFoundUnit=.T.
						Exit
					EndIf
				EndIf
			EndFor
			If Not lFoundUnit Then
				Dimension TmpUnitArray(Alen(TmpUnitArray,1)+1,2) && Add new item use to store the new ctn_unit
				If IsValidStr(cField_C) Then
					TmpUnitArray(Alen(TmpUnitArray,1),1)=Alltrim(&cField_C.)
				Else
					TmpUnitArray(Alen(TmpUnitArray,1),1)=Alltrim(cField_C) 
				EndIf
				TmpUnitArray(Alen(TmpUnitArray,1),2)=0 && Init value is number 0
			EndIf
		EndIf
	EndScan
	If Vartype(TmpUnitArray)=Upper('L') Then && If no any ctn_unit or others character field store in array ,So the array TmpUnitArray not exist.
		LcDbfClose(cAlias)
		Select (nSelect)
		Return cReturnValue
	EndIf
		
	** Count the quantity or other number fields and store in  the TmpUnitArray
	=Seek(cDocId,cAlias)
	Scan rest while &cOrderExp.==cDocId
		If Empty(&cField_N.) or !Evaluate(cFilter) Then
			Loop
		EndIf
		For nTag=1 to Alen(TmpUnitArray,1)
			If IsValidStr(cField_C) Then
				If Alltrim(&cField_C.)==TmpUnitArray(nTag,1) Then
					TmpUnitArray(nTag,2)=TmpUnitArray(nTag,2)+&cField_N.
					Exit
				EndIf
			Else
				If Alltrim(cField_C)==TmpUnitArray(nTag,1) Then
					TmpUnitArray(nTag,2)=TmpUnitArray(nTag,2)+&cField_N.
					Exit
				EndIf
			EndIf
		EndFor
	EndScan
	LcDbfClose(cAlias)
	Select (nSelect)
	cReturnValue=''
	** Build the return value in string
	For nTag=1 to Alen(TmpUnitArray,1)
		Local lFound_Decimal,lFound_needlessly_decimal_and_deleted
		lFound_Decimal=.F.
		lFound_needlessly_decimal_and_deleted=.F.
		If (Not IsInteger(TmpUnitArray(nTag,2))) Then
			If (Not '.' $ cFieldFormat) Then
				lFound_Decimal=.T.
				Local cTempFieldFormat 
				cTempFieldFormat=cFieldFormat
				cFieldFormat=cFieldFormat+'.'+Replicate('9',GetDecimalBits(TmpUnitArray(nTag,2)))
			Endif
		Else && IsInteger
			If lDel_needlessly_decimal  And '.' $ cFieldFormat Then
				lFound_needlessly_decimal_and_deleted=.T.
				Local cTempFieldFormat
				cTempFieldFormat=cFieldFormat
				cFieldFormat=ItSubstr(cFieldFormat,'.',1)
			EndIf			
		Endif
		Do	Case 
			Case nType=0  && Return the quantity and ctn_Unit
				cTmpValue=Transform(TmpUnitArray(nTag,2),cFieldFormat)+' '+TmpUnitArray(nTag,1)		
			Case nType=1 && Return quantity
				cTmpValue=Transform(TmpUnitArray(nTag,2),cFieldFormat)
			Case nType=2 && Return Ctn_Unit
				cTmpValue=TmpUnitArray(nTag,1)
		EndCase
		If lFound_Decimal Then
			cFieldFormat=cTempFieldFormat 
		Else
			If lFound_needlessly_decimal_and_deleted Then
				cFieldFormat=cFieldFormat
			EndIf
		EndIf						
		cReturnValue=Iif(Empty(cReturnValue),cTmpValue,cReturnValue+Chr(13)+Chr(10)+cTmpValue)
	EndFor
	Release TmpUnitArray && Release the memory
	Return cReturnValue
Endproc
*------
Procedure GetTotal
	Lparameters cDocID,cDbfAlias,cOrder,nType,cFilter,cField_N,cField_C,cFieldFormat,lDel_needlessly_decimal
	
	If !IsValidStr(cDocId) Then
		Return ''
	Endif
	If Vartype(nType)<>'N' Then
		nType=0
	Else
		If Not InList(nType,0,1,2) Then
			nType=0
		EndIf
	EndIf
	cFilter = DefCharacters(cFilter,'.T.') && Default no need to filter.
	cField_N = DefCharacters(cField_N,'Quantity') && Default count the quantity
	cField_C = DefCharacters(cField_C,'Ctn_Unit') && Default count the ctn_unit
	If !IsValidStr(cFieldFormat) Then
		If Vartype(qty_Pict)=Upper('U') Then && Undefine
			cFieldFormat='99,999,999.99'
		Else
			cFieldFormat=qty_pict && The default value format is the quantity in the itrader enviroment
		EndIf
	EndIf 
	lDel_needlessly_decimal=DefLogic(lDel_needlessly_decimal)	
		
	Local cReturnValue,nSelect,lNeedOpen,cAlias,cOrderExp,nTag,lFoundUnit,cTmpValue
	lNeedOpen = .T.
	nSelect = Select()
	If nType=2 Then && Get the unit
		cReturnValue=''
	Else
		cReturnValue='0'
	EndIf
	
	* Check the table if need to open again.	
	If IsValidStr(cDbfAlias) Then && If the parameter cDbfAlias is a vaild string.
		If Select(cDbfAlias)>0 and IsValidStr(GetAlias(cDbfAlias)) Then && If cDbfAlias exist opened and no need to open again
			cAlias = GetAlias(cDbfAlias)
			lNeedOpen = .F.
		Else
			lNeedOpen = .T.
		EndIf
	Else
		If IsValidStr(GetAlias()) Then && If there is a table opened in the current select
			cAlias = GetAlias()
			lNeedOpen = .F.
		Else
			lNeedOpen = .T.
		EndIf
	EndIf
	* Confirm the table which need to dispose and check index information.
	If !lNeedOpen Then && If no need open the table, That's mean has been found a table to dispose
		If IsValidStr(cOrder) Then
			Select (cAlias)
			Set Order To &cOrder.
		Else
			If Empty(Order(cAlias)) Then
				Wait window 'No index seted. ' nowait
				Return cReturnValue
			Else
				cOrder = Order(cAlias)
			EndIf
		EndIf
	Else && Need to open the table base on cDbfAlias
		If IsValidStr(cDbfAlias) Then
			cAlias = AliasName()
		Else
			Wait window 'No table is open in the current work area, Please sent a parameter as table or alias name.' nowait
			Return cReturnValue
		EndIf
		If !IsValidStr(cOrder) Then
			Wait window 'No index seted. ' nowait
			Return cReturnValue
		EndIf
		If !LcDbfOpen(cDbfAlias,cAlias,.F.,cOrder) Then
			Return cReturnValue
		EndIf
	EndIf
	
	cOrderExp=IndexToExp(cOrder,cAlias)
	If Empty(cOrderExp) or !Seek(cDocID,cAlias) Then
		If lNeedOpen Then
			LcDbfClose(cAlias)
		EndIf
		Select (nSelect)
		Return cReturnValue
	EndIf
	
	Local Array TmpUnitArray(1,2)
	If nType=2 Then && Get the unit
		cReturnValue=''
	Else
		cReturnValue='0'
	EndIf

	Select (cAlias)
	Scan rest while &cOrderExp.=cDocId
		If Empty(&cField_N.) or !Evaluate(cFilter) Then
			Loop
		EndIf
		If Vartype(TmpUnitArray)=Upper('L') Then
			Dimension TmpUnitArray(1,2)
			If IsValidStr(cField_C) Then
				TmpUnitArray(1,1)=Alltrim(&cField_C.)
			Else
				TmpUnitArray(1,1)=Alltrim(cField_C)
			EndIf
			TmpUnitArray(1,2)=0 && Store the number use to count the quantity
		Else
			lFoundUnit=.F.
			For nTag=1 to Alen(TmpUnitArray,1)
				If IsValidStr(cField_C) Then
					If TmpUnitArray(nTag,1)==Alltrim(&cField_C.) Then
						lFoundUnit=.T.
						Exit
					EndIf
				Else
					If TmpUnitArray(nTag,1)==Alltrim(cField_C) Then
						lFoundUnit=.T.
						Exit
					EndIf
				EndIf
			EndFor
			If Not lFoundUnit Then
				Dimension TmpUnitArray(Alen(TmpUnitArray,1)+1,2) && Add new item use to store the new ctn_unit
				If IsValidStr(cField_C) Then
					TmpUnitArray(Alen(TmpUnitArray,1),1)=Alltrim(&cField_C.)
				Else
					TmpUnitArray(Alen(TmpUnitArray,1),1)=Alltrim(cField_C) 
				EndIf
				TmpUnitArray(Alen(TmpUnitArray,1),2)=0 && Init value is number 0
			EndIf
		EndIf
	EndScan
	If Vartype(TmpUnitArray)=Upper('L') Then && If no any ctn_unit or others character field store in array ,So the array TmpUnitArray not exist.
		If lNeedOpen Then
			LcDbfClose(cAlias)
		EndIf
		Select (nSelect)
		Return cReturnValue
	EndIf
		
	** Count the quantity or other number fields and store in  the TmpUnitArray
	=Seek(cDocId,cAlias)
	Scan rest while &cOrderExp.=cDocId
		If Empty(&cField_N.) or !Evaluate(cFilter) Then
			Loop
		EndIf
		For nTag=1 to Alen(TmpUnitArray,1)
			If IsValidStr(cField_C) Then
				If Alltrim(&cField_C.)==TmpUnitArray(nTag,1) Then
					TmpUnitArray(nTag,2)=TmpUnitArray(nTag,2)+&cField_N.
					Exit
				EndIf
			Else
				If Alltrim(cField_C)==TmpUnitArray(nTag,1) Then
					TmpUnitArray(nTag,2)=TmpUnitArray(nTag,2)+&cField_N.
					Exit
				EndIf
			EndIf
		EndFor
	EndScan
	If lNeedOpen Then
		LcDbfClose(cAlias)
	EndIf
	Select (nSelect)
	cReturnValue=''
	** Build the return value in string
	For nTag=1 to Alen(TmpUnitArray,1)
		Local lFound_Decimal,lFound_needlessly_decimal_and_deleted
		lFound_Decimal=.F.
		lFound_needlessly_decimal_and_deleted=.F.
		If (Not IsInteger(TmpUnitArray(nTag,2))) Then
			If (Not '.' $ cFieldFormat) Then
				lFound_Decimal=.T.
				Local cTempFieldFormat 
				cTempFieldFormat=cFieldFormat
				cFieldFormat=cFieldFormat+'.'+Replicate('9',GetDecimalBits(TmpUnitArray(nTag,2)))
			Endif
		Else && IsInteger
			If lDel_needlessly_decimal  And '.' $ cFieldFormat Then
				lFound_needlessly_decimal_and_deleted=.T.
				Local cTempFieldFormat
				cTempFieldFormat=cFieldFormat
				cFieldFormat=ItSubstr(cFieldFormat,'.',1)
			EndIf			
		Endif
		Do	Case 
			Case nType=0  && Return the quantity and ctn_Unit
				cTmpValue=Transform(TmpUnitArray(nTag,2),cFieldFormat)+' '+TmpUnitArray(nTag,1)		
			Case nType=1 && Return quantity
				cTmpValue=Transform(TmpUnitArray(nTag,2),cFieldFormat)
			Case nType=2 && Return Ctn_Unit
				cTmpValue=TmpUnitArray(nTag,1)
		EndCase
		If lFound_Decimal Then
			cFieldFormat=cTempFieldFormat 
		Else
			If lFound_needlessly_decimal_and_deleted Then
				cFieldFormat=cFieldFormat
			EndIf
		EndIf						
		cReturnValue=Iif(Empty(cReturnValue),cTmpValue,cReturnValue+Chr(13)+Chr(10)+cTmpValue)
	EndFor
	Release TmpUnitArray && Release the memory
	Return cReturnValue
EndProc
*------
Procedure GetDecimalBits
	Lparameters nValue,nAllowMaxBits
	nValue=DefNumber(nValue)
	If IsInteger(nValue) Then
		Return 0
	EndIf
	nAllowMaxBits=DefNumber(nAllowMaxBits)
	If nAllowMaxBits=0 Then
		nAllowMaxBits=12
	EndIf
	If nValue=0 Then
		Return 0
	Endif
	Local nTempValue,nTag
	For nTag=1 To nAllowMaxBits
		nTempValue='nValue*1'+Replicate('0',nTag)
		If IsInteger(&nTempValue) Then
			Return nTag
		Endif
	EndFor
	Return -1 && If the decimalBits larger than nAllowMaxBits
EndProc
*------
Procedure ItStr
	Lparameters nValue,nDecimalBits,lForce_DecimalBits,lIgnoreRound
	
	nValue = DefNumber(nValue)
	lForce_DecimalBits = DefLogic(lForce_DecimalBits)
	lIgnoreRound = DefLogic(lIgnoreRound)

	Local nActually_DecimalBits,cReturnValue,cValue_Decimal
	nActually_DecimalBits = GetDecimalBits(nValue)
	If nActually_DecimalBits < 0 Then && Maybe it will be -1 if the decimal bits larger than 12
		nActually_DecimalBits = 12 
	EndIf
	Store '' to cReturnValue,cValue_Decimal
	
	* If the nDecimalBits defalut value is numeric and is a negative numeric than need to convert to integer numberic,
	* else return the actually decimal bits.
	nDecimalBits = Int(DefNumber(nDecimalBits,nActually_DecimalBits))
	If nDecimalBits < 0 Then && If send the paramete to nDecimalBits less than 0 ,negative numeric
		nDecimalBits = Abs(nDecimalBits) && If it is a negative numeric than need convert to integer numeric.
	EndIf
	
	cReturnValue = Alltrim(Str(Int(nValue)))
	If nActually_DecimalBits > 0 Then
		If nDecimalBits = 0 or ( !lForce_DecimalBits and nActually_DecimalBits > nDecimalBits ) Then
			cValue_Decimal = (nValue - Int(nValue)) * 10^nActually_DecimalBits
		Else
			cValue_Decimal = (nValue - Int(nValue)) * 10^nDecimalBits
		EndIf
		If lIgnoreRound Then && No need round (四舍五入)
			cValue_Decimal = Int(cValue_Decimal) && Remove decimal numeric
		EndIf
		cValue_Decimal = Alltrim(Str(cValue_Decimal))
	EndIf
			
	If !Empty(cValue_Decimal) Then
		If nDecimalBits = 0 or ( !lForce_DecimalBits and nActually_DecimalBits > nDecimalBits ) Then
			cReturnValue = cReturnValue + '.' + Padl(cValue_Decimal,nActually_DecimalBits,'0')
		Else
			cReturnValue = cReturnValue + '.' + Padl(cValue_Decimal,nDecimalBits,'0')
		EndIf			
	EndIf
	
	Return cReturnValue
EndProc
*------
Procedure ItNum && UnFinished
	Lparameters nValue,nDecimalBits,lForce_DecimalBits,lIgnoreRound
		
	nValue = DefNumber(nValue)
	lForce_DecimalBits = DefLogic(lForce_DecimalBits)
	lIgnoreRound = DefLogic(lIgnoreRound)

	Local nActually_DecimalBits,nReturnValue,nValue_Decimal
	nActually_DecimalBits = GetDecimalBits(nValue)
	If nActually_DecimalBits < 0 Then && Maybe it will be -1 if the decimal bits larger than 12
		nActually_DecimalBits = 12 
	EndIf
	Store 0 to nReturnValue,nValue_Decimal
	
	* If the nDecimalBits defalut value is numeric and is a negative numeric than need to convert to integer numberic,
	* else return the actually decimal bits.
	nDecimalBits = Int(DefNumber(nDecimalBits,nActually_DecimalBits))
	If nDecimalBits < 0 Then && If send the paramete to nDecimalBits less than 0 ,negative numeric
		nDecimalBits = Abs(nDecimalBits) && If it is a negative numeric than need convert to integer numeric.
	EndIf
	
	nReturnValue = Int(nValue)
	Set Step On
	If nActually_DecimalBits > 0 Then
		If nDecimalBits = 0 or ( !lForce_DecimalBits and nActually_DecimalBits > nDecimalBits ) Then
			nValue_Decimal = Int( (nValue - Int(nValue)) * 10^nActually_DecimalBits + 0.000001 )/10^nActually_DecimalBits && LastPause
			*nValue_Decimal = nValue - Int(nValue)
		Else 
			nValue_Decimal = Int((nValue - Int(nValue)) * 10^nDecimalBits + 0.000001)/10^nDecimalBits
		EndIf
*!*			If lIgnoreRound Then && No need round (四舍五入)
*!*				nValue_Decimal = Int(nValue_Decimal) && Remove decimal numeric
*!*			EndIf
*!*			nValue_Decimal = Int(nValue_Decimal)
	EndIf
			
	If nValue_Decimal<>0 Then
		nReturnValue = nReturnValue + nValue_Decimal
	EndIf
	
	Return nReturnValue
EndProc
*------
Procedure IsInteger
	Lparameters nValue
	nValue=DefNumber(nValue)
	If nValue=0 Then
		Return .T.
	Else
		If nValue = Int(nValue) Then
			Return .T.
		Else
			Return .F.
		EndIf
	EndIf
EndProc
*------
Procedure GetCustMsg()
	Lparameters cCust_ID,nTag,cMsg
	If Not IsValidStr(cCust_ID) Then
		Wait window 'Please sure the customer_id is string and not empty ! 'nowait
		Return ''
	EndIf
	If Vartype(nTag)<>'N' OR NOT InList(nTag,0,1,2,3,4,5,6) Then
		nTag=0 && Get all message , Include customer_id,Customer_name(CHS AND ENG),TEL,FAX,ATTN
	EndIf
	If Not IsValidStr(cMsg,.T.) Then
		cMsg=''
	EndIf
	Local nSelect,cReturnValue,cLine
	nSelect=Select()
	cReturnValue=''
	cLine=Chr(13)+Chr(10)
	If Not LcDbfOpen('Customer','Customer_Msg') Then
		Return cReturnValue
	EndIf
	If Not (Seek(cCust_ID,'Customer_Msg','Customer_I') and cCust_ID==Customer_Msg.Customer_ID) Then
		Wait window 'Can not found the customer id of '+"'"+cCust_iD+"'"+' in customer table . ' nowait
		Select (nSelect)
		LcDbfClose('Customer_Msg')
		Return cReturnValue
	EndIf
	Do Case
		Case nTag=0 && Return all message
			cReturnValue=cMsg+'MESSRS: '+Alltrim(Customer_Msg.Customer_ID)+cLine
			cReturnValue=cReturnValue+Alltrim(Customer_Msg.Company_name)+cLine
			If Not Empty(Alltrim(Customer_Msg.Company_name2)) Then
				cReturnValue=cReturnValue+Alltrim(Customer_Msg.Company_name2)+cLine
			EndIf
			If Not Empty(Alltrim(Customer_Msg.Address)) Then
				cReturnValue=cReturnValue+Alltrim(Customer_Msg.Address)+cLine
			EndIf
			If Not Empty(Alltrim(Customer_Msg.Address2)) Then
				cReturnValue=cReturnValue+Alltrim(Customer_Msg.Address2)+cLine
			EndIf
			If Not Empty(Alltrim(Customer_Msg.Address3)) Then
				cReturnValue=cReturnValue+Alltrim(Customer_Msg.Address3)+cLine
			EndIf
			If Not Empty(Alltrim(Customer_Msg.Address4)) Then
				cReturnValue=cReturnValue+Alltrim(Customer_Msg.Address4)+cLine
			EndIf
			cReturnValue=cReturnValue+'TEL   : '+Alltrim(Customer_Msg.Phone)+cLine
			cReturnValue=cReturnValue+'FAX   : '+Alltrim(Customer_Msg.Fax)+cLine
			cReturnValue=cReturnValue+'ATTN  : '+Alltrim(Customer_Msg.Contact_name)
		Case nTag=1 && Return the customer_id
			cReturnValue=cMsg+Alltrim(Customer_Msg.Customer_ID)  && No need to add cline, Because not empty customer_id whenever
		Case nTag=2 && Return the company_name
			cReturnValue=cMsg+Alltrim(Customer_Msg.Company_name)
			If Not Empty(Alltrim(Customer_Msg.Company_name2)) Then
				cReturnValue=cReturnValue+cLine+Alltrim(Customer_Msg.Company_name2)
			EndIf
		Case nTag=3 && Reutrn the Address
			cReturnValue=cMsg+Alltrim(Customer_Msg.Address)
			If Not Empty(Alltrim(Customer_Msg.Address2)) Then
				cReturnValue=cReturnValue+cLine+Alltrim(Customer_Msg.Address2)
			EndIf
			If Not Empty(Alltrim(Customer_Msg.Address3)) Then
				cReturnValue=cReturnValue+cLine+Alltrim(Customer_Msg.Address3)
			EndIf
			If Not Empty(Alltrim(Customer_Msg.Address4)) Then
				cReturnValue=cReturnValue+cLine+Alltrim(Customer_Msg.Address4)
			EndIf
		Case nTag=4 && Return the Telephone
			cReturnValue=cMsg+Alltrim(Customer_Msg.Phone)
		Case nTag=5 && Return the Fax
			cReturnValue=cMsg+Alltrim(Customer_Msg.Fax)
		Case nTag=6 && Return the attn
			cReturnValue=cMsg+Alltrim(Customer_Msg.Contact_name)
	EndCase
	LcDbfClose('Customer_Msg')
	Return cReturnValue
EndProc
*------
Procedure uDateTime()
	oTemp=CreateObject('oTimeNew')
	Read events

	Define Class oTimeNew as Form 
		Add Object oTimeLast as Timer with Interval=1000
		
		Procedure oTimeLast.Timer
			Wait window 'Press Ctrl+F4 to exit …… '+Ttoc(DatetIME()) nowait
		EndProc
		
		Procedure Init
			On Key Label Ctrl+f4 Clear Events
		EndProc
		Procedure Destroy
			On Key Label Ctrl+F4
		EndProc
	EndDefine
EndProc
*------
Procedure ResizeImage
	Lparameters cSourceFileName,cNewFileName,nWidth,nHeight,lIsometric
	**************************************
	*{  resizeimage('e:\a.bmp','e:\b.bmp',nWidth ,nHeigh) }
	*如果nWidth 为0 那么以nHeigh来等比变化结果nWidth=原图片的宽度×nHeigh/ 原图片的高度
	*如果nHeigh 为0 那么以nWidth来等比变化结果nHeigh =原图片的高度×nWidth/ 原图片的宽度
	*如果两个都不为0 ，那么取nWidth ,nHeigh 的值
	*如果两个都为0 ，返回 .f.
	**************************************
	
	If Vartype(cSourceFileName)<>Upper('C') or !File(cSourceFileName)
		Wait window 'Image[ '+cSourceFileName+' ] not found.' nowait
		Return .F.
	Else
		cSourceFileName=ForcePath(JustFname(cSourceFileName),JustPath(cSourceFileName))
	EndIf
	If Vartype(cNewFileName)<>Upper('C') Or Empty(Alltrim(cNewFileName)) Then
		Return .F.
	EndIf
	If Vartype(nWidth)<>Upper('N') or nWidth<0 Then
		nWidth=0 && Default value
	EndIf	
	If Vartype(nHeight)<>Upper('N') or nHeight<0 Then
		nHeight=0 && Default value
	EndIf
	If Vartype(lIsometric)<>Upper('L') Then
		lIsometric=.F. && Default value
	EndIf
	
	&& Get the source image file width and height
	Local nSourceWidth,nSourceHeight
	nSourceWidth = GetImageWidth(cSourceFileName)
	nSourceHeight = GetImageHeight(cSourceFileName)
	
	&& Calculation the target image file width and height base on the source file width and height
	If Empty(nWidth) or Empty(nHeight) Then && At least one variable value is 0
		If nWidth=0 And nHeight=0 Then
			nWidth = nSourceWidth
			nHeight= nSourceHeight
		Else
			If Empty(nWidth)
				nWidth =nSourceWidth/nSourceHeight * nHeight
			EndIf
			If Empty(nHeight)
				nHeight=nSourceHeight/nSourceWidth * nWidth
			Endif
		EndIf
	Else && nWidth<>0 and nHeight<>0
		If lIsometric Then
			If nSourceWidth/nSourceHeight<>nWidth/nHeight Then 
				If nSourceWidth=nSourceHeight Then
					If nWidth>nHeight Then
						nWidth=nHeight 
					Else && nWidth<nHeight
						nHeight=nWidth
					EndIf
				Else && nSourceWidth<>nSourceHeight
					If nWidth>nHeight Then && First count height
						If nSourceWidth*nHeight /nSourceHeight <=nWidth Then && Base on nWidth, Count nHeight
							nWidth=nSourceWidth*nHeight /nSourceHeight
						Else
							nHeight=nSourceHeight*nWidth /nSourceWidth
						EndIf
					Else && First count width
						If nSourceHeight*nWidth /nSourceWidth <= nHeight Then && Base on nHeight, Count nWidth
							nHeight=nSourceHeight*nWidth /nSourceWidth
						Else 
							If nSourceWidth*nHeight /nSourceHeight <=nWidth Then && Base on nWidth, Count nHeight
								nWidth=nSourceWidth*nHeight /nSourceHeight
							EndIf					
						EndIf
					EndIf
				EndIf
			EndIf			
		EndIf
	EndIf
		
	Private cSourceFileName,cNewFileName,nWidth,nHeight
	Declare Integer GdiplusStartup In GDIPlus;
		INTEGER @token, String @Input, Integer Output
	Local hToken, cInput
	hToken = 0
	cInput = Padr(Chr(1), 16, Chr(0))
	GdiplusStartup(@hToken, @cInput, 0)
	Declare Integer GdipLoadImageFromFile In GDIPlus.Dll ;
		STRING wFilename, Integer @nImage
	Local nImage
	nImage = 0
	GdipLoadImageFromFile(Strconv(cSourceFileName + Chr(0), 5), @nImage)
	#Define   GDIPLUS_PIXELFORMAT_32bppARGB          2498570
	Declare Integer GdipCreateBitmapFromScan0 In GDIPlus.Dll ;
		INTEGER nWidth, Integer nHeight, Integer nStride;
		, Integer nPixelFormat ;
		, String @ cScan0, Integer @ nImage
	Local nBitmap, nWidth, nHeight, nX, nY
	nBitmap = 0
	nX = 0
	nY = 0
	GdipCreateBitmapFromScan0(nWidth, nHeight, 0, GDIPLUS_PIXELFORMAT_32bppARGB, 0, @nBitmap)
	Declare Integer GdipGetImageGraphicsContext In GDIPlus.Dll ;
		INTEGER nImage, Integer @ nGraphics
	Local nGraphics
	nGraphics = 0
	GdipGetImageGraphicsContext (nBitmap, @nGraphics)
	Declare Integer GdipDrawImageRect In GDIPlus.Dll ;
		INTEGER nGraphics, Integer nImage, Single,Single,Single,Single
	GdipDrawImageRect(nGraphics, nImage, nX, nY, nWidth, nHeight)
	Local lcEncoder
	lcEncoder = Replicate(Chr(0),16)
	Declare Integer CLSIDFromString In ole32 String lpsz, String @pclsid
	CLSIDFromString(Strconv("{557CF401-1A04-11D3-9A73-0000F81EF32E}" + Chr(0), 5), @lcEncoder)
	Declare Integer GdipSaveImageToFile In GDIPlus.Dll ;
		INTEGER nImage, String wFilename, String qEncoder, Integer nEncoderParamsPtr
	Erase (cNewFileName)
	Declare Long GdipDisposeImage In GDIPlus.Dll Long nativeImage
	GdipDisposeImage(nImage)
	GdipSaveImageToFile (nBitmap, Strconv(cNewFileName,5) + Chr(0), lcEncoder, 0)
	Declare Integer GdiplusShutdown In GDIPlus Integer token
	GdiplusShutdown(hToken)
	Clear Dlls
	Return .T.
EndProc
*------
Procedure PictureSaveAs && Pause
	Lparameters cSourceFileName as String,cTargetFileName as string
	cSourceFileName = DefCharacters( cSourceFileName )
	If !File( cSourceFileName ) Then
		Return .F.
	EndIf
	cTargetFileName = DefCharacters( cTargetFileName )
	If !IsValidStr( cTargetFileName ) Then
		Return .F.
	EndIf
	
	lqEncoderClsID_BMP=0h00F47C55041AD3119A730000F81EF32E &&BMP
	lqEncoderClsID_JPG=0h01F47C55041AD3119A730000F81EF32E &&JPG
	lqEncoderClsID_GIF=0h02F47C55041AD3119A730000F81EF32E &&GIF
	lqEncoderClsID_TIF=0h05F47C55041AD3119A730000F81EF32E &&TIF
	lqEncoderClsID_PNG=0h06F47C55041AD3119A730000F81EF32E &&PNG
	DECLARE Long GdipLoadImageFromFile IN Gdiplus.dll String cFile, Long @ nativeImage
	DECLARE Long GdipSaveImageToFile IN Gdiplus.dll Long nativeImage, String cFile, ;
	         String EncoderClsID, String EncoderParameters
	DECLARE Long GdipDisposeImage IN Gdiplus.dll Long nativeImage
	lcInputFile=STRCONV(cSourceFileName+CHR(0),5)
	lcOutputFile=STRCONV(cTargetFileName+CHR(0),5)
	lnImage=0
	GdipLoadImageFromFile(lcInputFile,@lnImage)
	GdipSaveImageToFile(lnImage, lcOutputFile, EVALUATE('lqEncoderClsID_'+UPPER(JUSTEXT(cTargetFileName))), NULL)
	GdipDisposeImage(lnImage)
	*!*		ERASE &cSourceFileName
	If File(cTargetFileName) Then
		Return .T.
	Else
		Return .F.
	EndIf
EndProc
*------
Procedure CDOSendMail
	Lparameters cTo,cCC,cSubject,cBody,cAttachment,cFrom,cUserName,cPassword,cSmtp
	If Not IsValidStr(cTo) Then
		Return .F.
	EndIf
	If Not IsValidStr(cCC) Then
		cCC=''
	EndIf
	If Not IsValidStr(cSubject) Then
		cSubject=''
	EndIf
	If Not IsValidStr(cBody) Then
		cBody=''
	EndIf
	If Not IsValidStr(cAttachment) Then
		cAttachment=''
	EndIf
	If Not IsValidStr(cFrom) or Not IsValidStr(cUserName) or Not IsValidStr(cPassword) or Not IsValidStr(cSmtp) Then
		Return .F. && ?
	EndIf
	Local oCDO,oConfig
	Try
		oCDO=NewObject('CDO.MESSAGE')
	Catch
		oCDO=.Null.
	EndTry
	If IsNull(oCDO) Then
		Wait window 'Can not create CDO object . ' nowait
		Return .F.
	EndIf
	oConfig=NewObject('Cdo.Configuration')
	With oConfig.Fields
		.Item('http://schemas.microsoft.com/cdo/configuration/sendusing')=2
		.Item('http://schemas.microsoft.com/cdo/configuration/smtpserverport')=25
		.Item('http://schemas.microsoft.com/cdo/configuration/smtpaccountname')=cFrom
		.Item('http://schemas.microsoft.com/cdo/configuration/sendusername')=cUserName
		.Item('http://schemas.microsoft.com/cdo/configuration/sendpassword')=cPassword
		.Item('http://schemas.microsoft.com/cdo/configuration/smtpauthenticate')=1
		.Item('http://schemas.microsoft.com/cdo/configuration/languagecode')=0x0804
		.Item('http://schemas.microsoft.com/cdo/configuration/smtpserver')=cSmtp
	EndWith
	oCDO.Configuration=oConfig
	With oCDO
		.From=.cFrom
		*!*				.CC ?
		.To=cTo
		.Subject=cSubject
		.TextBody=cBody
		.AddAttachment(cAttachment)
	EndWith
	Try
		oCDO.Send()
		cReturnValue='Email send finished!'
		oError=.Null.
	Catch to oError
		Text to cReturnValue Noshow TextMerge
				Email send failed.
				<<oError.Message>>

		ENDTEXT
	EndTry
	Store .Null. to oConfig,oCDO
EndProc
*------
Procedure lJmailSendMail && Question: Body type maybe need to add here.
	Lparameters cTo,cCC,cBCC,cSubject,cBody,cAttachment,cUserName,cPassword,cSmtp,cFrom,cCharset
	If Not IsValidStr(cTo) and Not IsValidStr(cCC) Then
		Wait window 'Please sure the recipient or cc not empty .'nowait
		Return .F.
	EndIf
	If Not IsValidStr(cUserName) Then
		Wait window 'Please sure the smtp username not empty.' nowait
		Return .F.
	EndIf
	If Not IsValidStr(cPassword) Then
		Wait window 'Please sure the smtp password not empty.' nowait
		Return .F.
	EndIf
	If Not IsValidStr(cSmtp) Then
		Wait window 'Please sure the smtp is not empty.' nowait
		Return .F.
	EndIf
	If Not IsValidStr(cFrom) Then
		cFrom=cUserName+'@'+Substr(cSmtp,At('.',cSmtp)+1)
	EndIf
	If Not IsValidStr(cCharset) Then
		DECLARE Integer GetSystemDefaultLCID IN kernel32 As GetSystemDefaultLCID
		If GetSystemDefaultLCID()=2052 && GB2312
			cCharSet='GB2312'
		Else
			cCharSet='UTF-8'
		EndIf
	Else
		cCharSet=Upper(Alltrim(cCharSet))
	EndIf
	Local oJmail,cOnError
	cOnError=On('Error')
	lError=.F.
	On Error lError=.T.
	oJmail=CreateObject('Jmail.Message')
	On Error &cOnError.
	If lError Then
		Wait window 'Please sure the file jmail.dll in your system and regsvr32 it . ' nowait
		Return .F.
	EndIf
	*!*		Try
	*!*			oJmail=CreateObject('Jmail.Message')
	*!*		Catch
	*!*			oJmail=.Null.
	*!*		EndTry
	*!*		If IsNull(oJmail) Then
	*!*			Wait window 'Please sure the file jmail.dll in your system and regsvr32 it . ' nowait
	*!*			Return .F.
	*!*		EndIf
	oJmail.Logging=.T.
	oJmail.Silent=.T.
	oJmail.From=cFrom
	If IsValidStr(cTo) Then
		For nTag=1 to Occurs(';',cTo)+1
			If ','$ItSubstr(cTo,';',nTag) Then
				oJmail.AddRecipient(ItSubstr(ItSubstr(cTo,';',nTag),',',1),ItSubstr(ItSubstr(cTo,';',nTag),',',2))
			Else
				oJmail.AddRecipient(ItSubstr(cTo,';',nTag))
			EndIf
		EndFor
	EndIf
	If IsValidStr(cCC) Then
		For nTag=1 to Occurs(';',cCC)+1
			If ','$ItSubstr(cTo,';',nTag) Then
				oJmail.AddRecipientCC(ItSubstr(ItSubstr(cCC,';',nTag),',',1),ItSubstr(ItSubstr(cCC,';',nTag),',',2))
			Else
				oJmail.AddRecipientCC(ItSubstr(cCC,';',nTag))
			EndIf
		EndFor
	EndIf
	If IsValidStr(cBCC) Then
		For nTag=1 to Occurs(';',cBCC)+1
			If ','$ItSubstr(cTo,';',nTag) Then
				oJmail.AddRecipientBCC(ItSubstr(ItSubstr(cBCC,';',nTag),',',1),ItSubstr(ItSubstr(cBCC,';',nTag),',',2))
			Else
				oJmail.AddRecipientBCC(ItSubstr(cBCC,';',nTag))
			EndIf
		EndFor
	EndIf
	oJmail.Subject=Iif(IsValidStr(cSubject),cSubject,'')
	oJmail.Body=Iif(IsValidStr(cBody),cBody,'')
	If IsValidStr(cAttachment) Then
		For nTag=1 to Occurs(';',cAttachment)+1
			oJmail.AddAttachment(ItSubstr(cAttachment,';',nTag))
		EndFor
	EndIf
	oJmail.Charset=cCharSet
	If oJmail.Send(cUserName+':'+cPassword+'@'+cSmtp) Then
		Return .T.
	Else
		Wait window oJmail.ErrorMessage nowait
		Return .F.
	EndIf
Endproc
*------
Procedure ConvertToAsc() && Old name cGetAsc(), Convert any type value in charcters and only can get the left 50th char.
	Lparameters cValue,cAorZ
	If Empty(Pcount()) Then
		Return ''
	EndIf
	If Not IsValidStr(cAorZ) or Not InList(Upper(cAorZ),Upper('A'),Upper('Z')) Then
		cAorZ='A' && The default value Ascending
	Else
		cAorZ=Upper(cAorZ)
	EndIf
	Local cValueType,cReturnValue
	cValueType=Vartype(cValue)
	cReturnValue=''
	Do Case
		Case cValueType='C'
			cReturnValue=cValue
		Case cValueType='N'
			cReturnValue=Str(cValue,20,10)
		Case cValueType='D'
			cReturnValue=Dtoc(cValue)
		Case cValueType='T'
			cReturnValue=Ttoc(cValue)
		Case cValueType='L'
			cReturnValue=Iif(cValue,'.T.','.F.')
		Otherwise
			cReturnValue=''
	EndCase
	*!*		If Len(cReturnValue)<50 Then
	*!*			cReturnValue=Padr(cReturnValue,50,' ')
	*!*		Else
	If Val(Left(Version(4),2))<>6 Then && If version not in 6 only can sort width in 50 characters such as VF9
		cReturnValue=Padr(cReturnValue,50,' ')
	EndIf
	*!*		EndIf
	*!*		If cAorZ='Z' Then && Descending
	*!*			Local cTempValue
	*!*			cTempValue=cReturnValue
	*!*			cReturnValue=''
	*!*			For nTag=1 to Lenc(cTempValue)
	*!*				cReturnValue=cReturnValue+Chr(Int(65279-Asc(Substrc(cTempValue,nTag,1))))
	*!*			EndFor
	*!*		EndIf
	Return cReturnValue
EndProc
*------
Procedure ConvertToInt() && Old name nGetAsc(), Convert any type value in Integer
	Lparameters cValue,cAorZ
	If Empty(Pcount()) Then
		Return ''
	EndIf
	If Not IsValidStr(cAorZ) or Not InList(Upper(cAorZ),Upper('A'),Upper('Z')) Then
		cAorZ='A' && The default value Ascending
	Else
		cAorZ=Upper(cAorZ)
	EndIf
	Local cValueType,cReturnValue
	cValueType=Vartype(cValue)
	cReturnValue=''
	Do Case
		Case cValueType='C'
			cReturnValue=cValue
		Case cValueType='N'
			cReturnValue=Str(cValue,20,10)
		Case cValueType='D'
			cReturnValue=Dtoc(cValue)
		Case cValueType='T'
			cReturnValue=Ttoc(cValue)
		Case cValueType='L'
			cReturnValue=Iif(cValue,'.T.','.F.')
		Otherwise
			cReturnValue=''
	EndCase
	If Len(cReturnValue)>50 Then
		cReturnValue=Padr(cReturnValue,50,' ')
	EndIf
	Local nReturnValue,nTag
	nReturnValue=0
	For nTag=1 to Lenc(cReturnValue)
		nReturnValue=nReturnValue+Asc(Substrc(cReturnValue,nTag,1))*2^(Lenc(cReturnValue)-nTag)
	EndFor
	If cAorZ='Z' Then && Descending
		nReturnValue=-nReturnValue
	EndIf
	Return nReturnValue
EndProc
*------
*!*	Procedure nEncrypt&& Question
*!*		Lparameters cString
*!*		If Empty(cString) Then
*!*			Return 0
*!*		EndIf
*!*		If Not IsValidStr(cString,.T.) Then
*!*			Return 0
*!*		EndIf
*!*		Local nReturnValue,nTag,nLeng
*!*		Store 0 to nReturnValue,nTag
*!*		nLeng=Lenc(cString)
*!*		For nTag=1 to Lenc(cString)
*!*			nReturnValue=nReturnValue+Asc(Substrc(cString,nTag,1))+(2^(nLeng-nTag))
*!*		EndFor
*!*		Return nReturnValue
*!*	EndProc
*------
Procedure cEncrypt
	Lparameters cString
	cString=DefCharacters(cString,'',.T.)
	cString=Strconv(cString,15)
	cString=String_Transfer(cString)
	cString=Strconv(cString,16)
	Return cString
EndProc
*------
Procedure cDecrypt 
	Lparameters cString
	cString=DefCharacters(cString,'',.T.)
	cString=Strconv(cString,15)
	cString=String_Transfer(cString)
	cString=Strconv(cString,16)
	Return cString
EndProc
*------
Procedure nCalc && UnFinished
	Lparameters nExp,nMin,nMax
	If Not IsNumber(nExp) Then
		Return 0
	Endif
	If Not IsNumber(nMin) Or Not IsNumber(nMax) Then
		Return nExp
	Endif
	If nMax<nMin Then
		Local nTempValue
		nTempValue=nMax
		nMax=nMin
		nMin=nTempValue
	EndIf
	
	Local nPeriod,nMod,nReturnValue
	nPeriod=nMax-nMin+1
	nMod=Mod(nExp,nPeriod)
EndProc
*------
Procedure cCreateCustMsg
	Lparameters cCustomer_ID
	cCustomer_ID=DefCharacters(cCustomer_ID)
	Local nSelect
	nSelect=Select()
	If Not Used('Customer_Msg') Then
		Use in 0 customer Alias Customer_msg Again Shared
	EndIf
	If Not Seek(cCustomer_ID,'Customer_msg','Customer_I') Then
		If Used('Customer_msg') Then
			Use in customer_msg
		EndIf
		Create Cursor _CustMsg(Contact_name c (50),Contact_Title c (50),Phone c (50),Cable c (80))
		Append Blank in _CustMsg && Default
		Select (nSelect)
		Return ''
	EndIf
	Create Cursor _CustMsg(Contact_name c (50),Contact_Title c (50),Phone c (50),Cable c (80))
	If Not Empty(Customer_msg.Contact_name) Then
		Append Blank in _CustMsg
		Replace _Custmsg.Contact_name with Customer_msg.Contact_name
		Replace _Custmsg.Contact_Title with Customer_msg.Contact_Title
		Replace _Custmsg.Phone with Customer_msg.Phone
		Replace _CustMsg.Cable with Customer_msg.Cable
	EndIf
	If Not Empty(Customer_msg.Contact1) Then
		Append Blank in _CustMsg
		Replace _Custmsg.Contact_name with Customer_msg.Contact1
		Replace _custmsg.Contact_Title with Customer_msg.Titile1
		Replace _custmsg.Phone with Customer_msg.Phone1
		Replace _Custmsg.Cable with Customer_msg.Email1
	EndIf
	If Not Empty(Customer_msg.Contact2) Then
		Append Blank in _CustMsg
		Replace _Custmsg.Contact_name with Customer_msg.Contact2
		Replace _custmsg.Contact_Title with Customer_msg.Titile2
		Replace _custmsg.Phone with Customer_msg.Phone2
		Replace _custmsg.Cable with Customer_msg.Email2
	EndIf
	If Not Empty(Customer_msg.Contact3) Then
		Append Blank in _Custmsg
		Replace _Custmsg.Contact_name with Customer_msg.Contact3
		Replace _Custmsg.Contact_Title with Customer_msg.Titile3
		Replace _Custmsg.Phone with Customer_msg.Phone3
		Replace _Custmsg.Cable with Customer_msg.Email3
	Endif
	
	
	If Not Used('Custattn_Msg') Then
		Use In 0 custattn Again Shared Alias Custattn_msg
	Endif
	Select CustAttn_msg
	Set Order To CUSTOMER_I   && UPPER(CUSTOMER_ID) 
	
	If Seek(cCustomer_ID,'Custattn_msg','Customer_I') Then
		Select CustAttn_msg
		Scan Rest While Alltrim(Upper(CustAttn_msg.Customer_ID))==Alltrim(Upper(cCustomer_ID))
			If Not Empty(Alltrim(Custattn_msg.Contact_name)) Then
				Append Blank In _Custmsg
				Replace _Custmsg.Contact_name With Custattn_msg.Contact_name
				Replace _Custmsg.Contact_Title With Custattn_msg.Title
				Replace _Custmsg.Phone With Custattn_msg.Phone
				Replace _Custmsg.Cable With Custattn_msg.email
			Endif
		EndScan
	Endif
	
	If Used('Custattn_msg') Then
		Use In Custattn_msg
	EndIf
			
	
	Append Blank in _CustMsg && Default
	If Used('Customer_msg') Then
		Use in Customer_msg
	EndIf
	Goto Top in _Custmsg
	Select (nSelect)
	Return _Custmsg.Contact_name
EndProc
*------
Procedure lDownloadFiles
	Lparameters cSource,cTarget,lErrored
	&& May be can add more parameters that can ask user to select the directotry or change the target file name
	If Not IsValidStr(cSource) Then
		Return .F.
	Else
		cSource=Alltrim(cSource)
	EndIf
	If Not IsValidStr(cTarget) Then
		cTarget=cSource
	Else
		cTarget=Alltrim(cTarget)
		If Upper(cTarget)==Upper(cSource) Then
			Wait window 'No need to download : '+"'"+cTarget+"'" nowait
			Return .F.
		EndIf
	EndIf
	If Empty(JustPath(cTarget)) or Not Directory(JustPath(cTarget)) Then && Check the target directory
		cTarget=Addbs(Set('Directory'))+JustFname(cTarget)
	EndIf
	If Empty(JustFname(cTarget)) Then && Check the target fname
		cTarget=Addbs(JustPath(cTarget))+JustFname(cSource)
	EndIf
	If Empty(JustExt(cTarget)) Then && Check the target extension name
		If Empty(JustExt(cSource)) or !Between(Lenc(JustExt(cSource)),1,5) Then
			cTarget=ForceExt(cTarget,'Html') && Default extension name
		Else
			cTarget=ForceExt(cTarget,JustExt(cSource))
		EndIf
	EndIf
	&& May by can check the special character in target file name here, or strtran the other character for the special characters
	DECLARE   INTEGER   URLDownloadToFile   IN   urlmon.dll;
		INTEGER   pCaller,   STRING   szURL,   STRING   szFileName,;
		INTEGER   dwReserved,   INTEGER   lpfnCB
	lErrored=.F. && The default value
	Try
		URLDownloadToFile   (0,cSource,cTarget,0,0)
	Catch
		lErrored=.T.
	EndTry
	Clear Dlls URLDownloadToFile
	If lErrored or Not File(cTarget) Then
		Wait window 'Download file : '+"'"+cTarget+"'"+' failed .' nowait
		Return .F.
	Else
		Wait window 'Download file : '+"'"+cTarget+"'"+' successed !' nowait
		Return .T.
	EndIf
EndProc
*------
Procedure nSearchFiles && Question Set Default To 'D:\History\Paul\UnType\Roger\Target\Gulf Database'   ?nSearchFiles('3-ABU_DHABI_&_AL_AIN_BUSINESS_DIRECTORY__*.dbf') && 0
	Lparameters cFileSkeleton,cPath,lSubInclude,cAttribute
	Local nReturnValue
	nReturnValue=0
	cPath=DefCharacters(cPath,Set('Directory'))
	If Not Directory(cPath) Then
		cPath=GetDir('','','Which directory do you want to search now ?')
		If Empty(cPath) or Not Directory(cPath) Then
			Return nReturnValue
		EndIf
	EndIf
	cPath=Addbs(cPath)
	If Not IsValidStr(cFileSkeleton) Then
		cFileSkeleton='*.*'
	EndIf
	Local nTag,cCondition,cTmpCondition
	cCondition=[Not(Alltrim(Fname)=='.' or Alltrim(Fname)=='..') and Not Upper('D') $ Upper(Fattrib)]
	If Not Empty(Alltrim(cFileSkeleton)) Then
		For nTag=1 to Occurs(',',cFileSkeleton)+1
			If Not Empty(Alltrim(ItSubstr(cFileSkeleton,',',nTag))) Then
				If Empty(cTmpCondition) Then
					cTmpCondition='Likec("'+Upper(Alltrim(ItSubstr(cFileSkeleton,',',nTag)))+'",Upper(Alltrim(Fname)))'
				Else
					cTmpCondition=cTmpCondition+' or Likec("'+Upper(Alltrim(ItSubstr(cFileSkeleton,',',nTag)))+'",Upper(Alltrim(Fname)))'
				EndIf
			EndIf
		EndFor
	EndIf
	If Not Empty(cTmpCondition) Then
		cCondition=cCondition+' and ('+cTmpCondition+')'
	EndIf
	cFileSkeleton=cCondition
	cAttribute=cChaReplace(cAttribute,'RASHD',.T.) && RASHDV include all attribute,V that mean return driver label of the cPath
	If Vartype(lSubInclude)<>Upper('L') Then
		lSubInclude=.F. && The default value
	EndIf
	If Not Upper('D') $ Upper(cAttribute) Then && The default value should add 'D',Else if will show error message when therer is a empty directory
		cAttribute=cAttribute+'D'
	EndIf
	Create Cursor sResult (Fname c (254),Fpath n (20),Adate d ,Atime c (8),Fattrib c (6))
	Append Blank in sResult
	Replace sResult.Fname with cPath
	Wait window 'Begin to search in '+"'"+cPath+"'"+' ……' nowait
	lTravelDir(cFileSkeleton,cPath,lSubInclude,cAttribute)
	nReturnValue=Reccount('sResult')-1
	If nReturnValue<=0 Then
		Wait window 'Search is complete. There are no results to display.' nowait
	Else
		Wait window 'Total '+Alltrim(Str(nReturnValue))+' files , Search finished ！' nowait
	EndIf
	Return nReturnValue
Endproc
*------
Procedure lTravelDir
	Lparameters cFileSkeleton,cPath,lSubInclude,cAttribute
	If Not IsValidStr(cPath) or Not Directory(cPath) Then
		Return .F.
	EndIf
	Private nTag,SearchArray
	ADir(SearchArray,cPath+'*.*',cAttribute,1)
	For nTag=1 to Alen(SearchArray,1)
		If Not(Alltrim(SearchArray(nTag,1))=='.' or Alltrim(SearchArray(nTag,1))=='..') && If it is empty directory.
			SearchArray(nTag,1)=Addbs(cPath)+SearchArray(nTag,1) && Get the full path
			If lSubInclude Then && Search the sub directory
				If Upper('D')$ SearchArray(nTag,5) Then && If it's directory
					Wait window 'Search in '+"'"+SearchArray(nTag,1)+"'"+' now……' nowait
					lTravelDir(cFileSkeleton,Addbs(SearchArray(nTag,1)),lSubInclude,cAttribute)
				EndIf
			EndIf
		EndIf
	EndFor
	If Upper(Alias())=Upper('sResult') Then
		Append From array SearchArray for &cFileSkeleton.
	EndIf
EndProc
*------
Procedure DefLogic
	Lparameters plLogicValue
	If Vartype(plLogicValue)<>Upper('L') Then
		Return .F.
	Else
		Return plLogicValue
	EndIf
EndProc
*------
Procedure DefCharacters
	Lparameters pcCharacters,pcDefValue,plIgnoreEmptyCharacters
	plIgnoreEmptyCharacters=DefLogic(plIgnoreEmptyCharacters)
	If Vartype(pcDefValue)<>Upper('C') Then
		pcDefValue='' && The default value
	EndIf
	If IsValidStr(pcCharacters,plIgnoreEmptyCharacters) Then
		Return pcCharacters
	Else
		Return pcDefValue
	EndIf
EndProc
*------
Procedure CreateMemo
	Local cCursorAlias,nSelect
	cCursorAlias=AliasName()
	nSelect=Select()
	Create Cursor &cCursorAlias. (mMemo m)
	Append Blank in &cCursorAlias.
	Select (nSelect)
	Return cCursorAlias+'.mMemo'
EndProc
*------
Procedure DefNumber
	Lparameters pcExp,pnDefValue
	If Vartype(pnDefValue)<>Upper('N') tHEN
		pnDefValue=0 && The default value is 0
	EndIf
	If Vartype(pcExp)==Upper('N') Then
		Return pcExp
	Else
		Return pnDefValue
	EndIf
EndProc
*------
*!*	Procedure GetAlias && Question , ? GetAlias('2a.dbf') && "" empty now
*!*		Lparameters cDbfAlias,lOpenAgainRandom

*!*		* Check the parameters first.
*!*		lOpenAgainRandom = DefLogic(lOpenAgainRandom) && The default value is no need open again

*!*		Local cReturnValue,nSelect,cTmpAlias
*!*		cReturnValue=''
*!*		nSelect=Select()
*!*		If IsValidStr(cDbfAlias) Then
*!*	*!*			cDbfAlias=JustFname(cDbfAlias) && Comment by roger at 2010-06-12 17:22 if use c:\temp\test\abc.dbf but the current directory is d:\, it will be errored. (If not comment this line code)
*!*			If lOpenAgainRandom Then
*!*				cTmpAlias=JustStem(cDbfAlias)+AliasName() && Generate a random alias
*!*				If LcDbfOpen(cDbfAlias,cTmpAlias) Then
*!*					cReturnValue=cTmpAlias && Else the default value should store '' to cReturnValue
*!*				EndIf
*!*			Else && No need to open again if the table has been opened or can open it
*!*				If Select(JustStem(cDbfAlias)) > 0 or LcDbfOpen(cDbfAlias,cDbfAlias) Then
*!*					cReturnValue = JustStem(cDbfAlias) && Else the default value shoudl store '' to cReturnValue
*!*				Else && Not opened and can't open
*!*					WaitWindow('The table '+"'"+cDbfAlias+"'"+' not opened and can not open.',Sys(16))
*!*				EndIf
*!*			EndIf
*!*		Else
*!*			cReturnValue=Alias()
*!*		EndIf
*!*		Select (nSelect)
*!*		Return cReturnValue
*!*	EndProc
*------
Procedure GetAlias && Question , ? GetAlias('2a.dbf') && "" empty now
	Lparameters cDbfAlias
	
	* New verion write by Roger at 2011-12-6
	Local cReturnValue,nSelect,cTmpAlias
	cReturnValue = ''
	nSelect		 = Select()
	
	*!*	cDbfAlias=JustFname(cDbfAlias) && Comment by roger at 2010-06-12 17:22 if use c:\temp\test\abc.dbf but the current directory is d:\, it will be errored. (If not comment this line code)
	If IsValidStr(cDbfAlias) Then
		If Select(JustStem(cDbfAlias)) > 0 Then
			cReturnValue = JustStem(cDbfAlias)
		Else
			cTmpAlias = JustStem(cDbfAlias)+AliasName() && Generate a random alias
			If LcDbfOpen(cDbfAlias,cTmpAlias) Then
				cReturnValue = cTmpAlias
			Else
				WaitWindow('The table of '+"'"+cDbfAlias+"'"+' not opened and can not open again.',Sys(16))
				cReturnValue = '' && Actualy no need to write this line code ,Because its default '' in the last return value.
			EndIf
		EndIf
	Else
		cReturnValue = Alias()
	EndIf
	
	* Restore the environment.
	Select (nSelect)
	
	Return cReturnValue
EndProc
*------
Procedure nReccount
	Lparameters pcAlias,plAvail,plAutoClose
	plAvail=DefLogic(plAvail)
	plAutoClose=DefLogic(plAutoClose)
	Local nReturnValue,nSelect,cAlias
	nReturnValue=0
	nSelect=Select()
	cAlias=GetAlias(pcAlias)
	If Empty(cAlias) Then && Empty(GetAlias(……)) mean's no table pcAlias or can not open the table pcAlias
		WaitWindow('There is no table is open in the current work area.',Proper(Sys(16)))
		Select (nSelect)
		Return nReturnValue
	Else
		Select (cAlias) && Select the alias which table will be deal with
	EndIf
	If plAvail Then && Count the not delete recno
		Count to nReturnValue for not Deleted()
	Else
		nReturnValue=Reccount()
	EndIf
	If plAutoClose Then
		LcDbfClose(cAlias)
	EndIf
	Return nReturnValue
EndProc
*------
Procedure WaitWindow
	Lparameters cMessage,cProcedure,lWait,cVariableName,nTimeout
	Local cWaitWindow
	cWaitWindow='Wait window '
	If IsValidStr(cMessage,.T.) Then
		cWaitWindow=cWaitWindow+'['+cMessage+']'
	EndIf
	If IsValidStr(cProcedure) Then
		cWaitWindow=cWaitWindow+'+[ | '+Proper(cProcedure)+']'
	EndIf
	If Vartype(lWait)<>Upper('L') or Not lWait Then
		cWaitWindow=cWaitWindow+' nowait'
	Endif
	If IsValidStr(cVariableName) Then
		cWaitWindow=cWaitWindow+' to '+cVariableName
	EndIf
	If Vartype(nTimeOut)=Upper('N') and Not Empty(nTimeout) Then
		cWaitWindow=cWaitWindow+' timeout Val(['+Str(nTimeOut)+'])'
	EndIf
	&cWaitWindow.
	If IsValidStr(cVariableName) Then
		Return &cVariableName
	Else
		Return '' && The default value
	EndIf
EndProc
*------
Procedure cGetMess() && This can not change name , Because it's has been used in man reports
	Lparameters cKeyvalue,cAlias,cTag,nTag,lName
	If Not IsValidStr(cKeyValue) Then && If is not string or empty string ,IsValidStr will return ''
		Return ''
	EndIf
	If Not IsValidStr(cAlias) Then
		cAlias=''
	EndIf
	Local nSelect
	nSelect=Select()
	cAlias=GetAlias(cAlias)
	If Empty(cAlias) Then
		Select (nSelect)
		Return ''
	Else
		Select (cAlias)
	EndIf
	If Not IsValidStr(cTag) Then
		cTag=GetPrimaryKey()
	EndIf
	If Empty(cTag) Then
		WaitWindow('Please sure the key tag not empty!',Sys(16))
		LcDbfClose(cAlias)
		Select (nSelect)
		Return ''
	Else
		If Not Seek(cKeyValue,Alias(),cTag) Then
			WaitWindow('Can not found the value '+cKeyValue+' in alias '+Alias()+' tag '+cTag,Sys(16))
			LcDbfClose(cAlias)
			Select (nSelect)
			Return ''
		EndIf
	EndIf
	If Vartype(nTag)<>Upper('N') Then
		nTag=0 && The default value will return all message.
	EndIf
	lName=DefLogic(lName) && If not a logic value it will return .f.

	Local cReturnValue,cLine,cColon
	cReturnValue=''
	cLine=Chr(13)+Chr(10)
	cColon=': '
	Do Case
		Case nTag=0 && Return all message include (Company_name,Company_name2,Address,Address2,Address3,Address4,Contact_name,Phone,Fax,Email
			&& May be can ergodic this procedure from 1 to 5 if have enough time
			If IsFieldExist('Company_name') and IsValidStr(Company_name) Then
				If IsValidStr(cReturnValue) Then && Not empty string
					cReturnValue=cReturnValue+cLine+Iif(lName,Tb_Company+cColon+Alltrim(Company_name),Alltrim(Company_name))
				Else
					cReturnValue=Iif(lName,Tb_Company+cColon+Alltrim(Company_name),Alltrim(Company_name))
				EndIf
			EndIf
			If IsFieldExist('Company_name2') and IsValidStr(Company_name2) Then
				If IsValidStr(cReturnValue) Then
					If IsValidStr(Company_name) Then && It's have add company_name
						cReturnValue=cReturnValue+cLine+Iif(lName,Space(Len(Tb_Company+cColon)),'')+Alltrim(Company_name2)
					Else
						cReturnValue=cReturnValue+cLine+Iif(lName,Tb_Company,'')+Alltrim(Company_name2)
					EndIf
				Else
					cReturnValue=Iif(lName,Tb_Company+cColon+Alltrim(Company_name2),Alltrim(Company_name2))
				EndIf
			EndIf

			If IsFieldExist('Address') and IsValidStr(Address) Then
				If IsValidStr(cReturnValue) Then
					cReturnValue=cReturnValue+cLine+Iif(lName,Tb_Address+cColon+Alltrim(Address),Alltrim(Address))
				Else
					cReturnValue=Iif(lName,Tb_Address+cColon+Alltrim(Address),Alltrim(Address))
				EndIf
			EndIf
			If IsFieldExist('Address2') And IsValidStr(Address2) Then
				If IsValidStr(cReturnValue) Then
					If IsValidStr(Address) Then && It's have add tb_address
						cReturnValue=cReturnValue+cLine+Iif(lName,Space(Len(Tb_Address+cColon)),'')+Alltrim(Address2)
					Else
						cReturnValue=cReturnValue+cLine+Iif(lName,Tb_Address+cColon,'')+Alltrim(Address2)
					EndIf
				Else
					cReturnValue=Iif(lName,Tb_Address+cColon+Alltrim(Address2),Alltrim(Address2))
				EndIf
			EndIf
			If IsFieldExist('Address3') and IsValidStr(Address3) Then
				If IsValidStr(cReturnValue) Then
					If IsValidStr(Address) or IsValidStr(Address2) Then && It's have add tb_address
						cReturnValue=cReturnValue+cLine+Iif(lName,Space(Len(Tb_Address+cColon)),'')+Alltrim(Address3)
					Else
						cReturnValue=cReturnValue+cLine+Iif(lName,Tb_Address+cColon,'')+Alltrim(Address3)
					EndIf
				Else
					cReturnValue=Iif(lName,Tb_Address+cColon+Alltrim(Address3),Alltrim(Address3))
				EndIf
			EndIf
			If IsFieldExist('Address4') and IsValidStr(Address4) Then
				If IsValidStr(cReturnValue) Then
					If IsValidStr(Address) or IsValidStr(Address2) or IsValidStr(Address3) Then && It's have add tb_address
						cReturnValue=cReturnValue+cLine+Iif(lName,Space(Len(Tb_Address+cColon)),'')+Alltrim(Address4)
					Else
						cReturnValue=cReturnValue+cLine+Iif(lName,Tb_Address+cColon,'')+Alltrim(Address4)
					EndIf
				Else
					cReturnValue=Iif(lName,Tb_Address+cColon+Alltrim(Address4),Alltrim(Address4))
				EndIf
			EndIf

			If IsFieldExist('Contact_name') and IsValidStr(Contact_name) Then
				If IsValidStr(cReturnValue) Then
					cReturnValue=cReturnValue+cLine+Iif(lName,Tb_Attn+cColon+Alltrim(Contact_name),Alltrim(Contact_name))
				Else
					cReturnValue=Iif(lName,Tb_Attn+cColon+Alltrim(Contact_name),Alltrim(Contact_name))
				EndIf
			EndIf

			If IsFieldExist('Phone') And IsValidStr(Phone) Then
				If IsValidStr(cReturnValue) Then
					cReturnValue=cReturnValue+cLine+Iif(lName,Tb_Phone+cColon+Alltrim(Phone),Alltrim(Phone))
				Else
					cReturnValue=Iif(lName,Tb_Phone+cColon+Alltrim(Phone),Alltrim(Phone))
				EndIf
			EndIf
			If IsFieldExist('Fax') and IsValidStr(Fax) Then
				If IsValidStr(cReturnValue) Then
					cReturnValue=cReturnValue+cLine+Iif(lName,Tb_Fax+cColon+Alltrim(Fax),Alltrim(Fax))
				Else
					cReturnValue=Iif(lName,Tb_Fax+cColon+Alltrim(Fax),Alltrim(Fax))
				EndIf
			EndIf

			If IsFieldExist('Cable') and IsValidStr(Cable) Then && It's will ignore the mast table . Because no cable field in any mast table.
				If IsValidStr(cReturnValue) Then
					cReturnValue=cReturnValue+cLine+Iif(lName,Tb_Email+cColon+Alltrim(Cable),Alltrim(Cable))
				Else
					cReturnValue=Iif(lName,Tb_Email+cColon+Alltrim(Cable),Alltrim(Cable))
				EndIf
			EndIf
		Case nTag=1 && Company_name
			If IsFieldExist('Company_name') and IsValidStr(Company_name) Then
				If IsValidStr(cReturnValue) Then && Not empty string
					cReturnValue=cReturnValue+cLine+Iif(lName,Tb_Company+cColon+Alltrim(Company_name),Alltrim(Company_name))
				Else
					cReturnValue=Iif(lName,Tb_Company+cColon+Alltrim(Company_name),Alltrim(Company_name))
				EndIf
			EndIf
			If IsFieldExist('Company_name2') and IsValidStr(Company_name2) Then
				If IsValidStr(cReturnValue) Then
					If IsValidStr(Company_name) Then && It's have add company_name
						cReturnValue=cReturnValue+cLine+Iif(lName,Space(Len(Tb_Company+cColon)),'')+Alltrim(Company_name2)
					Else
						cReturnValue=cReturnValue+cLine+Iif(lName,Tb_Company,'')+Alltrim(Company_name2)
					EndIf
				Else
					cReturnValue=Iif(lName,Tb_Company+cColon+Alltrim(Company_name2),Alltrim(Company_name2))
				EndIf
			EndIf
		Case nTag=2 && Address
			If IsFieldExist('Address') and IsValidStr(Address) Then
				If IsValidStr(cReturnValue) Then
					cReturnValue=cReturnValue+cLine+Iif(lName,Tb_Address+cColon+Alltrim(Address),Alltrim(Address))
				Else
					cReturnValue=Iif(lName,Tb_Address+cColon+Alltrim(Address),Alltrim(Address))
				EndIf
			EndIf
			If IsFieldExist('Address2') And IsValidStr(Address2) Then
				If IsValidStr(cReturnValue) Then
					If IsValidStr(Address) Then && It's have add tb_address
						cReturnValue=cReturnValue+cLine+Iif(lName,Space(Len(Tb_Address+cColon)),'')+Alltrim(Address2)
					Else
						cReturnValue=cReturnValue+cLine+Iif(lName,Tb_Address+cColon,'')+Alltrim(Address2)
					EndIf
				Else
					cReturnValue=Iif(lName,Tb_Address+cColon+Alltrim(Address2),Alltrim(Address2))
				EndIf
			EndIf
			If IsFieldExist('Address3') and IsValidStr(Address3) Then
				If IsValidStr(cReturnValue) Then
					If IsValidStr(Address) or IsValidStr(Address2) Then && It's have add tb_address
						cReturnValue=cReturnValue+cLine+Iif(lName,Space(Len(Tb_Address+cColon)),'')+Alltrim(Address3)
					Else
						cReturnValue=cReturnValue+cLine+Iif(lName,Tb_Address+cColon,'')+Alltrim(Address3)
					EndIf
				Else
					cReturnValue=Iif(lName,Tb_Address+cColon+Alltrim(Address3),Alltrim(Address3))
				EndIf
			EndIf
			If IsFieldExist('Address4') and IsValidStr(Address4) Then
				If IsValidStr(cReturnValue) Then
					If IsValidStr(Address) or IsValidStr(Address2) or IsValidStr(Address3) Then && It's have add tb_address
						cReturnValue=cReturnValue+cLine+Iif(lName,Space(Len(Tb_Address+cColon)),'')+Alltrim(Address4)
					Else
						cReturnValue=cReturnValue+cLine+Iif(lName,Tb_Address+cColon,'')+Alltrim(Address4)
					EndIf
				Else
					cReturnValue=Iif(lName,Tb_Address+cColon+Alltrim(Address4),Alltrim(Address4))
				EndIf
			EndIf
		Case nTag=3 && Contact_name
			If IsFieldExist('Contact_name') and IsValidStr(Contact_name) Then
				If IsValidStr(cReturnValue) Then
					cReturnValue=cReturnValue+cLine+Iif(lName,Tb_Attn+cColon+Alltrim(Contact_name),Alltrim(Contact_name))
				Else
					cReturnValue=Iif(lName,Tb_Attn+cColon+Alltrim(Contact_name),Alltrim(Contact_name))
				EndIf
			EndIf
		Case nTag=4 && Phone and fax
			If IsFieldExist('Phone') And IsValidStr(Phone) Then
				If IsValidStr(cReturnValue) Then
					cReturnValue=cReturnValue+cLine+Iif(lName,Tb_Phone+cColon+Alltrim(Phone),Alltrim(Phone))
				Else
					cReturnValue=Iif(lName,Tb_Phone+cColon+Alltrim(Phone),Alltrim(Phone))
				EndIf
			EndIf
			If IsFieldExist('Fax') and IsValidStr(Fax) Then
				If IsValidStr(cReturnValue) Then
					cReturnValue=cReturnValue+cLine+Iif(lName,Tb_Fax+cColon+Alltrim(Fax),Alltrim(Fax))
				Else
					cReturnValue=Iif(lName,Tb_Fax+cColon+Alltrim(Fax),Alltrim(Fax))
				EndIf
			EndIf
		Case nTag=5 && Email
			If IsFieldExist('Cable') and IsValidStr(Cable) Then && It's will ignore the mast table . Because no cable field in any mast table.
				If IsValidStr(cReturnValue) Then
					cReturnValue=cReturnValue+cLine+Iif(lName,Tb_Email+cColon+Alltrim(Cable),Alltrim(Cable))
				Else
					cReturnValue=Iif(lName,Tb_Email+cColon+Alltrim(Cable),Alltrim(Cable))
				EndIf
			EndIf
	EndCase
	LcDbfClose(cAlias)
	Select (nSelect)
	Return cReturnValue
EndProc
*------
Procedure cChaReplace
	Lparameters cCharacters,cNewCharacters,lDelEcho
	If Not IsValidStr(cCharacters) Then
		Return ''
	EndIf
	If Not IsValidStr(cNewCharacters) Then
		Return cCharacters
	EndIf
	lDelEcho=DefLogic(lDelEcho) && No need delete the echo value in cCharacters
	Local nTag,cReturnValue
	cReturnValue=''
	For nTag=1 to Lenc(cCharacters)
		If lDelEcho Then
			If Substrc(cCharacters,nTag,1)$cReturnValue Then
				Loop
			EndIf
		EndIf
		If Substrc(cCharacters,nTag,1) $ cNewCharacters Then
			cReturnValue=cReturnValue+Substrc(cCharacters,nTag,1)
		EndIf
	EndFor
	Return cReturnValue
EndProc
*------
&&DbfGroup('Order_no+Product_CO','Memo','Sequence','INV-00008','INV-00009','Order_ID','uTrim(Inv_ID)','Empty(uTrim(Group_ID))','Tmpinvbom','','Replace Group_ID with [AB]')
Procedure DbfGroup()
	Lparameters cGroupExp,cFieldsCnt_C,cFieldsSame_N,cDocFm,cDocTo,cOrder,cScanExp,cDocFilter,cDbf,cNewDbf,cRunExpInNewDbf
	If Not IsValidStr(cGroupExp,.T.) Then
		Return .F.
	EndIf
	If Not IsValidStr(cFieldsCnt_C,.T.) Then
		cFieldsCnt_C='' && The default value is empty string
	EndIf
	If Not IsValidStr(cFieldsSame_N,.T.) Then
		cFieldsSame_N='' && The default value is empty string
	EndIf
	If Not IsValidStr(cDocFm,.T.) or Not IsValidStr(cDocTo,.T.) Then
		WaitWindow('Please input a valid range first.',Sys(16))
		Return .F.
	Else
		If cDocFm>cDocTo Then
			WaitWindow('Please input a valid range first.',Sys(16))
			Return .F.
		EndIf
	EndIf
	Local nSelect,cAlias
	nSelect=Select()
	cAlias=GetAlias()
	If Empty(cAlias) Then
		WaitWindow('Can not found table to dispose.',Sys(16))
		Select (nSelect)
		Return .F.
	EndIf
	If Not IsValidStr(cOrder,.T.) Then
		If Empty(GetPrimaryKey(cAlias)) Then
			WaitWindow('Please type key first.',Sys(16))
			Select (nSelect)
			Return .F.
		Else
			cOrder=GetPrimaryKey(cAlias)
		EndIf
	EndIf
	If Not IsValidStr(cScanExp,.T.) Then
		If Empty(IndexToExp(cOrder,cAlias)) Then
			WaitWindow('Please type the scan range exp. first.',Sys(16))
			Select (nSeleect)
			Return .F.
		Else
			cScanExp=IndexToExp(cOrder,cAlias)
		EndIf
	EndIf
	If Not IsValidStr(cDocFilter) Then
		cDocFilter='.T.' && The default value no need to loop any records
	EndIf
	If IsValidStr(cNewDbf) Then
		Local cSet_Safety
		cSet_Safety=Set("Safety")
		Set Safety off && No need to ask if want to overwrite it.
		Select (cAlias)
		Copy Structure to (cNewDbf) with cdx
		Set Safety &cSet_Safety.
	Else
		cNewDbf=GetAlias(cDbf)
	EndIf
	If Not IsValidStr(cRunExpInNewDbf,.T.) Then
		cRunExpInNewDbf='' && No need to run any exp. in the new dbf
	EndIf
	Local cTmpAlias,cOrderExp,cGroupExpNew,cGroupExpOld,lAppend,nTag,nSubTag,cOldField,cNewField,lSubLoop
	cTmpAlias=GetAlias(cDbf)
	cOrderExp=IndexToExp(cOrder,cTmpAlias)
	Select (cTmpAlias)
	Set Order To cOrder
	Select (cAlias)
	Set Relation to &cOrderExp. into (cTmpAlias)
	cGroupExpOld=''
	**-----------------------------Ok, set the parameters finished, The next step need to write coding now -------------------------------
	Select (cAlias)
	Set Order To cOrder
	=Seek(cDocFm,cAlias,cOrder)
	Scan rest while &cScanExp.>=cDocFm and &cScanExp.<=cDocTo
		If Not (&cDocFilter.) Then
			Loop
		EndIf
		cGroupExpNew=&cGroupExp.
		If not (cGroupExpNew==cGroupExpOld) Then && If the different group exp.
			lAppend=.T.
			cGroupExpOld=cGroupExpNew && The newlist exp. shoudl auto update
			Select (cTmpAlias)
			Scan rest while &cGroupExp.==cGroupExpNew
				If Not (&cDocFilter.) Then
					Loop
				EndIf
				If lAppend Then && Append new record into target table such as cNewDbf
					lAppend=.F. && No need append new record again if has append in the different group
					Append Blank in (cNewDbf)
					=RecordReplace(cNewDbf,cTmpAlias) && Append data to the target table
					Select (cNewDbf)
					&cRunExpInNewDbf.
				Else && Accumulate the number fields or character fields
					Select (cTmpAlias)
					For nTag=1 to Fcount()
						cOldField=Field(nTag)
						lSubLoop=.F.
						Do Case
							Case Type(cOldField)=Upper('N') && The default is no need to loop if the field is a number type
								If Not Empty(cFieldsSame_n) Then
									For nSubTag=1 to Occurs(',',cFieldsSame_n)+1
										If Upper(cOldField)==uTrim(ItSubstr(cFieldsSame_n,',',nSubTag)) Then
											lSubLoop=.T. && If is the special number field
											Exit
										EndIf
									EndFor
								EndIf
							Case InList(Type(cOldField),Upper('C'),Upper('M')) && Character or memo field
								lSubLoop=.T. && The default value need to loop, No need accumulate
								If Not Empty(cFieldsCnt_C) Then
									For nSubTag=1 to Occurs(',',cFieldsCnt_C)+1
										If Upper(cOldField)==uTrim(ItSubstr(cFieldsCnt_C,',',nSubTag)) Then
											lSubLoop=.F. && If is the special character or memo field
											Exit
										EndIf
									EndFor
								EndIf
							Otherwise
								lSubLoop=.T. && Any field type it will loop except the number and the special character or memo fields
						EndCase
						If lSubLoop Then
							Loop
						EndIf
						cNewField=cNewDbf+'.'+cOldField
						cOldField=cTmpAlias+'.'+cOldField
						If Type(cOldField)=Upper('N') Then
							Replace &cNewField. with &cNewField.+&cOldField.
						Else && InList(Type(cOldField),'C','M')
							If Type(cOldField)='C' Then
								Replace &cNewField. with Alltrim(&cNewField.)+Alltrim(&cOldField.)
							Else && M
								Replace &cNewField. with Alltrim(&cNewField.)+Chr(13)+Chr(10)+Alltrim(&cOldField.)
							EndIf
						EndIf
					EndFor
					&& &cRunExpInNewDbf. Because is not the new record
				EndIf
				Select (cTmpAlias)
			EndScan
		EndIf
	EndScan
	LcDbfClose(cAlias)
	LcDbfClose(cNewDbf)
	LcDbfClose(cTmpAlias)
	Select (nSelect)
	Return .T.
EndProc
*------
Procedure cAccField && This function as the same as the GetTableExp()
	Lparameters cAccExp,lIgnore,cAccTag,cSeekExp,cDbf,cOrder,cScanExp,cCondition,lAutoClose
	Local cReturnValue,nSelect,cAlias,cTmpCharacters
	cReturnValue=''
	If Not IsValidStr(cAccExp) Then
		Return cReturnValue
	EndIf
	lIgnore=DefLogic(lIgnore)
	cAccTag=DefCharacters(cAccTag,',',.T.) &&It will return ',' if cAccTag is not a character exp.
	cSeekExp=DefCharacters(cSeekExp,'',.T.)
	nSelect=Select()
	lAutoClose=DefLogic(lAutoClose) && Get the default logic value is .f.
	cAlias=GetAlias(cDbf)
	If Empty(cAlias) Then
		WaitWindow('No table can found to dispose.',Sys(16))
		Select (nSelect)
		Return cReturnValue
	EndIf
	cOrder=DefCharacters(cOrder)
	If Empty(cOrder) and Empty(GetPrimaryKey(cAlias)) Then
		WaitWindow('Can not found any order tag in table '+Proper(JustStem(Dbf(cAlias))),Sys(16))
		Select (nSelect)
		Return cReturnValue
	EndIf
	If IsValidStr(DefCharacters(cScanExp)) Then
		cScanExp=DefCharacters(cScanExp)
	Else
		cScanExp=IndexToExp(cOrder,cAlias)
	EndIf
	cCondition=DefCharacters(cCondition,'.T.')
	cTmpCharacters=CreateMemo()
	Select (cAlias)
	Set Order To cOrder
	=Seek(cSeekExp,cAlias,cOrder)
	Scan rest while &cScanExp.==cSeekExp
		If Not (&cCondition.) Then
			Loop
		EndIf
		If Not IsValidStr(&cAccExp.) Then
			Loop
		EndIf
		If Not lIgnore Then
			If IsInclude(&cTmpCharacters.,&cAccExp.,cAccTag,.T.) Then
				Loop
			EndIf
		EndIf
		Replace &cTmpCharacters. with Iif(Empty(&cTmpCharacters.),&cAccExp.,&cTmpCharacters.+cAccTag+&cAccExp.)
	EndScan
	cReturnValue=&cTmpCharacters.
	LcDbfClose(JustStem(cTmpCharacters))
	If lAutoClose THen
		LcDbfClose(cAlias)
	EndIf
	Select (nSelect)
	Return cReturnValue
EndProc
*------
Procedure nAccExp && Accumulative total but for numeric expression.
	Lparameters cAccExp,eSeekExpression,cDbfAlias,cOrder,cFilter
	
	* Check the necessary parameter value
	If !IsValidStr(cAccExp) Then
		Return 0
	EndIf
	If !IsValidStr(eSeekExpression) Then
		Return 0
	EndIf
	cFilter = DefCharacters(cFilter,'.T.')
		
	* Initial necessary data environment and variable
	Local nReturnValue,cScanExp,nSelect,cAlias,lNeedOpen
	nReturnValue = 0
	nSelect = Select()
	lNeedOpen = .T.
	
	* Check the table if need to open again.	
	If IsValidStr(cDbfAlias) Then && If the parameter cDbfAlias is a vaild string.
		If Select(cDbfAlias)>0 and IsValidStr(GetAlias(cDbfAlias)) Then && If cDbfAlias exist opened and no need to open again
			cAlias = GetAlias(cDbfAlias)
			lNeedOpen = .F.
		Else
			lNeedOpen = .T.
		EndIf
	Else
		If IsValidStr(GetAlias()) Then && If there is a table opened in the current select
			cAlias = GetAlias()
			lNeedOpen = .F.
		Else
			lNeedOpen = .T.
		EndIf
	EndIf
	* Confirm the table which need to dispose and check index information.
	If !lNeedOpen Then && If no need open the table, That's mean has been found a table to dispose
		If IsValidStr(cOrder) Then
			Select (cAlias)
			Set Order To &cOrder.
		Else
			If Empty(Order(cAlias)) Then
				Wait window 'No index seted. ' nowait
				Return nReturnValue
			Else
				cOrder = Order(cAlias)
			EndIf
		EndIf
	Else && Need to open the table base on cDbfAlias
		If IsValidStr(cDbfAlias) Then
			cAlias = AliasName()
		Else
			Wait window 'No table is open in the current work area, Please sent a parameter as table or alias name.' nowait
			Return nReturnValue
		EndIf
		If !IsValidStr(cOrder) Then
			Wait window 'No index seted. ' nowait
			Return nReturnValue
		EndIf
		If !LcDbfOpen(cDbfAlias,cAlias,.F.,cOrder) Then
			Return nReturnValue
		EndIf
	EndIf
	
	cScanExp = IndexToExp(cOrder,cAlias)
	If Empty(cScanExp) or !Seek(eSeekExpression,cAlias) Then
		If lNeedOpen Then
			LcDbfClose(cAlias)
		EndIf
		Select (nSelect)
		Return nReturnValue
	EndIf
	
	
	* Begain to dispose accumulative expression to return value
	Select (cAlias)
	Scan rest while evaluate(cScanExp) = eSeekExpression
		If !Evaluate(cFilter) Then
			Loop
		EndIf
		nReturnValue = nReturnValue + Evaluate(cAccExp)
	EndScan
	* End to dispose
	
	
	* Restore the environment
	If lNeedOpen Then
		LcDbfClose(cAlias)
	EndIf
	Select (nSelect)
		
		
	* Return value
	Return nReturnValue
EndProc
*------
Procedure GetDoc_Net && Base on iTrader database environment
	Lparameters eSeekExpression,cDbfAlias,cOrder,cAccExp,cFilter
	
	cAccExp = DefCharacters(cAccExp,;
				[ITROUND(1*quantity*(unit_price *(1-item_disc/100)-disc_amt)*(1+gst/100),total_decimal,ITPV(1))];
				)
	Return nAccExp(cAccExp,eSeekExpression,cDbfAlias,cOrder,cFilter)
EndProc
*------
Procedure GetItem_Amt
	Lparameters eSeekExpression,cDbfAlias,cOrder,cCount_Formula
	
	* Initial necessary data environment and variable
	Local nReturnValue,nSelect,cAlias,lNeedOpen
	nReturnValue = 0
	nSelect = Select()
	lNeedOpen = .T.
	cOrder = DefCharacters(cOrder)
	cCount_Formula = DefCharacters (cCount_Formula,;
								[ItRound(1*quantity*(unit_price *(1-item_disc/100)-disc_amt)*(1+gst/100),total_decimal,ITPV(1))];
								   )
	
	* Check the table if need to open again.	
	If IsValidStr(cDbfAlias) Then && If the parameter cDbfAlias is a vaild string.
		If Select(cDbfAlias)>0 and IsValidStr(GetAlias(cDbfAlias)) Then && If cDbfAlias exist opened and no need to open again
			cAlias = GetAlias(cDbfAlias)
			lNeedOpen = .F.
		Else
			lNeedOpen = .T.
		EndIf
	Else
		If IsValidStr(GetAlias()) Then && If there is a table opened in the current select
			cAlias = GetAlias()
			lNeedOpen = .F.
		Else
			lNeedOpen = .T.
		EndIf
	EndIf
	* Confirm the table which need to dispose and check index information.
	If !lNeedOpen Then && If no need open the table, That's mean has been found a table to dispose
		If !IsValidStr(cOrder) and !Empty(Order(cAlias)) Then
			cOrder = Order(cAlias)
		Else
			cOrder = ''
		EndIf
	Else && Need to open the table base on cDbfAlias
		cAlias = AliasName()
		If !LcDbfOpen(cDbfAlias,cAlias,.F.) Then
			Return nReturnValue
		EndIf
	EndIf
	
	* Begain the kernel coding
	If IsValidStr(eSeekExpression) Then
		If !IsValidStr(cOrder) or !Seek(eSeekExpression,cAlias,cOrder) Then
			If lNeedOpen Then
				LcDbfClose(cAlias)
			EndIf
			Select (nSelect)
			Return nReturnValue	
		EndIf
	EndIf	
	* Define variable in kernel coding
	Select (cAlias)
	nReturnValue = Evaluate(cCount_Formula)
	* End to dispose
	
	
	* Restore the environment
	If lNeedOpen Then
		LcDbfClose(cAlias)
	EndIf
	Select (nSelect)
		
		
	* Return value
	Return nReturnValue	
EndProc
*------
Procedure GetItem_Discount && Return the item discount information as string
	Lparameters cReturnLeft_Tag,eSeekExpression,cDbfAlias,cOrder
	
	cReturnLeft_Tag = DefCharacters(cReturnLeft_Tag,Proper('Less: '))
	
	
	* Initial necessary data environment and variable
	Local cReturnValue,nSelect,cAlias,lNeedOpen
	cReturnValue = ''
	nSelect = Select()
	lNeedOpen = .T.
	cOrder = DefCharacters(cOrder)
	
	* Check the table if need to open again.	
	If IsValidStr(cDbfAlias) Then && If the parameter cDbfAlias is a vaild string.
		If Select(cDbfAlias)>0 and IsValidStr(GetAlias(cDbfAlias)) Then && If cDbfAlias exist opened and no need to open again
			cAlias = GetAlias(cDbfAlias)
			lNeedOpen = .F.
		Else
			lNeedOpen = .T.
		EndIf
	Else
		If IsValidStr(GetAlias()) Then && If there is a table opened in the current select
			cAlias = GetAlias()
			lNeedOpen = .F.
		Else
			lNeedOpen = .T.
		EndIf
	EndIf
	* Confirm the table which need to dispose and check index information.
	If !lNeedOpen Then && If no need open the table, That's mean has been found a table to dispose
		If !IsValidStr(cOrder) and !Empty(Order(cAlias)) Then
			cOrder = Order(cAlias)
		Else
			cOrder = ''
		EndIf
	Else && Need to open the table base on cDbfAlias
		cAlias = AliasName()
		If !LcDbfOpen(cDbfAlias,cAlias,.F.) Then
			Return cReturnValue
		EndIf
	EndIf
	
	* Begain the kernel coding
	If IsValidStr(eSeekExpression) Then
		If !IsValidStr(cOrder) or !Seek(eSeekExpression,cAlias,cOrder) Then
			If lNeedOpen Then
				LcDbfClose(cAlias)
			EndIf
			Select (nSelect)
			Return cReturnValue	
		EndIf
	EndIf	
	* Define variable in kernel coding
	Select (cAlias)
	Local cItem_Disc,cDisc_amt
	Store '' to cItem_Disc,cDisc_amt
	
	If &cAlias..item_disc <> 0 Then
		cItem_Disc = Alltrim(Str(&cAlias..item_disc))+'%'
	EndIf
	If &cAlias..Disc_amt <> 0 Then
		cDisc_amt = Alltrim(Str(&cAlias..Disc_amt))
	EndIf
	
	If !Empty(cItem_Disc) or !Empty(cDisc_amt) Then
		cReturnValue = cReturnLeft_Tag
		If !Empty(cItem_Disc) Then
			cReturnValue = cReturnValue + cItem_Disc
			If !Empty(cDisc_amt) Then
				cReturnValue = cReturnValue + ' , '+ cDisc_amt
			EndIf
		Else
			cReturnValue = cReturnValue + cDisc_amt
		EndIf
	EndIf
	* End to dispose
	
	
	* Restore the environment
	If lNeedOpen Then
		LcDbfClose(cAlias)
	EndIf
	Select (nSelect)
		
		
	* Return value
	Return cReturnValue	
EndProc
*------
Procedure GetDoc_Charge && Return the charge as string
	Lparameters nChargeTag,nReturnTag,eSeekExpression,cDbfAlias,cOrder,lIgnore_Percent
	
	nChargeTag = Int(DefNumber(nChargeTag))
	If !InList(nChargeTag,0,1,2,3,4) Then && All Charge,Charge1,Charge2,Charge3,Charge4
		nChargeTag = 0 && All Charge
	EndIf
	
	nReturnTag = Int(DefNumber(nReturnTag))
	If !InList(nReturnTag,0,1,2,3) Then && All Information,Charge description,Charge currency,Charge amount
		nReturnTag = 0
	EndIf
	
	lIgnore_Percent = DefLogic(lIgnore_Percent)

	* Initial necessary data environment and variable
	Local cReturnValue,nSelect,cAlias,lNeedOpen
	cReturnValue = ''
	nSelect = Select()
	lNeedOpen = .T.
	cOrder = DefCharacters(cOrder)
	
	* Check the table if need to open again.	
	If IsValidStr(cDbfAlias) Then && If the parameter cDbfAlias is a vaild string.
		If Select(cDbfAlias)>0 and IsValidStr(GetAlias(cDbfAlias)) Then && If cDbfAlias exist opened and no need to open again
			cAlias = GetAlias(cDbfAlias)
			lNeedOpen = .F.
		Else
			lNeedOpen = .T.
		EndIf
	Else
		If IsValidStr(GetAlias()) Then && If there is a table opened in the current select
			cAlias = GetAlias()
			lNeedOpen = .F.
		Else
			lNeedOpen = .T.
		EndIf
	EndIf
	* Confirm the table which need to dispose and check index information.
	If !lNeedOpen Then && If no need open the table, That's mean has been found a table to dispose
		If !IsValidStr(cOrder) and !Empty(Order(cAlias)) Then
			cOrder = Order(cAlias)
		Else
			cOrder = ''
		EndIf
	Else && Need to open the table base on cDbfAlias
		cAlias = AliasName()
		If !LcDbfOpen(cDbfAlias,cAlias,.F.) Then
			Return cReturnValue
		EndIf
	EndIf
	
	* Begain the kernel coding
	If IsValidStr(eSeekExpression) Then
		If !IsValidStr(cOrder) or !Seek(eSeekExpression,cAlias,cOrder) Then
			If lNeedOpen Then
				LcDbfClose(cAlias)
			EndIf
			Select (nSelect)
			Return cReturnValue	
		EndIf
	EndIf	
	* Define variable in kernel coding
	Local lCharge1_available,lCharge2_available,lCharge3_available,lCharge4_available,cCharge_Currency,cAmt_Format,cTag
	Select (cAlias)
	Store &cAlias..Charge1_amt<>0 to lCharge1_available
	Store &cAlias..Charge2_amt<>0 to lCharge2_available
	Store &cAlias..Charge3_amt<>0 to lCharge3_available
	Store &cAlias..Charge4_amt<>0 to lCharge4_available
	If IsFieldExist('Charge1_Cur',cAlias) Then
		cCharge_Currency = Upper('Cur')
	Else
		cCharge_Currency = Upper('Curr') && Only for somast table.
	EndIf
	If InList(Vartype(total_pic),Upper('C'),Upper('M')) Then
		cAmt_Format = total_pic
	Else
		cAmt_Format = '99,999,999.99'
	EndIf
	cTag = Chr(13)+Chr(10)
	
	Do	Case
	Case nChargeTag = 0 && Get all charge information.
		Do Case
		Case nReturnTag = 0 && Return all informatin.
			cReturnValue = CharactersAdd(cTag,.T.,GetDoc_Charge(1,0),GetDoc_Charge(2,0),GetDoc_Charge(3,0),GetDoc_Charge(4,0))
		Case nReturnTag = 1 && Return charge description.
			If lCharge1_available Then
				If lIgnore_Percent or &cAlias..percent1 = 0 Then
					cReturnValue = Alltrim(&cAlias..Charge1)
				Else
					cReturnValue = ItStr(&cAlias..percent1)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge1)
				EndIf
			EndIf
			If lCharge2_available Then
				If lIgnore_Percent or &cAlias..percent2 = 0 Then
					cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,Alltrim(&cAlias..Charge2))
				Else
					cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,ItStr(&cAlias..percent2)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge2))
				EndIf
			EndIf
			If lCharge3_available Then
				If lIgnore_Percent or &cAlias..percent3 = 0 
					cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,Alltrim(&cAlias..Charge3))
				Else
					cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,ItStr(&cAlias..percent3)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge3))
				EndIf				
			EndIf
			If lCharge4_available Then
				If lIgnore_Percent or &cAlias..percent4 = 0 
					cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,Alltrim(&cAlias..Charge4))
				Else
					cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,ItStr(&cAlias..percent4)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge4))
				EndIf
			EndIf
		Case nReturnTag = 2 && Return charge currency.
			If lCharge1_available Then
				If cCharge_Currency == Upper('Cur') Then
					cReturnValue = Alltrim(&cAlias..Charge1_cur)
				Else
					cReturnValue = Alltrim(&cAlias..Charge1_curr)
				EndIf
			EndIf
			If lCharge2_available Then
				If cCharge_Currency == Upper('Cur') Then
					cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,Alltrim(&cAlias..Charge2_cur))
				Else
					cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,Alltrim(&cAlias..Charge2_curr))
				EndIf					
			EndIf
			If lCharge3_available Then
				If cCharge_Currency == Upper('Cur') Then
					cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,Alltrim(&cAlias..Charge3_cur))
				Else
					cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,Alltrim(&cAlias..Charge3_curr))
				EndIf
			EndIf
			If lCharge4_available Then
				If cCharge_Currency == Upper('Cur') Then
					cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,Alltrim(&cAlias..Charge4_cur))
				Else
					cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,Alltrim(&cAlias..Charge4_curr))
				EndIf
			EndIf
		Case nReturnTag = 3 && Return charge amount.
			If lCharge1_available Then
				cReturnValue = Alltrim(Transform(&cAlias..Charge1_amt,cAmt_Format))
			EndIf
			If lCharge2_available Then
				cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,Alltrim(Transform(&cAlias..Charge2_amt,cAmt_Format)))
			EndIf
			If lCharge3_available Then
				cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,Alltrim(Transform(&cAlias..Charge3_amt,cAmt_Format)))
			EndIf
			If lCharge4_available Then
				cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,Alltrim(Transform(&cAlias..Charge4_amt,cAmt_Format)))
			EndIf
		EndCase
	Case nChargeTag = 1 && Get charge1 information.
		Do	Case
		Case nReturnTag = 0 && Return all informatin.
			If lCharge1_available Then
				If cCharge_Currency == Upper('Cur') Then
					If lIgnore_Percent or &cAlias..percent1 = 0 Then
						cReturnValue = &cAlias..Charge1 + Padl(&cAlias..Charge1_cur,4,Space(1)) + Transform(&cAlias..Charge1_amt,cAmt_Format)
					Else
						cReturnValue = Padr(ItStr(&cAlias..percent1)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge1),Len(&cAlias..Charge1),Space(1)) + Padl(&cAlias..Charge1_cur,4,Space(1)) + Transform(&cAlias..Charge1_amt,cAmt_Format)
					EndIf					
				Else
					If lIgnore_Percent or &cAlias..percent1 = 0 Then
						cReturnValue = &cAlias..Charge1 + Padl(&cAlias..Charge1_curr,4,Space(1)) + Transform(&cAlias..Charge1_amt,cAmt_Format)
					Else
						cReturnValue = Padr(ItStr(&cAlias..percent1)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge1),Len(&cAlias..Charge1),Space(1)) + Padl(&cAlias..Charge1_curr,4,Space(1)) + Transform(&cAlias..Charge1_amt,cAmt_Format)
					EndIF
				EndIf
			EndIf
		Case nReturnTag = 1 && Return charge description.
			If lCharge1_available Then
				If lIgnore_Percent or &cAlias..percent1 = 0 
					cReturnValue = Alltrim(&cAlias..Charge1)
				Else
					cReturnValue = ItStr(&cAlias..percent1)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge1)
				EndIf
			EndIf
		Case nReturnTag = 2 && Return charge currency.
			If lCharge1_available Then
				If cCharge_Currency == Upper('Cur') Then
					cReturnValue = Alltrim(&cAlias..Charge1_cur)
				Else
					cReturnValue = Alltrim(&cAlias..Charge1_curr)
				EndIf
			EndIf
		Case nReturnTag = 3 && Return charge amount.
			If lCharge1_available Then
				cReturnValue = Alltrim(Transform(&cAlias..Charge1_amt,cAmt_Format))
			EndIf
		EndCase
	Case nChargeTag = 2 && Get charge2 information.
		Do	Case
		Case nReturnTag = 0 && Return all information.
			If lCharge2_available Then
				If cCharge_Currency == Upper('Cur') Then
					If lIgnore_Percent or &cAlias..percent2 = 0 Then
						cReturnValue = &cAlias..Charge2 + Padl(&cAlias..Charge2_cur,4,Space(1)) + Transform(&cAlias..Charge2_amt,cAmt_Format)
					Else
						cReturnValue = Padr(ItStr(&cAlias..percent2)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge2),Len(&cAlias..Charge2),Space(1)) + Padl(&cAlias..Charge2_cur,4,Space(1)) + Transform(&cAlias..Charge2_amt,cAmt_Format)
					EndIf					
				Else
					If lIgnore_Percent or &cAlias..percent2 = 0 Then
						cReturnValue = &cAlias..Charge2 + Padl(&cAlias..Charge2_curr,4,Space(1)) + Transform(&cAlias..Charge2_amt,cAmt_Format)
					Else
						cReturnValue = Padr(ItStr(&cAlias..percent2)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge2),Len(&cAlias..Charge2),Space(1)) + Padl(&cAlias..Charge2_curr,4,Space(1)) + Transform(&cAlias..Charge2_amt,cAmt_Format)
					EndIF
				EndIf
			EndIf
		Case nReturnTag = 1 && Return charge description.
			If lCharge2_available Then
				If lIgnore_Percent or &cAlias..percent2 = 0 Then
					cReturnValue = Alltrim(&cAlias..charge2)
				Else
					cReturnValue = ItStr(&cAlias..percent2)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge2)
				EndIf
			EndIf
		Case nReturnTag = 2 && Return charge currency.
			If lCharge2_available Then
				If cCharge_Currency == Upper('Cur') Then
					cReturnValue = Alltrim(&cAlias..Charge2_cur)
				Else
					cReturnValue = Alltrim(&cAlias..Charge2_curr)
				EndIf					
			EndIf
		Case nReturnTag = 3 && Return charge amount.
			If lCharge2_available Then
				cReturnValue = Alltrim(Transform(&cAlias..Charge2_amt,cAmt_Format))
			EndIf
		EndCase
	Case nChargeTag = 3 && Get charge3 information.
		Do	Case
		Case nReturnTag = 0 && Return all information.
			If lCharge3_available Then
				If cCharge_Currency == Upper('Cur') Then
					If lIgnore_Percent or &cAlias..percent3 = 0 Then
						cReturnValue = &cAlias..Charge3 + Padl(&cAlias..Charge3_cur,4,Space(1)) + Transform(&cAlias..Charge3_amt,cAmt_Format)
					Else
						cReturnValue = Padr(ItStr(&cAlias..percent3)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge3),Len(&cAlias..Charge3),Space(1)) + Padl(&cAlias..Charge3_cur,4,Space(1)) + Transform(&cAlias..Charge3_amt,cAmt_Format)
					EndIf					
				Else
					If lIgnore_Percent or &cAlias..percent3 = 0 Then
						cReturnValue = &cAlias..Charge3 + Padl(&cAlias..Charge3_curr,4,Space(1)) + Transform(&cAlias..Charge3_amt,cAmt_Format)
					Else
						cReturnValue = Padr(ItStr(&cAlias..percent3)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge3),Len(&cAlias..Charge3),Space(1)) + Padl(&cAlias..Charge3_curr,4,Space(1)) + Transform(&cAlias..Charge3_amt,cAmt_Format)
					EndIF
				EndIf
			EndIf
		Case nReturnTag = 1 && Return charge description.
			If lCharge3_available Then
				If lIgnore_Percent or &cAlias..percent3 = 0 Then
					cReturnValue = Alltrim(&cAlias..charge3)
				Else
					cReturnValue = ItStr(&cAlias..percent3)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge3)
				EndIf
			EndIf
		Case nReturnTag = 2 && Return charge currency.
			If lCharge3_available Then
				If cCharge_Currency == Upper('Cur') Then
					cReturnValue = Alltrim(&cAlias..Charge3_cur)
				Else
					cReturnValue = Alltrim(&cAlias..Charge3_curr)
				EndIf
			EndIf
		Case nReturnTag = 3 && Return charge amount.
			If lCharge3_available Then
				cReturnValue = Alltrim(Transform(&cAlias..Charge3_amt,cAmt_Format))
			EndIf
		EndCase
	Case nChargeTag = 4 && Get charge4 information.
		Do	Case
		Case nReturnTag = 0 && Return all information.
			If lCharge4_available Then
				If cCharge_Currency == Upper('Cur') Then
					If lIgnore_Percent or &cAlias..percent4 = 0 Then
						cReturnValue = &cAlias..Charge4 + Padl(&cAlias..Charge4_cur,4,Space(1)) + Transform(&cAlias..Charge4_amt,cAmt_Format)
					Else
						cReturnValue = Padr(ItStr(&cAlias..percent4)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge4),Len(&cAlias..Charge4),Space(1)) + Padl(&cAlias..Charge4_cur,4,Space(1)) + Transform(&cAlias..Charge4_amt,cAmt_Format)
					EndIf					
				Else
					If lIgnore_Percent or &cAlias..percent4 = 0 Then
						cReturnValue = &cAlias..Charge4 + Padl(&cAlias..Charge4_curr,4,Space(1)) + Transform(&cAlias..Charge4_amt,cAmt_Format)
					Else
						cReturnValue = Padr(ItStr(&cAlias..percent4)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge4),Len(&cAlias..Charge4),Space(1)) + Padl(&cAlias..Charge4_curr,4,Space(1)) + Transform(&cAlias..Charge4_amt,cAmt_Format)
					EndIF
				EndIf
			EndIf
		Case nReturnTag = 1 && Return charge description.
			If lCharge4_available Then
				If lIgnore_Percent or &cAlias..percent4 = 0 Then
					cReturnValue = Alltrim(&cAlias..charge4)
				Else
					cReturnValue = ItStr(&cAlias..percent4)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge4)
				EndIf
			EndIf
		Case nReturnTag = 2 && Return charge currency.
			If lCharge4_available Then
				If cCharge_Currency == Upper('Cur') Then
					cReturnValue = Alltrim(&cAlias..Charge4_cur)
				Else
					cReturnValue = Alltrim(&cAlias..Charge4_curr)
				EndIf				
			EndIf
		Case nReturnTag = 3 && Return charge amount.
			If lCharge4_available Then
				cReturnValue = Alltrim(Transform(&cAlias..Charge4_amt,cAmt_Format))
			EndIf
		EndCase
	EndCase
	* End the kernel coding	
	
	If lNeedOpen Then
		LcDbfClose(cAlias)
	EndIf
	Select (nSelect)
	Return cReturnValue	
EndProc	
*------
Procedure GetDoc_ChargeFee
	Lparameters eSeekExpression,cDbfAlias,cOrder
	
	* Initial necessary data environment and variable
	Local nReturnValue,nSelect,cAlias,lNeedOpen
	nReturnValue = 0
	nSelect = Select()
	lNeedOpen = .T.
	cOrder = DefCharacters(cOrder)
	
	* Check the table if need to open again.	
	If IsValidStr(cDbfAlias) Then && If the parameter cDbfAlias is a vaild string.
		If Select(cDbfAlias)>0 and IsValidStr(GetAlias(cDbfAlias)) Then && If cDbfAlias exist opened and no need to open again
			cAlias = GetAlias(cDbfAlias)
			lNeedOpen = .F.
		Else
			lNeedOpen = .T.
		EndIf
	Else
		If IsValidStr(GetAlias()) Then && If there is a table opened in the current select
			cAlias = GetAlias()
			lNeedOpen = .F.
		Else
			lNeedOpen = .T.
		EndIf
	EndIf
	* Confirm the table which need to dispose and check index information.
	If !lNeedOpen Then && If no need open the table, That's mean has been found a table to dispose
		If !IsValidStr(cOrder) and !Empty(Order(cAlias)) Then
			cOrder = Order(cAlias)
		Else
			cOrder = ''
		EndIf
	Else && Need to open the table base on cDbfAlias
		cAlias = AliasName()
		If !LcDbfOpen(cDbfAlias,cAlias,.F.) Then
			Return nReturnValue
		EndIf
	EndIf
	
	* Begain the kernel coding
	If IsValidStr(eSeekExpression) Then
		If !IsValidStr(cOrder) or !Seek(eSeekExpression,cAlias,cOrder) Then
			If lNeedOpen Then
				LcDbfClose(cAlias)
			EndIf
			Select (nSelect)
			Return nReturnValue	
		EndIf
	EndIf	
	* Define variable in kernel coding
	Select (cAlias)
	nReturnValue = ;
					&cAlias..Charge1_amt * &cAlias..Charge1_Rate + ;
					&cAlias..Charge2_amt * &cAlias..Charge2_Rate + ;
					&cAlias..Charge3_amt * &cAlias..Charge3_Rate + ;
					&cAlias..Charge4_amt * &cAlias..Charge4_Rate
	* End the kernel coding	
	
	If lNeedOpen Then
		LcDbfClose(cAlias)
	EndIf
	Select (nSelect)
	Return nReturnValue	
EndProc	
*------
Procedure Get_UnderCharge && Return the under charge as string
	Lparameters nChargeTag,nReturnTag,eSeekExpression,cDbfAlias,cOrder,lIgnore_percent
	
	nChargeTag = Int(DefNumber(nChargeTag))
	If !InList(nChargeTag,0,1,2,3,4) Then && All Com_value,com_value,Com_value2,Com_value3,Com_value4
		nChargeTag = 0 && All Com_value
	EndIf
	
	nReturnTag = Int(DefNumber(nReturnTag))
	If !InList(nReturnTag,0,1,2,3) Then && All Information,Com_value description,Com_value currency,Com_value amount
		nReturnTag = 0
	EndIf
	
	lIgnore_percent = DefLogic(lIgnore_percent)

	* Initial necessary data environment and variable
	Local cReturnValue,nSelect,cAlias,lNeedOpen
	cReturnValue = ''
	nSelect = Select()
	lNeedOpen = .T.
	cOrder = DefCharacters(cOrder)
	
	* Check the table if need to open again.	
	If IsValidStr(cDbfAlias) Then && If the parameter cDbfAlias is a vaild string.
		If Select(cDbfAlias)>0 and IsValidStr(GetAlias(cDbfAlias)) Then && If cDbfAlias exist opened and no need to open again
			cAlias = GetAlias(cDbfAlias)
			lNeedOpen = .F.
		Else
			lNeedOpen = .T.
		EndIf
	Else
		If IsValidStr(GetAlias()) Then && If there is a table opened in the current select
			cAlias = GetAlias()
			lNeedOpen = .F.
		Else
			lNeedOpen = .T.
		EndIf
	EndIf
	* Confirm the table which need to dispose and check index information.
	If !lNeedOpen Then && If no need open the table, That's mean has been found a table to dispose
		If !IsValidStr(cOrder) and !Empty(Order(cAlias)) Then
			cOrder = Order(cAlias)
		Else
			cOrder = ''
		EndIf
	Else && Need to open the table base on cDbfAlias
		cAlias = AliasName()
		If !LcDbfOpen(cDbfAlias,cAlias,.F.) Then
			Return cReturnValue
		EndIf
	EndIf
	
	* Begain the kernel coding
	If IsValidStr(eSeekExpression) Then
		If !IsValidStr(cOrder) or !Seek(eSeekExpression,cAlias,cOrder) Then
			If lNeedOpen Then
				LcDbfClose(cAlias)
			EndIf
			Select (nSelect)
			Return cReturnValue	
		EndIf
	EndIf	
	* Define variable in kernel coding
	Local lCharge1_available,lCharge2_available,lCharge3_available,lCharge4_available,cCharge_Currency,cAmt_Format,cTag
	Select (cAlias)
	Store &cAlias..Com_value<>0 to  lCharge1_available
	Store &cAlias..Com_value2<>0 to lCharge2_available
	Store &cAlias..Com_value3<>0 to lCharge3_available
	Store &cAlias..Com_value4<>0 to lCharge4_available
	If IsFieldExist('Charge1_Cur',cAlias) Then
		cCharge_Currency = Upper('Cur')
	Else
		cCharge_Currency = Upper('Curr') && Only for somast table.
	EndIf
	If InList(Vartype(total_pic),Upper('C'),Upper('M')) Then
		cAmt_Format = total_pic
	Else
		cAmt_Format = '99,999,999.99'
	EndIf
	cTag = Chr(13)+Chr(10)
	
		
	Do	Case
	Case nChargeTag = 0 && Get all charge information.
		Do Case
		Case nReturnTag = 0 && Return all informatin.
			cReturnValue = CharactersAdd(cTag,.T.,Get_UnderCharge(1,0),Get_UnderCharge(2,0),Get_UnderCharge(3,0),Get_UnderCharge(4,0))
		Case nReturnTag = 1 && Return charge description.
			If lCharge1_available Then
				If lIgnore_percent or &cAlias..commission = 0 Then
					cReturnValue = Alltrim(&cAlias..Charge1)
				Else
					cReturnValue = ItStr(&cAlias..commission)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge1)
				EndIf
			EndIf
			If lCharge2_available Then
				If lIgnore_percent or &cAlias..commission2 = 0 Then
					cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,Alltrim(&cAlias..Charge2))
				Else
					cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,ItStr(&cAlias..commission2)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge2))
				EndIf
			EndIf
			If lCharge3_available Then
				If lIgnore_percent or &cAlias..commission3 = 0 
					cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,Alltrim(&cAlias..Com_value3))
				Else
					cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,ItStr(&cAlias..commission3)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge3))
				EndIf				
			EndIf
			If lCharge4_available Then
				If lIgnore_percent or &cAlias..commission4 = 0 
					cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,Alltrim(&cAlias..Com_value4))
				Else
					cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,ItStr(&cAlias..commission4)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge4))
				EndIf
			EndIf
		Case nReturnTag = 2 && Return charge currency.
			If lCharge1_available Then
				If cCharge_Currency == Upper('Cur') Then
					cReturnValue = Alltrim(&cAlias..Charge1_cur)
				Else
					cReturnValue = Alltrim(&cAlias..Charge1_curr)
				EndIf
			EndIf
			If lCharge2_available Then
				If cCharge_Currency == Upper('Cur') Then
					cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,Alltrim(&cAlias..Charge2_cur))
				Else
					cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,Alltrim(&cAlias..Charge2_curr))
				EndIf					
			EndIf
			If lCharge3_available Then
				If cCharge_Currency == Upper('Cur') Then
					cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,Alltrim(&cAlias..Charge3_cur))
				Else
					cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,Alltrim(&cAlias..Charge3_curr))
				EndIf
			EndIf
			If lCharge4_available Then
				If cCharge_Currency == Upper('Cur') Then
					cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,Alltrim(&cAlias..Charge4_cur))
				Else
					cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,Alltrim(&cAlias..Charge4_curr))
				EndIf
			EndIf
		Case nReturnTag = 3 && Return charge amount.
			If lCharge1_available Then
				cReturnValue = Alltrim(Transform(&cAlias..com_value,cAmt_Format))
			EndIf
			If lCharge2_available Then
				cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,Alltrim(Transform(&cAlias..Com_value2,cAmt_Format)))
			EndIf
			If lCharge3_available Then
				cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,Alltrim(Transform(&cAlias..Com_value3,cAmt_Format)))
			EndIf
			If lCharge4_available Then
				cReturnValue = CharactersAdd(cTag,.F.,cReturnValue,Alltrim(Transform(&cAlias..Com_value4,cAmt_Format)))
			EndIf
		EndCase
	Case nChargeTag = 1 && Get charge1 information.
		Do	Case
		Case nReturnTag = 0 && Return all informatin.
			If lCharge1_available Then
				If cCharge_Currency == Upper('Cur') Then
					If lIgnore_percent or &cAlias..commission = 0 Then
						cReturnValue = &cAlias..Charge1 + Padl(&cAlias..Charge1_cur,4,Space(1)) + Transform(&cAlias..com_value,cAmt_Format)
					Else
						cReturnValue = Padr(ItStr(&cAlias..commission)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge1),Len(&cAlias..Charge1),Space(1)) + Padl(&cAlias..Charge1_cur,4,Space(1)) + Transform(&cAlias..com_value,cAmt_Format)
					EndIf					
				Else
					If lIgnore_percent or &cAlias..commission = 0 Then
						cReturnValue = &cAlias..Charge1 + Padl(&cAlias..Charge1_curr,4,Space(1)) + Transform(&cAlias..com_value,cAmt_Format)
					Else
						cReturnValue = Padr(ItStr(&cAlias..commission)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge1),Len(&cAlias..Charge1),Space(1)) + Padl(&cAlias..Charge1_curr,4,Space(1)) + Transform(&cAlias..com_value,cAmt_Format)
					EndIF
				EndIf
			EndIf
		Case nReturnTag = 1 && Return charge description.
			If lCharge1_available Then
				If lIgnore_percent or &cAlias..commission = 0 
					cReturnValue = Alltrim(&cAlias..Charge1)
				Else
					cReturnValue = ItStr(&cAlias..commission)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge1)
				EndIf
			EndIf
		Case nReturnTag = 2 && Return charge currency.
			If lCharge1_available Then
				If cCharge_Currency == Upper('Cur') Then
					cReturnValue = Alltrim(&cAlias..Charge1_cur)
				Else
					cReturnValue = Alltrim(&cAlias..Charge1_curr)
				EndIf
			EndIf
		Case nReturnTag = 3 && Return charge amount.
			If lCharge1_available Then
				cReturnValue = Alltrim(Transform(&cAlias..com_value,cAmt_Format))
			EndIf
		EndCase
	Case nChargeTag = 2 && Get charge2 information.
		Do	Case
		Case nReturnTag = 0 && Return all information.
			If lCharge2_available Then
				If cCharge_Currency == Upper('Cur') Then
					If lIgnore_percent or &cAlias..commission2 = 0 Then
						cReturnValue = &cAlias..Charge2 + Padl(&cAlias..Charge2_cur,4,Space(1)) + Transform(&cAlias..Com_value2,cAmt_Format)
					Else
						cReturnValue = Padr(ItStr(&cAlias..commission2)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge2),Len(&cAlias..Charge2),Space(1)) + Padl(&cAlias..Charge2_cur,4,Space(1)) + Transform(&cAlias..Com_value2,cAmt_Format)
					EndIf					
				Else
					If lIgnore_percent or &cAlias..commission2 = 0 Then
						cReturnValue = &cAlias..Charge2 + Padl(&cAlias..Charge2_curr,4,Space(1)) + Transform(&cAlias..Com_value2,cAmt_Format)
					Else
						cReturnValue = Padr(ItStr(&cAlias..commission2)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge2),Len(&cAlias..Charge2),Space(1)) + Padl(&cAlias..Charge2_curr,4,Space(1)) + Transform(&cAlias..Com_value2,cAmt_Format)
					EndIF
				EndIf
			EndIf
		Case nReturnTag = 1 && Return charge description.
			If lCharge2_available Then
				If lIgnore_percent or &cAlias..commission2 = 0 Then
					cReturnValue = Alltrim(&cAlias..Charge2)
				Else
					cReturnValue = ItStr(&cAlias..commission2)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge2)
				EndIf
			EndIf
		Case nReturnTag = 2 && Return charge currency.
			If lCharge2_available Then
				If cCharge_Currency == Upper('Cur') Then
					cReturnValue = Alltrim(&cAlias..Charge2_cur)
				Else
					cReturnValue = Alltrim(&cAlias..Charge2_curr)
				EndIf					
			EndIf
		Case nReturnTag = 3 && Return charge amount.
			If lCharge2_available Then
				cReturnValue = Alltrim(Transform(&cAlias..Com_value2,cAmt_Format))
			EndIf
		EndCase
	Case nChargeTag = 3 && Get charge3 information.
		Do	Case
		Case nReturnTag = 0 && Return all information.
			If lCharge3_available Then
				If cCharge_Currency == Upper('Cur') Then
					If lIgnore_percent or &cAlias..commission3 = 0 Then
						cReturnValue = &cAlias..Charge3 + Padl(&cAlias..Charge3_cur,4,Space(1)) + Transform(&cAlias..Com_value3,cAmt_Format)
					Else
						cReturnValue = Padr(ItStr(&cAlias..commission3)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge3),Len(&cAlias..Charge3),Space(1)) + Padl(&cAlias..Charge3_cur,4,Space(1)) + Transform(&cAlias..Com_value3,cAmt_Format)
					EndIf					
				Else
					If lIgnore_percent or &cAlias..commission3 = 0 Then
						cReturnValue = &cAlias..Charge3 + Padl(&cAlias..Charge3_curr,4,Space(1)) + Transform(&cAlias..Com_value3,cAmt_Format)
					Else
						cReturnValue = Padr(ItStr(&cAlias..commission3)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge3),Len(&cAlias..Charge3),Space(1)) + Padl(&cAlias..Charge3_curr,4,Space(1)) + Transform(&cAlias..Com_value3,cAmt_Format)
					EndIF
				EndIf
			EndIf
		Case nReturnTag = 1 && Return charge description.
			If lCharge3_available Then
				If lIgnore_percent or &cAlias..commission3 = 0 Then
					cReturnValue = Alltrim(&cAlias..Charge3)
				Else
					cReturnValue = ItStr(&cAlias..commission3)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge3)
				EndIf
			EndIf
		Case nReturnTag = 2 && Return charge currency.
			If lCharge3_available Then
				If cCharge_Currency == Upper('Cur') Then
					cReturnValue = Alltrim(&cAlias..Charge3_cur)
				Else
					cReturnValue = Alltrim(&cAlias..Charge3_curr)
				EndIf
			EndIf
		Case nReturnTag = 3 && Return charge amount.
			If lCharge3_available Then
				cReturnValue = Alltrim(Transform(&cAlias..Com_value3,cAmt_Format))
			EndIf
		EndCase
	Case nChargeTag = 4 && Get charge4 information.
		Do	Case
		Case nReturnTag = 0 && Return all information.
			If lCharge4_available Then
				If cCharge_Currency == Upper('Cur') Then
					If lIgnore_percent or &cAlias..commission4 = 0 Then
						cReturnValue = &cAlias..Charge4 + Padl(&cAlias..Charge4_cur,4,Space(1)) + Transform(&cAlias..Com_value4,cAmt_Format)
					Else
						cReturnValue = Padr(ItStr(&cAlias..commission4)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge4),Len(&cAlias..Charge4),Space(1)) + Padl(&cAlias..Charge4_cur,4,Space(1)) + Transform(&cAlias..Com_value4,cAmt_Format)
					EndIf					
				Else
					If lIgnore_percent or &cAlias..commission4 = 0 Then
						cReturnValue = &cAlias..Charge4 + Padl(&cAlias..Charge4_curr,4,Space(1)) + Transform(&cAlias..Com_value4,cAmt_Format)
					Else
						cReturnValue = Padr(ItStr(&cAlias..commission4)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge4),Len(&cAlias..Charge4),Space(1)) + Padl(&cAlias..Charge4_curr,4,Space(1)) + Transform(&cAlias..Com_value4,cAmt_Format)
					EndIF
				EndIf
			EndIf
		Case nReturnTag = 1 && Return charge description.
			If lCharge4_available Then
				If lIgnore_percent or &cAlias..commission4 = 0 Then
					cReturnValue = Alltrim(&cAlias..Charge4)
				Else
					cReturnValue = ItStr(&cAlias..commission4)+Space(1)+'%'+Space(1)+Alltrim(&cAlias..Charge4)
				EndIf
			EndIf
		Case nReturnTag = 2 && Return charge currency.
			If lCharge4_available Then
				If cCharge_Currency == Upper('Cur') Then
					cReturnValue = Alltrim(&cAlias..Charge4_cur)
				Else
					cReturnValue = Alltrim(&cAlias..Charge4_curr)
				EndIf				
			EndIf
		Case nReturnTag = 3 && Return charge amount.
			If lCharge4_available Then
				cReturnValue = Alltrim(Transform(&cAlias..Com_value4,cAmt_Format))
			EndIf
		EndCase
	EndCase
	* End the kernel coding	
	
	If lNeedOpen Then
		LcDbfClose(cAlias)
	EndIf
	Select (nSelect)
	Return cReturnValue	
EndProc	
*------
Procedure Get_UnderChargeFee
	Lparameters eSeekExpression,cDbfAlias,cOrder,lCurrency
	
	lCurrency = DefLogic(lCurrency) && That mean no need to count the currency base on the document , This is the default setting.
	
	* Initial necessary data environment and variable
	Local nReturnValue,nSelect,cAlias,lNeedOpen
	nReturnValue = 0
	nSelect = Select()
	lNeedOpen = .T.
	cOrder = DefCharacters(cOrder)
	
	* Check the table if need to open again.	
	If IsValidStr(cDbfAlias) Then && If the parameter cDbfAlias is a vaild string.
		If Select(cDbfAlias)>0 and IsValidStr(GetAlias(cDbfAlias)) Then && If cDbfAlias exist opened and no need to open again
			cAlias = GetAlias(cDbfAlias)
			lNeedOpen = .F.
		Else
			lNeedOpen = .T.
		EndIf
	Else
		If IsValidStr(GetAlias()) Then && If there is a table opened in the current select
			cAlias = GetAlias()
			lNeedOpen = .F.
		Else
			lNeedOpen = .T.
		EndIf
	EndIf
	* Confirm the table which need to dispose and check index information.
	If !lNeedOpen Then && If no need open the table, That's mean has been found a table to dispose
		If !IsValidStr(cOrder) and !Empty(Order(cAlias)) Then
			cOrder = Order(cAlias)
		Else
			cOrder = ''
		EndIf
	Else && Need to open the table base on cDbfAlias
		cAlias = AliasName()
		If !LcDbfOpen(cDbfAlias,cAlias,.F.) Then
			Return nReturnValue
		EndIf
	EndIf
	
	* Begain the kernel coding
	If IsValidStr(eSeekExpression) Then
		If !IsValidStr(cOrder) or !Seek(eSeekExpression,cAlias,cOrder) Then
			If lNeedOpen Then
				LcDbfClose(cAlias)
			EndIf
			Select (nSelect)
			Return nReturnValue	
		EndIf
	EndIf	
	* Define variable in kernel coding
	Select (cAlias)
	If lCurrency Then && Need to count the currency base on the relationship document
		nReturnValue = ;
					&cAlias..Com_Value * &cAlias..Charge1_Rate + ;
					&cAlias..Com_Value2 * &cAlias..Charge2_Rate + ;
					&cAlias..Com_Value3 * &cAlias..Charge3_Rate + ;
					&cAlias..Com_Value4 * &cAlias..Charge4_Rate
	Else && Ignore the relationship currency
		nReturnValue = ; 
			&cAlias..Com_Value  + ;
			&cAlias..Com_Value2 + ;
			&cAlias..Com_Value3 + ;
			&cAlias..Com_Value4
	EndIf 

	* End the kernel coding	
	
	If lNeedOpen Then
		LcDbfClose(cAlias)
	EndIf
	Select (nSelect)
	Return nReturnValue	
EndProc	
*------
Procedure ItPacking
	Lparameter cSourceAlias
	
	If !IsValidStr(cSourceAlias) or Upper(cSourceAlias) == Upper(Alias()) Then
		Return .F.
	EndIf
	
	If IsFieldExist('Inner_qty',Alias()) and IsFieldExist('Inner_qty',cSourceAlias) Then
		Replace Inner_qty with &cSourceAlias..Inner_qty
	EndIf
	If IsFieldExist('inner_unit',Alias()) and IsFieldExist('inner_unit',cSourceAlias) Then
		Replace inner_unit with &cSourceAlias..inner_unit
	EndIf
	If IsFieldExist('inner_pack',Alias()) and IsFieldExist('inner_pack',cSourceAlias) Then
		Replace inner_pack with &cSourceAlias..inner_pack
	EndIf
	If IsFieldExist('ctn_qty',Alias()) and IsFieldExist('ctn_qty',cSourceAlias) Then
		Replace ctn_qty with &cSourceAlias..ctn_qty
	EndIf
	If IsFieldExist('ctn_unit',Alias()) and IsFieldExist('ctn_unit',cSourceAlias) Then
		Replace ctn_unit with &cSourceAlias..ctn_unit
	EndIf
	If IsFieldExist('ctn_pack',Alias()) and IsFieldExist('ctn_pack',cSourceAlias) Then
		Replace ctn_pack with &cSourceAlias..ctn_pack
	EndIf
	If IsFieldExist('length',Alias()) and IsFieldExist('length',cSourceAlias) Then
		Replace length with &cSourceAlias..length
	EndIf
	If IsFieldExist('hight',Alias()) and IsFieldExist('hight',cSourceAlias) Then
		Replace hight with &cSourceAlias..hight
	EndIf
	If IsFieldExist('width',Alias()) and IsFieldExist('width',cSourceAlias) Then
		Replace width with &cSourceAlias..width
	EndIf
	If IsFieldExist('measure_unit',Alias()) and IsFieldExist('measure_unit',cSourceAlias) Then
		Replace measure_unit with &cSourceAlias..measure_unit
	EndIf
	If IsFieldExist('net_wt',Alias()) and IsFieldExist('net_wt',cSourceAlias) Then
		Replace net_wt with &cSourceAlias..net_wt
	EndIf
	If IsFieldExist('grs_wt',Alias()) and IsFieldExist('grs_wt',cSourceAlias) Then
		Replace grs_wt with &cSourceAlias..grs_wt
	EndIf
	If IsFieldExist('nn_wt',Alias()) and IsFieldExist('nn_wt',cSourceAlias) Then
		Replace nn_wt with &cSourceAlias..nn_wt
	EndIf
	If IsFieldExist('wt_unit',Alias()) and IsFieldExist('wt_unit',cSourceAlias) Then
		Replace wt_unit with &cSourceAlias..wt_unit
	EndIf
	If IsFieldExist('packing',Alias()) and IsFieldExist('packing',cSourceAlias) Then
		Replace packing with &cSourceAlias..packing
	EndIf
	If IsFieldExist('cbm',Alias()) and IsFieldExist('cbm',cSourceAlias) Then
		Replace cbm with &cSourceAlias..cbm
	EndIf
	If IsFieldExist('cuft',Alias()) and IsFieldExist('cuft',cSourceAlias) Then
		Replace cuft with &cSourceAlias..cuft
	EndIf
	If IsFieldExist('inner_mark',Alias()) and IsFieldExist('inner_mark',cSourceAlias) Then
		Replace inner_mark with &cSourceAlias..inner_mark
	EndIf
	If IsFieldExist('side_mark',Alias()) and IsFieldExist('side_mark',cSourceAlias) Then
		Replace side_mark with &cSourceAlias..side_mark
	EndIf
	If IsFieldExist('item_mark',Alias()) and IsFieldExist('item_mark',cSourceAlias) Then
		Replace item_mark with &cSourceAlias..item_mark
	EndIf
	If IsFieldExist('bar_code',Alias()) and IsFieldExist('bar_code',cSourceAlias) Then
		Replace bar_code with &cSourceAlias..bar_code
	EndIf
	If IsFieldExist('bar_type',Alias()) and IsFieldExist('bar_type',cSourceAlias) Then
		Replace bar_type with &cSourceAlias..bar_type
	EndIf
	If IsFieldExist('material_name',Alias()) and IsFieldExist('material_name',cSourceAlias) Then
		Replace material_name with &cSourceAlias..material_name
	EndIf
	If IsFieldExist('material_desc',Alias()) and IsFieldExist('material_desc',cSourceAlias) Then
		Replace material_desc with &cSourceAlias..material_desc
	EndIf
	If IsFieldExist('desc2',Alias()) and IsFieldExist('desc2',cSourceAlias) Then
		Replace desc2 with &cSourceAlias..desc2
	EndIf
	If IsFieldExist('package',Alias()) and IsFieldExist('package',cSourceAlias) Then
		Replace package with &cSourceAlias..package
	EndIf
	If IsFieldExist('marks',Alias()) and IsFieldExist('marks',cSourceAlias) Then
		Replace marks with &cSourceAlias..marks
	EndIf
	
	Return .T.
EndProc
*------
Procedure CopyCdx
	Lparameters cSourceDbf,cTargetDbf,cCdx

	Local nSelect,cOld_Index_TagName,cSourceAlias,lNeedOpen
	nSelect=Select()
	cOld_Index_TagName = ''
	cSourceAlias	= ''
	lNeedOpen		= .F.
	
	cTargetDbf=GetAlias(DefCharacters(cTargetDbf))
	If IsValidStr(cTargetDbf) Then
		If Empty(Ndx(1,cTargetDbf)) Then
			cOld_Index_TagName = Order(cTargetDbf)
		Else
			* Idx file : If it is a cursor table the .idx file will auto delete after index on command ,
			           * otherwise it will generate a .idx file in the current directory.
		    * cOld_Index_TagName = ''
			* Ignore it temporarily 
		EndIf
	Else
		WaitWindow('Please make sure the target table is valid.',Sys(16))
		Select (nSelect)
		Return 0
	EndIf
	
	If IsValidStr(cSourceDbf) Then
		If Select(cSourceDbf) > 0 Then
			cSourceAlias = cSourceDbf
		Else
			* The cSourceDbf has been seted but not opened.
			lNeedOpen = .T.	
			cSourceAlias = GetAlias(cSourceDbf)
			If !IsValidStr(cSourceAlias) Then
				WaitWindow('Please make sure the source table is valid and can opened. ',Sys(16))
				Select (nSelect)
				Return 0
			EndIf
		EndIf
	Else
		cSourceAlias = Alias()
	EndIf
	cCdx = DefCharacters(cCdx)

	Local nTag,nReturnValue,cCreateIndex,cSet_Safety
	nReturnValue=0
	cSet_Safety=Set("Safety")
	Set Safety off

	Select (cSourceAlias)
	For nTag=1 to Tagcount()
		cCreateIndex='Index on '+Key(nTag)+' tag '+Tag(nTag)
		If IsValidStr(cCdx) Then
			If uTrim(Tag(nTag))==uTrim(cCdx) Then
				Select (cTargetDbf)
				&cCreateIndex.
				nReturnValue=nReturnValue+1
				Exit
			EndIf
		Else
			Select (cTargetDbf)
			&cCreateIndex.
			nReturnValue=nReturnValue+1
		EndIf
		Select (cSourceAlias)
	EndFor
	Set Safety &cSet_Safety.
	* Restore the index tag name for (cTargetDbf)
	Set Order To (cOld_Index_TagName) in (cTargetDbf)
	
	* Restoer the environment.
	If lNeedOpen Then
		LcDbfClose(cSourceAlias)
	EndIf	
	Select (nSelect)
	
	* Return value that's mean how many index created.
	Return nReturnValue
EndProc
*------
Procedure Itloaddata_roger
	Lparameter Paulvalue , Paulindex , Paulkey , Paulolddbf , Paulnewdbf , Pauloldopen ,  ;
		Paulnewopen , Paulcondition , Paulseekrange
	Set Exact Off
	Set Deleted On
	If Used('paulold')
		Use In Paulold
	Endif
	If Empty(paulcondition)
		Paulcondition = '  .t.'
	Endif
	Paulcondition2=" &paulkey.=paulvalue "
	Paulold = 'paulold'
	If  .not. Empty(paulindex)
		Use &paulolddbf. Order &paulindex. In 0 Alias (paulold) Again
	Else
		Use &paulolddbf.  In 0 Alias (paulold) Again
	Endif
	Paulnew = Paulnewdbf
	Paulkey_value = ''
	Continue_yn = 0
	Pauldeleted = .f.
	Fpauloldadatetime = Alltrim(paulold) + '.' + 'adatetime'
	Fpaulnewadatetime = Alltrim(paulnew) + '.' + 'adatetime'
	Select (paulold)
	Go Top
	If  .not. Empty(paulindex)
		Set Order To &paulindex.
		Go Top
		Seek Paulvalue
		If  .not. Found()
			If Used(paulold)
				Use In (paulold)
			Endif
			Lrprint = 999
			Set Exact Off
			Set Deleted On
			Return
		Endif
		Paulcondition2=" &paulkey.=paulvalue "
		Paulcondition3=" Alltrim(&paulkey.)==paulvalue "
	Else
		Paulcondition2 = '  .t. '
		Paulcondition3 = '  .t. '
	Endif
	Local Paulfield , Paulfield_value
	Select (paulold)
	Paulkey_value = Paulvalue
	Pauldeleted = Deleted()
	Paulnorec = 0
	If  .not. Empty(paulseekrange)
		Paulcondition2 = Alltrim(paulseekrange)
	Endif
	Do While Inkey()<>27 .and. .not. Eof(paulold) .and. &paulcondition2.
		Select (paulold)
		If  &paulcondition3.  .and. &paulcondition.
			Paulnorec = Paulnorec + 1
			Continue_yn = 1
			Select (paulnew)
			Append Blank
			Select (paulold)
			For Gncount = 1 To Fcount()
				Paulfield = Field(gncount)
				If Type(field(gncount)) = Upper('c')
					Paulfield_value=field(gncount)+&paulfield.
				Else
					Paulfield_value = Field(gncount)
				Endif
				Fpaulold = Alltrim(paulold) + '.' + Alltrim(paulfield)
				Fpaulnew = Alltrim(paulnew) + '.' + Alltrim(paulfield)
				Paulselect = .t.
				Select (paulnew)
				If Paulselect
					Replace &fpaulnew. With &fpaulold.
				Endif
				Select (paulold)
			Endfor
			Wait Window Nowait '# Of Record Loaded: ' + Alltrim(str(paulnorec,8))
		Endif
		Select (paulold)
		Skip
		Pauldeleted = Deleted()
		If  .not. Empty(paulkey)
			Paulkey_value=&paulkey.
		Endif
	Enddo
	If Used('paulold')
		Use In Paulold
	Endif
	If Used(paulold)
		Use In (paulold)
	Endif
	Set Exact Off
	Set Deleted On
	Return
Endproc
*------
Procedure uRename
	For nTag=1 to Fcount()
		cOldField=Field(nTag)
		cNewField=Alltrim(Left(&cOldField.,10))
		cCommand='Alter table Alias() rename '+cOldField+' to '+cNewField
		&cCommand.
	EndFor
EndProc
*------
*!*	Procedure cSubstr
*!*		Parameter SUBSTR_VALUE , SUBSTR_PLUS , SUBSTR_INDEX , lMessage_Off,SUBSTR_TRIM
*!*		lMessage_Off = DefLogic(lMessage_Off)
*!*		If Vartype(SUBSTR_VALUE) <> 'C' .Or. Empty(SUBSTR_VALUE)
*!*			Return ''
*!*		Endif
*!*		If Vartype(SUBSTR_TRIM) <> 'L'
*!*			SUBSTR_TRIM = .F.
*!*		Endif
*!*		If Vartype(SUBSTR_PLUS) <> 'C' .Or. Asc(SUBSTR_PLUS)=0 && no any character
*!*			SUBSTR_PLUS = ','
*!*		Endif
*!*		If Vartype(SUBSTR_INDEX) <> 'N'
*!*			SUBSTR_INDEX = 0
*!*		Else
*!*			If SUBSTR_INDEX < 0
*!*				SUBSTR_INDEX = 0
*!*			Endif
*!*		Endif
*!*		If  .Not. (SUBSTR_PLUS $ SUBSTR_VALUE) .Or. SUBSTR_INDEX = 0
*!*			If !lMessage_Off Then
*!*				Wait Window Nowait 'Can not found the plus of '+"'"+Substr_plus+"'"+' in '+Substr_Value+' !'
*!*			EndIf
*!*			Return ''
*!*		Endif
*!*		SUBSTR_VALUE = Strtran(SUBSTR_VALUE,SUBSTR_PLUS,Chr(13) + Chr(10))
*!*		Alines(SUBSTR_ARRAY,SUBSTR_VALUE)
*!*		If Alen(SUBSTR_ARRAY) >= SUBSTR_INDEX
*!*			If SUBSTR_TRIM
*!*				Return Alltrim(SUBSTR_ARRAY(SUBSTR_INDEX))
*!*			Else
*!*				Return SUBSTR_ARRAY(SUBSTR_INDEX)
*!*			Endif
*!*		Else
*!*			If !Message_Off Then
*!*				WaitWindow('Because the character index '+Alltrim(Str(Substr_Index))+' is larger than character counts '+Alltrim(Str(Alen(SUBSTR_ARRAY)))+' , Program will be return a empty string.',Sys(16))
*!*			EndIf
*!*			Return ''
*!*		Endif
*!*	EndProc
*------
Procedure IsValidEmail
	Lparameters cEmailAddress
	If Not IsValidStr(cEmailAddress) Then
		Return .F.
	Else
		If !'@' $ cEmailAddress Then
			Return .F.
		EndIf
	EndIf

	Local nTag,nAsc
	For nTag=1 to Lenc(cEmailAddress)
		nAsc=Asc(Substrc(cEmailAddress,nTag,1))
		If not ((nAsc=Asc('_')) or (nAsc=46) or (nAsc=64) or (nAsc>=48 and nAsc<=57) or(nAsc>=65 and nAsc<=90) or (nAsc>=97 and nAsc<=122)) Then
			Return .F. && Email address only allow "_",".","@","0-9","A-Z","a-z"
		EndIf
	EndFor
	Return .T.
EndProc
*------
Procedure cRepairEmail
	Lparameters cEmailAddress,cSpecialCharacters
	If Not IsValidStr(cEmailAddress) Then
		Return ''
	EndIf
	cSpecialCharacters=DefCharacters(cSpecialCharacters)
	Local nTag,nAsc,cReturnValue
	cReturnValue=''
	For nTag=1 to Lenc(cEmailAddress)
		nAsc=Asc(Substrc(cEmailAddress,nTag,1))
		If (nAsc=Asc('_')) or (nAsc=46) or (nAsc=64) or (nAsc>=48 and nAsc<=57) or(nAsc>=65 and nAsc<=90) or (nAsc>=97 and nAsc<=122) Then
			&& Email address allow "_",".","@","0-9","A-Z","a-z"
			cReturnValue=cReturnValue+Substrc(cEmailAddress,nTag,1)
		Else
			If IsValidStr(cSpecialCharacters) Then
				Local nTagSub
				For nTagSub=1 to Lenc(cSpecialCharacters)
					If nAsc=Asc(Substrc(cSpecialCharacters,nTagSub,1)) Then
						cReturnValue=cReturnValue+Substrc(cEmailAddress,nTag,1)
						Exit
					EndIf
				EndFor
			EndIf
		EndIf
	EndFor
	Return cReturnValue
EndProc
*------
Procedure ItRun
	Lparameters cApplication,nHide_State,lActivate_State
	If Not IsValidStr(cApplication) Then
		Return .F.
	Else
		cApplication=Alltrim(cApplication)
		If Left(cApplication,1)<>["] Then
			cApplication=["]+cApplication
		EndIf
		If Right(cApplication,1)<>["] Then
			cApplication=cApplication+["]
		EndIf
	Endif
	If Vartype(nHide_State)<>Upper('N') Then
		nHide_State=1 && Show, The default value
	Else
		nHide_State=Int(nHide_State)
		If Not Between(nHide_State,0,1) Then
			nHide_State=1
		Endif
	Endif
	lActivate_State=DefLogic(lActivate_State) && .F., Activate, The default value. You will can not return to Foxpro workspace unti the command not exited if you make this paramete in .T. (UnActivate)
	Local oWScript,cError,lErrored
	cError=On('Error')
	lErrored=.F.
	On Error lErrored=.T.
	oWScript=CreateObject('WScript.Shell')
	oWScript.Run(cApplication,nHide_State,lActivate_State)
	Release oWScript
	On Error &cError.
	If lErrored Then
		Return .F.
	Else
		Return .T.
	EndIf
EndProc
*------
Procedure GetWeb
	Lparameters cUrl,cReadType,nTimeout
	If Not IsValidStr(cUrl) Then
		Return .F.
	EndIf
	If IsValidStr(cReadType) and InList(Upper(Alltrim(cReadType)),Upper('Body'),Upper('Stream'),Upper('Text'),Upper('Xml'))
		cReadType=Upper(Alltrim(cReadType))
	Else
		cReadType=Upper('Text') && Default value
*!*			cReadType=Upper('Body') && If use default value in Body, Then GetGlobalInfo() can not update any datas.
	EndIf
	If Vartype(nTimeOut)<>Upper('N') or nTimeOut<=0 Then
		nTimeOut=5 && 5 seconds, Default value
	EndIf
	Release oXmlHttp
	Local uReturnValue,oXmlHttp,cOnError,lErrored,nTag
	uReturnValue=''
	cOnError=On('Error')
	For nTag=10 to 1 step -1
		lErrored=.F.
		On Error lErrored=.T.
		Do Case
			Case nTag=1
				oXmlHttp=CreateObject('Microsoft.XmlHttp')
			Case nTag=2
				oXmlHttp=CreateObject('Msxml2.XMLHTTP')
			Otherwise
				oXmlHttp=CreateObject('Msxml2.XMLHTTP.'+Alltrim(Str(nTag))+'.0')
		EndCase
		If Not lErrored Then
			Exit
		EndIf
	EndFor
	On Error &cOnError.
	If lErrored Then
		Release oXmlHttp
		Return 'Can not create "XmlHttp" object.'
	EndIf

	lErrored=.F.
	On Error lErrored=.T.
	oXmlHttp.Open('GET',cUrl,.F.)
	oXmlHttp.Send()
	On Error &cOnError.

	If lErrored Then
		uReturnValue='Can not recognize the URL of '+cUrl+' .'
	Else
		Local nStartTime
		nStartTime=Datetime()
		Do while not oXmlHttp.ReadyState=4
			If Datetime()-nStartTime>nTimeOut Then
				oXmlHttp.abort()
				Release oXmlHttp
				Return 'Timeout '+Alltrim(Str(nTimeOut))+' seconds.'
			EndIf
		Enddo
		If Inlist(oXmlHttp.Status,200,0) Then
			uReturnValue='oXmlHttp.response'+cReadType
			uReturnValue=&uReturnValue.
		Else
			uReturnValue='Error code: '+Alltrim(Str(oXmlHttp.Status))
		Endif
	EndIf
	If cReadType=Upper('Text') and Vartype(uReturnValue)<>Upper('C') Then
		uReturnValue=''
	EndIf
	Release oXmlhttp
	Return uReturnValue
EndProc
*------
Procedure Bytes2BStr
	Lparameters cBody,cCharset
	Local cReturnValue
	cReturnValue=''
	If IsNull(cBody) or Vartype(cBody)=Upper('L') or (IsValidStr(cBody,.T.) and Not IsValidStr(cBody)) Then
		Return cReturnValue
	EndIf && Pause
	cCharset=DefCharacters(cCharset,'GB2312')
	Release oStream
	Local 	oStream
	oStream = CreateObject("ADODB.Stream")
	oStream.Type = 1 && adTypeBinary(2,adTypeText )
	oStream.Mode = 3 && adModeReadWrite
	oStream.Open()
	oStream.Write(cbody)
	oStream.Position = 0
	oStream.Type = 2
	oStream.Charset =cCharset
	cReturnValue=oStream.ReadText
	oStream.Close
	Release oStream
	Return cReturnValue
EndProc
*------
Procedure GetWeather
	Lparameters cGoogleURL,cCharset
	If Not IsValidStr(cGoogleURL) Then
		Return ''
	Endif

	Local cTempValue
	If IsValidStr(cCharset) Then
		cTempValue=Bytes2BStr(GetWeb(cGoogleURL,'Body'),cCharset)
	Else
		cTempValue=GetWeb(cGoogleURL)
	Endif
	cTempValue=Strextract(cTempValue,'<!--Content Start-->','<!--Content End-->')
	If Lenc(cTempValue)<=500 Then && Is not valid information
		Return ''
	Else
		Local cCity_E,cMin_S,cMin_E,cMax_S,cMax_E,cWeather_S,cWeather_E,nTag,nCitys && S:Start , E:End
		Store [<span class='font'>] To cCity_S,cMin_S,cMax_S,cWeather_S
		Store [</span>] To cCity_E,cMin_E,cMax_E,cWeather_E
		nCitys=Occurs(Upper(cCity_S),Upper(cTempValue))
		If nCitys=0 Then && No found any city
			Return ''	
		EndIf
	Endif

	Local nSelect
	nSelect=Select()
	Create Cursor csWeather;
		(;
		Sequence c(5),;
		Code c(10),;
		Region c(30),;
		Country c(30),;
		City c(30),;
		Min c(20),;
		Max c(20),;
		Weather c(20),;
		Climate c(20),;
		Adatetime t,;
		Adate c(30),;
		Cdate c(30),;
		Ddate c(30),;
		Cname c(10),;
		URL c(45);
		)
	Select csWeather
	Index on Val(Alltrim(sequence)) Tag Sequence
	Index on Upper(code) Tag Code
	Index on Ctod(dtoc(adatetime)) Tag Adatetime Descending
	Index on Upper(country+city) Tag Doc_key
	Index on Upper(region+country+city) Tag Region

	Local nTempValue,cCountry,cAdate
	nTempValue=0
	cCountry=Strextract(cTempValue,[<FONT color=#660033><SPAN class=font>],[</SPAN></FONT>])
	cAdate=Strextract(cTempValue,[Updated at ],[</SPAN>])
	For nTag=1 To nCitys Step 4
		If Empty(Alltrim(Strextract(cTempValue,cCity_S,cCity_E,nTag))) Or Lenc(Alltrim(Strextract(cTempValue,cCity_S,cCity_E,nTag)))<2 Then
			Loop && It is not valid city name
		Endif
		nTempValue=nTempValue+1
		Select csWeather
		Append Blank
		Replace Sequence With Alltrim(Str(nTempValue))
		Replace Country With cCountry
		Replace City With Strextract(cTempValue,cCity_S,cCity_E,nTag)
		Replace Min With Strextract(Strextract(cTempValue,cMin_S,cMin_E,nTag+1),'>','<')
		Replace Max With Strextract(Strextract(cTempValue,cMax_S,cMax_E,nTag+2),'>','<')
		Replace Weather With Strextract(Strextract(cTempValue,cWeather_S,cWeather_E,nTag+3),'>','<')
		Replace Adatetime With Datetime()
		Replace Adate With cAdate
		Replace URL With cGoogleURL
	Endfor
	Select csWeather
	Set Order To SEQUENCE   && UPPER(SEQUENCE)
	Goto Top
	Select (nSelect)
	Return 'csWeather'
EndProc
*------
Procedure GetGlobalWeather
	lParameters cRegion,cCountry,cCity,cConditionExpression
	cRegion=DefCharacters(cRegion)
	cCountry=DefCharacters(cCountry)
	cCity=DefCharacters(cCity)
	cConditionExpression=DefCharacters(cConditionExpression)
	If Not IsValidStr(cConditionExpression) Then
		cConditionExpression='.T.'
	EndIf

	Local nSelect,cCountryAlias,nCurrentCountry,nValidCountry
	nSelect=Select()
	cCountryAlias=AliasName()
	nCurrentCountry=0
	If Not LcDbfOpen('Countrys',cCountryAlias) Then
		Select (nSelect)
		Return "NA,0 cities found., Error message:Can not found the table 'Countrys'"
	Else
		Select (cCountryAlias)
		Set Filter To uTrim(Region)=uTrim(cRegion) And uTrim(Country)=uTrim(cCountry)
		Count To nValidCountry
	Endif

	Create Cursor csGlobalWeather;
		(;
		Sequence c(5),;
		Code c(10),;
		Region c(30),;
		Country c(30),;
		City c(30),;
		Min c(20),;
		Max c(20),;
		Weather c(20),;
		Climate c(20),;
		Adatetime t,;
		Adate c(30),;
		Cdate c(30),;
		Ddate c(30),;
		Cname c(10),;
		URL c(45);
		)
	Select csGlobalWeather
	Index on Val(Alltrim(sequence)) Tag Sequence
	Index on Upper(code) Tag Code
	Index on Ctod(dtoc(adatetime)) Tag Adatetime Descending
	Index on Upper(country+city) Tag Doc_key
	Index on Upper(region+country+city) Tag Region

	Local cOnError,cError,nRecordsFound,cTempRegion
	cOnError=On('Error')
	cError=''
	On error cError=Message()
	nRecordsFound=0
	Select (cCountryAlias)
	Wait Window 'Completed '+Str(nCurrentCountry/nValidCountry*100,3,0)+'% ……' At Sysmetric(1)/1024*25,Sysmetric(2)/768*70 nowait
	Scan
		cTempRegion=Region
		If Empty(Alltrim(Url)) Or Empty(Alltrim(GetWeather(Alltrim(Url)))) Then
			Loop
		Endif
		If uTrim(Country)==Upper('China') Then
			GetCityWeather('http://www.hko.gov.hk/wxinfo/climat/gdwx.htm','Shenzhen','csWeather')
		Endif
		Select csWeather
		nCurrentCountry=nCurrentCountry+1
		Wait Window 'Completed '+Str(nCurrentCountry/nValidCountry*100,3,0)+'% ……' At Sysmetric(1)/1024*25,Sysmetric(2)/768*70 nowait
		Scan
			If Not (uTrim(City)=uTrim(cCity)) Then
				Loop
			Endif
			If Not (&cConditionExpression.) Then
				Loop
			Endif
			nRecordsFound=nRecordsFound+1
			Replace Region With cTempRegion
			Scatter Memo memvar
			Select csGlobalWeather
			Append Blank
			Gather Memo memvar
			Replace Sequence With Alltrim(Str(nRecordsFound,5,0))
		Endscan
	Endscan
	Wait clear
	LcDbfClose('csWeather')
	LcDbfClose(cCountryAlias)
	Select csGlobalWeather
	Set Order To
	Goto top
	Select (nSelect)
	On Error &cOnError.
	If Empty(cError) Then
		Return 'csGlobalWeather,'+Alltrim(Str(nRecordsFound))+' cities found!, Not error message.'
	Else
		Return 'csGlobalWeather,'+Alltrim(Str(nRecordsFound))+' cities found., Error message:'+cError
	EndIf
EndProc
*------
Procedure GetCityWeather
	Lparameters cUrl,cCityName,cCursorName
	If Not IsValidStr(cUrl) Or Not IsValidStr(cCityName) or Not IsValidStr(cCursorName) Or Select(cCursorName)=0 Then
		Return 0
	Endif
	
	Local cTempValue
	cTempValue=Strextract(GetWeb(cUrl),cCityName,[</tr>],1,1)
	If Len(cTempValue)<100 Then
		Return 0
	Else
		Select (cCursorName)
		Append Blank 
		Replace region With 'Asia'
		Replace country With 'China'
		If Upper(cCityName)=Upper('Shenzhen') Then
			Replace city With 'Hong Kong' && Shenzhen
		Else
			Replace City With Proper(cCityName)
		EndIf
		Replace min With Strextract(Strextract(cTempValue,[<td],[</td>],1),[>])
		Replace max With Strextract(Strextract(cTempValue,[<td],[</td>],2),[>])
		Replace weather With Strextract(Strextract(cTempValue,[<td],[</td>],3),[>])
		Replace sequence With Alltrim(Str(Recno()))
		Return 1
	Endif
EndProc
*------
Procedure GetGlobalWeatherClimate
	Lparameters cRegion,cCountry,cCity,cConditionExpression
	cRegion=DefCharacters(cRegion)
	cCountry=DefCharacters(cCountry)
	cCity=DefCharacters(cCity)
	cConditionExpression=DefCharacters(cConditionExpression)
	If Not IsValidStr(cConditionExpression) Then
		cConditionExpression='.T.'
	Endif
	
	Local nSelect,cCountryAlias,nCurrentCountry,nValidCountry
	nSelect=Select()
	cCountryAlias=AliasName()
	nCurrentCountry=0
	If Not LcDbfOpen('Weather.wsd',cCountryAlias) Then
		Select (nSelect)
		Return "NA,0 cities found., Error message:Can not found the source table 'Weather'"
	Else
		Select (cCountryAlias)
		Set Filter To uTrim(Region)=uTrim(cRegion) And uTrim(Country)=uTrim(cCountry)
		Count To nValidCountry For Not Empty(Climate)
	Endif
		
	Create Cursor csGlobal_Climate;
		(;
			Region c(30),;
			Country c(45),;
			City c(20),;
			Month_Day c(20),;
			Sequence c(5),;
			Min c(20),;
			Max c(20),;
			Img c(35),;
			Weather c(50),;
			Rainfall c(20),;
			Rain_Days c(20),;
			Adatetime T(8),;
			Cdatetime T(8),;
			Url c(70);
		)	
	Select csGlobal_Climate
	Index on Upper(Region+Country+City+Month_Day) Tag Doc_Key
	Index on Upper(Region+Country+City) Tag Region
	
	Local cOnError,cError,nRecordsFound,cTempRegion
	cOnError=On('Error')
	cError=''
	On Error cError=Message()
	nRecordsFound=0
	Select (cCountryAlias)
	Wait Window 'Update world weather climate : % to be completed : '+Str(nCurrentCountry/nValidCountry*100,3,0)+'% ……' At Sysmetric(1)/1024*25,Sysmetric(2)/768*70 nowait
	Scan
		cTempRegion=Region
		If Empty(Alltrim(Climate)) Or Empty(Alltrim(GetWeather_Climate(Alltrim(Climate)))) Then
			Loop
		Endif
		&&Question: How to Get Hong Kong weather 
		Select csClimate
		nCurrentCountry=nCurrentCountry+1
		Scan
			If Not (uTrim(City)=uTrim(cCity)) Then
				Loop
			Endif
			If Not (&cConditionExpression.) Then
				Loop
			Endif
			nRecordsFound=nRecordsFound+1
			Scatter Memo Memvar 
			Insert Into csGlobal_Climate From Memvar 
			Replace csGlobal_Climate.Region With cTempRegion
		Endscan
		Wait Window 'Update World Weather climate : % to be completed : '+Str(nCurrentCountry/nValidCountry*100,3,0)+'% ……' At Sysmetric(1)/1024*25,Sysmetric(2)/768*70 nowait
	EndScan
	Wait clear
	LcDbfClose('csClimate')
	LcDbfClose(cCountryAlias)
	Select csGlobal_Climate
	Set Order To 
	Goto Top
	Select (nSelect)
	On Error &cOnError.
	If Empty(cError) Then
		Return 'csGlobal_Climate,'+Alltrim(Str(nCurrentCountry))+' cities found!, Not error message.'
	Else
		Return 'csGlobal_Climate,'+Alltrim(Str(nCurrentCountry))+' cities found., Error message:'+cError
	Endif
Endproc

Procedure GetWeather_Climate
	Lparameters cClimateUrl
*!*		cClimateUrl='http://worldweather.wmo.int/001/c00554.htm'
	If Not IsValidStr(cClimateUrl) Then
		Return ''
	Endif
	
	Local nSelect,cWebContent,cIssued_Date,cWeather,cClimate,dUpdate_Date,cUpdate_Time,tUpdate_Datetime
	Local cCountry,cCity
	nSelect=Select()
	cWebContent=GetWeb(cClimateUrl)
	cCountry=StrRecombile(Strextract(cWebContent,[<td class="siteheader"><b><font class="text14">],[</td>]))
	If '.htm">' $ cCountry Then
		cCountry=Alltrim(Strextract(cCountry,'.htm">','</a>'))
	Else
		cCountry=Alltrim(Strextract(cCountry,'','<'))
	EndIf
	cCity=Alltrim(Strextract(Strextract(cWebContent,'Weather Information for','</font>'),'>'))
	
	cIssued_Date=DelAspScript(Strextract(cWebContent,'<i>','</i>',1,1),"';',' '")
	cWeather=DelAspScript(DelAspScript(Strextract(cWebContent,'</i>','<!--FDAY',1,1)),"'<b>',''|'</b>',''")
	cClimate=Strextract(cWebContent,'Climatological Information','</body>',1,1)

	&& Step 1: Get Issued datetime
	Create Cursor _GetEmptyDatetime (Temp_Datetime t (8))
	Append Blank In _GetEmptyDatetime
	tUpdate_Datetime=_GetEmptyDatetime.Temp_Datetime
	Use In _GetEmptyDatetime
	If Len(cIsSued_Date)>100 And Len(cIsSued_Date)<200 Then
		If Getwordcount(cIsSued_Date)=8 Then
			cUpdate_Time=Alltrim(Getwordnum(cIsSued_Date,3))
			dUpdate_Date='{^'+Alltrim(Getwordnum(cIsSued_Date,8))+'-'+Alltrim(Str(Month_N(Alltrim(Getwordnum(cIsSued_Date,7)))))+'-'+Alltrim(Getwordnum(cIsSued_Date,6))+'}'
		Else
			cUpdate_Time=''
			dUpdate_Date='{}'
		Endif
		If Not( Empty(&dUpdate_Date.) Or Empty(cUpdate_Time) ) Then
			tUpdate_Datetime=Left(dUpdate_Date,Len(dUpdate_Date)-1)+Space(1)+cUpdate_Time+Right(dUpdate_Date,1)
			tUpdate_Datetime=&tUpdate_Datetime.
		EndIf
	Endif
	
	Create Cursor csClimate;
	(;
		Region c(30),;
		Country c(45),;
		City c(20),;
		Month_Day c(20),;
		Sequence c(5),;
		Min c(20),;
		Max c(20),;
		Img c(35),;
		Weather c(50),;
		Rainfall c(20),;
		Rain_Days c(20),;
		Adatetime T(8),;
		Cdatetime T(8),;
		Url c(70);
	)	
	Select csClimate
	Index on Upper(Region+Country+City+Month_Day) Tag Doc_Key
	Index on Upper(Region+Country+City) Tag Region

	&& Step 2: Get weather forecast information
	If Len(cWeather)>=1000 Then
		cWeather=Strextract(cWeather,'Maximum')
		
		Local nTag,cTmpDate,cTmpMin,cTmpMax,cTmpImg,cTmpWeather,cTmpTag,cTmpValue
		For nTag=1 To Occurs('</td>',cWeather)
			Store '' To cTmpDate,cTmpMin,cTmpMax,cTmpWeather
			cTmpValue=Strextract(Strextract(cWeather,'<td','</td>',nTag),'>')
			cTmpValue=Strtran(cTmpValue,Chr(13)+Chr(10),' ')
			cTmpDate=StrRecombile(cTmpValue)

			If Len(cTmpDate)>=10 And Len(cTmpDate)<=20 Then
				nTag=nTag+1
				cTmpMin=StrRecombile(Strextract(Strextract(cWeather,'<td','</td>',nTag),'>','<',2))
				If Not Between(Len(cTmpMin),1,5) Then
					cTmpMin=''
				Endif
				
				nTag=nTag+1
				cTmpMax=StrRecombile(Strextract(Strextract(cWeather,'<td','</td>',nTag),'>','<',2))
				If Not Between(Len(cTmpMax),1,5) Then
					cTmpMax=''
				Endif
				
				nTag=nTag+1
				cTmpImg=Strextract(Strextract(cWeather,'<td','</td>',nTag),'img src=','alt')
				If Between(Len(cTmpImg),3,35) Then
					If Occurs(['],cTmpImg)=2 Then
						cTmpImg=Strextract(cTmpImg,['],['])
					Else
						If Occurs(["],cTmpImg)=2 Then
							cTmpImg=Strextract(cTmpImg,["],["])
						Endif
					Endif
					cTmpImg=Justfname(cTmpImg)
				Else
					cTmpImg=''
				EndIf
				
				nTag=nTag+2
				cTmpWeather=Strextract(Strextract(cWeather,'<td','</td>',nTag),'>')
				If Not Between(Len(cTmpWeather),1,50) Then
					cTmpWeather=''
				Endif
				
				Insert Into csClimate (Country,City,Month_Day,Sequence,Min,Max,Img,Weather,Adatetime,Cdatetime,Url);
				Values(cCountry,cCity,cTmpDate,Alltrim(Str(Reccount('csClimate')+1)),cTmpMin,cTmpMax,cTmpImg,cTmpWeather,tUpdate_Datetime,Datetime(),cClimateUrl)
			Endif
		EndFor
	Endif
	
	&& Step 3: Get Climatological Information
	If Between(Len(cClimate),10000,20000) Then
		Local cTmpRowDate,nRows,lFoundDate
		Local cTmpMonth,cTmpRainFall,cTmpRainDays,nTmpReccounts
		nTmpReccounts=Reccount('csClimate')
		lFoundDate=.F.
		nRows=Occurs('</tr>',cClimate)+1
		For nTag=1 To nRows
			cTmpRowDate=Strextract(cClimate,'<tr>','</tr>',nTag)
			If Empty(cTmpRowDate) Then
				If lFoundDate Then
					Exit
				Else
					Loop
				EndIf
			Endif
			cTmpMonth=Strextract(cTmpRowDate,'class="month">','</td>',1)
			If Month_N(cTmpMonth)=0 Then
				If lFoundDate Then
					Exit
				Else
					Loop
				Endif
			Else
				lFoundDate=.T.
				cTmpMin=Strextract(Strextract(cTmpRowDate,'<td','</td>',2),'>','<',3)
				If Not Between(Len(cTmpMin),1,10) Then
					cTmpMin=''
				Endif
				cTmpMax=Strextract(Strextract(cTmpRowDate,'<td','</td>',3),'>','<',3)
				If Not Between(Len(cTmpMax),1,10) Then
					cTmpMax=''
				Endif
				cTmpRainFall=Strextract(Strextract(cTmpRowDate,'<td','</td>',4),'>','<',3)
				If Not Between(Len(cTmpRainFall),1,10) Then
					cTmpRainFall=''
				Endif
				cTmpRainDays=Strextract(Strextract(cTmpRowDate,'<td','</td>',5),'>','<',2)
				If Not Between(Len(cTmpRainDays),1,10) Then
					cTmpRainDays=''
				Endif
*!*					?cTmpMonth,cTmpMin,cTmpMax,cTmpRainFall,cTmpRainDays
				Insert Into csClimate (Country,City,Month_Day,Sequence,Min,Max,RainFall,Rain_Days,Adatetime,Cdatetime,Url);
				Values(cCountry,cCity,cTmpMonth,Alltrim(Str(Reccount('csClimate')-nTmpReccounts+1)),cTmpMin,cTmpMax,cTmpRainFall,cTmpRainDays,tUpdate_Datetime,Datetime(),cClimateUrl)
			EndIf
		Endfor
	Endif
	Goto Top In csClimate
	Select (nSelect)
	Return 'csClimate'	
Endproc
*------
Procedure OldValue && Get the value before TableUpdate()
	Lparameters cExpression,cTableAlias_nWorkArea
	If	Not IsValidStr(cExpression) Then
		Wait Window 'No field found . Please input a field name as string .' nowait
		Return ''
	Else
		If Pcount()=1 Then
			Return Oldval(cExpression)
		Else
			Return Oldval(cExpression,cTableAlias_nWorkArea)
		Endif
	Endif
EndProc
*------
Procedure UpdateTime && Question
	Local cOnError,lSuccessed,cTempFile,nReturnValue
	nReturnValue=0
	cOnError=On('Error')
	lSuccessed=.T.
	On Error lSuccessed=.F.
	cTempFile=AliasName()+'.bat'
	Do While File(cTempFile)
		cTempFile=AliasName()+'.bat'
	Enddo
	=Strtofile( ;
		"@net Time /setsntp:210.72.145.44"+Chr(13)+Chr(10)+;
		"@net stop w32time"+Chr(13)+Chr(10)+;
		"@net start w32time"+Chr(13)+Chr(10)+;
		"@w32tm /resync /rediscover",cTempFile;
		)
	Declare Long WinExec In kernel32 String,Long
	If File(cTempFile) Then
		nReturnValue=WinExec(cTempFile,0) && Return 33
	EndIf
	On Error &cOnError.
	Clear Dlls 'WinExec'
	If File(cTempFile) Then
		Local cSetTalk
		cSetTalk=Set("Talk")
		Set Talk off
		Delete File (cTempFile)
		Set Talk &cSetTalk.
	Endif
	If Not lSuccessed Then && Has been found error
		nReturnValue=0
	Endif
	Return nReturnValue
EndProc
*------
Procedure Align_Fill
	Lparameters cString,nLength,cFillTag,cFillText
	If Not IsValidStr(cString) Then
		Return ''
	Endif
	If Not IsNumber(nLength) Then
		Return cString
	Endif
	If Not IsValidStr(cFillTag) Or Not Inlist(uTrim(cFillTag),uTrim('L'),uTrim('R'),uTrim('C')) Then
		Return cString
	Else
		cFillTag=uTrim(cFillTag)
	Endif
	cFillText=DefCharacters(cFillText,' ',.T.)
	Do Case
		Case cFillTag=uTrim('L') && Left alignment, Need to fill text in the right
			cString=PadR(cString,nLength,cFillText)
		Case cFillTag=uTrim('R') && Right alignment, Need to fill text in the left
			cString=PadL(cString,nLength,cFillText)
		Case cFillTag=uTrim('C') && Center alignment, Need to fill text in the left and right
			cString=Padc(cString,nLength,cFillText)
	Endcase
	Return cString
EndProc
*------
Procedure SendKey() && SendKey("%{TAB}") That's mean Keyboard{Alt + Tab}
	Lparameters cKeyExpression
	If Not IsValidStr(cKeyExpression) Then
		Return .F.
	EndIf
	Local oWScript,uReturnValue
	oWScript=CreateObject('WScript.Shell')
	uReturnValue=oWScript.SendKeys(cKeyExpression)
	Release oWScript
	Return uReturnValue
EndProc
*------
Procedure CurrenciesRate
	Lparameters cFirstCurrency,cLastCurrency,cURLTag
	If Not IsValidStr(cFirstCurrency) Then
		Return 0
	Endif
	If Not IsValidStr(cLastCurrency) Then
		Return 0
	Endif
	cURLTag=DefCharacters(cUrlTag,'http://download.finance.yahoo.com/d/quotes.csv?s=')
	cUrlTag=cUrlTag+uTrim(cFirstCurrency)+uTrim(cLastCurrency)+'=X&f=l'
	Local nSetDecimals,nReturnValue
	nSetDecimals=Set("Decimals")
	Set Decimals To 4
	nReturnValue=Val(Alltrim(Strextract(GetWeb(cUrlTag),'<b>','</b>')))
	Set Decimals To nSetDecimals
	Return nReturnValue
EndProc
*------
Procedure GetFolderSize
	Lparameters cFolderName
	&& Unit(Bytes,KB,MB,GB,TB)
	If Not IsValidStr(cFolderName) Then
		Return 0
	Else
		cFolderName=Alltrim(cFolderName)
		If Not Directory(cFolderName) Then
			Return 0
		Endif
	Endif
	Local oFso,oFolder,nReturnValue
	oFso=CreateObject("Scripting.FileSystemObject")
	oFolder=oFso.GetFolder(cFolderName)
	If oFolder.IsRootFolder Then
		nReturnValue=oFolder.Drive.TotalSize
	Else
		nReturnValue=oFolder.Size
	EndIf
	Release oFso,oFolder
	Return nReturnValue
EndProc
*------
Procedure String_Transfer
	Lparameters cString
	If Not IsValidStr(cString,.T.) Then
		Return ''
	Endif
	Local cReturnValue,cTempLength,nTag
	cReturnValue=''
	nTempLength=Lenc(cString)
	For nTag=nTempLength To 1 Step -1
		cReturnValue=cReturnValue+Substrc(cString,nTag,1)
	Endfor
	Return cReturnValue
EndProc
*------
Procedure String_DelEmptyLine
	Lparameters cString
	If Not IsValidStr(cString,.T.) Then
		Return ''
	EndIf 
	
	Local cTmpValue,cReturnValue,cSplit,nOccurs,nTag
	cTmpValue=''
	cReturnValue=''
	cSplit=Chr(13)+Chr(10)
	nOccurs=Occurs(cSplit,cString)+1	
	If nOccurs=0 Then
		Return cString
	EndIf
	
	For nTag=1 to nOccurs
		If nTag=1 Then
			If Leftc(Alltrim(Str(GetVfpVersion())),1)>'6' Then
				cTmpValue=StrExtract(cString,'',cSplit,1)
			Else && Run in vfp6 or more lower version
				cTmpValue=ItStrExtract(cString,'',cSplit,1)
			EndIf
		Else
			If nTag<nOccurs Then
				If Leftc(Alltrim(Str(GetVfpVersion())),1)>'6' Then
					cTmpValue=StrExtract(cString,cSplit,cSplit,nTag-1)
				Else
					cTmpValue=ItStrExtract(cString,cSplit,cSplit,nTag-1)
				EndIf
			Else && nTag=nOccurs
				If Left(Alltrim(Str(GetVfpVersion())),1)>'6' Then
					cTmpValue=StrExtract(cString,cSplit,'',nTag-1)
				Else
					cTmpValue=ItStrExtract(cString,cSplit,'',nTag-1)
				EndIf
			EndIf
		EndIf
		
		If Empty(Alltrim(cTmpValue)) Then
			Loop
		Else
			cReturnValue=cReturnValue+cTmpValue+cSplit
		EndIf
	EndFor
	
	Return cReturnValue		
EndProc
*------
Procedure String_DelDigit
	Lparameters cString
	If Not IsValidStr(cString) Then
		Return cString
	Endif
	Local cReturnValue,nTag,cTempValue
	cReturnValue=''
	cTempValue=''
	For nTag=1 To Lenc(cString)
		cTempValue=Substrc(cString,nTag,1)
		If Isdigit(cTempValue) Then
			Loop && Remove
		Else
			If Empty(cReturnValue) Then
				cReturnValue=cTempValue
			Else
				cReturnValue=cReturnValue+cTempValue
			Endif
		Endif
	Endfor
	Return cReturnValue
Endproc
*------
Procedure String_GetDigit
	Lparameters cString
	If Not IsValidStr(cString) Then
		Return cString
	Endif
	Local cReturnValue,nTag,cTempValue
	cReturnValue=''
	cTempValue=''
	For nTag=1 To Lenc(cString)
		cTempValue=Substrc(cString,nTag,1)
		If Not Isdigit(cTempValue) Then
			Loop && Remove
		Else
			If Empty(cReturnValue) Then
				cReturnValue=cTempValue
			Else
				cReturnValue=cReturnValue+cTempValue
			Endif
		Endif
	Endfor
	Return cReturnValue
EndProc
*------
Procedure String_DelAlpha
	Lparameters cString
	If Not IsValidStr(cString) Then
		Return cString
	Endif
	Local cReturnValue,nTag,cTempValue
	cReturnValue=''
	cTempValue=''
	For nTag=1 To Lenc(cString)
		cTempValue=Substrc(cString,nTag,1)
		If Isalpha(cTempValue) Then
			Loop && Remove
		Else
			If Empty(cReturnValue) Then
				cReturnValue=cTempValue
			Else
				cReturnValue=cReturnValue+cTempValue
			Endif
		Endif
	Endfor
	Return cReturnValue
Endproc
*------
Procedure String_GetAlpha && Usually use to get valid field name, Example. ? String_GetAlpha('Url_E-mail2 ','_') && "Url_Email"
	Lparameters cString,cExcept_Del_StringExp
	If Not IsValidStr(cString) Then
		Return cString
	EndIf
	cExcept_Del_StringExp=DefCharacters(cExcept_Del_StringExp)
	
	Local cReturnValue,nTag,cTempValue,lNeedto_except_delete_some_characters
	If IsValidStr(cExcept_Del_StringExp,.T.) and Lenc(cExcept_Del_StringExp)>0 Then
		lNeedto_except_delete_some_characters=.T.
		Local nSubTagCount,nSubTag,cSubTempValue,lFound_except_character
		nSubTagCount=Lenc(cExcept_Del_StringExp)
	Else
		lNeedto_except_delete_some_characters=.F.
	EndIf		
	cReturnValue=''
	cTempValue=''
	
	For nTag=1 To Lenc(cString)
		cTempValue=Substrc(cString,nTag,1)		
		If IsAlpha(cTempValue) Then
			cReturnValue=Iif(Empty(cReturnValue),cTempValue,cReturnValue+cTempValue)
		Else
			lFound_except_character=.F.
			If lNeedto_except_delete_some_characters Then
				For nSubTag=1 to nSubTagCount
					cSubTempValue=Substrc(cExcept_Del_StringExp,nSubTag,1)
					If cTempValue==cSubTempValue Then
						lFound_except_character=.T.
						Exit
					EndIf
				EndFor
			EndIf
			If lFound_except_character Then
				cReturnValue=Iif(Empty(cReturnValue),cTempValue,cReturnValue+cTempValue) && Else ,Do nothing, That mean remove this one character
			EndIf
		EndIf
	EndFor
	
	Return cReturnValue
EndProc
*------
Procedure String_DelSpecial
	Lparameters cString,cSpecialString
	If Not IsValidStr(cString) Then
		Return cString
	Endif
	If Not IsValidStr(cSpecialString) Then
		Return cString
	EndIf
	Local cReturnValue,nTag,cTempValue,nSubTag,lExcept
	cReturnValue=''
	For nTag=1 to Lenc(cString)
		cTempValue=Substrc(cString,nTag,1)
		lExcept=.F.
		For nSubTag=1 To Lenc(cSpecialString)
			If Substrc(cSpecialString,nSubTag,1)==cTempValue Then
				lExcept=.T.
				Exit
			EndIf
		Endfor
		If lExcept Then
			Loop
		Else
			If Empty(cReturnValue) Then
				cReturnValue=cTempValue
			Else
				cReturnValue=cReturnValue+cTempValue
			Endif
		Endif
	Endfor
	Return cReturnValue
EndProc
*------
Procedure ItValidName
	Lparameters cString,cSpecial_List
	
	cString = DefCharacters(cString,.T.)
	cSpecial_List = DefCharacters(cSpecial_List,.T.) + '\/:*?"<>|'
	
	Local cReturnValue
	cReturnValue = ''
	
	cReturnValue = String_DelSpecial(cString,cSpecial_List)
	
	Return cReturnValue
EndProc
*------
Procedure IsConnectInternet
	DECLARE Integer  InternetGetConnectedState IN "wininet.dll" Integer,Integer
	Return Iif(Empty(InternetGetConnectedState(0,0)),.F.,.T.)
EndProc
*------
Procedure ScreenProtect
	Declare Integer FindWindow  In Win32api String, String
	Declare Integer SendMessage In User32 Integer,integer,integer,integer
	Local nFhwnd 
	nFhwnd= FindWindow(0, _screen.caption)
	#Define wMsg      274
	#Define wParam    -3776
	#Define wPsave    61760
	Return Iif(SendMessage(nFhwnd, wMsg, wPsave, 0)=0,.T.,.F.)  &&开始屏幕保护
Endproc
*------
Procedure IsInstallWave && 是否安装好声卡
	DECLARE INTEGER waveInGetNumDevs IN winmm.dll
	Return Iif(waveInGetNumDevs()>0,.T.,.F.)
Endproc
*------
Procedure GetFirstSpell
	Lparameter cString
	If Not IsValidStr(cString,.T.)
		Return cString
	Else
		cString=Strconv(cString,2) && Convert double tyte into single bytes.
	Endif
	Local nTag,thisstr,cTempHz,cReturnValue,qw,nStringLength,_pbstr_
	Thisstr=alltrim(m.cString)
	nStringLength =len(m.thisstr)
	cReturnValue=""
	_PBSTR_=;
		Replicate("A",36)+;
		Replicate("B",196)+;
		Replicate("C",245)+;
		Replicate("D",196)+;
		Replicate("E",28)+;
		Replicate("F",131)+;
		Replicate("G",161)+;
		Replicate("H",193)+;
		Replicate("J",319)+;
		Replicate("K",106)+;
		Replicate("L",260)+;
		Replicate("M",163)+;
		Replicate("N",87)+;
		Replicate("O",8)+;
		Replicate("P",128)+;
		Replicate("Q",169)+;
		Replicate("R",59)+;
		Replicate("S",304)+;
		Replicate("T",168)+;
		Replicate("W",126)+;
		Replicate("X",241)+;
		Replicate("Y",324)+;
		Replicate("Z",341)+Space(11)+;
		"CJWGNSPGCGNE Y BTYYZDXYKYGT JNNJQMBSGZSCYJSYY PGKBZGY YWYKGKLJSWKPJQHY W DZLSGMRYPYWWCCKZNKYYG "+;
		"TTNJJEYKKZYTCJNMCYLQLYPYQFQRPZSLWBTGKJFYXJWZLTBNCXJJJJZXDTTSQZYCDXXHGCK PHFFSS YBGMXLPBYLL HLX "+;
		"S ZM JHSOJNGHDZQYKLGJHXGQZHXQGKEZZWYSCSCJXYEYXADZPMDSSMZJZQJYZC J WQJBDZBXGZNZCPWHKXHQKMWFBPBY "+;
		"DTJZZKQHYLYGXFPTYJYYZPSZLFCHMQSHGMXXSXJ DCSBBQBEFSJYHXWGZKPYLQBGLDLCCTNMAYDDKSSNGYCSGXLYZAYBN "+;
		"PTSDKDYLHGYMYLCXPY JNDQJWXQXFYYFJLEJPZRXCCQWQQSBZKYMGPLBMJRQCFLNYMYQMSQYRBCJTHZTQFRXQHXMJJCJLX "+;
		"XGJMSHZKBSWYEMYLTXFSYDSGLYCJQXSJNQBSCTYHBFTDCYZDJWYGHQFRXWCKQKXEBPTLPXJZSRMEBWHJLBJSLYYSMDXLCL "+;
		"QKXLHXJRZJMFQHXHWYWSBHTRXXGLHQHFNM YKLDYXZPWLGG MTCFPAJJZYLJTYANJGBJPLQGDZYQYAXBKYSECJSZNSLYZH "+;
		"ZXLZCGHPXZHZNYTDSBCJKDLZZYFMYDLEBBGQYZKXGLDNDNYSKJSHDLYXBCGHXYPKDQMMZMGMMCLGWZSZXZJFZNMLZZTHCS "+;
		"YDBDLLSCDDNLKJYKJSYCJLKOHQASDKNHCSGZEHDAASHTCPLCPQYBSDMPJLPZJOQLCDHJJYSPRCHN NNLHLYYQYHWZPTCZG "+;
		"WWMZFFJQQQQYXACLBHKDJXDGMMYDJXZLLSYGXGKJRYWZWYCLZMSSJZLDBYDCPCXYHLXCHYZJQ QAGMNYXPFRKSSBJLYXY "+;
		"SYGLNSCMHSWWMNZJJLXXHCHSY CTXRYCYXBYHCSMXJSZNPWGPXXTAYBGAJCXLY DCCWZOCWKCCSBNHCPDYZNFCYYTYCKX "+;
		"KYBSQKKYTQQXFCWCHCYKELZQBSQYJQCCLMTHSYWHMKTLKJLYCXWHYQQHTQH PQ QSCFYMMDMGBWHWLGSLLYSDLMLXPTHMJ "+;
		"HWLJZYHZJXHTXJLHXRSWLWZJCBXMHZQXSDZPMGFCSGLSXYMQSHXPJXWMYQKSMYPLRTHBXFTPMHYXLCHLHLZYLXGSSSSTCL "+;
		"SLTCLRPBHZHXYYFHB GDNYCNQQWLQHJJ YWJZYEJJDHPBLQXTQKWHLCHQXAGTLXLJXMSL HTZKZJECXJCJNMFBY SFYWYB "+;
		"JZGNYSDZSQYRSLJPCLPWXSDWEJBJCBCNAYTWGMPABCLYQPCLZXSBNMSGGFNZJJBZSFZYNDXHPLQKZCZWALSBCCJX YZHWK "+;
		"YPSGXFZFCDKHJGXDLQFSGDSLQWZKXTMHSBGZMJZRGLYJBPMLMSXLZJQSHZYJ ZYDJWBMJKLDDPMJEGXYHYLXHLQYQHKYCW "+;
		"CJMYYXNATJHYCCXZPCQLBZWWYTWBQCMLPMYRJCCCXFPZNZZLJPLXXYZTZLGDLDCKLYRZZGQTGJHHGJLJAXFGFJZSLCFDQZ "+;
		"LCLGJDJCSNCLLJPJQDCCLCJXMYZFTSXGCGSBRZXJQQCTZHGYQTJQQLZXJYLYLBCYAMCSTYLPDJBYREGKJZYZHLYSZQLZNW "+;
		"CZCLLWJQJJJKDGJZOLBBZPPGLGHTGZXYGHZMYCNQSYCYHBHGXKAMTXYXNBSKYZZGJZLQJDFCJXDYGJQJJPMGWGJJJPKQSB "+;
		"GBMMCJSSCLPQPDXCDYYKY CJDDYYGYWRHJRTGZNYQLDKLJSZZGZQZJGDYKSHPZMTLCPWNJZFYZDJCNMWESCYGLBTZCGMSS "+;
		"LLYXQSXSBSJSBBSGGHFJLYPMZJNLYYWDQSHZXTYYWHMZYHYWDBXBTLMSYYYFSXJC TXXLHJHF SXZQHFZMZCZTQCXZXRTT "+;
		"DJHNNYZQQMNQDMMG YTXMJGDHCDYZBFFALLZTDLTFXMXQZDNGWQDBDCZJDXBZGSQQDDJCMBKZFFXMKDMDSYYSZCMLJDSYN "+;
		"SPRSKMKMPCKLGDCQTFZSWTFGGLYPLLJZHGJ GYPZLTCSMCNBTJBQFKTHBYZGHPBBYMTDSSXTBNPDKLEYCJNYDDYKZTDHQH "+;
		"SDZSCTARLLTKZLGECLLKJLQJZQNBDKKGHPJTZQKSECSHALQFMMGJNLYJBBTMLYZXDCJPLDLPCQDHZYCBZSCZBZMSLJFLKR "+;
		"ZJSNFRGJHXPDHYJYBZGDLJCSEZGXLBLHYXTWMABCHECMWYJYZLLJJYHLG DJLSLYGKDZPZXJYYZLWCXSZFGWYYDLYHCLJS "+;
		"CMBJHBLYZLYCBLYDPDQYSXQZBYTDKYYJY CNRJMPDJGKLCLJBCTBJDDBBLBLCZQRPPXJCGLZCSHLTOLJNMDDDLNGKAQHQH "+;
		"JHYKHEZNMSHRP QQJCHGMFPRXHJGDYCHGHLYRZQLCYQJNZSQTKQJYMSZSWLCFQQQZYFGGYPTQWLMCRNFKKFSYYLQBMQAMM "+;
		"MYXCTPSHCPTXXZZSMPHPSHMCLMLDQFYQFSZYJDJJZZHQPDSZGLSTJBCKBXYQZJSGPSXQZQZRQTBDKYXZKHHGFLBCSMDLDG "+;
		"DZDBLZYYCXNNCSYBZBFGLZZXSWMSCCMQNJQSBDQSJTXXMBLTXZCLZSHZCXRQJGJYLXZFJPHY ZQQYDFQJJLZZNZJCDGZYG "+;
		"CTXMZYSCTLKPHTXHTLBJXJLXSCDQXCBBTJFQZFSLTJBTKQBXXJJLJCHCZDBZJDCZJDCPRNPQCJPFCZLCLZXZDMXMPHJSGZ "+;
		"GSZZQLYLWTJPFSYAXMCJBTZYYCWMYTCSJJLQCQLWZMALBXYFBPNLSFHTGJWEJJXXGLLJSTGSHJQLZFKCGNNDSZFDEQFHBS "+;
		"AQTGYLBXMMYGSZLDYDQMJJRGBJTKGDHGKBLQKBDMBYLXWCXYTTYBKMRTJZXQJBHLMHMJJZMQASLDCYXYQDLQCAFYWYXQHZ"
	For nTag = 1 To M.nStringLength
		If Asc(substr(m.thisstr,nTag,1))>160
			cTempHz=substr(m.thisstr,nTag,2)
			Qw=100 * Asc(left(m.cTempHz,1)) + Asc(right(m.cTempHz,1)) - 17760
			cReturnValue=iif(m.qw<1,m.cReturnValue+"v",m.cReturnValue+substr(_pbstr_,m.qw,1))
			nTag=nTag+1
		Else
			cReturnValue=m.cReturnValue+substr(m.thisstr,nTag,1)
		Endif
	Endfor
	Return M.cReturnValue
Endproc
*------
Procedure DelAspScript
	Lparameters cString,cAddFormat
	If Not IsValidStr(cString) Then
		Return ''
	Endif
	Local cAspString,cDefScriptString
	cAspString=''
	cDefScriptString=["&nbsp",Chr(32)|"<br>", Chr(13)+Chr(10)|"&amp;","&"]
	If IsValidStr(cAddFormat) .And. ',' $ cAddFormat Then
		If Leftc(cAddFormat,1)='|' Then
			cAddFormat=Rightc(cAddFormat,Lenc(cAddFormat)-1)
		Endif
		If Rightc(cAddFormat,1)='|' Then
			cAddFormat=Leftc(cAddFormat,Lenc(cAddFormat)-1)
		Endif
		cAspString=cAddFormat+'|'+cDefScriptString
	Else
		cAspString=cDefScriptString
	Endif
	
	&& Use cTempValue to store any substr delimiter '|' .
	Local nTag,nSubTotal,cTempValue
	nSubTotal=Occurs('|',cAspString)+1
	For nTag=1 To nSubTotal
		If nTag=1 Then
			cTempValue=Substrc(cAspString, 1, (Atc('|',cAspString)-1) )
		Else
			If nTag=nSubTotal Then
				cTempValue=Substrc(cAspString, (Atc('|',cAspString,nSubtotal-1)+1) )
			Else
				cTempValue=Strextract(cAspString,'|','|',nTag-1)
			Endif
		Endif
		If ',' $ cTempValue Then && Is valid substr string.
			Local cSourceTag,cTargetTag
			cSourceTag=Substrc(cTempValue,1,Atc(',',cTempValue)-1)
			cTargetTag=Substrc(cTempValue,Atc(',',cTempValue)+1)
			Local cOnError,lErrored
			cOnError=On('Error')
			lErrored=.F.
			On Error lErrored=.T.
			If Vartype(&cSourceTag.)=Upper('C') And Vartype(&cTargetTag.)=Upper('C') Then
				cString=Strtran(cString,&cSourceTag,&cTargetTag)
			Endif
			On Error &cOnError.
		Endif
	Endfor
	Return cString
Endproc
*------
Procedure GetGlobalInfo
	Lparameters cFilter,nValid_min_length,nValid_max_length,lAutoClose
	cFilter=DefCharacters(cFilter)
	nValid_min_length=DefNumber(nValid_min_length,3)
	nValid_max_length=DefNumber(nValid_max_length,15)
	lAutoClose=DefLogic(lAutoClose)
	If Not Used('Global_Analysis') And Not LcDbfOpen('GlobalInfo','Global_Analysis') Then
		Return 0
	EndIf
	Select Global_Analysis
	Set Order To name   && UPPER(ALLTRIM(NAME))
	If IsValidStr(cFilter) Then
		Set Filter To &cFilter.
	EndIf
		
	cGoogle_Url="http://www.google.com/finance"
	Local cGoogle_content,nUpdateCount,lUpdated,nTag,cTempName
	nUpdateCount=0
	cGoogle_content=DelAspScript(DelAspScript(GetWeb(cGoogle_Url)),"';',Chr(13)+Chr(10)")
	If Len(cGoogle_content)>800 Then
		**-------------- Upgrade Major index -----------------**
		Local cMajor_Index,nMajor_Index
		cMajor_Index=Strextract(cGoogle_content,[<table id="sfe-mktsumm">],[</table>])
		cMajor_Index=Strtran(cMajor_Index,Chr(10),'')
		nMajor_Index=Occurs([<a href="/finance?q=INDEX],cMajor_Index)
		If nMajor_Index>0 Then
			For nTag=1 To nMajor_Index
				cTempName=Strextract(Strextract(cMajor_Index,[<a href="/finance?q=INDEX],[</a>],nTag),'>')
				cTempName=Alltrim(Upper(cTempName))
				If Not Empty(cTempName) And Seek(cTempName,'Global_Analysis') Then
					lUpdated=.F.
					Store '' To cTempPrice,cTempChange,cTempUpDown
					cTempPrice= Strextract(Strextract(cMajor_Index,[<span],[</span>],(nTag-1)*3+1),[>])
					cTempPrice=Alltrim(cTempPrice)
					cTempChange=Strextract(Strextract(cMajor_Index,[<span],[</span>],(nTag-1)*3+2),[>])
					cTempChange=Alltrim(cTempChange)
					cTempUpDown=Strextract(Strextract(cMajor_Index,[<span],[</span>],(nTag-1)*3+3),[>])
					cTempUpDown=Alltrim(cTempUpDown)
					If Len(cTempPrice)>=nValid_min_length And Len(cTempPrice)<=nValid_max_length Then
						Replace Global_Analysis.Price With cTempPrice
						lUpdated=.T.
					Endif
					If Len(cTempChange)>=nValid_min_length And Len(cTempChange)<=nValid_max_length Then
						Replace Global_Analysis.Change With cTempChange
						lUpdated=.T.
					Endif
					If Len(cTempUpDown)>=nValid_min_length And Len(cTempUpDown)<=nValid_max_length Then
						Replace Global_Analysis.Updown With cTempUpDown
						lUpdated=.T.
					Endif
					If lUpdated Then
						nUpdateCount=nUpdateCount+1
						Replace Global_Analysis.Adatetime With Datetime()
					EndIf
				EndIf
			Endfor
		EndIf
		
		**-------------- Upgrade Minor index -----------------**
		Local cMinor_Index,nMinor_Index
		cMinor_Index=Strextract(cGoogle_content,[<div id=markets>],[</table>])
		cMinor_Index=Strtran(cMinor_Index,Chr(10),'')
		nMinor_Index=Occurs([<a href="/finance?q=],cMinor_Index)
		If nMinor_Index>0 Then
			For nTag=1 To nMinor_Index
				cTempName=Strextract(Strextract(cMinor_Index,[<a href="/finance?q=],[<td class=price>],nTag),[>])
				cTempName=Alltrim(Upper(cTempName))
				If Not Empty(cTempName) And Seek(cTempName,'Global_Analysis') Then
					lUpdated=.F.
					Store '' To cTempPrice,cTempChange,cTempUpDown
					cTempPrice=Strextract(Strextract(cMinor_Index,[<span],[</span>],(nTag-1)*3+1),[>])
					cTempPrice=Alltrim(cTempPrice)
					cTempChange=Strextract(Strextract(cMinor_Index,[<span],[</span>],(nTag-1)*3+2),[>])
					cTempChange=Alltrim(cTempChange)
					cTempUpDown=Strextract(Strextract(cMinor_Index,[<span],[</span>],(nTag-1)*3+3),[>])
					cTempUpDown=Alltrim(cTempUpDown)
					If Len(cTempPrice)>=nValid_min_length And Len(cTempPrice)<=nValid_max_length Then
						Replace Global_Analysis.Price With cTempPrice
						lUpdated=.T.
					Endif
					If Len(cTempChange)>=nValid_min_length And Len(cTempChange)<=nValid_max_length Then
						Replace Global_Analysis.Change With cTempChange
						lUpdated=.T.
					Endif
					If Len(cTempUpDown)>=nValid_min_length And Len(cTempUpDown)<=nValid_max_length Then
						Replace Global_Analysis.Updown With cTempUpDown
						lUpdated=.T.
					Endif
					If lUpdated Then
						nUpdateCount=nUpdateCount+1
						Replace Global_Analysis.Adatetime With Datetime()
					Endif
				EndIf
			Endfor
		Endif
		
		**-------------- Upgrade Currencies -----------------**
		Local cCurrencies,nCurrencies
		cCurrencies=Strextract(cGoogle_content,[<div id=currencies>],[</table>])
		cCurrencies=Strtran(cCurrencies,Chr(10),'')
		nCurrencies=Occurs([<a href="/finance?q=],cCurrencies)	
		If nCurrencies>0 Then
			For nTag=1 To nCurrencies
				cTempName=Strextract(Strextract(cCurrencies,[<a href="/finance?q=],[</a>],nTag),[>])
				cTempName=Alltrim(Upper(cTempName))
				If Not Empty(cTempName) And Seek(cTempName,'Global_Analysis') Then
					lUpdated=.F.
					Store '' To cTempPrice,cTempChange,cTempUpDown				
					cTempPrice=Strextract(cCurrencies,[<td class=price>],[<td],nTag) && Question 有乱码
					cTempPrice=Alltrim(cTempPrice)
					If nTag=nCurrencies Then
						cTempChange=Strextract(cCurrencies,[<td class="change],[],nTag)
					Else
						cTempChange=Strextract(cCurrencies,[<td class="change],[<tr>],nTag)
					Endif
					cTempChange=Alltrim(Strextract(cTempChange,[>])) 				
					cTempUpDown='('+Strextract(cTempChange,[(],[)])+')'
					cTempUpDown=Alltrim(cTempUpDown)
					
					cTempChange=Left(cTempChange,At('(',cTempChange)-1)
					
					If Len(cTempPrice)>=nValid_min_length And Len(cTempPrice)<=nValid_max_length Then
						Replace Global_Analysis.Price With cTempPrice
						lUpdated=.T.
					Endif
					If Len(cTempChange)>=nValid_min_length And Len(cTempChange)<=nValid_max_length Then
						Replace Global_Analysis.Change With cTempChange
						lUpdated=.T.
					Endif
					If Len(cTempUpDown)>=nValid_min_length And Len(cTempUpDown)<=nValid_max_length Then
						Replace Global_Analysis.UpDown With cTempUpDown
						lUpdated=.T.
					Endif				
					If lUpdated Then
						nUpdateCount=nUpdateCount+1
						Replace Global_Analysis.Adatetime With Datetime()
					EndIf
				Endif
			Endfor
		Endif
		
		**-------------- Upgrade bonds -----------------**
		Local cBonds,nBonds
		cBonds=Strextract(cGoogle_content,[<div id=bonds>],[</table>])
		cBonds=Strtran(cBonds,Chr(10),'')
		nBonds=Occurs([<td class=symbol>],cBonds)
		If nBonds>0 Then
			For nTag=1 To nBonds
				cTempName=Strextract(cBonds,[<td class=symbol>],[<td class=price>],nTag)
				cTempName=Alltrim(Upper(cTempName))
				If Not Empty(cTempName) And Seek(cTempName,'Global_Analysis') Then
					lUpdated=.F.
					Store '' To cTempPrice,cTempChange,cTempUpdown
					cTempPrice=Strextract(cBonds,[<td class=price>],[<td class="change],nTag)
					cTempPrice=Alltrim(cTempPrice)
					If nTag=nBonds Then
						cTempChange=Strextract(Strextract(cBonds,[<td class="change],'',nTag),[>])
					Else
						cTempChange=Strextract(Strextract(cBonds,[<td class="change],[<tr>],nTag),[>])
					EndIf
					cTempChange=Alltrim(cTempChange)
					cTempUpDown=Strextract(cTempChange,'(',')')
					cTempChange=Left(cTempChange,At('(',cTempChange)-1)
					
					If Len(cTempPrice)>=nValid_min_length And Len(cTempPrice)<=nValid_max_length Then
						Replace Global_Analysis.Price With cTempPrice
						lUpdated=.T.
					Endif
					If Len(cTempChange)>=nValid_min_length And Len(cTempChange)<=nValid_max_length Then
						Replace Global_Analysis.Change With cTempChange
						lUpdated=.T.
					Endif
					If Len(cTempUpDown)>=nValid_min_length And Len(cTempUpdown)<=nValid_max_length Then
						Replace Global_Analysis.Updown With cTempUpDown
						lUpdated=.T.
					Endif
					If lUpdated Then
						nUpdateCount=nUpdateCount+1
						Replace Global_Analysis.Adatetime With Datetime()
					Endif
				Endif
			Endfor
		EndIf
	Endif
	
	cBloomberg_Url="http://www.bloomberg.com/markets/commodities/cfutures.html"
	Local cBloomberg_content,cStart_Delimit,cEnd_Delimit	
	cBloomberg_content=DelAspScript(DelAspScript(GetWeb(cBloomberg_Url)),"';',''")
	If Len(cBloomberg_content)>800 Then
		cStart_Delimit=[<span class]
		cEnd_Delimit=[</span>]	
		**-------------- Upgrade Index -----------------**
		Local cIndex,nIndex
		cIndex=Strextract(cBloomberg_content,[Commodity Futures],[Energy],3)
		nIndex=Occurs(cStart_Delimit,cIndex)
		If nIndex>0 Then
			For nTag=1 To nIndex
				cTempName=Strextract(Strextract(cIndex,cStart_Delimit,cEnd_Delimit,nTag),[>])
				cTempName=Alltrim(Upper(cTempName))
				If Not Empty(cTempName) And Seek(cTempName,'Global_Analysis') Then
					Store '' To m.Price,m.Change,m.Open,m.High,m.Low,m.Time
					lUpdated=.F.
					m.Price= Alltrim(Strextract(Strextract(cIndex,cStart_Delimit,cEnd_Delimit,nTag+1),[>]))
					m.Change=Alltrim(Strextract(Strextract(cIndex,cStart_Delimit,cEnd_Delimit,nTag+2),[>]))
					m.Open=  Alltrim(Strextract(Strextract(cIndex,cStart_Delimit,cEnd_Delimit,nTag+3),[>]))
					m.High=  Alltrim(Strextract(Strextract(cIndex,cStart_Delimit,cEnd_Delimit,nTag+4),[>]))
					m.Low =  Alltrim(Strextract(Strextract(cIndex,cStart_Delimit,cEnd_Delimit,nTag+5),[>]))
					m.Time=	 Alltrim(Strextract(Strextract(cIndex,cStart_Delimit,cEnd_Delimit,nTag+6),[>]))
					nTag=nTag+6
					
					If Len(m.Price)>=nValid_min_length And Len(m.Price)<=nValid_max_length Then
						Replace Global_Analysis.Price With m.Price
						lUpdated=.T.
					Endif
					If Len(m.Change)>=nValid_min_length And Len(m.Change)<=nValid_max_length Then
						Replace Global_Analysis.Change With m.Change
						lUpdated=.T.
					Endif
					If Len(m.Open)>=nValid_min_length And Len(m.Open)<=nValid_max_length Then
						Replace Global_Analysis.Open With m.Open
						lUpdated=.T.
					Endif
					If Len(m.High)>=nValid_min_length And Len(m.High)<=nValid_max_length Then
						Replace Global_Analysis.High With m.High
						lUpdated=.T.
					Endif
					If Len(m.Low)>=nValid_min_length And Len(m.Low)<=nValid_max_length Then
						Replace Global_Analysis.Low With m.low
						lUpdated=.T.
					Endif
					If Len(m.Time)>=nValid_min_length And Len(m.Time)<=nValid_max_length Then
						Replace Global_Analysis.Time With m.Time
						lUpdated=.T.
					Endif					
*!*						?Padr(cTempname,40,' '),Padr(m.Price,15,' '),Padr(m.Change,15,' '),Padr(m.Open,15,' '),Padr(m.High,15,' '),Padr(m.Low,15,' '),Padr(m.Time,15,' ')
					If lUpdated Then
						nUpdateCount=nUpdateCount+1
						Replace Global_Analysis.Adatetime With Datetime()
						If Alltrim(Upper(Global_Analysis.Chiname))=Upper('INDEX NAME') Then
							Replace Global_Analysis.UpDown With ''
						EndIf
					Endif
				Endif
			Endfor
		EndIf
		
		**-------------- Upgrade Energy and all-----------------**
		Local cEnergy_and_all,nEnergy
		cEnergy_and_all=Strextract(cBloomberg_content,[Energy],[],2)
		nEnergy=Occurs(cStart_Delimit,cEnergy_and_all)
		If nEnergy>0 Then
			For nTag=1 To nEnergy
				cTempName=Strextract(Strextract(cEnergy_and_all,cStart_Delimit,cEnd_Delimit,nTag),[>])
				cTempName=Alltrim(Upper(cTempName))
				If Not Empty(cTempName) And Seek(cTempname,'Global_Analysis') Then
					Store '' To m.Lastname,m.Price,m.Change,m.UpDown,m.Time
					lUpdated=.F.		
					m.Lastname=Alltrim(Strextract(Strextract(cEnergy_and_all,cStart_Delimit,cEnd_Delimit,nTag+1),[>]))
					m.Price=Alltrim(Strextract(Strextract(cEnergy_and_all,cStart_Delimit,cEnd_Delimit,nTag+2),[>]))
					m.Change=Alltrim(Strextract(Strextract(cEnergy_and_all,cStart_Delimit,cEnd_Delimit,nTag+3),[>]))
					m.UpDown=Alltrim(Strextract(Strextract(cEnergy_and_all,cStart_Delimit,cEnd_Delimit,nTag+4),[>]))
					m.Time=Alltrim(Strextract(Strextract(cEnergy_and_all,cStart_Delimit,cEnd_Delimit,nTag+5),[>]))
					nTag=nTag+5
									
					If Len(m.LastName)>=nValid_min_length And Len(m.LastName)<=nValid_max_length Then
						If Alltrim(Upper(Global_Analysis.Name))<>cTempName+' '+Upper(m.LastName) Then
							Replace Global_Analysis.name With cTempName+' '+Upper(m.LastName)
							lUpdated=.T.
						Endif
					Endif
					If Len(m.Price)>=nValid_min_length And Len(m.Price)<=nValid_max_length Then
						Replace Global_Analysis.Price With m.Price
						lUpdated=.T.
					Endif
					If Len(m.Change)>=nValid_min_length And Len(m.Change)<=nValid_max_length Then
						Replace Global_Analysis.Change With m.Change
						lUpdated=.T.
					Endif
					If Len(m.UpDown)>=nValid_min_length And Len(m.UpDown)<=nValid_max_length Then
						Replace Global_Analysis.UpDown With m.UpDown
						lUpdated=.T.
					Endif
					If Len(m.Time)>=nValid_min_length And Len(m.Time)<=nValid_max_length Then
						Replace Global_Analysis.Time With m.Time
						lUpdated=.T.
					Endif
					If lUpdated Then
	*!*						?Padr(cTempname+m.LastName,40,' '),Padr(m.Price,15,' '),Padr(m.Change,15,' '),Padr(m.UpDown,15,' '),Padr(m.Time,15,' ')
						nUpdateCount=nUpdateCount+1
						Replace Global_Analysis.Adatetime With Datetime()
					Endif
				Endif			
			Endfor
		Endif
	Endif
	
	cFuturesUrl='http://www.bloomberg.com/markets/stocks/futures.html'
	Local cFutures_Content,cStart_Delimit,cEnd_Delimit,nFutures
	cStart_Delimit=[<span class]
	cEnd_Delimit=[</span>]
	cFutures_Content=DelAspScript(DelAspScript(GetWeb(cFuturesUrl)),"';',''")
	If Len(cFutures_Content)>500 Then
		nFutures=Occurs(cStart_Delimit,cFutures_Content)
		Select Global_Analysis
		Set Order To FUTURE   && UPPER(ALLTRIM(FUTURENAME)) 
		Local cPrice_Content,cOther_Content
		For nTag=1 To nFutures			
			cTempName=Strextract(Strextract(cFutures_Content,cStart_Delimit,cEnd_Delimit,nTag),[>])
			cTempName=Alltrim(Upper(cTempName))
			If Not Empty(cTempName) And Seek(cTempname,'Global_Analysis') Then
				
				Store '' To m.Price,m.Change,m.Open,m.High,m.Low,m.Time
				cPrice_Content=Strextract(cFutures_Content,cStart_Delimit,cStart_Delimit,nTag)
				m.Price=Alltrim(Strextract(Strextract(cPrice_Content,[<td],[</td>]),[>]))
				cOther_Content=Strextract(cFutures_Content,cStart_Delimit,cStart_Delimit,nTag+1)
				nTag=nTag+1

				m.Change=Alltrim(Strextract(cOther_Content,[>],[<],1))
				m.Open=Alltrim(Strextract(cOther_Content,[>],[<],4))
				m.High=Alltrim(Strextract(cOther_Content,[>],[<],6))
				m.Low=Alltrim(Strextract(cOther_Content,[>],[<],8))
				m.Time=Alltrim(Strextract(cOther_Content,[>],[<],10))
				
				If Len(m.Price)>=nValid_min_length And Len(m.Price)<=nValid_max_length Then
					Replace Global_Analysis.Futurepric With m.Price
					lUpdated=.T.
				Endif
				If Len(m.Change)>=nValid_min_length And Len(m.Change)<=nValid_max_length Then
					Replace Global_Analysis.Futurechan With m.Change
					lUpdated=.T.
				Endif
				If Len(m.Open)>=nValid_min_length And Len(m.Open)<=nValid_max_length Then
					Replace Global_Analysis.Futureopen With m.Open
					lUpdated=.T.
				Endif
				If Len(m.High)>=nValid_min_length And Len(m.High)<=nValid_max_length Then
					Replace Global_Analysis.Futurehigh With m.High
					lUpdated=.T.
				Endif
				If Len(m.Low)>=nValid_min_length And Len(m.Low)<=nValid_max_length Then
					Replace Global_Analysis.Futurelow With m.low
					lUpdated=.T.
				Endif
				If Len(m.Time)>=nValid_min_length And Len(m.Time)<=nValid_max_length Then
					Replace Global_Analysis.Futuretime With m.Time
					lUpdated=.T.
				Endif					
			Endif
		EndFor	
	EndIf
	
	If lAutoClose Or nUpdateCount=0 Then
		LcDbfClose('Global_Analysis')
	Endif
	Return nUpdateCount
Endproc
*------
Procedure SendPhoneMsg
	Lparameters cPhoneNumber,cMessageText
	If Not IsValidStr(cPhoneNumber) Then
		Return '0,The phone number is not valid.'
	Endif
	If Not IsValidStr(cMessageText) Then
		Return '0,Message can not empty.'
	Endif
	Local cTempPhone,cTempValue,nTag,nTagCount
	cTempPhone=cPhoneNumber
	cPhoneNumber=''
	nTagCount=Occurs(',',cTempPhone)+1
	For nTag=1 To nTagCount
		cTempValue=ItSubstr(cTempPhone,',',nTag)
		If Len(cTempValue)<11 Then
			Loop
		Else
			If Left(cTempValue,2)<>'86' Then
				cTempValue='86'+cTempValue
			EndIf
		Endif
		If Empty(cPhoneNumber) Then
			cPhoneNumber=cTempValue
		Else
			cPhoneNumber=cPhoneNumber+','+cTempValue
		Endif
	Endfor
	Local cSendUrl,cSendStr,cMessageStr,cSendMessageUrl
	cSendUrl="http://www.supor.cn/gv.php?demo=send&"
	cSendStr="sendto="
	cMessageStr="&message="
	cSendMessageUrl=cSendUrl+cSendStr+cPhoneNumber+cMessageStr+cMessageText
	Return GetWeb(cSendMessageUrl)
EndProc
*------
Procedure GetVfpVersion
	Return Version(5)
Endproc
*------
Procedure IsOSServer
	Return Iif(Os(11)='3',.T.,.F.)
EndProc
*------
Procedure GetOsLanguage
	Return Version(3)
EndProc
*------
Procedure GetOsType
	Local cOsType,lChs
	cOsType=Os(11)
	lChs=GetOsLanguage()=='86'
	Do	Case
		Case	cOsType="1" &&
			If lChs Then
				Return "操作系统类型: 工作站"
			Else
				Return "operating system type: workstation"
			Endif
		Case	cOsType="2"
			If lChs Then
				Return "操作系统类型: 域名控件器"
			Else
				Return "operating system type: domain control server"
			Endif
		Case	cOsType="3"
			If lChs Then
				Return "操作系统类型: 服务器"
			Else
				Return "operating system type: server"
			Endif
		Otherwise
		If lChs Then
			Return "操作系统类型: 不明确"
		Else
			Return "operating system type: unknow"
		Endif
	Endcase
EndProc
*------
Procedure IsOSDoubleByte
    If OS(2)==Upper('DBCS') Then
    	Return .T.
    Else
    	Return .F.
    ENDIF 
Endproc
*------
Procedure GetComputerName
	Local xNull,oWscript,cReturnValue
	xNull=.Null.
	cReturnValue=''
	Try
		oWscript=Createobject('wscript.network')
	Catch To xNull
	Endtry
	If Isnull(xNull) Then
		cReturnValue=oWscript.ComputerName
	Endif
	Release oWscript
	Return cReturnValue
EndProc
*------
Procedure GetUserName
	Local xNull,oWscript,cReturnValue
	xNull=.Null.
	cReturnValue=''
	Try
		oWscript=Createobject('wscript.network')
	Catch To xNull
	Endtry
	If Isnull(xNull) Then
		cReturnValue=oWscript.UserName
	Endif
	Release oWscript
	Return cReturnValue
EndProc
*------
Procedure GetGuestState
	Local cComputerName,oUser,lReturnValue
	cComputerName=GetComputerName()
	If IsValidStr(cComputerName) Then
		oUser=Getobject('WinNT://'+cComputerName+'/Guest')
		If oUser.AccountDisabled Then
			lReturnValue=.F.
		Else
			lReturnValue=.T.
		Endif
		Store .Null. To oUser
		Release oUser
	Else
		lReturnValue=.F.
	EndIf
	Return lReturnValue
EndProc
*------  
Procedure SetGuestState
	lParameter lSetValue
	If Pcount()=0 Then
		Return .F. && execute false
	Else
		If Vartype(lSetValue)<>Upper('L') Then
			Return .F. && execute false
		Else
			lSetValue=lSetValue
		Endif
	Endif
	
	Local lGuestState
	lGuestState=GetGuestState()
	If lGuestState=lSetValue Then
		Return .F. && No need set now.
	Else
		Local cComputerName,oUser
		cComputerName=GetComputerName()
		oUser=Getobject('WinNT://'+cComputerName+'/Guest')
		oUser.AccountDisabled=Not lSetValue && Because the AccountDisabled property, Then .t. need convert to be .f.
		oUser.SetInfo()
		Store .Null. To oUser
		Release oUser
	Endif
	Return .T. && execute  true
Endproc
*------
Procedure GetIPAddress
	Local oWMIService,colItems,cReturnValue,objItem,lcIP 
	cReturnValue=''
	oWMIService=GetObject("winmgmts:\\.\root\CIMV2") 
	colItems = oWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration Where IPEnabled=TRUE",,48) 
	For Each m.objItem in colItems 
	    For Each m.lcIP In m.objItem.IPAddress
	        IF ALLTRIM(m.lcIP)="0.0.0"
	        	If Empty(cReturnValue) Then
	        		cReturnValue='.null.'
	        	Else
	        		cReturnValue=cReturnValue+Chr(13)+Chr(10)+'.null.'
	        	EndIf
	        Else
	        	If Empty(cReturnValue) Then
	        		cReturnValue=m.LcIp
	        	Else
	        		cReturnValue=cReturnValue+Chr(13)+Chr(10)+m.LcIp
	        	EndIf
	        EndIf
	    EndFor
	Endfor
	Store .null. To oWMIService,colItems,lcIP
	Release oWMIService,colItems,lcIP
	Return cReturnValue
EndProc
*------
Procedure GetFirewallState
	Local objFirewall,objPolicy,lReturnValue
	objFirewall = CreateObject("HNetCfg.FwMgr")
	objPolicy = objFirewall.LocalPolicy.CurrentProfile
	lReturnValue=objPolicy.FirewallEnabled
	
	Store .null. To objFirewall,objPolicy
	Release objFirewall,objPolicy
	Return lReturnValue
EndProc
*------
Procedure SetFirewallState
	Lparameters lSetValue
	If Pcount()=0 Then
		Return .F. && Set failed, No paramete
	Else
		If Vartype(lSetValue)<>Upper('L') Then
			Return .F. && Set failed , Not valid value
		Endif
	Endif
	
	Local objFirewall,objPolicy,lEnabledState,lReturnValue
	objFirewall = CreateObject("HNetCfg.FwMgr")
	objPolicy = objFirewall.LocalPolicy.CurrentProfile
	lEnabledState=objPolicy.FirewallEnabled
	If lEnabledState=lSetValue Then
		lReturnValue=.F. && Set failed, No need setting now.
	Else
		objPolicy.FirewallEnabled=lSetValue
		lReturnValue=.T. && Set success
	EndIf	
	Store .null. To objFirewall,objPolicy
	Release objFirewall,objPolicy
	Return lReturnValue
Endproc
*------
Procedure SetWscriptState
	Lparameters lSetValue
	If Pcount()=0 or Vartype(lSetValue)!=Upper('L') Then
		Return .F. && Set failed, No paramete or paramete is not logic value.
	EndIf
	
	Local cRunCommand
	If lSetValue Then
		cRunCommand='run/n regsvr32 /s wshom.ocx'
	Else
		cRunCommand='run/n regsvr32 /u /s wshom.ocx'
	EndIf
	
	Local cOn_Error,lErrored
	cOn_Error=On('Error')
	lErrored=.F.
	On Error lErrored=.T.
	&cRunCommand.
	
	On Error &cOn_Error.
	Return Not lErrored
EndProc
*------
Procedure GetWscriptState
	Local cOn_Error,lErrored
	cOn_Error=On('Error')
	lErrored=.F.
	On Error lErrored=.T.
	
	Local cWshell
	cWshell=CreateObject('Wscript.Shell')
	Release cWshell
	On Error &cOn_Error.
	
	Return Not lErrored
EndProc
*------
Procedure GetAllProcess
	Create Cursor csTasklist (Process_Name C(30),pid C(5),ThreadCount c(5),Full_Path C(100),Description c (50))
	Local oWMI,objs,obj
	oWMI=GetObject("WinMgmts:")
	objs=oWMI.InstancesOf("Win32_Process")
	For Each obj In objs
		If Type('Obj.ExecuTablePath')<>Upper('U') Then
			Insert into csTaskList values (obj.Name,Alltrim(Str(obj.ProcessId)),;
											Alltrim(Str(obj.ThreadCount)),obj.ExecutablePath,obj.Description)
		Else
			Insert into csTaskList values (obj.Name,Alltrim(Str(obj.ProcessId)),;
											Alltrim(Str(obj.ThreadCount)),'',obj.Description)

			*依次是：进程Name，进程ID，进程线程数，进程文件路径 
		EndIf
	Endfor
	Release oWMI,objs,obj
	Goto Top In csTaskList
	Select csTaskList
	Browse
	Return Reccount('csTaskList')
Endproc
*------
Procedure GetAllProcess2 && Except some process which can not found process full path
	Create Cursor csTasklist (Process_Name C(30),pid C(5),ThreadCount c(5),Full_Path C(100),Description c (50))
	LOCAL oWbemLocator, oWMIService, oItems, oItem 
	oWbemLocator = CreateObject("WbemScripting.SWbemLocator") 
	oWMIService = oWbemLocator.ConnectServer(".", "root/cimv2") 
	oItems = oWMIService.ExecQuery("Select * From Win32_Process") 
	For Each oItem in oItems
		If TYPE('oItem.ExecutablePath')<>Upper('U')
			Insert into csTaskList values (oItem.Name,Alltrim(Str(oItem.ProcessId)),;
										Alltrim(Str(oItem.ThreadCount)),oItem.ExecutablePath,oItem.Description)
		    *依次是：进程Name，进程ID，进程线程数，进程文件路径 ，进程 Description
		EndIf
	EndFor 
	Release oWbemLocator, oWMIService, oItems, oItem 
	Goto Top In csTaskList
	Select csTaskList
	Browse
	Return Reccount('csTasklist')
EndProc
*------
Procedure Sleep
	Lparameters nMilliSecond
	nMilliSecond=DefNumber(nMilliSecond)
	Local lReturnValue
	lReturnValue=.F.
	If Not Empty(nMilliSecond) Then
		Declare Sleep in Kernel32 Integer dwMilliSeconds
		lReturnValue=Sleep(nMilliSecond)
		Clear Dlls Sleep
	EndIf
	Return lReturnValue
EndProc
*------		
Procedure ArrayToCursor
	Lparameters cArrayName,cCursorName,lNo_Browse

	If ! IsValidStr(DefCharacters(cArrayName)) Then
		WaitWindow('Please input a valid array name.',Sys(16))
		Return 0
	Endif
	If Not IsValidStr(DefCharacters(cCursorName)) Then
		WaitWindow('Please input a valid cursor name.',Sys(16))
		Return 0
	EndIf
	lNo_Browse = DefLogic(lNo_Browse) && .F. default value that means need to browse after convert array to cursor
	
	cArrayName = DefCharacters(cArrayName)
	Local cOnError,lErrored
	cOnError=On('Error')
	On Error lErrored=.T.
	=Alen(&cArrayName.)
	On Error &cOnError.
	If lErrored Then
		WaitWindow("It is not a valid array name of "+"'"+cArrayName+"'",Sys(16))
		Return 0 && Not a array
	Endif
	Local cCreateCursorScript,nRows,nColumns,nTagColumn,nTagRow,lSameRow
	nRows=Alen(&cArrayName.,1)
	nColumns=Alen(&cArrayName.,2)
	lSameRow=.T.
	If nColumns=0 Then
		nColumns=1 && 一维数组
	Endif
	cCreateCursorScript="Create cursor &cCursorName ("
	If nRows>1 Then && 如果数组中同列数据有不同的数据类型，就直接 Return 0.
		Local cFirstRowDataType,cTempFieldValue,cTempFieldName,cTempFieldType,cTempFieldLength,lFieldAdded
		lFieldAdded=.F.
		For nTagColumn=1 To nColumns
			If nColumns=1 Then && 一列数据
				cTempFieldValue=&cArrayName(1)
			Else
				cTempFieldValue=&cArrayName(1,nTagColumn)
			Endif
			cFirstRowDataType=Vartype(cTempFieldValue) && 记录数组列中的第一个数据类型			
			cTempFieldType=cFirstRowDataType
			cTempFieldName="Col"+Alltrim(Str(nTagColumn))+"_"+cTempFieldType
			Do	Case
				Case	cTempFieldType=Upper('M')
					cTempFieldLength="4"
				Case	cTempFieldType=Upper('C')
					If Len(Alltrim(cTempFieldValue))>0 Then && Empty string fields
						cTempFieldLength=Alltrim(Str(Len(Alltrim(cTempFieldValue))))
					Else
						cTempFieldLength='1'
					EndIf
				Case	cTempFieldType=Upper('N')
					cTempFieldLength="20,4"
				Case	cTempFieldType=Upper('L')
					cTempFieldLength="1"
				Case	cTempFieldType=Upper('D')
					cTempFieldLength="4"
				Case	cTempFieldType=Upper('T')
					cTempFieldLength="4"
				Otherwise
					cTempFieldLength="0" && Ignore this column
			EndCase				

			For nTagRow=2 To nRows
				If nColumns=1 Then && 一维数组
					cTempFieldValue=&cArrayName(nTagRow)
				Else
					cTempFieldValue=&cArrayName(nTagRow,nTagColumn)
				Endif
				cTempFieldType=Vartype(cTempFieldValue)
				If cTempFieldType<>cFirstRowDataType Then && 发现同列数据有不同数据的数据类型
					lSameRow=.F.
					Exit
				Else
					If cTempFieldType=Upper('C') Then
						If Len(Alltrim(cTempFieldValue))>Val(cTempFieldLength)Then
							cTempFieldLength=Alltrim(Str(Len(Alltrim(cTempFieldValue))))
						Endif
					EndIf
				Endif
			Endfor
			If Not lSameRow Then
				If nColumns=1 Then && 一维数组
					WaitWindow("Row in "+Alltrim(Str(nTagRow))+" has found a difference data type, 'Vartype(&cArrayName("+Alltrim(Str(nTagRow))+"))!=Vartype(&cArrayName(1))'",Sys(16),.t.)
				Else
					WaitWindow("Row in "+Alltrim(Str(nTagRow))+" Column in "+Alltrim(Str(nTagColumn))+" has found a difference data type, 'Vartype(&cArrayName("+Alltrim(Str(nTagRow))+","+Alltrim(Str(nTagColumn))+"))!=Vartype(&cArrayName(1,"+Alltrim(Str(nTagColumn))+"))'",Sys(16),.t.)
				Endif
				Exit
			Else
				If Not Inlist(cTempFieldType,Upper('M'),Upper('C'),Upper('N'),Upper('L'),Upper('D'),Upper('T')) Then
					Local nTagDelRow,nTagDel_Rows
					nTagDel_Rows=nRows
					For nTagDelRow=1 To nTagDel_Rows
						If nColumns=1 Then && 一维数组
							&cArrayName(nTagDelRow)='.Null.'
						Else
							&cArrayName(nTagDelRow,nTagColumn)='.Null.'
						Endif
					Endfor
					cTempFieldType=Upper('C')
					cTempFieldLength='6'
				EndIf		
				If lFieldAdded Then && First add field now				
					cCreateCursorScript=cCreateCursorScript+","+cTempFieldName+Space(1)+cTempFieldType+"("+cTempFieldLength+")"
				Else
					cCreateCursorScript=cCreateCursorScript+cTempFieldName+Space(1)+cTempFieldType+"("+cTempFieldLength+")"
					lFieldAdded=.T.
				Endif
			Endif
		Endfor
	Endif
	If Not lSameRow Then
		Return 0
	Endif
	If Not lFieldAdded Then
		WaitWindow("Can not found any one valid data type from array column,please make sure data type in '"+Upper('M,C,N,L,D,T')+"'",Sys(16))
		Return 0
	Else
		cCreateCursorScript=cCreateCursorScript+")"
		&cCreateCursorScript.
	Endif
	
	&& The next step need to append all data into cursor table from array
	Local nReturnValue
	nReturnValue=0
	For nTagRow=1 To nRows
		Select (cCursorName)
		Append Blank 
		For nTagColumn=1 To nColumns
			If nColumns=1 Then && 一维数组
				cTempFieldValue=&cArrayName(nTagRow)
			Else
				cTempFieldValue=&cArrayName(nTagRow,nTagColumn)
			Endif
			cTempFieldName=cCursorName+'.'+Fields(nTagColumn,cCursorName)
			Replace &cTempFieldName. With cTempFieldValue
		Endfor
		nReturnValue=nReturnValue+1
	Endfor
	Select (cCursorName)
	Goto Top
	If !lNo_Browse Then
		Browse nowait
	EndIf
	Return nReturnValue						
EndProc
*------
Procedure GetVfpAll
	Lparameters nTag,cExportFileName
	If Left(Alltrim(Str(GetVfpVersion())),1)<'8' Then && Question, I'm not sure if vfp7 has this funtion alanguage()
		Return 0 && Please make sure run in vfp8 or high version
	EndIf	
	nTag=DefNumber(nTag,0) 
	*!*			1-Commands
	*!*			2-Functions
	*!*			3-Baseclasses
	*!*			4-DBC Events
	If nTag=0 Or Not Inlist(nTag,1,2,3,4) Then
		Return 0
	EndIf		
	cExportFileName=DefCharacters(cExportFileName)
	Local Array aTempArray(1)
	Local nReturnValue
	nReturnValue=Alanguage(aTempArray,nTag)
	Release aTempArray
	Return nReturnValue
EndProc
*------
Procedure GetLastDay
	Lparameters cYearStr,cMonthStr
	If Not IsValidStr(cYearStr) Or Not IsValidStr(cMonthStr) Then
		Return 0
	Else
		cYearStr=Alltrim(cYearStr)
		If Len(cYearStr)<>4 Then
			WaitWindow('Please input a 4 bit as year number.',Sys(16))
			Return 0
		Endif
		cMonthStr=Alltrim(cMonthStr)
		If Not(Len(cMonthStr)>=1 And Len(cMonthStr)<=2) Then
			WaitWindow('Please input a 1 or 2 bit as month number',Sys(16))
			Return 0
		Else
			cMonthStr=Val(cMonthStr)+1
			If cMonthStr>12 Then
				cMonthStr='1'
				cYearStr=Val(cYearStr)+1
				cYearStr=Alltrim(Str(cYearStr))
			Else
				cMonthStr=Alltrim(Str(cMonthStr))
			EndIf
		EndIf
	Endif
	Local cTempDate
	cTempDate='{^'+cYearStr+'-'+cMonthStr+'-1}'
	cTempDate=&cTempDate.-1
	Return Day(cTempDate)
EndProc
*------	
Procedure send_phone() && Unfinished
	Lparameters cUrl
*!*		Lparameters nphonecode,cmessage
	*nphonecode=8615002084237
	Declare Integer InternetOpen In wininet.Dll String, Integer, String, String, Integer
	Declare Integer InternetOpenUrl In wininet.Dll Integer, String, String, Integer, Integer, Integer
	Declare Integer InternetReadFile In wininet.Dll Integer, String @, Integer, Integer @
	Declare short InternetCloseHandle In wininet.Dll Integer
	Local nHandleInternetSession
	SAGENT = "DYJ4.04"
	nHandleInternetSession= INTERNETOPEN(SAGENT,0,"","",0)
	If HINTERNETSESSION = 0
		Wait Window "不能建立 Internet 会话期" Timeout 2
		Return -1
	Endif
	HURLFILE = INTERNETOPENURL(nHandleInternetSession,cUrl,"",0,2147483648,0)
	If HURLFILE = 0
		Wait Window Nowait "您没有连接到internet！"
		Return -2
	Endif
	= INTERNETCLOSEHANDLE(HURLFILE)
	= INTERNETCLOSEHANDLE(HINTERNETSESSION)
Endproc
*------
Procedure ReturnWeb && Unfinished
	Lparameters cUrl
	Declare Integer InternetOpen In wininet.Dll String, Integer, String, String, Integer
	Declare Integer InternetOpenUrl In wininet.Dll Integer, String, String, Integer, Integer, Integer
	Declare Integer InternetReadFile In wininet.Dll Integer, String @, Integer, Integer @
	Declare short InternetCloseHandle In wininet.Dll Integer
	
	Create Cursor HURL (FMEMO M)
	Append Blank
	
	Local cSAgent,nHandleInternetSession,nHandleUrlFile,nTotalRead_Bytes,nTempRead_Bytes,sTempRead_Buffer,nReadSuccess
	cSAgent = "DYJ4.04"
	nHandleInternetSession=InternetOpen(cSAgent,0,"","",0)
	If nHandleInternetSession= 0
		WaitWindow('Con not create a  internet session',Sys(16))
*!*			Wait Window "不能建立 Internet 会话期" Timeout 2
		Return ''
*!*			Return -1
	Endif
	nHandleUrlFile = InternetOpenUrl(nHandleInternetSession,cUrl,"",0,2147483648,0)
	If nHandleUrlFile = 0
		WaitWindow('You have not connect to internet.',Sys(16))
*!*			Wait Window Nowait "您没有连接到internet！"
		Return -2
	Endif
	nTotalRead_Bytes = 0
	Do While .T.
		sTempRead_Buffer = Space(4096) && Maybe this variable of sTempRead_Buffer can be change with remaining bytes.
		&& Question1: How do I know how many bytes is not download complete ,
		&&            That's mean I don't know how long bytes as this handle nHandleUrlFile .
		&& Question3: If I use this function download other files such as *.mp3,*.jpg……
		nTempRead_Bytes= 0
		m.nReadSuccess = InternetReadFile(nHandleUrlFile,@sTempRead_Buffer,Len(sTempRead_Buffer),@nTempRead_Bytes)
		Replace HURL.FMEMO With sTempRead_Buffer Additive
*!*			Replace HURL.FMEMO With Alltrim(sTempRead_Buffer) Additive
		&& Question4: Maybe I can use alltrim to delete extra space but I'm not sure if the source sTempRead_Buffer include space .
		If m.nReadSuccess = 0 .Or. nTempRead_Bytes = 0
			Exit
		Endif
		nTotalRead_Bytes=nTotalRead_Bytes+nTempRead_Bytes
		
		&& Prompt message how many Bytes buffering has been read		
		If nTotalRead_Bytes > 0001048576
			Wait Window Nowait "正在接收 "+Alltrim(Str(nTotalRead_Bytes/0001048576,10,3))+"MB……"
		Else
			Wait Window Nowait "正在接收 "+Alltrim(Str(nTotalRead_Bytes/1024))+"KB……"
		Endif
	Enddo
	&& Format the download bytes in text sdf 
	lswjm=Sys(2023)+'\M'+Sys(3)+'.TXT'
	Strtofile(HURL.FMEMO,lswjm)
	Create Cursor WEBDATA (STRSQL CHANGESET (254))
	Append From (lswjm) Type Sdf
	Erase (lswjm)
	

	= InternetCloseHandle(nHandleUrlFile)
	= InternetCloseHandle(nHandleInternetSession)
	Wait Clear
	Return nTotalRead_Bytes
EndProc
*------
Procedure Number_GetDecimals
	Lparameters nValue
	If DefNumber(nValue)=0 Then
		Return 0
	Else
		nValue=nValue-Int(nValue)
	Endif
	
	Local cSet_Decimals,cTempValue,nTag,nTempDecimals,nValidDecimals	
	cSet_Decimals=Set("Decimals")	

	cTempValue=ItSubstr(Transform(nValue),'.',2)
	cTempValue=String_Transfer(cTempValue)
	nTempDecimals=Lenc(cTempValue)
	nValidDecimals=nTempDecimals
	For nTag=1 To nTempDecimals
		If Substrc(cTempValue,nTag,1)<>'0' Then
			nValidDecimals=nTempDecimals-nTag+1
			Exit
		Endif
	Endfor	
	Set Decimals To nValidDecimals
	
	Local cFormat,nReturnValue
	cFormat='9.'+Replicate('9',nValidDecimals)
	cTempValue=Transform(nValue,cFormat)
	cTempValue=Transform(nValue)
	nReturnValue=Val(cTempValue)
	Set Decimals To cSet_Decimals
	
	Return nReturnValue
EndProc	
*------
Procedure Number_GetInteger
	Lparameters nValue
	If DefNumber(nValue)=0 Then
		Return 0
	Else
		Return Int(nValue)
	Endif
EndProc
*------
Procedure BitHexToInt
	Lparameters cValue
	If Not IsValidStr(cValue) Then
		Return 0
	Else
		cValue=Leftc(Alltrim(Upper(cValue)),1)
	Endif
	If Asc(cValue)<Asc('0') Then
		Return 0
	Else
		If Asc(cValue)>Asc(Upper('Z')) Then
			Return ( Asc('9')-Asc('1')+1 )+( Asc(Upper('Z'))-Asc(Upper('A'))+1 ) && Return 35
		Else
			If Asc(cValue)<=Asc('9') Then
				Return Asc(cValue)-Asc('0')
			Else
				Return ( Asc(cValue)-Asc('1')+1 ) - ( Asc(Upper('A'))-Asc('9') )+1
			EndIf
		Endif
	Endif
EndProc
*------
Procedure BitIntToHex
	Lparameters nValue
	If DefNumber(nValue)=0 Then
		Return '0'
	Else
		nValue=Int(Abs(nValue))
	Endif
	If nValue > ( Asc('9')-Asc('1')+1 )+( Asc(Upper('Z'))-Asc(Upper('A'))+1 ) Then && nValue>35
		Return Upper('Z')
	Else
		If nValue<=9 Then
			Return Alltrim(Str(nValue))
		Else
			Return Chr(( Asc(Upper('A'))-1 )+(nValue-9))
		Endif
	Endif
EndProc
*------
Procedure ToDecimal && Convert any bit data to decimal,?ToDecimal('FF',16) && 255, Question: Negative binary should add - in the top of data
	Lparameters cStringValue,nBit,lStrict
	&& ToDecimal('21',2)=5;ToDecimal('21',2,.T.)=3, When lStrict=.T. and any one bit>=nBit, any one bit will be replace with nBit-1
	Local nSign
	nSign=1
	If Empty(DefCharacters(cStringValue)) Then
		WaitWindow('Please input any type value as string.',Sys(16))
		Return 0
	Else
		cStringValue=Alltrim(Upper(cStringValue))
		If Inlist(Leftc(cStringValue,1),'-','+') Then
			If Leftc(cStringValue,1)='-' Then && negative
				nSign=-1
			Endif
			cStringValue=Substrc(cStringValue,2)
		EndIf
	Endif
	If DefNumber(nBit)=0 Then
		WaitWindow('Please input a bit as number which the source value such as 2,8,16.',Sys(16))
		Return 0
	Else
		nBit=Int(Abs(nBit))
	Endif
	lStrict=DefLogic(lStrict)
	
	Local cInteger,nIntegerLength,nIntegerTag,cDecimal,nDecimalLenght,nDecimalTag,cTempValue,nBitInt,nTempBits,nReturnValue
	
	If '.' $ cStringValue Then && If the stringvalue include decimal
		cInteger=Leftc(cStringValue,Atc('.',cStringValue)-1) && Get the integer string
		nIntegerLength=Lenc(cInteger)
		
		cDecimal=Substrc(cStringValue,Atc('.',cStringValue)+1) && Get the decimal string
		nDecimalLength=Lenc(cDecimal)
	Else && Not include decimal
		cInteger=cStringValue
		nIntegerLength=Lenc(cStringValue)
		
		cDecimal=''
		nDecimalLength=0
	Endif
	
	nReturnValue=0
	For nIntegerTag=1 To nIntegerLength
		nTempBits=nIntegerLength-nIntegerTag
		cTempValue=Substrc(cInteger,nIntegerTag,1)
		nBitInt=BitHexToInt(cTempValue)
		If lStrict Then
			If nBitInt>nBit-1 Then && 如果>进制数当中的最大数
				nBitInt=nBit-1  && 得到进制数当中最大的数，例如 十进制中的 9, 十六进制当中的 15
			Endif
		EndIf
		nReturnValue=nReturnValue+nBitInt*nBit^nTempBits
	Endfor
	For nDecimalTag=1 To nDecimalLength
		cTempBits=nDecimalTag
		cTempValue=Substrc(cDecimal,nDecimalTag,1)
		nBitInt=BitHexToInt(cTempValue)
		If lStrict Then
			If nBitInt>nBit-1 Then
				nBitInt=nBit-1
			Endif
		EndIf
		nReturnValue=nReturnValue+nBitInt*nBit^-cTempBits
	Endfor
	
	nReturnValue=nReturnValue*nSign
	nReturnValue=Int(nReturnValue)+Number_GetDecimals(nReturnValue)
	Return nReturnValue
EndProc
*------
Procedure DecimalTo
	Lparameters nDecimalValue,nBit
	&& nBit can not large than 36 (9 number + 26 alpha=35) (But is' can equal 36, When nBit is 36, The max remain number is 35)
	Local nSign
	nSign=1
	If DefNumber(nDecimalValue)=0 Then
		WaitWindow('Please input the valid decimal value as number.',Sys(16))
		Return '0'
	Else
		If Abs(nDecimalValue)>nDecimalValue Then
			nSign=-1
		EndIf			
		nDecimalValue=Abs(nDecimalValue)
	Endif
	If DefNumber(nBit)=0 Then
		WaitWindow('Please input a valid bit as number which do you want to transfer.',Sys(16))
		Return '0'
	Else
		nBit=Int(Abs(nBit))
	Endif
	Local nInt,cReturnInt,nDecimal,cReturnDecimal,cReturnValue,nTempValue
	nInt=Int(nDecimalValue)
	cReturnInt=''
	nDecimal=nDecimalValue-Int(nDecimalValue)
	cReturnDecimal=''
	
	If nInt>0 Then && 整数部分: 除基数倒序取余数法
		cReturnInt=BitIntToHex(Mod(nInt,nBit)) && 得到余数
		nInt=Int(nInt/nBit) && 得到除掉以后剩余的数字
		Do	While nInt>0 && 如果余数不为0,则继续循环
			cReturnInt=cReturnInt+BitIntToHex(Mod(nInt,nBit))
			nInt=Int(nInt/nBit)
		Enddo
		cReturnInt=String_Transfer(cReturnInt)
	Endif
	
	If nDecimal>0 Then && 小数部分：乘基数顺序取整数法
		cReturnDecimal=BitIntToHex(Int(nDecimal*nBit))
		nDecimal=nDecimal*nBit
		Do	While nDecimal<nBit-1
			cReturnDecimal=cReturnDecimal+BitIntToHex(Int(nDecimal*nBit))
			nDecimal=nDecimal*nBit
		Enddo
		If Not Empty(cReturnDecimal) Then
			cReturnDecimal='.'+cReturnDecimal
		EndIf
	Endif
	
	cReturnValue=cReturnInt+cReturnDecimal
	If nSign=-1 Then
		cReturnValue='-'+cReturnValue
	EndIf
	Return cReturnValue
EndProc
*------
Procedure BinaryTo && Question: Binaryto('1101100',10) && Return 6C ,Error value
	Lparameters cBinaryValue,nBit
	Local nSign
	nSign=1	
	If Not IsValidStr(cBinaryValue) Then
		WaitWindow('Please input a valid binary data as string first.',Sys(16))
		Return '0'
	Else
		cBinaryValue=Alltrim(cBinaryValue)
		If Inlist(Leftc(cBinaryValue,1),'+','-') Then
			If Leftc(cBinaryValue,1)='-' Then
				nSign=-1
			Endif
			cBinaryValue=Substrc(cBinaryValue,2)
		EndIf
	Endif
	If DefNumber(nBit)=0 Then
		WaitWindow('Please input a valid bit as number which you want to transfer.',Sys(16))
		Return '0'
	Else
		nBit=Int(Abs(nBit))
	EndIf
	
	Local cBinaryInt,cReturnInt,cBinaryDecimal,cReturnDecimal,nSubLength
	Store '' To cBinaryInt,cReturnInt,cBinaryDecimal,cReturnDecimal
	If '.' $ cBinaryValue Then
		cBinaryInt=ItSubstr(cBinaryValue,'.',1)
		cBinaryDecimal=ItSubstr(cBinaryValue,'.',2)
	Else
		cBinaryInt=cBinaryValue
	Endif
	nSubLength=Lenc(DecimalTo(nBit-1,2)) && Because binary , So the last parameter in decimalto() is 2 , Maybe can use paramete instead of 2
	
	If Not Empty(cBinaryInt) Then
		cBinaryInt=Padl(cBinaryInt,Lenc(cBinaryInt) + (nSubLength-Mod(Lenc(cBinaryInt),nSubLength)) ,'0')
		Do While Lenc(cBinaryInt)>0
			cReturnInt=cReturnInt+BitIntToHex(ToDecimal(Leftc(cBinaryInt,nSubLength),2)) && Maybe this 2 can instead of a paramete
			cBinaryInt=Substrc(cBinaryInt,nSubLength+1)
		Enddo
	Endif
	
	If Not Empty(cBinaryDecimal) Then
		cBinaryDecimal=Padr(cBinaryDecimal,Lenc(cBinaryDecimal) + (nSubLength-Mod(Lenc(cBinaryDecimal),nSubLength)) , '0')
		Do While Lenc(cBinaryDecimal)>0 
			cReturnDecimal=cReturnDecimal+BitIntToHex(ToDecimal(Leftc(cBinaryDecimal,nSubLength),2))
			cBinaryDecimal=Substrc(cBinaryDecimal,nSubLength+1)
		Enddo
		If Not Empty(cReturnDecimal) Then
			cReturnDecimal='.'+cReturnDecimal
		Endif
	Endif
	
	cReturnValue=cReturnInt+cReturnDecimal
	If nSign=-1 Then
		cReturnValue='-'+cReturnValue
	EndIf
	Return cReturnValue
Endproc
*------
		
Procedure Month_N && Convert month from english to number , Sample: ? Month_n('May') && 5
	Lparameters cMonthExp
	If Not IsValidStr(cMonthExp) Then
		Return 0
	Else
		cMonthExp=uTrim(cMonthExp)
	Endif
	
	Local Array cMonthArray(12,2)
	cMonthArray(1,1)=Upper('January')
	cMonthArray(1,2)=1
	
	cMonthArray(2,1)=Upper('February')
	cMonthArray(2,2)=2
	
	cMonthArray(3,1)=Upper('March')
	cMonthArray(3,2)=3
	
	cMonthArray(4,1)=Upper('April')
	cMonthArray(4,2)=4
	
	cMonthArray(5,1)=Upper('May')
	cMonthArray(5,2)=5
	
	cMonthArray(6,1)=Upper('June')
	cMonthArray(6,2)=6
	
	cMonthArray(7,1)=Upper('July')
	cMonthArray(7,2)=7
	
	cMonthArray(8,1)=Upper('August')
	cMonthArray(8,2)=8
	
	cMonthArray(9,1)=Upper('September')
	cMonthArray(9,2)=9
	
	cMonthArray(10,1)=Upper('October')
	cMonthArray(10,2)=10
	
	cMonthArray(11,1)=Upper('November')
	cMonthArray(11,2)=11
	
	cMonthArray(12,1)=Upper('December')
	cMonthArray(12,2)=12
	
	Local nSearchElement,nReturnValue
	nReturnValue=0
	nSearchElement=Ascan(cMonthArray,cMonthExp)
	If nSearchElement>0 Then
		nReturnValue=cMonthArray(nSearchElement+1)
	Endif
	Release cMonthArray
	
	Return nReturnValue	
Endproc
*------
Procedure Month_C && Convert month from number to English , Sample: ? Month_c(5) && May
	Lparameters m.nMonth
	m.nMonth=Int(DefNumber(m.nMonth))
	If m.nMonth>=12 Then
		If Mod(m.nMonth,12)=0 Then
			m.nMonth=12
		Else
			m.nMonth=Mod(m.nMonth,12)
		Endif
	EndIf

	Local Array cMonthArray(12,2)
	cMonthArray(1,1)=Upper('January')
	cMonthArray(1,2)=1
	
	cMonthArray(2,1)=Upper('February')
	cMonthArray(2,2)=2
	
	cMonthArray(3,1)=Upper('March')
	cMonthArray(3,2)=3
	
	cMonthArray(4,1)=Upper('April')
	cMonthArray(4,2)=4
	
	cMonthArray(5,1)=Upper('May')
	cMonthArray(5,2)=5
	
	cMonthArray(6,1)=Upper('June')
	cMonthArray(6,2)=6
	
	cMonthArray(7,1)=Upper('July')
	cMonthArray(7,2)=7
	
	cMonthArray(8,1)=Upper('August')
	cMonthArray(8,2)=8
	
	cMonthArray(9,1)=Upper('September')
	cMonthArray(9,2)=9
	
	cMonthArray(10,1)=Upper('October')
	cMonthArray(10,2)=10
	
	cMonthArray(11,1)=Upper('November')
	cMonthArray(11,2)=11
	
	cMonthArray(12,1)=Upper('December')
	cMonthArray(12,2)=12
	
	Local nSearchElement,cReturnValue
	cReturnValue=''
	nSearchElement=Ascan(cMonthArray,m.nMonth)
	If nSearchElement>0 Then
		cReturnValue=cMonthArray(nSearchElement-1)
	Endif
	Release cMonthArray
	
	Return cReturnValue	
Endproc
*------
Procedure StrRecombile && ? StrRecombile('Just    for  test           !') Return: "Just for test !"
	Lparameters cString,cSpilt_Tag,cAdd_Tag	
	If Not IsValidStr(cString) Then
		Return ''
	Endif
	cAdd_Tag=DefCharacters(cAdd_Tag,Space(1))

	Local cReturnValue,nTag,nTagCount
	cReturnValue=''
	If IsValidStr(cSpilt_Tag) Then
		nTagCount=Getwordcount(cString,cSpilt_Tag)
	Else
		nTagCount=Getwordcount(cString)
	EndIf
	For nTag=1 To nTagCount
		If Empty(cReturnValue) Then
			If IsValidStr(cSpilt_Tag) Then
				cReturnValue=Getwordnum(cString,nTag,cSpilt_Tag)
			Else
				cReturnValue=Getwordnum(cString,nTag)
			EndIf
		Else
			If IsValidStr(cSpilt_Tag) Then
				cReturnValue=cReturnValue+cAdd_Tag+Getwordnum(cString,nTag,cSpilt_Tag)
			Else
				cReturnValue=cReturnValue+cAdd_Tag+Getwordnum(cString,nTag)
			EndIf
		EndIf
	Endfor
	Return cReturnValue
Endproc
*------
Procedure StrRecombile6 && Can support in vfp6
	Lparameters cString,cSpilt_Tag,cAdd_Tag	
	If Not IsValidStr(cString) Then
		Return ''
	Endif
	cAdd_Tag=DefCharacters(cAdd_Tag,Space(1),.T.)
		
	Local cSet_Library
	cSet_Library=Set("Library")
	If File('FoxTools.Fll') Then
		Set Library To FoxTools.Fll additive
	EndIf
	
	Local cReturnValue,nTag,nTagCount
	cReturnValue=''
	If IsValidStr(cSpilt_Tag,.T.) Then
		nTagCount=Words(cString,cSpilt_Tag)
	Else
		nTagCount=Words(cString)
	EndIf
	For nTag=1 To nTagCount
		If Empty(cReturnValue) Then
			If IsValidStr(cSpilt_Tag,.T.) Then
				cReturnValue=WordNum(cString,nTag,cSpilt_Tag)
			Else
				cReturnValue=WordNum(cString,nTag)
			EndIf
		Else
			If IsValidStr(cSpilt_Tag,.T.) Then
				cReturnValue=cReturnValue+cAdd_Tag+WordNum(cString,nTag,cSpilt_Tag)
			Else
				cReturnValue=cReturnValue+cAdd_Tag+WordNum(cString,nTag)
			EndIf
		EndIf
	EndFor
	Set Library To &cSet_Library.
	Return cReturnValue
Endproc
*------
Procedure GetWeatherUrl
	Lparameters cWorldWeather
	If Not IsValidStr(cWorldWeather) Then
		cWorldWeather='http://worldweather.wmo.int/'
	Endif
	Local nSelect,cHomeContent,cRegionContent,nTag,nRegions,cTmpRowRegion,lFoundData,cTmpRegionName,cTmpRegionUrl
	nSelect=Select()
	lFoundData=.F.
	&& Step 1: Append all region into cursor table csRegion
	Create Cursor csRegion (Region_name c (50),Region_Url c (200))
	cHomeContent=DelAspScript(GetWeb('http://worldweather.wmo.int/'))
	cRegionContent=Strextract(cHomeContent,'Select WMO Region')
	nRegions=Occurs('</tr>',cRegionContent)+1
	For nTag=2 To nRegions
		cTmpRowRegion=Strextract(cRegionContent,'<tr>','</tr>',nTag)
		If 'href="' $ cTmpRowRegion Then			
			cTmpRegionName=Strextract(cTmpRowRegion,'>','<',4)
			If Not Between(Len(cTmpRegionName),1,100) Then
				cTmpRegionName=''
			Endif
			cTmpRegionUrl=Strextract(cTmpRowRegion,'href="','"')
			If Not Between(Len(cTmpRegionUrl),5,60) Then
				cTmpRegionUrl=''
			Else
				If Between(Len(cTmpRegionUrl),1,20) Then
					cTmpRegionUrl=cWorldWeather+cTmpRegionUrl
				EndIf
			Endif
			If Not Empty(cTmpRegionName) Then
				lFoundData=.T.
				Insert Into csRegion values(cTmpRegionName,cTmpRegionUrl)
			Endif
		Else
			If lFoundData Then
				Exit
			Else
				Loop
			EndIf
		Endif
	Endfor
	
	&& Step 2 : Append all country into cursor table csCountry
	Create Cursor csCountry(Region_name c (50),Country_name c(100),Country_Url c(200),Weather_Group c (20))
	Local cRegionContent,cWeatherContent,cClimateContent,cTmpRowData,nRows,cTmpCountryName,cTmpCountryUrl	
	Select csRegion
	Scan
		If Empty(Region_Url) Then
			Loop
		Endif
		cRegionContent=DelAspScript(GetWeb(csRegion.Region_Url))
		cWeatherContent=Strextract(cRegionContent,'In alphabetical order','In alphabetical order',1)
		cClimateContent=Strextract(cRegionContent,'In alphabetical order','',2)
		
		&& The next code using to add all country name and country url which country include weather and climate info.
		nRows=Occurs('href="',cWeatherContent)
		lFoundData=.F.
		For nTag=1 To nRows
			cTmpRowData=Strextract(cWeatherContent,'a href','</a>',nTag)
			If Between(Len(cTmpRowData),10,1000) Then
				cTmpCountryName=Strextract(cTmpRowData,'>','<',2)
				If Not Between(Len(cTmpCountryName),1,200) Then
					cTmpCountryName=''
				Endif
				cTmpCountryUrl=Strextract(cTmpRowData,'="','"')
				If Not Between(Len(cTmpCountryUrl),1,200) Then
					cTmpCountryUrl=''
				Else
					If Between(Len(cTmpCountryUrl),1,20) Then
						cTmpCountryUrl=cWorldWeather+cTmpCountryUrl
					EndIf
				Endif
				If Not Empty(cTmpCountryName) Then
					lFoundData=.T.
					Insert Into csCountry values(csRegion.Region_name,cTmpCountryName,cTmpCountryUrl,'Weather and Climate')
				Endif
			Else
				If lFoundData Then
					Exit
				Else
					Loop
				EndIf
			Endif
		EndFor
		
		&& The next code using to add all country name and country url which country only include climate info.
		nRows=Occurs('href="',cClimateContent)
		lFoundData=.F.
		For nTag=1 To nRows
			cTmpRowData=Strextract(cClimateContent,'a href','</a>',nTag)
			If Between(Len(cTmpRowData),10,1000) Then
				cTmpCountryName=Strextract(cTmpRowData,'>','<',2)
				If Not Between(Len(cTmpCountryName),1,200) Then
					cTmpCountryName=''
				Endif
				cTmpCountryUrl=Strextract(cTmpRowData,'="','"')
				If Not Between(Len(cTmpCountryUrl),1,200) Then
					cTmpCountryUrl=''
				Else
					If Between(Len(cTmpCountryUrl),1,20) Then
						cTmpCountryUrl=cWorldWeather+cTmpCountryUrl
					Endif
				Endif
				If Not Empty(cTmpCountryName) Then
					lFoundData=.T.
					Insert Into csCountry values(csRegion.Region_Name,cTmpCountryName,cTmpCountryUrl,'Only Climate')
				Endif
			Else
				If lFoundData Then
					Exit
				Else
					Loop
				Endif
			Endif
		Endfor
	EndScan
		
	&& Step 3 : Append all city into cursor table csCity
	Create Cursor csCity(Region_name c (50),Country_name c (100),City_name c (100),City_url c(200),Weather_Group c(20))
	Local cCityContent,cTmpCityName,cTmpCityUrl,cFirstCityUrl,nFinishedCountry,nTotalCountry
	cCityContent=''
	Select csCountry
	Count To nTotalCountry For Not Empty(Country_URL)
	nFinishedCountry=0
	Wait Window 'Complete World Weather cities : % to be completed : '+Str(nFinishedCountry/nTotalCountry*100,3,0)+'% ……' At Sysmetric(1)/1024*25,Sysmetric(2)/768*70 nowait
	Scan
		If Empty(Country_Url) Then
			Loop
		EndIf
		cCityContent=Strextract(DelAspScript(GetWeb(Country_Url)),'In alphabetical order','</table')
		
		cFirstCityUrl=Strextract(cCityContent,'a href="','"',1)
		If Between(Len(cFirstCityUrl),1,3) Then
			cCityContent=Strextract(DelAspScript(GetWeb(Country_Url)),'In alphabetical order','')
			cCityContent=Strextract(cCityContent,'</table>','</table>',1)
		EndIf
			
		nRows=Occurs('a href="',cCityContent)
		lFoundData=.F.
		For nTag=1 To nRows
			cTmpRowData=Strextract(cCityContent,'<a href','</a>',nTag)
			If Between(Len(cTmpRowData),10,1000) Then
				cTmpCityName=Strextract(cTmpRowData,'>','')
				If '>' $ cTmpCityName And '<' $ cTmpCityName Then
					cTmpCityName=Strextract(cTmpCityName,'>','<',1)
				EndIf
				If Not Between(Len(cTmpCityName),1,200) Then
					cTmpCityName=''
				Endif
				cTmpCityUrl=Strextract(cTmpRowData,'="','"')
				If '#' $ cTmpCityUrl Or Not Between(Len(cTmpCityUrl),1,200) Then
					cTmpCityUrl=''
				Else
					If Between(Len(cTmpCityUrl),1,20) Then
						cTmpCityUrl=Justpath(csCountry.Country_Url)+'/'+cTmpCityUrl
					Endif
				Endif
				If Not Empty(cTmpCityName) Then
					lFoundData=.T.
					Insert Into csCity values(csCountry.Region_name,csCountry.Country_name,cTmpCityName,cTmpCityUrl,csCountry.Weather_Group)
				Endif
			Else
				If lFoundData Then
					Exit
				Else
					Loop
				Endif
			Endif
		Endfor
		nFinishedCountry=nFinishedCountry+1
		Wait Window 'Complete World Weather cities : % to be completed : '+Str(nFinishedCountry/nTotalCountry*100,3,0)+'% ……' At Sysmetric(1)/1024*25,Sysmetric(2)/768*70 nowait
	Endscan
	Wait clear
	Select (nSelect)
EndProc
*------
Procedure GetValidCode
	Lparameters cBarcode
	If Not IsValidStr(cBarcode) Then
*!*			WaitWindow('Please make sure the barcode not empty.',Sys(16))
		Return 0
	Else
		cBarcode=Alltrim(cBarcode)
	EndIf
	
	&& Delete the space bit in cBarcode
	Local nTag,cTmpBarcode
	cTmpBarcode=''
	For nTag=1 to Lenc(cBarcode)
		If IsDigit(Substrc(cBarcode,nTag,1)) Then
			cTmpBarcode=cTmpBarcode+Substrc(cBarcode,nTag,1)
		EndIf
	EndFor
	cBarcode=cTmpBarcode
	
	Local aTmpArray(Lenc(cBarcode),3)
	For nTag=1 to Lenc(cBarcode)
		aTmpArray(nTag,1)=Val(Substrc(cBarcode,nTag,1))
	EndFor
	
	Local nTmpTag
	nTmpTag=1
	For nTag=Lenc(cBarcode) to 1 step -1
		nTmpTag=nTmpTag+1
		If Mod(nTmpTag,2)=0 Then && 偶数
			aTmpArray(nTag,2)=3
		Else &&奇数
			aTmpArray(nTag,2)=1
		EndIf
	EndFor
	
	For nTag=1 to Lenc(cBarcode)
		aTmpArray(nTag,3)=aTmpArray(nTag,1)*aTmpArray(nTag,2)
	EndFor
	
	Local nTmpTotal,nTmpMod,nReturnValue
	nTmpTotal=0
	For nTag=1 to Len(cBarcode)
		nTmpTotal=nTmpTotal+aTmpArray(nTag,3)
	EndFor
	Release aTmpArray
	
	nTmpMod=Mod(nTmpTotal,10)
	If nTmpMod=0 Then
		nReturnValue=0
	Else
		nReturnValue=10-nTmpMod
	EndIf
	nReturnValue=Int(nReturnValue)
	Return nReturnValue
EndProc	
*------
Procedure FrxToXml
	Lparameters cFrx,cXml
	If (Not IsValidStr(cFrx)) or (Not IsValidStr(cXml)) Then
		WaitWindow('Please make sure the frx resource file name and xml target file name not empty.',Sys(16))
		Return .F.
	EndIf 
	*This code will instantiate the XML listener object, run “myReport” report, 
	*generate it as a XML document and store it in (cXml) in the current directory.
	Local Obj
	Do (_ReportOutPut) with 4,Obj && get the XML Listener reference
	Obj.targetFileName = cXml  && set the document name
	Obj.AllowModalMessages=.F. && Specifiles whether the reportlistener may provide modal message as part of its user interface.
    Obj.includeFormattingInLayoutObjects = .t. && we need the formatting information
    Local cSet_Notify
    cSet_Notify=Set("Notify")
    Set Notify off
    Report Form (cFrx) Object obj && run the report
    Set Safety &cSet_Notify.
    Release Obj
    Return .T.
EndProc
*------
Procedure XmlReportOut && Question
	LPARAMETERS tcInputFile, tcType, tcOutputFile, tlZipped, tcEmail
	*XmlReportOut("out.xml", "RTF",  "output.doc")
	*XmlReportOut("out.xml", "RTF",  "output.zip", .t.) && zipped
	*XmlReportOut("out.xml", "PDF",  "output.pdf")
	*XmlReportOut("out.xml", "HTML", "output.htm")
	*XmlReportOut("out.xml", "PDF", "status.txt", .t., "mhaluza@eqeus.com") && send the zipped PDF as an email attachment to the given address,please be aware only 50 email per hour are allowed

	*!*		Calling the web service
	*!*		The web service is available at http://www.eqeus.net/x.net/xfrx.asmx. It implements one method - ConvertReport, which takes 4 parameters:
	*!*		         SourceXML
	*!*		                   The XML document to be converted, sent as a binary stream
	*!*		         OutputType
	*!*		                   The type of a document to generate. The allowed parameters are: PDF, HTML, RTF
	*!*		         ZippedFlag
	*!*		                   If set to .T., the generated document will be returned in a zip archive.
	*!*		         EmailAddress
	*!*		                   If empty, the generated document will be returned as a binary stream. If not empty, the document will be sent to a given address.
	*!*		Example:
	*!*		This is a simple wrapper VFP procedure (most of it is generated by the TaskPane Web services wizard), which takes care of the binary stream and saves the web service result to a file:

	Local loxfrx AS "XML Web Service"
	*__VFPWSDef__: loxfrx = http://www.eqeus.net/x.net/xfrx.asmx?wsdl , xfrx , xfrxSoap

	Local loException, lcErrorMsg, loWSHandler
	Try
	      loWSHandler = NEWOBJECT("WSHandler",IIF(VERSION(2)=0,"",HOME()+"FFC\")+"_ws3client.vcx")
	      loxfrx = loWSHandler.SetupClient("http://www.eqeus.net/x.net/xfrx.asmx?wsdl", "xfrx", "xfrxSoap")	 

	      LOCAL mystr, mybin
	      mystr = FILETOSTR(tcInputFile)
	      mybin = CREATEBINARY(mystr)
	      mybin = loxfrx.ConvertReport(mybin, tcType, tlZipped, IIF(EMPTY(tcEmail),"",tcEmail))
	      SET SAFETY off
	      = STRTOFILE(mybin, tcOutputFile)
	Catch To loException
	      lcErrorMsg="Error: "+TRANSFORM(loException.Errorno)+" - "+loException.Message
	      DO CASE
	      	CASE VARTYPE(loxfrx)#"O"
	            * Handle SOAP error connecting to web service
	      	CASE !EMPTY(loxfrx.FaultCode)
	            * Handle SOAP error calling method
	            lcErrorMsg=lcErrorMsg+CHR(13)+loxfrx.Detail
	      OTHERWISE
	            * Handle other error
	      ENDCASE
	      * Use for debugging purposes
	      MESSAGEBOX(lcErrorMsg)
	Finally

	EndTry
EndProc
*------
Procedure WordToTxt
	Lparameters cDoc,cTxt
	If IsValidStr(cDoc) Then
		cDoc=Alltrim(cDoc)
		If Empty(JustExt(cDoc)) Then
			cDoc=ForceExt(cDoc,'Doc') && Default extension file name
		EndIf
		If File(cDoc) Then
			cDoc=LocFile(cDoc)
			If Not IsValidStr(cTxt) Then
				If Empty(JustPath(cDoc)) Then
					cTxt=Addbs(Set('Directory'))+ForceExt(JustStem(cDoc),'Txt')
				Else
					cTxt=Addbs(JustPath(cDoc))+ForceExt(JustStem(cDoc),'Txt')
				EndIf
			EndIf
		Else
			WaitWindow('Please make sure the word file of "'+cdoc+'" exist.',Sys(16))
			Return ''
		EndIf
	Else
		WaitWindow('Please make sure the word file name not empty.',Sys(16))
		Return ''
	EndIf
	
	Local oWord,cOn_Error,lError
	cOn_Error=On('Error')
	lError=.F.
	On Error lError=.T.
	
	oWord=CreateObject('Word.Application')
	If lError Then
		On Error &cOn_Error.
		WaitWindow('Please make sure the microsoft word application installed or configuration correct.',Sys(16))
		Return ''
	EndIf
		
	oWord.Documents.Open(cDoc)
	If lError Then
		On Error &cOn_Error. && Restore the error dispose environment
		WaitWindow('Please make sure the document file of "'+cDoc+'" not corruption.',Sys(16))
		Return ''
	EndIf
	
    oWord.ActiveDocument.SaveAs(cTxt,2,.F.,'',.T.,'',.F.,.F.,.F.,.F.,.F.,936,.F.,.F.,0)
    oWord.Quit(.F.)
    Release oWord    
    On Error &cOn_Error.
    
    Return cTxt
EndProc
*------
Procedure GetShortCutTarget
	Lparameters cLnk
	If IsValidStr(cLnk) Then
		cLnk=Alltrim(cLnk)
		If Empty(JustExt(cLnk))Then
			cLnk=ForceExt(cLnk,'LNK') && .Lnk or .Url...
		EndIf 
    Else
    	WaitWindow('Please make sure the the shortcut file name not empty .',Sys(16))
    	Return ''
    EndIf
    
    Local cReturnValue,cError,cWshell,cShortCut
    cReturnValue=''
    cError=''    
    
   	Try
		cWshell=CreateObject('WScript.Shell')
		cShortCut=cWshell.CreateShortCut(cLnk)
		cReturnValue=cShortCut.TargetPath
	Catch
		cError=null
	EndTry
	
	Release cWshell,cShortCut 
	If IsNull(cError) Then
		WaitWindow('Please correct configuration WScript.Shell first.',Sys(16))
	EndIf
    Return cReturnValue
EndProc
*------
Procedure EAN13
	Lparameters Bm
	Private BM
	
	If IsValidStr(Bm) Then
		Bm=Alltrim(Bm)
		If Lenc(Bm)<>12 Then
			Wait window 'EAN-13 code lenght is not valid.' nowait
			Return ''
		EndIf
	Else
		Return ''
	EndIf

	Dimension EAN_code[10,3]
	EAN_code[1,1]='00000011110011'
	EAN_code[1,2]='00110000111111'
	EAN_code[1,3]='11111100001100'
	EAN_code[2,1]='00001111000011'
	EAN_code[2,2]='00111100001111'
	EAN_code[2,3]='11110000111100'
	EAN_code[3,1]='00001100001111'
	EAN_code[3,2]='00001111001111'
	EAN_code[3,3]='11110011110000'
	EAN_code[4,1]='00111111001100'
	EAN_code[4,2]='00001111110011'
	EAN_code[4,3]='11000000001100'
	EAN_code[5,1]='00110000001111'
	EAN_code[5,2]='00001111110011'
	EAN_code[5,3]='11001111110000'
	EAN_code[6,1]='00111100000011'
	EAN_code[6,2]='00111111000011'
	EAN_code[6,3]='11000011111100'
	EAN_code[7,1]='00110011111111'
	EAN_code[7,2]='00000011001111'
	EAN_code[7,3]='11001100000000'
	EAN_code[8,1]='00111111001111'
	EAN_code[8,2]='00001100000011'
	EAN_code[8,3]='11000000110000'
	EAN_code[9,1]='00111100111111'
	EAN_code[9,2]='00000011000011'
	EAN_code[9,3]='11000011000000'
	EAN_code[10,1]='00000011001111'
	EAN_code[10,2]='00001100111111'
	EAN_code[10,3]='11111100110000'
	
	Dimension EAN_left[10]
	EAN_left[1]='111111'
	EAN_left[2]='112122'
	EAN_left[3]='112212'
	EAN_left[4]='112221'
	EAN_left[5]='121122'
	EAN_left[6]='122112'
	EAN_left[7]='122211'
	EAN_left[8]='121212'
	EAN_left[9]='121221'
	EAN_left[10]='122121'
	
	Dimension EAN_mode[8]
	Store '' To EAN_mode
	EAN_mode[1]='000000000000000000'
	EAN_mode[2]='110011'
	For i=0 To 9
		If Val(Substr(BM,1,1))=i
			For ii=1 To 6
				BMZ=Val(Substr(BM,ii+1,1))
				MODE=Val(Substr(EAN_left[i+1],ii,1))
				EAN_mode[3]=EAN_mode[3]+EAN_code[BMZ+1,MODE]
			Endf
		Endi
	Endf
	EAN_mode[4]='0011001100'
	For i=1 To 5
		BMZ=Val(Substr(BM,i+7,1))
		EAN_mode[5]=EAN_mode[5]+EAN_code[BMZ+1,3]
	Endf

	Local JY_A,JY_B
	JY_A=0
	JY_B=0
	For i=1 To 12
		If i%2=0
			JY_A=JY_A+Val(Substr(BM,i,1))
		Else
			JY_B=JY_B+Val(Substr(BM,i,1))
		Endif
	Endf
	
	Local JYM
	JYM=10-(JY_A*3+JY_B)%10
	If JYM=10
		JYM=1
	Endi
	EAN_mode[6]=EAN_code[JYM+1,3]
	EAN_mode[7]='110011'
	EAN_mode[8]='000000000000000000'
	EAN_code=EAN_mode[1]+EAN_mode[2]+EAN_mode[3]++EAN_mode[4]+EAN_mode[5]+EAN_mode[6]+EAN_mode[7]+EAN_mode[8]
	
	Dimension BMP[4]
	BMP[4]=90
	BMP[3]=224
	BMP[2]=Int((BMP[3]*3+3)/4)*4*BMP[4]+54
	BMP[1]=BMP[2]-54
	Dimension BMP_T[4]
	For i=1 To 4
		k1='0x'+Subs(Righ(Transform(BMP[i],"@0"),8),7,2)
		k2='0x'+Subs(Righ(Transform(BMP[i],"@0"),8),5,2)
		k3='0x'+Subs(Righ(Transform(BMP[i],"@0"),8),3,2)
		k4='0x'+Subs(Righ(Transform(BMP[i],"@0"),8),1,2)
		BMP_T[i]=Chr(&k1)+Chr(&k2)+Chr(&k3)+Chr(&k4)
	Endf
	st1='BM'+BMP_T[2]+Chr(0)+Chr(0)+Chr(0)+Chr(0)+Chr(54)+Chr(0)+Chr(0)+Chr(0);
		+Chr(40)+Chr(0)+Chr(0)+Chr(0)+BMP_T[3]+BMP_T[4]+Chr(1)+Chr(0)+Chr(24)+Chr(0)+Chr(0)+Chr(0)+Chr(0)+Chr(0)+BMP_T[1]+Chrt(Spac(16),' ',Chr(0))
	st2=Chrt(Spac(224*10*3),' ',Chr(255))
	st3=''
	For i=11 To 70
		For k1=1 To 224
			If Substr(EAN_code,k1,1)=='1'
				st3=st3+Chr(0)+Chr(0)+Chr(0)
			Else
				st3=st3+Chr(255)+Chr(255)+Chr(255)
			Endi
		Endf
	Endf
	Pb=Chr(0)+Chr(0)+Chr(0)
	Pw=Chr(255)+Chr(255)+Chr(255)
	st4=Chrt(Spac(18*3),' ',Chr(255))+Pb+Pb+Pw+Pw+Pb+Pb+Chrt(Spac(84*3),' ',Chr(255))+Pw+Pw+Pb+Pb+Pw+Pw+Pb+Pb+Pw+Pw+Chrt(Spac(84*3),' ',Chr(255))+Pb+Pb+Pw+Pw+Pb+Pb+Chrt(Spac(16*3),' ',Chr(255))
	st4=st4+st4
	Dimension T_D[11]
	T_D[1]='11111000111111111100000111111110111100111111101111101111111011111011111110111110111111101111101111'+;
		'11101111101111111011111011111110111110111111101111101111111011110011111111000001111111111000111111'
	T_D[2]='11111110111111111111001111111111100011111111100000111111111011101111111111111011111111111110111111'+;
		'11111110111111111111101111111111111011111111111110111111111111101111111111111011111111111110111111'
	T_D[3]='11111000111111111000000111111110111110111111101111101111111111111011111111111110111111111111011111'+;
		'11111110011111111111001111111111100111111111110011111111111001111111111110000000111111000000001111'
	T_D[4]='11111000111111111100000111111110011100111111101111101111111111110111111111110011111111111100011111'+;
		'11111111101111111111111011111111111110111111101111101111111011110011111111000001111111111000111111'
	T_D[5]='11111111011111111111100111111111111001111111111100011111111110110111111111011101111111110111011111'+;
		'11101111011111110111110111111100000000011111000000000111111111110111111111111101111111111111011111'
	T_D[6]='11110000001111111100000011111111011111111111110111111111111000001111111110000001111111101111101111'+;
		'11111111101111111111111011111111111110111111101111101111111011110011111111000001111111111000111111'
	T_D[7]='11111000111111111100000111111110011110111111101111111111111011001111111110000001111111100111001111'+;
		'11101111101111111011111011111110111110111111101111101111111001111011111111000001111111111000111111'
	T_D[8]='11000000001111110000000011111111111100111111111111011111111111101111111111111011111111111101111111'+;
		'11111101111111111110011111111111101111111111111011111111111110111111111111101111111111110011111111'
	T_D[9]='11111000111111111100000111111110011100111111101111101111111011111011111110011100111111110000011111'+;
		'11110000011111111011111011111110111110111111101111101111111011111011111110000001111111111000111111'
	T_D[10]='11111000111111111100000111111110111100111111101111101111111011111011111110111110111111101111101111'+;
		'11101111001111111100000011111111100110111111111111101111111011110111111110000001111111111001111111'
	T_D[11]='11111111111111111111111111111111111111111111111111001111111111000011111111000001111111100111111111'+;
		'11100111111111111100000111111111110000111111111111001111111111111111111111111111111111111111111111'
	Dimension td[14]
	Store '' To td
	For i=1 To 14
		For k1=1 To 13
			zh=Val(Substr(BM+Alltrim(Str(JYM)),k1,1))+1
			td[i]=td[i]+Substr(T_D[zh],14*i-13,14)
		Endf
		td[i]=td[i]+Substr(T_D[11],14*i-13,14)
	Endf
	For i=1 To 7
		td[i]='11'+Subs(td[i],1,14)+'11'+'001100'+Subs(td[i],15,84)+'1100110011'+Subs(td[i],99,84)+'001100'+Subs(td[i],183,14)+'11'
	Endf
	For i=8 To 14
		td[i]='11'+Subs(td[i],1,14)+'11'+'111111'+Subs(td[i],15,84)+'1111111111'+Subs(td[i],99,84)+'111111'+Subs(td[i],183,14)+'11'
	Endf
	For i=1 To 14
		td[i]=Strtran(td[i],'1',Chr(255)+Chr(255)+Chr(255))
		td[i]=Strtran(td[i],'0',Chr(0)+Chr(0)+Chr(0))
	Endf
	st5=Chrt(Spac(224*4*3),' ',Chr(255))
	h=Fcreate(BM+Alltrim(Str(JYM))+'.bmp')
	=Fwrite(h,st1)
	=Fwrite(h,st5)
	For i=14 To 1 Step -1
		=Fwrite(h,td[i])
	Endf
	=Fwrite(h,st4)
	=Fwrite(h,st3)
	=Fwrite(h,st2)
	Fclose(h)
	
	Return BM+Alltrim(Str(JYM))+'.bmp'
EndProc
*------
Procedure GetFsize
	Lparameters cFileName
	cFileName=DefCharacters(cFileName)
	If NOT File(cFileName) Then
		Return 0
	Else
		Local cTempArray(5)
		ADir(cTempArray,cFileName)
		Local nReturnValue
		nReturnValue=DefNumber(cTempArray(2))
		Release cTempArray
	EndIf
	Return nReturnValue
EndProc
*------
Procedure IsAliasOpened
	Lparameters cAlias
	cAlias=DefCharacters(cAlias)
	Local lReturnValue
	lReturnValue=.F.
	If IsValidStr(cAlias) Then
		If Select(cAlias)>0 Then
			lReturnValue=.T.
		Else
			lReturnValue=.F.
		EndIf
	Else
		If Empty(Alias()) Then
			lReturnValue=.F.
		Else
			lReturnValue=.T.
		EndIf
	EndIf
	Return lReturnValue
EndProc
*------
Procedure GetTableExp && This function as the same as the cAccField(), But it's only can add string field, Should be add any type field if have time to upgrade this procedure
	Lparameters cExpression,cAlias,cDoc_ID,cOrder,cFilter,lDistinct,cAddTag

	Local cReturnValue,lCloseAlias,nSelect,cOrderExp
	cReturnValue=''	
	lCloseAlias=.F.
	nSelect=Select()
	cOrderExp=''
			
	cExpression=DefCharacters(cExpression)
	If IsAliasOpened(cAlias) Then
		lCloseAlias=.F.
	Else
		lCloseAlias=.T.
	EndIf
	cAlias=GetAlias(cAlias)
	cDoc_ID=DefCharacters(cDoc_ID)
	cOrder=DefCharacters(cOrder)
	cFilter=DefCharacters(cFilter)
	lDistinct=DefLogic(lDistinct)
	cAddTag=DefCharacters(cAddTag,Chr(13)+Chr(10))
		
	If !IsValidStr(cExpression) or !IsValidStr(cAlias) Then
		Return cReturnValue
	EndIf
	
	If IsValidStr(cOrder) Then
		Set Order To &cOrder. in &cAlias.
		cOrderExp=IndexToExp(cOrder,cAlias)
	EndIf
	
	If !IsValidStr(cFilter) Then
		cFilter='.T.'
	EndIf
	
	Goto top in (cAlias)
	Select (cAlias)
	If !Empty(Order()) Then
		If !Seek(cDoc_ID) Then
			If lCloseAlias Then
				LcDbfClose(cAlias)
			EndIf		
			Select (nSelect)
			Return cReturnValue
		EndIf
	EndIf
	
	Scan rest 
		If IsValidStr(cDoc_ID) and IsValidStr(cOrderExp) Then
			If !&cOrderExp.=cDoc_ID Then
				Exit
			EndIf
		EndIf
		If !Evaluate(cFilter) Then
			Loop
		EndIf
		If IsValidStr(cReturnValue,.T.) Then
			If lDistinct and IsInclude(cReturnValue,&cExpression.,cAddTag,.T.) Then
				Loop
			Else
				cReturnValue=cReturnValue+cAddTag+&cExpression.
			EndIf
		Else
			cReturnValue=&cExpression.
		EndIf
	EndScan
			
	If lCloseAlias Then
		LcDbfClose(cAlias)
		Select (nSelect)
	EndIf
	
	Return cReturnValue
EndProc		
*------
Procedure ItStrExtract && This function as the same as the system function called StrExtract, But it's can run in vfp6
	Lparameters cSearchExpression,cBeginDelimit,cEndDelimit,nOccurrence,lIgnoreMatchCase,lCompatibleVFP9
	
	&& Step1: deal with the parameters
	cSearchExpression=DefCharacters(cSearchExpression,,.T.)
	cBeginDelimit=DefCharacters(cBeginDelimit,,.T.)
	cEndDelimit=DefCharacters(cEndDelimit,,.T.)
	nOccurrence=DefNumber(nOccurrence,1)
	lIgnoreMatchCase=DefLogic(lIgnoreMatchCase)
	lCompatibleVFP9=DefLogic(lCompatibleVFP9)
	
	If !IsValidStr(cSearchExpression) Then
		Return ''
	EndIf
	
	If !Lenc(cBeginDelimit)>0 and !Lenc(cEndDelimit)>0 Then
		Return cSearchExpression
	Else
		If lCompatibleVFP9 Then
			If !Lenc(cBeginDelimit)>0 and Lenc(cEndDelimit)>0 Then
				nOccurrence=1
			EndIf
		EndIf
	EndIf

	If nOccurrence=0 Then
		Return ''
	EndIf
		
	&& Step2: define some variable
	Local cReturnValue,nTempStartPosition,nStartPosition,nEndPosition,cTempSearchExpression
	cReturnValue=''
	nTempStartPosition=0
	nStartPosition=0
	nEndPosition=0 
	cTempSearchExpression=''
	
	&& Step3: count the cBeginDelimit and cEndDelimit postion to nStartPosition and nEndPosition
	nTempStartPosition=ItAtc(cBeginDelimit,cSearchExpression,nOccurrence,lIgnoreMatchCase)
	If nTempStartPosition>0 Then
		nStartPosition=nTempStartPosition+( Lenc(cBeginDelimit)-1 )
	EndIf
	********************************************************************************************
	If Lenc(cBeginDelimit)>0 and Lenc(cEndDelimit)>0 Then
		cTempSearchExpression=Substrc(cSearchExpression,nStartPosition+1)
		nEndPosition=nStartPosition + ItAtc(cEndDelimit,cTempSearchExpression,,lIgnoreMatchCase)
	Else && Only one delimit is not empty.
		nEndPosition=ItAtc(cEndDelimit,cSearchExpression,nOccurrence,lIgnoreMatchCase)
	EndIf
	
	&& Step4: substr from cSearchExpression base on nStartPosition and nEndPosition
	If Lenc(cBeginDelimit)>0 and Lenc(cEndDelimit)>0 Then
		If !nStartPosition=0 and !nEndPosition=0 Then
			If nStartPosition<nEndPosition Then
				cReturnValue=Substrc(cSearchExpression,nStartPosition+1,nEndPosition-nStartPosition-1)
			EndIf
		EndIf
	Else
		If Lenc(cBeginDelimit)>0 Then && Lenc(cEndDelimit)=0
			If nStartPosition>0 Then && Else cStartDelimit not include in cSearchExpression
				cReturnValue=Substrc(cSearchExpression,nStartPosition+1)
			EndIf
		Else && Lenc(cBeginDelimit)=0
			If nEndPosition>0 Then && Else cEndDelimit not include in cSearchExpression
				cReturnValue=Leftc(cSearchExpression,nEndPosition-1)
			EndIf
		EndIf
	EndIf
	
	&& Step5: return value
	Return cReturnValue
EndProc
*------
Procedure ItAtc
	Lparameters cSearchExpression,cExpressionSearched,nOccurrence,lIgnoreMatchCase

	&&   Atc('dd','dddd',2) && Return 2
	&& ItAct('dd','dddd',2) && Return 3
	
	cSearchExpression=DefCharacters(cSearchExpression,,.T.)
	cExpressionSearched=DefCharacters(cExpressionSearched,,.T.)
	nOccurrence=DefNumber(nOccurrence,1)
	lIgnoreMatchCase=DefLogic(lIgnoreMatchCase)
	
	Local nReturnValue
	nReturnValue=0	
	
	If Lenc(cSearchExpression)=0 Then
		Return nReturnValue
	EndIf
	
	If Lenc(cExpressionSearched)=0 Then
		Return nReturnValue
	EndIf
	
	If nOccurrence=0 Then
		Return nReturnValue
	EndIf
	
	Local nOccurs
	If lIgnoreMatchCase Then 
		nOccurs=Occurs(Upper(cSearchExpression),Upper(cExpressionSearched))
	Else
		nOccurs=Occurs(cSearchExpression,cExpressionSearched)
	EndIf
	If nOccurs<nOccurrence Then
		Return nReturnValue
	EndIf
	
	If Lenc(cSearchExpression)=1 Then
		If lIgnoreMatchCase Then
			nReturnValue=Atcc(cSearchExpression,cExpressionSearched,nOccurrence)
		Else
			nReturnValue=At_c(cSearchExpression,cExpressionSearched,nOccurrence)
		EndIf
	Else && Lenc(cSearchExpression)>1
		Local nTag,nSearchExpressionLength,nTempPosition,cTempExpressionSearched,cNewExpressionSearched
		nSearchExpressionLength=Lenc(cSearchExpression)
		nTempPosition=0
		cTempExpressionSearched=''
		cNewExpressionSearched=cExpressionSearched
		
		For nTag=1 to nOccurrence
			If lIgnoreMatchCase Then
				nTempPosition=Atcc(cSearchExpression,cNewExpressionSearched)
			Else
				nTempPosition=At_c(cSearchExpression,cNewExpressionSearched)
			EndIf
			cTempExpressionSearched=cTempExpressionSearched+Leftc(cNewExpressionSearched,( nTempPosition + nSearchExpressionLength - 1 ))
			cNewExpressionSearched=Substrc(cNewExpressionSearched,( nTempPosition+nSearchExpressionLength )) && Question :This line coding always error found.
		EndFor
		nReturnValue=( Lenc(cTempExpressionSearched)-nSearchExpressionLength)+1
	EndIf

	Return nReturnValue
			
EndProc
*------
Procedure SwitchWindow
	Local oWScript
	oWScript=CreateObject('WScript.Shell')
	oWScript.SendKeys("%{TAB}")
	Release oWScript 
	Return .T.
EndProc
*------
Procedure ScanPrg
	Lparameters cExpressionSearched,cSearchExpression,cStartDelimit,cEndDelimit
	cExpressionSearched=DefCharacters(cExpressionSearched,,.T.)
	cSearchExpression=DefCharacters(cSearchExpression,,.T.)
	cStartDelimit=DefCharacters(cStartDelimit,'Procedure',.T.)
	cEndDelimit=DefCharacters(cEndDelimit,'EndProc',.T.)
	
	Local nReturnValue
	nReturnValue=0
	If Lenc(cExpressionSearched)=0 Then
		Return nReturnValue
	EndIf
	
	Local nStartDelimit_Occurs
	nStartDelimit_Occurs=Occurs(Upper(cStartDelimit),Upper(cExpressionSearched))
	If nStartDelimit_Occurs=0 Then
		Return nReturnValue
	EndIf
	
	Local nSelect
	nSelect=Select()	
	Select 0
	Create Cursor csProcedure (name c (30),memo m (4))
	
	Local nTag,nSubTag,nStart_Position,nEnd_Position,lValidProcedure,nTmpAsc
	Store 0 to nTag,nSubTag,nStart_Position,nEnd_Position,nTmpAsc
	
	Local cTmpCharacter,cTmpProcedureName,cTmpProcedureValue
	Store '' to cTmpCharacter,cTmpProcedureName,cTmpProcedureValue
	
	For nTag=1 to nStartDelimit_Occurs
		nStart_Position=Atcc(cStartDelimit,cExpressionSearched,nTag)
		If nStart_Position<=nEnd_Position Then
			Loop
		EndIf
		lValidProcedure=.T.
		For nSubTag=nStart_Position-1 to nEnd_Position step -1
			cTmpCharacter=Substrc(cExpressionSearched,nSubTag,1)
			nTmpAsc=Asc(cTmpCharacter)
			If InList(nTmpAsc,13,10)
				Exit
			Else
				If InList(nTmpAsc,32,9) Then && Space,Tab
					Loop
				Else && Other character, Not include Enter,Line,Space,Tab
					lValidProcedure=.F.
					Exit
				EndIf
			EndIf
		EndFor
				
		If lValidProcedure Then
			cTmpProcedureValue=StrExtract(cExpressionSearched,cStartDelimit,cEndDelimit,nTag,1)
			cTmpProcedureName=Alltrim(StrExtract(cTmpProcedureValue,'',Chr(13),1))
			If Empty(Alltrim(cTmpProcedureValue)) or Empty(Alltrim(cTmpProcedureName)) Then
				Loop
			EndIf
				
			cTmpProcedureName=GetWordNum(cTmpProcedureName,1)
			cTmpProcedureName=GetWordNum(cTmpProcedureName,1,'(')
			cTmpProcedureValue=cStartDelimit+cTmpProcedureValue+cEndDelimit
			nEnd_Position=nStart_Position+Lenc(cTmpProcedureValue)
			If Lenc(cSearchExpression)>0 Then
				If !(Upper(cSearchExpression) $ Upper(cTmpProcedureName)) Then
					Loop
				EndIf
			EndIf
			Insert into csProcedure  values (cTmpProcedureName,cTmpProcedureValue)
			nReturnValue=nReturnValue+1
		EndIf
		Wait window 'Scan completed '+Alltrim(Str(nTag/nStartDelimit_Occurs*100,3,0))+'% ……' At Sysmetric(1)/1024*25,Sysmetric(2)/768*70 nowait		
	EndFor
	Wait window 'Scan completed 100% ……' At Sysmetric(1)/1024*25,Sysmetric(2)/768*70 timeout 0.1
	Wait clear
	
	If nReturnValue=0 Then
		LcDbfClose('csProcedure')
	EndIf
	Select (nSelect)
	Return	nReturnValue
EndProc		
*------
Procedure UrlToMht && Question
	Lparameters cUrl as String , cMhtFileName as String
	If !IsValidStr(cUrl) Then
		Return .F.
	EndIf
	
	If !IsValidStr(cMhtFileName) Then
		Return .F.
	EndIf
	
	Local oCdo
	oCdo=CreateObject('Cdo.Message')
	oCdo.CreateMhtmlBody(cUrl,0,'','')
	oCdo.GetStream.SaveToFile(cMhtFileName)
	Release oCdo
	
	If File(cMhtFileName) Then
		Return .T.
	Else
		Return .F.
	EndIf
EndProc
*------
Procedure GetRtfText
	Lparameters cFileName as String 
		
	Local cReturnValue
	cReturnValue=''
	If !IsValidStr(cFileName) or !File(cFileName) Then
		cFileName=GetFile('RTF')
		If !File(cFileName) Then
			Return cReturnValue
		EndIf
	EndIf
	
	Local oRtf
	oRtf=CreateObject('Richtext.RichTextCtrl.1')
	oRtf.TextRTF=FileToStr(cFileName)
	cReturnValue=oRtf.Text
	Release oRtf
	
	Return cReturnValue
EndProc
*------
Procedure SpeakWords
	Lparameters cWords,cLanguage,nSpeak_volume,nSpeak_Rate
	cWords=DefCharacters(cWords)
	cLanguage=DefCharacters(cLanguage,Upper('CN'))
	cLanguage=Alltrim(Upper(cLanguage))
	If !InList(cLanguage,Upper('CN'),Upper('EN')) Then
		cLanguage=Upper('CN')
	EndIf
	
	If !IsValidStr(cWords) Then
		Return .F.
	Else
		If cLanguage=Upper('CN') Then
			cWords="<LANG LANGID='804'>"+cWords+"</LANG>"
		Else && En
			cWords="<LANG LANGID='409'>"+cWords+"</LANG>"
		EndIf
	EndIf
	
	nSpeak_volume=DefNumber(nSpeak_volume,100)	
	If nSpeak_Volume<0 or nSpeak_Volume>100 Then
		nSpeak_volume=100 && Default value
	EndIf
	
	nSpeak_Rate=DefNumber(nSpeak_Rate)
	
	Local oSpeech
	oSpeech=CreateObject('SAPI.SpVoice')&&连接到系统的语音功能
	oSpeech.Volume=nSpeak_volume
	oSpeech.Rate=nSpeak_Rate
	oSpeech.Speak(cWords)&&让系统读出字符串里的内容
	Release oSpeech
	
	Return .T.
EndProc
*------
Procedure Hwnd2JPG(wHwnd as INTEGER,imagefile as string)
	**wHwnd 窗口句柄
	***imagefile 要保存到本地的文件名，我这里只定义了JPG格式，大家可以扩展
	CF_BITMAP=2
	SRCCOPY=13369376
	Declare SHORT GetWindowRect IN user32 INTEGER hwnd, STRING @ lpRect
	Declare INTEGER GetWindowDC IN user32 INTEGER hwnd
	Declare INTEGER CreateCompatibleDC IN gdi32 INTEGER hdc
	Declare INTEGER DeleteDC IN gdi32 INTEGER hdc
	Declare INTEGER ReleaseDC IN user32 INTEGER hwnd, INTEGER hdc
	Declare INTEGER CreateCompatibleBitmap IN gdi32;
		INTEGER hdc,;
		INTEGER nWidth,;
		INTEGER nHeight
	Declare INTEGER SelectObject IN gdi32 INTEGER hdc, INTEGER hObject
	Declare INTEGER DeleteObject IN gdi32 INTEGER hObject
	Declare INTEGER BitBlt IN gdi32;
		INTEGER hDestDC,;
		INTEGER x, INTEGER y,;
		INTEGER nWidth, INTEGER nHeight,;
		INTEGER hSrcDC,;
		INTEGER xSrc, INTEGER ySrc,;
		INTEGER dwRop
	Declare INTEGER OpenClipboard IN user32 INTEGER hwnd
	Declare INTEGER CloseClipboard IN user32
	Declare INTEGER EmptyClipboard IN user32
	Declare INTEGER SetClipboardData IN user32;
		INTEGER wFormat,;
		INTEGER hMem
	DECLARE INTEGER GetClipboardData IN user32;
		INTEGER uFormat
	DECLARE INTEGER GdipCreateBitmapFromHBITMAP IN gdiplus;
		INTEGER   hbm,;
		INTEGER   hpal,;
		INTEGER @ hbitmap
	DECLARE INTEGER GdipSaveImageToFile IN gdiplus;
		INTEGER img,;
		STRING filename,;
		STRING clsidEncoder,;
		INTEGER encoderParams
	DECLARE Long GdipDisposeImage IN Gdiplus.dll Long nativeImage
	*-----------------------------------------------------------------*
	*-VFP应用程式算法群:12787940 行者孙:310727570-*
	*-----------------------------------------------------------------*
	lpRect = REPLI (Chr(0), 16)
	GetWindowRect (wHwnd, @lpRect)
	lnWidth=ctob(SUBS(lpRect,9,4),'4rs')-ctob(SUBS(lpRect,1,4),'4rs')&&窗口宽度
	lnHeight=ctob(SUBS(lpRect,13,4),'4rs')-ctob(SUBS(lpRect,5,4),'4rs')&&窗口高度
	hdc = GetWindowDC (wHwnd)
	hVdc = CreateCompatibleDC (hdc)
	hBitmap = CreateCompatibleBitmap(hdc, lnWidth, lnHeight)
	SelectObject (hVdc, hBitmap)
	BitBlt (hVdc, 0,0, lnWidth,lnHeight, hdc, 0,0, SRCCOPY)
	OpenClipboard (wHwnd)
	EmptyClipboard()
	SetClipboardData (CF_BITMAP, hBitmap)&&我在这里顺便把图像放到了剪切板，如果不需要可删除。
	hClipBmp=GetClipboardData(CF_BITMAP)
	hbitmap=0
	GdipCreateBitmapFromHBITMAP(hClipBmp,2,@hbitmap)
	lcOutputFile=STRCONV(imagefile+CHR(0),5)
	jpg=0h01F47C55041AD3119A730000F81EF32E&&JPG格式，其它格式可以到我前面的文章里找
	GdipSaveImageToFile(hbitmap,lcOutputFile,jpg,0)
	GdipDisposeImage(hbitmap)
	CloseClipboard()
	DeleteObject (hBitmap)
	DeleteDC (hVdc)
	ReleaseDC (wHwnd, hdc)
EndProc
*------
Procedure CharToBin 
	Lparameters cWords as String
	If !IsValidStr(cWords,.T.) Then
		Return 0
	EndIf
	Local nTag, nReturnValue
	nReturnValue = 0
	For nTag = 1 to Len(cWords )
		nReturnValue = nReturnValue + (Asc(Substr(cWords , nTag, 1)) * (2 ^ (8 * (nTag -1))))
	EndFor
	Return nReturnValue
EndProc
*------
Procedure BinToChar
	Lparameters nInteger, nCharacter_Width
	nInteger=DefNumber(nInteger)
	nCharacter_Width=DefNumber(nCharacter_Width)
	
	Local cReturnValue
	cReturnValue = ''

	If nCharacter_Width<=0 Then
		Return cReturnValue
	EndIf
	
*!*	  	Private tcOutput
	Local tcOutPut
  	tcOutput = ""
  	Do while(m.nInteger>0)
  		tcOutput = m.tcOutput + chr( m.nInteger%256)
  		nInteger = int(m.nInteger/256)
  	Enddo
 	cReturnValue = padr(m.tcOutput,m.nCharacter_Width,chr(0))
 	Return cReturnValue
EndProc
*------
Procedure VirusTest
	Lparameters cTestString
	cTestString=DefCharacters(cTestString,'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*',.T.)
	Local cVirusFile
	cVirusFile=Addbs(GetEnv("TEMP"))+AliasName()
	StrToFile(cTestString,cVirusFile)
	Return cVirusFile
EndProc
*------
Procedure Regedit
	PARAMETERS    nReg_code,;&&操作代码，0-创建子键，1-写注册表，2-读注册表，3-删除注册表项
	cReg_MainKey,;              &&注册表主键
	cReg_skey,;                        &&子键
	cReg_skey_New,;                &&需创建的子键
	cReg_skeyname,;                &&注册表项
	cReg_keyvalue,;                &&注册表项的值
	nReg_ValueType                  &&注册表项的值的类型,{1:数据串,	2:Unicode串,		3:二进制,	4:32位数值}
	
	cReg_MainKey=Upper(DefCharacters(cReg_MainKey))
	
	*操作注册表 
	*语法：
	*创建子键：regedit(0,主键值,子键名,新建子键名)  		&& regedit(0,"HKCU","Software","Roger")
	*写注册表：regedit(1,主键值,子键名,,注册项,项目值)  	&& regedit(1,"HKCU",'Software\Roger',,'Windir','%Windir%',1)
	*读注册表：regedit(2,主键值,子键名,,注册项)  			&& regedit(2,'HKCU','software\Roger',,'Windir')  It will return "&Windir&"
	*删除子键：regedit(3,主键值,子键名)  					&& regedit(3,"HKCU","Software\Roger")

	Local Error_wk,_isError
	Error_wk = On("ERROR")
	ON  ERROR  _isError = .T.
	LOCAL  nDisposition,;
		lnResult,;            &&要取得值的注册表子项的地址
	nResult,;
		ReturnValue,;      &&返回的注册表值
	nKeyLength,;        &&要写的值的长度
	BUFFER,;                &&返回注册表项值
	BufferSize,;        &&返回值的长度
	lnError,;              &&返回注册表函数的错误代码
	nError,;                &&返回的错误代码
	skey1,skey2

	Do Case
		Case Upper(cReg_MainKey)='HKEY_CLASSES_ROOT' or Upper(cReg_MainKey)='HKCR'
			nReg_MainKeyNo = bitset(0,31) &&-2147483648
		Case Upper(cReg_MainKey)='HKEY_CURRENT_USER' or Upper(cReg_MainKey)='HKCU'
			nReg_MainKeyNo = bitset(0,31)+1 &&-2147483647
		Case Upper(cReg_MainKey)='HKEY_LOCAL_MACHINE' or Upper(cReg_MainKey)='HKLM'
			nReg_MainKeyNo = bitset(0,31)+2 &&-2147483646
		Case Upper(cReg_MainKey)='HKEY_USERS' or Upper(cReg_MainKey)='HKUR'
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
		On Error &Error_wk.
		Return  .F.
	EndIF
	*nReg_MainKeyNo=nReg_MainKeyNo-2147483649
	*注册表键值访问权限
	#DEFINE  KEY_ALL_ACCESS                          983103                    &&所有权限

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
		INTEGER  hKey,;                                &&一个打开项的句柄，或者一个标准项名
	STRING  lpSubKey,;                          &&欲创建的新子项的名字
	INTEGER  Reserved,;                        &&设为零
	STRING  lpClass,;                            &&项的类名
	INTEGER  dwOptions,;                      &&零,这个项不正式保存下来，系统重新启动后会消失
	INTEGER  samDesired,;                    &&访问权限
	INTEGER  lpSecurityAttributes,;	   &&对这个项的安全特性进行描述的一个结构,零
	INTEGER  @phkResult,;                    &&指定用于装载新子项句柄的一个变量
	INTEGER  @lpdwDisposition            &&返回是新建子项,还是打开子项(如果新建的子项存在)

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

	DO Case
		Case  nReg_code=0          &&创建子建
			nResult=  0
			nDisposition  =  0
			nError  =  RegOpenKeyEx(nReg_MainKeyNo,cReg_sKey,0,  KEY_ALL_ACCESS,  @nResult)
			IF  nError#0
				Wait window "Can't open the sub_key." nowait
				On Error &Error_wk.
				Return  .F.
			EndIF
			nError=RegCreateKeyEx(nResult,cReg_sKey_New,0,'nReg_ValueType',0,KEY_ALL_ACCESS,0,@lnResult,@nDisposition)
			=RegCloseKey(nResult)
			Return  nError
			***********************************
		Case  nReg_code=1    &&写注册表
			nError=0
			nError  =RegOpenKeyEx(nReg_MainKeyNo,cReg_sKey,  0,KEY_ALL_ACCESS,  @lnResult)
			IF  nError#0
				Wait window "Can't write the sub_key." nowait
				On Error &Error_wk.
				Return  .F.
			EndIF
			nKeyLength=LEN(cReg_KeyValue)
			nError=RegSetValueEx(lnResult,cReg_sKeyName,0,nReg_ValueType,  @cReg_KeyValue,  @nKeyLength)
			=RegCloseKey(lnResult)
			On Error &Error_wk.
			Return  nError=0
			***********************************
		Case  nReg_code=2              &&读注册表
			ReturnValue  =  ""
			lnResult  =  0
			BUFFER  =  SPACE(128)
			BufferSize  =  128
			lnError  =  RegOpenKeyEx(nReg_MainKeyNo,cReg_sKey,  0,  KEY_ALL_ACCESS,  @lnResult)
			IF  lnError  =  0
				lnType  =  0
				lnError  =  RegQueryValueEx(lnResult,  cReg_skeyname,  0,  @lnType,  @BUFFER,  @BufferSize)
				IF  lnError  =  0  AND  BUFFER  <>  CHR(0)                        &&如果错误码为  0,  否则正常读取值.
					ReturnValue  =  LEFT(BUFFER,  BufferSize  -  1)  &&取得返回值
				EndIF
			EndIF
			=RegCloseKey(lnResult)
			On Error &Error_wk.
			Return  ReturnValue
			***********************************
		Case  nReg_code=3                &&删除注册表项
			skey1=LEFT(cReg_sKey,AT('\',cReg_sKey,OCCURS('\',cReg_sKey))-1)
			skey2=SUBST(cReg_sKey,AT('\',cReg_sKey,OCCURS('\',cReg_sKey))+1)
			nError  =RegOpenKeyEx(nReg_MainKeyNo,sKey1,  0,KEY_ALL_ACCESS,  @lnResult)
			IF  nError#0
				Wait window "Can't delete the sub_key." nowait
				On Error &Error_wk.
				Return  .F.
			ELSE
				nError=RegDeleteKey(lnResult,sKey2)
			EndIF
			On Error &Error_wk.
			Return  nError
	EndCase
EndProc
*------
Procedure GetPassword
	Parameters cForm_caption,cOk_button_caption,cCancel_button_caption,lOnly_ok_button,;
			   nLeft_Position,nWidth_Position,nTop_Position,nHeight_Position,lForm_AutoCenter
				
	cForm_caption=DefCharacters(cForm_caption,'Input password')
	cOk_button_caption=DefCharacters(cOk_button_caption,'\<OK')
	cCancel_button_caption=DefCharacters(cCancel_button_caption,'\<Cancel')
	lOnly_ok_button=DefLogic(lOnly_ok_button)
	
	nWidth_Position  = DefNumber(nWidth_Position,260)
	nLeft_Position   = DefNumber(nLeft_Position,Sysmetric(1)/2-nWidth_Position/2)	
	nHeight_Position = DefNumber(nHeight_Position,90)
	nTop_Position    = DefNumber(nTop_Position,( Sysmetric(2)*0.75/2 )- (nHeight_Position/2) ) && *0.8, Because we should remove status bar height
	lForm_AutoCenter = DefLogic(lForm_AutoCenter)
		
	Private cTempReturnValue
	cTempReturnValue=''
	
	oTemp=CreateObject('_Form')
	oTemp.Show()
	
	Release cForm_caption,cOk_button_caption,cCancel_button_caption,lOnly_ok_button,;
			   nLeft_Position,nWidth_Position,nTop_Position,nHeight_Position,lForm_AutoCenter
	
	Local cReturnValue
	cReturnValue=cTempReturnValue
	Release cTempReturnValue
		
	Return cReturnValue  && Exit of this procedure

	Define Class _Form as Form 
		Visible=.T.
		ShowWindow=0
		WindowType=1
		BorderStyle= 0
		MinButton=.F.
		MaxButton=.F.
		Closable=.F.
		Icon=''
		
		Procedure Init && Form.Init
			* Because these properties should be refresh every time,It must be changed in Form.Init event.
			* It will refresh next time if these properties changed in the top coding such as Visible=.T. , ShowWindow=0 ……
			This.Name='GetPassword'
			This.Caption=cForm_caption 
			This.Left=nLeft_Position
			This.Width=nWidth_Position
			This.Top=nTop_Position
			This.Height=nHeight_Position
			
			This.AddObject('TxtPassword','oTextbox')
			This.AddObject('CmdCancel','oCancel')
			This.AddObject('CmdOk','oConfirm')
			
			This.TxtPassword.Width=This.Width*0.9
			This.TxtPassword.Left=This.Width*0.05
			This.TxtPassword.Height=This.Height*0.3
			This.TxtPassword.Top=This.Height*0.2
			This.TxtPassword.FontSize=10+Int( (This.TxtPassword.Height-30)/2)
			
			This.CmdCancel.Caption=cCancel_button_caption
			This.CmdOk.Caption=cOk_button_caption
			This.CmdCancel.Cancel=.T.
			This.CmdOk.Default=.T.	
					
			If lOnly_ok_button Then
				This.CmdCancel.Visible=.F.
				
				This.CmdOk.Width=This.Width*0.9
				This.CmdOk.Left=This.Width*0.05
				This.CmdOk.Height=This.Height*0.3
				This.CmdOk.Top=This.Height*0.6
				This.CmdOk.FontSize=9+Int(This.Height/100)				
			Else
				This.CmdCancel.Width=ThisForm.Width*0.4
				This.CmdCancel.Left=This.Width*0.05
				This.CmdCancel.Height=This.Height*0.3
				This.CmdCancel.Top=This.Height*0.6
				This.CmdCancel.FontSize=9+Int(This.Height/100)	

				This.CmdOk.Width=This.Width*0.4
				This.CmdOk.Left=This.Width*0.55
				This.CmdOk.Height=This.Height*0.3
				This.CmdOk.Top=This.Height*0.6
				This.CmdOk.FontSize=9+Int(This.Height/100)
			EndIf
			
			This.AutoCenter=lForm_AutoCenter 
		EndProc
	EndDefine
	
	Define Class oTextbox as TextBox
		Visible=.T.
		Inputmask=Replicate('x',255)
		PasswordChar='*'
		Value=''
	EndDefine
	
	Define Class oCancel as CommandButton
		Visible=.T.
		Procedure Click
			cTempReturnValue=''
			ThisForm.Release()
		EndProc
	EndDefine
	
	Define Class oConfirm as CommandButton
		Visible=.T.
		Procedure Click
			cTempReturnValue=Alltrim(ThisForm.TxtPassword.Value)
			ThisForm.Release()
		EndProc
	EndDefine
EndProc
*------
Procedure GetCurDir
	Lparameters cTmpDir
	If IsValidStr(cTmpDir) Then
		cTmpDir=Alltrim(cTmpDir)
	Else
		cTmpDir=Sys(16)
	EndIf
	
	Local cReturnValue
	cReturnValue=''
	Do	Case
	Case ':' $ cTmpDir && Local address
		cReturnValue=JustPath(Substrc(cTmpDir,At(':',cTmpDir)-1))
		cReturnValue=Addbs(cReturnValue)
	Case '\\' $ cTmpDir && Server address
		cReturnValue=JustPath(Substrc(cTmpDir,At('\\',cTmpDir) ))
		cReturnValue=Addbs(cReturnValue)
	Otherwise
		cReturnValue=Addbs(JustPath(cTmpDir))
	EndCase
	
	Return cReturnValue
EndProc
*------
Procedure ReadIniFile
	Parameters lpFileName,lpApplicationName,lpKeyName
	&&  读取 INI 文件指定节点,指定项目的值.	参数：文件名,节点名,项目名	返回 字符串
	&&  Read ini file		Eg. readinifile("include\privSetting.ini","节点","项目")
	If Empty(lpFileName) or !File(lpFileName) Then
		Return ""
	Else
		If Upper(lpFileName)<>Upper(LocFile(lpFileName)) Then
			lpFileName=LocFile(LpFileName)
		EndIf
	Endif
	Declare Integer GetPrivateProfileString In Win32API As GetPrivStr  String , String , String , String @ , Integer , String
	Local lpReturnedString , nSize , LcString
	lpReturnedString = Space(200)
	nSize = 200
	*lpApplicationName -  String，欲在其中查找条目的小节名称。这个字串不区分大小写。如设为vbNullString，就在lpReturnedString缓冲区内装载这个ini文件所有小节的列表
	*lpKeyName ------  String，欲获取的项名或条目名。这个字串不区分大小写。如设为vbNullString，就在lpReturnedString缓冲区内装载指定小节所有项的列表
	*lpDefault ------  String，指定的条目没有找到时返回的默认值。可设为空（""）
	*lpReturnedString -  String，指定一个字串缓冲区，长度至少为nSize
	*nSize ----------  Long，指定装载到lpReturnedString缓冲区的最大字符数量
	*lpFileName -----  String，初始化文件的名字。如没有指定一个完整路径名，windows就在Windows目录中查找文件
	= GetPrivStr(lpApplicationName , lpKeyName , '', @ lpReturnedString, nSize , lpFileName)
	LcString = KillPrivNullChar(Alltrim(lpReturnedString))
	Return LcString
EndProc
*------
Procedure WriteIniFile
	Parameters lpFileName,lpApplicationName,lpKeyName,lpKeyValue
	&&	写一个值到INI文件.		参数： 文件名,节点名,项目名,项目值	返回：成功.T., 失败.F.
	&&  Write ini file			Eg. Writeinifile("include\privSetting.ini","节点","项目","值")
	If Empty(lpFileName) or !File(lpFileName) Then
		Return ""
	Else
		If Upper(lpFileName)<>Upper(LocFile(lpFileName)) Then
			lpFileName=LocFile(LpFileName)
		EndIf
	EndIf
	If Empty(lpApplicationName) Or Empty(lpKeyValue)
		Return .F.
	Endif
	Local nReturnValue
	Declare Integer WritePrivateProfileString In Win32API As WritePrivStr String , String , String , String
	*lpApplicationName -  String，要在其中写入新字串的小节名称。这个字串不区分大小写
	*lpKeyName ------  Any，要设置的项名或条目名。这个字串不区分大小写。用vbNullString可删除这个小节的所有设置项
	*lpString -------  String，指定为这个项写入的字串值。用vbNullString表示删除这个项现有的字串
	*lpFileName -----  String，初始化文件的名字。如果没有指定完整路径名，则windows会在windows目录查找文件。如果文件没有找到，则函数会创建它
	nReturnValue = WritePrivStr(lpApplicationName, lpKeyName, lpkeyValue, lpFileName)
	If nReturnValue=0
		Return .F.
	Else
		Return .T.
	Endif
EndProc
*------
Procedure KillPrivNullChar
	Lparameters sPSW
	* 消除字符串中的非打印字符
	Local Lnlength, LcString
	Lnlength = Len(sPSW)
	LcString = Strtran(sPSW, Chr(0), "")
	Return LcString
EndProc
*------
Procedure GetWeekDate
	Lparameters m.nWeek, m.nDayTag, m.nYear, m.nFirstWeek, m.nFirstDayOfWeek
			
	m.nWeek=Int(DefNumber(m.nWeek))
	m.nDayTag=Int(DefNumber(m.nDayTag,1))
	m.nYear=Int(DefNumber(m.nYear,Year(Date())))

	m.nFirstWeek=Int(DefNumber(m.nFirstWeek,1))
	m.nFirstDayOfWeek=Int(DefNumber(m.nFirstDayOfWeek,1))

	Local dReturnValue
	dReturnValue={^//}
		
	If m.nWeek<1 Then
		Return dReturnValue
	EndIf
	If !InList(m.nDayTag,1,2,3,4,5,6,7) Then
		m.nDayTag=1 && The 1st day in the nWeek 
	EndIf
	If Empty(m.nYear) Then
		Return dReturnValue
	EndIf

	If !InList(m.nFirstWeek,0,1,2,3) Then
		m.nFirstWeek=1 && First week contains January 1st.
	EndIf
	If !InList(m.nFirstDayOfWeek,0,1,2,3,4,5,6,7) Then
		m.nFirstDayOfWeek=1 && Sunday
	EndIf
		
	&& Calculation the first day base on nYear and nWeek.
	Local dTmpDate,dTmpThisYear,nTag,dTmpLastYear,dThisYearFirstDay
	dTmpDate='{^'+Alltrim(Str(m.nYear))+'-01-01}'
	dTmpThisYear=&dTmpDate.
	dTmpLastYear=dTmpThisYear-7
	dThisYearFirstDay={^//}
	
	For nTag=1 to 14
		dTmpDate=dTmpLastYear+nTag-1
		If Week(dTmpDate,m.nFirstWeek,m.nFirstDayOfWeek)=1 Then
			dThisYearFirstDay=dTmpDate
			Exit
		EndIf
	EndFor
			
	dReturnValue=( dThisYearFirstDay-1 )+ ( (m.nWeek-1)*7 ) + m.nDayTag
	
	Return dReturnValue
EndProc
*------
Procedure GetWeekCount
	Lparameters m.nYear,m.nFirstWeek,m.nFirstDayOfWeek
	
	m.nYear=Int(DefNumber(m.nYear,Year(Date())))
	m.nFirstWeek=Int(DefNumber(m.nFirstWeek,1))
	m.nFirstDayOfWeek=Int(DefNumber(m.nFirstDayOfWeek,1))

	Local nReturnValue
	nReturnValue=52
		
	If Empty(m.nYear) Then
		Return nReturnValue
	EndIf

	If !InList(m.nFirstWeek,0,1,2,3) Then
		m.nFirstWeek=1 && First week contains January 1st.
	EndIf
	If !InList(m.nFirstDayOfWeek,0,1,2,3,4,5,6,7) Then
		m.nFirstDayOfWeek=1 && Sunday
	EndIf
	
	Local dTmpDate,nTag	
	For nTag=53 to 54
		dTmpDate=GetWeekDate(nTag,1,m.nYear,m.nFirstWeek,m.nFirstDayOfWeek)
		If Year(dTmpDate)>m.nYear Then
			nReturnValue = nTag-1
			Exit
		EndIf
	EndFor
				
	Return nReturnValue
EndProc
*------
Procedure SebmpsLog_Update
	Lparameters m.YYYYWW,m.Desc,m.Status,m.Supplier_I,m.Company_Na
	Local m.Datetime,m.nSelect,m.lReturnValue
	
	If IsValidStr(m.YYYYWW) Then
		m.YYYYWW = Alltrim(m.YYYYWW)
	Else
		Return m.lReturnValue
	EndIf
	m.Desc = DefCharacters(m.Desc)
	m.Status = DefCharacters(m.Status)
	m.Supplier_I = DefCharacters(m.Supplier_I)
	m.Company_Na = DefCharacters(m.Company_Na)
	m.Datetime = Datetime()
	m.nSelect = Select()
	
	If LcDbfOpen('Sebmpslog','Sebmpslog_update') Then
		Insert into Sebmpslog_update (Datetime,YYYYWW,Supplier_I,Company_Na,Status,Desc);
		Values (m.Datetime,m.YYYYWW,m.Supplier_I,m.Company_Na,m.Status,m.Desc)
		m.lReturnValue = .T.
	Else
		m.lReturnValue = .F.
	EndIf
	LcDbfClose('Sebmpslog_update')
	
	Select (m.nSelect)
	Return m.lReturnValue
EndProc
*------
Procedure PrvotSheetName
	Lparamete cString
		
	If Not IsValidStr(cString) Then
		Return ''
	EndIf
	
	Local cReturnValue,cTempValue,nTag,nTagCount
	Store '' to cTempValue,cReturnValue
	Store 0 to nTag
	Store Lenc(cString) to nTagCount
	
	For nTag=1 to nTagCount && New Pause
		cTempValue = Substrc(cString,nTag,1)
		If cTempValue == ['] Then
			cReturnValue = cReturnValue + Replicate(cTempValue,2)
		Else
			cReturnValue = cReturnValue + cTempValue
		EndIf
	EndFor
	
	Return cReturnValue
EndProc
*------
Procedure ItCopyData
	Lparameters cDbfSource,cCursorTarget,cSeekOrder,cuSeekExpression,cFilterExpression,lIgnorePrompt
	
	* Save the enviroment
	Local lReturnValue,nSelect,lAutoCloseSourceTable
	lReturnValue = .F.
	nSelect = Select()
	lAutoCloseSourceTable = .T.
	
	* Deal with the parameters	
	lIgnorePrompt = DefLogic(lIgnorePrompt)	
	
	If IsValidStr(cDbfSource) Then
		cDbfSource = DefCharacters(cDbfSource)
		If Select(cDbfSource)>0 Then
			lAutoCloseSourceTable = .F.
		EndIf
	Else	
		lAutoCloseSourceTable = .F.
	EndIf
	cDbfSource = GetAlias(cDbfSource)
	If Not IsValidStr(cDbfSource) Then && Can not get the alias base on cDbfSource
		If Not lIgnorePrompt Then
			WaitWindow('Can not get the source data.',Sys(16))
		EndIf
		If lAutoCloseSourceTable Then
			LcDbfClose(cDbfSource)
			Select (nSelect)
		EndIf
		Return lReturnValue
	EndIf	
	
	If IsValidStr(cCursorTarget) Then
		cCursorTarget = DefCharacters(cCursorTarget)
		If Select(cCursorTarget)>0 Then
			If Not lIgnorePrompt Then
				WaitWindow('The cursor table name "'+cCursorTarget+'" already existed .',Sys(16))
			EndIf
			If lAutoCloseSourceTable Then
				LcDbfClose(cDbfSource)
				Select (nSelect)
			EndIf
			Return lReturnValue 
		EndIf
	Else
		If Not lIGnorePrompt Then
			WaitWindow('Target cursor table name can not empty .',Sys(16))
		EndIf
		If lAutoCloseSourceTable Then
			LcDbfClose(cDbfSource)
			Select (nSelect)
		EndIf
		Return lReturnValue 
	EndIf
	
	cSeekOrder = DefCharacters(cSeekOrder)
	cuSeekExpression = DefCharacters(cuSeekExpression)
	cFilterExpression = DefCharacters(cFilterExpression,'.T.')
	
	Local cScanExpression
	cScanExpression = IndexToExp(cSeekOrder,cDbfSource)	
		
	* Program main body begain		
	If ItCreateCursor('',Dbf(cDbfSource),cCursorTarget) Then
		If CopyCdx(Dbf(cDbfSource),cCursorTarget)>0 Then
			Select (cCursorTarget)
			Set Order To && Empty the order in cCursorTarget
		Else
			If Not lIgnorePrompt Then
				WaitWindow('Copy index from '+cDbfSource+' to '+cCursorTarget+' failed.',Sys(16))
			EndIf
		EndIf
	Else
		If Not lIgnorePrompt Then
			WaitWindow('Create cursor table '+cCursorTarget+' base on '+cDbfSource+' failed.',Sys(16))
		EndIf
		If lAutoCloseSourceTable Then
			LcDbfClose(cDbfSource)
			Select (nSelect)
		EndIf
		Return lReturnValue
	EndIf
			
	If IsValidStr(cSeekOrder) Then
		Set Order To &cSeekOrder. in (cDbfSource)
	EndIf
		
	If IsValidStr(cuSeekExpression) and IsValidStr(cSeekOrder) Then
		If Seek(Evaluate(cuSeekExpression),cDbfSource,cSeekOrder) Then
			Select (cDbfSource)
			Scan rest while &cScanExpression.=&cuSeekExpression.
				If !Evaluate(cFilterExpression) Then
					Loop
				EndIf
				Scatter memo memvar
				Insert into (cCursorTarget) from memvar
			EndScan
		EndIf
	Else
		Select (cDbfSource)
		Scan
			If !Evaluate(cFilterExpression) Then
				Loop
			EndIf
			Scatter memo memvar
			Insert into (cCursorTarget) from memvar
		EndScan
	EndIf

	* Restore the enviroment *
	If lAutoCloseSourceTable Then
		LcDbfClose(cDbfSource)
	EndIf
	Select (cCursorTarget)
	lReturnValue = .T.
	
	* Return the value *
	Return lReturnValue
EndProc
*------
Procedure ItMirrorData
	Lparameters cCursorName,cSource_DbfAlias, ;
		cAddField1,cAddField2,cAddField3,cAddField4,cAddField5,cAddField6,cAddField7,cAddField8,cAddField9,cAddField10,;
		cAddField11,cAddField12,cAddField13,cAddField14,cAddField15,cAddField16,cAddField17,cAddField18,cAddField19,;
		cAddField20,cAddField21,cAddField22,cAddField23,cAddField24
	
	* Default return value.
	Local lReturnValue
	lReturnValue = .F.
	
	* Check the mirror cursor name.
	If IsValidStr(cCursorName) Then
		If Select(cCursorName) > 0 Then
			Waitwindow("The alias '" + cCursorName + "' has been allocated.",Sys(16))
			Return lReturnValue
		EndIf
	Else
		Waitwindow('Please set the mirror cursor name first.',Sys(16))
		Return lReturnValue
	EndIf
	
	* Check the mirror datasource.
	If !IsValidStr(cSource_DbfAlias) Then
		If Empty(Alias()) Then
			Waitwindow('Can not found the mirror datasource.',Sys(16))
			Return lReturnValue
		Else
			cSource_DbfAlias = Alias()
		EndIf
	EndIf
			

	* Mirror data now. 
	If ItCreateCursor_Roger(cSource_DbfAlias,cCursorName, ;
		cAddField1,cAddField2,cAddField3,cAddField4,cAddField5,cAddField6,cAddField7,cAddField8,cAddField9,cAddField10,;
		cAddField11,cAddField12,cAddField13,cAddField14,cAddField15,cAddField16,cAddField17,cAddField18,cAddField19,;
		cAddField20,cAddField21,cAddField22,cAddField23,cAddField24	;
							) Then
		CopyCdx(cSource_DbfAlias,cCursorName)
		ItAppendData(cSource_DbfAlias,cCursorName)

		lReturnValue = .T.
	EndIf
	
	Return lReturnValue	
EndProc
*------
Procedure ItAppendData
	Lparameters cSource_DbfAlias,cTarget_DbfAlias,cIndex_TagName,eSeekExpression,cFilterExpression
	
	* Save the enviroment first.
	Local lReturnValue,nSelect
	lReturnValue = .F.
	nSelect = Select()
	
	* Checking the parameters.
	cIndex_TagName = DefCharacters(cIndex_TagName)
	eSeekExpression = DefCharacters(eSeekExpression)
	cFilterExpression = DefCharacters(cFilterExpression,'.T.')

	Local cSourceAlias,cTargetAlias,lDbfSource_Opened,lDbfTarget_Opened,cScanExpression
	Store '' to cSourceAlias,cTargetAlias
	Store .T. to lDbfSource_Opened,lDbfTarget_Opened
	
	* ----------------------- For target table alias --------------------------- *
	* Check the table if need to open again.	
	If IsValidStr(cTarget_DbfAlias) Then && If the parameter cTarget_DbfAlias is a vaild string.
		If Select(cTarget_DbfAlias)>0 and IsValidStr(GetAlias(cTarget_DbfAlias)) Then && If cTarget_DbfAlias exist opened and no need to open again
			cTargetAlias = GetAlias(cTarget_DbfAlias)
			lDbfTarget_Opened = .F.
		Else
			lDbfTarget_Opened = .T.
		EndIf
		* Confirm the table which need to dispose and check index information.
		If lDbfTarget_Opened Then && If no need open the table, That's mean has been found a table to dispose
			* Need to open the table base on cTarget_DbfAlias
			cTargetAlias = AliasName()
			If !LcDbfOpen(cTarget_DbfAlias,cTargetAlias,.F.) Then
				Waitwindow("The target DbfAlias '" + cTarget_DbfAlias + "' can not open.",Sys(16))
				Return lReturnValue
			EndIf
		EndIf	
	Else
		Waitwindow('Please set target DbfAlias first.',Sys(16))
		Return lReturnValue
	EndIf
	
	* ----------------------- For source table alias --------------------------- *	
	Local nRecno_Source
	nRecno_Source = 0
	* Check the table if need to open again.	
	If IsValidStr(cSource_DbfAlias) Then && If the parameter cSource_DbfAlias is a vaild string.
		If Select(cSource_DbfAlias)>0 and IsValidStr(GetAlias(cSource_DbfAlias)) Then && If cSource_DbfAlias exist opened and no need to open again
			cSourceAlias = GetAlias(cSource_DbfAlias)
			nRecno_Source = Iif(Eof(cSourceAlias),0,Recno(cSourceAlias))
			lDbfSource_Opened = .F.
		Else
			lDbfSource_Opened = .T.
		EndIf
		* Confirm the table which need to dispose and check index information.
		If lDbfSource_Opened Then && If no need open the table, That's mean has been found a table to dispose
			* Need to open the table base on cSource_DbfAlias
			cSourceAlias = AliasName()
			If !LcDbfOpen(cSource_DbfAlias,cSourceAlias,.F.) Then
				Waitwindow("The source DbfAlias '" + cSource_DbfAlias + "' can not open.",Sys(16))
				Return lReturnValue
			EndIf
		EndIf
	Else
		Waitwindow('Please set the source DbfAlias first.',Sys(16))
		Return lReturnValue
	EndIf
	* Set index for (cSourceAlias).
	If IsValidStr(cIndex_TagName) Then
		Set Order To (cIndex_TagName) in (cSourceAlias)
	Else
		If IsValidStr(eSeekExpression) and Empty(Order(cSourceAlias)) Then
			Waitwindow("No index seted of '" + cSourceAlias + "'.",Sys(16))
			Return lReturnValue
		EndIf
	EndIf
	* Get index expression.
	Select (cSourceAlias)
	cScanExpression = IndexToExp()
	
		
	* Program main body begain.						
	If IsValidStr(eSeekExpression) Then
		If Seek(eSeekExpression,cSourceAlias,cIndex_TagName) Then
			Select (cSourceAlias)
			Scan rest while &cScanExpression. = eSeekExpression
				If !Evaluate(cFilterExpression) Then
					Loop
				EndIf
				Scatter memo memvar
				Insert into (cTargetAlias) from memvar
			EndScan
		EndIf
	Else
		Select (cSourceAlias)
		Scan
			If !Evaluate(cFilterExpression) Then
				Loop
			EndIf
			Scatter memo memvar
			Insert into (cTargetAlias) from memvar
		EndScan
	EndIf
	* Program main body end.

	* Restore the enviroment *
	If lDbfSource_Opened Then
		LcDbfClose(cSourceAlias)
	Else
		If nRecno_Source > 0 Then
			Go nRecno_Source in (cSourceAlias)
		EndIf		
	EndIf
	If lDbfTarget_Opened Then
		LcDbfClose(cTargetAlias)
	EndIf
	
	Select (nSelect)
	lReturnValue = .T.
	 
	* Return the value *
	Return lReturnValue
EndProc
*------
Procedure ItSearchData
	Lparameters cSourceAlias,cTargetAlias,cSearch

EndProc
*------
Procedure ItUpdateData3
	LPARAMETER PAULKEYVALUE , PAULINDEX , PAULKEY , PAULOLDDBF , PAULNEWDBF , PAULCONDITION
	SET EXACT ON
	SET DELETED OFF
	IF EMPTY(PAULCONDITION)
		PAULCONDITION = '.T.'
	ENDIF
	IF USED('paulOLD')
		USE IN PAULOLD
	ENDIF
	PAULOLD = 'paulOLD'
	use &paulOLDDBF. order &paulindex. in 0 alias (paulOLD) again
	= CURSORSETPROP('Buffering',5,(PAULOLD))
	PAULNEW = PAULNEWDBF
	PAULKEY_VALUE = ''
	CONTINUE_YN = 0
	PAULDELETED = .F.
	FPAULOLDADATETIME = ALLTRIM(PAULOLD) + '.' + 'ADATETIME'
	FPAULNEWADATETIME = ALLTRIM(PAULNEW) + '.' + 'ADATETIME'
	SELECT (PAULNEW)
	GO TOP
	IF EOF()
		IF USED(PAULOLD)
			USE IN (PAULOLD)
		ENDIF
		WAIT WINDOW NOWAIT 'Update completed !'
		LRPRINT = 999
		SET EXACT OFF
		SET DELETED ON
		RETURN .T.
	ENDIF
	LOCAL PAULFIELD , PAULFIELD_VALUE
	SELECT (PAULNEW)
	paulKEY_VALUE=&paulKEY.
	PAULDELETED = DELETED()
	PAULNOREC = 0
	PAULSELECT = .T.
	DO WHILE  .NOT. EOF(PAULNEW)
		if &paulcondition.
			SELECT (PAULNEW)
			** Scatter memo memvar && Store all field value in variable.
			** Question: Please check if there is any field is blanked, Please use scatter memo memvar, Else please use field to upgrade
			** one by one.  Becauase scatter memo memvar and gather memo memvar is faster than one field by on field.
			PAULDELETED = DELETED()
			paulKEY_VALUE=&paulKEY.
			
			Select (PAULOLD)
			GO TOP
			SEEK PAULKEY_VALUE
			If Found(PAULOLD) && If found in the server database table.
				CONTINUE_YN = 1
				If PAULDELETED && If deleted in the Cursor table.
					Delete In (PaulOld) && Deleted in the server Database table.
				Else
					If Deleted('PAULOLD') && If deleted in the server database table.  But can not deleted in the Cursor table.
						Recall in (PaulOld) && Recall in the server database table.
					EndIf
				EndIf
			Else && Can not found in the server database table. That's mean a new reocrd should insert into server database table.
				If  .NOT. PAULDELETED && If not deleted in the Cursor table. That's mean a available record in Cursor table.
					CONTINUE_YN = 0
					SELECT (PAULOLD)
					Append Blank in (PaulOld) && Append new blank record in the server database table.
				Else
					Select (PAULNEW) && Select the Cursor table.
					SKIP
					LOOP
				ENdIf
			EndIf
			
			Select (PAULOLD) && Select the server database table.
			For GNCOUNT = 1 TO Fcount()
				PAULFIELD = Field(GNCOUNT)
				FPAULOLD = ALLTRIM(PAULOLD) + '.' + ALLTRIM(PAULFIELD)
				FPAULNEW = ALLTRIM(PAULNEW) + '.' + ALLTRIM(PAULFIELD)
				IF PAULSELECT && What's this variable use ?
					If IsBlank(&FpaulNEW.) Then
						Blank fields (PaulField) in (PaulOld)
					Else  
						Replace &FpaulOLD. WITH &FpaulNEW.
					EndIf
				EndIf
			EndFor

			** Gather memo memvar && Upgrade the record.
			* Question: Maybe should release all field variable before exit this procedure.
			
			PAULNOREC = PAULNOREC + 1			
			WAIT WINDOW NOWAIT '# OF RECORD UPDATED: ' + ALLTRIM(STR(PAULNOREC,8))
		ENDIF
		SELECT (PAULNEW)
		SKIP
		PAULDELETED = DELETED()
		paulKEY_VALUE=&paulKEY.
	ENDDO
	SELECT (PAULOLD)
	VPLUPDATEOK = TABLEUPDATE(.T.)
	IF  .NOT. VPLUPDATEOK
		= TABLEREVERT(.T.)
	ENDIF
	IF USED(PAULOLD)
		USE IN (PAULOLD)
	ENDIF
	SET EXACT OFF
	SET DELETED ON
	RETURN VPLUPDATEOK
ENDPROC
*------
Procedure CopyAllDocs
	lParameters cOldScreen_ID,cNewScreen_ID,cOldDoc_ID,cNewDoc_ID,nOverwrite_Append,cFilterCondition
	
	If !IsValidStr(cOldScreen_ID) or !IsValidStr(cNewScreen_ID) or !IsValidStr(cOldDoc_ID) or !IsValidStr(cNewDoc_ID) Then
		Return .F.
	Else
		cOldScreen_ID = Padr(cOldScreen_ID,10,Space(1))
		cNewScreen_ID = Padr(cNewScreen_ID,10,Space(1))
		If cOldScreen_ID == cNewScreen_ID Then
			* Can not copy the relation document between the same document
			Return .F.
		EndIf
		cOldDoc_ID = Padr(cOldDoc_ID,20,Space(1))
		cNewDoc_ID = Padr(cNewDoc_ID,20,Space(1))
	EndIf
	
	nOverWrite_Append= DefNumber(nOverWrite_Append)
	nOverWrite_Append= Int(nOverWrite_Append)
	If !InList(nOverWrite_Append,0,1) Then
		nOverWrite_Append= 0 && default value was 0 that's mean OverWrite , 1 that's mean append .
	EndIf
	
	If Pcount()<6 Then && That mean no paramete sent to cFilterCondition
		cFilterCondition = '.T.'
	EndIf
	
	Local nSelect,cTmpAlias,lReturnValue
	nSelect = Select()
	cTmpAlias = AliasName()
	lReturnValue = .F.
	
	If !LcDbfOpen('Alldocs',cTmpAlias,.F.,'Doc_Key2') Then && UPPER(SCREEN_ID+DOC_ID+LINENO)
		Select (nSelect)
		Return lReturnValue
	EndIf
		
	Local cTmpAlldocs
	cTmpAlldocs = AliasName()
	ItCreateCursor('','Alldocs',cTmpAlldocs)
		
	Select (cTmpAlias)
	If Seek(Upper(cOldScreen_ID+cOldDoc_ID),cTmpAlias,'Doc_Key2') Then && UPPER(SCREEN_ID+DOC_ID+LINENO)
		* Copy the eligible records into (cTmpAllDocs)
		Select (cTmpAlias)
		Scan rest while Upper(Screen_ID+Doc_ID) == Upper(cOldScreen_ID+cOldDoc_ID) 
			If Evaluate(cFilterCondition) Then
				Scatter memo memvar
				Insert into (cTmpAllDocs) from memvar
			Else
				Loop
			EndIf
		EndScan
	
		If Reccount(cTmpAllDocs)>0 Then && If found eligible records
			* Got the maximum lineno
			Local nMaxLineNo
			nMaxLineNo = 0
			If Seek(Upper(cNewScreen_ID+cNewDoc_ID),cTmpAlias,'Doc_Key2') Then && UPPER(SCREEN_ID+DOC_ID+LINENO)
				Select (cTmpAlias)
				Scan rest while Upper(Screen_ID+Doc_ID) == Upper(cNewScreen_ID+cNewDoc_ID)
					If Val(Lineno) > nMaxLineNo Then
						nMaxLineNo = Val(LineNo)
					EndIf
					If nOverWrite_Append = 0 Then && Overwrite , Delete the old records first.
						Delete In (cTmpAlias)
					EndIf
				EndScan
			EndIf
				
			* Upgrade screen_id,doc_id or Lineno if need .
			Select (cTmpAllDocs)
			Scan
				Replace Screen_id with cNewScreen_ID in (cTmpAllDocs)
				Replace Doc_ID with cNewDoc_ID in (cTmpAllDocs)
				Replace Adatetime with Datetime()
				Replace Adate with Pauluser_create()
				If nOverWrite_Append = 1 Then && Append , Need to upgrade the lineno first .
					nMaxLineNo = nMaxLineNo +1
					Replace Lineno with Alltrim(Str(nMaxLineNo ))
				EndIf
				If !Empty(Alltrim(FileName)) Then
					Local cSourceFile,cTargetFname,cTargetFile,cTargetPath
					cSourceFile = ForcePath(Alltrim(FileName),Addbs(Set_Path)+'Files\'+Alltrim(cOldScreen_ID))
					cTargetFname =ForceExt(Alltrim(cNewDoc_ID)+Padl(Alltrim(Str(Val(Lineno))),4,'0'),JustExt(FileName))
					cTargetFile = ForcePath(Alltrim(cTargetFname),Addbs(Set_Path)+'Files\'+Alltrim(cNewScreen_ID))
					cTargetPath = JustPath(cTargetFile)
					*!*	If File(cSourceFile) and !File(cTargetFile) Then
					If File(cSourceFile) Then
						If !Directory(cTargetPath) Then
							Md &cTargetPath.
						EndIf
						ItCopyFile(cSourceFile,cTargetFile,.T.)
					EndIf
					Replace FileName with cTargetFname
				EndIf
				
				Scatter memo memvar
				Insert into (cTmpAlias) From memvar
			EndScan	
		EndIf		
		lReturnValue = .T.
	Else
		lReturnValue = .F. && Not found the eligible records in (cTmpAlias)
	EndIf
	
	* Restore the enviroment
	LcDbfClose(cTmpAlias)
	LcDbfClose(cTmpAllDocs)
	Select (nSelect)
	
	Return lReturnValue	
EndProc
*------
Procedure CreateFolder
	Lparameters cPath
	
	If !IsValidStr(cPath) Then
		Return .F.
	Else
		cPath = Alltrim(cPath)
	EndIf
	
	If Directory(cPath) Then
		Return .F.
	Else
		Md (cPath)
	EndIf
	
	Return .T.
EndProc
*------
Procedure IsExcelObject
	Lparameters oExcelObject
	
	Local cOn_Error,lErrored,lReturnValue
	cOn_Error = On('Error')
	lErrored = .F.
	lReturnValue = .F.
	
	On Error lErrored = .T.
	
	If Vartype(oExcelObject)==Upper('O') and Upper(oExcelObject.Name)==Upper('Microsoft Excel') Then
		lReturnValue = .T.
	EndIf
	
	If lErrored Then
		lReturnValue = .F. 
	EndIf
	
	On Error &cOn_Error.
	
	Return lReturnValue	
EndProc
*------
Procedure ExcelFind
	Lparameters oExcelObject,cFindValue,lGoTop
		
	Local cReturnValue
	cReturnValue = ''
	
	If !IsExcelObject(oExcelObject) Then
		Return cReturnValue 
	EndIf
	
	If InList(Vartype(cFindValue),Upper('L')) Then
		Return cReturnValue 
	EndIf
	
	Local cTmpValue
	cTmpValue = oExcelObject.ActiveCell.Value
	If !IsNull(cTmpValue) and Vartype(cTmpValue)==Upper('C') and cFindValue $ cTmpValue Then
		cReturnValue = Alltrim(Str(oExcelObject.ActiveCell.Row))+','+Alltrim(Str(oExcelObject.ActiveCell.Column))
	Else
		lGoTop = DefLogic(lGoTop)
		If lGoTop Then
			Local nActiveRow,nActiveColumn
			nActiveRow = oExcelObject.ActiveCell.Row()
			nActiveColumn = oExcelObject.ActiveCell.Column()
			oExcelObject.Range('A1').Select && Go top
		EndIf
		
		If !Isnull(oExcelObject.Cells.Find(cFindValue,oExcelObject.ActiveCell,-4123,2,1,1,.F.,.F.,.F.)) Then
			oExcelObject.Cells.Find(cFindValue,oExcelObject.ActiveCell,-4123,2,1,1,.F.,.F.,.F.).Activate		
			cReturnValue = Alltrim(Str(oExcelObject.ActiveCell.Row))+','+Alltrim(Str(oExcelObject.ActiveCell.Column))
		EndIf
		
		If lGoTop Then
			oExcelObject.Cells(nActiveRow,nActiveColumn).Select && Restore the position
		EndIf
	EndIf
	
	Return cReturnValue 
EndProc
*------
Procedure ExcelRange && UnFinished
	Lparameters oExcelObject
	
	Local cReturnValue
	cReturnValue = ''
	
	If !IsValidStr(oExcelObject) Then
		Return cReturnValue
	EndIf
	
	Local nSelection_Column_NO,nSelection_Column_Count ,;
	      nSelection_Row_NO,nSelection_Row_Count
	
	nSelection_Column_NO	= oExcelObject.Selection.Column
	nSelection_Column_Count	= oExcelObject.Selection.Columns.Count
	nSelection_Row_NO	 	= oExcelObject.Selection.Row
	nSelection_Row_Count 	= oExcelObject.Selection.Rows.Count
	
	
*------
Procedure ExcelFindCount
	Lparameters oExcelObject,cFindValue
	
	Local nReturnValue,lAllSheet
	cReturnValue = 0
	
	If !IsExcelObject(oExcelObject) Then
		Return nReturnValue
	Endif
	If InList(Vartype(cFindValue),Upper('L')) Then
		Return cReturnValue 
	EndIf
		
	Local nActive_Row,nActive_Column,nReturnValue,cFirstFind_Cell,cTmpFind_Cell
	nActive_Row 	= oExcelObject.Selection.Row
	nActive_Column	= oExcelObject.Selection.Column
	nReturnValue = 0
	
	If !IsNull(oExcelObject.Selection.Find(cFindValue,oExcelObject.ActiveCell,-4123,2,1,1,.F.,.F.,.F.)) Then
		oExcelObject.Selection.Find(cFindValue,oExcelObject.ActiveCell,-4123,2,1,1,.F.,.F.,.F.).Activate		
		cFirstFind_Cell = Alltrim(Str(oExcelObject.ActiveCell.Row))+','+Alltrim(Str(oExcelObject.ActiveCell.Column))
		nReturnValue = nReturnValue + 1
		
		Do while oExcelObject.Selection.Find(cFindValue,oExcelObject.ActiveCell,-4123,2,1,1,.F.,.F.,.F.).Activate
			cTmpFind_Cell = Alltrim(Str(oExcelObject.ActiveCell.Row))+','+Alltrim(Str(oExcelObject.ActiveCell.Column))
			If cTmpFind_Cell == cFirstFind_Cell Then
				Exit
			Else
				nReturnValue = nReturnValue + 1
			EndIf
		EndDo
		
		* Recover the first position ,If posiable maybe can restore the selection range.
		oExcelObject.Cells(nActive_Row,nActive_Column).Select
	EndIf
	
	Return nReturnValue
EndProc
*------
Procedure ExcelEvaluate
	Lparameters oExcelObject,nRow,nColumn
	
	Local nReturnValue
	nReturnValue = 0
	
	If !IsExcelObject(oExcelObject) Then
		Return nReturnValue
	EndIf
	
	nRow = Abs(Int(DefNumber(nRow)))
	nColumn = Abs(Int(DefNumber(nColumn)))	
	If nRow=0 or nColumn=0 Then
		Return nReturnValue
	Else
		If Left(oExcelObject.Cells(nRow,nColumn).formular1c1,1) == '=' Then
			Return nReturnValue
		EndIf
	EndIf
	
			
	Local nTag,cTmpXlsValue,cTmpXlsFunction,cTmpXlsParameters
	nTag = 0
	Note: 
	
	* nTag = 1 : That mean return a value to excel .
	* nTag = 2 : That mean return an object to excel .
	* nTag = 3 : That mean no need to return a value but need to run a foxpro expression.
	* nTag = 4 : Define an object such as foxpro object.
	
	cTmpXlsValue = ItStrExtract(oExcelObject.Cells(nRow,nColumn).Value,'[<','>]')
	If !IsValidStr(cTmpXlsValue) Then
		Return nReturnValue
	Else
		cTmpXlsValue = Alltrim(cTmpXlsValue)
	EndIf
	
	Local lReturn,cOn_Error,cErrorMessage
	lReturn = .F.
	cOn_Error = On('Error')
	cErrorMessage = ''
	On Error cErrorMessage = 'Message : ' + Message()

	* Check if need to print
	If Rightc(cTmpXlsValue,1) == '|' Then && '|' Need to check Print condition
		Local cPrint_Condition,lRemove_Place_If_Not_Condition
		cTmpXlsValue = Leftc(cTmpXlsValue,Lenc(cTmpXlsValue)-1) && Re-set the print expression
		
		Local cDelete_Tag
		cDelete_Tag = Rightc(cTmpXlsValue,1)
		If InList(cDelete_Tag,'-','|') Then && Need to remove the place if not print condition
			cTmpXlsValue = Leftc(cTmpXlsValue,Lenc(cTmpXlsValue)-1) && Re-set the print expression
			lRemove_Place_If_Not_Condition = .T.
		Else
			lRemove_Place_If_Not_Condition = .F.
		EndIf

		cPrint_Condition = Alltrim(ItSubstr(cTmpXlsValue,'?',2))  && '?' that mean print condition split keyword
		If Evaluate(cPrint_Condition) Then && If condition is true
			cTmpXlsValue = Alltrim(ItSubstr(cTmpXlsValue,'?',1)) && Re-set the print expresstion
			If !IsValidStr(cTmpXlsValue) Then && If the print expression is empty or not valid
				oExcelObject.Cells(nRow,nColumn).Value = .Null.
				lReturn = .T. && Just remote the place no need set value .
			EndIf
		Else && Print condition is not true <=> False <=> .F.
			If lRemove_Place_If_Not_Condition Then
				* Delete the row or column.
				oExcelObject.Cells(nRow,nColumn).Select 
				If cDelete_Tag = '-' && Row(s)
					nReturnValue = oExcelObject.Selection.Rows.Count()
					oExcelObject.Selection.EntireRow.Delete()
				Else && '|' Column(s)
					oExcelObject.Selection.EntireColumn.Delete()
				EndIf
			Else
				oExcelObject.Cells(nRow,nColumn).Value = .Null.
			EndIf
			lReturn = .T.
		EndIf
	EndIf
	If lReturn Then
		If !Empty(cErrorMessage) Then && Add comment and store the error message
			If IsNull(oExcelObject.Cells(nRow,nColumn).Comment) Then
				oExcelObject.Cells(nRow,nColumn).AddComment()
				oExcelObject.Cells(nRow,nColumn).Comment.Text(cErrorMessage)
			Else
				oExcelObject.Cells(nRow,nColumn).Comment.Text(oExcelObject.Cells(nRow,nColumn).Comment.Text + ;
																Chr(13)+Chr(10)+cErrorMessage)
			EndIf
		EndIf
		On Error &cOn_Error.
		Return nReturnValue
	EndIf

	
	If Leftc(cTmpXlsValue,1)==Upper('@') Then
		cTmpXlsValue = Rightc(cTmpXlsValue,Lenc(cTmpXlsValue)-1)
		nTag = 2 && That mean return an object to excel .
	Else
		If Leftc(cTmpXlsValue,1) == Upper('$') Then
			cTmpXlsValue = Rightc(cTmpXlsValue,Lenc(cTmpXlsValue)-1)
			nTag = 3 && That mean no need to return a value but need to run a foxpro expression.
		Else
			nTag = 1 &&	That mean return a value to excel .
		EndIf
	EndIf Maybe they will become 3、4、5 etd.. for the furture.
	
	Do	Case 
	Case nTag = 1 
		Local eValue 
		eValue = Evaluate(cTmpXlsValue)
		If Empty(cErrorMessage) Then
			If Vartype(eValue) = Upper('D') and Empty(eValue) Then
				oExcelObject.Cells(nRow,nColumn).Value = .Null.
			Else
				oExcelObject.Cells(nRow,nColumn).Value = eValue
			EndIf
		EndIf
	Case nTag = 2
		oExcelObject.Cells(nRow,nColumn).Value = .Null.			
		Local cPicPath,nPicWidth,nPicHeight,nPicLeft,nPicTop,nParametersCount,nParametersTag,cTmpParameterValue
		Store '' to cPicPath
		Store Occurs('#',cTmpXlsValue)+1 to nParametersCount 
		Store 0 to nPicWidth,nPicHeight,nPicLeft,nPicTop,nParametersTag
		For nParametersTag = 1 to nParametersCount
			If nParametersTag = 1 Then
				If '#' $ cTmpXlsValue Then
					cTmpParameterValue = Alltrim(ItSubstr(cTmpXlsValue,'#',nParametersTag))
				Else
					cTmpParameterValue = Alltrim(cTmpXlsValue)
				EndIf
			EndIf
			
			If !IsValidStr(cTmpParameterValue) Then
				Loop
			EndIf
			
			Do	Case
				Case nParametersTag = 1
					Store Evaluate(cTmpParameterValue) to cPicPath
				Case nParametersTag = 2 
					Store Val(cTmpParameterValue) to nPicWidth
				Case nParametersTag = 3 
					Store Val(cTmpParameterValue) to nPicHeight
				Case nParametersTag = 4
					Store Val(cTmpParameterValue) to nPicLeft
				Case nParametersTag = 5
					Store Val(cTmpParameterValue) to nPicTop
				Otherwise
					&& No need to deal with it.
			EndCase
		EndFor
		
		If IsValidStr(cPicPath) Then				
			If At(":",cPicPath) != 0 Or At("\\",cPicPath) != 0
				cPicPath=Alltrim(cPicPath)
			Else
				If File(ForcePath(cPicPath,Set_Path+'Photos')) Then
					cPicPath = ForcePath(cPicPath,Set_Path+'Photos')
				Else
					If File(ForcePath(cPicPath,Set_Path+'Bitmaps')) Then
						cPicPath = ForcePath(cPicPath,Set_Path+'Bitmaps')
					Else
						If File(cPicPath) Then
							cPicPath = LocFile(cPicPath)
						Else
							lReturn = .T.
						EndIf
					EndIf
				EndIf
			EndIf				
		Else
			lReturn = .T.
		EndIf	
		* Check if need to exit the Program	
		If lReturn Then
			If !Empty(cErrorMessage) Then && Add comment and store the error message
				If IsNull(oExcelObject.Cells(nRow,nColumn).Comment) Then
					oExcelObject.Cells(nRow,nColumn).AddComment()
					oExcelObject.Cells(nRow,nColumn).Comment.Text(cErrorMessage)
				Else
					oExcelObject.Cells(nRow,nColumn).Comment.Text(oExcelObject.Cells(nRow,nColumn).Comment.Text + ;
																	Chr(13)+Chr(10)+cErrorMessage)
				EndIf
			EndIf
			On Error &cOn_Error.
			Return nReturnValue
		EndIf
				
		oExcelObject.Cells(nRow,nColumn).Select && if no this code they can not get the default width,height
		If nPicWidth = 0 Then
			nPicWidth = oExcelObject.Selection.Width-4
		EndIf
		If nPicHeight = 0 Then
			nPicHeight = oExcelObject.Selection.Height-4
		EndIf
		If nPicLeft = 0 Then
			nPicLeft = oExcelObject.Selection.Left
		EndIf
		If nPicTop = 0 Then
			nPicTop = oExcelObject.Selection.Top
		EndIf
		
		* Insert picture
		oExcelObject.activesheet.PictureS.Insert(cPicPath).Select
		oExcelObject.Selection.ShapeRange.Lockaspectratio = .T.

		* Set the position for insert picture
		If (oExcelObject.Application.Selection.shaperange.Width > nPicWidth) Or (oExcelObject.Application.Selection.shaperange.Height > nPicHeight)
			If oExcelObject.Application.Selection.shaperange.Width/nPicWidth > oExcelObject.Application.Selection.shaperange.Height/nPicHeight
				oExcelObject.Application.Selection.shaperange.Width = nPicWidth
			Else
				oExcelObject.Application.Selection.shaperange.Height= nPicHeight
			Endif
		Else
			If oExcelObject.Application.Selection.shaperange.Width/nPicWidth > oExcelObject.Application.Selection.shaperange.Height/nPicHeight
				oExcelObject.Application.Selection.shaperange.Width = nPicWidth
			Else
				oExcelObject.Application.Selection.shaperange.Height= nPicHeight
			Endif
		Endif
		oExcelObject.Selection.shaperange.Left = nPicLeft + 2 
		oExcelObject.Selection.shaperange.Top = nPicTop + 2
		
		* The following coding comment by Roger. Because do not know what's it use , And it will add in split line in the picture
		If Val(Alltrim(oExcelObject.Version))>=14 Then && If the excel version is 2010 or more height edition 
			nPicWidth  = oExcelObject.Selection.ShapeRange.Width
			nPicHeight = oExcelObject.Selection.ShapeRange.Height
			nPicLeft   = oExcelObject.Selection.ShapeRange.Left
			nPicTop    = oExcelObject.Selection.ShapeRange.Top
			oExcelObject.Selection.Delete
			oExcelObject.ActiveSheet.Shapes.AddShape(1,nPicLeft,nPicTop,nPicWidth,nPicHeight).Fill.UserPicture(cPicPath)
			oExcelObject.ActiveSheet.Shapes(oExcelObject.ActiveSheet.Shapes.Count).Line.visible = .F.
		EndIf
	Case nTag = 3 
		Local cFoxpro_Coding
		cFoxpro_Coding = ExecScript(cTmpXlsValue)
		If Empty(cErrorMessage) Then
			oExcelObject.Cells(nRow,nColumn).Value = .Null.
		EndIf
	EndCase
	
	If !Empty(cErrorMessage) Then && Add comment and store the error message
		If IsNull(oExcelObject.Cells(nRow,nColumn).Comment) Then
			oExcelObject.Cells(nRow,nColumn).AddComment()
			oExcelObject.Cells(nRow,nColumn).Comment.Text(cErrorMessage)
		Else
			oExcelObject.Cells(nRow,nColumn).Comment.Text(oExcelObject.Cells(nRow,nColumn).Comment.Text + ;
															Chr(13)+Chr(10)+cErrorMessage)
		EndIf
	EndIf
	
	* Restore the error handle environment.
	On Error &cOn_Error. 
	
	Return nReturnValue
EndProc
*------
Procedure Excel_Fill_Mast
	Lparameters oExcelObject,eSeekExpression,cTableAlias,cIndex_TagName ,;
				nMaxColumns,cDiv_Start,cDiv_End
		
	Local nFilled_Rows,nDeleted_Rows,nInsert_Rows,cReturnValue
	nFilled_Rows = 0
	nDeleted_Rows = 0
	nInsert_Rows = 0
	cReturnValue = Alltrim(Str(nFilled_Rows)) + ',' + Alltrim(Str(nDeleted_Rows)) + ',' + Alltrim(Str(nInsert_Rows))
	
	* Check the parameters
	If !IsExcelObject(oExcelObject) Then
		Return cReturnValue 
	EndIf
	
	cDiv_Start = DefCharacters(cDiv_Start,'<Mast>') && Default value is '<Mast>'
	cDiv_End   = DefCharacters(cDiv_End, '</Mast>') && Default value is '</Mast>'

	Local cMast_Start,cMast_End,nRow_Start,nRow_End
	cMast_Start = ExcelFind(oExcelObject,cDiv_Start)
	cMast_End   = ExcelFind(oExcelObject,cDiv_End)
	If !IsValidStr(cMast_Start) or !IsValidStr(cMast_End) Then && Not find the tag
		Return cReturnValue
	Else
		nRow_Start = Val(ItSubstr(cMast_Start,',',1))
		nRow_End   = Val(ItSubstr(cMast_End,',',1))

		* nFilled_Rows to store all of the the rows behind in the brand default . 
		* It will deduct the child nFilled_Rows when call the child procedure/function.
		nFilled_Rows = nRow_End - nRow_Start + 1
		
		cReturnValue = Alltrim(Str(nFilled_Rows)) + ',' + Alltrim(Str(nDeleted_Rows)) + ',' + Alltrim(Str(nInsert_Rows))
	EndIf
		
	If !IsValidStr(cTableAlias) Then
		cTableAlias = GetAlias()
	EndIf
	If !IsValidStr(cTableAlias) or Select(cTableAlias)=0 Then
		Return cReturnValue 
	EndIf
	
	Local nSelect
	nSelect = Select()
	
	Local cSetkey_Start,cSetkey_End
	Select (cTableAlias) && Use the (cTableAlias) as the current work table.
	cSetkey_Start = Set("Key",1)
	cSetkey_End	  = Set("Key",2)
	
	If IsValidStr(cIndex_TagName) Then
		* If set the index as parameter then set order to the (cIndex_TagName) else use the default index.
		Set Order To (cIndex_TagName) 
	EndIf
			
	If IsValidStr(eSeekExpression) Then
		* Question: But this just can seek string expression and can not include other data types such as number,date,logic and so on.
		If Empty(Order()) Then
			* Table has no index set.
			Select (nSelect)
			Return cReturnValue
		Else
			Set Key To 
			If Seek(eSeekExpression ,cTableAlias) Then
				Set Key To (eSeekExpression)
			Else
				oExcelObject.Rows(Alltrim(Str(nRow_Start))+':'+Alltrim(Str(nRow_End))).Delete			
				nDeleted_Rows = nFilled_Rows
				nFilled_Rows = 0
				cReturnValue = Alltrim(Str(nFilled_Rows)) + ',' + Alltrim(Str(nDeleted_Rows)) + ',' + Alltrim(Str(nInsert_Rows))

				If Empty(cSetkey_Start) and Empty(cSetkey_End) Then
					Set Key To 
				Else
					Set Key To (cSetkey_Start) , (cSetkey_End)
				EndIf
				
				Select (nSelect)
				Return cReturnValue
			EndIf
		EndIf
	EndIf	
	
	If Vartype(nMaxColumns)<>Upper('N') or Int(nMaxColumns)<=0 Then
		nMaxColumns = oExcelObject.ActiveSheet.UsedRange.Columns.Count() + oExcelObject.ActiveSheet.UsedRange.Columns.Column() - 1
	Else
		nMaxColumns = Int(nMaxColumns)
	EndIf	
	
	* Fill the data .
	Local nCurrent_Row,nCurrent_Col,eTmp_Excel_Value,cChild_ReturnValue,nRows_Deleted
	
	oExcelObject.Rows(nRow_Start).Delete
	nRow_End = nRow_End -1
	
	oExcelObject.Rows(nRow_End).Delete
	nRow_End = nRow_End -1

	* nDeleted_Rows to store delete start_row and delete end_tag row ,2 Rows.
	* It will + the child nDeleted_rows when call the child procedure/function.
	nDeleted_Rows = 2
	
	* nFilled_Rows need to deduct the start_tag row and end_tag row ,2 rows.
	nFilled_Rows = nFilled_Rows - 2
	
	oExcelObject.Rows(Alltrim(Str(nRow_Start))+':'+Alltrim(Str(nRow_End))).Select
	Select (cTableAlias)
	nCurrent_Row = nRow_Start
	Do	while nCurrent_Row <= nRow_End
		If nCurrent_Row > nRow_End Then
			Exit
		EndIf
		
		For nCurrent_Col = 1 to nMaxColumns
			eTmp_Excel_Value = oExcelObject.Cells(nCurrent_Row,nCurrent_Col).Value
			If !IsNull(eTmp_Excel_Value) and Type('eTmp_Excel_Value') = Upper('C') Then
				eTmp_Excel_Value = Alltrim(Upper(eTmp_Excel_Value))
				If !InList(eTmp_Excel_Value,Upper('[<'),Upper('<div')) Then
					* If not a value fill expression or brand fill expression.
					Loop
				EndIf
				If eTmp_Excel_Value = Upper('<div') Then
					* Found a nesting '<div' ,Please note this will call 1th ,2th ,3th brand and return 3th ,2th ,1th brand value.
					* Call the child excel fill procedure/function.
					cChild_ReturnValue = Excel_Fill_Div(oExcelObject,'<div','</div>') && Return the console to parent procedure/function (Which procedure/function call it).
					* Note: If Val(ItSubstr(cChild_ReturnValue,',',3)) > 0 Then ;
					*       The last Excel_Fill_Div must be call Excel_Fill_Detail and looped larger than 1.
					
					* ----------------------------------------------------------------------------------------- *					
					nCurrent_Row	= nCurrent_Row  + Val(ItSubstr(cChild_ReturnValue,',',1))
					nCurrent_Row    = nCurrent_Row  - 1 && Because it has called the child Excel_Fill_Div procedure/Function ,So current row has been processed - 1.
					* ----------------------------------------------------------------------------------------- *					
					nRow_End		= nRow_End      - Val(ItSubstr(cChild_ReturnValue,',',2)) && - Deleted Rows
					nRow_End		= nRow_End      + Val(ItSubstr(cChild_ReturnValue,',',3)) && + Inserted Rows
					* ----------------------------------------------------------------------------------------- *									
					oExcelObject.Rows(Alltrim(Str(nCurrent_Row+1))+':'+Alltrim(Str(nRow_End))).Select

					* The parent nFilled_Rows must be deduct child nDeleted_Rows
					nFilled_Rows	= nFilled_Rows  - Val(ItSubstr(cChild_ReturnValue,',',2)) && 1th count the nFilled_Rows ,2th fill the least row(s).
					nFilled_Rows	= nFilled_Rows  + Val(ItSubstr(cChild_ReturnValue,',',3))
					* The parent nInserted_Rows must be + child nInserted_Rows
					nInsert_Rows = nInsert_Rows + Val(ItSubstr(cChild_ReturnValue,',',3))
					* The parent nDeleted_Rows must be + child nDeleted_Rows
					nDeleted_Rows	= nDeleted_Rows + Val(ItSubstr(cChild_ReturnValue,',',2)) && 1th delete the least row(s) if need ,2th count the nDeletede_Row(s)
					
					* Current row has been processed no need to process again ,Just need to exit the column cycle and goto the row cycle.
					Exit
				Else && eTmp_Excel_Value = Upper('[<')					
					nRows_Deleted = ExcelEvaluate(oExcelObject,nCurrent_Row,nCurrent_Col)
					If nRows_Deleted > 0 Then
						* The row(s) has been deleted no need fill data again base on the clolumn loop.
						nRow_End 	  = nRow_End      - nRows_Deleted
						nCurrent_Row  = nCurrent_Row  - nRows_Deleted	
						nDeleted_Rows = nDeleted_Rows + nRows_Deleted
						nFilled_Rows  = nFilled_Rows  - nRows_Deleted
						oExcelObject.Rows(Alltrim(Str(nRow_Start))+':'+Alltrim(Str(nRow_End))).Select
						Exit
					EndIf 
				EndIf
			EndIf
		EndFor
		nCurrent_Row = nCurrent_Row + 1
	EndDo
	
	Select (cTableAlias)
	If Empty(cSetkey_Start) and Empty(cSetkey_End) Then
		Set Key To 
	Else
		Set Key To (cSetkey_Start) , (cSetkey_End)
	EndIf
					
	Select (nSelect)
	
	* nFilled_Rows that means how many row(s) has been filled.
	* nDeleted_Rows that means how many row(s) has been deleted.
	cReturnValue = Alltrim(Str(nFilled_Rows)) + ',' + Alltrim(Str(nDeleted_Rows)) + ',' + Alltrim(Str(nInsert_Rows))
	
	Return cReturnValue
EndProc
*------
Procedure Excel_Fill_Detail
	Lparameters oExcelObject,eSeekExpression,cTableAlias,cIndex_TagName ,;
				cFilterExpression,nMaxColumns,cDiv_Start,cDiv_End
				
	On Error && Test
		
	Local nFilled_Rows,nDeleted_Rows,nInsert_Rows,cReturnValue,cIndex_expression
	nFilled_Rows = 0
	nDeleted_Rows = 0
	nInsert_Rows = 0
	cReturnValue = Alltrim(Str(nFilled_Rows)) + ',' + Alltrim(Str(nDeleted_Rows)) + ',' + Alltrim(Str(nInsert_Rows))
	cIndex_expression = ''
	
	* Check the parameters
	If !IsExcelObject(oExcelObject) Then
		Return cReturnValue
	EndIf
	
	cDiv_Start = DefCharacters(cDiv_Start,'<Detail>') && Default value is '<Detail>'
	cDiv_End   = DefCharacters(cDiv_End, '</Detail>') && Default value is '</Detail>'
	* Count the brand start tag row no and end tag row no.
	Local cDetail_Start,cDetail_End,nRow_Start,nRow_End
	cDetail_Start = ExcelFind(oExcelObject,cDiv_Start)
	cDetail_End   = ExcelFind(oExcelObject,cDiv_End)
	If !IsValidStr(cDetail_Start) or !IsValidStr(cDetail_End) Then && Not find the tag
		Return cReturnValue
	Else
		nRow_Start = Val(ItSubstr(cDetail_Start,',',1))
		nRow_End   = Val(ItSubstr(cDetail_End,',',1))
	
		* nFilled_Rows to store all of the the rows behind in the brand default . 
		* It will deduct the child nFilled_Rows when call the child procedure/function.
		nFilled_Rows = nRow_End - nRow_Start + 1
		
		cReturnValue = Alltrim(Str(nFilled_Rows)) + ',' + Alltrim(Str(nDeleted_Rows)) + ',' + Alltrim(Str(nInsert_Rows))
	EndIf
	
	
	If IsValidStr(cTableAlias) Then
		If Select(cTableAlias) = 0 Then && The alias of 'cTableAlias' not found.
			Return cReturnValue
		EndIf
	Else 
		* No TableAlias set ,Got the TableAlias in the current work area .
		If Empty(Alias()) Then
			Return cReturnValue
		Else
			cTableAlias = Alias()
		EndIf
	EndIf
	
	Local nSelect 
	nSelect = Select()
		
	Local cSetkey_Start,cSetkey_End
	Select (cTableAlias) && Use the (cTableAlias) as the current work table.
	cSetkey_Start = Set("Key",1)
	cSetkey_End	  = Set("Key",2)
	
	If IsValidStr(cIndex_TagName) Then
		* If set the index as parameter then set order to the (cIndex_TagName) else use the default index.
		Set Order To (cIndex_TagName) 
	EndIf
	
	If IsValidStr(eSeekExpression) Then
		* Question: But this just can seek string expression and can not include other data types such as number,date,logic and so on.
		If Empty(Order()) Then
			* Table has no index set.
			Select (nSelect)
			Return cReturnValue
		Else
			Set Key To 
			If Seek(eSeekExpression ,cTableAlias) Then
				Set Key To (eSeekExpression)
			Else
				oExcelObject.Rows(Alltrim(Str(nRow_Start))+':'+Alltrim(Str(nRow_End))).Delete			
				nDeleted_Rows = nFilled_Rows
				nFilled_Rows = 0
				cReturnValue = Alltrim(Str(nFilled_Rows)) + ',' + Alltrim(Str(nDeleted_Rows)) + ',' + Alltrim(Str(nInsert_Rows))
				
				If Empty(cSetkey_Start) and Empty(cSetkey_End) Then
					Set Key To 
				Else
					Set Key To (cSetkey_Start) , (cSetkey_End)
				EndIf
				
				Select (nSelect)
				Return cReturnValue
			EndIf
		EndIf
	EndIf
	
	cFilterExpression = DefCharacters(cFilterExpression,'.T.')
	*!*	Set Filter To Evaluate(cFilterExpression) 
	* Can not set filter to , Because when exit this procedure it will lose this varaible and prompt error message.
	* If the variable of (cFilterExpression) is the public varialbe otherwise can not use Set filter to (cFilterExpression) command.

	* If has used "set key to" command then the "Set filter" will not slowly ,
	* else if the reccount() more large then the speed more slowly.			
		
	If Vartype(nMaxColumns)<>Upper('N') or Int(nMaxColumns)<=0 Then
		nMaxColumns = oExcelObject.ActiveSheet.UsedRange.Columns.Count() + oExcelObject.ActiveSheet.UsedRange.Columns.Column() - 1
	Else
		nMaxColumns = Int(nMaxColumns)
	EndIf
	
	Local nCurrent_Row,nCurrent_Col,nDetail_Rows,eTmp_Excel_Value,cChild_ReturnValue,nDetail_Added,nRows_Deleted			

	oExcelObject.Rows(nRow_Start).Delete
	nRow_End = nRow_End -1
	
	oExcelObject.Rows(nRow_End).Delete
	nRow_End = nRow_End -1	

	 * Store the brand row(s)
	nDetail_Rows = nRow_End - nRow_Start + 1

	* nDeleted_Rows to store delete start_row and delete end_tag row ,2 Rows.
	* It will + the child nDeleted_rows when call the child procedure/function.
	nDeleted_Rows = 2
	
	* nFilled_Rows need to deduct the start_tag row and end_tag row ,2 rows.
	nFilled_Rows = nFilled_Rows - 2
	
	
	* Loop and copy the line in the current sheet
	Select (cTableAlias)
	Scan
		If !Evaluate(cFilterExpression) Then
			Loop
		EndIf
		oExcelObject.Rows(Alltrim(Str(nRow_Start))+':'+Alltrim(Str(nRow_End))).Select
		oExcelObject.Selection.Copy
		oExcelObject.Selection.Insert(-4121) && Down
		oExcelObject.Application.CutCopyMode = .F.
		nFilled_Rows = nFilled_Rows + nDetail_Rows
	EndScan
	oExcelObject.Rows(Alltrim(Str(nRow_Start))+':'+Alltrim(Str(nRow_End))).Delete
	
	* Re-set the nFilled_Rows and nDeleted_Rows
	If nFilled_Rows = nDetail_Rows Then
		* No detail data need to filled and delete all rows(nDetail_Rows) behind in the detail brand.
		nFilled_Rows = 0
		nDeleted_Rows = nDeleted_Rows + nDetail_Rows
	Else
		* The detail row(s) need to looped but need to deduct the 1th detail row(s).
		* because it has been include when the detail row(s) loop and copy.
		nFilled_Rows = nFilled_Rows - nDetail_Rows
		nInsert_Rows = nFilled_Rows - nDetail_Rows
		nRow_End = nRow_Start + nFilled_Rows - 1
	EndIf
	
	* Fill the data in above line table
	Store 0 to nCurrent_Row,nDetail_Added 
	Select (cTableAlias)
	Scan
		If !Evaluate(cFilterExpression) Then
			Loop
		EndIf
		If nDetail_Added = 0 Then && Have not fill any detail brand
			nRow_Start = nRow_Start + (nDetail_Rows * nDetail_Added) && Need to initail the first detail brand row no
		Else
			nRow_Start = nCurrent_Row && nCurrent_Row will save the last row no of the last detail barnd 
		EndIf
		nRow_End = nRow_Start + nDetail_Rows - 1
		oExcelObject.Rows(Alltrim(Str(nRow_Start))+':'+Alltrim(Str(nRow_End))).Select
		nCurrent_Row = nRow_Start
		Do	while nCurrent_Row <= nRow_End
			For nCurrent_Col = 1 to nMaxColumns			
				eTmp_Excel_Value = oExcelObject.Cells(nCurrent_Row,nCurrent_Col).Value
				If !IsNull(eTmp_Excel_Value) and Type('eTmp_Excel_Value') = Upper('C') Then
					eTmp_Excel_Value = Alltrim(Upper(eTmp_Excel_Value))
					If !InList(eTmp_Excel_Value,Upper('[<'),Upper('<div')) Then
						* If not a value fill expression or brand fill expression.
						Loop
					EndIf
					If eTmp_Excel_Value = Upper('<div') Then
						* Found a nesting '<div' ,Please note this will call 1th ,2th ,3th brand and return 3th ,2th ,1th brand value.
						* Call the child excel fill procedure/function.
						cChild_ReturnValue = Excel_Fill_Div(oExcelObject,'<div','</div>') && Return the console to parent procedure/function (Which procedure/function call it).
						* Note: If Val(ItSubstr(cChild_ReturnValue,',',3)) > 0 Then ;
						*       The last Excel_Fill_Div must be call Excel_Fill_Detail and looped larger than 1.
*!*							Set Step On && Test
						* Question: If the excel_fill_div call excel_fill_detail then the nRow_End will error.

						* ----------------------------------------------------------------------------------------- *												
						nCurrent_Row	= nCurrent_Row  + Val(ItSubstr(cChild_ReturnValue,',',1))
						nCurrent_Row    = nCurrent_Row  - 1 && Because it has called the child Excel_Fill_Div procedure/Function ,So current row has been processed - 1.
						* ----------------------------------------------------------------------------------------- *												
						nRow_End		= nRow_End      - Val(ItSubstr(cChild_ReturnValue,',',2)) && Deleted rows.
						nRow_End		= nRow_End      + Val(ItSubstr(cChild_ReturnValue,',',3)) && Inserted rows.
						* ----------------------------------------------------------------------------------------- *						
						*!*	oExcelObject.Rows(Alltrim(Str(nCurrent_Row+1))+':'+Alltrim(Str(nRow_End+1))).Select && In detail brand no need select the next brand range. Because it will auto select it in the top when loop the next brand.
						
						* The parent nFilled_Rows must be deduct child nDeleted_Rows
						nFilled_Rows	= nFilled_Rows - Val(ItSubstr(cChild_ReturnValue,',',2)) && 1th count the nFilled_Rows ,2th fill the least row(s).
						nFilled_Rows	= nFilled_Rows + Val(ItSubstr(cChild_ReturnValue,',',3))
						* The parent nInserted_Rows must be + child nInserted_Rows
						nInsert_Rows = nInsert_Rows + Val(ItSubstr(cChild_ReturnValue,',',3))
						* The parent nDeleted_Rows must be + child nDeleted_Rows
						nDeleted_Rows	= nDeleted_Rows + Val(ItSubstr(cChild_ReturnValue,',',2)) && 1th delete the least row(s) if need ,2th count the nDeletede_Row(s)
						
						* Current row has been processed no need to process again ,Just need to exit the column cycle and goto the row cycle.
						Exit
					Else && eTmp_Excel_Value = Upper('[<')				
						nRows_Deleted = ExcelEvaluate(oExcelObject,nCurrent_Row,nCurrent_Col)
						If nRows_Deleted > 0 Then
							* The row(s) has been deleted no need fill data again base on the clolumn loop.							
							nRow_End 	  = nRow_End      - nRows_Deleted
							nCurrent_Row  = nCurrent_Row  - nRows_Deleted	
							nDeleted_Rows = nDeleted_Rows + nRows_Deleted
							nFilled_Rows  = nFilled_Rows  - nRows_Deleted
							oExcelObject.Rows(Alltrim(Str(nRow_Start))+':'+Alltrim(Str(nRow_End))).Select
							Exit
						EndIf 
					EndIf
				EndIf
			EndFor
			nCurrent_Row = nCurrent_Row + 1
		EndDo
		nDetail_Added = nDetail_Added + 1
	EndScan
	If nCurrent_Row > 0 Then
		oExcelObject.Range('A'+Alltrim(Str(nCurrent_Row))).Select && Goto the detail end row.
	EndIf
	
	Select (cTableAlias)
	If Empty(cSetkey_Start) and Empty(cSetkey_End) Then
		Set Key To 
	Else
		Set Key To (cSetkey_Start) , (cSetkey_End)
	EndIf
	
	Select (nSelect)
					
	* nFilled_Rows that means how many row(s) has been filled.
	* nDeleted_Rows that means how many row(s) has been deleted.
	cReturnValue = Alltrim(Str(nFilled_Rows)) + ',' + Alltrim(Str(nDeleted_Rows)) + ',' + Alltrim(Str(nInsert_Rows))
	
	Return cReturnValue
EndProc
*------
Procedure Excel_Fill_Sheet
	Lparameters oExcelObject,eSeekExpression,cTableAlias,cIndex_TagName ,;
				cSheet_Split_Exp,cSheet_Name_Exp,cFilterExpression ,;
				nMaxColumns,cDiv_Start,cDiv_End
		
	On Error && Test
	
	Local nFilled_Rows,nDeleted_Rows,nInsert_Rows,cReturnValue ,cIndex_expression ,lSplit_Sheet
	nFilled_Rows = 0
	nDeleted_Rows = 0
	nInsert_Rows = 0
	cReturnValue = Alltrim(Str(nFilled_Rows)) + ',' + Alltrim(Str(nDeleted_Rows)) + ',' + Alltrim(Str(nInsert_Rows))
	* ------------ *
	cIndex_expression = ''
	lSplit_Sheet = .F.
	
	* Check the parameters
	If !IsExcelObject(oExcelObject) Then
		Return cReturnValue
	EndIf

	* Checking if need to split sheet
	cSheet_Split_Exp = DefCharacters(cSheet_Split_Exp)
	cSheet_Name_Exp = DefCharacters(cSheet_Name_Exp)	
	* Set the default value for (cSheet_Split_Exp) or (cSheet_Name_Exp) if need.
	If IsValidStr(cSheet_Split_Exp) Then
		* That's means if the (cSheet_Split_Exp) is a valid expression then must need to split sheet no matter the (cSheet_Name_Exp) if a valid expression.
		* If set the avlid split sheet expression then need to check the sheet name if avlid.
		If !IsValidStr(cSheet_Name_Exp) Then
			* If it is not a vliad expression then got the default expression base on index expression. The max lenght of excel sheet name can 
			* include 31 bit characters, This include 20 bit characters means if found a same sheet name will be add AliasName() && 10 bit random name.
			cSheet_Name_Exp = cSheet_Split_Exp
		EndIf
	Else
		* In this case it will not set default value for (cSheet_Name_Exp) ,Just set default value for (cSheet_Split_Exp) .
		* That's means if set a valid parameter for (cSheet_Name_Exp) and table has been order seted, It will split sheet,
		* otherwise will not split sheet.
		* If no set the avlid split sheet expression then got the default index expression.
		If !Empty(Order()) Then
			cSheet_Split_Exp = IndexToExp() && Got the default index expression as the split sheet expression
		EndIf
	EndIf	
	* In the last check if need to split sheet in Excel
	If IsValidStr(cSheet_Split_Exp) and IsValidStr(cSheet_Name_Exp) Then	
		cSheet_Name_Exp = 'ItValidName(' + cSheet_Name_Exp + ')' && Need to delete the special characters. such as \/:*?"<>| default.
		lSplit_Sheet = .T.
	EndIf
	
	If !lSplit_Sheet Then
	* -------------------------------------- No need split per sheet ,Just need fill detail data ----------------------------------- *
		cReturnValue = Excel_Fill_Detail(;
											oExcelObject,eSeekExpression,cTableAlias,cIndex_TagName ,;
											cFilterExpression,nMaxColumns,cDiv_Start,cDiv_End ;
										)
		Return cReturnValue
	* ------------------------------------------------------------------------------------------------------------------------------ *
	EndIf


	* ----------------------------------------------------------------------------------------------------------------------------- *
	*										Need to split per sheet																	*
	* -----------------------------------------------------------------------------------------------------------------------------	*
	* Just set the tag value to '<Detail>' and '</Detail>' default.
	*	Actualy it will call excel_fill_mast() to fill the brand data in the next coding.
	cDiv_Start = DefCharacters(cDiv_Start,'<Detail>') && Default value.
	cDiv_End   = DefCharacters(cDiv_End, '</Detail>') && Default value.
	* Count the brand start tag row no and end tag row no.
	Local cDetail_Start,cDetail_End,nRow_Start,nRow_End
	cDetail_Start = ExcelFind(oExcelObject,cDiv_Start)
	cDetail_End   = ExcelFind(oExcelObject,cDiv_End)
	If !IsValidStr(cDetail_Start) or !IsValidStr(cDetail_End) Then && Not find the tag
		Return cReturnValue
	Else
		nRow_Start = Val(ItSubstr(cDetail_Start,',',1))
		nRow_End   = Val(ItSubstr(cDetail_End,',',1))
	
		* nFilled_Rows to store all of the the rows behind in the brand default . 
		* It will deduct the child nFilled_Rows when call the child procedure/function.
		nFilled_Rows = nRow_End - nRow_Start + 1
		
		cReturnValue = Alltrim(Str(nFilled_Rows)) + ',' + Alltrim(Str(nDeleted_Rows)) + ',' + Alltrim(Str(nInsert_Rows))
	EndIf

	If IsValidStr(cTableAlias) Then
		If Select(cTableAlias) = 0 Then && The alias of 'cTableAlias' not found.
			Return cReturnValue
		EndIf
	Else 
		* No TableAlias set ,Got the TableAlias in the current work area .
		If Empty(Alias()) Then
			Return cReturnValue
		Else
			cTableAlias = Alias()
		EndIf
	EndIf
	
	Local nSelect 
	nSelect = Select()	
	
	Local cSetkey_Start,cSetkey_End
	Select (cTableAlias) && Use the (cTableAlias) as the current work table.
	cSetkey_Start = Set("Key",1)
	cSetkey_End	  = Set("Key",2)
	
	If IsValidStr(cIndex_TagName) Then
		* If set the index as parameter then set order to the (cIndex_TagName) else use the default index.
		Set Order To (cIndex_TagName) 
	EndIf
			
	If IsValidStr(eSeekExpression) Then
		* Question: But this just can seek string expression and can not include other data types such as number,date,logic and so on.
		If Empty(Order()) Then
			* Table has no index set.
			Select (nSelect)
			Return cReturnValue
		Else
			Set Key To 
			If Seek(eSeekExpression ,cTableAlias) Then
				Set Key To (eSeekExpression)
			Else
				oExcelObject.Rows(Alltrim(Str(nRow_Start))+':'+Alltrim(Str(nRow_End))).Delete			
				nDeleted_Rows = nFilled_Rows
				nFilled_Rows = 0
				cReturnValue = Alltrim(Str(nFilled_Rows)) + ',' + Alltrim(Str(nDeleted_Rows)) + ',' + Alltrim(Str(nInsert_Rows))

				If Empty(cSetkey_Start) and Empty(cSetkey_End) Then
					Set Key To 
				Else
					Set Key To (cSetkey_Start) , (cSetkey_End)
				EndIf
				
				Select (nSelect)
				Return cReturnValue
			EndIf
		EndIf
	EndIf
		
	cFilterExpression = DefCharacters(cFilterExpression,'.T.')
	*!*	Set Filter To Evaluate(cFilterExpression) 
	* Can not set filter to , Because when exit this procedure it will lose this varaible and prompt error message.
	* If the variable of (cFilterExpression) is the public varialbe otherwise can not use Set filter to (cFilterExpression) command.

	* If has used "set key to" command then the "Set filter" will not slowly ,
	* else if the reccount() more large then the speed more slowly.		
		
	If Vartype(nMaxColumns)<>Upper('N') or Int(nMaxColumns)<=0 Then
		nMaxColumns = oExcelObject.ActiveSheet.UsedRange.Columns.Count() + oExcelObject.ActiveSheet.UsedRange.Columns.Column() - 1
	Else
		nMaxColumns = Int(nMaxColumns)
	EndIf


	* Copy the detail line and use excel_fill_mast() to fill the data in echo sheet(s) loop.
	Local nCurrent_Sheet,nSheet_Splited,eOld_Split_Exp,eNew_Split_Exp,cChild_ReturnValue,cSheet_ReturnValue
	nCurrent_Sheet = oExcelObject.ActiveSheet.Index		
	nSheet_Splited = 0
	Store null to eOld_Split_Exp,eNew_Split_Exp
	Select (cTableAlias)
	Scan
		If !Evaluate(cFilterExpression) Then
			Loop
		EndIf		
		eNew_Split_Exp = Evaluate(cSheet_Split_Exp)
		If (IsNull(eOld_Split_Exp) and !IsNull(eNew_Split_Exp)) or;
		   !(eOld_Split_Exp == eNew_Split_Exp) Then
			
			* Found a new split sheet expression and create a new sheet in ExcelObject
			oExcelObject.Sheets(nCurrent_Sheet).Copy(,oExcelObject.Sheets(oExcelObject.ActiveSheet.Index))
			
			* Rename the new sheet name
			Local cOn_Error,lErrored
			cOn_Error = On('Error')
			lErrored = .F.
			On Error lErrored = .T.
			oExcelObject.ActiveSheet.Name = Alltrim(Leftc(Evaluate(cSheet_Name_Exp),25))
			If lErrored Then
				Local nSheetName_Tag
				For nSheetName_Tag = 2 to 255
					lErrored = .F.
					oExcelObject.ActiveSheet.Name = Alltrim(Leftc(Evaluate(cSheet_Name_Exp),25)) + ;
													Space(1) + '(' + Alltrim(Str(nSheetName_Tag)) + ')'
					If !lErrored Then
						Exit
					EndIf
				EndFor
				If lErrored Then
					* Larger then 255
					oExcelObject.ActiveSheet.Name = Alltrim(Leftc(Evaluate(cSheet_Name_Exp),20)) + ;
													AliasName()
					lErrored = .F.
				EndIf
			EndIf
			On Error &cOn_Error. && Restore the on error command
				
			nSheet_Splited = nSheet_Splited + 1				
			eOld_Split_Exp = eNew_Split_Exp
			
			cChild_ReturnValue	= Excel_Fill_Mast(oExcelObject, ,cTableAlias, ,nMaxColumns,cDiv_Start,cDiv_End)
			cSheet_ReturnValue = cChild_ReturnValue
			If nSheet_Splited = 1 Then
				* Just need to return value in the first loopp sheet.
				cReturnValue = cChild_ReturnValue
			EndIf
		Else
			* Loop and copy the line in the current sheet
			oExcelObject.Sheets(nCurrent_Sheet).Select
			oExcelObject.Rows(Alltrim(Str(nRow_Start))+':'+Alltrim(Str(nRow_End))).Select
			oExcelObject.Selection.Copy
			
			oExcelObject.Sheets(nCurrent_Sheet + nSheet_Splited).Select
			oExcelObject.Rows(Alltrim(Str(nRow_Start + Val(ItSubstr(cSheet_ReturnValue,',',1))))).Select
			oExcelObject.Selection.Insert(-4121) && Down
			oExcelObject.Application.CutCopyMode = .F.
			
			cChild_ReturnValue	= Excel_Fill_Mast(oExcelObject, ,cTableAlias, ,nMaxColumns,cDiv_Start,cDiv_End)
			cSheet_ReturnValue  = Alltrim(Str(		Val(ItSubstr(cSheet_ReturnValue,',',1)) + Val(ItSubstr(cChild_ReturnValue,',',1)) 	));
						   		  + ',' + ;
						  		  Alltrim(Str( 	Val(ItSubstr(cSheet_ReturnValue,',',2)) + Val(ItSubstr(cChild_ReturnValue,',',2)) 	))
			If nSheet_Splited = 1 Then
				* Just need to return value in the first loop sheet.
				cReturnValue = cSheet_ReturnValue
			EndIf
		EndIf
	EndScan
	
	If nSheet_Splited >= 1 Then
		oExcelObject.Sheets(nCurrent_Sheet).Select
		oExcelObject.DisplayAlerts = .F.
		
		oExcelObject.ActiveSheet.Delete
		oExcelObject.DisplayAlerts = .T.
	EndIf
	* For split echo sheet completed.	
		
	Select (cTableAlias)
	If Empty(cSetkey_Start) and Empty(cSetkey_End) Then
		Set Key To 
	Else
		Set Key To (cSetkey_Start) , (cSetkey_End)
	EndIf
	
	Select (nSelect)	
	
	Return cReturnValue
EndProc	
*------
Procedure Excel_Fill_Div
	Lparameters oExcelObject,cDiv_Start,cDiv_End
	
	* Desc: This can fill a full nesting brand in the sheet.
	
	Local nFilled_Rows,nDeleted_Rows,nInsert_Rows,cReturnValue
	nFilled_Rows = 0
	nDeleted_Rows = 0
	nInsert_Rows = 0
	cReturnValue = Alltrim(Str(nFilled_Rows)) + ',' + Alltrim(Str(nDeleted_Rows)) + ',' + Alltrim(Str(nInsert_Rows))
	
	* Check the parameters
	If !IsExcelObject(oExcelObject) Then
		Return cReturnValue
	EndIf
		
	cDiv_Start	= DefCharacters(cDiv_Start,'<div')
	cDiv_End	= DefCharacters(cDiv_End,'</div>')
	
	* Fill the data .
	Local cCell_Start,cCell_End,nCount_Start,nCount_End
	cCell_Start = ExcelFind(oExcelObject,cDiv_Start)
	cCell_End   = ExcelFind(oExcelObject,cDiv_End)
	If !IsValidStr(cCell_Start) or !IsValidStr(cCell_End) Then && Not find the tag
		Return cReturnValue
	Else
		* Check if has the nesting '<div' and '</div>' between cDiv_Start and cDiv_End.
		oExcelObject.Rows(ItSubstr(cCell_Start,',',1)+':'+ItSubstr(cCell_End,',',1)).Select
		nCount_Start = ExcelFindCount(oExcelObject,cDiv_Start)
		oExcelObject.Rows(ItSubstr(cCell_Start,',',1)+':'+ItSubstr(cCell_End,',',1)).Select
		nCount_End   = ExcelFindCount(oExcelObject,cDiv_End)
		
		Do while nCount_Start > nCount_End
			* Found the nesting '<div' between cDiv_Start and cDiv_End ,Re-count the (cCell_End) value.
			oExcelObject.Cells(Val(ItSubstr(cCell_End,',',1)),Val(ItSubstr(cCell_End,',',2))).Activate
				
			* Skip the next (cDiv_End)
			oExcelObject.Cells.Find(cDiv_End,oExcelObject.ActiveCell,-4123,2,1,1,.F.,.F.,.F.).Activate
			cCell_End  = Alltrim(Str(oExcelObject.ActiveCell.Row))+','+Alltrim(Str(oExcelObject.ActiveCell.Column))
			nCount_End = nCount_End + 1		
			
			oExcelObject.Rows(ItSubstr(cCell_Start,',',1)+':'+ItSubstr(cCell_End,',',1)).Select
			nCount_Start = ExcelFindCount(oExcelObject,cDiv_Start)					
		EndDo
	EndIf
	
	Local nRow_Start,nCol_Start,nRow_End,nCol_End
	nRow_Start = Val(ItSubstr(cCell_Start,',',1))
	nCol_Start = Val(ItSubstr(cCell_Start,',',2))
	nRow_End   = Val(ItSubstr(cCell_End,',',1))	
	nCol_End   = Val(ItSubstr(cCell_End,',',2))
	
	Local nCurrent_Sheet_Index,cDiv_Start_Value,cDiv_Tag,cDiv_ID, ;
		  eSeekExpression,cTableAlias,cIndex_TagName,cSheet_Split_Exp,cSheet_Name_Exp, ;
		  cFilterExpression		  
		
	nCurrent_Sheet_Index = oExcelObject.ActiveSheet.Index
	oExcelObject.Cells(nRow_Start,nCol_Start).Activate
	
	cDiv_Start_Value = Alltrim(oExcelObject.ActiveCell.Value)
	cDiv_Start_Value = Leftc(cDiv_Start_Value,Lenc(cDiv_Start_Value)-1) && Delete the right '>'
	cDiv_Tag   = Iif(Rightc(cDiv_Start_Value,1)=';',cDiv_Start_Value,cDiv_Start_Value + ';')
		
	cDiv_ID				= ItSubstr(GetTagWord(cDiv_Tag,'ID',1,';'),'=',2)
	eSeekExpression 	= ItSubstr(GetTagWord(cDiv_Tag,'SeekExp',1,';'),'=',2)
	cTableAlias 		= ItSubstr(GetTagWord(cDiv_Tag,'TableAlias',1,';'),'=',2)
	cIndex_TagName 		= ItSubstr(GetTagWord(cDiv_Tag,'Index',1,';'),'=',2)
	cSheet_Split_Exp 	= ItSubstr(GetTagWord(cDiv_Tag,'SheetExp',1,';'),'=',2)
	cSheet_Name_Exp		= ItSubstr(GetTagWord(cDiv_Tag,'SheetName',1,';'),'=',2)
	cFilterExpression 	= ItStrextract(GetTagWord(cDiv_Tag,'FilterExp',1,';'),'=')

	cDiv_ID 			= Iif(Empty(cDiv_ID),cDiv_ID,Evaluate(cDiv_ID))
	eSeekExpression 	= Iif(Empty(eSeekExpression),eSeekExpression,Evaluate(eSeekExpression))
	cTableAlias 		= Iif(Empty(cTableAlias),cTableAlias,Evaluate(cTableAlias))
	cIndex_TagName 		= Iif(Empty(cIndex_TagName),cIndex_TagName,Evaluate(cIndex_TagName))
	*cSheet_Split_Exp 	= Iif(Empty(cSheet_Split_Exp),cSheet_Split_Exp,Evaluate(cSheet_Split_Exp))
	*cSheet_Name_Exp 	= Iif(Empty(cSheet_Name_Exp),cSheet_Name_Exp,Evaluate(cSheet_Name_Exp))
	cFilterExpression 	= Iif(Empty(cFilterExpression),cFilterExpression,Evaluate(cFilterExpression))
				
	If !InList(Upper(cDiv_ID),Upper("Mast"),Upper("Detail")) Then
		* Can not ignore the div id keyword ,Comment it in Excel file.			
		Local cErrorMessage	
					
		* Comment in div start as tag "<div" .
		* Current activecell is the start tag ,No need to local again.
		If IsNull(oExcelObject.ActiveCell.Comment) Then
			oExcelObject.ActiveCell.AddComment(oExcelObject.ActiveCell.Value)
		Else
			oExcelObject.ActiveCell.Comment.Text(oExcelObject.ActiveCell.Comment.Text + ;
											Chr(13)+Chr(10)+ ;
											oExcelObject.ActiveCell.Value)
		EndIf
		cErrorMessage = '<Error:div' + Rightc(cDiv_Start_Value,Lenc(cDiv_Start_Value)-4) + '>'
		oExcelObject.ActiveCell.Value = cErrorMessage				

		* Comment in div end as tag "</div>" .				
		oExcelObject.Cells(nRow_End,nCol_End).Activate && Local the end tag
				
		If IsNull(oExcelObject.ActiveCell.Comment) Then
			oExcelObject.ActiveCell.AddComment(oExcelObject.ActiveCell.Value)
		Else
			oExcelObject.ActiveCell.Comment.Text(oExcelObject.ActiveCell.Comment.Text + ;
											Chr(13)+Chr(10)+ ;
											oExcelObject.ActiveCell.Value)
		EndIf				
		cErrorMessage = '</Error:div>'
		oExcelObject.ActiveCell.Value = cErrorMessage
		
		* Restore the start tag position ,Because it maybe the nesting '<div' and '</div>'.
		oExcelObject.Cells(nRow_Start,nCol_Start).Activate		
	Else 
		Local nTagStart_Row,nTagStart_Column,;
			  nMaxColumns,cTag_Start,cTag_End
		
		nTagStart_Row 		= oExcelObject.ActiveCell.Row
		nTagStart_Column	= oExcelObject.ActiveCell.Column
		nMaxColumns		    = oExcelObject.ActiveSheet.UsedRange.Columns.Count() + oExcelObject.ActiveSheet.UsedRange.Columns.Column() - 1
		
		If Upper(cDiv_ID) = Upper("Mast") Then
			* Replace the tag value to <Mast> and </Mast>
			cTag_Start = '<Mast>'
			oExcelObject.ActiveCell.Value = cTag_Start 
			
			oExcelObject.Cells(nRow_End,nCol_End).Activate && Local the end tag
			cTag_End = '</Mast>'
			oExcelObject.ActiveCell.Value = cTag_End
			
			oExcelObject.Cells(nTagStart_Row,nTagStart_Column).Select
			
			* Fill the mast value
			cReturnValue = Excel_Fill_Mast(;
												oExcelObject,eSeekExpression,cTableAlias,cIndex_TagName ,;
												nMaxColumns,cTag_Start,cTag_End;
										   )
		Else
			* Replace the tag value to <Detail> and </Detail>
			cTag_Start = '<Detail>'
			oExcelObject.ActiveCell.Value = cTag_Start 
			
			oExcelObject.Cells(nRow_End,nCol_End).Activate && Local the end tag
			cTag_End = '</Detail>'
			oExcelObject.ActiveCell.Value = cTag_End
			
			oExcelObject.Cells(nTagStart_Row,nTagStart_Column).Select
			
			* Fill the detail value
			cReturnValue = Excel_Fill_Sheet(;
												oExcelObject,eSeekExpression,cTableAlias,cIndex_TagName ,;
												cSheet_Split_Exp,cSheet_Name_Exp,cFilterExpression ,;
												nMaxColumns,cTag_Start,cTag_End;
											)
		EndIf
	EndIf
	
	Return cReturnValue
EndProc	
*------
Procedure Excel_Fill_Data
	Lparameters oExcelObject
	
	* Its the entry point of module of excel fill data .
	* This can fill data in each sheet.
	
	* Check the parameters
	If !IsExcelObject(oExcelObject) Then
		Return .F.
	EndIf

	Local nTag_Sheet,nCurrent_Sheet_Index,cDiv_Start,cDiv_End	  		  		  
	nTag_Sheet				= 0
	nCurrent_Sheet_Index	= oExcelObject.ActiveSheet.Index
	cDiv_Start 	= DefCharacters(cDiv_Start,'<div')
	cDiv_End   	= DefCharacters(cDiv_End,'</div>')
	
	Do	while .T.
		nTag_Sheet = nTag_Sheet + 1
		oExcelObject.Sheets(nTag_Sheet).Select	
				
		oExcelObject.Range('A1').Select
		* Checking the cDiv_Start count if not equal cDiv_End count.
		If ExcelFindCount(oExcelObject,cDiv_Start) <> ExcelFindCount(oExcelObject,cDiv_End) Then
			* Not equal ,Nesting error.
			Loop
		EndIf
				
		oExcelObject.Range('A1').Select 
		* Actualy no need to select Range('A1') cell ,Because ExcelFindCount().
		* Because it will restore the activate cell position before exit module when call ExcelFindCount() procedure/function.
		Do	While !Empty(ExcelFind(oExcelObject,cDiv_Start)) and !Empty(ExcelFind(oExcelObject,cDiv_End,.T.)) && Found the tag		
			Excel_Fill_Div(oExcelObject,cDiv_Start,cDiv_End) && This can fill a full nesting cDiv_Start and cDiv_End brand.							 
		EndDo		
		* Activate the top cell in echo sheet 
		* Actualy no need to re-activate the current sheet in excel .Because it will auto re-activate the current sheet before the child
		* 	procedure/function exit ,despite the child procedure/function call the excel_fill_sheet and it has been splited the sheet(s).
		oExcelObject.Sheets(nTag_Sheet).Select
		oExcelObject.Range('A1').Select
		
		If nTag_Sheet >= oExcelObject.Sheets.Count Then
			* Active the current sheet	
			oExcelObject.Sheets(nCurrent_Sheet_Index).Select
			Exit
		EndIf
	EndDo	
		
	Return .T.
EndProc
*------
Procedure OpenDataEnvironment
	Lparameters cScreen_ID
	
	Local nSelect,;
			cTable_Mast,cAlias_Mast,cIndex_Mast,cIndex_Mast_Exp ,;
			cTable_Dtl ,cAlias_Dtl ,cIndex_Dtl ,cIndex_Dtl_Exp  ,;
			cTable_Bom ,cAlias_Bom ,cIndex_Bom ,;
			cTable_Snc ,cAlias_Snc ,cIndex_Snc 
	
	If !IsValidStr(cScreen_ID) Then
		MessageBox('Please set the document type first.',0+48,'Warning')
		Return .T.
	Else
		cScreen_ID = Alltrim(Upper(cScreen_ID))
		If !InList(cScreen_ID,Upper('QUOT'),Upper('PROF'),Upper('INVOICE'),Upper('PACKLIST'),Upper('CDN'),Upper('PO'),Upper('SDN')) Then
			MessageBox('Please set the document include in the list.'+Chr(13)+;
						Replicate('-',44)+Chr(13)+;
						Upper('QUOT')+Chr(13)+;
						Upper('PROF')+Chr(13)+;
						Upper('INVOICE')+Chr(13)+;
						Upper('PACKLIST')+Chr(13)+;
						Upper('CDN')+Chr(13)+;
						Upper('PO')+Chr(13)+;
						Upper('SDN'),;
						0+48,'Warning')
			Return .F.
		Else
			nSelect = Select()
			Do	Case
			Case cScreen_ID = Upper('QUOT') 
				cTable_Mast	= 'Quotmast'
				cIndex_Mast	= 'Quot_ID'
				cTable_Dtl	= 'Quotdtl'
	            cIndex_Dtl	= 'Order_ID'
	            cTable_Bom	= 'Quotbom'
	            cIndex_Bom	= 'Order_ID'
	           	cTable_Snc	= 'Quotsnc'
	           	cIndex_Snc	= 'Order_ID'
			Case cScreen_ID = Upper('PROF')
				cTable_Mast = 'Somast'
				cIndex_Mast = 'So_ID'
				cTable_Dtl	= 'Sodtl'
				cIndex_Dtl 	= 'Order_ID'
				cTable_Bom 	= 'Sobom'
				cIndex_Bom 	= 'Order_ID'
				cTable_Snc 	= 'Sosnc'
				cIndex_Snc 	= 'Order_ID'
			Case cScreen_ID = Upper('INVOICE')
				cTable_Mast = 'Invmast'
				cIndex_Mast = 'Inv_ID'
				cTable_Dtl 	= 'Invdtl'
				cIndex_Dtl 	= 'Order_ID'
				cTable_Bom 	= 'Invbom'
				cIndex_Bom 	= 'Order_ID'
				cTable_Snc 	= 'Invsnc'
				cIndex_Snc 	= 'Order_ID'
			Case cScreen_ID = Upper('PACKLIST')
				cTable_Mast = 'Invmast'
				cIndex_Mast = 'Inv_ID'
				cTable_Dtl 	= 'Packlst'
				cIndex_Dtl 	= 'Order_ID'
				cTable_Bom 	= 'Packbom'
				cIndex_Bom 	= 'Order_ID'
				cTable_Snc 	= 'Packsnc'
				cIndex_Snc 	= 'Order_ID'
			Case cScreen_ID = Upper('CDN')
				cTable_Mast = 'Cdnmast'
				cIndex_Mast = 'Cdn_ID'
				cTable_Dtl 	= 'Cdndtl'
				cIndex_Dtl 	= 'Order_ID'
				cTable_Bom 	= 'Cdnbom'
				cIndex_Bom 	= 'Order_ID'
				cTable_Snc 	= 'Cdnsnc'
				cIndex_Snc 	= 'Order_ID'
			Case cScreen_ID = Upper('PO')
				cTable_Mast = 'Pomast'
				cIndex_Mast = 'Po_ID'
				cTable_Dtl 	= 'Podtl'
				cIndex_Dtl 	= 'Order_ID'
				cTable_Bom 	= 'Pobom'
				cIndex_Bom 	= 'Order_ID'
				cTable_Snc 	= 'Posnc'
				cIndex_Snc 	= 'Order_ID'
			Case cScreen_ID = Upper('SDN')
				cTable_Mast = 'Sdnmast'
				cIndex_Mast = 'Sdn_ID'
				cTable_Dtl 	= 'Sdndtl'
				cIndex_Dtl 	= 'Order_ID'
				cTable_Bom 	= 'Sdnbom'
				cIndex_Bom 	= 'Order_ID'
				cTable_Snc 	= 'Sdnsnc'
				cIndex_Snc 	= 'Order_ID'
			EndCase
			cAlias_Mast = cTable_Mast + 'R'
			cAlias_Dtl  = cTable_Dtl  + 'R'
			cAlias_Bom	= cTable_Bom  + 'R'
			cAlias_Snc  = cTable_Snc  + 'R'
		EndIf
	EndIf

	* Open the mast table.
	If LcDbfOpen(cTable_Mast,cAlias_Mast,.F.,cIndex_Mast) Then
		Select (cAlias_Mast)
		cIndex_Mast_Exp = IndexToExp()
		* Seek and set key .
		If Vartype(Dv1_fm)<>Upper('U') Then
			= Seek(Dv1_fm,cAlias_Mast,cIndex_Mast)
			If Vartype(Dv1_to)<>Upper('U') Then
				Set Key To dv1_fm,dv1_to
			Else
				Set Key To Dv1_fm
			EndIf
		EndIf
		
		* Open the detail table.
		If LcDbfOpen(cTable_Dtl ,cAlias_Dtl,.F.,cIndex_Dtl) Then
			Select (cAlias_Dtl)
			cIndex_Dtl_Exp = IndexToExp()
			* Seek and set key .
			If Vartype(Dv1_fm)<>Upper('U') Then
				= Seek(Dv1_fm,cAlias_Dtl,cIndex_Dtl)
				If Vartype(Dv1_to)<>Upper('U') Then
					Set Key To dv1_fm,dv1_to
				Else
					Set Key To Dv1_fm
				EndIf
			EndIf
			
			* Set relation into child cTableAlias (cAlias_Dtl)
			Select (cAlias_Mast)
			Set Relation to &cIndex_Mast_Exp. into (cAlias_Dtl) Additive
			
			* Open the bom table.
			If LcDbfOpen(cTable_Bom,cAlias_Bom,.F.,cIndex_Bom) Then
				* Seek and set key .
				If Vartype(Dv1_fm)<>Upper('U') Then
					Select (cAlias_Bom)
					= Seek(Dv1_fm,cAlias_Bom,cIndex_Bom)
					If Vartype(Dv1_to)<>Upper('U') Then
						Set Key To dv1_fm,dv1_to
					Else
						Set Key To Dv1_fm
					EndIf
				EndIf
				
				* Set relation into child cTableAlias (cAlias_Bom)
				Select (cAlias_Dtl)
				Set Relation to &cIndex_Dtl_Exp. into (cAlias_Bom) Additive
			EndIf
			
			* Open the size and color table.
			If LcDbfOpen(cTable_Snc,cAlias_Snc,.F.,cIndex_Snc) Then
				* Seek and set key .
				If Vartype(Dv1_fm)<>Upper('U') Then
					Select (cAlias_Snc)
					= Seek(Dv1_fm,cAlias_Snc,cIndex_Snc)
					If Vartype(Dv1_to)<>Upper('U') Then
						Set Key To dv1_fm,dv1_to
					Else
						Set Key To Dv1_fm
					EndIf
				EndIf

				* Set relation into child cTableAlias (cAlias_Snc)
				Select (cAlias_Dtl)
				Set Relation to &cIndex_Dtl_Exp. into (cAlias_Snc) Additive
			EndIf
		Endif
	EndIf
		

	* Connect the relationshipment table for (cAlias_Mast).
	
	* -------------- For Mast (cAlias_Mast) ------------------ *
	If Select(cAlias_Mast) >0 and IsFieldExist('Customer_ID',cAlias_Mast) and LcDbfOpen('Customer','CustomerR',.F.,'Customer_I') Then
		Select (cAlias_Mast)
		Set Relation to Upper(ltrim(customer_id)) into CustomerR Additive
	EndIf
	If Select(cAlias_Mast) >0 and IsFieldExist('Supplier_ID',cAlias_Mast) and LcDbfOpen('Supplier','SupplierR',.F.,'Supplier_I') Then
		Select (cAlias_Mast)
		Set Relation to Upper(ltrim(supplier_id)) into SupplierR Additive
	EndIf
	If Select(cAlias_Mast) >0 and IsFieldExist('Employee_ID',cAlias_Mast) and LcDbfOpen('Employee','EmployeeR',.F.,'Employee_I') Then
		Select (cAlias_Mast)
		Set Relation to Upper(ltrim(employee_id)) into EmployeeR Additive
	EndIf		
	If Select(cAlias_Mast) >0 and IsFieldExist('Agent_ID',cAlias_Mast) and LcDbfOpen('Agent','AgentR',.F.,'Agent_ID') Then
		Select (cAlias_Mast)
		Set Relation to Upper(ltrim(agent_id)) into AgentR Additive
	EndIf
	If Select(cAlias_Mast) >0 and IsFieldExist('Bank_ID',cAlias_Mast) and LcDbfOpen('Bank','BankR',.F.,'Bank_ID') Then
		Select (cAlias_Mast)
		Set Relation to Upper(ltrim(bank_id)) into BankR Additive
	EndIf
	If Select(cAlias_Mast) >0 and IsFieldExist('Shipper_ID',cAlias_Mast) and LcDbfOpen('Shippers','ShippersR',.F.,'Shipper_ID') Then
		Select (cAlias_Mast)
		Set Relation to Upper(Ltrim(Shipper_ID)) into ShippersR Additive
	EndIf
	If Select(cAlias_Mast) >0 and IsFieldExist('Ship_From',cAlias_Mast) and LcDbfOpen('Country','Country_Ship_FromR',.F.,'Code') Then
		Select (cAlias_Mast)
		Set Relation to Upper(Ship_From) into Country_Ship_FromR additive
	EndIf
	If Select(cAlias_Mast) >0 and IsFieldExist('Ship_To',cAlias_Mast) and LcDbfOpen('Country','Country_Ship_ToR',.F.,'Code') Then
		Select (cAlias_Mast)
		Set Relation to Upper(Ship_To) into Country_Ship_ToR Additive
	EndIf
	If Select(cAlias_Mast) >0 and IsFieldExist('Pay_By',cAlias_Mast) and LcDbfOpen('Terms','TermsR',.F.,'Code') Then
		Select (cAlias_Mast)
		Set Relation to Upper(Pay_By) into TermsR Additive
	EndIf
	
	
	* -------------- For DTL (cAlias_Dtl) ------------------ *
	If Select(cAlias_Dtl)>0 and IsFieldExist('Product_ID',cAlias_Dtl) Then
		* Relation the products for (cAlias_Dtl)
		If LcDbfOpen('Products','ProductsR',.F.,'Product_ID') Then
			Select (cAlias_Dtl)
			Set Relation to Upper(Product_ID) into ProductsR Additive

			* Relation the photos for (cAlias_Dtl)
			If LcDbfOpen('Photos','PhotosR',.F.,'Order_ID') Then
				Select ProductsR
				Set Relation to Upper(Product_ID) into PhotosR Additive
			EndIf
		EndIf
	EndIf	
	
	* -------------- For BOM (cAlias_Bom) ------------------ *
	If Select(cAlias_Bom)>0 and IsFieldExist('Product_ID',cAlias_Bom) Then
		* Relation the products for (cAlias_Bom)
		If LcDbfOpen('Products','Products_BomR',.F.,'Product_ID') Then
			Select (cAlias_Bom)
			Set Relation to Upper(Product_id) into Products_BomR Additive
			
			* Relation the photos for (cAlias_Bom)
			If LcDbfOpen('Photos','Photos_BomR',.F.,'Order_ID') Then
				Select Products_BomR
				Set Relation to Upper(Product_ID) into Photos_BomR Additive
			EndIf
		EndIf
	EndIF
	
	* -------------- For SNC (cAlias_Snc) ------------------ *
	If Select(cAlias_Snc)>0 and IsFieldExist('Product_ID',cAlias_Snc) Then
		* Relation the products for (cAlias_Snc)
		If LcDbfOpen('Products','Products_SncR',.F.,'Product_ID') Then
			Select (cAlias_Snc)
			Set Relation to Upper(Product_id) into Products_SncR Additive
			
			* Relation the photos for (cAlias_Snc)
			If LcDbfOpen('Photos','Photos_SncR',.F.,'Order_ID') Then
				Select Products_SncR
				Set Relation to Upper(Product_ID) into Photos_SncR Additive
			EndIf
		EndIf
	EndIf
		
	Select(nSelect)

	Return .T.
EndProc
*------
Procedure CloseDataEnvironment
	Lparameters cScreen_ID
	
	If !IsValidStr(cScreen_ID) Then
		MessageBox('Please set the document type first.',0+48,'Warning')
		Return .T.
	Else
		cScreen_ID = Alltrim(Upper(cScreen_ID))
		If !InList(cScreen_ID,Upper('QUOT'),Upper('PROF'),Upper('INVOICE'),Upper('PACKLIST'),Upper('CDN'),Upper('PO'),Upper('SDN')) Then
			MessageBox('Please set the document include in the list.'+Chr(13)+;
						Replicate('-',44)+Chr(13)+;
						Upper('QUOT')+Chr(13)+;
						Upper('PROF')+Chr(13)+;
						Upper('INVOICE')+Chr(13)+;
						Upper('PACKLIST')+Chr(13)+;
						Upper('CDN')+Chr(13)+;
						Upper('PO')+Chr(13)+;
						Upper('SDN'),;
						0+48,'Warning')
			Return .F.
		Else
			Local cAlias_Mast ,cAlias_Dtl ,cAlias_Bom ,cAlias_Snc
			
			Do	Case
			Case cScreen_ID = Upper('QUOT') 
				cAlias_Mast = 'Quotmast'
				cAlias_Dtl 	= 'Quotdtl'
	           	cAlias_Bom  = 'Quotbom'
	           	cAlias_Snc  = 'Quotsnc'
			Case cScreen_ID = Upper('PROF')
				cAlias_Mast = 'Somast'
				cAlias_Dtl 	= 'Sodtl'
				cAlias_Bom  = 'Sobom'
				cAlias_Snc  = 'Sosnc'
			Case cScreen_ID = Upper('INVOICE')
				cAlias_Mast = 'Invmast'
				cAlias_Dtl 	= 'Invdtl'
				cAlias_Bom  = 'Invbom'
				cAlias_Snc  = 'Invsnc'
			Case cScreen_ID = Upper('PACKLIST')
				cAlias_Mast = 'Invmast'
				cAlias_Dtl 	= 'Packlst'
				cAlias_Bom  = 'Packbom'
				cAlias_Snc  = 'Packsnc'
			Case cScreen_ID = Upper('CDN')
				cAlias_Mast = 'Cdnmast'
				cAlias_Dtl 	= 'Cdndtl'
				cAlias_Bom  = 'Cdnbom'
				cAlias_Snc  = 'Cdnsnc'
			Case cScreen_ID = Upper('PO')
				cAlias_Mast = 'Pomast'
				cAlias_Dtl 	= 'Podtl'
				cAlias_Bom  = 'Pobom'
				cAlias_Snc  = 'Posnc'
			Case cScreen_ID = Upper('SDN')
				cAlias_Mast = 'Sdnmast'
				cAlias_Dtl	= 'Sdndtl'
				cAlias_Bom  = 'Sdnbom'
				cAlias_Snc  = 'Sdnsnc'
			EndCase
			
			cAlias_Mast = cAlias_Mast + 'R'
			cAlias_Dtl 	= cAlias_Dtl  + 'R'
           	cAlias_Bom  = cAlias_Bom  + 'R' 
           	cAlias_Snc  = cAlias_Snc  + 'R'
		EndIf
	EndIf
	
	Local nSelect
	nSelect = Select()

	LcDbfClose('Photos_SncR')
	LcDbfClose('Products_SncR')
	LcDbfClose(cAlias_Snc)
	
	LcDbfClose('Photos_BomR')
	LcDbfClose('Products_BomR')
	LcDbfClose(cAlias_Bom)

	LcDbfClose('PhotosR')
	LcDbfClose('ProductsR')
	LcDbfClose(cAlias_Dtl)
		
	LcDbfClose('CustomerR')
	LcDbfClose('SupplierR')
	LcDbfClose('EmployeeR')
	LcDbfClose('AgentR')
	LcDbfClose('BankR')
	LcDbfClose('ShippersR')
	LcDbfClose('Country_Ship_FromR')
	LcDbfClose('Country_Ship_ToR')
	LcDbfClose('TermsR')
	LcDbfClose(cAlias_Mast)
	
	Select (nSelect)
	
	Return .T.
EndProc
*------
Procedure BuildExcel
	Lparameters cExcelFile

	Local oExcel,cExcelSourceFile,cExcelOutputFile

	If Parameters() = 0 Then
		If IsValidStr(lrExcelFile) and File(lrExcelFile) Then
			cExcelSourceFile = LocFile(lrExcelFile)
		Else	
			MessageBox('No Excel template file found.',0+48,'Warning')
			Return .F.
		EndIf
	Else
		If IsValidStr(cExcelFile) and File(cExcelFile) Then
			cExcelSourceFile = LocFile(cExcelFile)
		Else
			MessageBox('Excel template file not found.',0+48,'Warning')
			Return .F.
		EndIf
	EndIf
			
	oExcel = CreateExcel()
	If !IsExcelObject(oExcel) Then
		Release oExcel
		MessageBox('Excel not installed or configure failed.',0+48,'Warning')
		Return .F.
	EndIf	

	cExcelOutputFile = ForcePath(ForceExt(AliasName(),JustExt(cExcelSourceFile)),GetEnv("TEMP"))
	If !ItCopyFile(cExcelSourceFile ,cExcelOutputFile ,.T.) Then
		MessageBox('Can not copy the template file .',0+48,'Warning')
		Return .F.
	EndIf
	oExcel.WorkBooks.Open(cExcelOutputFile)

	* Fill the data in echo sheet(s) now .
	Excel_Fill_Data(oExcel)

	oExcel.Visible = .T.
	oExcel.Visible = .F.
	MessageBox('Document generate completed.',0+64,'Message')
	Wait Clear
	oExcel.Range('A1').Select
	oExcel.Visible = .T.
	Release oExcel
	*SendKey("%{TAB}")
	Return .T. && The end
EndProc
*------
Procedure StringIncrease
	Lparameters cString,nIncreaseValue,lMatchUpper && nIncreaseValue can not larger than 1, else can not return the correct value.
		
	cString = Alltrim(DefCharacters(cString))
	nIncreaseValue = DefNumber(nIncreaseValue,1)
	lMatchUpper = DefLogic(lMatchUpper)
	If ! lMatchUpper Then
		cString = Upper(cString)
	EndIf
	
	Local cReturnValue,cString_Left,cString_Right_Bit,nTmpAsc_Right
	cReturnValue = cString
	cString_Left = Left(cString,Len(cString)-1)
	cString_Right_Bit = Right(cString,1)
	
	nTmpAsc_Right = Asc(cString_Right_Bit)
	If Between(nTmpAsc_Right,Asc('0'),Asc('9')) or;
	   Between(nTmpAsc_Right,Asc(Upper('A')),Asc(Upper('Z'))) or ;
	   Between(nTmpAsc_Right,Asc(Lower('a')),Asc(Lower('z'))) Then
	   If lMatchUpper Then
			Do	Case
			Case Between(nTmpAsc_Right,Asc('0'),Asc('9'))
				If nTmpAsc_Right = Asc('9') Then
					cString_Right_Bit =  Upper('A')
				Else
					cString_Right_Bit =  Chr(nTmpAsc_Right+nIncreaseValue )
				EndIf
			Case Between(nTmpAsc_Right,Asc(Upper('A')),Asc(Upper('Z')))
				If nTmpAsc_Right = Asc(Upper('Z')) Then
					cString_Right_Bit =  Lower('a')
				Else
					cString_Right_Bit =  Chr(nTmpAsc_Right+nIncreaseValue ) && Question: +1 should be + nIncreaseValue
				EndIf
			Case Between(nTmpAsc_Right,Asc(Lower('a')),Asc(Lower('z')))
				If nTmpAsc_Right = Asc(Lower('z')) Then
					cString_Right_Bit =  Alltrim(Str(nIncreaseValue))
					cString_Left = StringIncrease(cString_Left,nIncreaseValue,lMatchUpper)
				Else
					cString_Right_Bit =  Chr(nTmpAsc_Right+nIncreaseValue )
				EndIf
			EndCase
		Else
			Do	Case
			Case Between(nTmpAsc_Right,Asc('0'),Asc('9'))
				If nTmpAsc_Right = Asc('9') Then
					cString_Right_Bit =  Upper('A')
				Else
					cString_Right_Bit =  Chr(nTmpAsc_Right+nIncreaseValue )
				EndIf
			Case Between(nTmpAsc_Right,Asc(Upper('A')),Asc(Upper('Z')))
				If nTmpAsc_Right = Asc(Upper('Z')) Then
					cString_Right_Bit = Alltrim(Str(nIncreaseValue))
					cString_Left = StringIncrease(cString_Left,nIncreaseValue,lMatchUpper)
				Else
					cString_Right_Bit =  Chr(nTmpAsc_Right+nIncreaseValue )
				EndIf
			EndCase
		EndIf
		* Got the return value
		cReturnValue = cString_left + cString_Right_Bit
	Else
		cReturnValue = cString_Left + cString_Right_Bit + Alltrim(Str(nIncreaseValue ))
	EndIf
		
	Return cReturnValue
EndProc
*------
Procedure IsContainObject
	Lparameters oObject
	If Vartype(oObject)==Upper('O') and InList(Upper(oObject.BaseClass),Upper('Form'),Upper('PageFrame'),Upper('Page'),;
											Upper('Container'),Upper('GRID'),Upper('Commandgroup'),Upper('Optiongroup')) Then
		Return .T.
	Else
		Return .F.
	EndIf
EndProc
*------
*!*	Procedure ShowMemo && Pause	
*!*		Parameters cForm_caption,cOk_button_caption,cCancel_button_caption,lOk_Button_visible,lCancel_Button_visible,;
*!*				   nLeft_Position,nWidth_Position,nTop_Position,nHeight_Position,lForm_AutoCenter
*------
Procedure MaxSizeNo
	Lparameters eExpression,cOrder,cAlias
	
	cAlias = GetAlias(cAlias)
	If Empty(cAlias) Then
		Return ''
	EndIf
	If Pcount() >= 2 and IsValidStr(cOrder) Then
		If !Seek(eExpression,cAlias,cOrder) Then
			Return ''
		EndIf
	EndIf
	
	Local cReturnValue,nSelect,nTag,cTmpValue,cTmpSnNo,;
		cTmpSn1,cTmpSn2,cTmpSn3,cTmpSn4,cTmpSn5,cTmpSn6,cTmpSn7,cTmpSn8,cTmpSn9,;
		cTmpSn10,cTmpSn11,cTmpSn12,cTmpSn13,cTmpSn14,cTmpSn15,cTmpSn16
	
	cReturnValue = ''
	nSelect = Select()	
	
	Select (cAlias)
	For nTag =1 to 16
		cTmpValue = 'Sn' + Alltrim(Str(nTag))
		cTmpSnNo  = 'cTmpSn' + Alltrim(Str(nTag))
		&cTmpSnNo. = Val(&cTmpValue.)
	EndFor
			
	cReturnValue = Max(cTmpSn1,cTmpSn2,cTmpSn3,cTmpSn4,;
					   cTmpSn5,cTmpSn6,cTmpSn7,cTmpSn8,;
					   cTmpSn9,cTmpSn10,cTmpSn11,cTmpSn12,;
					   cTmpSn13,cTmpSn14,cTmpSn15,cTmpSn16)
	cReturnValue = Alltrim(Str(cReturnValue))

	Select (nSelect)
		
	Return cReturnValue
EndProc
*------
Procedure MinSizeNo
	Lparameters eExpression,cOrder,cAlias
				
	cAlias = GetAlias(cAlias)
	If Empty(cAlias) Then
		Return ''
	EndIf
	If Pcount() >= 2 and IsValidStr(cOrder) Then
		If !Seek(eExpression,cAlias,cOrder) Then
			Return ''
		EndIf
	EndIf
		
	Local cReturnValue,nSelect,cMaxSizeNo,nTag,cTmpValue,cTmpSnNo,;
		cTmpSn1,cTmpSn2,cTmpSn3,cTmpSn4,cTmpSn5,cTmpSn6,cTmpSn7,cTmpSn8,cTmpSn9,;
		cTmpSn10,cTmpSn11,cTmpSn12,cTmpSn13,cTmpSn14,cTmpSn15,cTmpSn16
	
	cReturnValue = ''
	nSelect = Select()	
	cMaxSizeNo = MaxSizeNo(eExpression,cOrder,cAlias)

	Select (cAlias)
	For nTag =1 to 16
		cTmpValue = 'Sn' + Alltrim(Str(nTag))
		cTmpSnNo  = 'cTmpSn' + Alltrim(Str(nTag))
		If Val(&cTmpValue.) = 0 Then
			&cTmpSnNo. = Val(cMaxSizeNo)
		Else
			&cTmpSnNo. = Val(&cTmpValue.)
		EndIf
	EndFor
		
	cReturnValue = Min(cTmpSn1,cTmpSn2,cTmpSn3,cTmpSn4,;
					   cTmpSn5,cTmpSn6,cTmpSn7,cTmpSn8,;
					   cTmpSn9,cTmpSn10,cTmpSn11,cTmpSn12,;
					   cTmpSn13,cTmpSn14,cTmpSn15,cTmpSn16)
	cReturnValue = Alltrim(Str(cReturnValue))
	
	Select (nSelect)
	
	Return cReturnValue
EndProc			 
*------
Procedure AllSizeNo
	Lparameters nSizeWidth,eExpression,cOrder,cAlias,cSizeTag,lIncludeSequenceEmptySizeNo
	
	cAlias = GetAlias(cAlias)
	If Empty(cAlias) Then
		Return ''
	EndIf
	If Pcount() >= 3 and IsValidStr(cOrder) Then
		If !Seek(eExpression,cAlias,cOrder) Then
			Return ''
		EndIf
	EndIf
	
	nSizeWidth = DefNumber(nSizeWidth,Len(&cAlias..Sn1))
	cSizeTag = DefCharacters(cSizeTag,'',.T.)
	lIncludeSequenceEmptySizeNo = DefLogic(lIncludeSequenceEmptySizeNo)

	Local cReturnValue,nSelect,lFirstAvailable,lLastAvailable,nTag,nSubTag,cTmpValue,cTmpSubValue
	cReturnValue = ''
	nSelect = Select()	
	lFirstAvailable = .F.
	
	Select (cAlias)
	For nTag =1 to 16
		cTmpValue = 'Sn' + Alltrim(Str(nTag))
		cTmpValue = Alltrim(&cTmpValue.)
	
		lLastAvailable = .T.		
		For nSubTag = nTag+1 to 16
			cTmpSubValue = 'Sn' + Alltrim(Str(nSubTag))
			If !Empty(Alltrim(&cTmpSubValue.)) Then
				lLastAvailable = .F.
				Exit
			EndIf
		EndFor
		
		If lFirstAvailable Then
			If Empty(cTmpValue) and !lIncludeSequenceEmptySizeNo Then
				Loop
			Else
				cReturnValue = cReturnValue + cSizeTag + Padl(cTmpValue,nSizeWidth,Space(1))
			EndIf
		Else
			If Empty(cTmpValue) Then
				Loop
			Else
				cReturnValue = Padl(cTmpValue,nSizeWidth,Space(1))
				lFirstAvailable = .T.
			EndIf
		EndIf
		
		If lLastAvailable Then
			Exit
		EndIf
	EndFor
	cReturnValue = Alltrim(cReturnValue)
	
	Select (nSelect)
	
	Return cReturnValue
EndProc
*------
Procedure AllSizeValue
	Lparameters nSizeWidth,eExpression,cOrder,cAlias,cSizeTag,lIncludeSequenceEmptySizeNo,cEmptyDefValue,lCheckLeft
	
	cAlias = GetAlias(cAlias)
	If Empty(cAlias) Then
		Return ''
	EndIf
	If Pcount() >= 3 and IsValidStr(cOrder) Then
		If !Seek(eExpression,cAlias,cOrder) Then
			Return ''
		EndIf
	EndIf
	
	nSizeWidth = DefNumber(nSizeWidth,Len(Str(&cAlias..S1)))
	cSizeTag = DefCharacters(cSizeTag,'',.T.)
	lIncludeSequenceEmptySizeNo = DefLogic(lIncludeSequenceEmptySizeNo)
	cEmptyDefValue = DefCharacters(cEmptyDefValue,'',.T.)
	lCheckLeft = DefLogic(lCheckLeft)

	Local cReturnValue,nSelect,lFirstAvailable,lLastAvailable,nTag,nSubTag,cTmpValue,cTmpReturnValue,cTmpSubValue
	cReturnValue = ''
	nSelect = Select()	
	lFirstAvailable = .T.
	
	If lCheckLeft Then
		lFirstAvailable = .F.
	EndIf 
	
	Select (cAlias)
	For nTag =1 to 16
		cTmpValue = 'S' + Alltrim(Str(nTag))
		cTmpValue = Alltrim(Str(&cTmpValue.))
		If cTmpValue == '0' Then
			cTmpValue = ''
			cTmpReturnValue = cEmptyDefValue
		Else
			cTmpReturnValue = cTmpValue
		EndIf
	
		lLastAvailable = .T.		
		For nSubTag = nTag+1 to 16
			cTmpSubValue = 'S' + Alltrim(Str(nSubTag))
			If &cTmpSubValue.<>0 Then
				lLastAvailable = .F.
				Exit
			EndIf
		EndFor
		
		If lFirstAvailable Then
			If Empty(cTmpValue) and !lIncludeSequenceEmptySizeNo Then
				Loop
			Else
				cReturnValue = cReturnValue + cSizeTag + Padl(cTmpReturnValue,nSizeWidth,Space(1))
			EndIf
		Else
			If Empty(cTmpValue) Then
				Loop
			Else
				cReturnValue = Padl(cTmpReturnValue,nSizeWidth,Space(1))
				lFirstAvailable = .T.
			EndIf
		EndIf
		
		If lLastAvailable Then
			Exit
		EndIf
	EndFor
	cReturnValue = Alltrim(cReturnValue)
	
	Select (nSelect)
	
	Return cReturnValue
EndProc
*------
Procedure Itcreatecursor_roger && Question
	Lparameter Vtablename,Vcursorname,;
		cAddField1,cAddField2,cAddField3,cAddField4,cAddField5,cAddField6,cAddField7,cAddField8,cAddField9,cAddField10,;
		cAddField11,cAddField12,cAddField13,cAddField14,cAddField15,cAddField16,cAddField17,cAddField18,cAddField19,;
		cAddField20,cAddField21,cAddField22,cAddField23,cAddField24
		
	If Empty(vcursorname) .or. Empty(vtablename)
		Wait Window 'pls Specify Your Cursor Name Or Table Name From Which You Want To Copy !' nowait
		Return .F.
	Endif

	Local Vplworkingare,lNeedOpen,cSourceAlias
	Vplworkingare	= Select()
	lNeedOpen 		= .F.
	cSourceAlias 	= ''
	
	LcDbfClose(cSourceAlias)
	LcDbfClose(vcursorname)
	
	If Select(Vtablename) > 0 Then && The source table has been opened.
		cSourceAlias = Vtablename
	Else
		cSourceAlias = AliasName()
		LcDbfOpen(Vtablename,cSourceAlias)
		lNeedOpen = .T.
	EndIf

	Select (cSourceAlias)
	Vplfieldcount = Afields(vplgamyarray)
	For Gncount = 1 To Vplfieldcount
		Vplgamyarray( Gncount , 7 ) = ''
		Vplgamyarray( Gncount , 8 ) = ''
		Vplgamyarray( Gncount , 10 ) = ''
		Vplgamyarray( Gncount , 11 ) = ''
		Vplgamyarray( Gncount , 13 ) = ''
		Vplgamyarray( Gncount , 14 ) = ''
		Vplgamyarray( Gncount , 15 ) = ''
	Endfor
	Select 0
	
	Local lnExtend,lnAdded,nTag,nSubTag,cTmpField,cTmpFieldName,cTmpValue
	lnExtend = 0 
	lnAdded = 0
	For nTag = 1 to 24
		cTmpField = 'cAddField'+Alltrim(Str(nTag))
		If IsValidStr(&cTmpField.) Then
			lnExtend = lnExtend + 1
		EndIf
	EndFor

	If lnExtend = 0
		Create Cursor (vcursorname) From Array Vplgamyarray
	Else
		Dimension Vplgamyarraynew( Vplfieldcount + lnExtend , 11 )
		For nTag = 1 To Vplfieldcount
			For nSubTag = 1 to 15
				VplGamyArrayNew(nTag,nSubTag) = VplGamyArray(nTag,nSubTag)
			EndFor
		EndFor
		
		For nTag = 1 to 24
			cTmpField = 'cAddField'+Alltrim(Str(nTag))
			If !IsValidStr(&cTmpField.) Then
				Loop
			Else
				cTmpField = StringDecrease(Alltrim(&cTmpField.),Space(2),Space(1))
				lnAdded = lnAdded + 1
			EndIf
			For nSubTag = 1 to 11 && Pause
				cTmpFieldName = ItSubstr(cTmpField,Space(1),1)
				Do	Case
				Case nSubTag = 1 && Field name
					cTmpValue = cTmpFieldName
				Case nSubTag = 2 && Field type
					cTmpValue = Alltrim(Strtran(cTmpField,cTmpFieldName,''))
					If '(' $ cTmpValue Then && Include field size
						cTmpValue = Alltrim(ItStrExtract(cTmpValue,'','('))
					Else
						cTmpValue = Leftc(cTmpValue,1)
					EndIf
				Case nSubTag = 3 && Field width
					cTmpValue = Alltrim(Strtran(cTmpField,cTmpFieldName,''))
					cTmpValue = Alltrim(ItStrExtract(cTmpValue,'(',')'))
					If ',' $ cTmpValue Then && If found decimal
						cTmpValue = ItSubstr(cTmpValue,',',1) && Integer
					EndIf
				Case nSubTag = 4 && Field decimal
					cTmpValue = Alltrim(Strtran(cTmpField,cTmpFieldName,''))
					cTmpValue = Alltrim(ItStrExtract(cTmpValue,'(',')'))
					If ',' $ cTmpValue Then && If found decimal
						cTmpValue = ItSubstr(cTmpValue,',',2) && Decimal
					Else
						cTmpValue = ''
					EndIf
				Case InList(nSubTag,5,6)
					cTmpValue = .F.
				Case Between(nSubTag,7,11)
					cTmpValue = ''
				EndCase
				VplGamyArrayNew(VplFieldCount + lnAdded,nSubTag) = cTmpValue
			EndFor
			If lnAdded >= lnExtend Then
				Exit
			EndIf
		EndFor
		Create Cursor (vcursorname) From Array Vplgamyarraynew
	EndIf
	
	* Restore the environment.
	If lNeedOpen Then
		LcDbfClose(cSourceAlias)
	EndIf
	
	Return .T.
EndProc
*------
Procedure GenProdCode
	Lparameters cLeftCode,cProdCode,cRightCode,nCodeLength,cTable,cOrder,lOnlyNumber,lIgnoreDeleted
	
	cLeftCode = Alltrim(DefCharacters(cLeftCode))
	cProdCode = Alltrim(DefCharacters(cProdCode,'1'))
	cRightCode= Alltrim(DefCharacters(cRightCode))
	nCodeLength = DefNumber(nCodeLength)	
	If nCodeLength <=0 Then
		Return cProdCode
	Else
		cProdCode = Padl(cProdCode,nCodeLength,'0')
	EndIf
			
	cTable = DefCharacters(cTable)
	cOrder = DefCharacters(cOrder) 
	lOnlyNumber = DefLogic(lOnlyNumber)
	lIgnoreDeleted = DefLogic(lIgnoreDeleted)
			
	Local nSelect,cReturnValue,cAlias,cTmpExpression,cSet_Deleted
	nSelect = Select()
	cReturnValue = cProdCode
	cAlias = AliasName()
	cTmpExpression = cLeftCode + cProdCode + cRightCode
	cSet_Deleted = Set("Deleted")
	If lIgnoreDeleted Then
		Set Deleted on
	Else
		Set Deleted off
	EndIf
	
	LcDbfOpen(cTable,cAlias,.F.,cOrder)	
	Do While Seek(cTmpExpression,cAlias,cOrder)
		If lOnlyNumber Then
			If Len(ItStr(Val(cProdCode)+1)) > nCodeLength Then
				Exit
			Else
				cProdCode = ItStr(Val(cProdCode)+1)
				cTmpExpression = cLeftCode + cProdCode + cRightCode
			EndIf
		Else
			If Len(StringIncrease(cProdCode,1,.F.)) > nCodeLength Then
				Exit
			Else
				cProdCode = StringIncrease(cProdCode,1,.F.)
				cTmpExpression = cLeftCode + cProdCode + cRightCode
			EndIf
		EndIf
	EndDo
	
	LcDbfClose(cAlias)
	Select (nSelect)
	Set Deleted &cSet_Deleted.
	
	Return cProdCode
EndProc	
*------
Procedure StringDecrease && StringDecrease('a     b','  ',' ') && 'a b'
	Lparameters cString,cTagOld,cTagNew
	
	cString = DefCharacters(cString,'',.T.)
	cTagOld = DefCharacters(cTagOld,'',.T.)
	cTagNew = DefCharacters(cTagNew,'',.T.)
	
	If cTagOld $ cTagNew Then && cTagOld == cTagNew or cTagOld $ cTagNew
		Return cString
	EndIf
	
	If !IsValidStr(cString,.T.) or !IsValidStr(cTagOld,.T.) or !IsValidStr(cTagNew,.T.) Then
		Return cString
	EndIf
	
	Do While cTagOld $ cString
		cString = Strtran(cString,cTagOld,cTagNew)
	EndDo
	
	Return cString
EndProc
*------
Procedure ImageGetProp
	Lparameters cPicture,cProperty
	
	Local eReturnValue
	eReturnValue = .Null.
	
	If !IsValidStr(cPicture) or !File(cPicture) Then
		Return eReturnValue
	Else
		cPicture = LocFile(cPicture)
	EndIf
	
	If !IsValidStr(cProperty) Then
		Return eReturnValue
	EndIf
	
	Local cOn_Error,lErrored
	cOn_Error = On('Error')
	lErrored  = .F.

	If Vartype(_Screen._TmpImage) == Upper('O') Then
		_Screen.RemoveObject('_TmpImage')
	EndIf	
	_Screen.AddObject('_TmpImage','Image')
	_Screen._TmpImage.Picture = cPicture
	eReturnValue = _Screen._TmpImage.&cProperty.
	If Vartype(_Screen._TmpImage) == Upper('O') Then
		_Screen.RemoveObject('_TmpImage')
	EndIf
	
	On Error &cOn_Error.
	If lErrored Then
		eReturnValue = .Null.
	EndIf
	
	Return eReturnValue
EndProc
*------
Procedure ErrorHand
	Local cError_ID,cError_Message,cError_LineNo,cError_Coding,cMessageText
	cError_ID = Alltrim(Str(Error()))
	cError_Message = Message()
	cError_LineNo = Alltrim(Str(Lineno(1)))
	cError_Coding = Message(1)
	
	*cMessageText = 'ID      : ' + cError_ID + Chr(13)+Chr(10) + ;
				   'Message : ' + cError_Message + Chr(13)+Chr(10) + ;
				   'Line no : ' + cError_LineNo  + Chr(13)+Chr(10) + ;
				   'Latest Coding  : ' + cError_Coding

	cMessageText = 'ID      : ' + cError_ID + Chr(13)+Chr(10) + ;
				   'Message : ' + cError_Message + Chr(13)+Chr(10) + ;
				   'Latest Coding  : ' + cError_Coding
	
	Local nReturnValue_From_User
	nReturnValue_From_User = MessageBox(cMessageText,2+48+512,'Error found by Roger') && Ignore default
	
	Do	Case
	Case nReturnValue_From_User = 3 && Abort
		Cancel
	Case nReturnValue_From_User = 4 && Retry
		Retry
	Case nReturnValue_From_User = 5 && Ignore
		Return nReturnValue_From_User
	EndCase
	
*!*		If nReturnValue_From_User = 4 Then && Retry
*!*			Retry
*!*		Else && Cancel
*!*			Return nReturnValue_From_User
*!*		EndIf
EndProc	
*-------
Procedure GetBodyText && UnFinished, Question : Maybe should sent a parameter as chart set otherwise its will return unreadable codes

	Lparameters cUrl
	
	* Check the cUrl parameter
	
	Local oCdo,cReturnValue
	oCdo = CreateObject('Cdo.Message')
	cReturnValue = ''
	
	oCdo = CreateMHTMLBody(cUrl)
	cReturnValue = oCdo.TextBody
	
	Release oCdo
	
	Return cReturnValue
EndProc
*-------
Procedure GetImageWidth
	Lparameters cSourceFileName
	If !IsValidStr(cSourceFileName) or !File(cSourceFileName) Then
		Return 0 
	EndIf

	Local nReturnValue,nImage
	Store 0 to nReturnValue,nImage
	
	Declare Integer GdipLoadImageFromFile In gdiplus.dll string wFilename, Integer @nImage
	Declare Integer GdipGetImageWidth IN gdiplus Integer m_Image ,Integer @Width 
	
	GdipLoadImageFromFile(Strconv(cSourceFileName + Chr(0), 5), @nImage)
	GdipGetImageWidth(nImage,@nReturnValue)
	
	Clear Dlls GdipLoadImageFromFile ,GdipGetImageWidth 
	Release wFilename ,nImage ,m_Image  ,Width
	
	Return nReturnValue
EndProc
*-------
Procedure GetImageHeight
	Lparameters cSourceFileName
	If !IsValidStr(cSourceFileName) or !File(cSourceFileName) Then
		Return 0 
	EndIf

	Local nReturnValue,nImage
	Store 0 to nReturnValue,nImage
	
	Declare Integer GdipLoadImageFromFile In gdiplus.dll string wFilename, Integer @nImage
	Declare Integer GdipGetImageHeight IN gdiplus Integer m_Image ,Integer @Height 
	
	GdipLoadImageFromFile(Strconv(cSourceFileName + Chr(0), 5), @nImage)
	GdipGetImageHeight(nImage,@nReturnValue)
	
	Clear Dlls GdipLoadImageFromFile ,GdipGetImageHeight 
	Release wFilename ,nImage ,m_Image  ,Height
	
	Return nReturnValue
EndProc
*-------
Procedure RunVb && RunVb([MsgBox( "Just for test", vbOKCancel, "Warning")]) && UnFinshed Question: How to run multi line coding ?
	Lparameters m.mCode
	
	If !IsValidStr(m.mCode) Then
		Return Null
	EndIf
	
	Local oVbObject,eReturnValue
	oVbObject = CreateObject("MSScriptcontrol.scriptcontrol")
	oVbObject.Language = "VBScript"
	eReturnValue = oVbObject.Eval(m.mCode)
	
	Release oVbObject
EndProc
*-------
Procedure ItJustPath
	Lparameters cPathExpression

	Local cReturnValue
	cReturnValue = ''
	
	If Vartype(cPathExpression) <> Upper('C') or Empty(Alltrim(cPathExpression)) Then
		cPathExpression = Sys(16)
	Else
		cPathExpression = Alltrim(cPathExpression)
	EndIf
	
	If ':' $ cPathExpression Then && Local machine path
		cReturnValue = JustPath(Substrc(cPathExpression ,Atc(':',cPathExpression)-1))
	Else
		If '\\' $ cPathExpression Then && Network machine path
			cReturnValue = JustPath(Substrc(cPathExpression , Atc('\\',cPathExpression)))
		Else
			* Can not ignore the path ,Maybe it's the Http ,Ftp such as the web path.
			* Ignore it temporarily 
			cReturnValue = ''
		EndIf
	EndIf
	
	Return cReturnValue
EndProc
*-------
Procedure ItParameters && This use to count the parameters such as ItParameters(1,,2) && Return 3 as integer value.
	Lparameters eParameter1 ,eParameter2 ,eParameter3 ,eParameter4 ,eParameter5 ,eParameter6 ,eParameter7 ,eParameter8 ,eParameter9
	
	Local nReturnValue
	nReturnValue = Pcount()
	
	Return nReturnValue
EndProc
*-------
Procedure itCopyFile
	Lparameters cSourceFile,cTargetFile,lOverwrite,lForce_Create_Directory

	Local lReturnValue,nOverWrite
	lReturnValue = .F.
	
	If !IsValidStr(cSourceFile) or !File(cSourceFile) Then
		Return lReturnValue
	Else
		cSourceFile = Alltrim(LocFile(cSourceFile))
	EndIf
	
	lOverwrite = DefLogic(lOverwrite)
	nOverWrite = Iif(lOverwrite,0,1)
	lForce_Create_Directory = DefLogic(lForce_Create_Directory)
	
	If !IsValidStr(cTargetFile) or Empty(JustPath(cTargetFile)) and Empty(JustFname(cTargetFile)) Then
		Return lReturnValue
	Else
		If IsValidStr(JustFname(cTargetFile)) and IsValidStr(JustPath(cTargetFile)) Then
			* Fname and directory both set but need to check the direcoty if exist.
			Local cTargetDirectory
			cTargetDirectory = JustPath(cTargetFile)
			If !Directory(cTargetDirectory) Then
				* The target directory not exist.
				If lForce_Create_Directory Then
					* Create the directory
					Md (cTargetDirectory)
				Else
					Return lReturnValue
				EndIf
			EndIf				
		Else
			If Empty(JustPath(cTargetFile)) Then
				* No directory set(but fname set).
				* Get the source directory as the target directory default.
				*!*	cTargetFile = ForcePath(JustFname(cTargetFile),JustPath(cSourceFile)) && Just the source path as the target file directory default.
				cTargetFile = ForcePath(JustFname(cTargetFile),Set('Directory')) && Just current path as the target file directory default.
			Else
				* No file name set(But directory set), Check the path if valid
				* Got the source file name as the target file name default.
				If Directory(JustPath(cTargetFile)) Then
					cTargetFile = ForcePath(JustFname(cSourceFile),JustPath(cTargetFile))
				Else
					Return lReturnValue
				EndIf
			EndIf
		EndIf
	EndIf
	
	* Declare the dll first.
	Declare Integer CopyFile In Kernel32 As CopyFileA String lpExistingFileName , String lpNewFileName, Integer bFailIfExists
	If CopyFileA(cSourceFile,cTargetFile,nOverWrite) > 0 Then
		lReturnValue = .T.
	EndIf
	Clear Dlls CopyFileA

	Return lReturnValue
EndProc
*-------
Procedure ItGroupData
	Lparameters cGroupExp,cCursorName,cDbfAlias,eSeekExpression,cIndex_TagName,cFieldsList,cFilterExpression,cRunExpInNewDbf
	
	* ItGroupData('Inv_ID + Product_ID + Lot_No','csPacklst_GroupR','PacklstR',Dv1_fm,'','quantity,desc')

	Local lReturnValue 
	lReturnValue = .F.
	
	If !IsValidStr(cGroupExp,.T.) Then
		Return lReturnValue
	EndIf
	
	cCursorName 		= DefCharacters(cCursorName,'csResult')
	eSeekExpression 	= DefCharacters(eSeekExpression)
	cFieldsList			= DefCharacters(cFieldsList)
	cFilterExpression	= DefCharacters(cFilterExpression,'.T.')
	cRunExpInNewDbf 	= DefCharacters(cRunExpInNewDbf) && Run the expression foxpro coding when new record appeneded.
	
	Local nSelect,lNeedOpen,cAlias,cIndex_Exp
	nSelect=Select()
	* Check the table if need to open .	
	If IsValidStr(cDbfAlias) Then && If the parameter cDbfAlias is a vaild string.
		If Select(cDbfAlias)>0 and IsValidStr(GetAlias(cDbfAlias)) Then && If cDbfAlias exist opened and no need to open again
			lNeedOpen = .F.
			cAlias = GetAlias(cDbfAlias)
		Else
			* Need to open the table base on cDbfAlias, That's mean not found a table to dispose
			lNeedOpen = .T.
			cAlias = AliasName()
			If !LcDbfOpen(cDbfAlias,cAlias) tHEN
				Wait window "File '"+ForcePath(ForceExt(cDbfAlias,'dbf'),Set('directory')) + "' does not exist ." nowait
				Return lReturnValue
			EndIf
		EndIf
	Else
		If IsValidStr(GetAlias()) Then && If there is a table opened in the current select
			cAlias = GetAlias()
			lNeedOpen = .F.
		Else
			Wait window 'No table is opened in the current work area .' nowait
			Return lReturnValue
		EndIf
	EndIf

	If IsValidStr(cIndex_TagName) Then
		Set order to (cIndex_TagName) in (cAlias)
	Else
		If Empty(Order(cAlias)) Then
			cIndex_TagName = AliasName()
			Select (nSelect)
			Index on &cGroupExp. to ForcePath(cIndex_TagName,GetEnv("TMP"))
		Else
			cIndex_TagName = Order(cAlias)
		EndIf	
	EndIf
	cIndex_Exp = IndexToExp(cIndex_TagName,cAlias)
	* Checking the parameters completed *
	
	
	* Create the cursor table for (cCursorName) base on (cAlias)
	ItCreateCursor_Roger(cAlias,cCursorName) && Question
	CopyCdx(cAlias,cCursorName)
	
	Local cGroupExpNew,cGroupExpOld,cTmpField,cOldField,cNewField,nTag
	Store '' to cGroupExpNew,cGroupExpOld,cTmpField,cOldField
	* ------------	Scan the (cAlias) and append new record into (cCursorName) -------------- *
	Select (cAlias)
	=Seek(eSeekExpression,cAlias,cIndex_TagName)
	Scan rest while &cIndex_Exp.= eSeekExpression
		If !Evaluate(cFilterExpression) Then
			Loop
		EndIf
		
		cGroupExpNew = &cGroupExp.
		If !(cGroupExpNew==cGroupExpOld) Then && If the different group exp.
			cGroupExpOld=cGroupExpNew && The newlist exp. shoudl auto update
			* Append new record into target table such as cCursorName
			Select (cAlias)
			Scatter memo memvar
			Insert into (cCursorName) from memvar
			
			Select (cCursorName)
			&cRunExpInNewDbf.
		Else && Accumulate the number fields or character fields
			If IsValidStr(cFieldsList) Then
				For nTag = 1 to  Occurs(',',cFieldsList)+1
					cTmpField = uTrim(ItSubstr(cFieldsList,',',nTag))
					If IsFieldExist(cTmpField,cAlias)
						cOldField = cAlias + '.' + cTmpField
						cNewField = cCursorName + '.' + cTmpField
						If Type(cOldField)=Upper('N') Then
							Replace &cNewField. with &cNewField.+&cOldField.
						Else && InList(Type(cOldField),'C','M')
							If Type(cOldField)='C' Then
								Replace &cNewField. with Alltrim(&cNewField.)+Alltrim(&cOldField.)
							Else && M
								Replace &cNewField. with Alltrim(&cNewField.)+Chr(13)+Chr(10)+Alltrim(&cOldField.)
							EndIf
						EndIf
					EndIf
				EndFor
			EndIf
			* No need run cRunExpInNewDbf. Because is not the new appended record.		
		EndIf
	EndScan
	lReturnValue = .T.

	* Restore the data environment. That's means if need to close the table
	If lNeedOpen Then
		LcDbfClose(cAlias)
	EndIf
	Select (nSelect)
	
	Return lReturnValue
EndProc
*-------
Procedure ItCreateIdx
	Lparameters cIndex_Expression,cAlias
	
	Local cReturnValue,cIndex_Tag,nSelect
	cReturnValue = ''
	cIndex_Tag = ForcePath(AliasName(),GetEnv("TMP"))
	nSelect = Select()
	
	If !IsValidStr(cIndex_Expression) Then
		Waitwindow("Please set the index expression first.",Sys(16))		   
		Return cReturnValue
	EndIf
	
	If !IsValidStr(cAlias) Then
		If Empty(Alias()) Then
			Waitwindow("Can not found table to dispose .",Sys(16))
			Return cReturnValue
		Else
			cAlias = Alias()
		EndIf
	Else
		If !Select(cAlias) > 0 Then
			Waitwindow("The alias of '" + cAlias + "' does not exist .",Sys(16))
			Return cReturnValue
		EndIf
	EndIf
	
	Select (cAlias)
	Index on &cIndex_Expression. to &cIndex_Tag.
	
	* Restore the environment.
	Select (nSelect)
	cReturnValue = JustStem(cIndex_Tag)
	
	Return  cReturnValue
EndProc
*-------
Procedure DbftoHtml
EndProc
*-------
Procedure HtmlToDbf
EndProc
* ------
Procedure DbfToXml
EndProc
* ------
Procedure XmlToDbf
EndProc
* ------
Procedure ItCast
	Lparameters eExpression,cDataType,
EndProc
* ------
Procedure ItMessageBox
	* Note : It base for MessageBox function but it can get a default response after timeout.
EndProc
	
*!*	Procedure RestoreEnvironment
*!*		Lparameters cStatus
*!*	EndProc
*!*		Dim WshShell
*!*		Set WshShell=WScript.CreateObject(”WScript.Shell”)
*!*		WshShell.Run “notepad”



*!*	Procedure cReline
*!*		Lparameters cTempValue,l
*!*		If Not IsValidStr(DefCharacters(cTempValue,'',.T.)) Then
*!*			Return ''
*!*		Else
*!*			cTempValue=DefCharacters(cTempValue,'',.T.)
*!*		EndIf
*!*		Local cReturnValue,
*!*	Roger Fionished

*!*	Procedure LcMemoValue
*!*		Lparameters cField,cKeyword,nTag,cTag,
*!*		Local cReturnValue
*!*		cReturnValue=''
*!*		If Type('cField')<>'M' Or Empty(Alltrim(cField)) Then
*!*			Wait window 'Please type a memo field and not empty!' nowait
*!*			Return cReturnValue
*!*		EndIf
*!*		If Vartype(cKeyWord)<>'C' Or Empty(Alltrim(cKeyWord)) Then
*!*			Wait window 'Please type the key word as the word tag first !' nowait
*!*			Return cReturnValue
*!*		EndIf
*!*		If Vartype(nTag)<>'N' or Empty(nTag) Then && Not a digit value or value is 0
*!*			nTag=1
*!*		Else
*!*			If nTag<0 Then && It's a negative value
*!*				nTag=-1
*!*			EndIf
*!*		EndIf
*!*		If Vartype(cTag)<>'C' Then
*!*			cTag=''
*!*		Else
*!*			cTag=Alltrim(cTag)
*!*		EndIf


*!*	Procedure LcWordTag(cString,cSearchExp,nIndex,cDelimiter,lForce)
*!*		If Vartype(cString)<>'C' Or



*!*	Procedure LcHtmlAll
*!*		Lparameters cDir
*!*		cDir=GetDir()
*!*		If Empty(cDir) Then
*!*			Return .F.
*!*		EndIf
*!*		Local oFiler
*!*		oFiler=CreateObject('Filer.Fileutil')
*!*		oFiler.SearchPath=cDir
*!*		oFiler.FileExpression='*.html'
*!*		oFiler.Find(0)
*!*		nTag=0
*!*		For LcControl=1 to oFiler.Files.Count()
*!*			nTag=nTag+1
*!*			cTempName=Addbs(cDir)+oFiler.Files.Item(LcControl).Name
*!*			Wait window 'Processing '+Alltrim(Str(nTag))+' of '+cTempName nowait
*!*			=LcHtmlToTxt(cTempName)
*!*		EndFor
*!*	EndProc