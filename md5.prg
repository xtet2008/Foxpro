* --------------------------------------------------------------
* Md5算法在VFP中的实现
* 调用方法: MD5(要加密的字符串,32),或 MD5(要加密的字符串,16)
* 第二个参数:16或32,默认为32,16:中间16位结果,32:常序32位结果
* mayleelife 2005-09-25
* 注：Md5是可以破解的(http://md5.mmkey.com/index.asp)
* --------------------------------------------------------------

*--示例：
Clear
?md5("123456")
?md5("sunlin")
?MD5("Test",16) &&中间16位结果：f5540bd0809a388d
?MD5("Test",32) &&常序32位结果：0cbc6611f5540bd0809a388dc95a615b
?MD5("Test")    &&常序32位结果：0cbc6611f5540bd0809a388dc95a615b


Function MD5(sMessage,lRetuLength)
    If Parameters()<1
        Return
    Endif
    If Parameters()=1
        m.lRetuLength=32
    Endif
    If Parameters()>1 And Vartype(m.lRetuLength)#'N'
        m.lRetuLength=32
    Endif


    BITS_TO_A_BYTE=8
    BYTES_TO_A_WORD=4
    BITS_TO_A_WORD=32
    Dime m_lOnBits(31)
    Dime m_l2Power(31)
    m_lOnBits(1)=1
    m_lOnBits(2)=3
    m_lOnBits(3)=7
    m_lOnBits(4)=15
    m_lOnBits(5)=31
    m_lOnBits(6)=63
    m_lOnBits(7)=127
    m_lOnBits(8)=255
    m_lOnBits(9)=511
    m_lOnBits(10)=1023
    m_lOnBits(11)=2047
    m_lOnBits(12)=4095
    m_lOnBits(13)=8191
    m_lOnBits(14)=16383
    m_lOnBits(15)=32767
    m_lOnBits(16)=65535
    m_lOnBits(17)=131071
    m_lOnBits(18)=262143
    m_lOnBits(19)=524287
    m_lOnBits(20)=1048575
    m_lOnBits(21)=2097151
    m_lOnBits(22)=4194303
    m_lOnBits(23)=8388607
    m_lOnBits(24)=16777215
    m_lOnBits(25)=33554431
    m_lOnBits(26)=67108863
    m_lOnBits(27)=134217727
    m_lOnBits(28)=268435455
    m_lOnBits(29)=536870911
    m_lOnBits(30)=1073741823
    m_lOnBits(31)=2147483647


    m_l2Power(1)=1
    m_l2Power(2)=2
    m_l2Power(3)=4
    m_l2Power(4)=8
    m_l2Power(5)=16
    m_l2Power(6)=32
    m_l2Power(7)=64
    m_l2Power(8)=128
    m_l2Power(9)=256
    m_l2Power(10)=512
    m_l2Power(11)=1024
    m_l2Power(12)=2048
    m_l2Power(13)=4096
    m_l2Power(14)=8192
    m_l2Power(15)=16384
    m_l2Power(16)=32768
    m_l2Power(17)=65536
    m_l2Power(18)=131072
    m_l2Power(19)=262144
    m_l2Power(20)=524288
    m_l2Power(21)=1048576
    m_l2Power(22)=2097152
    m_l2Power(23)=4194304
    m_l2Power(24)=8388608
    m_l2Power(25)=16777216
    m_l2Power(26)=33554432
    m_l2Power(27)=67108864
    m_l2Power(28)=134217728
    m_l2Power(29)=268435456
    m_l2Power(30)=536870912
    m_l2Power(31)=1073741824


    S11=7
    S12=12
    S13=17
    S14=22
    S21=5
    S22=9
    S23=14
    S24=20
    S31=4
    S32=11
    S33=16
    S34=23
    S41=6
    S42=10
    S43=15
    S44=21
 

    *********Function ConvertToWordArray(sMessage)
    MODULUS_BITS=512
    CONGRUENT_BITS=448


    lMessageLength=Len(sMessage)
    lNumberOfWords=(Int((lMessageLength+Int((MODULUS_BITS-CONGRUENT_BITS)/BITS_TO_A_BYTE))/Int(MODULUS_BITS/BITS_TO_A_BYTE))+1)*Int(MODULUS_BITS/BITS_TO_A_WORD)


    Dime lWordArray(lNumberOfWords)
    Store 0 To lWordArray


    lBytePosition=0
    lByteCount=0
    Do While lByteCount<lMessageLength
        lWordCount=Int(lByteCount/BYTES_TO_A_WORD)
        lBytePosition=Mod(lByteCount,BYTES_TO_A_WORD)*BITS_TO_A_BYTE
        lWordArray(lWordCount+1)=Bitor(lWordArray(lWordCount+1),LShift(Asc(Substr(sMessage,lByteCount+1,1)),lBytePosition))
        lByteCount=lByteCount+1
    Enddo
 

    lWordCount=Int(lByteCount/BYTES_TO_A_WORD)
    lBytePosition=Mod(lByteCount,BYTES_TO_A_WORD)*BITS_TO_A_BYTE
    lWordArray(lWordCount+1)=Bitor(lWordArray(lWordCount+1),LShift(0x80,lBytePosition))
    lWordArray(lNumberOfWords-1)=LShift(lMessageLength,3)
    lWordArray(lNumberOfWords)=RShift(lMessageLength,29)
    ***************************
    a=0x67452301
    b=0xEFCDAB89
    c=0x98BADCFE
    d=0x10325476


    Dime x(lNumberOfWords)
    For k=1 To lNumberOfWords
        x(k)=lWordArray(k)
    Endfor
 

    *****设置错误处理程序，因Visual FoxPro程序本身所限，对大数的处理能力不够
    On Error Do err_treat
    For k=1 To lNumberOfWords Step 16
        AA=a
        BB=b
        CC=c
        DD=d


        Do md5_FF With a,b,c,d,x(k+0),S11,0xD76AA478
        Do md5_FF With d,a,b,c,x(k+1),S12,0xE8C7B756
        Do md5_FF With c,d,a,b,x(k+2),S13,0x242070DB
        Do md5_FF With b,c,d,a,x(k+3),S14,0xC1BDCEEE
        Do md5_FF With a,b,c,d,x(k+4),S11,0xF57C0FAF
        Do md5_FF With d,a,b,c,x(k+5),S12,0x4787C62A
        Do md5_FF With c,d,a,b,x(k+6),S13,0xA8304613
        Do md5_FF With b,c,d,a,x(k+7),S14,0xFD469501
        Do md5_FF With a,b,c,d,x(k+8),S11,0x698098D8
        Do md5_FF With d,a,b,c,x(k+9),S12,0x8B44F7AF
        Do md5_FF With c,d,a,b,x(k+10),S13,0xFFFF5BB1
        Do md5_FF With b,c,d,a,x(k+11),S14,0x895CD7BE
        Do md5_FF With a,b,c,d,x(k+12),S11,0x6B901122
        Do md5_FF With d,a,b,c,x(k+13),S12,0xFD987193
        Do md5_FF With c,d,a,b,x(k+14),S13,0xA679438E
        Do md5_FF With b,c,d,a,x(k+15),S14,0x49B40821


        Do md5_GG With a,b,c,d,x(k+1),S21,0xF61E2562
        Do md5_GG With d,a,b,c,x(k+6),S22,0xC040B340
        Do md5_GG With c,d,a,b,x(k+11),S23,0x265E5A51
        Do md5_GG With b,c,d,a,x(k+0),S24,0xE9B6C7AA
        Do md5_GG With a,b,c,d,x(k+5),S21,0xD62F105D
        Do md5_GG With d,a,b,c,x(k+10),S22,0x2441453
        Do md5_GG With c,d,a,b,x(k+15),S23,0xD8A1E681
        Do md5_GG With b,c,d,a,x(k+4),S24,0xE7D3FBC8
        Do md5_GG With a,b,c,d,x(k+9),S21,0x21E1CDE6
        Do md5_GG With d,a,b,c,x(k+14),S22,0xC33707D6
        Do md5_GG With c,d,a,b,x(k+3),S23,0xF4D50D87
        Do md5_GG With b,c,d,a,x(k+8),S24,0x455A14ED
        Do md5_GG With a,b,c,d,x(k+13),S21,0xA9E3E905
        Do md5_GG With d,a,b,c,x(k+2),S22,0xFCEFA3F8
        Do md5_GG With c,d,a,b,x(k+7),S23,0x676F02D9
        Do md5_GG With b,c,d,a,x(k+12),S24,0x8D2A4C8A


        Do md5_HH With a,b,c,d,x(k+5),S31,0xFFFA3942
        Do md5_HH With d,a,b,c,x(k+8),S32,0x8771F681
        Do md5_HH With c,d,a,b,x(k+11),S33,0x6D9D6122
        Do md5_HH With b,c,d,a,x(k+14),S34,0xFDE5380C
        Do md5_HH With a,b,c,d,x(k+1),S31,0xA4BEEA44
        Do md5_HH With d,a,b,c,x(k+4),S32,0x4BDECFA9
        Do md5_HH With c,d,a,b,x(k+7),S33,0xF6BB4B60
        Do md5_HH With b,c,d,a,x(k+10),S34,0xBEBFBC70
        Do md5_HH With a,b,c,d,x(k+13),S31,0x289B7EC6
        Do md5_HH With d,a,b,c,x(k+0),S32,0xEAA127FA
        Do md5_HH With c,d,a,b,x(k+3),S33,0xD4EF3085
        Do md5_HH With b,c,d,a,x(k+6),S34,0x4881D05
        Do md5_HH With a,b,c,d,x(k+9),S31,0xD9D4D039
        Do md5_HH With d,a,b,c,x(k+12),S32,0xE6DB99E5
        Do md5_HH With c,d,a,b,x(k+15),S33,0x1FA27CF8
        Do md5_HH With b,c,d,a,x(k+2),S34,0xC4AC5665


        Do md5_II With a,b,c,d,x(k+0),S41,0xF4292244
        Do md5_II With d,a,b,c,x(k+7),S42,0x432AFF97
        Do md5_II With c,d,a,b,x(k+14),S43,0xAB9423A7
        Do md5_II With b,c,d,a,x(k+5),S44,0xFC93A039
        Do md5_II With a,b,c,d,x(k+12),S41,0x655B59C3
        Do md5_II With d,a,b,c,x(k+3),S42,0x8F0CCC92
        Do md5_II With c,d,a,b,x(k+10),S43,0xFFEFF47D
        Do md5_II With b,c,d,a,x(k+1),S44,0x85845DD1
        Do md5_II With a,b,c,d,x(k+8),S41,0x6FA87E4F
        Do md5_II With d,a,b,c,x(k+15),S42,0xFE2CE6E0
        Do md5_II With c,d,a,b,x(k+6),S43,0xA3014314
        Do md5_II With b,c,d,a,x(k+13),S44,0x4E0811A1
        Do md5_II With a,b,c,d,x(k+4),S41,0xF7537E82
        Do md5_II With d,a,b,c,x(k+11),S42,0xBD3AF235
        Do md5_II With c,d,a,b,x(k+2),S43,0x2AD7D2BB
        Do md5_II With b,c,d,a,x(k+9),S44,0xEB86D391
 

        a=AddUnsigned(a,AA)
        b=AddUnsigned(b,BB)
        c=AddUnsigned(c,CC)
        d=AddUnsigned(d,DD)
    Endfor
 

    On Error &&恢复默认的错误处理
    If m.lRetuLength=32
        Return Lower(WordToHex(a)+WordToHex(b)+WordToHex(c)+WordToHex(d)) &&输出32位代码
    Else
        Return Lower(WordToHex(b)+WordToHex(c)) &&输出16位代码
    Endif
Endfunc
 

Procedure err_treat
    Return &&在此设置错误处理程序
Endproc
*----------------------------------------------------------
Function LShift(lvalue,iShiftBits)
    If iShiftBits=0
        Return lvalue
    Else
        If iShiftBits=31
            If Bitand(lvalue,1)<>0
                Return 0x80000000
            Else
                Return 0
            Endif
        Endif
    Endif
    If Bitand(lValue,m_l2Power(32-iShiftBits))<>0
        Return Bitor((Bitand(lValue,m_lOnBits(32-(iShiftBits+1)))*m_l2Power(iShiftBits+1)),0x80000000)
    Else
        Return Bitand(lvalue,m_lOnBits(32-iShiftBits))*m_l2Power(iShiftBits+1)
    Endif
Endfunc
 

Function RShift(lvalue,iShiftBits)
    If iShiftBits=0
        Return lvalue
    Else
        If iShiftBits=31
            If Bitand(lvalue,0x80000000)
                Return 1
            Else
                Return 0
            Endif
        Endif
    Endif
    RShift2=Int(Bitand(lvalue,0x7FFFFFFE)/m_l2Power(iShiftBits+1))
    If Bitand(lvalue,0x80000000)<>0
        RShift2=Bitor (RShift2,Int(0x40000000/m_l2Power(iShiftBits)))
    Endif
    Return RShift2
Endfunc


Function RotateLeft(lvalue,iShiftBits)
    Return Bitor(LShift(lvalue,iShiftBits),RShift(lvalue,(32-iShiftBits)))
Endfunc


Function AddUnsigned(lX,lY)
    lX8=Bitand(lX,0x80000000)
    lY8=Bitand(lY,0x80000000)
    lX4=Bitand(lX,0x40000000)
    lY4=Bitand(lY,0x40000000)
    lResult=Bitand(lX,0x3FFFFFFF)+Bitand(lY,0x3FFFFFFF)
    If Bitand(lX4,lY4)<> 0
        lResult=Bitxor(Bitxor(Bitxor(lResult,0x80000000),lX8),lY8)
    Else
        If Bitor(lX4,lY4)<> 0
            If Bitand(lResult,0x40000000)<> 0
                lResult=Bitxor(Bitxor(Bitxor(lResult,0xC0000000),lX8),lY8)
            Else
                lResult=Bitxor(Bitxor(Bitxor(lResult,0x40000000),lX8),lY8)
            Endif
        Else
            lResult=Bitxor(Bitxor(lResult,lX8),lY8)
        Endif
    Endif
    Return lResult
Endfunc


Function md5_F(x,Y,z)
    Return Bitor(Bitand(x,Y),Bitand(Bitnot(x),z))
Endfunc
 

Function md5_G(x,Y,z)
    Return Bitor(Bitand(x,z),Bitand(Y,Bitnot(z)))
Endfunc
 

Function md5_H(x,Y,z)
    Return Bitxor(Bitxor(x,Y),z)
Endfunc
 

Function md5_I(x,Y,z)
    Return Bitxor(Y,Bitor(x,Bitnot(z)))
Endfunc


Procedure md5_FF(a,b,c,d,x,s,ac)
    a=AddUnsigned(a,AddUnsigned(AddUnsigned(md5_F(b,c,d),x),ac))
    a=RotateLeft(a,s)
    a=AddUnsigned(a,b)
Endproc


Procedure md5_GG(a,b,c,d,x,s,ac)
    a=AddUnsigned(a,AddUnsigned(AddUnsigned(md5_G(b,c,d),x),ac))
    a=RotateLeft(a,s)
    a=AddUnsigned(a,b)
Endproc


Procedure md5_HH(a,b,c,d,x,s,ac)
    a=AddUnsigned(a,AddUnsigned(AddUnsigned(md5_H(b,c,d),x),ac))
    a=RotateLeft(a,s)
    a=AddUnsigned(a,b)
Endproc


Procedure md5_II(a,b,c,d,x,s,ac)
    a=AddUnsigned(a,AddUnsigned(AddUnsigned(md5_I(b,c,d),x),ac))
    a=RotateLeft(a,s)
    a=AddUnsigned(a,b)
Endproc


Function Hex(lByte)
    x=''
    Do While lByte>0
        If lByte>=16
            Y=lByte%16
        Else
            Y=lByte
        Endif
        If Y<10 And Y>=0
            x=Str(Y,1)+x
        Else
            x=Chr(65+Y-10)+x
        Endif
        lByte=(lByte-Y)/16
    Enddo
    Return x
Endfunc


Function WordToHex(lvalue)
    lResult=''
    For lCount=0 To 3
        lByte=Bitand(RShift(lvalue,lCount*BITS_TO_A_BYTE),m_lOnBits(BITS_TO_A_BYTE))
        lResult=lResult+Right("00"+Hex(lByte),2)
    Endfor
    Return lResult
Endfunc