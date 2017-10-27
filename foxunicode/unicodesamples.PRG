SET PROCEDURE TO wwUtils ADDITIVE
SET CLASSLIB TO wwSQL ADDITIVE
CLEAR

*** Make sure you set the connection strings!!!
oSamples = CREATEOBJECT("UnicodeSamples")
oSamples.cOdbcConnectionString =  "driver={sql server};server=(local);database=WestwindAdmin"
oSamples.cADOConnectionString =  "Provider=sqloledb;Data Source=(local);Initial Catalog=WestWindAdmin;Integrated Security=SSPI"

*oSamples.CreateSqlSampleTable()
*RETURN

SET STEP ON 
oSamples.OdbcUTF8Query()

*oSamples.AdoRecordSetQuery()

*oSamples.AdoQuery()
*oSamples.AdoInsert()

*oSamples.wwAdoSqlQuery()
*oSamples.wwAdoSqlInsert()

RETURN


*************************************************************
DEFINE CLASS UnicodeSamples AS Custom
*************************************************************
*: Author: Rick Strahl
*:         (c) West Wind Technologies, 2005
*:Contact: http://www.west-wind.com
*:Created: 01/01/2005
*************************************************************
#IF .F.
*:Help Documentation
*:Topic:
Class UnicodeSamples

*:Description:

*:Example:

*:Remarks:

*:SeeAlso:


*:ENDHELP
#ENDIF

*** Custom Properties
cODBCConnectionString = "driver={sql server};server=(local);database=WestWindAdmin"
cAdoConnectionString = "Provider=sqloledb;Data Source=(local);Initial Catalog=WestWindAdmin;Integrated Security=SSPI"


cErrorMsg = ""
lError = .f.

*EOC UnicodeSamples 

************************************************************************
* UnicodeSamples :: CreateDataBase
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION CreateSqlSampleTable()

IF EMPTY(this.cOdbcConnectionString)
   INPUTBOX("Please enter a connection string to the database",;
            "SQL Database Connection","")
ENDIF

TEXT TO lcSql NOSHOW
CREATE TABLE [dbo].[ForeignData]
(
[Id] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descript] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL DEFAULT (''),
[lDescript] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL DEFAULT ('')
)
ENDTEXT


loSQL = CREATEOBJECT("wwADOSQL")
loSQL.nCodePage = 65001
IF !loSQL.Connect(this.cADOConnectionString)
   MESSAGEBOX("Unable to connect to the database" + CHR(13) + CHR(13) +;
               loSQL.cErrorMsg,48)
   RETURN
ENDIF   

IF !loSQL.ExecuteNonQuery(lcSQL) 
   MESSAGEBOX(loSQL.cErrorMsg,48)
ELSE
   MESSAGEBOX("Table created in Database.")
ENDIF

pcData = 'This is some basic English text'
TEXT TO lcSQL NOSHOW
INSERT INTO ForeignData (ID, Descript, lDescript ) VALUES
 ('_11111','English',?pcData)
ENDTEXT
? loSQL.ExecuteNonQuery(lcSQL)

pcData = 'Odkryj Telefon Motoroli Który Pasuje do Twojego Stylu Życia!Odkryj Telefon Motoroli Który'
TEXT TO lcSQL NOSHOW
INSERT INTO ForeignData (ID, Descript, lDescript ) VALUES
 ('_11112','Polish',?pcData)
ENDTEXT
? loSQL.ExecuteNonQuery(lcSQL)

pcData = 'Большой цветной внутренний дисплей'
TEXT TO lcSQL NOSHOW
INSERT INTO ForeignData (ID, Descript, lDescript ) VALUES
 ('_11113','Russian',?pcData)
ENDTEXT
? loSQL.ExecuteNonQuery(lcSQL)

pcData = '새롭게 소개되는 멋진 단말기 칼라 '
TEXT TO lcSQL NOSHOW
INSERT INTO ForeignData (ID, Descript, lDescript ) VALUES
 ('_11114','Korean',?pcData)
ENDTEXT
? loSQL.ExecuteNonQuery(lcSQL)

pcData = '鮮艷彩色內置顯示屏'
TEXT TO lcSQL NOSHOW
INSERT INTO ForeignData (ID, Descript, lDescript ) VALUES
 ('_11115','Chinese',?pcData)
