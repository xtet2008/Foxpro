Procedure lResizeImage()
	Lparameters pSourceFileName,pNewFileName,nWidth,nHeight
	**************************************
	*{  resizeimage('e:\a.bmp','e:\b.bmp',nWidth ,nHeigh) }
	*如果nWidth 为0 那么以nHeigh来等比变化结果nWidth=原图片的宽度×nHeigh/ 原图片的高度
	*如果nHeigh 为0 那么以nWidth来等比变化结果nHeigh =原图片的高度×nWidth/ 原图片的宽度
	*如果两个都不为0 ，那么取nWidth ,nHeigh 的值
	*如果两个都为0 ，返回 .f.
	**************************************
	If !File(pSourceFileNAme)
		Messagebox("Images[ "+pSourceFileNAme+" ] not found")
		Return .F.
	EndIf
	If Vartype(pNewFileName)<>'C' Or Empty(Alltrim(pNewFileName)) Then
		Return .F.
	EndIf
	If Empty(nWidth) or Empty(nHeight) Then && 
		If Vartype(_Screen.Pic)='O' Then
			_Screen.RemoveObject('PIC')
		EndIf
		_Screen.AddObject( 'pic', 'Image' )
		_Screen.Pic.Picture=pSourceFileNAme
		If Empty(nWidth) And Empty(nHeight) Then
			nWidth=_Screen.Pic.Width
			nHeight=_Screen.Pic.Height
		Else
			If Empty(nWidth)
				nWidth =_Screen.Pic.Width/_Screen.Pic.Height*nHeight
			EndIf
			If Empty(nHeight)
				nHeight=_Screen.Pic.Height/_Screen.Pic.Width*nWidth
			Endif
		EndIf
		If Vartype(_Screen.Pic)='O' Then
			_Screen.RemoveObject('PIC')
		EndIf
	EndIf
	Private pSourceFileNAme,pNewFileNAme,nWidth,nHeight
	Declare Integer GdiplusStartup In GDIPlus;
		INTEGER @token, String @Input, Integer Output
	Local hToken, cInput
	hToken = 0
	cInput = Padr(Chr(1), 16, Chr(0))
	GdiplusStartup(@hToken, @cInput, 0)
	Declare Integer GdipLoadImageFromFile In GDIPlus.Dll ;
		STRING wFilename, Integer @nImage
	Local nImage
	nImage = 0
	GdipLoadImageFromFile(Strconv(pSourceFileNAme + Chr(0), 5), @nImage)
	#Define   GDIPLUS_PIXELFORMAT_32bppARGB          2498570
	Declare Integer GdipCreateBitmapFromScan0 In GDIPlus.Dll ;
		INTEGER nWidth, Integer nHeight, Integer nStride;
		, Integer nPixelFormat ;
		, String @ cScan0, Integer @ nImage
	Local nBitmap, nWidth, nHeight, nX, nY
	nBitmap = 0
	nX = 0
	nY = 0
	GdipCreateBitmapFromScan0(nWidth, nHeight, 0, GDIPLUS_PIXELFORMAT_32bppARGB, 0, @nBitmap)
	Declare Integer GdipGetImageGraphicsContext In GDIPlus.Dll ;
		INTEGER nImage, Integer @ nGraphics
	Local nGraphics
	nGraphics = 0
	GdipGetImageGraphicsContext (nBitmap, @nGraphics)
	Declare Integer GdipDrawImageRect In GDIPlus.Dll ;
		INTEGER nGraphics, Integer nImage, Single,Single,Single,Single
	GdipDrawImageRect(nGraphics, nImage, nX, nY, nWidth, nHeight)
	Local lcEncoder
	lcEncoder = Replicate(Chr(0),16)
	Declare Integer CLSIDFromString In ole32 String lpsz, String @pclsid
	CLSIDFromString(Strconv("{557CF401-1A04-11D3-9A73-0000F81EF32E}" + Chr(0), 5), @lcEncoder)
	Declare Integer GdipSaveImageToFile In GDIPlus.Dll ;
		INTEGER nImage, String wFilename, String qEncoder, Integer nEncoderParamsPtr
	Erase (pNewFileNAme)
	Declare Long GdipDisposeImage In GDIPlus.Dll Long nativeImage
	GdipDisposeImage(nImage)
	GdipSaveImageToFile (nBitmap, Strconv(pNewFileNAme,5) + Chr(0), lcEncoder, 0)
	Declare Integer GdiplusShutdown In GDIPlus Integer token
	GdiplusShutdown(hToken)
	Clear Dlls
	Return .T.
	*!* EndIf
