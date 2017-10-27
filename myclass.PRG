*This entirely self-contained program will build a COM server 
* called "myserver.myclass"
* It will unregister a prior instance, if any
IF PROGRAM() != "MYCLASS"
   ?"this file MUST BE NAMED 'myclass.prg'"
   return
ENDIF
IF FILE("myclass.dll")
   DECLARE integer DllUnregisterServer IN myclass.dll
   DllUnregisterServer()
   CLEAR DLLS
ENDIF
BUILD PROJECT myserver FROM myclass
BUILD DLL myserver from myserver recomp
*now test this COM server:
ox = CreateObject("myserver.myclass")    && create the server object
ox.mydocmd("USE home(1)+'samples\data\customer'")    && use a table
?ox.myeval("RECCOUNT()")    && get the record count

DEFINE CLASS myclass AS session OLEPUBLIC
   PROCEDURE MyDoCmd(cCmd as String) as Variant ;
         helpstring "Execute a VFP cmd"
      &cCmd    && just execute parm as if it were a fox command
   FUNCTION MyEval(cExpr as String) ;
         helpstring "Evaluate a VFP expression"
      RETURN &cExpr    && evaluate parm as if it were a fox expr
   FUNCTION Error(nError, cMethod, nLine)
      COMreturnerror(cMethod+'  err#='+str(nError,5)+;
         '  line='+str(nline,6)+' '+message(),_VFP.ServerName)
      && this line is never executed
*!*	   Function ShowMessage(cMsg as String )
*!*	   	MessageBox(ShowMessage)
ENDDEFINE