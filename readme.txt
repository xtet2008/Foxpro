���ĵ�Ϊ MYDLL.DLL ˵���ĵ�
***********************************************************
�������� AS IS ��ʽ�ַ���ʹ�øó�����������Ըð�ķ��ա�
��ʹ�øó������ɵ���ʧ���˸Ų�����
��������ʹ�ã��ַ�������ʹ�øó����ڷַ��ʹ���ʱ�����δ���޸ĵı��ĵ���
***********************************************************
MYDLL.DLL �а������º���

1  encstr               ������/����
2  getserial            ��ȡӲ�̳������к�  
3  IsWin2000            ��ǰ�����Ĳ���ϵͳ
4  DPGetDefaultPrinter  ��ȡ��ǰĬ�ϴ�ӡ��
5  DPSetDefaultPrinter  ���õ�ǰĬ�ϴ�ӡ��
6  getname              ��ȡ��ǰ�û���
7  getip                ��ȡ���� IP
8  topy                 ����תƴ��ͷ 
9  getmac               ��ȡ���� MAC
10 VolumeNumber         ��ȡ���̸�ʽ��ʱ�ľ��
11 changeres            �ı���ʾ�ֱ���
12 getcrc               ȡ��һ���ļ��� CRC У��ֵ 
13 IsConnected          �жϱ����Ƿ����ӵ� Internet
14 IsDiskInDrive        �ж��������������Ƿ��������
15 num2txt_e            ת��һ����ֵ��Ϊ��д�Ľ�(Ӣ��)
16 num2txt_c            ת��һ����ֵ��Ϊ��д�Ľ�(����)
17 pinghost             Ping һ��������ַ
18 connecttonetwork     ӳ��������ԴΪһ������������, ��װ�� WNetUseConnection API
19 cancelconnect        �Ͽ�һ���Ѿ�ӳ���������Դ  , ��װ�� WNetCancelConnection2 API
20 myftpputfile         �Ӵ�һ���ļ���ָ���� ftp 
21 myftpgetfile         ��ָ���� ftp ����һ���ļ�
22 httpdownload         ��ָ���� http ����һ���ļ�
23 getmetric            ��ȡϵͳ��ʾ����ǰ�ķֱ���
24 sendmail             ����һ�� email (�ɴ�һ������)
25 smail                ͨ�� smtp �ʼ�����������һ�� email (����Ҫ���ص� OUTLOOK ���ʼ�����,���ɴ��ĸ�����)
26 PrintStringDirect    ֱ�ӷ���һ������ָ����ӡ������ӡ��󲻻���ֽ
27 DialUp               ��������
28 DisconnectRas        �Ͽ�����
29 MD5File              �� md5 �㷨��һ���ļ��� 16 λ����       ( ��л���� goodfrd �ṩԴ���� )
30 MD5String            �� md5 �㷨��һ������ 16 λ����         ( ��л���� goodfrd �ṩԴ���� )
31 compress             ѹ��һ��Ŀ¼�е������ļ���һ�����������(��������Ŀ¼�е�����)
32 decompress           ��ѹһ���� compress ����ѹ�����ļ��е��������ݵ�һ��ָ��Ŀ¼��
33 MyInputBox           һ���򵥵Ŀ��������
34 InitUser             ���ڴ���ȱʡ����Կ��������һ̨������ֻ������һ�Σ���Ϊ��������������׼���ĺ���
35 CAPIEncryptFile      ����һ���ļ�
36 CAPIDecryptFile      ����һ���ļ�
37 sharedel             ����һ��������������Ŀ¼Ϊ����
38 shareadd             ɾ������
39 ShellExecWait        ִ��һ�� DOS ����                          ( ��л���� goodfrd �ṩԴ���� )
40 SetTime              ����һ��Ŀ¼���ļ�������  
41 vfpbeep              ��ϵͳ���� "�" ��
42 hzbh                 ��ȡ���ֱʻ� 
43 exitw                ע��/�ر�/����ϵͳ
44 dirsize              ��ȡһ��Ŀ¼�Ĵ�С
45 getcpuid             ��ȡ��ǰ������ CPUID
46 tojpeg               ת��һ�� BMP �ļ��� JPG �ļ�
47 tobmp                ת��һ�� JPG �ļ��� BMP �ļ�
48 formtobmp            ��������Ļ���ݱ���Ϊһ��λͼ
49 getbmpdemension      ��ȡһ�� BMP �ļ��Ĵ�С
50 getjpgdimension      ��ȡһ�� JPG �ļ��Ĵ�С
51 LoadIME              �����ض������뷨
52 getallproc           ��ȡ��ǰϵͳ�е����н���
53 TerminateApp         ��ֹһ�� 32 λ����
54 ListMail             �г� POP 3 �ʼ��������ϵ��ʼ� 


�������Ϻ����ľ��������ʹ�÷�����μ��渽��ʾ������ mydlltest.prg��
�κν��飬BUG �����뵽 http://www.myf1.net/bbs/list.asp?boardid=1 �����
�Ĵ����ڽ����罨����˾�����ʹ��� ������
njjane@21cn.com

vfp��Ӣվ
www.foxer.net