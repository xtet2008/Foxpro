���   �'  �'  W                     ��0	   m                 z  PLATFORM   C                  UNIQUEID   C	   
               TIMESTAMP  N   
               CLASS      M                  CLASSLOC   M!                  BASECLASS  M%                  OBJNAME    M)                  PARENT     M-                  PROPERTIES M1                  PROTECTED  M5                  METHODS    M9                  OBJCODE    M=                 OLE        MA                  OLE2       ME                  RESERVED1  MI                  RESERVED2  MM                  RESERVED3  MQ                  RESERVED4  MU                  RESERVED5  MY                  RESERVED6  M]                  RESERVED7  Ma                  RESERVED8  Me                  USER       Mi                                                                                                                                                                                                                                                                                          COMMENT Screen                                                                                              WINDOWS _1BQ03WPU8 824577581      /  F      ]                          j      s                       WINDOWS _1BQ03WPU9 824710196�      �  �  �  �                                                           WINDOWS _1BQ03WPUA 824710196|      �  �      �      W  0                                               WINDOWS _1BQ03WPUB 824710140�      �  �  �  �      �	  �                                               WINDOWS _1BQ03WPUC 824577581g      u  �  �  �                                                           WINDOWS _1BQ03WPUD 824710192�      �  �    ,      �  �                                               WINDOWS _1BQ03WPUE 824577581�      �  �  �  �                                                           WINDOWS _1BQ03WPUF 824710192&      5  D  Q  q      �  X                                               WINDOWS _1BQ03WPUG 824577581�      �      <                                                           WINDOWS _1BQ03WPUH 824710192l      {  �  �  �                                                       WINDOWS _1BQ03WPUI 8245775817      E  S  b  �                                                           WINDOWS _1BQ03WPUJ 824710192�      �  �  �  �      ^  �                                               WINDOWS _1BQ03WPUK 824710140}      �  �  �  �      )  T                                               WINDOWS _1BQ03WPUL 824710140"      7  L  �  Z      �  %
                                               WINDOWS _1BQ03WPUM 824710140�      �  v  i  �
      5  =                                               COMMENT RESERVED                                                                                            �                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 VERSION =   3.00      dataenvironment      dataenvironment      Dataenvironment      KLeft = 24
Top = 212
Width = 520
Height = 200
Name = "Dataenvironment"
      cursor      cursor      Cursor1      Dataenvironment      pLeft = 10
Top = 20
Width = 100
Height = 90
Alias = "setpath"
CursorSource = setpath.dbf
Name = "Cursor1"
      2      1      form      form      Form1      �Height = 260
Width = 461
DoCreate = .T.
AutoCenter = .T.
BorderStyle = 0
Caption = "Set Path "
WindowType = 1
AlwaysOnTop = .T.
AlwaysOnBottom = .F.
Name = "Form1"
      �PROCEDURE Init
ThisForm.grdSetpath.setall('Dynamicbackcolor',"IIF(mod(recno(),2) = 0 ,RGB(254,254,239),RGB(255,255,255))","COLUMN")
ENDPROC
PROCEDURE Unload
*clear event
ENDPROC
PROCEDURE Load
*read event
ENDPROC
      ����    �   �                         ��   %   P       e      _           �  U   
 ��  � � U  THISFORM RELEASE Click,     ��1 � 1                       !       )   �                         !Arial, 0, 9, 5, 15, 12, 32, 3, 0
      ,PROCEDURE Click
thisform.release
ENDPROC
      Form1      CmdClose      commandbutton      commandbutton      Form1      grid      grid      
grdSetpath      Form1     �ColumnCount = 4
HeaderHeight = 24
Height = 200
Left = 0
Panel = 1
RecordSource = "setpath"
RecordSourceType = 1
RowHeight = 23
Top = 0
Width = 461
BackColor = 254,254,239
GridLineColor = 64,128,128
Name = "grdSetpath"
Column1.ControlSource = "setpath.company"
Column1.BackColor = 254,254,239
Column1.Name = "Column1"
Column2.ControlSource = "setpath.remarks"
Column2.BackColor = 254,254,239
Column2.Name = "Column2"
Column3.ControlSource = "setpath.set_defa"
Column3.Width = 111
Column3.BackColor = 254,254,239
Column3.Name = "Column3"
Column4.ControlSource = "setpath.set_path"
Column4.Width = 160
Column4.BackColor = 254,254,239
Column4.Name = "Column4"
      vPROCEDURE DblClick
ThisForm.cmdSetPath.click
ENDPROC
PROCEDURE Init
this.setall('alignment',2,'Header')
ENDPROC
      ����    �   �                         �B   %   U       l      d           �  U    �
 ��  � � U  THISFORM REFRESH Click,     ��1 Q � 1                       /       )   �                         dTop = 216
