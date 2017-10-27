Public _Form1
_Form1=CreateObject("Form1")
_Form1.show
RETURN

**VFP应用程式算法群（12787940） 行者孙 ：QQ310727570
DEFINE CLASS Form1 AS form
Top = 63
Left = 173
Height = 450
Width = 600
DoCreate = .T.
Caption = "IP地图导航"
BackColor =RGB( 247,239,202)
Name = "Form1"
PROCEDURE Init
this.AddObject("MAPWEB","_classname1")
this.AddObject("web","_classname2")
this.AddObject("Label6","_classname3")
this.AddObject("Shape12","_classname4")
this.AddObject("Command1","_classname5")
this.AddObject("Text1","_classname6")
SET SAFETY OFF 
TEXT TO main NOSHOW 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"> 
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml"> 
<head> 
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/> 
    <title>Google Maps JavaScript API Example: Controls</title> 
    <script src="http://maps.google.com/maps?file=api&amp;v=2&amp;key=ABQIAAAAzr2EBOXUKnm_jVnk0OJI7xSosDVG8KKPE1-m51RBrvYughuyMxQ-i1QfUnH94QxWIa6N4U6MouMmBA"
            type="text/javascript"></script> 
    <script type="text/javascript"> 
var xmlDoc;
    function initialize()
{
var map;
xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
        xmlDoc.async = false;
//xmlDoc.onreadystatechange = readxml;
xmlDoc.load("testWebStudents.xml");
       if (GBrowserIsCompatible()) 
   {
   //----------------------------------------------------------------
   var mapOptions = {
           googleBarOptions : {
              style : "new"
           }
   }
   //----------------------------------------------------------------
   if(xmlDoc.readyState == 4)
   {
    //------------------Xml Code----------------------------- 
    var lat=xmlDoc.documentElement.childNodes[0].text;
    var longi=xmlDoc.documentElement.childNodes[1].text; 
    //-------------------map code-----------------------------         
    map = new GMap2(document.getElementById("map_canvas"),mapOptions);
               map.setCenter(new GLatLng(lat,longi),9);
             map.setUIToDefault();
            var latlng = new GLatLng(lat,longi);
    map.addOverlay(new GMarker(latlng));
    map.enableGoogleBar();     
    //-------------------map end-------------------------------
   }
      }
    }
    </script> 
</head> 
<body onload="initialize()" onunload="GUnload()" topmargin="0" leftmargin="0" rightmargin="0"> 
    <div id="map_canvas" style="width:590px; height: 450px"></div> 
</body> 
</html> 
ENDTEXT 
STRTOFILE(main,'main.html')
ENDPROC
ENDDEFINE
DEFINE CLASS _classname1 AS olecontrol
oleclass='Shell.Explorer.2'
Visible=.T.
Top = 24
Left = 0
Height = 420
Width = 600
Name = "MAPWEB"
PROCEDURE NavigateError
LPARAMETERS pdisp, url, frame, statuscode, cancel
MESSAGEBOX('无法获取数据')
ENDPROC
ENDDEFINE
DEFINE CLASS _classname2 AS olecontrol
oleclass='Shell.Explorer.2'
Visible=.T.
Top = 228
Left = 948
Height = 36
Width = 60
Name = "web"
PROCEDURE DocumentComplete
LPARAMETERS pdisp, url
IF url="http://www.ip2location.com/demo.aspx?ip="+ALLTRIM(thisform.text1.value)
VIEWSTATEValue=STRCONV(thisform.web.document.Form1.__VIEWSTATE.value,14)
Latitude=thisform.web.object.Document.getElementById("dgLookup__ctl2_lblILatitude").innerText &&经度
Longitude=thisform.web.object.Document.getElementById("dgLookup__ctl2_lblILongitude").innerText &&纬度
SET TEXTMERGE ON
TEXT TO testWebStudents NOSHOW 
<?xml version="1.0"?>
<wroot><Latitude><<Latitude>></Latitude><longitutde><<Longitude>></longitutde></wroot>
ENDTEXT
STRTOFILE(testWebStudents,'testWebStudents.xml')
thisform.mapWEB.navigate2(FULLPATH("main.html"))
ENDI
ENDPROC
PROCEDURE NavigateError
LPARAMETERS pdisp, url, frame, statuscode, cancel
MESSAGEBOX('无法获取数据')
ENDPROC
ENDDEFINE
DEFINE CLASS _classname3 AS label
Visible=.T.
AutoSize = .T.
FontSize = 11
BackStyle = 0
Caption = "请输入要查询的IP地址："
Height = 19
Left = 2
Top = 3
Width = 175
Name = "Label6"
ENDDEFINE
DEFINE CLASS _classname4 AS shape
Visible=.T.
Top = 0
Left = 0
Height = 24
Width = 600
BackStyle = 0
BorderColor =RGB( 128,128,255)
Rotation = 12
Name = "Shape12"
ENDDEFINE
DEFINE CLASS _classname5 AS commandbutton
Visible=.T.
Top = 0
Left = 492
Height = 25
Width = 108
Caption = "查询IP地图"
Name = "Command1"
PROCEDURE Click
thisform.WEB.navigate2("http://www.ip2location.com/demo.aspx?ip="+ALLTRIM(thisform.text1.value))
ENDPROC
ENDDEFINE
DEFINE CLASS _classname6 AS textbox
Visible=.T.
FontSize = 10
BackStyle = 0
Height = 22
Left = 168
SpecialEffect = 1
Top = 1
Width = 325
BackColor =RGB( 247,239,202)
BorderColor =RGB( 247,239,202)
Name = "Text1"
ENDDEFINE
