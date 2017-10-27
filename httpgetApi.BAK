Function HTTPGET
Parameters URLNAME
Declare Integer InternetOpen In wininet.Dll String, Integer, String, String, Integer
Declare Integer InternetOpenUrl In wininet.Dll Integer, String, String, Integer, Integer, Integer
Declare Integer InternetReadFile In wininet.Dll Integer, String @, Integer, Integer @
Declare short InternetCloseHandle In wininet.Dll Integer
SAGENT="Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022)"
HINTERNETSESSION = INTERNETOPEN(SAGENT,0,"","",0)
If HINTERNETSESSION = 0
Return ""
Endif
HURLFILE = INTERNETOPENURL(HINTERNETSESSION,URLNAME,"",0,2147483648,0)
If HURLFILE = 0
Return ""
Endif
STRFF=""
Do While .T.
SREADBUFFER = Space(1024)
LBYTESREAD = 0
m.OK = INTERNETREADFILE(HURLFILE,@SREADBUFFER,Len(SREADBUFFER),@LBYTESREAD)
If m.OK = 0 .Or. LBYTESREAD = 0
Exit
Else
STRFF=STRFF+SREADBUFFER
Endif
Enddo
= INTERNETCLOSEHANDLE(HURLFILE)
= INTERNETCLOSEHANDLE(HINTERNETSESSION)
Clear Dlls INTERNETOPEN,INTERNETOPENURL,INTERNETREADFILE,INTERNETCLOSEHANDLE
=DELCACHE(URLNAME)
Return STRFF
Endfunc
*É¾³ýÍøÒ³»º´æ
Function DELCACHE
 Parameters LCREMOTEURL
 TFFJG=-99
 Declare Integer DeleteUrlCacheEntry In Wininet.Dll String szUrl
 TFFJG=DELETEURLCACHEENTRY(LCREMOTEURL) &&É¾³ý»º´æ£¬É¾³ý³É¹¦·µ»Ø1£¬²»´æÔÚ»òÊ§°Ü·µ»Ø0
 Clear Dlls DELETEURLCACHEENTRY
 Return TFFJG
Endfunc

