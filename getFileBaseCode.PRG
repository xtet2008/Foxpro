*--文本文件的编码格式手动查看方法：
*--用记事本打开文本后，点击菜单上的“另存为”，编码格式在出现的对话框下方。
*--那用VFP如何取得文本文件的编码格式呢，如下：
lcFileName = GetFile("txt")
*lcFileName='C:/A.txt'    &&文本文件名
lcStr=Filetostr(lcFileName)
lcStrType=Createbinary(Substr(lcStr,1,2))
Do Case
    Case lcStrType=0hEFBB    &&VFP6.0不支持此种方式，此实列是在VFP9.0+SP2下测试的。
        lcCode='UTF-8'
    Case lcStrType=0hFFFE
        lcCode='Unicode'
    Case lcStrType=0hFEFF
        lcCode='Unicode big endian'
    Otherwise
        lcCode='ANSI'
Endcase
?'此文本的编码格式为:',lcCode