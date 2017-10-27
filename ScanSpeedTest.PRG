Set Procedure To d:\roger\roger addi
? && Move to next row
*!*	If Empty(nSearchFiles('*.*','E:\i386')) Then
*!*		?'No data to test¡­¡­Test finished.'
*!*		Wait window 'No data to test' nowait
*!*	EndIf
Select sResult
Local Row_Column_Seconds,Column_Row_Seconds,Tmp_Value,nColumn,cFiledName,tStart,tEnd
tStart=Datetime()
?tStart,'¡­¡­Row_Column start¡­¡­'
For nColumn=1 to Fcount()
	cFieldName=Field(nColumn)
	Scan
		Wait window 'Recno()='+Alltrim(Str(Recno()))+' | Field()='+cFieldName nowait
	EndScan
EndFor
tEnd=Datetime()
?tEnd,'¡­¡­Row_Column end¡­¡­'
?'¡­¡­Total second:',tEnd-tStart,'¡­¡­'


?
tStart=Datetime()
tStart=Datetime()
?tStart,'¡­¡­Column_Row start¡­¡­'
Scan
	For nConlumn=1 to Fcount()
		cFieldName=Field(nColumn)
		Wait window 'Recno()='+Alltrim(Str(Recno()))+' | Field()='+cFieldName nowait
	EndFor
EndScan
tEnd=Datetime()
?tEnd,'¡­¡­Column_Row end¡­¡­'
?'¡­¡­Total second:',tEnd-tStart,'¡­¡­'
Wait window '' nowait