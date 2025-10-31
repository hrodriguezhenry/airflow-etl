SELECT ahce.AÑO AS 'year',
    ahce.SEMANA AS 'week',
    ahce.FECHA_INICIO AS start_date,
    ahce.FECHA_FIN AS end_date,
    ahce.CENTRO_COSTO AS cost_center,
    ahce.DESCRIPCION_CENTRO_COSTO AS cost_center_description,
    ahce.HEAD_COUNT_ESTANDAR AS standard_head_count
FROM AUTOMATE_HEAD_COUNT_ESTANDAR AS ahce
