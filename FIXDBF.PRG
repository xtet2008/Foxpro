&&2002.03.22  ���ӽ����ļ�����Ϊ*.BAD,�޸����FIXEDDBF.DBF����
&&            ����Ϊԭ�ļ�,���������ļ��ؽ�����
&&1999.09.30  �����޸Ļ������
SET TALK OFF
SET DELE OFF
SET SAFETY OFF

DO WHILE .T.
	CLOSE ALL
	SET COLOR TO
	CLEAR
DEFINE WINDOW wtmp FROM 6,15 TO 14,50  SHADOW ;
	TITLE ' ���ݿ�ṹ���޸� ' COLOR SCHEME 5
MOVE WINDOW wtmp CENTER
ACTIVATE WINDOW wtmp
STORE SPACE(50) TO badname &&,bakname
@1,2 SAY'�������𻵵����ݿ�ȫ��(��.DBF)'
@3,2 GET badname VALID chkname() SIZE 1,20 ;
	PICT'@Sk!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
@3,24 GET tbrow PICT'@*n ���' DEFA 1 VALID getname()
@5,7 GET ask PICT'@*hn \\ȷ��;\?ȡ��' DEFAULT 1 SIZE 1,4,4  VALID clearead()
READ CYCLE
IF ask=2 OR LASTKEY()=27
	RELEASE WINDOW wtmp
        CLOSE ALL
	RETURN
ENDIF
DO fixing
RELEASE WINDOW wtmp
CLOSE ALL
ON ERROR
ENDDO
CLOSE ALL
RETURN



	PROCEDURE fixing
	WAIT WINDOW NOWAIT'�����޸�,���Ժ�...'
	badname=LEFT(badname,LEN(badname)-4)

	PUBLIC err_code,has_err
	STORE 0 TO err_code,has_err
	ON ERROR DO get_no WITH ERROR()
	CLOSE ALL
	USE &badname.  &&��ȡ�򿪿��Ƿ��д����
	USE
	ON ERROR

	IF has_err=0
		WAIT WINDOW NOWAIT 'δ���� �ļ��� ����!'
        CLOSE ALL
		RETURN
	ENDIF

	IF err_code=41 &&invalid memory file
		IF NOT FILE('&badname..fpt')
			WAIT WINDOW NOWAIT '��ע�ļ�������,�޷��޸�!!!'
        CLOSE ALL
			RETURN
		ENDIF
&&   do fix_memo

		mfile=FOPEN('&badname..fpt',2)
		IF mfile<0
			WAIT WINDOW NOWAIT '����! �޷��򿪱�ע�ļ�!!!'
		ENDIF
		=FSEEK(mfile,7,0)
		=FWRITE(mfile,CHR(64))
		=FCLOSE(mfile)
		WAIT WINDOW NOWAIT'�޸����!! �볢�Դ� &badname..DBF'
        CLOSE ALL
		RETURN
	ENDIF

	CLOSE ALL
	WAIT WINDOW NOWAIT'���ļ�����Ϊ: &BADNAME..BAD!'
	COPY FILE &badname..DBF TO &badname..badname
	sfile=FOPEN('&badname..dbf')
	IF sfile<0
		WAIT WINDOW NOWAIT '����! ���ܴ� &badname..DBF �ļ�!!!'
        CLOSE ALL
		RETU
	ENDIF

	ERASE fixeddbf.DBF
	tfile=FCREATE('fixeddbf.dbf',0)
	IF tfile<0
		WAIT WINDOW NOWAIT '����! ���ܴ���Ŀ���ļ�!!!'
        CLOSE ALL
		RETU
	ENDIF
	=FSEEK(sfile,0)
	b0=FREAD(sfile,1)  &&ȡMEMO ��־
	=FSEEK(sfile,8,0)
	b8=ASC(FREAD(sfile,1))
	b9=ASC(FREAD(sfile,1))
	badname=ASC(FREAD(sfile,1))
	bb=ASC(FREAD(sfile,1))

	RECSIZE=bb*16*16+badname  &&
	HEAD=b9*16*16+b8

	=FSEEK(sfile,0)
	readhead=FREAD(sfile,HEAD)
	=FSEEK(tfile,0)
	=FWRITE(tfile,readhead)  &&д�ļ�ͷ�ṹ

