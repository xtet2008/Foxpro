Xls_Handle=CreateObject('Excel.Application')
Xls_Handle.WorkBooks.Open(GetFile('Xls'))
If NOt Used('Four') Then
	Use Four
EndIf
Select Four
For LcControl=3 to 464
	TempId=LcConvert('C',Xls_Handle.Range('A'+Alltrim(Str(LcControl))).Value)
	If IsNull(TempId)
		TempId=''
	EndIf
	TempName=LcConvert('C',Xls_Handle.Range('B'+Alltrim(Str(LcControl))).Value)
	If IsNull(TempName) Then
		TempName=''
	EndIf
	TempShout=LcConvert('C',Xls_Handle.Range('C'+Alltrim(Str(LcControl))).Value)
	If IsNull(TempShout) Then
		TempShout=''
	EndIf
	TempMemo=LcConvert('C',Xls_Handle.Range('D'+Alltrim(Str(LcControl))).Value)
	If IsNull(TempMemo) Then
		TempMemo=''
	EndIf
	Append Blank 
	Replace ID with TempId,Name with TempName,Shout with TempShout,Memo with TempMemo
EndFor