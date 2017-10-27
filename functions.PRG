*********************************************************
* 函数名称:--IsObject()
* 创建时间:--2008 -07-07
* 目 的:--判断所给变量是否为对象
* 参 数:
* voObject:--对象的引用
Function IsObject(voObject)
	Local llOK
	llOK = .T.
	If Not Type ('voObject') == "O"
		llOK = .F.
	Else
		If IsNull (voObject)
			llOK = .F.
		EndIf
	EndIf
	Return llOK
EndFunc

*********************************************************
* 函数名称:--GetBaseClass()
* 创建时间:--2008 -07-07
* 目 的:--返回所给对象的基类(大写字母)
* 参 数:
* voObject:--对象的引用
Function GetBaseClass(voObject)
	Local lcRetVal
	lcRetVal = ""
	If IsObject(voObject)
		If HasPEM(voObject,"BaseClass")
			If Type ('voObject.BaseClass') == "C"
				lcRetVal = Upper (voObject. BaseClass )
			EndIf
		EndIf
	EndIf
	Return lcRetVal
EndFunc

*********************************************************
* 函数名称:--CloseLib()
* 创建时间:--2009 -01-05
* 目 的:-- 关闭指定的过程库（.Prg）/类库（.VCX）
* 参 数:
* vcLib:----指定要关闭的过程库文件（.Prg）/类库（.VCX）
* 注意：必须带扩展名
Procedure CloseLib(vcLib)
	Local lcExt
	lcExt= Upper ( JustExt (vcLib))
	Do Case
		Case lcExt=="VCX"
			If Upper (vcLib) $ Upper ( Set ("ClassLib"))
				Release Classlib (vcLib)
			EndIf
		Case lcExt=="PRG"
			Local lcProc
			lcProc= ForceExt (vcLib,'FXP')
			If Upper (lcProc) $ Upper ( Set ("Procedure"))
				Release Procedure (vcLib)
			EndIf
		Otherwise
	EndCase
EndProc

*********************************************************
* 函数名称:--OpenLib()
* 创建时间:--2009 -01-05
* 目 的:-- 打开指定的过程库（.Prg）/类库（.VCX）
* 参 数:
* vcLib:----指定要打开的过程库文件（.Prg）/类库（.VCX）
* 注意：必须带扩展名
Procedure OpenLib(vcLib)
	Local lcExt As String
	lcExt= Upper ( JustExt (vcLib))
	Do Case
		Case lcExt=="VCX"
			If Not ( Upper (vcLib) $ Upper ( Set ("ClassLib")))
				Set Classlib To (vcLib) Additive
			EndIf
		Case lcExt=="PRG"
			Local lcProc
			lcProc= ForceExt (vcLib,'FXP')
			If Not ( Upper (lcProc)$ Upper ( Set ("Procedure")))
				Set Procedure To (vcLib) Additive
			EndIf
		Otherwise
	EndCase
EndProc

*********************************************************
* 函数名称:--HasPEM()
* 创建时间:--2008 -07-18
* 目 的:--判断某对象是否具有给定的属性
* 参 数:
* voObj:----对象引用
* vcPEM:----给定的属性
Function HasPEM(voObj,vcPEM)
	Local llOK
	llOK = .T.
	If Not IsObject(voObj)
		llOK = .F.
	Else
		If Not PemStatus (voObj,vcPEM,5)
			llOK = .F.
		EndIf
	EndIf
	Return llOK
EndFunc

*********************************************************
* 函数名称:--OGetClass()
* 创建时间:--2008 -07-29
* 目 的:--从选择的类库中，返回选择的类及类库对象
* 参 数:
* 返回值:对象
* 对象属性:
* --Classlib:--类库
* --ClassName:--类名称
* --ClassPath:--类库文件的路径
Function OGetClass()
	Local loClass
	Dimension gaClassLib[2]
	loClass = .NULL.
	AGETCLASS (gaClassLib) && 显示对话框。
	IF VarTYPE (gaClassLib(2)) == 'C' && 选择了类?
		loClass= CreateObject ("Empty")
		AddProperty (loClass,"Classlib", Alltrim (gaClassLib(1)))
		AddProperty (loClass,"ClassName", Alltrim (gaClassLib(2)))
		AddProperty (loClass,"ClassPath", Addbs ( JustPath (gaClassLib(1))))
	EndIf
	Return loClass
EndFunc

*********************************************************
* 函数名称:--GetTodayDT()
* 创建时间:--2008 -07-15
* 目 的:--返回当天的日期和时间
* 参 数:
* vcTag: D--日期，T--时间，W--星期
Function GetToDayDT(vcTag)
	Local lcRet
	If IsType(vcTag,"C") .And. ! Empty (vcTag)
		vcTag = Upper (vcTag)
	Else
		vcTag = "DTW"
	EndIf
	lcRet=""
	*----日期部分
	If "D" $ vcTag
		lcRet=lcRet+ Dtoc ( Date ())+ Space (1)
	EndIf
	*----星期部分
	If "W" $ vcTag
		lcRet=lcRet+ ICase ( Dow ( Date ())==1, "星期日" ,;
		Dow ( Date ())==2, "星期一" ,;
		Dow ( Date ())==3, "星期二" ,;
		Dow ( Date ())==4, "星期三" ,;
		Dow ( Date ())==5, "星期四" ,;
		Dow ( Date ())==6, "星期五" ,;
		Dow ( Date ())==7, "星期六" ,"")+ Space (1)
	EndIf
	*----时间部分
	If "T" $ vcTag
		lcRet=lcRet+ Time ( Date ())
	EndIf
	Return lcRet
EndFunc

*********************************************************
* 函数名称:--GetFirstLetter()
* 创建时间:--2008 -07-15
* 目 的:--返回汉字串的首字母序列
* 参 数:
* vcHzString:--汉字串
Function GetFirstLetter(vcHzString)
	Local tCh &&----临时单元
	Local CLists &&----存放所有国标二级汉字读音首字母
	Local cRetStr &&----返回串
	Local I, J
	Local nQCode &&----汉字区码
	Local nWCode &&----汉字位码
	Local nQWCode &&----汉字区位码
	Local nOffSet &&- ---二级字库偏移量
	Local CLPos &&--存放国标一级汉字不同读音的起始区
	&&--位码以及一级汉字不同读音的起始区
	&&--位码对应读音
	Local lcNums,lcKeys,K
	lcNums= [1601,1637,1833,2078,2274,2302,2433,2594,2787,3106,3212,3472,3635,3722,3730,]+;
	[3858,4027,4086,4390,4558,4684,4925,5249,]
	lcKeys = [A,B,C,D,E,F,G,H,J,K,L,M,N,O,P,Q,R,S,T,W,X,Y,Z]

	CLPos= CreateObject ("Collection")
	For K = 1 To 23
		CLPos. Add ( Int ( Val ( GetWordNum (lcNums,K,[,]))), GetWordNum (lcKeys,K,[,]))
	EndFor

	CLists="CQWGNSPGCGNEGYPBTYYZDXYKYGT[JNNJQMBSGZSCYJSYY[PGKBZGY[YWJKGKLJYWKPJQHY[W["+;
	"DZLSGMRYPYWWCCKZNKYYGTTNJJNYKKZYTCJNMCYLQLYPYQFQRPZSLWBTGKJFYXJWZLTBNCXJJ"+;
	"JJTXDTTSQZYCDXXHGCK[PHFFSS[YBGXLPPBYLL[HLXS[ZM[JHSOJNGHDZQYKLGJHSGQZHXQGK"+;
	"EZZWYSCSCJXYEYXADZPMDSSMZJZQJYZC[J[WQJBYZPXGZNZCPWHKXHQKMWFBPBYDTJZZKQHYL"+;
	"YGXFPTYJYYZPSZLFCHMQSHGMXXSXJ[[DCSBBQBEFSJYHXWGZKPYLQBGLDLCCTNMAYDDKSSNGY"+;
	"CSGXLYZAYBNPTSDKDYLHGYMYLCXPY[JNDQJWXQXFYYFJLEJPZRXCCQWQQSBNKYMGPLBMJRQCF"+;
	"LNYMYQMSQYRBCJTHZTQFRXQHXMJJCJLXQGJMSHZKBSWYEMYLTXFSYDSWLYCJQXSJNQBSCTYHB"+;
	"FTDCYZDJWYGHQFRXWCKQKXEBPTLPXJZSRMEBWHJLBJSLYYSMDXLCLQKXLHXJRZJMFQHX HWYWS"+;
	"BHTRXXGLHQHFNM[YKLDYXZPYLGG[MTCFPAJJZYLJTYANJGBJPLQGDZYQYAXBKYSECJSZNSLYZ"+;
	"HSXLZCGHPXZHZNYTDSBCJKDLZAYFMYDLEBBGQYZKXGLDNDNYSKJSHDLYXBCGHXYPKDJMMZNGM"+;
	"MCLGWZSZXZJFZNMLZZTHCSYDBDLLSCDDNLKJYKJSYCJLKWHQASDKNHCSGANHDAASHTCPLCPQY"+;
	"BSDMPJLPZJOQLCDHJJYSPRCHN[NNLHLYYQYHWZPTCZGWWMZFFJQQQQYXACLBHKDJXDGMMYDJX"+;
	"ZLLSYGXGKJRYWZWYCLZMSSJZLDBYD[FCXYHLXCHYZJQ[[QAGMNYXPFRKSSBJLYXYSYGLNSCMH"+;
	"ZWWMNZJJLXXHCHSY[[TTXRYCYXBYHCSMXJSZNPWGPXXTAYBGAJCXLY[DCCWZOCWKCCSBNHCPD"+;
	"YZNFCYYTYCKXKYBSQKKYTQQXFCWCHCYKELZQBSQYJQCCLMTHSYWHMKTLKJLYCXWHEQQHTQH[P"+;
	"Q[QSCFYMNDMGBWHWLGSLLYSDLMLXPTHMJHWLJZYHZJXHTXJLHXRSWLWZJCBXMHZQXSDZ PMGFC"+;
	"SGLSXYMJSHXPJXWMYQKSMYPLRTHBXFTPMHYXLCHLHLZYLXGSSSSTCLSLDCLRPBHZHXYYFHB[G"+;
	"DMYCNQQWLQHJJ[YWJZYEJJDHPBLQXTQKWHLCHQXAGTLXLJXMSL[HTZKZJECXJCJNMFBY[SFYW"+;
	"YBJZGNYSDZSQYRSLJPCLPWXSDWEJBJCBCNAYTWGMPAPCLYQPCLZXSBNMSGGFNZJJBZSFZYNDX"+;
	"HPLQKZCZWALSBCCJX[YZGWKYPSGXFZFCDKHJGXDLQFSGDSLQWZKXTMHSBGZMJZRGLYJBPMLMS"+;
	"XLZJQQHZYJCZYDJWBMYKLDDPMJEGXYHYLXHLQYQHKYCWCJMYYXNATJHYCCXZPCQLBZWWYTWBQ"+;
	"CMLPMYRJCCCXFPZNZZLJPLXXYZTZLGDLDCKLYRZZGQTGJHHGJLJAXFGFJZSLCFDQZLCLGJDJC"+;
	"SNZLLJPJQDCCLCJXMYZFTSXGCGSBRZXJQQCTZHGYQTJQQLZXJYLYLBCYAMCSTYLPDJBYREGKL"+;
	"ZYZHLYSZQLZNWCZCLLWJQJJJKDGJZOLBBZPPGLGHTGZXYGHZMYCNQSYCYHBHGXKAMTXY XNBSK"+;
	"YZZGJZLQJDFCJXDYGJQJJPMGWGJJJPKQSBGBMMCJSSCLPQPDXCDYYKY[CJDDYYGYWRHJRTGZN"+;
	"YQLDKLJSZZGZQZJGDYKSHPZMTLCPWNJAFYZDJCNMWESCYGLBTZCGMSSLLYXQSXSBSJSBBSGGH"+;
	"FJLYPMZJNLYYWDQSHZXTYYWHMZYHYWDBXBTLMSYYYFSXJC[DXXLHJHF[SXZQHFZMZCZTQCXZX"+;
	"RTTDJHNNYZQQMNQDMMG[YDXMJGDHCDYZBFFALLZTDLTFXMXQZDNGWQDBDCZJDXBZGSQQDDJCM"+;
	"BKZFFXMKDMDSYYSZCMLJDSYNSBRSKMKMPCKLGDBQTFZSWTFGGLYPLLJZHGJ[GYPZLTCSMCNBT"+;
	"JBQFKTHBYZGKPBBYMTDSSXTBNPDKLEYCJNYDDYKZDDHQHSDZSCTARLLTKZLGECLLKJLQJAQNB"+;
	"DKKGHPJTZQKSECSHALQFMMGJNLYJBBTMLYZXDCJPLDLPCQDHZYCBZSCZBZMSLJFLKRZJSNFRG"+;
	"JHXPDHYJYBZGDLQCSEZGXLBLGYXTWMABCHECMWYJYZLLJJYHLG[DJLSLYGKDZPZXJYYZ LWCXS"+;
	"ZFGWYYDLYHCLJSCMBJHBLYZLYCBLYDPDQYSXQZBYTDKYXJY[CNRJMPDJGKLCLJBCTBJDDBBLB"+;
	"LCZQRPPXJCJLZCSHLTOLJNMDDDLNGKAQHQHJGYKHEZNMSHRP[QQJCHGMFPRXHJGDYCHGHLYRZ"+;
	"QLCYQJNZSQTKQJYMSZSWLCFQQQXYFGGYPTQWLMCRNFKKFSYYLQBMQAMMMYXCTPSHCPTXXZZSM"+;
	"PHPSHMCLMLDQFYQXSZYYDYJZZHQPDSZGLSTJBCKBXYQZJSGPSXQZQZRQTBDKYXZKHHGFLBCSM"+;
	"DLDGDZDBLZYYCXNNCSYBZBFGLZZXSWMSCCMQNJQSBDQSJTXXMBLTXZCLZSHZCXRQJGJYLXZFJ"+;
	"PHYMZQQYDFQJJLZZNZJCDGZYGCTXMZYSCTLKPHTXHTLBJXJLXSCDQXCBBTJFQZFSLTJBTKQBX"+;
	"XJJLJCHCZDBZJDCZJDCPRNPQCJPFCZLCLZXZDMXMPHJSGZGSZZQLYLWTJPFSYASMCJBTZKYCW"+;
	"MYTCSJJLJCQLWZMALBXYFBPNLSFHTGJWEJJXXGLLJSTGSHJQLZFKCGNNNSZFDEQFHBSA QTGYL"+;
	"BXMMYGSZLDYDQMJJRGBJTKGDHGKBLQKBDMBYLXWCXYTTYBKMRTJZXQJBHLMHMJJZMQASLDCYX"+;
	"YQDLQCAFYWYXQHZ"
	cRetStr = ""
	For I=1 To Lenc (vcHzString) &&----依次处理tcHzString中每个字符
		tCh = Substrc (vcHzString,I,1)
		IF Asc (tCh) < 128 &&----非汉字
			cRetStr = cRetStr+tCh &&----不变
		ELSE &&----是汉字
			nQCode = Asc ( Left (tCh,1)) - 160 &&----区码
			nWCode = Asc ( Right (tCh,1)) - 160 &&----位码
			nQWCode = nQCode * 100 + nWCode &&----区位码
			IF nQWCode > 1600 AND nQWCode < 5590 &&----一级汉字
				For J = 23 To 1 Step -1 &&----找声母
					IF nQWCode >= CLPos. Item (J) THEN
						cRetStr = cRetStr + Lower (CLPos. GetKey (J))
						EXIT
					EndIf
				EndFor
			Else
				IF nQWCode > 5600 AND nQWCode < 8795 THEN &&----二级汉字
					nOffSet = (nQCode - 56) * 94 + nWCode &&----计算偏移量
					&&--取汉字对应声母
					cRetStr = cRetStr + Lower ( Substrc (CLists,nOffSet,1))
				EndIf
			EndIf
		EndIf
	EndFor
	RETURN Upper (cRetStr) &&----返回 vcHzString 的声母串
