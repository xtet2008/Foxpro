Define Class Upload as Custom olepublic
	oTemp=CreateObject('oForm')
	oTemp.Show()
	Read events
	Define Class oForm as Form 
*!*	*!*			local cReturnValue
*!*			cReturnValue=''
*!*			Add Object Btn_Ok as CommandButton
*!*			Procedure Btn_ok.Click
*!*				cReturnValue=Getpict()
*!*			EndProc
*!*			Add Object Btn_Cancel as CommandButton
*!*	*!*			Procedure Btn_Cancel.Click()
*!*	*!*				ThisForm.Release()
*!*	*!*			Endproc
		Procedure Click
			Return Getpict()
			Clear event
		EndProc
		Procedure Destroy
*!*				Return cReturnValue
		Endproc
	EndDefine
EndDefine