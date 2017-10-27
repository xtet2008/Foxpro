Public goFlashForm
goFlashForm = Createobject("FlashForm")
goFlashForm.Show()


Define Class FlashForm As Form

	Width = 412
	Height = 306
	FlashCount = 0
	Dimension FlashHandler[1]
	Callback = Null

	Add Object oleFlash1 As OleControl With ;
		OleClass = "ShockwaveFlash.ShockwaveFlash.9", ;
		Width = 390, ;
		Height = 95, ;
		Left = 11, ;
		Top = 11

	Add Object oleFlash2 As OleControl With ;
		OleClass = "ShockwaveFlash.ShockwaveFlash.9", ;
		Width = 390, ;
		Height = 95, ;
		Left = 11, ;
		Top = 108

	Add Object oleFlash3 As OleControl With ;
		OleClass = "ShockwaveFlash.ShockwaveFlash.9", ;
		Width = 390, ;
		Height = 95, ;
		Left = 11, ;
		Top = 204

	Procedure Init
	#Define GW_CHILD 5
	#Define GWL_WNDPROC -4
	Private loFlash, lcPath, lnHwnd, lnHandler, Init
	Local loFlash, lcPath, lnHwnd, lnHandler, Init
*!*		This.DeclareDlls()
	lcPath = Addbs(Alltrim(Justpath(Substr(Sys(16), ;
		AT("INIT", Sys(16)) + 5))))
	For Each loFlash As OleControl In This.Controls
*!*			loFlash.Movie = lcPath + "banner.swf"
		loFlash.Movie = GetFile('swf') && 'D:\Files\Flash\Temp.swf'
		loFlash.Play
		LoFlash.Anchor=240
	Endfor
	lnHandler = 0
	This.FlashCount = 0
*!*		If This.ShowWindow =
EndDefine