EndProc

Procedure lJmailSendMail
	Lparameters cTo,cCC,cBCC,cSubject,cBody,cAttachment,cUserName,cPassword,cSmtp,cFrom,cCharset
	If Not LcIsString(cTo) and Not LcIsString(cCC) Then
		Wait window 'Please sure the recipient or cc not empty .'nowait
		Return .F.
	EndIf
	If Not LcIsString(cUserName) Then
		Wait window 'Please sure the smtp username not empty.' nowait
		Return .F.
	EndIf
	If Not LcIsString(cPassword) Then
		Wait window 'Please sure the smtp password not empty.' nowait
		Return .F.
	EndIf
	If Not LcIsString(cSmtp) Then
		Wait window 'Please sure the smtp is not empty.' nowait
		Return .F.
	EndIf
	If Not LcIsString(cFrom) Then
		cFrom=cUserName+'@'+Substr(cSmtp,At('.',cSmtp)+1)
	EndIf
	If Not LcIsString(cCharset) Then
		DECLARE Integer GetSystemDefaultLCID IN kernel32 As GetSystemDefaultLCID
		If GetSystemDefaultLCID()=2052 && GB2312
			cCharSet='GB2312'
		Else
			cCharSet='UTF-8'
		EndIf
	Else
		cCharSet=Upper(Alltrim(cCharSet))
	EndIf		
	Local oJmail,cOnError
	cOnError=On('Error')
	lError=.F.
	On Error lError=.T.
	oJmail=CreateObject('Jmail.Message')
	On Error &cOnError.
	If lError Then
		Wait window 'Please sure the file jmail.dll in your system and regsvr32 it . ' nowait
		Return .F.
	EndIf
*!*		Try 
*!*			oJmail=CreateObject('Jmail.Message')
*!*		Catch
*!*			oJmail=.Null.
*!*		EndTry
*!*		If IsNull(oJmail) Then
*!*			Wait window 'Please sure the file jmail.dll in your system and regsvr32 it . ' nowait
*!*			Return .F.
*!*		EndIf
	oJmail.Logging=.T.
	oJmail.Silent=.T.
	oJmail.From=cFrom
	If LcIsString(cTo) Then
		For nTag=1 to Occurs(';',cTo)+1
			If ','$LcSubstr(cTo,';',nTag) Then
				oJmail.AddRecipient(LcSubstr(LcSubstr(cTo,';',nTag),',',1),LcSubstr(LcSubstr(cTo,';',nTag),',',2))
			Else
				oJmail.AddRecipient(LcSubstr(cTo,';',nTag))
			EndIf
		EndFor
	EndIf
	If LcIsString(cCC) Then
		For nTag=1 to Occurs(';',cCC)+1
			If ','$LcSubstr(cTo,';',nTag) Then
				oJmail.AddRecipientCC(LcSubstr(LcSubstr(cCC,';',nTag),',',1),LcSubstr(LcSubstr(cCC,';',nTag),',',2))
			Else
				oJmail.AddRecipientCC(LcSubstr(cCC,';',nTag))
			EndIf
		EndFor
	EndIf
	If LcIsString(cBCC) Then
		For nTag=1 to Occurs(';',cBCC)+1
			If ','$LcSubstr(cTo,';',nTag) Then
				oJmail.AddRecipientBCC(LcSubstr(LcSubstr(cBCC,';',nTag),',',1),LcSubstr(LcSubstr(cBCC,';',nTag),',',2))
			Else
				oJmail.AddRecipientBCC(LcSubstr(cBCC,';',nTag))
			EndIf
		EndFor
	EndIf
	oJmail.Subject=Iif(LcIsString(cSubject),cSubject,'')
	oJmail.Body=Iif(LcIsString(cBody),cBody,'')
	If LcIsString(cAttachment) Then
		For nTag=1 to Occurs(';',cAttachment)+1
			set step on
			oJmail.AddAttachment(LcSubstr(cAttachment,';',nTag))
		EndFor
	EndIf
	oJmail.Charset=cCharSet
	If oJmail.Send(cUserName+':'+cPassword+'@'+cSmtp) Then
		Return .T.
	Else
		Wait window oJmail.ErrorMessage nowait
		Return .F.
	EndIf
Endproc

