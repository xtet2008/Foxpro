Lparameters cPrgName
*!*	cPrgName='Cheng.Prg'
If Not (Vartype(cPrgName)='C' And  Not Empty(cPrgName) )THen
	cPrgName='Roger.Prg'
Else
	cPrgName=ForceExt(Alltrim(cPrgName),'Prg')
	If Not File(cPrgName) Then
		Wait window 'Cannot find the file of '+cPrgName nowait
		Return .F.
	EndIf
Endif
On Error 
Set Procedure To roger addi
Local TempSetSafety
TempSetSafety=Set("Safety")
Set Safety Off

If Used('AllFunc') Then
	Use in AllFunc
EndiF
If Not LcDbfOpen('AllFunc','AllFunc',.F.) Then
	Wait window nowait 'Can not use AllFunc share' nowait
	Set Safety &TempSetSafety.
	Return .F.
EndIf

If Used('rFunction') Then
	Use in rFunction
Endif
If Not LcDbfOpen('rFunction','rFunction',.T.) Then
	Wait window nowait 'Can not use rFunction exclusive'
	Set Safety &TempSetSafety.
	Return .F.
Else	
	Select rFunction
	If Alias()=Upper('rFunction') Then
		Zap
	EndIf
EndIf

Local cPrgValue,nAppended,nProcStart,nProcEnd,lappended,cTempValue
Store 0 to nAppended,nProcStart,nProcEnd
cTempValue=''
cPrgValue=FileToStr(cPrgName)
Select AllFunc
Replace Prg_Value with cPrgValue
If Empty(Alltrim(cPrgValue)) Then
	Set Safety &TempSetSafety.
	LcDbfClose('rFunction')
	LcDbfClose('AllFunc')
	Return .F.
EndIf
TempProcedureTotal=Occurs('PROCEDURE',Upper(cPrgValue))
Select rFunction
For LcControl=1 to Memlines(AllFunc.Prg_Value)
	If Not 'PROCEDURE' $ Upper(Mline(AllFunc.Prg_Value,LcControl)) Then && If not find the procedure in the memo line
		Loop
	Else
		If lappended Then &&
			nProcEnd=LcControl-1 && save the end procedure number
			For SubLcControl=nProcStart to nProcEnd
				If Empty(cTempValue) Then
					cTempValue=Mline(AllFunc.Prg_Value,SubLcControl)
				Else
					cTempValue=cTempValue+Chr(13)+Mline(AllFunc.Prg_Value,SubLcControl)
				EndIf
			EndFor
 			Replace Func with cTempValue
			cTempValue=''
		EndIf
		
		If nAppended>=TempProcedureTotal Then
			Exit && it has been add procedure finished
		EndIf
		nProcStart=LcControl && Save the procedure start number
		Append Blank 
		nAppended=nAppended+1
		Replace name with Rtrim(Substr(Mline(AllFunc.Prg_Value,LcControl),At(' ',Mline(AllFunc.Prg_Value,LcControl))+1))
		lappended=.T.
		Wait window 'Scan procedure of '+Rtrim(name)+'  '+Alltrim(Str(nAppended))+'/'+Alltrim(Str(TempProcedureTotal)) nowait
	EndIf
EndFor
For SubLcControl=nProcStart to Memlines(AllFunc.Prg_Value)
	If Empty(cTempValue) Then
		cTempValue=Mline(AllFunc.Prg_Value,SubLcControl)
	Else
		cTempValue=cTempValue+Chr(13)+Mline(AllFunc.Prg_Value,SubLcControl)
	EndIf
EndFor
Replace  Func with cTempValue
Set Safety &TempSetSafety.
LcDbfClose('rFunction')
LcDbfClose('AllFunc')
Wait window 'Finished' nowait
Return .T.