?
=A(3)
Procedure A
	lparameters lValue
	nValue=lValue
	?'First=',nValue
	b(nValue) && Is the differnt with Do b with nValue
*!*		Do b with nValue
	?'Last =',nValue
EndProc
Procedure B
	lparameters lValue
*!*		Private nValue	
	nValue=lValue
	nValue=nValue+1
	?'Second=',nValue
EndProc