* Program Name : ClosingVFP.Prg
* Article No.  : [Win API] - 016
* Illustrate   : ǿ���˳� VFP
* Date / Time  : 2001.09.10
* Writer       : 
* 1st Post     : 
* My Comment   : ����ֱ���˳� VFP ��Ӧ�ó��򣬱��ⰴ���Ͻǵ� 'X'����ʾ
*              :�������˳� VFP Ӧ�ó��򡯵ķ��գ����Ҫֱ���˳� VFP ��
*              : ĳһ��Ӧ�ó��򣬿����� GetExitCodeProcess ����ʹ�á�

Declare ExitProcess IN kernel32 INTEGER uExitCode
? ExitProcess (54)    && ����ֵ