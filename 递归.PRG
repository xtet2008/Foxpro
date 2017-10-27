=Travel(5)
Procedure Travel
	Lparameters nValue
	If nValue<=0 Then
		Return
	Else
		Wait window Alltrim(Str(nValue))
		nValue=nValue-1
		Travel(nValue)
	EndIf
EndProc