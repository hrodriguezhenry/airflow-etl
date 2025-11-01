SELECT sc.ID AS id,
    sc.CODIGO_EMPLEADO AS cod_employee,
    sc.COMPANIA AS cod_company,
    sc.CODIGO_MOTIVO AS clinical_suspension_reason_id,
    sc.FECHA_INICIO AS start_date,
    sc.FECHA_FIN AS end_date,
    sc.HORAS AS hours,
    sc.DIAS AS days
FROM SUSPENSION_CLINICA AS sc