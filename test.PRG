With oRoger as function of "Roger.prg"
? .aliasname()
EndWith




?'begain to found somethings'
For a = 100 to 10000
	length = Len(Alltrim(Str(a)))
	
	stringRemoveLeft = Substr(Alltrim(Str(a)),2)
	stringRemoveRight = left(Alltrim(Str(a)),length-1)
	
	If Val(stringRemoveLeft ) = 13 and Val(stringRemoveRight ) = 40 then 
		?a
		EndIf
		endfor
	?'no found anything'

*!*	a=1
*!*	b='2'
*!*	Wait window a+b
*!*	Wait window 1+'3'

*!*	a= 1
*!*	asdfs + a

*!*	Close Tables all
*!*	Set Safety off
*!*	Use data\cdnmast Exclusive 
*!*	Zap
*!*	Use data\cdndtl Exclusive 
*!*	Zap
*!*	Use in cdndtl
*!*	Do form xlstodbf

*!*	For a =1 to 10
*!*		Do while b = 1
*!*	EndFor
*!*		EndDo