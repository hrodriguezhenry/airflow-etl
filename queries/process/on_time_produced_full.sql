SELECT sq.cust_ord_hdr_number AS cust_ord,
	w.day AS scan_date,
	w.week AS scan_week,
	s.name AS stage,
	
	SUM(
		IIF(ps.stage_id = 11 AND sqb.quantity_barrettes > 0, sqb.quantity_barrettes * ps.quantity, ps.quantity)
	) AS produced_quantity,
	
	SUM(
		IIF(ps.stage_id = 11 AND sqb.quantity_barrettes > 0, sqb.quantity_barrettes * ISNULL(sqd.quantity_original, ps.quantity), ISNULL(sqd.quantity_original, ps.quantity))
	) AS produced_quantity_original
	
FROM source_atomic_sfc.production_scan AS ps
INNER JOIN source_atomic_sfc.scan_qr AS sq
ON ps.sfc_scan_qr_id = sq.id
INNER JOIN source_atomic_sfc.scan_qr_detail AS sqd
ON sq.id = sqd.scan_qr_id
INNER JOIN source_atomic.stage AS s
ON ps.stage_id = s.id
LEFT JOIN (
	SELECT pst.style_id,
		pst.quantity_barrettes
	FROM dwh.pdm_style AS pst
	GROUP BY pst.style_id,
		pst.quantity_barrettes
) AS sqb
ON sq.style_id = sqb.style_id
INNER JOIN source_accesorios.weeks AS w
ON CONVERT(date, ps.created_at) = w.day
WHERE CASE
		WHEN ps.stage_id IN (11) AND ps.scan_type = 1 THEN 'Y'
		WHEN ps.stage_id IN  (2) AND ps.scan_type = 2 THEN 'Y'
		ELSE 'N'
	END = 'Y'
AND ps.line_id NOT IN (1, 2, 3, 4)
AND sq.stage_id != 45
GROUP BY sq.cust_ord_hdr_number,
	w.day,
	w.week,
	s.name

UNION ALL

SELECT sq.cust_ord_hdr_number AS cust_ord,
	w.day AS scan_date,
	w.week AS scan_week,
	
	CASE
		WHEN stp.operation_id = 1890 THEN 'TROQUEL'
		WHEN stp.operation_id = 1891 THEN 'ESTAMPADO'
		WHEN stp.operation_id = 1879 THEN 'CUERPOS'
		WHEN stp.operation_id = 684 THEN 'COSTURA'
		WHEN stp.operation_id = 1892 THEN 'CANTOS'
		WHEN stp.operation_id = 787 THEN 'ENSAMBLE'
		WHEN stp.operation_id = 1999 THEN 'AZ46'
		WHEN stp.operation_id = 1649 THEN 'SETS'
		WHEN stp.operation_id = 2001 THEN 'PERFORADO'
		WHEN stp.operation_id = 1997 THEN 'ESFUMADO'
		WHEN stp.operation_id = 2123 THEN 'PREENTINTADO'
		WHEN stp.operation_id = 2108 THEN 'TROQUEL SETS'
		WHEN stp.operation_id = 2003 THEN 'CORTE'
		WHEN stp.operation_id = 1995 THEN 'PEGADO'
	END AS stage,

	SUM(
		CASE
			WHEN stp.operation_id = 1890 THEN ISNULL(sqd.quantity_original, stp.quantity)
			WHEN stp.operation_id = 1891 THEN ISNULL(sqd.quantity_original, stp.quantity)
			WHEN stp.operation_id = 1879 THEN ISNULL(sqd.quantity_original, stp.quantity)
			WHEN stp.operation_id = 684 THEN ISNULL(sqd.quantity_original, stp.quantity)
			WHEN stp.operation_id = 1892 THEN ISNULL(sqd.quantity_original, stp.quantity)
			WHEN stp.operation_id = 787 THEN ISNULL(sqd.quantity_original, stp.quantity)
			WHEN stp.operation_id = 1999 THEN stp.quantity
			WHEN stp.operation_id = 1649 THEN ISNULL(sqd.quantity_original, stp.quantity)
			WHEN stp.operation_id = 2001 THEN stp.quantity
			WHEN stp.operation_id = 1997 THEN stp.quantity
			WHEN stp.operation_id = 2123 THEN ISNULL(sqd.quantity_original, stp.quantity)
			WHEN stp.operation_id = 2108 THEN stp.quantity
			WHEN stp.operation_id = 2003 THEN stp.quantity
			WHEN stp.operation_id = 1995 THEN stp.quantity
		END
	) AS produced_quantity,

	SUM(ISNULL(sqd.quantity_original, stp.quantity)) AS produced_quantity_original
FROM source_atomic_sfc.scan_transact_production AS stp
INNER JOIN source_atomic_sfc.scan_qr AS sq
ON stp.sfc_scan_qr_id = sq.id
INNER JOIN source_atomic_sfc.scan_qr_detail AS sqd
ON sq.id = sqd.scan_qr_id
INNER JOIN source_accesorios.weeks AS w
ON stp.created_at_short = w.day
WHERE stp.operation_id IN(1890, 1891, 1879, 684, 1892, 787, 1999, 1649, 2001, 1997, 2123, 2108, 1995, 2003)
AND sq.stage_id != 45
GROUP BY sq.cust_ord_hdr_number,
	w.day,
	w.week,
	
	CASE
		WHEN stp.operation_id = 1890 THEN 'TROQUEL'
		WHEN stp.operation_id = 1891 THEN 'ESTAMPADO'
		WHEN stp.operation_id = 1879 THEN 'CUERPOS'
		WHEN stp.operation_id = 684 THEN 'COSTURA'
		WHEN stp.operation_id = 1892 THEN 'CANTOS'
		WHEN stp.operation_id = 787 THEN 'ENSAMBLE'
		WHEN stp.operation_id = 1999 THEN 'AZ46'
		WHEN stp.operation_id = 1649 THEN 'SETS'
		WHEN stp.operation_id = 2001 THEN 'PERFORADO'
		WHEN stp.operation_id = 1997 THEN 'ESFUMADO'
		WHEN stp.operation_id = 2123 THEN 'PREENTINTADO'
		WHEN stp.operation_id = 2108 THEN 'TROQUEL SETS'
		WHEN stp.operation_id = 2003 THEN 'CORTE'
		WHEN stp.operation_id = 1995 THEN 'PEGADO'
	END