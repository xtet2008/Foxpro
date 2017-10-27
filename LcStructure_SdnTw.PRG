Procedure LcStructure
	Lparameters cTable
	cTable='Sdn_TW'
	If Vartype(cTable)<>'C' Or Empty(cTable) Then
		cTable=Alias()
	EndIf
	Local LcTempAlias
	LcTempAlias=AliasName()
	If  Empty(Alltrim(cTable)) or Not LcDbfOpen(cTable,LcTempAlias,.T.) Then
		Wait window 'Please sure the table '+Iif(Vartype(cTable)='C',cTable,'')+' exist and can open exclusive !' nowait
		Return .F.
	EndIf
	For LcControl=1 to Fcount(LcTempAlias)
		TempFieldName=Field(LcControl,LcTempAlias)
		If Vartype(&TempFieldName)='C' Then
			Select Max(Len(Alltrim(&TempFieldName))) from (cTable) into Array TempArray	 
			TempCmd=[Alter Table (cTable) Alter Column &TempFieldName. ]+Vartype(&TempFieldName.)+'('+Str(TempArray)+')'
			&TempCmd.
		Else
			If Vartype(&TempFieldName)='N' Then
				Alter Table (cTABLE) Alter Column &TempFieldName. N (20,4)
			EndIf
		EndIf
	EndFor
	LcDbfClose(LcTempAlias)
	Return .T.
EndProc