ENDTEXT
? loSQL.ExecuteNonQuery(lcSQL)

ENDFUNC
*  UnicodeSamples :: CreateDataBase


************************************************************************
* UnicodeSamples :: OdbcQuery
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION OdbcUtf8Query()

lnHandle = SQLSTRINGCONNECT(this.cODBCConnectionString)
IF lnHandle = -1
   this.FillErrors()
   MESSAGEBOX(this.cErrorMsg)
   RETURN 
ENDIF

TEXT TO lcSQL NOSHOW
select ID,
   CAST( CAST( Descript as nVarChar(4000) ) as VarBinary(8000) ) as Note,
   CAST( CAST( lDescript as nVarChar(4000) ) as VarBinary(8000) ) as Description
from ForeignData
ENDTEXT

lnResult = SQLEXEC(lnHandle,lcSQL,"TFData")
IF lnResult < 1
   THIS.FillErrors()
   MESSAGEBOX(this.cErrorMsg)
ENDIF

=SQLDISCONNECT(lnHandle)

*** Now convert into UTF-8 data
SELECT CAST( STRCONV( Note,10) as M) as Note, ;
       CAST( STRCONV( Description, 10) as M) as Description ;
   FROM TFData ;
   INTO CURSOR TFData2

*** You should really do this:
*!*   SELECT STRCONV( Note,10) as Note, ;
*!*          CAST( STRCONV( Description, 10) as M)  as Description ;
*!*      FROM TFData ;
*!*      INTO CURSOR TFData2
   
BROWSE   

ShowHtml( THIS.CursorToHtml("ODBCQuery with SQL Passthrough") )

ENDFUNC
*  UnicodeSamples :: OdbcQuery

************************************************************************
* UnicodeSamples :: AdoQuery
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION AdoRecordSetQuery()

pcLang="%"  && Our query parameter

SYS(3101,65001)

LOCAL oConn as ADODB.Connection
oConn = CREATEOBJECT("ADODB.Connection")
oConn.ConnectionString = this.cADOConnectionString
oConn.Open()

LOCAL oCommand as ADODB.Command
oCommand = CREATEOBJECT("ADODB.Command")
oCommand.ActiveConnection = oConn

oCommand.CommandText = ;
  "Select Descript, lDescript as Description " + ;
  "from foreigndata"

LOCAL oRS as ADODB.RecordSet
oRS = oCommand.Execute()

lcHTML = this.HtmlHeader("ADO Recordset via COM") 
*** 
IF !ISNULL(oRS) AND oRS.State = 1
   DO while !oRS.EOF 
      lcHtml = lcHTML + ;
         oRS.Fields("Descript").Value + " - " +;
         oRS.Fields("Description").Value + "<hr>" + CHR(13) + CHR(10)
      oRS.MoveNext()
   ENDDO
ELSE
   WAIT WINDOW "SQL command failed." NOWAIT
   RETURN
ENDIF   

lcHTML = lcHtml  + "</body></html>"

ShowHtml(lcHTML)

*** Make free standing cursor

RETURN
ENDFUNC
*  UnicodeSamples :: AdoQuery


************************************************************************
* UnicodeSamples :: AdoQuery
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION AdoQuery()

pcLang="%"  && Our query parameter

*SYS(3101,65001)

LOCAL oConn as ADODB.Connection
oConn = CREATEOBJECT("ADODB.Connection")
oConn.Open(this.cADOConnectionString)

LOCAL oCommand as ADODB.Command
oCommand = CREATEOBJECT("ADODB.Command")
oCommand.ActiveConnection = oConn

LOCAL oRS as ADODB.RecordSet
oRS = CREATEOBJECT("ADODB.RecordSet")
oRS.ActiveConnection = oConn

LOCAL oCA as CursorAdapter
oCA = CREATEOBJECT("CursorAdapter")
oCA.ADOCodePage = 65000
oCA.Alias = "TSqlQUery"
oCA.DataSourceType = "ADO"
oCA.DataSource = oRS

oCA.SelectCmd = ;
  "Select Descript, lDescript as Description " + ;
  "from foreigndata where descript like ?pcLang"

