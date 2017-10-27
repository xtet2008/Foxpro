IF USED("test") THEN 
	USE IN test
ENDIF 

USE d:\test SHARED AGAIN 
SELECT test
GOTO bottom
DO WHILE NOT downloads 
	IF downloads then
		SKIP -1
		loop
	else
		IF lDownloadFiles(column1) then
			replace Downloads WITH .t.
			SKIP -1
		ENDIF
	ENDIF
enddo
