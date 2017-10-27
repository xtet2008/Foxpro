*!*	close data all
*!*	m.lcDBF = "c:\mypath\myTable.dbf"
*!*	RepairMemo(Forceext(m.lcDBF,'FPT'))

Function RepairMemo
	* RepairMemo
	* Simply fixes next block pointer, blocksize and filesize
	Lparameters tcMemoFilename
	Local handle, lnFileSize, lnNextBlockPointer, lnBlockSize, lnFirstBlock, lnCalculatedFileSize

	handle=Fopen(tcMemoFilename,12) && Opened readwrite
	lnFileSize = Fseek(handle,0,2) && Get file size
*!*		With This
		* Read header info
		lnNextBlockPointer = ReadBytes(handle, 0,4,.T.) && Stored in left-to-right format
		lnBlockSize        = ReadBytes(handle, 6,2,.T.) && Stored in left-to-right format

		* Specific to me - no blocksize setting to something other than default 0x40
		If lnBlockSize # 0x40
			WriteBytes(handle, 6,2,0x40,.T.)
			lnBlockSize=0x40
		Endif
		*

		lnFirstBlock    = Ceiling(512/lnBlockSize) && Possible min lnNextblockpointer
		lnCalculatedFileSize = lnNextBlockPointer*lnBlockSize

		* Fix if needs repair
		If !(lnFileSize >= 512 ;
				and lnNextBlockPointer >= lnFirstBlock ;
				and lnCalculatedFileSize >= lnFileSize) && Memo needs repair
			lnNextBlockPointer = Max(lnNextBlockPointer, lnFirstBlock)
			lnFileSize = lnNextBlockPointer * lnBlockSize
			WriteBytes(handle, 0,4,lnNextBlockPointer,.T.) && Fix next block pointer
			=Fchsize(handle, lnFileSize) && Fix filesize
		Endif
*!*		Endwith
	=Fclose(handle)

Function WriteBytes
	Lparameters tnHandle, tnPos, tnSize, tnNumber, tlLR
	Local lcString, lnLowDword, lnHighDword,ix
	lcString=''
	If tlLR
		For ix=tnSize-1 To 0 Step -1
			lcString=lcString+Chr(tnNumber/256^ix%256)
		Endfor
	Else
		For ix=0 To tnSize-1
			lcString=lcString+Chr(tnNumber/256^ix%256)
		Endfor
	EndIf
	Return LcString
	=Fseek(tnHandle, tnPos,0) && Go to pos
	Return Fwrite(tnHandle,lcString)
Function ReadBytes
	Lparameters tnHandle, tnPos, tnSize, tlLR
	Local lcString, lnRetValue,ix
	=Fseek(tnHandle, tnPos,0) && Go to pos
	lcString = Fread(tnHandle, tnSize) && Read tnSize bytes
	lnRetValue = 0
*!*		Set Step On 
	For ix=0 To tnSize-1  && Convert to a number
		lnRetValue = lnRetValue + Asc(Substr(lcString,ix+1)) * ;
			iif(tlLR,256^(tnSize-1-ix),256^ix)
	Endfor
	Return Int(lnRetValue)
	