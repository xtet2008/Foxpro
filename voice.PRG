************************************************ 
* 拷備至 *.prg 欲離開程式時,點擊[空白的地方] 
************************************************ 

ouserform=CREATEOBJECT ("userform") 
ouserform.SHOW 

DEFINE CLASS userform AS form 
name="Form1" 
caption="Form1" 
left=47 
top=46 
width=100 
height=142 
maxbutton=.F. 
closable=.F. 
showwindow=2 
visible=.T. 

add object 控制線名稱 AS Label with left=12,top=8 , autosize=.T. 
add object shape1 AS shape with left=4,top=24,width=90,height=2 ,specialEffect=0 
add object chkMute AS checkbox with left=7,top=26, autosice=.T. ,caption=[ 靜音], backstyle=0 
add object timer1 AS Timer 


PROCEDURE ACTIVATE 
_screen.windowstate=1 
_screen.visible=.F. 
READ EVENTS 
ENDPROC 

PROCEDURE CLICK &&離開 
= GlobalFree (hmem) 
RELEASE DLL 
CLEAR EVENTS 
_screen.visible=.T. 
_screen.windowstate=2 
ENDPROC 

PROCEDURE ERROR 
LPARAMETERS nError, cMethod, nLine 
messagebox("錯誤碼: "+ltrim(str(nError))+chr(13)+Message()+chr(13)+chr(13)+"請安裝 ActiveX"+chr(13)+" (或)"+chr(13)+"將 PROCEDURE INIT 事件裏的 COMCTL.Slider.1 換成 MSComctlLib.Slider.2 試試",16) 
QUIT 
ENDPROC 

PROCEDURE INIT 
this.addobject ("VSlider" , "Slider" , "COMCTL.Slider.1") && 建立 Slider物件 
this.VSlider.move(30,42,90,90) 
this.VSlider.tickStyle=2 
this.VSlider.orientation=1 

DECLARE INTEGER mixerOpen IN winmm INTEGER @ phmx, INTEGER uMxId, INTEGER dwCallback, INTEGER dwInstance, INTEGER fdwOpen 
DECLARE INTEGER mixerGetLineInfo IN winmm INTEGER hmxobj, STRING @ pmxl, INTEGER fdwInfo 
DECLARE INTEGER mixerGetLineControls IN winmm INTEGER hmxobj, STRING @ pmxlc, INTEGER fdwControls 
DECLARE INTEGER mixerGetControlDetails IN winmm INTEGER hmxobj, STRING @ pmxcd, INTEGER fdwDetails 
DECLARE INTEGER mixerSetControlDetails IN winmm INTEGER hmxobj, STRING @ pmxcd, INTEGER fdwDetails 
DECLARE INTEGER GlobalFree IN kernel32 INTEGER hMem 
DECLARE INTEGER GlobalLock IN kernel32 INTEGER hMem 
DECLARE INTEGER GlobalAlloc IN kernel32 INTEGER wFlags, INTEGER dwBytes 
DECLARE RtlMoveMemory IN kernel32 As CopyMemory STRING @ Destination, INTEGER Source, INTEGER nLength 


public hmixer, hmem, mxcd, muted, 最大音量 

hmixer=0 
= mixerOpen(@hmixer, 0, 0, 0, 0) &&開啟預設裝置 

* -------------------------------------------------------------------- 
componentType = 4 && MIXERLINE_COMPONENTTYPE_DST_SPEAKERS &&主音量的值 
ctrlType = 1342177280 + 196608 + 1 && MIXERCONTROL_CONTROLTYPE_VOLUME 
* -------------------------------------------------------------------- 

mxl = this.num2dword(168) + repl(chr(0),20) + this.num2dword(componentType) + repl(chr(0),140) 
= mixerGetLineInfo (hmixer, @mxl, 3) && MIXER_GETLINEINFOF_COMPONENTTYPE=3 

this.控制線名稱.caption= substr(mxl,57,64) && 本線的長名稱 
Lcontrols = this.buf2dword(substr(mxl,37,4)) && 本線的 Controls數量 

mxc = this.num2dword(152) + repl(chr(0),148) 
mute = mxc 

hMem = GlobalAlloc(64, len(mxc) * Lcontrols) 
_add = GlobalLock(hMem) 

dwLineID = substr(mxl, 13, 4) 
mxlc = this.num2dword(24) + dwLineID + this.num2dword(ctrlType) + this.num2dword(Lcontrols) + this.num2dword(len(mxc)) + this.num2dword(_add) 
= mixerGetLineControls(hmixer, @mxlc, 0) &&MIXER_GETLINECONTROLSF_ALL=0 

= CopyMemory (@mxc , _add , len(mxc)) && 音量 (Lcontrols的第1個是音量) 
* = CopyMemory (@mute, _add + len(mxc) , len(mxc)) && 靜音 (預設在Lcontrols的第2個,但還是簡單的尋找一下) 

for s=0 to Lcontrols-1 &&尋找靜音 
= CopyMemory (@mute, _add+(len(mxc)*s) , len(mxc)) 
if "mute" $ lower(substr(mute,21,16)) 
exit 
else 
if s=Lcontrols-1 && 都沒有找到的話,可能是名稱不同,那就.. 
= CopyMemory (@mute, _add+len(mxc) , len(mxc)) && 死馬當活馬醫, 採用 Lcontrols的第2個 
endif 
endif 
endfor 
= GlobalFree (hMem) 


