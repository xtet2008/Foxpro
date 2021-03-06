Local imageFolder
imageFolder = GetDir(GetEnv("USERPROFILE"),"Image(s) folder","Pls select the image(s) folder",16)
If !Directory(imageFolder) then
	Return .f.
EndIf

Local cSet_Escape
cSet_Escape = Set("Escape")
Set Escape Off && Make sure it will not interrupted when pressed the ESC key."

If nSearchFiles("*.jpg,*.bmp,*.png,*.gif",imageFolder,.T.)= 0 then
	Return .F.
Else
	Alter table Alias() add column Renamed l
EndIf

Clear
FSO = createobject("scripting.filesystemobject")
Scan
	Wait window '# of records handled :  ' + Alltrim(Str(Recno())) + "/" + Alltrim(Str(Reccount())) nowait
	If Inkey()=27
		Exit && If it has pressed ESC
	EndIf
	
	If Fsize > 300 * 1024 then
		Loop && Just can be deal with the fsize less then 300 KB
	EndIf
	
	If File(fname) and !Renamed then
		fileText = Alltrim(ItValidName(getImageText(Fname," ")))
		If Empty(fileText) Then
			Loop
		EndIf
		
		newFileName = ForcePath(Forceext(fileText,JustExt(fname)),JustPath(fname))
		If Lower(newFileName) = Lower(Alltrim(fname)) Then
			Loop && No need to rename cause it already get the image text as image name.
		EndIf
		
		If File(newFileName) Then
			newFileName = newFileName + AliasName() && If the file already exist then genreate a random file name.
		EndIf
		
		Try
			FSO.MoveFile(fname, newFileName) && Rename
			If File(newFileName) then
				Replace fname with newFileName ,Renamed with .t.
			EndIf
		Catch to err
			?
			?"err no: ",err.Message
			?"recno(): ",Recno()
			?"err message: ",fileText
		EndTry 
	endif
EndScan

Set Escape &cSet_Escape. && Recover the environment.