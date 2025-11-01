SELECT hdpp.COMPANIA AS cod_company,
    hdpp.PERIODO AS cod_payroll,
    hdpp.TIPO_PLANILLA AS cod_type_payroll,
    hdpp.CODIGO_EMPLEADO AS cod_employee,
    hdpp.CUENTA_CONTABLE AS accounting_account,
    hdpp.CODIGO_CONCEPTO AS cod_concept,
    hdpp.CC2 AS cost_center,
    hdpp.TIPO AS type,
    hdpp.MONTO AS amount,
    pppp.PARPLA_FECHA_INI AS start_date
FROM HISTORICO_DATOS_POLIZA_PROVISIONES AS hdpp
INNER JOIN PAZ_PARPLA_PARAMETROS_PLANILLA AS pppp
ON hdpp.COMPANIA = pppp.PARPLA_CODCIA
AND hdpp.PERIODO = pppp.PARPLA_CODPLA
AND hdpp.TIPO_PLANILLA = pppp.PARPLA_CODTPL
WHERE CONVERT(date, pppp.PARPLA_FECHA_INI) >= CONVERT(date, GETDATE() - 60)