EndFunc

*********************************************************
* 函数名称:--GetUserName()
* 创建时间:--2008 -07-16
* 目 的:--取得本机用户名
* 参 数:
* 注意:Sys(0)返回:<机器名>#<用户名>
Function GetUserName()
	Local lcName
	lcName = GetWordNum ( Sys (0),2,[#])
	Return Alltrim (lcName)
EndFunc

*********************************************************
* 函数名称:--GetComputerName()
* 创建时间:--2008 -07-16
* 目 的:--取得计算机名称
* 参 数:
* 注意:Sys(0)返回:<机器名>#<用户名>
Function GetComputerName()
	Local lcName
	lcName = GetWordNum ( Sys (0),1,[#])
	Return Alltrim (lcName)
EndFunc

*********************************************************
* 函数名称:--DelChars()
* 创建时间:--2008-08-01
* 目 的:--删除字符串中指定的字符
* 参 数:
* vcStr - 字符串变量
* vcCha r - 要删除的字符
Function DelChars(vcStr,vcChar)
	Return Strtran (vcStr,vcChar,"")
EndFunc

*********************************************************
* 函数名称:--SetIDE()
* 创建时间:--2008 -09-21
* 目 的:--设置环境,并返回一个命令的原设置
* 参 数:
* vcIDECmd:--IDE命令字符串
Function SetIDE(vcIDECmd)
	Local lcRetVal,lcCommand
	vcIDECmd= Alltrim (vcIDECmd)
	lcCommand= GetWordNum (vcIDECmd,2, Chr (32))
	lcCommand= Alltrim (lcCommand)
	lcRetVal= Set (lcCommand)
	_VFP .DoCmd(vcIDECmd)
	Return lcRetVal
EndFunc

*********************************************************
* 函数名称:--OVcxClasses()
* 创建时间:--2008 -07-31
* 目 的:--将指定类库中的类名(ClassName)、基类(BaseClass)、
* 父类(ParentClass)、类库(Classlib)
* 信息放入对象中，并返回对象的集合。
* 参 数:
* vcClib - 类库文件名
Function OVcxClasses(vcClib)
	vcClib= Alltrim (vcClib)
	Local lnRows,K,J,loClass,loCObj,lcLib
	lnRows= AVcxClasses (gaClass,vcClib)
	If lnRows>0
		loClasses= CreateObject ("Collection")
		For K=1 To lnRows
			lcLib= Alltrim (gaClass[K,4])
			loCObj= CreateObject ("Empty")
			AddProperty (loCObj,"ClassName", Alltrim (gaClass[K,1]))
			AddProperty (loCObj,"BaseClass", Alltrim (gaClass[K,2]))
			AddProperty (loCObj,"ParentClass", Alltrim (gaClass[K,3]))
			AddProperty (loCObj,"Classlib", Iif (! Empty (lcLib),lcLib,vcClib))
			loClasses. Add (loCObj)
		EndFor
	EndIf
	Return (loClasses)
EndFunc

*********************************************************
* 函数名称:--GetCHStr()
* 创建时间:--2008 -10-13
* 目 的:--从字符串中提取汉字,返回汉字串。
* 参 数:
* vcString:--字符串
Function GetCHStr(vcString)
	vcString= Alltrim (vcString)
	Local lnI,lnLength,lcRetval,lcStr
	lcRetval=""
	lnLength= Lenc (vcString)
	If lnLength>0
		For lnI=1 To lnLength
			lcStr= Substrc (vcString,lnI,1)
			If IsLeadByte (lcStr)
				lcRetval=lcRetval+lcStr
			EndIf
		EndFor
	EndIf
	Return (lcRetval)
Endfunc

*********************************************************
* 函数名称:--GetENStr()
* 创建时间:--2008 -10-13
* 目 的:--从字符串中提取字母串,返回字母串。
* 参 数:
* vcString:--字符串
Function GetENStr(vcString)
	vcString= Alltrim (vcString)
	Local lnI,lnLength,lcRetval,lcStr
	lcRetval=""
	lnLength= Lenc (vcString)
	If lnLength>0
		For lnI=1 To lnLength
			lcStr= Substrc (vcString,lnI,1)
			If Isalpha (lcStr) And ! Isleadbyte (lcStr)
				lcRetval=lcRetval+lcStr
			EndIf
		EndFor
	Endif
	Return (lcRetval)
EndFunc

*********************************************************
* 函数名称 :--GetNumStr()
* 创建时间:--2008 -10-13
* 目 的:--从字符串中提取数字串,返回数字串。
* 参 数:
* vcString:--字符串
Function GetNumStr(vcString)
	vcString= Alltrim (vcString)
	Local lnI,lnLength,lcRetval,lcStr
	lcRetval=""
	lnLength= Lenc (vcString)
	If lnLength>0
		For lnI=1 To lnLength
			lcStr= Substrc (vcString,lnI,1)
			If Isdigit (lcStr)
				lcRetval=lcRetval+lcStr
			EndIf
		EndFor
	Endif
	Return (lcRetval)
EndFunc

*********************************************************
* 函数名称:--GetCNEStr()
* 创建时间:--2008 -10-13
* 目 的:--从字符串中提取汉字、数字串和字母,返回串。
* 参 数:
* vcString:--字符串
Function GetCNEStr(vcString)
	vcString= Alltrim (vcString)
	Local lnI,lnLength,lcRetval,lcStr
	lcRetval=""
	lnLength= Lenc (vcString)
	If lnLength>0
		For lnI=1 To lnLength
			lcStr= Substrc (vcString,lnI,1)
			If Isdigit (lcStr) Or Isalpha (lcStr) Or Isleadbyte (lcStr)
				lcRetval=lcRetval+lcStr
			EndIf
		EndFor
	Endif
	Return (lcRetval)
EndFunc

*********************************************************
* 函数名称:--ExtractStr()
* 创建时间:--2008 -10-13
* 目 的:--从字符串中提取汉字,数字串,字母,返回串。
* 参 数:
* vcString:--字符串
* vcTag -- C(汉字)N(数字)E(字母)
Function ExtractStr(vcStr,vcTag)
	vcString= Alltrim (vcString)
	vcTag = Upper (vcTag)
	Local lnI,lnLength,lcRetval,lcStr
	lcRetval=""
	lnLength= Lenc (vcString)
	If lnLength>0
		For lnI=1 To lnLength
			lcStr= Substrc (vcString,lnI,1)
			If "N" $ vcTag And Isdigit (lcStr)
				lcRetval=lcRetval+lcStr
			EndIf
			If "C" $ vcTag And Isleadbyte (lcStr)
				lcRetval=lcRetval+lcStr
			EndIf
			If "E" $ vcTag And Isalpha (lcStr)
				If ! Isleadbyte (lcStr)
					lcRetval=lcRetval+lcStr
				EndIf
			EndIf
		EndFor
	Endif
	Return (lcRetval)
EndFunc

*********************************************************
* 函数名称:--DelFile()
* 创建时间:--2008 -08-17
* 目 的:--删除指定的文件
* 参 数:
* vcFile:----要删除的文件
Procedure DelFile(vcFile)
	If File (vcFile)
		Delete File (vcFile)
	EndIf
EndProc

*********************************************************
* 函数名称:--CopyFile()
* 创建时间:--2008 -08-17
* 目 的:--把指定的文件拷贝到另一个位置
* 参 数:
* vcSFile:--要拷贝的文件
* vcDFile:--新位置的文件
* vlOver--如果目标文件存在，是否覆盖。.T.覆盖 .F.不覆盖
Procedure CopyFile(vcSFile,vcDFile,vlOver)
	If File (vcSFile)
		If ! File (vcDFile)
			Copy File (vcSFile) To (vcDFile)
		Else
			Local lFile,lcSafety
			lcSafety=SetIDE("Set Safety Off")
			If Not Type ('vlOver') == "L"
				vlOver = .F.
			EndIf
			If vlOver
				Copy File (vcSFile) To (vcDFile)
			EndIf
			Set Safety &lcSafety.
		EndIf
	EndIf
EndProc

*********************************************************
* 函数名称:--MoveFile()
* 创建时间:--2008 -08-17
* 目 的:--把指定的文件移到另一个位置
* 参 数:
* vcSFile:--要移动的文件
* vcDFile:--新位置的文件
* vlOver--如果目标文件存在，是否覆盖。.T.覆盖 .F.不覆盖
Procedure MoveFile(vcSFile,vcDFile,vlOver)
	If File (vcSFile)
		If ! File (vcDFile)
			Copy File (vcSFile) To (vcDFile)
			DelFile(vcSFile)
		Else
			Local lFile,lcSafety
			lcSafety=SetIDE("Set Safety Off")
			If Not Type ('vlOver') == "L"
				vlOver = .F.
			EndIf
			If vlOver
				Copy File (vcSFile) To (vcDFile)
				DelFile(vcSFile)
			EndIf
			Set Safety &lcSafety.
		EndIf
	EndIf
EndProc

*********************************************************
* 函数名称:--ReNameFile()
* 创建时间:--2008 -08-17
* 目 的:--重命名文件
* 参 数:
* vcSFile:--要命名的文件
* vcDFile:--新的文件名
Procedure RenameFile(vcSFile,vcDFile)
	If File (vcSFile)
		If ! File (vcDFile)
			Rename (vcSFile) To (vcDFile)
		Else
			MessageBox ( "命名冲突:目标文件 " +vcDFile+ "已经存在!" )
			Return
		EndIf

	EndIf
EndProc

*********************************************************
* 函数名称:--SwapFileName()
* 创建时间:--2008 -08-17
* 目 的:--交换两个文件的文件名
* 参 数:
* vcFile1:--文件名
* vcFile2:--文件名
Procedure SwapFileName(vcFile1,vcFile2)
	Local lcTempFile
	lcTempFile= Sys (2015)
	lcTempFile= Strtran (vcFile1, JustStem (vcFile1),lcTempFile)
	If File (vcFile1) And File (vcFile2)
		RenameFile(vcFile1,lcTempFile)
		RenameFile(vcFile2,vcFile1)
		RenameFile(lcTempFile,vcFile2)
	EndIf
EndProc


*********************************************************
* 函数名称:--MkDir()
* 创建时间:--2008 -08-17
* 目 的:--创建指定的文件夹
* 参 数:
* vcDir:--要创建的文件夹
Procedure MkDir(vcDir)
	vcDir= Alltrim (vcDir)
	If Not Directory (vcDir)
		MkDir (vcDir)
	EndIf
EndProc

*********************************************************
* 函数名称:--DelDir()
* 创建时间:--2008 -08-17
* 目 的:--删除指定的文件夹
* 参 数:
* vcDir:--要创建的文件夹
Procedure DelDir(vcDir)
	vcDir= Alltrim (vcDir)
	If Directory (vcDir)
		Rd (vcDir)
	EndIf
EndProc

*********************************************************
* 函数名称:--HasDir()
* 创建时间:--2008 -08-17
* 目 的:--指定的文件夹是否存在
* 参 数:
* vcDir:--要创建的文件夹
Function HasDir(vcDir)
	vcDir= Alltrim (vcDir)
	Return Directory (vcDir)
EndFunc

***************************************************************
* 函数名称:UFToFoxCode()
* 创建时间:2008-10-16
* 目的:将用户自定义函数添加到表UserFoxCode.dbf
* 参数:
* tcAbbrev:--函数名称缩写
* tcExpanded:--函数全名
* tcTip:--函数参数提示(多个参数用逗号分隔)
Procedure UFToFoxCode(vcFile,vcAlias,vcAbbrev,vcExpanded,vcTip)
	Local lcAlias As String , lcFile As String
	Local lcOldAlias As String
	Local loRecObj
	lcAlias= Alltrim (vcAlias)
	lcFile= Alltrim (vcFile)
	loRecObj= CreateObject ("Empty")
	AddProperty (loRecObj,"Type","F")
	AddProperty (loRecObj,"Abbrev",vcAbbrev) &&---
	AddProperty (loRecObj,"Expanded",vcExpanded) &&---
	AddProperty (loRecObj,"Cmd","")
	AddProperty (loRecObj,"Tip",vcTip) &&--
	AddProperty (loRecObj,"Data","")
	AddProperty (loRecObj,"Case","M")
	AddProperty (loRecObj,"Save",.F.)
	AddProperty (loRecObj,"TimeStamp", Datetime ())
	AddProperty (loRecObj,"Source","RESERVED")
	AddProperty (loRecObj,"Uniqueid", Sys (2015))
	AddProperty (loRecObj,"User","User")
	lcOldAlias=OpenTable(lcAlias,lcFile)
	Locate For Upper ( Alltrim (Expanded))== Upper (loRecObj.Expanded)
	If ! Found ()
		Append Blank
		Gather Memo Name loRecObj
	EndIf
	SelOldAlias(lcOldAlias)
EndProc

********************************************************
* 函数名称: GetNextItemID()
* 创建函数: 2009-01-30
* 功能: 创建下一个项目ID
* 参数:
* tcFix--项目前缀
* tnItemCount--项目编号
* tnLen--ID长度
Function GetNextItemID(vcFix,vnItemCount,vnLen)
	Return Alltrim (vcFix)+ Padl (vnItemCount+1,vnLen,"0")
EndFunc

***************************************************************
* 函数名称:GetNextID()
* 创建时间:2008-10-20
* 目的:返回指定条件下的下一个ID号
* 参数:
* tcAlias:--表别名
* tcFile:--文件名称
* tcField:--操作的字段(程序从该字段的值生成新编号)
* tnLen:--ID长度
* tcFix:--ID的前缀(可以为空:"")
Function GetNextID(tcAlias,tcFile,tcField,tnLen,tcFix)
	Dimension laMax[1]
	Local lcFix,lcField,lcFixLen,lnFix,leState
	m.lcFix= Alltrim (tcFix)
	lnFix= Len (m.lcFix)
	lcFixLen= Alltrim ( Str (lnFix+1))
	If lnFix>0
		lcField=[Max(Val(Substrc(&tcField.,&lcFixLen.)))]
	Else
		lcField=[Max(Val(&tcField.))]
	EndIf
	leState=AGetSQLResult("laMax",;
	tcAlias,;
	tcFile,;
	lcField,;
	"",;
	"",;
	"")
	If leState>0 And Vartype (laMax[1])=="N"
		Return GetNextItemID(m.lcFix, Int (laMax[1]),tnLen)
	Else
		Return GetNextItemID(m.lcFix,0,tnLen)
	EndIf

EndFunc

*********************************************************
* 函数名称:--OpenTable()
* 目 的:--打开指定的表,并选定该表，返回原来表的别名。
* 参 数:
* vcFile:--表文件
* vlExclusive -- 是否。.T. (独占) .F.(独占共享)
* vcAlias:--表别名
Function OpenTable(vcAlias,vcFile,vlExclusive)
	Local lcAlias,lnTag
	lcAlias= Alias ()
	If Empty (vcAlias) And Empty (vcFile)
		* -- 没有提供别名和文件名，则返回NULL
		Return .NULL.
	Else
		If ! Empty (vcALias)
			vcAlias = Alltrim (vcAlias)
		Else
			vcAlias = JustStem (vcFile)
		EndIf
	EndIf
	vlExclusive = Iif (IsType(vlExclusive,"L"),vlExclusive,.F.)
	If Not Used (vcAlias)
		* -- 表没有打开的情况
		If File (vcFile)
			If vlExclusive
				Use (vcFile) In 0 Alias (vcAlias) Exclusive && -- 独占方式
			Else
				Use (vcFile) In 0 Alias (vcAlias) Shared && -- 共享方式
			EndIf
			Select (vcAlias)
		EndIf
	Else
		* -- 表已经打开的情况
		lnTag = Iif ( ISEXCLUSIVE (vcAlias,1),1,0) * 2 + Iif (vlExclusive,1,0)
		Do Case
			Case lnTag == 2 && -- 表独占方式打开，要求共享
				CloseTable(vcAlias)
				If File (vcFile)
					Use (vcFile) In 0 Alias (vcAlias) Shared
				EndIf
			Case lnTag == 1 && -- 表共享打开，要求独占
				CloseTable(vcAlias)
				If File (vcFile)
					Use (vcFile) In 0 Alias (vcAlias) Exclusive
				EndIf
			Otherwise
				* -- Nothing
		EndCase
		Select (vcAlias)
	EndIf
	Return (lcAlias)
Endfunc

*********************************************************
* 函数名称:--CloseTable()
* 创建时间:--2008 -07-27
* 目 的:--关闭指定别名的表，并恢复原先打开的表
* 参 数:
* teAlias:--要关闭的表别名或工作区
* teOldAlias:--要恢复的表别名或工作区
Procedure CloseTable(teAlias,teOldAlias )
	Local lcType,lcOldType
	lcType= Type ("teAlias")
	lcOldType= Type ("teOldAlias")
	If lcType=="N"
		Use In (teAlias)
	Else
		If lcType=="C"
			If ! Empty (teAlias) And Used (teAlias)
				Use In (teAlias)
			EndIf
		EndIf
	EndIf

	If lcOldType=="N"
		Select (teOldAlias)
	Else
		If lcOldType=="C"
			If ! Empty (teOldAlias) And Used (teOldAlias)
				Select (teOldAlias)
			EndIf
		EndIf
	EndIF
EndProc

*********************************************************
* 函数名称:--SelOldAlias()
* 创建时间:--2008 -07-31
* 目 的:--恢复原来表为当前表
* 参 数:
* vcAlias:表别名
Procedure SelOldAlias(vcAlias)
	Local lcType
	lcType = Type ('vcAlias')
	If lcType == "N"
		Select (vcAlias)
	EndIf
	If lcType == "C"
		vcAlias= Alltrim (vcAlias)
		If ! Empty (vcAlias) And Used (vcAlias)
			Select (vcAlias)
		EndIf
	EndIf
EndProc

*********************************************************
* 函数名称:--oGetPosInForm()
* 创建时间:--2008 -11-23
* 目 的:--获取对象在表单中的绝对位置
* 参 数:
* voObj:--对象引用
* vnHeight--下拉窗口的高度倍数。
Function OGetPosInForm(voObj,vnHeight)
	Local loPos,loObject,lnLeft,lnTop,lnShowWindow
	loPos= CreateObject ("Empty")
	loObject=voObj
	Store 0 To lnLeft,lnTop
	Do While .T.
		If GetBaseClass(loObject)$"FORM/TOOLBAR"
			lnShowWindow=loObject. ShowWindow
			Exit
		EndIf
		If GetBaseClass(loObject)=="FORMSET"
			Exit
		EndIf
		lnLeft= Iif (HasPEM(loObject,"Left"),lnLeft+loObject. Left ,lnLeft)
		lnTop= Iif (HasPEM(loObject,"Top"),lnTop+loObject. Top ,lnTop)
		lnTop= Iif (GetBaseClass(loObject)=="PAGEFRAME",lnTop+loObject. Height -loObject. PageHeight -1,lnTop)

		loObject=loObject. Parent
	Enddo
	If lnShowWindow ==2
		Addproperty (loPos,"Left",lnLeft)
		Addproperty (loPos,"Top",lnTop+voObj. Height )
		Addproperty (loPos,"Width",voObj. Width -2)
		Addproperty (loPos,"Height",vnHeight)
	Else
		If lnShowWindow==0 &&--在屏幕中
			Addproperty (loPos,"Top",lnTop+voObj. Height + Sysmetric (4)-2)
		Else
			Addproperty (loPos,"Top",lnTop+voObj. Height + Sysmetric (4)+ Sysmetric (9))
		EndIf

		Addproperty (loPos,"Left",lnLeft+ Sysmetric (3))
		Addproperty (loPos,"Width",voObj. Width -2)
		Addproperty (loPos,"Height",vnHeight)
	EndIf
	Return loPos
EndFunc

*********************************************************
* 函数名称:--AddControl()
* 创建时间:--2008 -07-0 9
* 目 的:--动态添加对象或控件到容器中,并返回对象的引用。
* 参 数:
* voContainer:--容器对象引用
* vcName:--对象名称
* vcClass:--类名
* vcClassLib:--类库
* veP1~5:--额外的参数
Function AddControl(voContainer,vcName,vcClass,vcClassLib,veP1,veP2,veP3,veP4,veP5)
	Local lnParams As Integer ,loRet
	loRet = .NULL.
	tcName= Alltrim (vcName)
	tcClass= Alltrim (vcClass)
	tcClassLib= Alltrim (vcClassLib)
	lnParams= Parameters ()
	If lnParams<4 &&----参数太少.
		Return .NULL.
	EndIf
	OpenLib(vcClassLib)
	If GetBaseClass(voContainer)$"FORM/FORMSET/GRID/CONTAINER/TOOLBAR"
		If !HasPEM(voContainer,vcName) &&----
			Do Case
				Case lnParams==4
					voContainer. AddObject (vcName,vcClass)
				Case lnParams==5
					voContainer. AddObject (vcName,vcClass,veP1)
				Case lnParams==6
					voContainer. AddObject (vcName,vcClass,veP1,veP2)
				Case lnParams==7
					voContainer. AddObject (vcName,vcClass,veP1,veP2,veP3)
				Case lnParams==8
					voContainer. AddObject (vcName,vcClass,veP1,veP2,veP3,veP4)
				Case lnParams==9
					voContainer. AddObject (vcName,vcClass,veP1,veP2,veP3,veP4,veP5)
				Otherwise
			EndCase
			voContainer.&vcName.. Visible =.T.
			loRet=voContainer.&vcName
		Else
			If Isobject(voContainer.&vcName.) &&----如果是对象,重新初始化.
				Do Case
					Case lnParams==4
						*----No Init
					Case lnParams==5
						voContainer.&vcName.. Init (veP1)
					Case lnParams==6
						voContainer.&vcName.. Init (veP1,veP2)
					Case lnParams==7
						voContainer.&vcName.. Init (veP1,veP2,veP3)
					Case lnParams==8
						voContainer.&vcName.. Init (veP1,veP2,veP3,veP4)
					Case lnParams==9
						voContainer.&vcName.. Init (veP1,veP2,veP3,veP4,veP5)

					Otherwise
				EndCase
				loRet=voContainer.&vcName
			Else
				voObj=.NULL.
			Endif

		EndIf
	EndIf
	Return loRet
EndFunc

*********************************************************
* 函数名称:--GetOPos()
* 创建时间:--2008 -07-10
* 目 的:--返回一个指定对象的大小
* 参 数:
* voObj:--指定的对象
Function GetOPos(voObj)
	Local loPos
	loPos= CreateObject ("Empty")
	If IsObject(voObj)
		AddProperty (loPos,"Top",voObj. Top )
		AddProperty (loPos,"Left",voObj. Left )
		AddProperty (loPos,"Height",voObj. Height )
		AddProperty (loPos,"Width",voObj. Width )
	Else
		AddProperty (loPos,"Top",0)
		AddProperty (loPos,"Left",0)
		AddProperty (loPos,"Height",0)
		AddProperty (loPos,"Width",0)
	EndIf

	Return (loPos)
EndFunc

*********************************************************
* 函数名称:--SetOPos()
* 创建时间:--2008 -07-07
* 目 的:-- 用指定的对象的大小和位置来设置该对象的大小和位置
* 参 数:
* voObj:--对象的引用
* voPos:--位置大小对象(Top,Left,Height,Width)
Procedure SetOPos(voObj,voPos)
	If IsObject(voObj) And IsObject(voPos)
		With voObj
			. Top =voPos. Top
			. Left =voPos. Left
			. Height =voPos. Height
			. Width =voPos. Width
		EndWith
	EndIf
EndProc

*********************************************************
* 函数名称:--GetPValue()
* 创建时间:-- 2008-09-26
* 目 的:--取得对象的属性值。
* 参 数:
* voObject:--对象的引用
* vcProp:--对象的属性
Function GetPValue(voObject,vcProp)
	If HasPEM(voObject,vcProp)
		Return toObject.&tcProp.
	Else
		Return .NULL.
	EndIf
EndFunc

*********************************************************
* 函数名称:--SetPValue()
* 创建时间:-- 2008-09-26
* 目 的:--设置对象的属性值。
* 参 数:
* voObject:--对象的引用
* vcProperty:--对象的属性
* veValue:--要设置的属性值
Function SetPValue(voObject,vcProp,veValue)
	If HasPEM(voObject,vcProp)
		voObject.&vcProp.=veValue
	Else
		AddProperty (voObject,vcProp,veValue)
	EndIf
EndFunc

*********************************************************
* 函数名称:--AToLCBox()
* 创建时间:--2008 -07-19
* 目 的:--将项目添加到列表框/组合框中(数组方式)
* 参 数:
* toList:--列表框/组合框的引用
* tnColumns:--显示的列数
* tnImageCol:--图象所在的列数(即图象在数组的第几列)
* tcAlias:--表别名
* tcFile:--表文件
* tcFieldslist:--字段列表
* tcFilter:--筛选条件
* tcOrder:--排序字段
Procedure A2LCBox(voLcbox,vnCols,vnImgCol,vcAlias,vcFile,vcFldlist,vcFilter,vcOrder,vlColWidth)
	If Type ('tlColWidth')<>"L"
		vlColWidth = .F.
	EndIf
	If GetBaseClass(voLcbox) $ "LISTBOX/COMBOBOX"

		Dimension gaItems[1]
		Local lnRow,lnCol,lnTally,lcColWidths
		lnTally=AGetSQLResult("gaItems",vcAlias,vcFile,vcFldlist,vcFilter,"",vcOrder)
		lcColWidths=SetLCBoxColWidths(voLCBox,vcAlias,vcFile,vcFldlist)
		If lnTally>0
			With voLcbox
				. Clear ()
				If GetWordCount (vcFldlist,[,]) == vnCols
					. ColumnCount =vnCols
					If vlColWidth
						. Columnwidths = lcColWidths
					EndIf
				EndIf

				For lnRow=1 To lnTally
					For lnCol=1 To Alen (gaItems,2)
						. List (lnRow,lnCol)= Alltrim (ToString(gaItems[lnRow,lnCol]))
					EndFor
					If vnImgCol>0
						. Picture (lnRow)= Alltrim (ToString(gaItems[lnRow,vnImgCol]))
					EndIf
				EndFor
			EndWith
		EndIf
	EndIf

EndProc

*********************************************************
* 函数名称:--SetLCBoxColWidths()
* 创建时间:--2008 -10-29
Function SetLCBoxColWidths(voLCBox,vcAlias,vcFile,vcFldList)
	Local loSizeRate,lnCount,lnFields,lcField,lcColWidth,lcRetVal
	lcRetVal=""
	If GetFldSize(@loSizeRate,vcAlias,vcFile,vcFldList)
		lnFields= GetWordCount (vcFldList,[,])
		For lnCount=1 To lnFields
			lcField= GetWordNum (vcFldList,lnCount,[,])
			lcColWidth=ToString( Int (loSizeRate.&lcField * voLCBox. Width ))
			lcRetVal= Iif ( Empty (lcRetVal),lcColWidth,lcRetVal+","+lcColWidth)
		EndFor
		lcRetVal= Left (lcRetVal, Rat ([,],lcRetVal)-1)
	EndIf
	Return lcRetVal
EndFunc

*********************************************************
* 函数名称:--DoForm()
* 创建时间:--2008 -10-29
* 目 的:--运行表单
* 参 数:
* vcForm:--表单引用
Procedure DoForm(vcForm,teP1,teP2,teP3,teP4,teP5)
	Local lnParams As Integer ,lcForm
	lnParams= Parameters ()
	Do Case
		Case lnParams==1
			lcForm = JustStem (vcForm)
			Do Form (vcForm) Name (lcForm)
		Case lnParams==2
			lcForm = JustStem (vcForm)
			Do Form (vcForm) Name (lcForm) With teP1
		Case lnParams==3
			lcForm = JustStem (vcForm)
			Do Form (vcForm) Name (lcForm) With teP1,teP2
		Case lnParams==4
			lcForm = JustStem (vcForm)
			Do Form (vcForm) Name (lcForm) With teP1,teP2,teP3
		Case lnParams==5
			lcForm = JustStem (vcForm)
			Do Form (vcForm) Name (lcForm) With teP1,teP2,teP3,teP4
		Case lnParams==6
			lcForm = JustStem (vcForm)
			Do Form (vcForm) Name (lcForm) With teP1,teP2,teP3,teP4,teP5
		Otherwise
	EndCase
	Return (lcForm)
EndProc

*********************************************************
* 函数名称:--ValidUrl()
* 创建时间:--2008 -09-10
* 目 的:--验证URL的合法性
* 参 数:
* vcUrl: URL字符串
Function ValidUrl(vcUrl)
	Local lcURL
	If Empty (vcURL)
		Return ""
	Endif
	lcURL= Alltrim (vcURL)
	If Not ":"$lcURL And Not Lower ( Left (lcURL,5))=="http:" And ;
		NOT Lower ( Left (lcURL,5))=="file:" And ;
		NOT Lower ( Left (lcURL,4))=="ftp." And ;
		( Lower ( Left (lcURL,4))=="www." Or ;
		INLIST ( Lower ( Right (lcURL,4)),".com",".gov",".net") Or ;
		(Not Substr (lcURL,2,1)==":" And Not Left (lcURL,2)=="\\"))
		lcURL="http://"+lcURL
	Endif
	If Substr ( Padr (lcURL,5),5,1)==":"
		lcURL= Strtran ( Strtran (lcURL,"\","/"),"///","//")
	Else
		If (Not ":"$lcURL Or At (":",lcURL)=2) And Not Lower ( Left (lcURL,4))=="ftp."
			lcURL="file://"+;
			Strtran ( Strtran ( Strtran (lcURL,"\","/"),"///","//"),"//","/")
		Endif
	Endif
	Return lcURL
EndFunc

*********************************************************
* 函数名称:- -ShellExecute()
* 创建时间:--2008 -07-09
** 功能: 打开和应用程序相关联的文件。
** 参数: lcFileName - 要打开的文件名
**
** 返回值: 2 - 无效的关联 (例如, 无效的 URL)。
** 31 - 无关联程序。
** 29 - 加载应用程序失败。
** 30 - 应用程序忙。
*-* HINSTANCE ShellExecute(hwnd, lpszOp, lpszFile, lpszParams,;
*-* lpszDir, wShowCmd)
*-* HWND hwnd - 父窗口的句柄。
*-* LPC TSTR lpszOp - 执行操作的字符串的地址。
*-* LPCTSTR lpszFile - 文件字符串的地址。
*-* LPTSTR lpszParams - 可执行文件参数的字符串地址。
*-* LPCTSTR lpszDir - 默认路径的字符串地址。
*-* INT wShowCmd - 打开时文件是否显示。
Function ShellExecute(vcFileName,vcWorkDir,vcOperation,vnShowWindow)
	LOCAL lcFileName,lcWorkDir,lcOperation,lnShowWindow
	IF EMPTY (vcFileName)
		RETURN -1
	ENDIF
	lcFileName= ALLTRIM (vcFileName)
	If IsType(vcWorkDir,"C")
		lcWorkDir = ALLTRIM (vcWorkDir)
	Else
		lcWorkDir = ""
	EndIf
	If Istype(vcOperation,"C") And ! EMPTY (vcOperation)
		lcOperation = ALLTRIM (vcOperation)
	Else
		lcOperation = "Open"
	EndIf
	If Istype(vnShowWindow,"N")
		lnShowWindow = vnShowWindow
	Else
		lnShowWindow = 1
	EndIf

	DECLARE INTEGER ShellExecute IN SHELL32. DLL ;
	INTEGER nWinHandle,;
	STRING cOperation,;
	STRING cFileName,;
	STRING cParameters,;
	STRING cDirectory,;
	INTEGER nShowWindow
	RETURN ShellExecute(0,lcOperation,lcFilename,"",lcWorkDir,lnShowWindow)
EndFunc

*********************************************************
* 函数名称:--GetWinRect()
* 创建时间:--2008 -07-11
* 目 的:--取得指定窗口的区域
* 参 数:
* lpRect:--字符缓冲区
* HWnd:--窗口句柄
* 返回值：对象
* 对象属性：
* Left
* Top
* Width
* Height
* Border
* Title
Function GetWinRect(voControl)
	Local lpRect,;
	loPos,;
	lhwnd,;
	lnLeft,;
	lnTop,;
	lnRight,;
	lnBottom,;
	lnWidth,;
	lnHeight,;
	lnBorder,;
	lnTitle
	lhwnd= PemStatus (voControl,"HWnd",5)
	loPos=.NULL.
	If lhwnd
		lpRect = Replicate ( Chr (0),16)
		loPos= CreateObject ("Empty")
		Declare Integer GetWindowRect In user32 ;
		Integer HWnd , ;
		String @ lpRect
		GetWindowRect(voControl. HWnd , @lpRect)
		lnLeft = CToBin ( Substr (lpRect, 1, 4),"4rs")
		lnTop = CToBin ( Substr (lpRect, 5, 4),"4rs")
		lnRight = CToBin ( Substr (lpRect, 9, 4),"4rs")
		lnBottom = CToBin ( Substr (lpRect,13, 4),"4rs")
		lnWidth = lnRight - lnLeft
		lnHeight = lnBottom - lnTop
		lnBorder = (lnWidth - voControl. Width )/2
		lnTitle = (lnHeight - voControl. Height - (lnBorder*2))
		AddProperty (loPos,"Left",lnLeft)
		AddProperty (loPos,"Top",lnTop)
		AddProperty (loPos,"Width",lnWidth)
		AddProperty (loPos,"Height",lnHeight)
		AddProperty (loPos,"Border",lnBorder)
		AddProperty (loPos,"Title",lnTitle)
	EndIf
	Return (loPos)
EndFunc

*********************************************************
* 类名称:--LocateFor()
* 创建时间:--2008 -10-29
* 目 的:--定位记录指针
* 参 数:
* vcValue:-- 定位字段值
* vcPosField:--定位字段
* vcAlias:--表别名
Procedure LocateFor(vcAlias,vcPosField,vcValue)
	Local oldAlias,lRetVal
	oldAlias= Alias ()
	Select (vcAlias)
	Locate For Alltrim (&vcPosField.)== Alltrim (vcValue)
	lRetVal= Found ()
	SelOldAlias(oldAlias)
	Return lRetVal
EndProc

*********************************************************
* 类名称:--GetSQLSelect()
* 创建时间:--2008 -09-16
* 目 的:--生成SQL语句
* 参 数:
* vcAlias:--表别名
* vcFldList:--字段列表
* vcFilter:--筛选条件
* vcGroupBy:--分组字段列表
* vcOrderBy:--排序字段列表
* vcDirection:--结果方向（和tnFlag的设置相对应）
* vcTag -- 结果去向：数组名，游标名，表名
* vcFlag:--方向标识（Array：数组，Cursor：游标，Table：表）
* 返回值：String型。SQL表达式
Function GetSQLSelect(vcAlias,vcFldList,vcFilter,vcGroupBy,vcOrderBy,vcTag,vcFlag)
	Local lcAlias,lcFldList,lcFilter,lcGroupBy,lcOrderBy,lcTag
	lcAlias=[ From ]+ Alltrim (vcAlias)
	lcFldList=[Select ]+ Iif ( Empty (vcFldList),"*", Alltrim (vcFldList))
	lcFilter= Iif (! Empty (vcFilter),[ Where ]+ Alltrim (vcFilter),"")
	lcGroupBy= Iif (! Empty (vcGroupBy),[ Group By ]+ Alltrim (vcGroupBy),"")
	lcOrderBy= Iif (! Empty (vcOrderBy),[ Order By ]+ Alltrim (vcOrderBy),"")

	If Istype(vcTag,"C") And ! Empty (vcTag)
		vcTag = Alltrim (vcTag)
	Else
		vcTag = Sys (2015)
	EndIf

	If Not Istype(vcFlag,"C")
		vcFlag = "Cursor"
	Else
		If Not InList (vcFlag,"Array","Cursor","Table")
			vcFlag = "Cursor"
		EndIf
	EndIf
	Do Case
		Case Upper (vcFlag) == "CURSOR"
			lcTag = [ Into Cursor ] + vcTag
		Case Upper (vcFlag) == "ARRAY"
			Dimension &vcTag.[1]
			lcTag = [ Into Array ] + vcTag
		Case Upper (vcFlag) == "TABLE"
			lcTag = [Into Table ] +vcTag
		Otherwise
			* -- Nothing
	EndCase
	Return (lcFldList+lcAlias+lcFilter+lcGroupBy+lcOrderBy+lcTag)
EndFunc

*********************************************************
* 类名称:--AGetSQLResult()
* 创建时间:--2008 -10-05
* 目 的:--运行SQL查询,并将结果填充到数组,返回处理的记录数
* 参 数:
* vaResult -- 数组名称
* vcAlias--表别名
* vcFile--表文件名
* vcFldList--字段列表
* vcFilter--筛选条件
* vcGroup By--分组字段
* vcOrderBy--排序字段
* 注意：使用前必须首先定义数组
Function AGetSQLResult(vaResult,vcAlias,vcFile,vcFldList,vcFilter,vcGroupBy,vcOrderBy)
	Local lcOldAlias,lcSQL,lnRecCount
	lcSQL=GetSQLSelect(vcAlias,vcFldList,vcFilter,vcGroupBy,vcOrderBy,vaResult,"Array")
	lcOldAlias=OpenTable(vcAlias,vcFile)
	&lcSQL.
	lnRecCount= _Tally
	SelOldAlias(lcOldAlias)
	Return (lnRecCount)
EndFunc

*********************************************************
* 函数名称:--GetFldVal()
* 创建时间:-- 2008-09-30
* 目 的:--从表中返回指定条件的指定字段的值。
* 参 数:
* vcAlias:--表别名
* vcFile:--表文件
* vcPosField:--定位字段
* vcPosValue:--定位值
* vcRetField:--返回的字段
* 注意：只是用于字符型的数据
Function GetFldVal(vcAlias,vcFile,vcPosFld,vcPosValue,vcRetFld)
	Local oldAlias,leRetVal
	oldAlias=OpenTable(vcAlias,vcFile)
	Locate For Upper ( Alltrim (&vcPosFld.)) == Upper ( Alltrim (vcPosValue))
	If Found ()
		leRetVal= Alltrim (&vcRetFld.)
	Else
		leRetVal=""
	EndIf
	SelOldAlias(oldAlias)
	Return leRetVal
EndFunc

*********************************************************
* 函数名称:--SetFldVal()
* 创建时间:-- 2008-09-30
* 目 的:--设置指定条件的字段的值。
* 参 数:
* vcAlias:--表别名
* vcFile:--表文件
* vcPosField:--定位字段
* vcPosValue:--定位值
* vcRetField:--返回的字段
* 注意：只是用于字符型的数据
Function SetFldVal(vcAlias,vcFile,vcPosFld,vcPosVal,vcSetFld,veSetVal)
	Local oldAlias
	oldAlias=OpenTable(vcAlias,vcFile)
	Locate For Upper ( Alltrim (&vcPosFld.)) == Upper ( Alltrim (vcPosVal))
	If Found ()
		Replace (vcSetFld) With (veSetVal)
	EndIf
	SelOldAlias(oldAlias)
EndFunc

*********************************************************
* 函数名称:--OGetFldVal()
* 创建时间:-- 2008-09-30
* 目 的:--从表中返回指定条件的记录集合。
* 参 数:
* vcAlias:--表别名
* vcFile:--表文件
* vcFilter:--筛选条件
Function OGetFldVal(vcAlias,vcFile,vcFilter)
	Local oldAlias,loRet,lnCount
	loRet = .NULL.
	oldAlias=OpenTable(vcAlias,vcFile)
	lnCount = Reccount ()
	* -- 如果表中无记录，则返回.NULL.
	If lnCount == 0
		SelOldAlias(oldAlias)
		Return .NULL.
	EndIf
	* -- 根据条件查询记录
	vcFilter = Alltrim (vcFilter)
	loRet = CreateObject ("Collection")

	If Not Empty (vcFilter)
		Scan For &vcFilter.
			Scatter Memo Name loRecord
			loRet. Add (loRecord)
		EndScan
	Else
		Scan
			Scatter Memo Name loRecord
			loRet. Add (loRecord)
		EndScan
	EndIf
	SelOldAlias(oldAlias)
	Return loRet
Endfunc

*********************************************************
* 函数名称:--SetFilter()
* 创建时间:--2008 -10-06
* 目 的:--设置打开表的筛选条件,并返回一个原来的筛选条件
* 参 数:
* vcAlias:--表别名
* vcFldName:--字段名
* vcFldValue:--字段值
Procedure SetFilter(vcAlias,vcFldName,vcFldValue)
	Local lcFilter
	lcFilter=[Set Filter To &vcFldName. = '&vcFldValue.' In &vcAlias.]
	Return SetIDE(lcFIlter)
EndProc

*********************************************************
* 类名称:--GetFldSize()
* 创建时间:--2008 -10-29
* 目 的:--返回指定字段列表的各字段的大小
* 参 数:
* voSize:--字段大小对象
* vcAlias:--表别名
* vcFile:--表文件
* vcFldList:--字段列表
* 返回对象属性
* Sizes:字段长度综合
* 字段名：所占百分比
* ..................
Function GetFldSize(voSize,vcAlias,vcFile,vcFldList)
	voSize=.NULL.
	Local oldAlias,lnFields,lnFldList,lcFldList,lcField,I

	Dimension laFields[1]
	lcFldList= Alltrim (vcFldList)
	lnFldList= GetWordCount (lcFldList,[,])
	oldAlias=OpenTable(vcAlias,vcFile)
	lnFields= AFields (laFields)
	SelOldAlias(oldAlias)
	If lnFields>0
		voSize= CreateObject ("Empty")
		AddProperty (voSize,"Sizes",0)
		For I=1 To lnFields
			If Upper ( Alltrim (laFields[I,1])) $ Upper (lcFldList)
				AddProperty (voSize, Alltrim (laFields[I,1]),laFields[I,3])
				voSize.Sizes=voSize.Sizes+laFields[I,3]
			EndIf
		EndFor
		For I=1 To lnFldList
			lcField= GetWordNum (lcFldList,I,[,])
			voSize.&lcField.=voSize.&lcField./voSize.Sizes
		EndFor
	EndIf
	Return IsObject(voSize)
EndFunc

*********************************************************
* 函数/过程名称:AddTVRoot()
* 创建时间:2008-10-06
* 目 的:为TREEVIEW添加根节点
* 参 数:
* voTV:--TreeView对象的引用
* vcKey:--唯一标识字符串
* vcText:--Node节点中显示的字符串
* veImageIndex :--与ImageList控件关联的图象索引
* veSelImgIndex:--Node节点选中时,与ImageList控件关联的图象索引
* 返回值:新添加节点的引用.
Function AddTVRoot(voTV,vcKey,vcText,veImgIndex,veSelImgIndex)
	Local loNode,llExist,loRet
	llExist=.F.
	loRet=.NULL.
	For Each loNode In voTV.Nodes
		If Upper ( Alltrim (loNode. Key ))== Upper ( Alltrim (vcKey))
			llExist=.T.
			Exit
		EndIf
	EndFor
	If !llExist
		loRet=voTV.Nodes. Add (,1,vcKey,vcText,veImgIndex,veSelImgIndex)
	EndIf
	Return loRet
EndFunc

*********************************************************
* 函数/过程名称:AddTVChild()
* 创建时间:2008-10-06
* 目 的:为TREEVIEW添加字节点
* 参 数:
* voTV:--TreeView对象的引用
* vcpKey:--父节点的标识字符串
* vcKey:--唯一标识字符串
* vcText:--Node节点中显示的字符串
* veImgIndex:--与ImageList控件关联的图象索引
* teSelImageIndex:--Node节点选中时,与ImageList控件关联的图象索引
* 返回值:新添加节点的引用.
Function AddTVChild(voTV,vcpKey,vcKey,vcText,veImgIndex,veSelImgIndex)
	Local loNode,loNode2,llExist,loRet
	llExist=.F.
	loRet=.NULL.

	For Each loNode In toTV.Nodes
		If Upper ( Alltrim (loNode. Key ))== Upper ( Alltrim (vcpKey))
			llExist=.T.
			loNode2=loNode
			Exit
		EndIf
	EndFor
	If llExist
		loRet=toTV.Nodes. Add (loNode2. Key ,4,vcKey,vcText,;
		veImgIndex,veSelImgIndex)
	EndIf
	Return loRet
EndFunc

*********************************************************
* 函数/过程名称:GetNodeKey()
* 创建时间:2008-10-06
* 目 的:返回Node节点的唯一标识字符串
* 参 数:
* voNode:--Node节点的引用
* 返回值:节点的标识字符串[C].
Function GetNodeKey(voNode)
	Return Alltrim (voNode. Key )
EndFunc

*********************************************************
* 函数/过程名称:GetNodeChildren()
* 创建时间:2008-10-06
* 目 的:返回Node节点的子节点的数量.
* 参 数 :
* voNode:--Node节点的引用
* 返回值:节点的子节点的数量[N].
Function GetNodeChildren(voNode)
	Return voNode.Children
EndFunc

*********************************************************
* 函数/过程名称:AddImage()
* 创建时间:2008-10-06
* 目 的:添加图片到ImageList控件集合中.
* 参 数:
* voIamgeList:--ImageList控件的引用
* vcImage:--图片文件
* vcKey:--图片标识唯一字符串
PROCEDURE AddImage(voImgList,vcImg,vcKey)

	IF NOT ".ico" $ Lower (vcImg)
		vcImg = ForceExt (vcImg,"bmp")
	ENDIF
	IF NOT IsType(vcKey,"C")
		vcKey = JustStem (vcImg)
	ENDIF
	*检测当前图象是否已经添加了 ...
	LOCAL llFound, lnCounter
	llFound = .F.
	FOR lnCounter = 1 TO voImgList.ListImages. Count
		IF Lower (voImgList.ListImages(lnCounter). Key ) == Lower (vcKey)
			llFound = .T.
			EXIT
		ENDIF
	ENDFOR
	IF NOT llFound
		voImgList.ListImages. Add ( , vcKey, LoadPicture (vcImg) )
	ENDIF
	RETURN vcKey
EndProc

*********************************************************
* 函数名称:--GetTimeStamp()
* 创建时间:--2008 -12-23
* 目 的:--返回指定时间的时间戳
* 参 数:
* tDateTime:--日期时间参数
FUNCTION GetTimeStamp(tDateTime)
	LOCAL cTimeValue
	IF VARTYPE (m.tDateTime) <> 'T'
		m.tDateTime = DATETIME ()
		m.cTimeValue = TIME ()
	ELSe
		m.cTimeValue = TTOC (m.tDateTime, 2)
	ENDIF
	RETURN (( YEAR (m.tDateTime) - 1980) * 2 ** 25);
	+ ( MONTH (m.tDateTime) * 2 ** 21);
	+ ( DAY (m.tDateTime) * 2 ** 16);
	+ ( VAL ( LEFTC (m.cTimeValue, 2)) * 2 ** 11);
	+ ( VAL ( SUBSTRC (m.cTimeValue, 4, 2)) * 2 ** 5);
	+ VAL ( RIGHTC (m.cTimeValue, 2))
EndFunc

******************************************************
* 函数名称: GetSelItem()
* 功能: 根据唯一ID返回表字段Item的值
* 参数
* vcAlias--表别名
* vcFile--表文件
* vcId--字段ID值
Function GetSelItem(vcAlias,vcFile,vcId)
	Return GetFldVal(vcAlias,vcFile,"ID",vcId,"Item")
EndFunc

*********************************************************
* 函数名称:--CountFor()
* 创建时间:--2008 -09-17
* 目 的:--统计指定条件的记录数
* 参 数:
* vcAlias--表别名
* vcFile--表文件名
* vcFilter--筛选条件
Function CountFor(vcAlias,vcFile,vcFilter)
	Local lnRetVal,lcSQL,lcOldAlias
	Dimension gaCount[1]
	lnRetVal=0
	lcOldAlias=OpenTable(vcAlias,vcFile)
	lcSQL=GetSQLSelect(vcAlias,"Count(*)",vcFilter,"","","gaCount","Array")
	&lcSQL.
	If _Tally >0
		lnRetVal=gaCount[1]
	EndIf
	Return (lnRetVal)
EndFunc

*********************************************************
* 函数名称:--ToCase()
* 创建时间:--2009 -04-19
* 目 的:--其他类型转换为大写字符串
* 参 数:
* vcStr -- 字符串表达式
Function ToCase(vcStr)
	If IsType(vcStr,"C")
		vcStr = Alltrim (vcStr)
	Else
		vcStr = ""
	EndIf
	Return Upper (vcStr)
EndFunc

*********************************************************
* 函数名称:--ToLower()
* 创建时间:--2009 -04-19
* 目 的:--其他类型转换为小写字符串
* 参 数:
* vcStr--字符串表达式
Function ToLower(vcStr)
	If IsType(vcStr,"C")
		vcStr = Alltrim (vcStr)
	Else
		vcStr = ""
	EndIf
	Return Lower (vcStr)
EndFunc

*********************************************************
* 函数名称:--ToString()
* 创建时间:--2009 -01-05
* 目 的:--其他类型转换为字符串
* 参 数:
* veExp:--表达式
Function ToString(veExp)
	Local lcRet,lcType
	lcRet = ""
	lcType= Type ('veExp')
	Do Case
		Case lcType=="N"
			lcRet= Alltrim ( Str (veExp))
		Case lcType=="C"
			lcRet= Alltrim (veExp)
		Case lcType=="D"
			lcRet= Dtoc (veExp)
		Case lcType=="T"
			lcRet= Ttoc (veExp)
		Case lcType=="L"
			lcRet= Iif (veExp,"T","F")
		Otherwise
	EndCase
	Return lcRet
EndFunc

*********************************************************
* 函数名称:--ToInteger()
* 创建时间:--2009 -01-05
* 目 的:--其他类型转换为整型
* 参 数:
* veExp:--表达式
Function ToInteger(veExp)
	Return Cast (veExp As I)
EndFunc

*********************************************************
* 函数名称:--ICaseRun()
* 创建时间:--2009 -01-05
* 目 的:--根据条件运行表达式
* 参 数:
* vlExp:--逻辑表达式
* vcRunExp:--要运行的表达式
* vcRunDefault:--运行的默认表达式
Function ICaseRun(vlExp,vcRunExp,vcDefault)
	Local lcRunExp
	lcRunExp= ICase (vlExp,vcRunExp,vcDefault)
	If Vartype (lcRunExp)=="C" And ! Empty (lcRunExp)
		Evaluate (lcRunExp)
	EndIf
EndFunc

*********************************************************
* 函数名称:--GetShortFName()
* 创建时间:--2009 -01-15
* 功能:--获取带最短路径的文件名
* 参 数:
* vcFile：文件扩展名
Function GetShortFName(vcFile)
	Local lcRetVal
	lcRetVal=""
	If ! Empty (vcFile)
		Local lnPos
		lnPos= Ratc ("\",vcFile,2)
		If lnPos==0
			lcRetVal= JustFname (vcFile)
		Else
			lcRetVal= Substrc (vcFile,lnPos+1)
		EndIf
	EndIf
	Return (lcRetVal)
EndFunc

*********************************************************
* 函数名称:--IIIf()
* 创建时间:--2009 -01-15
* 功能:--两个函数IIF（）的复合
* 参 数:
* vlExpr1..2--条件表达式
* veExpr1..4--表达式
Function IIIf(vlExpr1,vlExpr2,veExpr1,veExpr2,veExpr3,veExpr4)
	Local lnCount,lcCount,leRetVal,lcType
	lnCount=4-LToN(vlExpr1,vlExpr2)
	lcCount= Padl (lnCount,1,"0")
	leRetVal=[veExpr&lcCount.]
	lcType= Type ('&leRetVal.')
	Return Iif (lcTYpe=="U",.F.,&leRetVal.)
EndFunc

*********************************************************
* 函数名称:--LToN()
* 创建时间:--2009 -01-15
* 功能:--逻辑值序列转换成数值
* 参 数:
* tlExpr01..10 - 逻辑表达式
Function LToN(tlExpr01,tlExpr02,tlExpr03,tlExpr04,;
	tlExpr05,tlExpr06,tlExpr07,tlExpr08,;
	tlExpr09,tlExpr10)
	Local lnCount,lcCount,lnRetVal,lnParams
	lnParams= Parameters ()
	lnRetVal=0
	For lnCount=lnParams To 1 Step -1
		lcCount= Padl (lnCount,2,"0")
		lcCount=[tlExpr&lcCount.]
		lnRetVal=lnRetVal+;
		2^(lnParams-lnCount)* Iif (&lcCount.,1,0)
	EndFor
	Return Int (lnRetVal)
EndFunc

*********************************************************
* 函数名称:--ValueIf()
* 创建时间:--2009 -01-15
* 功能:--按条件从变量返回值
* 参 数:
* vlCondition:--为.T.时，返回参数，
Function ValueIf(vlCondition,veValue)
	Local lcType,leRetVal
	lcType= Type ('veValue')
	Do Case
		Case lcType=="C"
			leRetVal=""
			veValue= Alltrim (veValue)
		Case lcType=="N"
			leRetVal=0
		Case lcType=="L"
			leRetVal=.F.
		Case lcType=="D"
			leRetVal={}
		Case lcType=="T"
			leRetVal={/::}
		Otherwise
	EndCase

	If vlCondition
		leRetVal=veValue
	EndIf
	Return leRetVal
EndProc
*===================================================================
* Dec2Hex()
* 十进制转十六进制
* nDecimal 十进制数
* nDigits 位数（最大8位）
Function Dec2Hex(nDecimal, nDigits)
	IF PARAMETERS () = 2
		RETURN RIGHT ( TRANSFORM (nDecimal, "@0"), IIF (nDigits <= 8, nDigits, 8))
	ENDIF
	nExponent = 2 && Always return at least two characters.
	DO WHILE nExponent < 9
		IF nDecimal <= (16^nExponent)
			RETURN RIGHT ( TRANSFORM (nDecimal, "@0"), nExponent)
		ENDIF
		nExponent = nExponent + 1
	EndDo
EndFunc
*===================================================================
* Hex2Dec()
* 十六进制转为十进制
* cDigits 十六进制数
Function Hex2Dec(cDigits)
	RETURN EVALUATE ("0x" + ALLTRIM (cDigits))
EndFunc
*===================================================================
* BinVal()
* 二进制转为十进制
Function BinVal(bin)
	Local Ret,I
	Ret=0
	For I= Len (bin) To 1 Step -1
		Ret=Ret*256+ Asc ( Substr (bin,I,1))
	EndFor
	Return Ret
EndFunc
*===================================================================
* Bin2Str()
* 二进制转为字符串
Function Bin2Str(Bin)
	Local I, lcStr,cLow
	lcStr=""
	For I=1 To Len (Bin)
		clow= Substr (Bin,I,1)
		If ASC (clow)<128 Then
			lcStr = lcStr + Chr ( ASC (clow))
		Else
			I=I+1
			If I <= Len (Bin)
				lcStr = lcStr + Chr ( ASC ( Substr (Bin,I,1)+clow))
			EndIf
		EndIf
	EndFor
	Return lcStr
EndFunc
*===================================================================
* BinVal2()
Function BinVal2(Bin)
	Local Ret,I
	Ret = 0
	For I = 1 To Len (Bin)
		Ret = Ret *256 + Asc ( Substr (Bin,I,1))
	EndFor
	Return Ret
EndFunc
*===================================================================
* GetImgSize()
* 返回指定图片文件的尺寸
* 返回对象
* width 图片宽度
* Height 图片高度
* Rate=Width/Height 宽度与高度的比值
* 适用的文件类型: JPG PNG GIF BMP
Function GetImgSize(filespec)
	Local bFlag,loAso,lcTag
	Dimension Ret(3)
	loAso= CreateObject ("ADODB.Stream")
	With loAso
		.Mode=3
		. Type =1
		. Open ()
	EndWith

	loAso.LoadFromFile(filespec)
	bFlag=loAso. Read (3)
	lcTag=Dec2Hex(binVal(bFlag))
	Do Case
		Case lcTag=="4E5089"
			loAso. Read (15)
			ret(1)="PNG"
			ret(2)=BinVal2(loAso. Read (2))
			loAso. Read (2)
			ret(3)=BinVal2(loAso. Read (2))
		Case lcTag=="464947"
			loAso. read (3)
			ret(1)="gif"
			ret(2)=BinVal(loAso. Read (2))
			ret(3)=BinVal(loAso. Read (2))
		Case lcTag=="FFD8FF"
			Do While .T.
				p1=binVal(loAso. Read (1))
				Do While p1=255 And Not loAso.EOS
					p1=binVal(loAso. Read (1))
				EndDo

				If p1>191 And p1<196
					Exit
				Else
					loAso. read (binval2(loAso. Read (2))-2)
				EndIf

				Do While p1<255 And Not loAso.EOS
					p1=binVal(loAso. Read (1))
				EndDo
			EndDo
			loAso. Read (3)
			ret(1)="JPG"
			ret(3)=binval2(loAso. Read (2))
			ret(2)=binval2(loAso. Read (2))
		Otherwise
			If left (Bin2Str(bFlag),2)="BM" Then
				loAso. Read (15)
				ret(1)="BMP"
				ret(2)=binval(loAso. Read (4))
				ret(3)=binval(loAso. Read (4))
			Else
				ret(0)=""
			EndIf
	EndCase
	Local loRet
	loRet= CreateObject ("Empty")
	AddProperty (loRet,"Width",ret(2))
	AddProperty (loRet,"Height",ret(3))
	AddProperty (loRet,"Rate",ret(2)/ret(3))
	Return loRet
EndFunc
*===================================================================
* OOfClass()
*
Function OOfClass(vcClass,vcLib,veP1,veP2,veP3,veP4,veP5)
	Local lnParams,loRet
	lnParams= Parameters ()
	loRet= NULL
	If lnParams<2
		Return NULL
	EndIf
	OpenLib(vcLib)
	Do Case
		Case lnParams==2
			loRet= CreateObject (vcClass)
		Case lnParams==3
			loRet= CreateObject (vcClass,veP1)
		Case lnParams==4
			loRet= CreateObject (vcClass,veP1,veP2)
		Case lnParams==5
			loRet= CreateObject (vcClass,veP1,veP2,veP3)
		Case lnParams==6
			loRet= CreateObject (vcClass,veP1,veP2,veP3,veP4)
		Case lnParams==7
			loRet= CreateObject (vcClass,veP1,veP2,veP3,veP4,veP5)
		Otherwise
	EndCase
	If HasPEM(loRet,"Visible")
		loRet. Visible =.T.
	EndIf
	Return loRet
EndFunc
*===================================================================
*-- 直接从类库创建对象,返回创建对象的引用
Function ONewObject(vcClass,vcLib,vcInApp,vuP1,vuP2,vuP3,vuP4,vuP5,vuP6)
	local lcLib,lnParms,loObject,llOK
	llOK = .T.
	lcLib = vcLib
	If Empty (lcLib)
		llOK = .F.
	EndIf
	If upper (lcLib) $ set ('CLASSLIB')
		llOK = llOK Or .T.
	EndIf
	If upper (lcLib) $ set ('PROCEDURE')
		llOK = llOk Or .T.
	EndIf
	If File (lcLib)
		llOK = llOK Or .T.
	EndIf
	lcLib = ForceExt (vcLib,"VCX")
	If File (lcLib)
		llOK = llOK Or .T.
	EndIf

	lcLib = ForceExt (vcLib,"PRG")
	If File (lcLib)
		llOK = llOK Or .T.
	EndIf

	lcLib = ForceExt (vcLib,"FXP")
	If File (lcLib)
		llOK = llOK Or .T.
	EndIf
	lnParms = pcount ()
	do case
		case lnParms == 1
			loObject = createobject (vcClass)
		case not llOK
			loObject = .NULL.
		case lnParms == 2
			loObject = newobject (vcClass, vcLib)
		case lnParms == 3
			loObject = newobject (vcClass, vcLib, vcInApp)
		case lnParms == 4
			loObject = newobject (vcClass, vcLib, vcInApp, @vuP1)
		case lnParms == 5
			loObject = newobject (vcClass, vcLib, vcInApp, @vuP1,@vuP2)
		case lnParms == 6
			loObject = newobject (vcClass, vcLib, vcInApp, @vuP1,@vuP2, @vuP3)
		case lnParms == 7
			loObject = newobject (vcClass, vcLib, vcInApp, @vuP1,@vuP2, @vuP3, @vuP4)
		case lnParms == 8
			loObject = newobject (vcClass, vcLib, vcInApp, @vuP1,@vuP2, @vuP3, @vuP4, @vuP5)
		case lnParms == 9
			loObject = newobject (vcClass, vcLib, vcInApp, @vuP1,@vuP2, @vuP3, @vuP4, @vuP5, @vuP6)
	endcase
	return loObject
EndFunc

*********************************************************
* 函数名称:--GetSi zeBy()
* 创建时间:--2009 -07-28
* 目 的:--按指定的比例分配数值
* 参 数:
* vnSize -- 数值
* vcRate -- 分配比例
* vnFlag -- 返回形式
* 1-- 分配后的比例字符串
* 2-- 分配后的数值(对象）
* 3-- 分配后的累加数值（对象）
Function GetSizeBy(vnSize,vcRate,vnFlag)
	If IsType(vnFlag,"N")
		If Not InList (vnFlag,1,2,3)
			vnFlag = 1
		EndIf
	Else
		vnFlag = 1
	EndIf
	Do Case
		Case vnFlag==1
			Local lnCounts,lcRet,lnCount,lnSize
			lcRet=""
			lnSize= Evaluate ( Strtran (vcRate,[,],[+]))
			lnCounts= GetWordCount (vcRate,[,])
			For lnCount=1 To lnCounts
				lcRet=lcRet+ToString( Val ( GetWordNum (vcRate,lnCount,[,]))*vnSize/lnSize)+[,]
			EndFor
			lcRet= Left (lcRet, Len (lcRet)-1)
			Return lcRet
		Case vnFlag==2
			Local lnCounts,loRet,lnCount,lnSize,lcProp,lnTemp
			loRet= CreateObject ("Collection")
			lnSize= Evaluate ( Strtran (vcRate,[,],[+]))
			lnCounts= GetWordCount (vcRate,[,])
			For lnCount=1 To lnCounts
				lcProp= Alltrim ( Str (lnCount))
				lnTemp= Val ( GetWordNum (vcRate,lnCount,[,]))*vnSize/lnSize
				loRet. Add (lnTemp)
			EndFor
			Return loRet
		Case vnFlag==3
			Local lnCounts,loRet,lnCount,lnSize,lcProp,lnTemp
			loRet= CreateObject ("Collection")
			lnSize= Evaluate ( Strtran (vcRate,[,],[+]))
			lnCounts= GetWordCount (vcRate,[,])
			lnTemp=0
			For lnCount=1 To lnCounts
				lcProp= Alltrim ( Str (lnCount))
				lnTemp=lnTemp+ Val ( GetWordNum (vcRate,lnCount,[,]))*vnSize/lnSize
				loRet. Add (lnTemp)
			EndFor
			Return loRet
		Otherwise
			Return .NULL.
	EndCase
EndFunc
*===================================================================
* GetUppers()
* 从给定的字符串中提取汉字，并将其转换为首拼音字母字符串
Function GetUppers(vcStr)
	Local lcRet
	lcRet=""
	lcRet=GetChStr(vcStr)
	If ! Empty (lcRet)
		lcRet=GetFirstLetter(lcRet)
	EndIf
	Return lcRet
EndFunc
*===================================================================
* AToListBox()
* 按给定条件调整列表框的现实项目
* 列表框控件必须有数组属性:aItems
Procedure AToLCBox(voList,vcTag)
	Local lnparams
	lnparams= Parameters ()
	*--如果没有提供参数，返回
	If lnparams<1
		Return
	EndIf
	Do Case
		Case lnparams==1 &&--只提供一个参数
			Local lnRows,K
			lnRows= Alen (voList.aItems,1)
			If lnRows>0
				With voList
					. RowSource =""
					. Clear
					. RowSourceType =1
					For K=1 To lnRows
						. List (K)=.aItems[K]
					EndFor
				EndWith
			EndIf
		Case lnparams==2 &&--有筛选条件
			vcTag= Upper ( Alltrim (vcTag))
			Dimension laItems[1]
			Local lnCount,K,lcStr,lnRows
			lnCount=0
			lnRows= Alen (voList.aItems,1)
			If lnRows>0
				For K=1 To lnRows
					lcStr=GetUppers(voList.aItems[K])+;
					Upper (GetEnStr(voList.aItems[K]))
					If vcTag $ lcStr
						lnCount=lnCount+1
						Dimension laItems[lnCount]
						laItems[lnCount]=voList.aItems[K]
					EndIf
				EndFor
				If lnCount>0
					With voList
						. RowSource =""
						. Clear
						. RowSourceType =1
						For K=1 To lnCount
							. List (K,1)=laItems[K]
						EndFor
					EndWith
				EndIf
			EndIf
		Otherwise
			*--Nothing
	EndCase
EndProc
*===================================================================
* ACopyc()
* 将给定的数组的指定列复制到新数组中
Procedure Acopyc(vaSource,vaDest,vnCol)
	vnCol= Iif ( Type ("vnCol")=="N",vnCol,1)
	Local lnRows,K,lnCols
	lnRows= Alen (vaSource,1)
	lnCols= Alen (vaSource,2)
	vnCol= Iif ( Between (vnCol,1,lnCols),vnCol,1)
	If lnRows>0
		For K=1 To lnRows
			Dimension vaDest[K]
			vaDest[K]=vaSource[K,vnCol]
		EndFor
	EndIf
EndProc
*===================================================
* 二进制 Bin 十进制 Dec 十六进制 Hex
Function Bin2Dec(vcBin)
	If Vartype (vcBin)#"C" Or Empty (vcBin)
		Return -1
	EndIf
	Local lnDec,lnLen,i,lcStr
	vcBin= Alltrim (vcBin)
	lnLen= Len (vcBin)
	lnDec=0
	lcStr=""
	For i=0 To lnLen-1
		lcStr= Substr (vcBin,lnLen-i,1)
		If InList (lcStr,"0","1")
			lnDec=lnDec+2^i* Val (lcStr)
		Else
			Return -1
		EndIf
	EndFor
	Return Int (lnDec)
EndFunc
*====================================================
Function Bin2Hex(vcBin)
	If Vartype (vcBin)#"C" Or Empty (vcBin)
		Return -1
	EndIf
	vcBin= Alltrim (vcBin)
	If Mod ( Len (vcBin),4)>0
		vcBin= Padl (vcBin, Int ( Lenc (vcBin)/4)*4+4,"0")
	EndIf
	Local lcHex,i,lcStr,lcStr4
	lcHex= Space (0)
	For i=0 To Len (vcBin)/4-1
		lcStr= Substr (vcBin,i*4+1,4)
		lcStr4= ICase (lcStr=="0000","0",lcStr=="0001","1",;
		lcStr=="0010","2",lcStr=="0011","3",;
		lcStr=="0100","4",lcStr=="0101","5",;
		lcStr=="0110","6",lcStr=="0111","7",;
		lcStr=="1000","8",lcStr=="1001","9",;
		lcStr=="1010","A",lcStr=="1011","B",;
		lcStr=="1100","C",lcStr=="1101","D",;
		lcStr=="1110","E",lcStr=="1111","F")
		If Empty (lcStr4)
			Return -1
		EndIf
		lcHex=lcHex+lcStr4
	EndFor
	If Mod ( Len (lcHex),2)==1
		lcHex="0"+lcHex
	EndIf
	Return lcHex
EndFunc
*=================================================
Function Dec2Bin(vnDec)
	If Vartype (vnDec)#"N" Or vnDec<0
		Return ""
	EndIf
	Local lcBin
	vnDec= Int (vnDec)
	If vnDec==0
		Return "0"
	EndIf
	lcBin= Space (0)
	Do While vnDec>0
		lcBin= Str ( Mod (vnDec,2),1,0)+lcBin
		vnDec= Int (vnDec/2)
	EndDo
	Local lnMode
	lnMode= Mod ( Len (lcBin),8)
	If lnMode#0
		lcBin= Replicate ("0",8-lnMode)+lcBin
	EndIf
	Return lcBin
EndFunc
*==================================================
Function Dec2Hex(vnDec)
	If Vartype (vnDec)#"N" Or vnDec<0
		Return -1
	EndIf
	vnDec= Int (vnDec)
	Local lnMod,lcHex
	lcHex=""
	If vnDec==0
		Return "00"
	EndIf
	Do While vnDec>0
		lnMod= Mod (vnDec,16)
		If lnMod<=9
			lcHex= Alltrim ( Str (lnMod))+lcHex
		Else
			lcHex= Chr (lnMod+55)+lcHex
		EndIf
		vnDec= Int (vnDec/16)
	EndDo
	If Mod ( Len (lcHex),2)==1
		lcHex="0"+lcHex
	EndIf
	Return lcHex
EndFunc
*====================================================
Function Hex2Bin(vcHex)
	If Vartype (vcHex)#"C" Or Empty (vcHex)
		Return -1
	EndIf
	vcHex= Alltrim (vcHex)
	vcHex= Upper (vcHex)
	Local lcBin,lcStr,lcStr4,i
	lcBin= Space (0)
	For i=1 To Len (vcHex)
		lcStr= Substr (vcHex,i,1)
		If InList (lcStr,"0","1","2","3","4","5","6","7","8",;
			"9","A","B","C","D","E","F")
			lcStr4= ICase (lcStr=="0","0000",lcStr=="1","0001",;
			lcStr=="2","0010",lcStr=="3","0011",;
			lcStr=="4","0100",lcStr=="5","0101",;
			lcStr=="6","0110",lcStr=="7","0111",;
			lcStr=="8","1000",lcStr=="9","1001",;
			lcStr=="A","1010",lcStr=="B","1011",;
			lcStr=="C","1100",lcStr=="D","1101",;
			lcStr=="E","1110",lcStr=="F","1111")
		Else
			Return -1
		EndIf
		lcBin=lcBin+lcStr4
	EndFor
	Local lnMod
	lnMod= Mod ( Len (lcBin),8)
	If lnMod#0
		lcBin= Replicate ("0",8-lnMod)+lcBin
	EndIf
	Return lcBin
EndFunc
*================================================
Function Hex2Dec(vcHex)
	If Vartype (vcHex)#"C" Or Empty (vcHex)
		Return -1
	EndIf
	vcHex= Alltrim (vcHex)
	vcHex= Upper (vcHex)
	Local lnDec,lnLen,i,lcStr
	lnLen= Len (vcHex)
	lnDec=0
	For i=0 To lnLen-1
		lcStr= Substr (vcHex,lnLen-i,1)
		If InList (lcStr,"0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F")
			Do Case
				Case lcStr=="A"
					lcStr="10"
				Case lcStr=="B"
					lcStr="11"
				Case lcStr=="C"
					lcStr="12"
				Case lcStr=="D"
					lcStr="13"
				Case lcStr=="E"
					lcStr="14"
				Case lcStr=="F"
					lcStr="15"
				otherwise
			EndCase
			lnDec=lnDec+16^i* Val (lcStr)
		Else
			Return -1
		EndIf
	EndFor
	Return Int (lnDec)

EndFunc
*==================================================
* Long DWORD Num Short WORD
Function Short2Num(vcInt)
	Local b0,b1,lnRetVal
	b0= Asc (vcInt)
	b1= Asc ( Substr (vcInt,2,1))
	If b1<128
		lnRetVal=b1*256+b0
	Else
		b1=255-b1
		b0=256-b0
		lnRetVal=-(b1*256+b0)
	EndIf
	Return lnRetVal
EndFunc
*===================================================
Function Num2Short(vnNum)
	Local b0,b1,X
	If vnNum>=0
		X= Int (vnNum)
		b1= Int (X/256)
		b0= Mod (X,256)
	Else
		X= Int (-vnNum)
		b1=255- Int (X/256)
		b0=256- Mod (X,256)
		If b0==256
			b0=0
			b1=b1+1
		EndIf
	EndIf
	Return Chr (b0)+ Chr (b1)
EndFunc
*====================================================
Function Dword2Num(vcDword)
	Local b0,b1,b2,b3
	b0= Asc (vcDword)
	b1= Asc ( Substr (vcDword,2,1))
	b2= Asc ( Substr (vcDword,3,1))
	b3= Asc ( Substr (vcDword,4,1))
	Return b0+256*(b1+256*(b2+256*b3))
EndFunc
*=====================================================
Function Num2Dword(vnNum)
	Return Num2Long(vnNum)
EndFunc
*=====================================================
Function Word2Num(vcWord)
	Return 256* Asc ( Substr (vcWord,2,1))+ Asc (vcWord)
EndFunc
*=====================================================
Function Num2Word(vnNum)
	vnNum= Int (vnNum)
	Return Chr ( Mod (vnNum,256))+ Chr ( Int (vnNum/256))
EndFunc
*=====================================================
Function Num2Long(vnNum)
	Declare RtlMoveMemory In Win32API As RtlCopyLong ;
	String @pDestString,;
	Integer @pVoidSource,;
	Integer nLength
	Local lcStr
	lcStr= Space (4)
	=RtlCopyLong(@lcStr, Bitor (vnNum,0),4)
	Return lcStr
EndFunc
*=====================================================
Function Long2Num(vcLong)
	Declare RtlMoveMemory In Win32API As RtlCopyLong ;
	Integer @pDestNum,;
	String @pVoidSource,;
	Integer nLength
	Local lnNum
	lnNum=0
	=RtlCopyLong(@lnNum,vnNum,4)
	Return lnNum
EndFunc
*=====================================================
Function Convert(veStr)
	Local lcType,loRet
	lcType= Vartype (veStr)
	loRet= CreateObject ("Empty")
	AddProperty (loRet,"Dec",-1)
	AddProperty (loRet,"Hex","")
	AddProperty (loRet,"Bin","")
	Do Case
		Case lcType=="C" &&--veStr可能是二进制或十六进制
			Local lcBins,lcHexs,K
			lcBins=[0000,0001,0010,0011,0100,0101,0110,0111,;
			1000,1001,1010,1011,1100,1101,1110,1111]
			lcHexs=[0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F]
			For K=1 To 16
				If GetWordNum (lcBins,K,[,])==veStr
					With loRet
						.Dec=K-1
						.Bin=veStr
						.Hex= GetWordNum (lcHexs,K,[,])
					EndWith
					Exit
				EndIf
				If GetWordNum (lcHexs,K,[,])==veStr
					With loRet
						.Dec=K-1
						.Hex=veStr
						.Bin= GetWordNum (lcBins,K,[,])
					EndWith
					Exit
				EndIf
			EndFor
		Case lcType=="N"
			If ! Between (veStr,0,15)
				Return NULL
			EndIf
			Local lcBins,lcHexs
			lcBins=[0000,0001,0010,0011,0100,0101,0110,0111,;
			1000,1001,1010,1011,1100,1101,1110,1111]
			lcHexs=[0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F]
			With loRet
				.Dec=veStr
				.Bin= GetWordNum (lcBins,veStr+1,[,])
				.Hex= GetWordNum (lcHexs,veStr+1,[,])
			EndWith
		Otherwise
	EndCase
	Return loRet
EndFunc
*===================================================================
*----获取菜单项的设置
Function GetMenuItem(vcID)
	Local lcAlias,lcFile,lcOldAlias,loRet
	lcFile="Data\CmenuItems.dbf"
	lcAlias= JustStem (lcFile)
	loRet= NULL
	lcOldAlias=OpenTable(lcAlias,lcFile)
	Locate For Alltrim ( ID )== Alltrim (vcID)
	If Found ()
		Scatter Memo Name oRecord
		loRet=oRecord
	EndIf
	SelOldAlias(lcOldAlias)
	Return loRet
EndFunc
*===================================================================
*----返回程序代码
Function GetCode(vcID)
	Local lcOldAlias,lcCode
	lcCode=""
	vcId= Alltrim (vcId)
	vcId= Upper (vcId)
	lcOldAlias=OpenTable( _Screen .codeAlias, _Screen .codeFile)
	Locate For Upper ( Alltrim ( ID ))== Upper (vcID)
	If Found ()
		lcCode= Alltrim ( Code )
	EndIf
	SelOldAlias(lcOldAlias)
	Return lcCode
EndFunc
*===================================================================
*----运行程序代码
Function RunCode(vcID)
	Local lcOldAlias,lcCode,lcCodeId
	vcID= Upper ( Alltrim (vcID))
	lcOldAlias=OpenTable( _Screen .paramAlias, _Screen .paramFile)
	Locate For Upper ( Alltrim ( ID ))== Alltrim (vcID)
	If Found ()
		*--取得函数代码ID
		lcCodeId= Alltrim (FunctionId)

		*--返回函数代码
		lcCode=GetCode(lcCodeId)

		*--执行函数代码
		If ! Empty (lcCode)
			ExecScript (lcCode)
		EndIf
	EndIf
	SelOldAlias(lcOldAlias)
EndFunc
*===================================================================
*----运行用户程序代码
Function RunUserCode(vcfID,vcpID)
	Local lcOldAlias,lcCode
	vcpID= Upper ( Alltrim (vcpID))
	lcCode=GetCode(vcfID)
	lcOldAlias=OpenTable("Userparams","Data\Userparams.dbf")
	Locate For Upper ( Alltrim ( ID ))==vcpID
	If Found ()
		If ! Empty (lcCode)
			ExecScript (lcCode)
		EndIf
	EndIf
	SelOldAlias(lcOldAlias)
EndFunc
*===================================================================
*----菜单初始化代码
*----参数：
* vcProps="Prop1,Prop2,..."
* vcFlds="Fld1,fld2,..."
Procedure SetMenuProps(voThis,vcProps,vcFlds)
	Local lcOldAlias,lnCounts,lnK,lcProp,lcFld
	lnCounts= GetWordCount (vcProps,[,])
	lcOldAlias=OpenTable( _Screen .paramAlias, _Screen .paramFile)
	Locate For Alltrim ( ID )== Alltrim (voThis. ID )
	If Found ()
		If lnCounts>0
			For lnK=1 To lnCounts
				lcProp= GetWordNum (vcProps,lnK,[,])
				lcFld= GetWordNum (vcFlds,lnK,[,])
				If "PICTURE" $ Upper (lcProp)
					If "IMAGES\" $ Upper (lcProp)
						voThis.&lcProp.= Alltrim (&lcFld.)
					Else
						voThis.&lcProp.="Images\"+ Alltrim (&lcFld.)
					EndIf
				Else
					voThis.&lcProp.= Alltrim (&lcFld.)
				EndIf
			EndFor
		EndIf
	EndIf
	SelOldAlias(lcOldAlias)
EndProc
*===================================================================
*-- --返回菜单标题
*----参数：
* vcId 菜单ID
Procedure GetMenuCaption(vcID)
	Local lcOldAlias,lcRetVal
	lcOldAlias=OpenTable( _Screen .paramAlias, _Screen .paramFile)
	Locate For Alltrim ( ID )== Alltrim (vcID)
	If Found ()
		lcRetVal= Alltrim ( Caption )
	Else
		lcRetVal=""
	EndIf
	SelOldAlias(lcOldAlias)
	Return lcRetVal
EndProc
*===================================================================
*--加载表设置数据环境
Procedure LoadDE(voForm,vcFile,vcNavFlds,vcNavTitles,vcNavWidths,vcQueryFlds)
	If !IsForm(voForm)
		Return
	EndIf
	Local lcAlias
	With voForm
		If File (vcFile)
			.oldMultiLock=SetIDE("Set Multilocks On")
			.oldDelete=SetIDE("Set Delete On")
			. File =vcFile
			lcAlias= JustStem (. File )
			. Alias =lcAlias
			OpenTable(. Alias ,. File )
			. Path = JustPath (. File )
			. DataEnvironment = CreateObject ("DataEnvironment")
			. DataEnvironment . AddObject (. Alias ,"Cursor")
			With . DataEnvironment .&lcAlias.
				. CursorSource =voForm. File
				. Alias =voForm. Alias
				. BufferModeOverride =3

				If CursorGetProp ("Buffering",. Alias )<>3
					= CursorSetProp ("Buffering",3,. Alias )
				EndIf
			EndWith
			.Navfields= Alltrim (vcNavFlds)
			.Navtitles= Alltrim (vcNavTitles)
			.Navfieldwidths= Alltrim (vcNavWidths)
			.Queryfields= Alltrim (vcQueryFlds)
		EndIf
		If PemStatus (voForm,"CObjects",5)
			.CObjects= CreateObject ("Collection")
		EndIf
	EndWith
EndProc
*===================================================================
Function GetUrlState(vcUrl)
	Local oldAlias,loRet
	loRet= NULL
	oldAlias=OpenTable("Urls","Data\Urls.dbf")
	Locate For Lower ( Alltrim (url))== Lower ( Alltrim (vcUrl)) And Upper ( Alltrim (Yxid))== Upper ( _Screen .Yxid)
	If Found ()
		Scatter Name oRecord
		loRet=oRecord
	EndIf
	SelOldAlias(oldAlias)
	Return loRet
EndFunc
*===================================================================
Procedure UrlsToLCBox(voLcBox)
	Local oldAlias,K
	oldAlias=OpenTable("Urls","Data\Urls.dbf")
	K=0
	With voLcBox
		. Clear ()
		. ColumnCount =2
		. ColumnWidths = Alltrim ( Str (. Width -40)) + ",0"
		. ColumnLines = .F.
		Scan For State>0 And Upper ( Alltrim (Yxid))== Upper ( _Screen .Yxid)
			K=K+1
			. List (K,1)= Alltrim (Tips)
			. List (K,2)= Alltrim (Url)
		EndScan
	EndWith
	SelOldAlias(oldAlias)
EndProc
*===================================================================
Function GetHomeURL(vcYxid)
	Local oldAlias,lcRetUrl
	vcYxid = Upper ( Alltrim (vcYxid))
	lcRetUrl = ""
	oldAlias=OpenTable("Urls","Data\Urls.dbf")
	Locate For Upper ( Alltrim (cTag))== "HOME" And Upper ( Alltrim (Yxid)) == vcYxid
	If Found ()
		lcRetUrl = Alltrim (Url)
	EndIf
	SelOldAlias(oldAlias)
	Return lcRetUrl
EndFunc
*===================================================================
* 延时指定的时间
Procedure Delay(vnSec)
	Local lnStart
	lnStart= Seconds ()
	Do While .T.
		If Seconds ()-lnStart>=vnSec
			Exit
		EndIf
	EndDo
EndProc
*===================================================================
* 判断一个对象是否为表单对象
Function IsForm(voObject)
	Return GetBaseClass(voObject) == "FORM"
EndFunc

**********************************************************************
* Author.....: Taken from 1001 things about....Chapter 2 source.
* Program....: Str2Exp
* Compiler...: Visual FoxPro 06.00.8492.00 for Windows
* Abstract...: Passed a string and a data type, return the expression
* ...........: after conversion to the specified data type

**********************************************************************
FUNCTION Str2Exp( tcExp, tcType )
	*** Convert the passed string to the passed data type
	LOCAL luRetVal, lcType
	IF VARTYPE (tcExp) == 'N' AND tcExp == 0
		tcExp = ""
	ENDIF
	*** Remove double quotes (if any)
	tcExp = ALLTRIM ( STRTRAN (tcExp, CHR ( 34 ), "" ))
	*** If no type passed -- display error message
	*** the procedure is not clairvoyant
	IF TYPE ( 'tcType' ) = 'C'
		lcType = UPPER ( ALLTRIM ( tcType ) )
	ELSE
		*** Type is a required parameter. Let the developer know
		ERROR '缺少参数: Str2Exp函数要求必须提供表达式的类型参数'
	ENDIF
	*** Convert from Character to type
	DO CASE
		CASE INLIST ( lcType, 'I', 'N' ) AND INT ( VAL ( tcExp ) ) == VAL ( tcExp ) && 整型
			luRetVal = INT ( VAL ( tcExp ) )
		CASE INLIST ( lcType, 'N', 'Y') && 数值或货币型
			luRetVal = VAL ( tcExp )
		CASE INLIST ( lcType, 'C', 'M' ) && 字符或备注型
			luRetVal = tcExp
		CASE lcType = 'L' && 逻辑性
			*// Modified June 15, 02 By K.Chazotte
			*) Original line commented below
			*) luRetVal = IIF( !EMPTY( tcExp ), .T., .F. )
			DO CASE
				CASE '0'$tcExp OR 'F'$tcExp OR EMPTY (tcExp) OR 'f'$tcExp
					luRetVal = .F.
				CASE '1'$tcExp OR 'T'$tcExp OR 't'$tcExp
					luRetVal = .T.
				OTHERWISE
					ASSERT .F. MESSAGE "Unhandled Case Exception"
					luRetVal = .F.
			ENDCASE
		CASE lcType = 'D' && Date
			luRetVal = CTOD ( tcExp )
		CASE lcType = 'T' && DateTime
			luRetVal = CTOT ( tcExp )
		OTHERWISE
			* 在此没有其他情况，当然，Visual FoxPro有可能添加新的数据类型。
			* 这种情况下，必须修改该函数
	ENDCASE
	*** Return value as Data Type
	RETURN luRetVal
ENDFUNC
* --------------------------------------------------------------
* -- 返回图标文件ICO的大小(Height,Width)的对象
Function GetIcoSize(vcFile)
	Local loSize
	loSize = .NULL.
	If File (vcFile)
		Local lcInfo
		lcInfo = FileToStr (vcFile)
		loSize = CreateObject ("Empty")
		AddProperty (loSize,"Width", CToBin ( Substr (lcInfo,7,1),"RS"))
		AddProperty (loSize,"Height", CToBin ( Substr (lcInfo,7,1),"RS"))
	EndIf
	Return loSize
EndFunc
* --------------------------------------------------------------
* 检查表达式是否为指定的类型
* IsType()
Function IsType(veExp,vcType)
	vcType = Upper ( Alltrim (vcType))
	Local lcType
	lcType = Type ("veExp")
	Return Upper (lcType) == vcType
EndFunc
* -------------------------------------------------------------
* jpg 转tif
Function JPG2TIF(vcJpg)
	If Not Empty (vcJpg)
		Return .F.
	EndIf
	Local loModi,lcTif,llOK
	llOK = .F.
	lcTif = ForceExt ( Alltrim (vcJpg),"tif")
	Try
		loModi = CreateObject ("MODI.Document")
	Catch To oErr WHen oErr == 1733
		loModi = .NULL.
	EndTry
	If Not IsNull (loModi)
		With loModi
			. Create (vcjpg)
			. SaveAs (lcTif)
			. Close ()
		EndWith
		llOK = .T.
	EndIf
	Return llOK
EndFunc
* -------------------------------------------------------------
* 隐藏指定名称的窗口
Procedure HideWindow(vcWinName)
	If Empty (vcName)
		Return
	EndIf
	vcWinName = Alltrim (vcWinName)
	If Wexist (vcWinName)
		Hide Windows (vcWinName)
	EndIf
EndProc
* -------------------------------------------------------------
* 显示指定名称的窗口
Procedure ShowWindow (vcWinName)
	If Empty (vcName)
		Return
	EndIf
	vcWinName = Alltrim (vcWinName)
	If Wexist (vcWinName)
		Show Windows (vcWinName)
	EndIf
EndProc

*********************************************************************
* GetForm()
* 返回对象所在的表单引用
Function GetForm(voObject)
	Do Case
		Case GetBaseClass(voObject) == "FORM"
			Return voObject
		Case Not IsObject(voObject)
			Return .Null.
		Otherwise
			Return GetForm(voObject. Parent )
	Endcase
EndFunc

*********************************************************************
* SetImg()
* 设置对象的图片
Procedure SetImg(voObject,vcImg)
	If IsObject(voObject) And HasPEM(voObject,"Picture")
		voObject. Picture = vcImg
	EndIf
EndProc

*********************************************************************
* SetImg2()
* 设置对象的图片
Procedure SetImg2(voObject,vcImg)
	If IsObject(voObject) And HasPEM(voObject,"Picture")
		With voObject
			. Stretch = 0
			. Picture = vcImg
			. Stretch = 2
		EndWith
	EndIf
EndProc

*********************************************************************
* SetFrColor()
* 设置对象前景色
Procedure SetFrColor(voObj,vnColor)
	If IsObject(voObj) And HasPEM(voObj,"ForeColor")
		voObj. ForeColor = vnColor
	EndIf
EndProc

*********************************************************************
* SetBgColor()
* 设置对象背景色
Procedure SetBgColor(voObj,vnColor)
	If IsObject(voObj) And HasPEM(voObj,"ForeColor")
		voObj. BackColor = vnColor
	EndIf
EndProc

*********************************************************************
* SetCaption()
* 设置对象的标题
Procedure SetCaption(voObj,vcCaption)
	If IsObject(voObj) And HasPEM(voObj,"Caption")
		voObj. Caption = vcCaption
	EndIf
EndProc

*********************************************************************
* SetFont()
* 设置对象的字体名称
Procedure SetFont(voObj,vcFontName)
	If IsObject(voObj) And HasPEM(voObj,"FontName")
		voObj. FontName = vcFontName
	EndIf
EndProc

**********************************************************************
* Program....: ISTAG.PRG
* Compiler...: Visual FoxPro 07.00.0000.9262 for Windows
* Abstract...: Passed the name of an index tag returns true if it is a
* ...........: tag for the specified table. Uses table in the current
* ...........: work area if no table name is passed.

**********************************************************************
FUNCTION IsTag( vcTagName, vcTable )
	LOCAL ARRAY laTags[1]
	IF TYPE ( 'vcTagName' ) # 'C'
		ERROR '9000: 调用ISTAG()时必须传递索引标识名称'
		RETURN .F.
	ENDIF
	IF TYPE ('vcTable') = 'C' AND ! EMPTY ( vcTable )
		ATagInfo (laTags, "", vcTable )
	ELSE
		ATagInfo (laTags, "" )
	ENDIF
	RETURN ( ASCAN ( laTags, vcTagName, -1, -1, 1, 7) > 0)
EndFunc
* -- 检查某数组是否具有指定的信息

**********************************************************************
Procedure ACheck(vaSource,vcList)
	Local llOK
	llOK = .T.
	If IsType(vaSource,"A")
		Local lnRows,lnCounts,K,lcFld
		lnRows = Alen (vaSource,1)
		If lnRows == 0
			llOK = .F.
		Else
			lnCounts = GetWordCount (vcList,[,])
			If lnCounts > 0
				For K = 1 To lnCounts
					lcFld = GetWordNum (vcList,K,[,])
					If ASCAN (vaSource,lcFld, -1, -1, 1, 7) == 0
						llOK = .F.
						Exit
					EndIf
				EndFor
			EndIf
		EndIf
	EndIf
	Return llOK
EndProc

**********************************************************************
Function Msg(vcMsg)
	#Define TIPS_LOC "信息提示"
	If Empty (vcMsg)
		vcMsg = ""
	Else
		vcMsg = Alltrim (vcMsg)
	EndIf
	Return MessageBox (vcMsg,0+64,TIPS_LOC)
EndFunc
*--取指定文件的大小
Function GetFileSize(cfilename)
	If Type (cfilename)<>'C'
		Return 0
	Endif
	c_comp= Set ('comp')
	Set Comp On
	pnsize= Fsize (cfilename)
	Set Comp &c_comp
	Return pnsize
EndFunc
* -- 编辑照片
Procedure EditPhoto(vcFile)
	Local loPS
	If File (vcFile)
		loPS=MkComObj("Photoshop.Application")
		loPS. Open (vcFile)
	EndIf
EndProc
* -- 根据地区名称，查找该地区的院校
Function GetSchoolCode(vcRegion)
	Local lcAlias,lcFile,oldAlias
	Local loRet
	loRet = CreateObject ("Collection")
	lcFile = "Data\institutions.Dbf"
	lcAlias = JustStem (lcFile)
	oldAlias = Opentable(lcAlias,lcFile)
	Scan For Alltrim (vcRegion) $ Alltrim (Xxmc)
		Scatter Name oRecord
		loRet. Add (oRecord)
	EndScan
	SelOldAlias(oldAlias)
	Return loRet
EndFunc