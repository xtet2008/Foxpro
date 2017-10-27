************************************************************************
* WCONNECT Header File
**********************
***    Author: Rick Strahl
***            (c) West Wind Technologies, 1995-2004
***   Contact: http://www.west-wind.com/
***  Function: Global DEFINEs used by West Wind Web Connection.
***
*** IMPORTANT: Any changes made here or in WCONNECT_OVERRIDE.H
***            require a full recompile of all files that use
***            this header file!
************************************************************************

#DEFINE WWVERSION "Version 4.61"
#DEFINE WWVERSIONDATE "October 28, 2004"

*** DEBUGMODE effects how errors are handled.
*** If .T. errors are not handled and the server stops on errors.
*** If .F. the Web Connection error handlers kick in and
*** provide error pages and logging
#DEFINE DEBUGMODE .T.

*** Use this flag to handle different configurations
*** You can set up conditional DEFINES for applications
*** to easily switch configurations. (Optional - not used by framework)
*** 1 -  Development Server
*** 2 -  Live Server
#DEFINE LOCALSITE 1

*** When .T. server runs as a Top Level while running file based
#DEFINE SERVER_IN_DESKTOP	.F.

*** Carriage Return/Line Break
#DEFINE CR					CHR(13)+CHR(10)  && DO NOT USE ANY MORE
#DEFINE CRLF				CHR(13)+CHR(10)

*** Customizable default HTTP Header
#DEFINE DEFAULT_CONTENTTYPE_HEADER ;
   "HTTP/1.1 200 OK" + CRLF + ;
	"Content-type: text/html" + CRLF

#DEFINE DEFAULT_HTTP_VERSION	"1.1"

*** Post boundary used for posting multipart vars
#DEFINE POST_BOUNDARY    		CRLF + "#@$ FORM VARIABLES $@#" + CRLF
#DEFINE MULTIPART_BOUNDARY		"------7cf2a327f01ae"

*** SQL Connect String to database containing
*** wwSession and RequestLog files
#DEFINE WWC_USE_SQL_SYSTEMFILES			.F.

*** Determines whether the store runs with SQL Server Tables
#DEFINE WWSTORE_USE_SQL_TABLES			.F.
#DEFINE WWMSGBOARD_USE_SQL_TABLES		.F.

*** Visual FoxPro Version Number Macro
#DEFINE wwVFPVERSION  VAL(SUBSTR(Version(),ATC("FoxPro",VERSION())+7,2))

*** Determines whether TEMPLATE pages are cached (ExpandTemplate calls)
*** Note: This value specifies how often the file is checked for
***       a newer version in seconds. 0 means - don't cache.
#DEFINE WWC_CACHE_TEMPLATES			0

*** When set on adds Browser and POST data to the log
*** NOTE: This can really bloat your log considerably
***       so I suggest you use this feature only under
***       problem scenarios
***       If you switch formats make sure to delete the
***       log file.
#DEFINE WWC_EXTENDED_LOGGING_FORMAT  .F.


*** Maximum String size for the wwResponseString class
#DEFINE MAX_STRINGSIZE  			10000

*** Maximum number of cells that ShowCursor generates
*** before reverting to <pre> list
#DEFINE MAX_TABLE_CELLS 			15000

*** Special 'NULL' String to differentiate none from empty strings
#DEFINE WWC_NULLSTRING "*#*"

*** Defines the location of the Web Connection framework
*** the default is the current directory
#DEFINE WWC_FRAMEWORK_PATH			".\"

*** XML Size Id used for Memo Fields to differentiate memos from strings
*** This value is compatible with ADO's usage
#DEFINE XML_SCHEMA_MEMOSIZE			2147483647

#DEFINE XML_XMLDOM_PROGID			"msxml2.domdocument"  && "MSXML2.DOMDocument.4.0"
#DEFINE MSXML_PROGID             XML_XMLDOM_PROGID
#DEFINE MSSOAP_PROGID            "MSSOAP.SOAPCLIENT30"

*** Determines whether wwXML::XMLTOCURSOR tries to use
*** VFP 7's XMLTOCURSOR. NOTE: Requires SP1!!!!
*** This can drastically improve performance for large data sets
#DEFINE WWXML_USE_VFP_XMLTOCURSOR   .F.

*** Always filter Unsafe Commands like EVAL, EXECSTR
*** in FORM and QUERYSTRING results
#DEFINE WWWC_FILTER_UNSAFECOMMANDS	.F.

*** Default Session Cookie Name
#DEFINE WWWC_DEFAULT_SESSIONCOOKIE_NAME "WCSESSIONSTATE"

