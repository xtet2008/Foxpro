Lparameters urlContent,saveDir

urlContent = Defcharacters(urlContent,_cliptext)
If !IsValidStr(urlContent) Then
	MessageBox('Nothing to anlysised.',0+64,'Warning')
	Return .F.
EndIf

saveDir = DefCharacters(saveDir,GetDir(''),.T.)
If Empty(saveDir) Then
	MessageBox('Can not found the save path,Please try again.',0+48,'Warning')
	Return .F.
EndIf

Local url_front as String 
url_front = "http://www.excelbbx.net/Excel/"

Local url_file as String,url_path as String , url_localPath as String 
For nTag = 1 to Occurs("href=",urlContent)
	url_file = StrExtract(urlContent,"href="," ",nTag)
	url_file = Strtran(url_file,["],[])
	url_file = Strtran(url_file,['],[])
	url_file = ForceExt(url_file,'.gif')
	url_path = url_front + url_file
	url_localPath = ForcePath(url_file,saveDir)
	If !File(url_localPath) and !lDownloadFiles(url_path,url_localPath)
		? url_file,Chr(9),url_path
	EndIf
EndFor