&&��д MEMO ��־ , ��¼��
	=FSEEK(tfile,0)
	=FWRITE(tfile,CHR(3))
	=FSEEK(tfile,4,0)
	=FWRITE(tfile,CHR(0))
	=FWRITE(tfile,CHR(0))
	=FWRITE(tfile,CHR(0))
	=FWRITE(tfile,CHR(0))
	=FCLOSE(tfile)

	goodtxt=SYS(3)+'.txt'
	delerecn=SYS(3) +'.dbf'
	CREATE TABLE &delerecn. (RECNO N(8))
	USE
	USE &delerecn. ALIAS delerecn
	txtfile=FCREATE('&goodtxt.')
	IF txtfile<0
		WAIT WINDOW NOWAIT '����! ���ܴ����޸��ı��ļ�!!!'
        CLOSE ALL
		RETU
	ENDIF
	=FSEEK(sfile,0)
	=FSEEK(sfile,HEAD,1)
	rec=1
	DO WHILE NOT FEOF(sfile)
		gstr1=FGETS(sfile,1)
		DO WHILE EMPTY(gstr1) AND NOT FEOF(sfile)
			gstr1=FGETS(sfile,1)
		ENDDO
		IF gstr1='*'
			gstr2=FGETS(sfile,RECSIZE-1)
			SELECT delerecn
			APPEND BLANK
			REPLACE RECNO WITH rec
		ELSE
			gstr2=gstr1+FGETS(sfile,RECSIZE-2)
			IF EMPTY(gstr2)
				EXIT
			ENDIF
		ENDIF
		WAIT WINDOW NOWAIT'�����޸�, �� '+ALLT(STR(rec,10))+' ����¼...'
		=FPUTS(txtfile,gstr2)
		rec=rec+1
	ENDDO

	=FCLOSE(sfile)
	=FCLOSE(txtfile)

	WAIT WINDOW NOWAIT '���ڻָ�����...'
	USE fixeddbf IN 0
	
	SELECT fixeddbf
	APPEND FROM &goodtxt. TYPE SDF
   COPY TO D:\111
	SELECT delerecn
	SCAN
		WAIT WINDOW NOWAIT '����У������:'+STR(RECN()/RECCOUNT()*100,6,0)+'�� '
		rec=RECNO
		SELECT fixeddbf
		GO rec
		DELETE
		SELECT delerecn
	ENDSCAN

	CLOSE ALL
	sfile=FOPEN('fixeddbf.dbf',2)
	 
	IF sfile<0
		WAIT WINDOW NOWAIT '����! ���ܴ� FIXEDDBF.DBF �ļ�!!!'
        CLOSE ALL
		RETURN
	ENDIF

	=FSEEK(sfile,0)  &&д�� MEMO ��־
	=FWRITE(sfile,b0)
	=FCLOSE(sfile)

	ERASE &delerecn.
	ERASE &goodtxt.
&&   WAIT WINDOW nowait'�޸����!! �޸����Ϊ: FIXEDDBF.DBF'

&&&���޸���Ŀ��ļ������𻵵��ļ�,����ǰ�������ļ��ؽ�����
	COPY FILE fixeddbf.DBF TO &badname..DBF

	IF FILE('&BADNAME..IDX') OR FILE('&BADNAME..CDX')
		USE &badname. EXCLUSIVE IN 0 ALIAS tmp
		SELECT tmp
		REINDEX
	ENDIF
	CLOSE ALL
	
	*ERASE fixeddbf.DBF
	WAIT WINDOW NOWAIT'�޸����!!'

	RETU


	FUNCTION clearead
	CLEA READ
	RETURN

	PROCEDURE get_no
	PARAMETERS err_no
	err_code=err_no
	has_err=1
&& wait window 'get_no='+str(err_code,4)
	RETURN

	FUNCTION chkname
&& bakname=iif('.'$allt(bakname),allt(bakname),allt(bakname)+'.dbf')
	badname=ALLT(badname)
	IF  FILE('&badname.') AND UPPER(RIGHT(badname,4))='.DBF'
		SHOW OBJECT OBJNUM(ask) PROMPT'ȷ��' ENABLE
	ELSE
		STORE SPACE(50) TO badname
		SHOW OBJECT OBJNUM(ask) PROMPT'\\ȷ��' DISABLE
		WAIT WINDOW NOWAIT'�ļ������ļ����ʹ�!'
	ENDIF
	SHOW GETS
	RETURN


	FUNCTION getname
	badname=ALLT(GETFILE('dbf','�����ݿ��ļ���','ȷ��',0))
	IF EMPTY(ALLT(badname))  OR NOT UPPER(RIGHT(badname,4))=='.DBF'
		WAIT WINDOW NOWAIT'�ļ������ļ����ʹ�!'
		SHOW OBJECT OBJNUM(ask) PROMPT'\\ȷ��' DISABLE
	ELSE
		SHOW OBJECT OBJNUM(ask) PROMPT'ȷ��' ENABLE
	ENDIF

	SHOW GETS
	RETURN
