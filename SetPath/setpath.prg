*read events
_screen.icon = 'itrader.ico'
_screen.Caption = 'Oriental Studio'

Set carry on
Public isquit 
isquit = .f.

Local cCurdir
cCurdir=GetCurDir()
Set Default To (cCurdir)

* Loading toolbar
Set Classlib To ForcePath('Tony.vcx',cCurdir) additive
Public Tonytoolbar
Tonytoolbar = CREATEOBJECT('TonyToolBar',cCurdir)
TonyToolbar.show
close table all

* Loading set path screen
Do form SetPath with cCurdir

if isquit = .t.
   clear all
   quit
endif      
*clear events

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
Procedure DefLogic
	Lparameters plLogicValue
	If Vartype(plLogicValue)<>Upper('L') Then
		Return .F.
	Else
		Return plLogicValue
	EndIf
EndProc
