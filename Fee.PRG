Clear

Set Century on 
Set Date to ymd
Set Mark to '-'

month_fee = 2800  &&　房租
start_date = {^2017-9-9} && 搬进来日期
end_date = {^2018-8-5}
?'房子租期为：',start_date, '至', end_date, '房租支付费用如下'
? Replicate('.',110)

start_1th = {^2017-9-9}
end_1th = {^2017-11-30}
? '第1次',start_1th, '支付房租：'
?? start_1th,'至',end_1th, '，共2个月22天，租金为 2800*2 + 2800/30*22 =',Alltrim(Str( 2800*2 + 2800/30*22,8,2)),'元'
?Chr(9)+Chr(9)+Space(5)+'押金 + 1年宽带：2800+660 =',2800+660,'元'
? Chr(9)+Chr(9)+Space(7),'共支付：7653.33 + 3460 =',Alltrim(Str( 2800*2 + 2800/30*22 + 2800+660,8,2)),'元'


start_2th = end_1th + 1
end_2th = Gomonth(start_2th,3)-1
? '第2次',end_1th , '支付房租：'
?? start_2th, '至',end_2th, '，共3个月，租金为 2800*3 =',Alltrim(Str(2800*3)),'元'


start_3th = end_2th + 1
end_3th = Gomonth(start_3th ,3)-1
? '第3次',end_2th , '支付房租：'
?? start_3th, '至',end_3th, '，共3个月，租金为 2800*3 =',Alltrim(Str(2800*3)),'元'


start_4th = end_3th  + 1
end_4th = {^2018-8-5}
? '第4次',end_3th , '支付房租：'
?? start_4th, '至',end_4th, '，共2个月5天，租金为 2800*2 + 2800/30*5 =',Alltrim(Str(2800*2 + 2800/30*5,8,2)),'元'

