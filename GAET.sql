
DECLARE @DE DATETIME
DECLARE @ATE DATETIME

SET @DE = '2019-01-04'
SET @ATE = '2019-30-04'
SELECT DISTINCT
	LEFT(CONCAT(SPROFESSOR.CHAPA,SPACE(16)),16) AS CHAPA,
	SPROFESSOR.CODPROF,
	REPLACE(CONVERT(VARCHAR(10),@DE,103),'/','') AS COMPETENCIA,
	'1330' AS EVENTO,
	'000:00' AS HORA,
	RIGHT(CONCAT(SPACE(15),COUNT(SPL.DATA),'.00'),15) AS GAET,
	RIGHT(CONCAT(SPACE(15),'00','.00'),15) AS REAL,
	RIGHT(CONCAT(SPACE(15),'00','.00'),15) AS ORIGINAL,
	'N' AS MANUALMENTE
	
	
FROM

	STURMA ST (NOLOCK)

INNER JOIN
	STURMACOMPL STC (NOLOCK) ON
	STC.CODCOLIGADA = ST.CODCOLIGADA AND
	STC.CODFILIAL   = ST.CODFILIAL   AND
	STC.IDPERLET    = ST.IDPERLET    AND
	STC.CODTURMA    = ST.CODTURMA

INNER JOIN
	STURMADISC STD (NOLOCK) ON
	STD.CODCOLIGADA = ST.CODCOLIGADA AND
	STD.CODFILIAL   = ST.CODFILIAL AND
	STD.IDPERLET    = ST.IDPERLET AND
	STD.CODTURMA    = ST.CODTURMA

INNER JOIN
	STURMADISCCOMPL STDC (NOLOCK) ON
	STDC.CODCOLIGADA = STD.CODCOLIGADA AND
	STDC.IDTURMADISC = STD.IDTURMADISC

INNER JOIN
	SPLANOAULA SPL (NOLOCK) ON
	SPL.CODCOLIGADA = STD.CODCOLIGADA AND
	SPL.CODFILIAL   = STD.CODFILIAL   AND
	SPL.IDTURMADISC = STD.IDTURMADISC

INNER JOIN 
	SHORARIOTURMA SHT(NOLOCK) ON 
	SHT.CODCOLIGADA = SPL.CODCOLIGADA AND 
	SHT.IDHORARIOTURMA = SPL.IDHORARIOTURMA

INNER JOIN 
	SHORARIOPROFESSOR SHP(NOLOCK) ON 
	SHT.CODCOLIGADA = SHP.CODCOLIGADA AND 
	SHT.IDHORARIOTURMA = SHP.IDHORARIOTURMA

INNER JOIN
	SPROFESSORTURMA SPT (NOLOCK) ON
	SPT.CODCOLIGADA = SHP.CODCOLIGADA AND
	SPT.IDPROFESSORTURMA = SHP.IDPROFESSORTURMA
INNER JOIN SPROFESSOR (NOLOCK) ON
	SPROFESSOR.CODCOLIGADA = SPT.CODCOLIGADA
	AND SPROFESSOR.CODPROF = SPT.CODPROF

INNER JOIN
		PFUNC PF (NOLOCK) ON
		PF.CODCOLIGADA = SPROFESSOR.CODCOLIGADA AND
		PF.CODPESSOA   = SPROFESSOR.CODPESSOA

WHERE

ISNULL(SPL.SUBSTITUTO,'') <> 'S' /*RECUPERA OS DADOS DE PROFESSORES QUE N�O TEM SUBSTITUTOS*/
AND STDC.GAET = '1' /*CONTAR GAET SOMENTE PARA DISCIPLINAS DEVIDAMENTE MARCADAS*/
AND SPL.DATA BETWEEN @DE AND @ATE /*AS DATAS DOS PLANOS DE AULA PRECISAM ESTAR PREENCHIDAS DENTRO DO PER�ODO INDICADO*/
AND STD.CODCOLIGADA = 3 /*SOMENTE SE APLICA AO SENAI*/
AND STD.CODFILIAL = 4 /*FILIAL*/
AND ISNULL(STC.TRETIDA,2) = 2 /*N�O CONTA GAET PARA TURMAS RETIDAS*/
AND ISNULL(SHT.CODTIPOSALA,0) != '6' /*TURMAS SIMULTANEAS*/
AND PF.CODFUNCAO IN ('00045','00374') /*N�O PAGA GAET PARA PROFESSOR 06-05-2019*/

GROUP BY
	SPROFESSOR.CHAPA,
	SPROFESSOR.CODPROF