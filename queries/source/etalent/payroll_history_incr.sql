SELECT phhn.HN_CODCIA AS cod_company,
    phhn.HN_CODTPL AS cod_type_payroll,
    phhn.HN_CODPLA AS cod_payroll,
    phhn.HN_SALARIO AS salary,
    phhn.HN_CODEMP AS cod_employee,
    phhn.HN_CODUNI AS cod_unit,
    phhn.HN_CODPLZ AS cod_position,
    phhn.HN_NOMBRE_UNIDAD AS cost_center_description,
    phhn.HN_BONIFICACION AS bonus,
    phhn.HN_BONO_NO_AFECTO AS no_effect_bonus
FROM PAZ_HN_HISTORICO_NOMINA AS phhn
INNER JOIN PAZ_PARPLA_PARAMETROS_PLANILLA AS pppp
ON phhn.HN_CODCIA = pppp.PARPLA_CODCIA
AND phhn.HN_CODTPL = pppp.PARPLA_CODTPL
AND phhn.HN_CODPLA = pppp.PARPLA_CODPLA
WHERE CONVERT(date, pppp.PARPLA_FECHA_INI) >= CONVERT(date, GETDATE() - 7)