Procedure GbConvert
	Lparameter LCVALUE , LCTYPE
	If Parameters() < 2
		Wait Window Nowait 'Please type the convert value and convert type !'
		Return ''
	Endif
	If Vartype(LCVALUE) <> 'C'
		Wait Window Nowait 'Please sure the convert value in character ! '
		Return ''
	Else
		If Empty(LCVALUE)
			Return ''
		Endif
	Endif
	If Vartype(LCTYPE) <> 'N'
		Wait Window Nowait 'Please sure the convert type in number !'
		Return ''
	Else
		If  .Not. (LCTYPE = 1 .Or. LCTYPE = 2)
			Wait Window Nowait 'Please sure the convert type in 1 or 2 !'
			Return ''
		Endif
	Endif
	Local LCTEMPVALUE
	LCTEMPVALUE = LCVALUE
	*!*		Declare Integer GBToBig5 In 'mchset.dll' String @
	*!*		Declare Integer Big5ToGB In 'mchset.dll' String @
	If LCTYPE = 1 && Gb2321 -> Big5
		LcTempValue=cConvert(LcTempValue,6) && Gbk -> Gb2321
		LcTempValue=cConvert(LcTempValue,2) && Gb2312 -> Big5
	Else && Big5 -> Gb2312
		LCTEMPVALUE=cConvert(LcTempValue,3) && Big5 -> Gb2312
	Endif
	Return LCTEMPVALUE
Endproc

Procedure cConvert
	Lparameters HzStr,HzType
	If Pcount()<>2
		Wait window nowait "有两个参数前一个为传递的字符"+Chr(13)+"后一个为变换的类型"
		Return HzStr
	Endif
	If Vartype(HzType)#"N"
		Wait window "参数类型不正确，应该为数字型。" Nowait
		Return HzStr
	EndIf
	If Not InList(HzType,0,1,2,3,4,5,6) Then
		Return HzStr
	EndIf
	If HzType=0 Then
		Return HzStr
	EndIf
	
	HzStr=Strconv(HzStr,2)
	Local nSelect,cReturnValue,EndChar
	cReturnValue=''
	EndChar=""
	nSelect=Select()
	If Not Used('Hanzi') Then
		Use in 0 HanZi
	EndIf
	Select HANZI
	Do Case
		Case HzType=1&&简－>假繁
			Set Order To GB2312   && JTZI
			For HzLenStr=1 To Lenc(HzStr)
				TempStr=Substrc(HzStr,HzLenStr,1)
				IF InList(TempStr,Chr(9),Chr(10),Chr(13),Chr(32)) or TempStr$" ,.，。;；<>()*$@!0123456789=/\#&-[]{}?+abcdefghigklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
					EndChar=EndChar+TempStr
				else
					If Seek(TempStr)
						EndChar=EndChar+Alltrim(jft)
					ELSE
						EndChar=EndChar+TempStr
					ENDIF
				endif
			ENDFOR
			cReturnValue=EndChar
		Case HzType=2&&简－>真繁
			Set Order To GB2312   && JTZI
			For HzLenStr=1 To Lenc(HzStr)
				TempStr=Substrc(HzStr,HzLenStr,1)
				IF InList(TempStr,Chr(9),Chr(10),Chr(13),Chr(32)) or TempStr$" ,.，。;；<>()*$@!0123456789=/\#&-[]{}?+abcdefghigklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
					EndChar=EndChar+TempStr
				else
					If Seek(TempStr)
						EndChar=EndChar+Alltrim(zft)
					ELSE
						EndChar=EndChar+TempStr
					ENDIF
				endif
			ENDFOR
			cReturnValue=EndChar
		Case HzType=3&&真繁->简
			Set Order To BIG5   && ZFT
			For HzLenStr=1 To Lenc(HzStr)
				TempStr=Substrc(HzStr,HzLenStr,1)
				IF InList(TempStr,Chr(9),Chr(10),Chr(13),Chr(32)) or TempStr$" ,.，。;；<>()*$@!0123456789[]{}?+=/\#&-abcdefghigklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
					EndChar=EndChar+TempStr
				else
					If Seek(TempStr)
						EndChar=EndChar+Alltrim(jtzi)
					ELSE
						EndChar=EndChar+TempStr
					ENDIF
				endif
			ENDFOR
			cReturnValue=EndChar
		Case HzType=4&&真繁->假繁
			Set Order To BIG5   && ZFT
			For HzLenStr=1 To Lenc(HzStr)
				IF InList(TempStr,Chr(9),Chr(10),Chr(13),Chr(32)) or TempStr$" ,.，。;；<>()*$@!0123456789=/\#&-a[]{}?+bcdefghigklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
					EndChar=EndChar+TempStr
					EndChar=EndChar+" "
				else
					If Seek(TempStr)
						EndChar=EndChar+Alltrim(jft)
					ELSE
						EndChar=EndChar+TempStr
					ENDIF
				endif
			ENDFOR
			cReturnValue=EndChar
		Case HzType=5&&假繁->真繁
			Set Order To GBK   && JFT
			For HzLenStr=1 To Lenc(HzStr)
				TempStr=Substrc(HzStr,HzLenStr,1)
				IF InList(TempStr,Chr(9),Chr(10),Chr(13),Chr(32)) or TempStr$" ,.，。;；<>()*$@!0123456789=/\#&-a[]{}?+bcdefghigklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
					EndChar=EndChar+TempStr
				else
					If Seek(TempStr)
						EndChar=EndChar+Alltrim(zft)
					ELSE
						EndChar=EndChar+TempStr
					ENDIF
				endif
			ENDFOR
			cReturnValue=EndChar
		Case HzType=6&&假繁->简体
			Set Order To GBK   && JFT
			For HzLenStr=1 To Lenc(HzStr)
				TempStr=Substrc(HzStr,HzLenStr,1)
				IF InList(TempStr,Chr(9),Chr(10),Chr(13),Chr(32)) or TempStr$" ,.，。;；<>()*$@!0123456789=/\#&-[]{}?+abcdefghigklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
					EndChar=EndChar+TempStr
				else
					If Seek(TempStr)
						EndChar=EndChar+Alltrim(jtzi)
					ELSE
						EndChar=EndChar+TempStr
					ENDIF
				endif
			ENDFOR
			cReturnValue=EndChar
	EndCase
	Select (nSelect)
	If Used('Hanzi') Then
		Use in Hanzi
	EndIf
	Return cReturnValue
