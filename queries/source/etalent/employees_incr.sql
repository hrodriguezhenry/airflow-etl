SELECT DISTINCT pee.EPDO_CODIGO AS code_employee,
    pee.EPDO_PRIMER_NOM AS first_name,
    pee.EPDO_SEGUNDO_NOM AS second_name,
    pee.EPDO_PRIMER_APE AS first_surname,
    pee.EPDO_SEGUNDO_APE AS second_surname,
    pee.EPDO_PROFESION AS profession,
    pee.EPDO_ESTADO AS state,
    pee.EPDO_CELULAR AS phone,
    pee.EPDO_FECHA_INGRESO AS date_entry,
    pee.EPDO_FECHA_NAC AS date_birth,
    ppp.PLA_NOMBRE AS position,
    ppp.VAR2 AS area,
    rep.cod_supervisor,
    rep.supervisor_name,
    pccb.CEB_CODIGO AS cod_cost_center,
    pccb.CEB_CC2 AS cost_center,
    pccb.CEB_DESCRIPCION AS cost_center_description,
    pee.EPDO_CODJOR AS cod_day,
    pjj.JDA_DESCRIPCION AS day_desc,
    piie.IDEM_DPI AS dpi
    
FROM dbo.PAZ_EPDO_EMPLEADO AS pee

LEFT OUTER JOIN dbo.PAZ_PLA_PLAZA AS ppp 
ON pee.EPDO_CODCIA = ppp.PLA_CODCIA
AND pee.EPDO_CODPLZ = ppp.PLA_CODIGO

LEFT OUTER JOIN (
	SELECT paee.EPDO_NOMBRE_COMPLETO AS supervisor_name,
	    paee.EPDO_CODIGO AS cod_supervisor,
	    papp.PLA_REPORTA AS reports,
	    paee.EPDO_CODCIA
	FROM dbo.PAZ_EPDO_EMPLEADO AS paee
    LEFT OUTER JOIN dbo.PAZ_PLA_PLAZA AS papp 
	ON papp.PLA_CODCIA = paee.EPDO_CODCIA
    AND papp.PLA_REPORTA = paee.EPDO_CODPLZ
	WHERE paee.EPDO_ESTADO = 'A'
) AS rep 
ON ppp.PLA_REPORTA = rep.reports 
AND pee.EPDO_CODCIA = rep.EPDO_CODCIA

LEFT JOIN PAZ_CEBPP_CENTROS_BENEFICIO_POR_PLAZA AS pccbpp 
ON pccbpp.CEBPP_CODPLZ = ppp.PLA_CODIGO 
AND pee.EPDO_CODCIA = pccbpp.CEBPP_CODCIA 

LEFT JOIN PAZ_CEB_CENTRO_BENEFICIO AS pccb 
ON pccbpp.CEBPP_CODCEB = pccb.CEB_CODIGO 
AND pee.EPDO_CODCIA = pccb.CEB_CODCIA

LEFT JOIN PAZ_JDA_JORNADA AS pjj 
ON pee.EPDO_CODJOR = pjj.JDA_CODIGO 
AND pee.EPDO_CODCIA = pjj.JDA_CODCIA

LEFT JOIN PAZ_IDEM_IDENTIFICACION_EMPLEADO AS piie 
ON pee.EPDO_CODIGO = piie.IDEM_CODEMP
WHERE pee.EPDO_CODCIA = 1