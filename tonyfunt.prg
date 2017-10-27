*===============================================================*
procedure  error_process         &&...PROCESS ERROR
*===============================================================*
parameter lhandler,lmessage,lposition,lline,lprocode
do case
case lhandler = 109 or lhandler = 108
	if cursorgetprop('BUFFERING') > 1
		=tablerevert()
	endif
	=messagebox('�����û�����ʹ�ø�����!'+chr(13)+chr(13)+'���β���������!',48,'ϵͳ��Ϣ')
case lhandler = 1884
	if cursorgetprop('BUFFERING') > 1
		=tablerevert()
	endif
	=messagebox('�����ڸùؼ��������!'+chr(13)+chr(13)+'���β���������!',48,'ϵͳ��Ϣ')
case lhandler = 1585
	if cursorgetprop('BUFFERING') > 1
		=tablerevert()
	endif
	=messagebox('�����û����޸��˸�����!'+chr(13)+chr(13)+'����պ������޸�!',48,'ϵͳ��Ϣ')

case lhandler = 1582 or lhandler = 1502 or lhandler = 1539
	if cursorgetprop('BUFFERING') > 1
		=tablerevert()
	endif
case lhandler = 1104
	if cursorgetprop('BUFFERING') > 1
		=tablerevert()
	endif
	=messagebox('�Ӵ��̻������ȡ����ʧ��!',16,'ϵͳ��Ϣ')
	do exit_system
case lhandler = 2005 or lhandler = 1705
	=messagebox('�����2005/1705: '+ltrim(str(lhandler,5))+chr(13)+'ԭ��: '+lmessage+chr(13);
		+'Դ���룺'+lprocode+chr(13)+chr(13)+'����: '+lposition+'(��'+ltrim(str(lline,4));
		+'��)'+chr(13)+'erritm:',48,'ϵͳ��Ϣ')  &&+ _erritm

other
	=messagebox('�����: '+ltrim(str(lhandler,5))+chr(13)+'ԭ��: '+lmessage+chr(13);
		+'Դ���룺'+lprocode+chr(13)+chr(13)+'����: '+lposition+'(��'+ltrim(str(lline,4));
		+'��)'+chr(13)+'erritm:',48,'ϵͳ��Ϣ')  &&+ _erritm
endcase
_iserror = .t.
return


*================================================================*
function  cn_amt		&&... ����תΪ���Ĵ�д
*================================================================*
parameter lnum
local lbignum,ldw,inilen,i,j,k
dimension lbignum[12],ldw[11]
lbignum[1] = 'Ҽ'
lbignum[2] = '��'
lbignum[3] = '��'
lbignum[4] = '��'
lbignum[5] = '��'
lbignum[6] = '½'
lbignum[7] = '��'
lbignum[8] = '��'
lbignum[9] = '��'
lbignum[10] = 'ʰ'
lbignum[11] = '��'
ldw [1] = 'ʰ'
ldw [2] = '��'
ldw [3] = 'Ǫ'
ldw [4] = '��'
ldw [5] = 'ʰ'
ldw [6] = '��'
ldw [7] = 'Ǫ'
ldw [8] = '��'
ldw [9] = 'ʰ'
ldw [10] = '��'
ldw [11] = 'Ǫ'

if lnum = 0
	return
endif

lnum = round(lnum,2)
loutstr=''
intlen = atc('.',allt(str(lnum,20,2)))-1
for i = 1 to intlen  &&С����ǰ��ת��
	k = substr(allt(str(lnum,20,2)),i,1)
	if k = '0'
		j = 11
	else
		j =val(k)
	endif
	if i = intlen
		if k = '0'
			if right(loutstr,2) = '��'
				loutstr = substr(loutstr,1,len(loutstr)-2)
			endif
			if int(lnum) = lnum
				loutstr = loutstr + 'Ԫ��'
			endif
		else
			if int(lnum) = lnum
				loutstr = loutstr +lbignum[J]+ 'Ԫ��'
			else
				loutstr = loutstr +lbignum[J]
			endif
		endif
	else
		if k # '0'
			loutstr = loutstr + lbignum[J]+ldw[INTLEN-I]
		else
			if right(loutstr,2) # '��'
				loutstr = loutstr + '��'
			endif
			if intlen - i = 8
				loutstr = substr(loutstr,1,len(loutstr)-2)+'��'
			endif
			if intlen - i = 4
				if right(loutstr,4) # '����'
					loutstr = substr(loutstr,1,len(loutstr)-2)+'��'
				endif
			endif
		endif
	endif
endfor

if int(lnum) # lnum  &&С������ת��
	loutstr = loutstr + 'Ԫ'
	for i =  1 to 2
		k = substr(allt(str(lnum,20,4)),intlen+1+i,1)
		if k ='0'
			j=11
		else
			j =val(k)
		endif
		if i = 1
			if k # '0'
				loutstr = loutstr + lbignum[J]	+'��'
			else
				loutstr = loutstr + lbignum[J]
			endif
		else
			if k # '0'
				loutstr = loutstr + lbignum[J]	+'��'
			endif
		endif
	endfor
endif

if left(loutstr,2) = 'Ԫ'
	loutstr = substr(loutstr,3)
endif
return	loutstr

*================================================================*
function  tonydate		&&... 
*================================================================*
parameter ldate
if def_lang = 'CHS'
   ldate = dtos(ldate)
   retu  left(ldate,4)+'��'+subs(ldate,5,2) + '��' + right(ldate,2) + '��'
else
   retu dmy(ldate)
endif   

*================================================================*
function  tonysele_cn_en		&&.��Ӣ����ѡ��
*================================================================*
parameter Ldbf,cn_name,en_name
local Lworkarea,lretuvalue
Lworkarea = select()
sele (ldbf)
if def_lang = 'CHS'
   lretuvalue = iif(empty(&cn_name.),alltrim(&en_name.),alltrim(&cn_name.))
else 
   lretuvalue = iif(empty(&en_name.),alltrim(&cn_name.),alltrim(&en_name.))
endif 
sele (Lworkarea)
retu lretuvalue

Public showmark_c
showmark_c = 0
Function ShowMark_Once
	&& Use this function to control princt marks in Detail zero one time.
	If Showmark_c = 0
		Showmark_c = Showmark_c + 1
		Return 0
	Else
		Return 1
	Endif
EndFunc