EndProc

Procedure LcIsString(cString,lForce)
	If lForce Then
		If Vartype(cString)<>'C' Then
			Return .F.
		Else
			Return .T.
		EndIf
	Else  && Ignore all empty string
		If Vartype(cString)<>'C' Or Empty(Alltrim(cString)) Then
			Return .F.
		Else
			Return .T.
		EndIf
	EndIf
EndProc

Procedure LcSubstr
	Parameter SUBSTR_VALUE , SUBSTR_PLUS , SUBSTR_INDEX , SUBSTR_TRIM
	If Vartype(SUBSTR_VALUE) <> 'C' .Or. Empty(SUBSTR_VALUE)
		Return ''
	Endif
	If Vartype(SUBSTR_TRIM) <> 'L'
		SUBSTR_TRIM = .F.
	Endif
	If Vartype(SUBSTR_PLUS) <> 'C' .Or. Asc(SUBSTR_PLUS)=0 && no any character
		SUBSTR_PLUS = ','
	Endif
	If Vartype(SUBSTR_INDEX) <> 'N'
		SUBSTR_INDEX = 0
	Else
		If SUBSTR_INDEX < 0
			SUBSTR_INDEX = 0
		Endif
	Endif
	If  .Not. (SUBSTR_PLUS $ SUBSTR_VALUE) .Or. SUBSTR_INDEX = 0
*!*			Wait Window Nowait 'Because the plus is empty or character index is 0 !'
		If SUBSTR_TRIM
			Return Alltrim(SUBSTR_VALUE)
		Else
			Return SUBSTR_VALUE
		Endif
	Endif
	SUBSTR_VALUE = Strtran(SUBSTR_VALUE,SUBSTR_PLUS,Chr(13) + Chr(10))
	If Alines(SUBSTR_ARRAY,SUBSTR_VALUE) < 2
		If SUBSTR_TRIM
			Return Alltrim(SUBSTR_VALUE)
		Else
			Return SUBSTR_VALUE
		Endif
	Else
		If Alen(SUBSTR_ARRAY) >= SUBSTR_INDEX
			If SUBSTR_TRIM
				Return Alltrim(SUBSTR_ARRAY(SUBSTR_INDEX))
			Else
				Return SUBSTR_ARRAY(SUBSTR_INDEX)
			Endif
		Else
			Wait Window Nowait  ;
				'Because the character index large than character counts, Programe will be get the last index of character value !'
			If SUBSTR_TRIM
				Return Alltrim(SUBSTR_ARRAY(Alen(SUBSTR_ARRAY)))
			Else
				Return SUBSTR_ARRAY(Alen(SUBSTR_ARRAY))
			Endif
		Endif
	Endif
Endproc

