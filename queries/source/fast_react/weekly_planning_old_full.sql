SELECT pco.ORDER_TOT AS cust_ord_hdr_number,
	pco.ORDEN AS cust_ord,
	pco.LINEA AS line_number,
	pco.DESCRIPCION AS line,
	pco.UNIDADES AS quantity,
	pco.FECHA AS planning_date,
	pco.ETAPA AS stage,
	pco.SEMANA AS 'week',
	pco.DIA AS 'day',
	pco.ESTILO AS style_id,
	pco.SEMANA_CARGA AS loading_week,
	pco.AÑO_CARGA AS loading_year,
	pco.FECHA_CARGA AS loading_date
FROM PLAN_CONGELADO_OLD AS pco