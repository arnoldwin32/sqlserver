DECLARE @CODMATRICULA VARCHAR(50)
DECLARE @STATUS INT

DECLARE CR_ATUALIZA_STATUS CURSOR FOR
	SELECT 
	MATRICULA,
	SITUACAO
	FROM 
	MTS
OPEN CR_ATUALIZA_STATUS

FETCH NEXT FROM CR_ATUALIZA_STATUS INTO @CODMATRICULA,@STATUS
WHILE @@FETCH_STATUS = 0 
BEGIN
	UPDATE ZVSI
	SET SITUACAO = @STATUS
	WHERE CODMATRICULA = @CODMATRICULA
	FETCH NEXT FROM CR_ATUALIZA_STATUS INTO @CODMATRICULA,@STATUS
END
CLOSE CR_ATUALIZA_STATUS
DEALLOCATE CR_ATUALIZA_STATUS