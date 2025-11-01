SELECT pc.ORDER_TOT AS cust_ord_hdr_number,
	pc.ORDEN AS cust_ord,
	pc.LINEA AS line_number,
	pc.DESCRIPCION AS line,
	pc.UNIDADES AS quantity,
	pc.FECHA AS planning_date,
	pc.ETAPA AS stage,
	pc.SEMANA AS 'week',
	pc.DIA AS 'day',
	pc.ESTILO AS style_id,
	pc.FAMILIA AS family,
	pc.CLIENTE AS customer
FROM PLAN_CONGELADO AS pc