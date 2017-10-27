PUBLIC oform1
oform1=NEWOBJECT("form1")
oform1.Show
RETURN
**************************************************
*-- Form: form1 (e:program files\vfp9\表单1.scx)
*-- 父类: form
*-- 基类: form
*-- 时间戳: 12/18/09 06:02:12 PM
*
DEFINE CLASS form1 AS form
Top = 0
Left = 0
Height = 413
Width = 441
DoCreate = .T.
Caption = "Form1"
Name = "Form1"
ADD OBJECT shape1 AS shape WITH ;
Top = 32, ;
Left = 12, ;
Height = 108, ;
Width = 408, ;
SpecialEffect = 0, ;
Name = "Shape1"
ADD OBJECT label1 AS label WITH ;
AutoSize = .T., ;
Caption = "今天天气", ;
Height = 16, ;
Left = 36, ;
Top = 25, ;
Width = 50, ;
Name = "Label1"
ADD OBJECT label2 AS label WITH ;
Caption = "地名：", ;
Height = 16, ;
Left = 36, ;
Top = 56, ;
Width = 38, ;
Name = "Label2"
ADD OBJECT label3 AS label WITH ;
Caption = "天气：", ;
Height = 16, ;
Left = 144, ;
Top = 56, ;
Width = 38, ;
Name = "Label3"
ADD OBJECT label4 AS label WITH ;
Caption = "气温：", ;
Height = 16, ;
Left = 144, ;
Top = 104, ;
Width = 38, ;
Name = "Label4"
ADD OBJECT image1 AS image WITH ;
Height = 73, ;
Left = 288, ;
Top = 50, ;
Width = 60, ;
Name = "Image1"
ADD OBJECT text1 AS textbox WITH ;
Height = 20, ;
Left = 78, ;
Top = 51, ;
Width = 48, ;
Name = "Text1"
ADD OBJECT text2 AS textbox WITH ;
Height = 20, ;
Left = 180, ;
Top = 54, ;
Width = 84, ;
Name = "Text2"
ADD OBJECT text3 AS textbox WITH ;
Height = 20, ;
Left = 180, ;
Top = 96, ;
Width = 84, ;
Name = "Text3"
ADD OBJECT text4 AS textbox WITH ;
Value = "泸州", ;
Height = 20, ;
Left = 212, ;
Top = 3, ;
Width = 160, ;
Name = "Text4"
ADD OBJECT label5 AS label WITH ;
AutoSize = .T., ;
Caption = "请在这里输入你要查询的城市名称：", ;
Height = 16, ;
Left = 18, ;
Top = 7, ;
Width = 194, ;
Name = "Label5"
ADD OBJECT command1 AS commandbutton WITH ;
Top = 0, ;
Left = 372, ;
Height = 25, ;
Width = 48, ;
Caption = "GO", ;
Name = "Command1"
ADD OBJECT shape2 AS shape WITH ;
Top = 148, ;
Left = 12, ;
Height = 108, ;
Width = 408, ;
SpecialEffect = 0, ;
Name = "Shape2"
ADD OBJECT label6 AS label WITH ;
AutoSize = .T., ;
Caption = "明天天气", ;
Height = 16, ;
Left = 36, ;
Top = 141, ;
Width = 50, ;
Name = "Label6"
ADD OBJECT label7 AS label WITH ;
Caption = "地名：", ;
Height = 16, ;
Left = 36, ;
Top = 172, ;
Width = 38, ;
Name = "Label7"
ADD OBJECT label8 AS label WITH ;
Caption = "天气：", ;
Height = 16, ;
Left = 144, ;
Top = 172, ;
Width = 38, ;
Name = "Label8"
ADD OBJECT label9 AS label WITH ;
Caption = "气温：", ;
Height = 16, ;
Left = 144, ;
Top = 220, ;
Width = 38, ;
Name = "Label9"
ADD OBJECT image2 AS image WITH ;
Height = 73, ;
Left = 288, ;
Top = 166, ;
Width = 60, ;
Name = "Image2"
ADD OBJECT text5 AS textbox WITH ;
Height = 20, ;
Left = 78, ;
Top = 167, ;
Width = 48, ;
Name = "Text5"
ADD OBJECT text6 AS textbox WITH ;
Height = 20, ;
Left = 180, ;
Top = 170, ;
Width = 84, ;
Name = "Text6"
ADD OBJECT text7 AS textbox WITH ;
Height = 20, ;
Left = 180, ;
Top = 212, ;
Width = 84, ;
Name = "Text7"
ADD OBJECT shape3 AS shape WITH ;
Top = 276, ;
Left = 12, ;
Height = 108, ;
Width = 408, ;
SpecialEffect = 0, ;
Name = "Shape3"
ADD OBJECT label10 AS label WITH ;
AutoSize = .T., ;
Caption = "后天天气", ;
Height = 16, ;
Left = 36, ;
Top = 269, ;
Width = 50, ;
Name = "Label10"
ADD OBJECT label11 AS label WITH ;
Caption = "地名：", ;
Height = 16, ;
Left = 36, ;
Top = 300, ;
Width = 38, ;
Name = "Label11"
ADD OBJECT label12 AS label WITH ;
Caption = "天气：", ;
Height = 16, ;
Left = 144, ;
Top = 300, ;
Width = 38, ;
Name = "Label12"
ADD OBJECT label13 AS label WITH ;
Caption = "气温：", ;
Height = 16, ;
Left = 144, ;
Top = 348, ;
Width = 38, ;
Name = "Label13"
ADD OBJECT image3 AS image WITH ;
Height = 73, ;
Left = 288, ;
Top = 294, ;
Width = 60, ;
Name = "Image3"
ADD OBJECT text8 AS textbox WITH ;
Height = 20, ;
Left = 78, ;
Top = 295, ;
Width = 48, ;
Name = "Text8"
ADD OBJECT text9 AS textbox WITH ;
Height = 20, ;
Left = 180, ;
Top = 298, ;
Width = 84, ;
Name = "Text9"
ADD OBJECT text10 AS textbox WITH ;
Height = 20, ;
Left = 180, ;
Top = 340, ;
Width = 84, ;
Name = "Text10"
PROCEDURE Init
PUBLIC oXmlHttp
TRY
    oXmlHttp=CREATEOBJECT("msXml2.XmlHttp")
