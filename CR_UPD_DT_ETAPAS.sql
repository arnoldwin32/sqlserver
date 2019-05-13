DECLARE @CODETAPA INT
DECLARE @DTINICIO DATETIME
DECLARE @DTFIM	  DATETIME
DECLARE @DTINICIODIGITACAO DATETIME
DECLARE @DTLIMITEDIGITACAO DATETIME
DECLARE @ANO VARCHAR(4)
DECLARE @DESCRICAO VARCHAR(40)
DECLARE @TIPOETAPA CHAR(1)
DECLARE @@CODCOLIGADA INT
DECLARE @@CODFILIAL   INT
DECLARE @@IDPERLET    INT

SET @@CODCOLIGADA = :codcoligada
SET @@CODFILIAL   = :codfilial
SET @@IDPERLET    = :idperlet
SET @ANO = DATEPART(YEAR,(SELECT SPLETIVO.DTINICIO FROM SPLETIVO WHERE SPLETIVO.CODCOLIGADA = @@CODCOLIGADA AND SPLETIVO.CODFILIAL = @@CODFILIAL AND SPLETIVO.IDPERLET = @@IDPERLET))

DECLARE  CR_UPD_DT_ETAPAS CURSOR FOR
SELECT
		SMODETAPAPLETIVO.CODETAPA,
		SMODETAPAPLETIVO.TIPOETAPA,
		CASE WHEN SMODETAPAPLETIVO.TIPOETAPA = 'N'
			THEN SMODETAPAPLETIVO.DESCRICAO
		ELSE CONCAT(LEFT(SMODETAPAPLETIVO.DESCRICAO,5),' (',CONCAT(FORMAT(DATEPART(DAY,SMODETAPAPLETIVO.DTINICIO),'00'),'/',FORMAT(DATEPART(MONTH,SMODETAPAPLETIVO.DTINICIO),'00'),'/',@ANO),' À ',FORMAT(DATEPART(DAY,SMODETAPAPLETIVO.DTFIM),'00'),'/',FORMAT(DATEPART(MONTH,SMODETAPAPLETIVO.DTINICIO),'00'),'/',@ANO,')') 
		END
		DESCRICAO,
		CONCAT(@ANO,'-',FORMAT(DATEPART(MONTH,SMODETAPAPLETIVO.DTINICIO),'00'),'-',FORMAT(DATEPART(DAY,SMODETAPAPLETIVO.DTINICIO),'00'),' 00:00:00') DTINICIO,
		CONCAT(@ANO,'-',FORMAT(DATEPART(MONTH,SMODETAPAPLETIVO.DTFIM),'00'),'-',FORMAT(DATEPART(DAY,SMODETAPAPLETIVO.DTFIM),'00'),' 00:00:00') DTFIM,
		CONCAT(@ANO,'-',FORMAT(DATEPART(MONTH,SMODETAPAPLETIVO.DTINICIODIGITACAO),'00'),'-',FORMAT(DATEPART(DAY,SMODETAPAPLETIVO.DTINICIODIGITACAO),'00'),' 00:00:00') DTINICIODIGITACAO,
		CONCAT(@ANO,'-',FORMAT(DATEPART(MONTH,SMODETAPAPLETIVO.DTLIMITEDIGITACAO),'00'),'-',FORMAT(DATEPART(DAY,SMODETAPAPLETIVO.DTLIMITEDIGITACAO),'00'),' 00:00:00') DTLIMITEDIGITACAO
		FROM SMODETAPAPLETIVO
		INNER JOIN SPLETIVO ON 
		SPLETIVO.CODCOLIGADA = SMODETAPAPLETIVO.CODCOLIGADA AND 
		SPLETIVO.IDPERLET = SMODETAPAPLETIVO.IDPERLET
		WHERE SPLETIVO.CODCOLIGADA = @@CODCOLIGADA
		AND   SPLETIVO.CODFILIAL = @@CODFILIAL
		AND   SPLETIVO.IDPERLET = @@IDPERLET
		AND   SMODETAPAPLETIVO.CODETAPA NOT IN (30,31,60,61)
		AND   SMODETAPAPLETIVO.DTINICIO IS NOT NULL
		AND   SMODETAPAPLETIVO.DTFIM    IS NOT NULL
		AND   SMODETAPAPLETIVO.DTINICIODIGITACAO IS NOT NULL
		AND   SMODETAPAPLETIVO.DTLIMITEDIGITACAO IS NOT NULL

OPEN CR_UPD_DT_ETAPAS
FETCH NEXT FROM CR_UPD_DT_ETAPAS INTO @CODETAPA,@TIPOETAPA,@DESCRICAO,@DTINICIO,@DTFIM,@DTINICIODIGITACAO,@DTLIMITEDIGITACAO
WHILE @@FETCH_STATUS = 0
BEGIN
	UPDATE SMODETAPAPLETIVO
	SET 
	SMODETAPAPLETIVO.DTINICIO = @DTINICIO,
	SMODETAPAPLETIVO.DTFIM = @DTFIM,
	SMODETAPAPLETIVO.DESCRICAO = @DESCRICAO,
	SMODETAPAPLETIVO.DTINICIODIGITACAO = @DTINICIODIGITACAO,
	SMODETAPAPLETIVO.DTLIMITEDIGITACAO = @DTLIMITEDIGITACAO,
	SMODETAPAPLETIVO.RECMODIFIEDBY = :codusuario,
    SMODETAPAPLETIVO.RECMODIFIEDON = GETDATE()
	FROM SMODETAPAPLETIVO
	INNER JOIN SPLETIVO ON 
		SPLETIVO.CODCOLIGADA = SMODETAPAPLETIVO.CODCOLIGADA AND 
		SPLETIVO.IDPERLET = SMODETAPAPLETIVO.IDPERLET
	WHERE 
		SMODETAPAPLETIVO.CODETAPA = @CODETAPA
		AND   SMODETAPAPLETIVO.TIPOETAPA = @TIPOETAPA
		AND   SPLETIVO.CODCOLIGADA = @@CODCOLIGADA
		AND   SPLETIVO.CODFILIAL = @@CODFILIAL
		AND   SPLETIVO.IDPERLET = @@IDPERLET
		AND   SMODETAPAPLETIVO.CODETAPA NOT IN (30,31,60,61)
		AND   SMODETAPAPLETIVO.DTINICIO IS NOT NULL
		AND   SMODETAPAPLETIVO.DTFIM    IS NOT NULL
		AND   SMODETAPAPLETIVO.DTINICIODIGITACAO IS NOT NULL
		AND   SMODETAPAPLETIVO.DTLIMITEDIGITACAO IS NOT NULL
		
	
	FETCH NEXT FROM CR_UPD_DT_ETAPAS INTO @CODETAPA,@TIPOETAPA,@DESCRICAO,@DTINICIO,@DTFIM,@DTINICIODIGITACAO,@DTLIMITEDIGITACAO	
END
CLOSE CR_UPD_DT_ETAPAS
DEALLOCATE CR_UPD_DT_ETAPAS