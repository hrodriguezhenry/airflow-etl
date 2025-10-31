SELECT ew.ID AS id,
    ew.COMPANIA AS cod_company,
    ew.CODIGO_EMPLEADO AS cod_employee,
    ew.FECHA AS date,
    ew.TIPO_PLANILLA AS cod_type_payroll,
    ew.PERIODO AS cod_payroll,
    ew.ESTADO AS status,
    ew.HORA_ENTRADA AS entry_time,
    ew.HORA_SALIDA AS departure_time,
    ew.MARCA_ENTRADA AS check_in,
    ew.MARCA_SALIDA AS check_out,
    ew.COMENTARIO AS comentary
FROM EXCEPCIONES_WEA AS ew