CATCH
    MESSAGEBOX("创建对象 msXml2.XmlHttp 失败！",16,_screen.Caption)
    RETURN .f.
ENDTRY
ENDPROC
PROCEDURE command1.Click
oXmlHttp.open("post","http://www.ayandy.com/Service.asmx/getWeatherbyCityName",.f.)
ctmpstr="theCityName="+ALLTRIM(thisform.text4.Text)+"&theDayFlag=1"
oXmlHttp.setRequestHeader("CONTENT-TYPE","application/x-www-form-urlencoded")
oXmlHttp.setRequestHeader("Content-Length:",LEN(ctmpstr))
oXmlHttp.send(ctmpstr)
oNodes=oXmlHttp.responseXML.selectNodes("ArrayOfString/string")
thisform.text1.Value=oNodes.item(1).text
thisform.text2.Value=oNodes.item(2).text
thisform.text3.Value=oNodes.item(3).text
oXmlHttp.open("get",oNodes.item(6).text,.f.)
oXmlHttp.send()
thisform.image1.PictureVal=""
thisform.image1.PictureVal=oXmlHttp.responseBody
oXmlHttp.open("post","http://www.ayandy.com/Service.asmx/getWeatherbyCityName",.f.)
ctmpstr="theCityName="+ALLTRIM(thisform.text4.Text)+"&theDayFlag=2"
oXmlHttp.setRequestHeader("CONTENT-TYPE","application/x-www-form-urlencoded")
oXmlHttp.setRequestHeader("Content-Length:",LEN(ctmpstr))
oXmlHttp.send(ctmpstr)
oNodes=oXmlHttp.responseXML.selectNodes("ArrayOfString/string")
thisform.text5.Value=oNodes.item(1).text
thisform.text6.Value=oNodes.item(2).text
thisform.text7.Value=oNodes.item(3).text
oXmlHttp.open("get",oNodes.item(6).text,.f.)
oXmlHttp.send()
thisform.image2.PictureVal=""
thisform.image2.PictureVal=oXmlHttp.responseBody
oXmlHttp.open("post","http://www.ayandy.com/Service.asmx/getWeatherbyCityName",.f.)
ctmpstr="theCityName="+ALLTRIM(thisform.text4.Text)+"&theDayFlag=3"
oXmlHttp.setRequestHeader("CONTENT-TYPE","application/x-www-form-urlencoded")
oXmlHttp.setRequestHeader("Content-Length:",LEN(ctmpstr))
oXmlHttp.send(ctmpstr)
oNodes=oXmlHttp.responseXML.selectNodes("ArrayOfString/string")
thisform.text8.Value=oNodes.item(1).text
thisform.text9.Value=oNodes.item(2).text
thisform.text10.Value=oNodes.item(3).text
oXmlHttp.open("get",oNodes.item(6).text,.f.)
oXmlHttp.send()
thisform.image3.PictureVal=""
thisform.image3.PictureVal=oXmlHttp.responseBody
ENDPROC
ENDDEFINE