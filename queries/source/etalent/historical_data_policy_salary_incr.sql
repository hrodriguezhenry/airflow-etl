SELECT hdps.COMPANIA AS cod_company,
    hdps.PERIODO AS cod_payroll,
    hdps.TIPO_PLANILLA AS cod_type_payroll,
    hdps.CODIGO_EMPLEADO AS cod_employee,
    hdps.CUENTA_CONTABLE AS accounting_account,
    hdps.CODIGO_CONCEPTO AS cod_concept,
    hdps.CC2 AS cost_center,
    hdps.TIPO AS type,
    hdps.MONTO AS amount,
    pppp.PARPLA_FECHA_INI AS start_date
FROM HISTORICO_DATOS_POLIZA_SALARIO AS hdps
INNER JOIN PAZ_PARPLA_PARAMETROS_PLANILLA AS pppp
ON hdps.COMPANIA = pppp.PARPLA_CODCIA
AND hdps.PERIODO = pppp.PARPLA_CODPLA
AND hdps.TIPO_PLANILLA = pppp.PARPLA_CODTPL
WHERE CONVERT(date, pppp.PARPLA_FECHA_INI) >= CONVERT(date, GETDATE() - 60)