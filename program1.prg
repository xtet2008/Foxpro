#DEFINE wdToggle 9999998
#DEFINE wdTableRight -999996
#DEFINE wdAlignParagraphLeft 0
#DEFINE wdAlignParagraphCenter 1
#DEFINE wdAlignParagraphJustify 3
#DEFINE wdHorizontalPositionMargin 0
#DEFINE wdCollapseEnd 0
#DEFINE wdCollapseStart 1
#DEFINE wdParagraph 4

oWord = CREATEOBJECT("Word.Application")
oWord.Visible = .F.  && Toggle this to True to see if there's
                     && any difference
oDoc = oWord.Documents.Add()
oRange = oDoc.Range()
oRange.Collapse(wdCollapseStart)
WITH oRange
	.ParagraphFormat.Alignment = wdAlignParagraphCenter
	.Font.Size = 14
	.Font.Name = "Arial Black"
	.InsertAfter("Heading for Sales Report")
	.MoveEnd(wdParagraph,1)

	.Bold = .T.
	.Collapse(wdCollapseEnd)
	.InsertParagraphAfter()
	.MoveEnd(wdParagraph,1)
	.Bold = .F.
	.Collapse(wdCollapseEnd)

	.ParagraphFormat.Alignment = wdAlignParagraphLeft
	.Font.Size = 12
	.Font.Name = "Times New Roman"
	.InsertParagraphAfter()
	.InsertParagraphAfter()
	.ParagraphFormat.Alignment = wdAlignParagraphLeft
	.InsertAfter(REPLICATE("Paragraph #1 is left aligned. "+;
		"Paragraph 2 is justified. ",4))
	.Collapse(wdCollapseEnd)
	.InsertParagraphAfter()
	.InsertParagraphAfter()
	.Collapse(wdCollapseEnd)
	.ParagraphFormat.Alignment = wdAlignParagraphJustify
	.InsertAfter(REPLICATE("This is a long paragraph that "+;
		"needs to wrap around a table that will fit in the "+;
		"paragraph, aligned at the right margin. ", 3))
	.Collapse(wdCollapseEnd)
ENDwith

*!* Need a table of 4 rows, 3 columns, plus cells for labels and headings.
oWord.ActiveDocument.Tables.Add(oRange, 5, 4, 1, 0) && Word 2000 syntax
*!* Arguments are Range, #rows, #cols, [DefaultTableBehavior,] [AutoFitBehavior])
*!* Word 97 syntax is oWord.ActiveDocument.Tables.Add(oRange, 5, 4)
oTable = oWord.ActiveDocument.Tables(1) && Assign a table object
WITH oTable
	.Columns.SetWidth(72,0)               && 72 points/inch
	.Rows.WrapAroundText = .T.
	.Rows.RelativeHorizontalPosition = 0  && wdHorizontalPositionMargin
	.Rows.HorizontalPosition = -999996    && wdTableRight
	.Autoformat(2,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.)
*!* (Format,ApplyBorders,ApplyShading,ApplyFont,ApplyColor,ApplyHeadingRows,
*!*         ApplyLastRow,ApplyFirstColumn,ApplyLastColumn,AutoFit)
	.Cell(2,1).Range.InsertAfter("Qtr 1")
	.Cell(3,1).Range.InsertAfter("Qtr 2")
	.Cell(4,1).Range.InsertAfter("Qtr 3")
	.Cell(1,2).Range.InsertAfter("Eastern")
	.Cell(1,3).Range.InsertAfter("Central")
	.Cell(1,4).Range.InsertAfter("Western")
	.Cell(2,2).Range.InsertAfter("4.5")
	.Cell(2,3).Range.InsertAfter("3.7")
	.Cell(2,4).Range.InsertAfter("4.2")
	

	.Cell(3,2).Range.InsertAfter("4.7")
	.Cell(3,3).Range.InsertAfter("4.1")
	.Cell(3,4).Range.InsertAfter("4.3")
	
	.Cell(4,2).Range.InsertAfter("4.9")
	.Cell(4,3).Range.InsertAfter("4.0")
	.Cell(4,4).Range.InsertAfter("4.5")
	
	.Rows(5).Cells.Merge
	.Cell(5,1).Range.InsertAfter("Quarterly Cookie "+;
		"Sales by Region - in $ Millions")
	.Cell(5,1).Range.MoveEnd(wdParagraph,1)
	.Cell(5,1).Range.Bold = .T.
	.Cell(5,1).FitText = .T.
	
	.Rows(1).Shading.Texture = 200	
ENDwith
oRange = oTable.Range
oRange.Collapse(wdCollapseEnd) && Move insertion point beyond table
WITH oRange
	.InsertAfter("The table goes before this sentence. ")
	.InsertAfter(REPLICATE("This is a long paragraph that "+;
		"needs to wrap around a table that will fit in the "+;
    	"paragraph, aligned at the right margin. ",5)) 
	.InsertParagraphAfter()
	.InsertParagraphAfter()
	.InsertAfter("A New Paragraph")
ENDwith

oWord.Visible = .T.  && Inspect the results
MESSAGEBOX("Look at results in Word.")


oWord.Quit(.F.) && Don't save changes
ThisForm.Release
					