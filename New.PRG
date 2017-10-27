Lparameters cText,nConvert,lNoRelease
&& if nConvert=1 then convert GbK to GbW, else if nConvert=0 or 2 then gb2 to GbK
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
oWord.Visible=.T.
cTempError=On('Error')
TempIsError=.F.
On Error TempIsError=.T.
TempCount=oWord.Documents.Count
If TempIsError Then && No Document added 
	On Error &cTempError.
	oWord.Documents.Add()
EndIf

	
oWord.Selection.Text=cText
oWord.Selection.Range.TcscConverter(nConvert,.T.,.T.)
Return oWord.Selection.Text
If Not lNoRelease Then
	Release oWord
EndIf
