* Program Name : PrintingText.Prg
* Article No.  : [Win API] - 008
* Illustrate   : 如何把字符窜直接发送到 VFP 主窗口上？
* Date / Time  : 2001.09.10
* Writer       : 
* 1st Post     : 
*

Do decl

HWnd = GetActiveWindow()
hDC = GetWindowDC (hwnd)

lpString = "Printing Text with TextOut"
= TextOut (hDC, 50,80, lpString, Len(lpString)) &&

= ReleaseDC (hwnd, hDC)

Procedure  decl
    Declare INTEGER GetWindowDC IN user32 INTEGER hwnd

    Declare INTEGER ReleaseDC IN user32;
        INTEGER hwnd, INTEGER hdc

    Declare INTEGER GetActiveWindow IN user32

    Declare INTEGER TextOut IN gdi32;
        INTEGER hdc,;
        INTEGER x,;
        INTEGER y,;
        STRING  lpString,;
        INTEGER nCount