Left = 300
Height = 37
Width = 75
Cancel = .T.
Caption = "Close"
Name = "CmdClose"
      header      header      Header1      Form1.grdSetpath.Column1      'Caption = "company"
Name = "Header1"
      textbox      textbox      Text1      Form1.grdSetpath.Column1      YBorderStyle = 0
Margin = 0
ForeColor = 0,0,0
BackColor = 254,254,239
Name = "Text1"
      8PROCEDURE DblClick
ThisForm.cmdSetPath.click
ENDPROC
      ����    �   �                         ��   %   ]       u      o           �  U    ��  � � � U  THISFORM
 CMDSETPATH CLICK DblClick,     ��1 � 1                       -       )   �                         header      header      Header1      Form1.grdSetpath.Column2      'Caption = "remarks"
Name = "Header1"
      textbox      textbox      Text1      Form1.grdSetpath.Column2      YBorderStyle = 0
Margin = 0
ForeColor = 0,0,0
BackColor = 254,254,239
Name = "Text1"
      8PROCEDURE DblClick
ThisForm.cmdSetPath.click
ENDPROC
      ����    �   �                         ��   %   ]       u      o           �  U    ��  � � � U  THISFORM
 CMDSETPATH CLICK DblClick,     ��1 � 1                       -       )   �                         header      header      Header1      Form1.grdSetpath.Column3      (Caption = "set_defa"
Name = "Header1"
      textbox      textbox      Text1      Form1.grdSetpath.Column3      YBorderStyle = 0
Margin = 0
ForeColor = 0,0,0
BackColor = 254,254,239
Name = "Text1"
      8PROCEDURE DblClick
ThisForm.cmdSetPath.click
ENDPROC
      ����    �   �                         ��   %   ]       u      o           �  U    ��  � � � U  THISFORM
 CMDSETPATH CLICK DblClick,     ��1 � 1                       -       )   �                         header      header      Header1      Form1.grdSetpath.Column4      (Caption = "set_path"
Name = "Header1"
      textbox      textbox      Text1      Form1.grdSetpath.Column4      YBorderStyle = 0
Margin = 0
ForeColor = 0,0,0
BackColor = 254,254,239
Name = "Text1"
      8PROCEDURE DblClick
ThisForm.cmdSetPath.click
ENDPROC
      ����    �   �                         ��   %   ]       u      o           �  U    ��  � � � U  THISFORM
 CMDSETPATH CLICK DblClick,     ��1 � 1                       -       )   �                         commandbutton      commandbutton      
cmdSetPath      Form1      [Top = 216
Left = 192
Height = 37
Width = 75
Caption = "Set Path"
Name = "cmdSetPath"
     #PROCEDURE Click
local ldefa,lpath
thisform.visible = .F.
ldefa = alltrim(set_defa)
lpath = alltrim(set_path)
Lsetpath = ldefa + ',' + ldefa + '\include,' + lpath +'\data,'+lpath +'\public,'+lpath +'\reports'
set default to &ldefa.
set path to &Lsetpath.

thisform.release
ENDPROC
     ����    �  �                        �   %   A      d  
   P          �  U  �  ��  � � T� � �-�� T�  �C� ��� T� �C� ���Q T� ��  � ,�  �	 \include,� � \data,� � \public,� � \reports�� set default to &ldefa.
 set path to &Lsetpath.

 �� � � U  LDEFA LPATH THISFORM VISIBLE SET_DEFA SET_PATH LSETPATH RELEASE Click,     ��1 � � � � ��� 1                             )   �                        commandbutton      commandbutton      CmdNew      QTop = 216
Left = 12
Height = 37
Width = 75
Caption = "New"
Name = "CmdNew"
      :PROCEDURE Click
append blank
thisform.refresh
ENDPROC
     3���                              ��   %   �       �      �           �  U    ��  � � � U  THISFORM
 CMDSETPATH CLICK( % ��C�	 alignment�� Header�  � �� U  THIS SETALL DblClick,     �� Init]     ��1 � 2 Q1                       -         H   k       )                          ����    g  g                        p�   %   �       �      �           �  U  l i ��C� Dynamicbackcolor�: IIF(mod(recno(),2) = 0 ,RGB(254,254,239),RGB(255,255,255))� COLUMN�  � � �� U  THISFORM
 GRDSETPATH SETALL  U    U   Init,     �� Unload�     �� Load�     ��1 �2 3 2                       �         �   �         �   �       )   g                      %           N      J   (1   �  � D:\set_path\setpath� U  D�1                 .\ setpath.scx setpath.sct setpath.prg c:\docume~1\admini~1\locals~1\temp\ setpath.fxp 	)   o                 o  ''                  ''  �'  '   K           