*** Class Names - These classes are defined here and used in the code
***               so if you subclass an essential class you can change
***               the class used here and automatically have the framework
***               inherit from your subclass
#DEFINE WWC_SERVER				wwServer
#DEFINE WWC_SERVERFORM 			wwServerForm
#DEFINE WWC_SERVERFORM_VFPFRAME wwServerFormVFPFrame

#DEFINE WWC_PROCESS         	wwProcess
#DEFINE WWC_WEBSERVICE			wwWebService

#DEFINE WWC_SESSION 			   wwSession
#DEFINE WWC_SQLSESSION 			wwSessionSQL

#DEFINE WWC_REQUEST				wwRequest
#DEFINE WWC_REQUESTASP			wwASPRequest

#DEFINE WWC_RESPONSE			   wwResponse
#DEFINE WWC_RESPONSEFILE    	wwResponseFile
#DEFINE WWC_RESPONSESTRING		wwResponseStringNoBuffer
#DEFINE WWC_RESPONSEASP			wwASPResponse

#DEFINE WWC_WWDHTMLFORM       wwDhtmlForm
#DEFINE WWC_WWDHTMLCONTROL    wwDhtmlControl

#DEFINE WWC_HTTPHEADER			wwHTTPHeader
#DEFINE WWC_HTMLHEADER        wwHtmlHeader

#DEFINE WWC_WWEVAL 				wwEval
#DEFINE WWC_WWVFPSCRIPT     	wwVFPScript
#DEFINE WWC_WWPDF				   wwPDF50
#DEFINE WWC_WWSOAP				wwSOAP
#DEFINE WWC_WWCONFIG          wwConfig
#DEFINE WWC_CACHE             wwCache
#DEFINE WWC_WWBUSINESS			wwBusiness

*** Class Include flags - Use these to make the install lighter   -  New 07/05/97
#DEFINE WWC_LOAD_WWSESSION 				.T.
#DEFINE WWC_LOAD_WWBANNER 					.T.
#DEFINE WWC_LOAD_WWSHOWCURSOR          .T.
#DEFINE WWC_LOAD_WWDBFPOPUP 				.T.
#DEFINE WWC_LOAD_WWIPSTUFF 			   .T.
#DEFINE WWC_LOAD_WWHTTP                .T.
#DEFINE WWC_LOAD_WWBUSINESS            .T.
#DEFINE WWC_LOAD_WWSQL      		      .T.
#DEFINE WWC_LOAD_WWHTTPSQL             .T.
#DEFINE WWC_LOAD_WWVFPSCRIPT 				.T.
#DEFINE WWC_LOAD_WWPDF						.T.
#DEFINE WWC_LOAD_WWXML						.T.  && Don't change! Required!
#DEFINE WWC_LOAD_WWMSMQ						.F.
#DEFINE WWC_LOAD_WWSOAP						.T.
#DEFINE WWC_LOAD_DYNAMICHTML_FORMRENDERING  .T.

*** VERSION CONSTANTS
#DEFINE SHAREWARE 		.F.
#DEFINE WWC_DEMO		.T.
#DEFINE SWTIMEOUT 		1800
#DEFINE HTMLCLASSONLY 	.F.

#DEFINE SHOWSQLERRORS 	   .F.
#DEFINE FOXISAPI 		   .F.
#DEFINE VISUALWEBBUILDER   .F.

*** COMPATIBILITY CONSTANTS
*** Turn on for backwards compatibility
*** As features are removed they are bracketed in this flag.
#DEFINE WWC_COMPATIBILITY    .F.

*** Use old Style button in Form Rendering
*** All buttons are rendered with the same name if .t.
*** END COMPATIBILITY CONSTANTS

*** Images in forms are pathed relative to the Web request
*** and must be located in the directory specified here
#DEFINE WWFORM_IMAGEPATH "formimages/"
#DEFINE WWFORM_USEOLD_BUTTONSTYLE   .F.

*** wwList ActiveX Control settings - Changed 9/2/2000
#DEFINE WWLIST_USEOLDGRID .F.
#DEFINE WWLIST_CLASSID "36E500EB-8219-11D1-A398-00600889F23B"
#DEFINE WWLIST_CODEBASE "wwCTLS.cab"

#DEFINE LISTVIEW_CLASSID "BDD1F04B-858B-11D1-B16A-00C0F0283628"
#DEFINE LISTVIEW_CODEBASE "http://activex.microsoft.com/controls/vb6/MSComCtl.cab"

*** General WinINET Constants
#DEFINE INTERNET_OPEN_TYPE_PRECONFIG    		0
#DEFINE INTERNET_OPEN_TYPE_DIRECT       		1
#DEFINE INTERNET_OPEN_TYPE_PROXY             	3

