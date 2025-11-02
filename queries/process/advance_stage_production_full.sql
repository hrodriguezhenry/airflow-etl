SELECT cosl.cust_ord,
	CASE
		WHEN ps.line_id IN (1, 2, 3, 4, 5, 6, 7, 8, 101, 102) THEN 'CORTE COMBINADO'
		WHEN ps.line_id IN (36, 37, 38) THEN 'CORTE SINTETICO'
	END AS stage,

	sq.production_prefix,
	SUM(ps.quantity) AS quantity,
	CONVERT(date, ps.created_at) AS date
FROM source_atomic_sfc.production_scan AS ps
INNER JOIN source_atomic_sfc.scan_qr AS sq
ON ps.sfc_scan_qr_id = sq.id
INNER JOIN analysis.customer_order_style_layer AS cosl
ON sq.cust_ord_hdr_number = cosl.cust_ord
LEFT JOIN (
	SELECT wp.cust_ord
	FROM source_fast_react.weekly_planning AS wp
	WHERE wp.stage IN ('CORTE PIEL', 'GUILLOTINA')
	GROUP BY wp.cust_ord
) AS co
ON sq.cust_ord_hdr_number = co.cust_ord

WHERE ps.stage_id = 2
AND ps.scan_type = 2
AND ps.line_id IN (1, 2, 3, 4, 5, 6, 7, 8, 101, 102, 36, 37, 38)
AND CASE
		WHEN cosl.layers > 1 THEN 'Y'
		WHEN co.cust_ord IS NOT NULL THEN 'Y'
		ELSE 'N'
	END = 'Y'
GROUP BY cosl.cust_ord,
	CASE
		WHEN ps.line_id IN (1, 2, 3, 4, 5, 6, 7, 8, 101, 102) THEN 'CORTE COMBINADO'
		WHEN ps.line_id IN (36, 37, 38) THEN 'CORTE SINTETICO'
	END,
	sq.production_prefix,
	CONVERT(date, ps.created_at)

UNION ALL

SELECT sq.cust_ord_hdr_number AS cust_ord,
	
	CASE
		WHEN stp.operation_id = 1997 THEN 'ESFUMADO'
		WHEN stp.operation_id = 1890 THEN 'TROQUEL'
		WHEN stp.operation_id = 2108 THEN 'TROQUEL SETS'
		WHEN stp.operation_id = 1891 THEN 'ESTAMPADO'
		WHEN stp.operation_id = 1892 THEN 'CANTOS'
		WHEN stp.operation_id = 2123 THEN 'PREENTINTADO'
		WHEN stp.operation_id = 2001 THEN 'PERFORADO'
		WHEN stp.operation_id = 936 THEN 'ATRAQUE'
		WHEN stp.operation_id = 787 THEN 'EMPAQUE'
		WHEN stp.operation_id = 1649 THEN 'SETS'
		WHEN stp.operation_id  IN (1987, 1986) THEN 'COSTURA OCULTA'
		WHEN stp.operation_id = 684 THEN 'COSTURA CUERPOS'
		WHEN stp.operation_id = 1879 THEN 'CUERPOS'
		WHEN stp.operation_id = 1999 THEN 'AZ46'
		WHEN stp.operation_id = 2003 THEN 'CORTE'
		WHEN stp.operation_id = 1995 THEN 'PEGADO'
	END AS stage,
	
	sq.production_prefix,
	SUM(stp.quantity) AS quantity,
	stp.created_at_short AS date
FROM source_atomic_sfc.scan_transact_production AS stp
INNER JOIN source_atomic_sfc.scan_qr AS sq
ON stp.sfc_scan_qr_id = sq.id
INNER JOIN analysis.customer_order_style_layer AS cosl
ON sq.cust_ord_hdr_number = cosl.cust_ord
LEFT JOIN (
	SELECT pds.style_id,
		pds.quantity_seams,
		pds.type_seams
	FROM dwh.pdm_style AS pds
	GROUP BY pds.style_id,
		pds.quantity_seams,
		pds.type_seams
) AS pdsa
ON sq.style_id = pdsa.style_id

WHERE (stp.operation_id IN (1997, 1890, 2108, 1891, 1892, 2123, 2001, 936, 787, 1649, 1987, 1986, 1879, 1999, 2003, 1995)
OR (stp.operation_id = 684 AND pdsa.quantity_seams > 0 AND pdsa.type_seams != 'Costura en Capas'))
AND sq.stage_id != 45
GROUP BY sq.cust_ord_hdr_number,
	CASE
		WHEN stp.operation_id = 1997 THEN 'ESFUMADO'
		WHEN stp.operation_id = 1890 THEN 'TROQUEL'
		WHEN stp.operation_id = 2108 THEN 'TROQUEL SETS'
		WHEN stp.operation_id = 1891 THEN 'ESTAMPADO'
		WHEN stp.operation_id = 1892 THEN 'CANTOS'
		WHEN stp.operation_id = 2123 THEN 'PREENTINTADO'
		WHEN stp.operation_id = 2001 THEN 'PERFORADO'
		WHEN stp.operation_id = 936 THEN 'ATRAQUE'
		WHEN stp.operation_id = 787 THEN 'EMPAQUE'
		WHEN stp.operation_id = 1649 THEN 'SETS'
		WHEN stp.operation_id  IN (1987, 1986) THEN 'COSTURA OCULTA'
		WHEN stp.operation_id = 684 THEN 'COSTURA CUERPOS'
		WHEN stp.operation_id = 1879 THEN 'CUERPOS'
		WHEN stp.operation_id = 1999 THEN 'AZ46'
		WHEN stp.operation_id = 2003 THEN 'CORTE'
		WHEN stp.operation_id = 1995 THEN 'PEGADO'
	END,
	sq.production_prefix,
	stp.created_at_short

UNION ALL

SELECT cosl.cust_ord,
	s.name AS stage,
	sq.production_prefix,
	
	SUM(
		CASE
			WHEN pdsa.quantity_barrettes != 0 THEN pdsa.quantity_barrettes * ps.quantity
			ELSE ps.quantity
		END
	) AS quantity,
	
	CONVERT(date, ps.created_at) AS date
FROM source_atomic_sfc.production_scan AS ps
INNER JOIN source_atomic_sfc.scan_qr AS sq
ON ps.sfc_scan_qr_id = sq.id
INNER JOIN analysis.customer_order_style_layer AS cosl
ON sq.cust_ord_hdr_number = cosl.cust_ord
INNER JOIN source_atomic.stage AS s
ON ps.stage_id = s.id
LEFT JOIN (
	SELECT pds.style_id,
		pds.quantity_barrettes
	FROM dwh.pdm_style AS pds
	GROUP BY pds.style_id,
		pds.quantity_barrettes
) AS pdsa
ON sq.style_id = pdsa.style_id
WHERE ps.stage_id = 11
GROUP BY cosl.cust_ord,
	s.name,
	sq.production_prefix,
	CONVERT(date, ps.created_at)