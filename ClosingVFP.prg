* Program Name : ClosingVFP.Prg
* Article No.  : [Win API] - 016
* Illustrate   : 强行退出 VFP
* Date / Time  : 2001.09.10
* Writer       : 
* 1st Post     : 
* My Comment   : 可以直接退出 VFP 的应用程序，避免按右上角的 'X'，提示
*              :‘不能退出 VFP 应用程序’的烦恼，如果要直接退出 VFP 的
*              : 某一子应用程序，可以用 GetExitCodeProcess 仿照使用。

Declare ExitProcess IN kernel32 INTEGER uExitCode
? ExitProcess (54)    && 任意值