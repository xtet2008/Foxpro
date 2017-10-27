*****************************************
* OFFICE助手对象示例 *
* *
* 蓝色雪狐基地 2001.02 *
* *
*注意：确保EXCEL中的助手可用 *
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
.Heading = "请选择下列提示中的一项："
.Labels(1).Text = "保存退出."
.Labels(2).Text = "放弃退出."
.Labels(3).Text = "取消操作."
a = .Show
EndWith
INKEY(2)
With RptSheet.Application.Assistant.NewBalloon
.Heading = "提示信息"
.Text = "选择您所需的项目"
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