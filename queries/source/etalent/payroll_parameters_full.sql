SELECT pppp.PARPLA_CODCIA AS cod_company,
    pppp.PARPLA_CODTPL AS cod_type_payroll,
    pppp.PARPLA_CODPLA AS cod_payroll,
    pppp.PARPLA_FECHA_INI AS start_date,
    pppp.PARPLA_FECHA_FN AS end_date,
    pppp.PARPLA_FRECUENCIA AS frequency
FROM PAZ_PARPLA_PARAMETROS_PLANILLA AS pppp