IF USED(oCA.Alias)
   USE IN (oCA.Alias)
ENDIF

*** Fill the cursor based on Command object
*** Must pass Command object to get parameter parsing to work
IF !oCA.CursorFill(,,,oCommand)
  AERROR(laErrors)
  ? lAERRORS[1]
  ? lAERRORs[2]
  RETURN
ENDIF

*** Make free standing cursor
oCA.CursorDetach()

BROWSE

RETURN
ENDFUNC
*  UnicodeSamples :: AdoQuery


************************************************************************
* UnicodeSamples :: AdoInsert
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION AdoInsert()

*** Some Russian text - must convert to UTF-8 for Insert
lDescriptBin = STRCONV("EQQ+BDsETARIBD4EOQQgAEYEMgQ1BEIEPQQ+BDkEIAAyBD0EQwRCBEAENQQ9BD0EOAQ5BCAANAQ4BEEEPwQ7BDUEOQQ=",14) 
lcDescriptUtf8 = STRCONV(lDescriptBin,10)

pcID = SYS(2015)
pcDescript = "Russian"
pclDescript = lcDescriptUtf8

lcSql = [Insert into ForeignData (id,descript,lDescript) values ] +;
        [(?,?,?)]

SYS(3101,65001)

LOCAL oConn as ADODB.Connection
oConn = CREATEOBJECT("ADODB.Connection")
oConn.ConnectionString = THIS.cAdoConnectionString
oConn.Open()

LOCAL oCommand as ADODB.Command
oCommand = CREATEOBJECT("ADODB.Command")
oCommand.ActiveConnection = oConn
oCommand.CommandText = lcSQL


LOCAL oParameter as ADODB.Parameter 
oParameter = CREATEOBJECT("ADODB.Parameter")
oParameter.Type= 202  && adVarWChar
oParameter.Value = pcId
oParameter.Size = LEN(pcID)
oCommand.Parameters.Append(oParameter)


*** Or wrappered
this.AdoAddParameter(oCommand,pcDescript)
this.AdoAddParameter(oCommand,pclDescript)


lnAffected=0
? oCommand.Execute(@lnAffected,,128)     && No result set

RETURN

************************************************************************
* UnicodeSamples :: ADOAddParameter
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION ADOAddParameter
LPARAMETERS loCommand, lvValue, lcName, lcDirection, lnType, lnSize, lnPrecision

LOCAL oParameter as ADODB.Parameter
oParameter = CREATEOBJECT("ADODB.Parameter")
oParameter.Direction = 1  && InParm by default

oParameter.Value = lvValue

IF !EMPTY(lcName)
  oParameter.Name = lcName
ENDIF

IF !EMPTY(lnType)
  *** Type info passed
  oParameter.Type  = lnType
  IF !EMPTY(lnSize)
     oParameter.Size = lnSize
  ENDIF
  IF !EMPTY(lnPrecision)
     oParameter.Precision = lnPrecision
  ENDIF
ELSE
  *** No Type Info passed - guess
  lcType = VARTYPE(lvValue)
  DO CASE
  CASE lcType = "C"
      oParameter.Type = 202  && adVarWChar
      oParameter.Size = LEN(lvValue)
      IF oParameter.Size < 1
         oParameter.Size = 1
      ENDIF

      *** Switch to nTEXT over 4000
      IF oParameter.Size > 4000
         oParameter.Type= 203  && adLongVarWChar 
         oParameter.Size = LEN(lvValue)
      ENDIF
 CASE lcType = "N"
     oParameter.Type= 5  && adDouble
     oParameter.Size = 16
   CASE lcType = "L"
      oParameter.Type= 11  && adBoolean
   CASE lcType = "T" OR lcType = "D"
      oParameter.Type = 7 &&adDate
   CASE lcType = "W" OR lcType = "Q"
      oParameter.Type= 204  && adVarBinary
      oParameter.Size = LEN(lvValue)
      IF (oParameter.Size) > 8000
         oParameter.Type= 205  && adLongVarBinary
         oParameter.Size= .null.
      ENDIF
      IF oParameter.Size = 0
         oParameter.Size=1
      ENDIF
  OTHERWISE
      oParameter.Type = 12 && adVariant
  ENDCASE