#DEFINE INTERNET_OPTION_CONNECT_TIMEOUT         2
#DEFINE INTERNET_OPTION_CONNECT_RETRIES         3
#DEFINE INTERNET_OPTION_SEND_TIMEOUT       		5
#DEFINE INTERNET_OPTION_RECEIVE_TIMEOUT    		6
#DEFINE INTERNET_OPTION_DATA_SEND_TIMEOUT       5
#DEFINE INTERNET_OPTION_DATA_RECEIVE_TIMEOUT    6
#DEFINE INTERNET_OPTION_LISTEN_TIMEOUT          11
#DEFINE INTERNET_OPTION_DISABLE_AUTODIAL        70

#DEFINE INTERNET_SERVICE_FTP				    1
#DEFINE INTERNET_DEFAULT_FTP_PORT				21

#DEFINE ERROR_INTERNET_EXTENDED_ERROR           12003

*** WinInet Service Flags
#DEFINE INTERNET_SERVICE_HTTP         			3
#DEFINE INTERNET_DEFAULT_HTTP_PORT      		80
#DEFINE INTERNET_DEFAULT_HTTPS_PORT   		  	443

#DEFINE INTERNET_FLAG_RELOAD            		2147483648
#DEFINE INTERNET_FLAG_SECURE            		8388608
#define INTERNET_FLAG_KEEP_CONNECTION        0x00400000


#DEFINE HTTP_STATUS_PROXY_AUTH_REQ           	407
#define HTTP_QUERY_STATUS_CODE                  19
#define HTTP_QUERY_FLAG_NUMBER                  0x20000000
#DEFINE HTTP_QUERY_RAW_HEADERS_CRLF          	22

*** Allow certificate errors
#DEFINE INTERNET_FLAG_IGNORE_CERT_DATE_INVALID  0x00002000
#DEFINE INTERNET_FLAG_IGNORE_CERT_CN_INVALID    0x00001000
*** Allow Cookies to be set manually
#DEFINE INTERNET_FLAG_NO_COOKIES                0x00080000  

#define HTTP_QUERY_STATUS_CODE                  19
#define HTTP_QUERY_STATUS_TEXT                  20

#DEFINE FTP_TRANSFER_TYPE_ASCII     			   1
#DEFINE FTP_TRANSFER_TYPE_BINARY    			   2
#DEFINE FTP_CONNECT_PASSIVE                     134217728

*** Win32 API Constants
#DEFINE ERROR_SUCCESS               			0

*** Access Flags
#DEFINE GENERIC_READ                     		0x80000000
#DEFINE GENERIC_WRITE                    		0x40000000
#DEFINE GENERIC_EXECUTE                  		0x20000000
#DEFINE GENERIC_ALL                      		0x10000000

*** File Attribute Flags
#DEFINE FILE_ATTRIBUTE_NORMAL               	0x00000080
#DEFINE FILE_ATTRIBUTE_READONLY             	0x00000001
#DEFINE FILE_ATTRIBUTE_HIDDEN               	0x00000002
#DEFINE FILE_ATTRIBUTE_SYSTEM               	0x00000004

*** Values for FormatMessage API
#DEFINE FORMAT_MESSAGE_FROM_SYSTEM     			4096
#DEFINE FORMAT_MESSAGE_FROM_HMODULE    			2048

*** Registry roots
#DEFINE HKEY_CLASSES_ROOT           -2147483648  && (( HKEY ) 0x80000000 )
#DEFINE HKEY_CURRENT_USER           -2147483647  && (( HKEY ) 0x80000001 )
#DEFINE HKEY_LOCAL_MACHINE          -2147483646  && (( HKEY ) 0x80000002 )
#DEFINE HKEY_USERS                  -2147483645  && (( HKEY ) 0x80000003 )

*** Registry Value types
#DEFINE REG_NONE					0    && Undefined Type (default)
#DEFINE REG_SZ						1	 && Regular Null Terminated String
#DEFINE REG_BINARY				3    && ??? (unimplemented)
#DEFINE REG_DWORD					4    && Long Integer value
#DEFINE MULTI_SZ					7	 && Multiple Null Term Strings (not implemented)

*** Generic File Access Rights for NT ACLs
#define  FILERIGHTS_READ         1179785
#define 	FILERIGHTS_READEXECUTE	1179817
#define 	FILERIGHTS_CHANGE			1245631
#define	FILERIGHTS_FULL			2032127


**** CUSTOMIZE AND OVERRIDE SETTINGS INDEPENDENTLY
**** OF THE WC INSTALLATION
#IF FILE("WCONNECT_OVERRIDE.H")
	#INCLUDE WCONNECT_OVERRIDE.H
#ENDIF

*!*  WCONNECT_OVERRIDE.H would contain (for example):
*!*			#UNDEFINE DEBUGMODE
*!*         #DEFINE DEBUGMODE .T.

*!*			#UNDEFINE SERVER_IN_DESKTOP
*!*         #DEFINE SERVER_IN_DESKTOP .T.