最小音量 = this.buf2dword (substr(mxc,101,4)) 
最大音量 = this.buf2dword (substr(mxc,105,4)) 
this.VSlider.tickFrequency=最大音量/6 &&出現6個或7個指標線 
this.VSlider.min = 最小音量 
this.VSlider.max = 最大音量 

vol = REPL(chr(0),4) 
hmem = GlobalAlloc(0, Len(vol)) 
_add = GlobalLock(hmem) 

xControlID = substr(mxc,5,4) 
uControlID = substr(mute,5,4) 
mxcd = this.num2dword(24) + xControlID + this.num2dword(1) + this.num2dword(0) + this.num2dword(len(vol)) + this.num2dword(_add) 
muted = this.num2dword(24) + uControlID + this.num2dword(1) + this.num2dword(0) + this.num2dword(len(vol)) + this.num2dword(_add) 

thisform.取得音量與靜音 

this.timer1.interval = 200 &&與windows的音量控制同步, 不想的話可以 mark 起來, 加快速度 

* ------- 下面程式會開啟windows的音量控制,可以把它mark ------ 
DECLARE INTEGER ShellExecute IN shell32 INTEGER, STRING, STRING, STRING, STRING, INTEGER 
= ShellExecute (0, "open", "Sndvol32.exe", "", "", 1) 
ENDPROC 


PROCEDURE Timer1.Timer 
thisform.forecolor=rgb(255,255,255) 
thisform.line(13,55,24,55) 
thisform.line(13,55,24,127) 
thisform.forecolor=rgb(100,100,100) 
thisform.line(24,55,24,123) 

thisform.取得音量與靜音 
ENDPROC 


PROCEDURE 取得音量與靜音 
DECLARE RtlMoveMemory IN kernel32 As CopyMemory INTEGER @ Destination, INTEGER Source, INTEGER nLength 

*音量 
= mixerGetControlDetails (hmixer, @mxcd, 0) && MIXER_GETCONTROLDETAILSF_VALUE = 0 
_add = this.buf2dword(substr(mxcd,21,4)) &&存放區的地址 
vol = 4 
= CopyMemory (@vol, _add, vol) &&將 _add指定存放區的值,拷備給vol 
this.VSlider.value = 最大音量 - vol 

*靜音 
= mixerGetControlDetails(hmixer, @muted, 0) && MIXER_GETCONTROLDETAILSF_VALUE = 0 
_add = this.buf2dword(substr(muted,21,4)) &&存放區的地址 
OnOff = 4 
= CopyMemory (@OnOff, _add, OnOff) &&將 _add指定存放區的值,拷備給OnOff 
this.chkMute.value = OnOff 
ENDPROC 



PROCEDURE 設定音量 
DECLARE RtlMoveMemory IN kernel32 As CopyMemory INTEGER Destination, STRING @ Source, INTEGER nLength 

_add = this.buf2dword(substr(mxcd,21,4)) &&存放區的地址 
vol = this.num2dword(最大音量 - this.VSlider.value) &&設定音量的值 
= CopyMemory (_add , @vol , 4) &&將vol的值,拷備至 _add所指的存放區 
= mixerSetControlDetails (hmixer, @mxcd, 0) 
ENDPROC 



PROCEDURE 設定靜音 
DECLARE RtlMoveMemory IN kernel32 As CopyMemory INTEGER Destination, STRING @ Source, INTEGER nLength 

_add = this.buf2dword(substr(muted,21,4)) &&存放區的地址 
OnOff = this.num2dword(this.chkMute.value) &&設定靜音的值 
= CopyMemory (_add , @OnOff , 4) &&將OnOff的值,拷備至 _add所指的存放區 
= mixerSetControlDetails (hmixer, @muted, 0) 
ENDPROC 



PROCEDURE chkMute.interactivechange && 點擊靜音 (設定靜音) 
thisform.設定靜音 
ENDPROC 



PROCEDURE buf2Dword (v) &&接收32位元數值資料,回傳十進位 
RETURN ; 
asc(substr(v, 1,1)) +; 
asc(substr(v, 2,1)) * 256 +; 
asc(substr(v, 3,1)) * 65536 +; 
asc(substr(v, 4,1)) * 16777216 
ENDPROC 


PROCEDURE num2Dword (lnValue) &&接收十進位,回傳32位元數值資料 
#DEFINE m0 256 
#DEFINE m1 65536 
#DEFINE m2 16777216 
LOCAL b0, b1, b2, b3 
b3 = Int(lnValue/m2) 
b2 = Int((lnValue - b3*m2)/m1) 
b1 = Int((lnValue - b3*m2 - b2*m1)/m0) 
b0 = Mod(lnValue, m0) 
RETURN Chr(b0)+Chr(b1)+Chr(b2)+Chr(b3) 
ENDPROC 


ENDDEFINE 



DEFINE CLASS Slider AS OLEcontrol 
visible=.T. 
PROCEDURE mouseDOWN 
LPARAMETERS button, shift, x, y 
thisform.timer1.enabled=.F. 
ENDPROC 

PROCEDURE mouseUP 
LPARAMETERS button, shift, x, y 
thisform.timer1.enabled=.T. 
ENDPROC 

PROCEDURE Scroll 
thisform.設定音量 
ENDPROC 
ENDDEFINE