ENDIF

IF !EMPTY(lcDirection) AND ;
   UPPER(lcDirection) = "OUT"
      oParameter.Direction=3  &&adOutput
ENDIF

loCommand.Parameters.Append(oParameter)

ENDFUNC
*  UnicodeSamples :: ADOAddParameter


************************************************************************
* UnicodeSamples :: wwAdoSqlQuery
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION wwAdoSqlQuery()

LOCAL o as wwADOSql
IF .T.
   o = CREATEOBJECT("wwADOSql")
   o.nCodepage=65001
   ? o.Connect(this.cAdoConnectionString)
ELSE
   o = CREATEOBJECT("wwSql")
   ? o.Connect(this.cODBCConnectionString)
ENDIF

? o.Execute("select id,descript as Description,lDescript as  Note from foreigndata") && Utf-8 data returned
if o.lError
   ? o.cErrorMsg
   RETURN
endif

ShowHtml( this.CursorToHtml("wwADOSql Query Result") )

ENDFUNC
*  UnicodeSamples :: wwAdoSqlQuery

************************************************************************
* UnicodeSamples :: wwADOSqlInsert
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION wwADOSqlInsert()

LOCAL o as wwADOSql
IF .T.
   o = CREATEOBJECT("wwADOSql")
   o.nCodepage=65001
   if !o.Connect(this.cAdoConnectionString)
      ? o.cErrorMsg
      RETURN
   ENDIF
ELSE
   o = CREATEOBJECT("wwSql")
   IF o.Connect(this.cODBCConnectionString)
      ? o.cErrorMsg
      RETURN
   ENDIF
ENDIF

o.AddParameter(SYS(2015),"pcID")
o.AddParameter("Polish","pcDescript")
o.AddParameter([Odkryj Telefon Motoroli Który Pasuje do Twojego Stylu Życia!Odkryj Telefon Motoroli Który])  && UTF-8 encoded

? " Executing Query"
? o.ExecuteNonQuery("insert into foreigndata (id,Descript,lDescript) values " +;
                    "(?pcID,?pcDescript,?pclDescript)" )
? o.cErrorMsg


*** Re-run query to refresh the data with our view.
this.wwADoSqlQuery()

ENDFUNC
*  UnicodeSamples :: wwADOSqlInsert


************************************************************************
* UnicodeSamples :: ShowCursorAsHtml
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION CursorToHtml(lcHeader)

IF EMPTY(lcHeader)
   lcHeader = "VFP Unicode Data Representation"
ENDIF

lcHTML = this.HtmlHeader(lcHeader) 

*** UTF-8 Encode - not necessary here, but if you had extended text
*** you'd need to do this
lcHtml = STRCONV(lcHTML,9)

SCAN
   lcHTML = lcHTML + Note + " - " + Description + ;
            "  <hr>" + CHR(13) + CHR(10)
ENDSCAN

lcHTML = lcHTML + "</body></html>"

RETURN lcHTML
ENDFUNC
*  UnicodeSamples :: ShowCursorAsHtml


************************************************************************
* UnicodeSamples :: HtmlHeader
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION HtmlHeader(lcHeader)
LOCAL lcHTML
TEXT TO lcHTML NOSHOW TEXTMERGE
<HTML>
<HEAD>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
</HEAD>
<body style="font-family:verdana;font-size:10pt">
<h2><<lcHeader>></h2>
<hr>
ENDTEXT

RETURN lcHTML
ENDFUNC
*  UnicodeSamples :: HtmlHeader
************************************************************************
* UnicodeSamples :: FillErrors
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION FillErrors()
LPARAMETER lcClear
LOCAL lnLoc, lcErrorMsg

lcClear=IIF(type("lcClear")="C",UPPER(lcClear),"")

IF lcCLear = "CLEAR"
   THIS.lError=.F.
   THIS.cErrorMsg = ""
   RETURN
ENDIF

lnCount = AERROR(laError)
IF lnCount > 0
   this.cErrorMsg = laError[2]
ENDIF

ENDFUNC
*  UnicodeSamples :: FillErrors
ENDDEFINE


