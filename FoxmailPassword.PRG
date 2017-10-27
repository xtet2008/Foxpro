ms="~draGon~"&&这是foxmail的加密密匙，因为foxmail是阿龙的作品，所以他就用了这个密匙，真没创意!
*!*	mw='8D6EC28ADC54E679D7'
mw='0EB84CC150FE1D'
dime A(8),B(len(mw)/2),C(len(mw)/2),D(len(mw)/2),E(len(mw)/2)

for i=1 to 8
	a(i)=asc(substr(ms,i,1))
endf
for i=1 to len(mw)/2
	x='0X'+substr(mw,2*i-1,2)
	B(i)=&x
	C(i)=&x
endf
C(1)=bitxor(90,B(1))
for i=1 to len(mw)/2-1
	if i<9
		k=i
	else
		k=i-8
	endi
	D(i)=bitxor(A(k),B(i+1))
endf
for i=1 to len(mw)/2-1
	if D(i)-C(i)>0
		E(i)=D(i)-C(i)
	else
		E(i)=255+D(i)-C(i)
	endi
endf
mm=''
for i=1 to len(mw)/2-1
	mm=mm+chr(E(i))
endf
?mm &&　密文8D6EC28ADC54E679D7破解出来后是88636500
