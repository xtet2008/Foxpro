*****************************************
* OFFICE���ֶ���ʾ�� *
* *
* ��ɫѩ������ 2001.02 *
* *
*ע�⣺ȷ��EXCEL�е����ֿ��� *
*****************************************
Clear All
Close All
#Define msoBalloonTypeButtons 0
#Define msoAnimationGreeting 2
#Define msoButtonSetNone 0
#Define msoButtonSetOK 1
#Define msoButtonSetCancel 2
#Define msoButtonSetOkCancel 3
#Define msoButtonSetYesNo 4
#Define msoButtonSetYesNoCancel 5
#Define msoButtonSetBackClose 6
#Define msoButtonSetNextClose 7
#Define msoButtonSetBackNextClose 8
#Define msoButtonSetRetryCancel 9
#Define msoButtonSetAbortRetryIgnore 10
#Define msoButtonSetBackNextSnooze 12
#Define msoButtonSetSearchClose 13
#Define msoButtonSetYesAllNoCancel 14
RptSheet = Getobject('','excel.sheet')
RptSheet.Application.Visible = .T.
With RptSheet.Application.Assistant
*!*	.On = .T.
.Visible = .T.
.Sounds = .T.
.Move(700, 100)
.MoveWhenInTheWay = .T.
.TipOfDay = .T.
.Animation = msoAnimationGreeting
EndWith
INKEY(2)
With RptSheet.Application.Assistant.NewBalloon
.BalloonType = msoBalloonTypeButtons
.Button = msoButtonSetOkCancel
.Heading = "��ѡ��������ʾ�е�һ�"
.Labels(1).Text = "�����˳�."
.Labels(2).Text = "�����˳�."
.Labels(3).Text = "ȡ������."
a = .Show
EndWith
INKEY(2)
With RptSheet.Application.Assistant.NewBalloon
.Heading = "��ʾ��Ϣ"
.Text = "ѡ�����������Ŀ"
For i = 1 To 3
.CheckBoxes(i).Text = "Region " + ALLTRIM(STR(i))
Next
.Button = msoButtonSetOkCancel
.Show
EndWith
INKEY(5)
RptSheet = .null.
CLEAR ALL 
CLOSE ALL 
Retu