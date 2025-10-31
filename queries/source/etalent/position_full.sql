SELECT ppp.PLA_CODCIA AS cod_company,
    ppp.PLA_CODIGO AS cod_position,
    ppp.PLA_NOMBRE AS position,
    ppp.PLA_CODUNI AS cod_unit,
    ppp.PLA_ESTADO AS state,
    ppp.VAR2 AS area,
    ppp.PLA_REPORTA AS supervisor_cod_position
FROM PAZ_PLA_PLAZA AS ppp