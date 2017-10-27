extractString  = _cliptext
extractStart = "<mp3>"
extractEnd = "</mp3>"
extractCount = Occurs(extractStart,extractString)

extractOutput = ""
extractLine = Chr(13)+Chr(10)
For extractTag = 1 to extractCount
*	Set step on 
	extractOutput = extractOutput +StrExtract(extractString  ,extractStart ,extractEnd ,extractTag )+extractLine 
EndFor

*_setSafety = Set("safety");
*Set safety off
?StrToFile(extractOutput ,"d:\temp\mp3List.txt",0)
*Set safety &_setSafety .
run/n notepad d:\temp\mp3List.txt