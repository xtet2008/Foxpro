*!*	copy stru extended to c:\mytmp\gl.dbf
*!*	USE d:\aa.dbf in 0 excl
*!*	sele aa
*!*	COPY TO c:\mytmp\gl.xls TYPE XL5

public dbfname
dnfname = alias()
copy stru extended to d:\set_path\tools\gl.dbf
sele 0
USE  d:\set_path\tools\gl.dbf  excl
alter table gl alter field_type c(120)
alter table gl alter field_name c(40)
repl all field_name with proper(field_name)
repl all field_type with ltrim(field_type)-'/'-alltrim(str(field_len))-iif(field_dec=0,'','/'-alltrim(str(field_dec)))-iif(!empty(field_defa),'/'-alltrim(field_defa),'')
repl all field_len with 0
append blank 
repl field_name with 'INDEX' ,field_len with 1
sele (dnfname)
N=tagcount()
for M=1to N
   na=tag(M)
   ke=key(M)
   sele gl
   append blank
   repl field_name with proper(Na),field_type with proper(Ke),field_len with 2
   sele (dnfname)
 endfor  
  sele gl
 brow nowait

retu
rwin = createobject('form')
rwin.height = 500
rwin.width = 700
set defa to 
public dbfname
report  form d:\set_path\tools\dbf_stru  NOCONSOLE PREVIEW in rwin
rwin.release
*ENVIRONMENT NOEJECT