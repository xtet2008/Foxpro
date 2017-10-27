Procedure GetColumn
	Lparameters cAlias,cColumn
	Private cTempAlias,cTempColumn
	cTempAlias=cAlias
	cTempColumn=cColumn
	Select (cTempAlias)
	Scan
		GetColumn(cTempAlias,cTempColumn)
	Endscan
	Messagebox(Str(&nColumn.))
Endproc
