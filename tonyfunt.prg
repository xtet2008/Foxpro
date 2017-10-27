*===============================================================*
procedure  error_process         &&...PROCESS ERROR
*===============================================================*
parameter lhandler,lmessage,lposition,lline,lprocode
do case
case lhandler = 109 or lhandler = 108
	if cursorgetprop('BUFFERING') > 1
		=tablerevert()
	endif
	=messagebox('其他用户正在使用该资料!'+chr(13)+chr(13)+'本次操作被撤消!',48,'系统信息')
case lhandler = 1884
	if cursorgetprop('BUFFERING') > 1
		=tablerevert()
	endif
	=messagebox('己存在该关键码的资料!'+chr(13)+chr(13)+'本次操作被撤消!',48,'系统信息')
case lhandler = 1585
	if cursorgetprop('BUFFERING') > 1
		=tablerevert()
	endif
	=messagebox('其它用户刚修改了该资料!'+chr(13)+chr(13)+'请参照后再作修改!',48,'系统信息')

case lhandler = 1582 or lhandler = 1502 or lhandler = 1539
	if cursorgetprop('BUFFERING') > 1
		=tablerevert()
	endif
case lhandler = 1104
	if cursorgetprop('BUFFERING') > 1
		=tablerevert()
	endif
	=messagebox('从磁盘或网络读取资料失败!',16,'系统信息')
	do exit_system
case lhandler = 2005 or lhandler = 1705
	=messagebox('错误号2005/1705: '+ltrim(str(lhandler,5))+chr(13)+'原因: '+lmessage+chr(13);
		+'源代码：'+lprocode+chr(13)+chr(13)+'出错处: '+lposition+'(第'+ltrim(str(lline,4));
		+'行)'+chr(13)+'erritm:',48,'系统信息')  &&+ _erritm

other
	=messagebox('错误号: '+ltrim(str(lhandler,5))+chr(13)+'原因: '+lmessage+chr(13);
		+'源代码：'+lprocode+chr(13)+chr(13)+'出错处: '+lposition+'(第'+ltrim(str(lline,4));
		+'行)'+chr(13)+'erritm:',48,'系统信息')  &&+ _erritm
endcase
_iserror = .t.
return


*================================================================*
function  cn_amt		&&... 数字转为中文大写
*================================================================*
parameter lnum
local lbignum,ldw,inilen,i,j,k
dimension lbignum[12],ldw[11]
lbignum[1] = '壹'
lbignum[2] = '贰'
lbignum[3] = '叁'
lbignum[4] = '肆'
lbignum[5] = '伍'
lbignum[6] = '陆'
lbignum[7] = '柒'
lbignum[8] = '捌'
lbignum[9] = '玖'
lbignum[10] = '拾'
lbignum[11] = '零'
ldw [1] = '拾'
ldw [2] = '佰'
ldw [3] = '仟'
ldw [4] = '万'
ldw [5] = '拾'
ldw [6] = '佰'
ldw [7] = '仟'
ldw [8] = '亿'
ldw [9] = '拾'
ldw [10] = '佰'
ldw [11] = '仟'

if lnum = 0
	return
endif

lnum = round(lnum,2)
loutstr=''
intlen = atc('.',allt(str(lnum,20,2)))-1
for i = 1 to intlen  &&小数点前的转换
	k = substr(allt(str(lnum,20,2)),i,1)
	if k = '0'
		j = 11
	else
		j =val(k)
	endif
	if i = intlen
		if k = '0'
			if right(loutstr,2) = '零'
				loutstr = substr(loutstr,1,len(loutstr)-2)
			endif
			if int(lnum) = lnum
				loutstr = loutstr + '元整'
			endif
		else
			if int(lnum) = lnum
				loutstr = loutstr +lbignum[J]+ '元整'
			else
				loutstr = loutstr +lbignum[J]
			endif
		endif
	else
		if k # '0'
			loutstr = loutstr + lbignum[J]+ldw[INTLEN-I]
		else
			if right(loutstr,2) # '零'
				loutstr = loutstr + '零'
			endif
			if intlen - i = 8
				loutstr = substr(loutstr,1,len(loutstr)-2)+'亿'
			endif
			if intlen - i = 4
				if right(loutstr,4) # '亿零'
					loutstr = substr(loutstr,1,len(loutstr)-2)+'万'
				endif
			endif
		endif
	endif
endfor

if int(lnum) # lnum  &&小数点后的转换
	loutstr = loutstr + '元'
	for i =  1 to 2
		k = substr(allt(str(lnum,20,4)),intlen+1+i,1)
		if k ='0'
			j=11
		else
			j =val(k)
		endif
		if i = 1
			if k # '0'
				loutstr = loutstr + lbignum[J]	+'角'
			else
				loutstr = loutstr + lbignum[J]
			endif
		else
			if k # '0'
				loutstr = loutstr + lbignum[J]	+'分'
			endif
		endif
	endfor
endif

if left(loutstr,2) = '元'
	loutstr = substr(loutstr,3)
endif
return	loutstr

*================================================================*
function  tonydate		&&... 
*================================================================*
parameter ldate
if def_lang = 'CHS'
   ldate = dtos(ldate)
   retu  left(ldate,4)+'年'+subs(ldate,5,2) + '月' + right(ldate,2) + '日'
else
   retu dmy(ldate)
endif   

*================================================================*
function  tonysele_cn_en		&&.中英文名选择
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