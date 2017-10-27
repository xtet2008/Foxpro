*!* 作  者：十豆三
*!* 日  期：2010-06-30
*!* 说  明：本例是获取VFP版的帖子列表，同理也可以获取其他版块的帖子列表。

 

Set Century On
Set Date YMD
Create Cursor CSDN_VFP (帖子标题 C(254),帖子链接 C(254),发帖人 C(50),发帖时间 T,发帖星期 C(6),更新时间 T) && CSDN没有提供 帖子分数、回复数和最后回复人
Declare Integer DeleteUrlCacheEntry In Wininet.Dll String szUrl
* lcCSDNXML="http://forum.csdn.net/Rss/VFP/UnClosedList/" && 更改此链接可以获取其他版块的帖子列表
lcCSDNXML = "http://bbs.csdn.net/forums/VFP.rss"
=DeleteUrlCacheEntry(lcCSDNXML) && 清理缓存
loXMLHTTP=Newobject("Microsoft.XMLHTTP")
loXMLHTTP.Open("get",lcCSDNXML,.F.) && 最近200个帖子
loXMLHTTP.Send()
*!* =Strtofile(loXMLHTTP.responseBody,"C:/CSDN_VFP.xml")
loDom=Newobject("Msxml2.DOMDocument")
loDom.LoadXML(loXMLHTTP.responseText)
lnItemCount=loDom.SelectNodes("/rss/channel/item").Length
For lnI=0 To lnItemCount-1
    lcpubDate=loDom.SelectNodes("/rss/channel/item/pubDate").Item(lnI).Text && 发帖星期及英文日期
    *Set Step On 
    Insert Into CSDN_VFP Values (;
        loDom.SelectNodes("/rss/channel/item/title").Item(lnI).Text,; && 帖子标题
        loDom.SelectNodes("/rss/channel/item/link").Item(lnI).Text,; && 帖子链接
        loDom.SelectNodes("/rss/channel/item/author").Item(lnI).Text,; && 发帖人
        Ctot(itsubstr(lcpubDate,"+",1)),; && 发帖时间
        "星期"+Substrc("一二三四五六日",Ceiling(At(Left(cdow(Ctot(itsubstr(lcpubDate,"+",1))),3),"MonTueWedThuFriSatSun")/3),1),; && 发帖星期 
        Ctot(itsubstr(loDom.selectNodes("/rss/channel/item/updated").Item(lnI).Text,"+",1));&& 更新时间
        )
Endfor
Locate
Browse
Release loXMLHTTP,loDom