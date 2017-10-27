PROCEDURE itmsg
	LPARAMETER PLKEY , PLFIELD , PLREMARKS , PLLANG , PLFORM
	LOCAL PLSELECTITMSG , PLITMSG , PLITLANG
	SET TALK OFF
	PLITMSG = ''
	PLSELECTITMSG = SELECT()
	SELECT 0
	PLITLANG = DEF_LANG
	IF  .NOT. EMPTY(PLLANG)
		PLITLANG = PLLANG
	ENDIF
	IF  .NOT. EMPTY(PLFIELD)
		IF  .NOT. USED('itmsg')
			USE IN 0 caption AGAIN ALIAS itmsg ORDER id
		ELSE
			SELECT itmsg
			SET ORDER TO id
		ENDIF
		SELECT itmsg
		SEEK ALLTRIM(UPPER(PLKEY)) + PLITLANG
		IF FOUND()
			PLITMSG=alltrim(&PLFIELD.)
		ENDIF
	ELSE
		IF  .NOT. USED('itmessag')
			IF FILE('itmessag.dbf')
				USE IN 0 itmessag AGAIN ORDER id
			ELSE
				USE IN 0 (GCOLDDIR + 'include\itmessag') AGAIN ALIAS itmessag ORDER id
			ENDIF
		ELSE
			SELECT itmessag
			SET ORDER TO id
		ENDIF
		SELECT itmessag
		SEEK PLITLANG + SUBSTR(UPPER(PLKEY),1,5)
		IF FOUND()
			PLITMSG = ALLTRIM(MESSAGE)
			IF  .NOT. EMPTY(PLFORM)
				IF UPPER(PLFORM) = 'BUTTON' .OR. UPPER(ALLTRIM(PLFORM)) = '1'
					PLITMSG = ALLTRIM(BUTTON)
				ENDIF
				IF UPPER(PLFORM) = 'SHORTFORM' .OR. UPPER(ALLTRIM(PLFORM)) = '2'
					PLITMSG = ALLTRIM(SHORTFORM)
				ENDIF
				IF UPPER(PLFORM) = 'HELP' .OR. UPPER(ALLTRIM(PLFORM)) = '3'
					PLITMSG = ALLTRIM(HELP)
				ENDIF
			ENDIF
		ENDIF
	ENDIF
	SELECT (PLSELECTITMSG)
	RETURN PLITMSG
ENDPROC

Procedure dataint
	Lparamete Lcscreen_id,LcAlias,lTag
	Local cReturnValue
	cReturnValue = ''
	IF PCOUNT()<1
		Return cReturnValue
	ENDIF
	Lcscreen_id=Upper(Lcscreen_id)
	*set step on
	IF Pcount()=2 and !Empty(LcAlias)
		Caption_alias = Allt(LcAlias)
	Else
		Caption_alias = "caption_"+Allt(Lcscreen_id)
	Endif
	if !used(Caption_alias)
		use caption in 0 again alias &Caption_alias. order screen_id
	Endif
	Select (Caption_alias)
	Local LcSet_Filter
	If lTag Then
		LcSet_Filter = "Set Filter to Allt(Upper(screen_id)) = '"+Lcscreen_id+"'" && and language = '"+DEF_LANG+"'"
	Else
		LcSet_Filter =  "Set Filter to '" + Lcscreen_id+"'=Allt(Upper(screen_id))"  && and language = '"+DEF_LANG+"'" && Commend by roger at 2010-07-26 15:45
	EndIf
	*LcSet_Filter = "Set Filter to Allt(Upper(screen_id)) = '"+Lcscreen_id+"' and language = '"+DEF_LANG+"'"
	&LcSet_Filter.
	LOCATE FOR language = DEF_LANG
	cReturnValue = It_program
	
	Return cReturnValue
EndProc

Procedure repoint
	paramete Lcscreen_id
	IF PCOUNT()<1
		RETURN
	ENDIF
	Lcscreen_id=Upper(Lcscreen_id)
	*set step on
	if !used('repolist')
		use repolist in 0 again  order ctype
	Endif
	Select repolist
	Local LcSet_Filter
	LcSet_Filter = "Set Filter to Allt(Upper(screen_id)) = '"+Lcscreen_id+"'"
	&LcSet_Filter.
	*	Set Filter to Allt(Upper(screen_id)) = Lcscreen_id
	*!*		IF !EOF()
	*!*			skip
	*!*		Endif
*!*		Select 0
ENDPROC


*===============================================================*
procedure  error_process         &&...PROCESS ERROR
	*===============================================================*
	parameter lhandler,lmessage,lposition,lline,lprocode
	do case
		case lhandler = 109 or lhandler = 108
			if cursorgetprop('BUFFERING') > 1
				=tablerevert()
			endif
			=messagebox('其他用户正在使用该资料!'+chr(13)+chr(13)+'本次操作被撤消!',48,'系统信息')
		case lhandler = 1884
			if cursorgetprop('BUFFERING') > 1
				=tablerevert()
			endif
			=messagebox('己存在该关键码的资料!'+chr(13)+chr(13)+'本次操作被撤消!',48,'系统信息')
		case lhandler = 1585
			if cursorgetprop('BUFFERING') > 1
				=tablerevert()
			endif
			=messagebox('其它用户刚修改了该资料!'+chr(13)+chr(13)+'请参照后再作修改!',48,'系统信息')

		case lhandler = 1582 or lhandler = 1502 or lhandler = 1539
			if cursorgetprop('BUFFERING') > 1
				=tablerevert()
			endif
		case lhandler = 1104
			if cursorgetprop('BUFFERING') > 1
				=tablerevert()
			endif
			=messagebox('从磁盘或网络读取资料失败!',16,'系统信息')
			Return
		case lhandler = 2005 or lhandler = 1705
			=messagebox('错误号2005/1705: '+ltrim(str(lhandler,5))+chr(13)+'原因: '+lmessage+chr(13);
				+'源代码：'+lprocode+chr(13)+chr(13)+'出错处: '+lposition+'(第'+ltrim(str(lline,4));
				+'行)'+chr(13)+'erritm:',48,'系统信息')  &&+ _erritm

		other
			=messagebox('错误号: '+ltrim(str(lhandler,5))+chr(13)+'原因: '+lmessage+chr(13);
				+'源代码：'+lprocode+chr(13)+chr(13)+'出错处: '+lposition+'(第'+ltrim(str(lline,4));
				+'行)'+chr(13)+'erritm:',48,'系统信息')  &&+ _erritm
	endcase
	_iserror = .t.
	return
EndProc