SELECT w.year,
	w.week,
	w.day AS date,
	sq.cust_ord_hdr_number AS cust_ord,
	cod.stl_number AS style_id,
	sq.id AS qr_id,
	s.name AS stage,
	ps.line_id,
	l.name AS line,
	sd.sz_dim_det_size AS size,
	
	CASE
		WHEN ps.stage_id = 11 AND pdsa.quantity_barrettes != 0 THEN  pdsa.quantity_barrettes * ps.quantity
		ELSE ps.quantity
	END AS quantity,
	
	ps.created_at AS scan_date
FROM source_atomic_sfc.production_scan AS ps
INNER JOIN source_atomic_sfc.scan_qr AS sq
ON ps.sfc_scan_qr_id = sq.id
INNER JOIN source_atomic_sfc.scan_qr_detail AS sqd
ON sq.id = sqd.scan_qr_id
INNER JOIN source_atomic_sfc.size_detail AS sd
ON sqd.sz_dim_det_number = sd.sz_dim_det_number
INNER JOIN source_proaktiv.cust_ord_detail AS cod
ON sq.cust_ord_hdr_number = cod.cust_ord_hdr_number
AND sqd.sz_dim_det_number = cod.sz_dim_det_number
INNER JOIN source_atomic.stage AS s
ON ps.stage_id = s.id
INNER JOIN source_atomic.line AS l
ON ps.line_id = l.id
INNER JOIN source_accesorios.weeks AS w
ON CONVERT(date, ps.created_at) = w.day

LEFT JOIN (
	SELECT pds.style_id,
		pds.quantity_barrettes
	FROM dwh.pdm_style AS pds
	GROUP BY pds.style_id,
		pds.quantity_barrettes
) AS pdsa
ON sq.style_id = pdsa.style_id

WHERE CASE
		WHEN ps.stage_id = 2 AND ps.scan_type = 1 THEN 'N'
		ELSE 'Y'
	END ='Y'

UNION ALL

SELECT w.year,
	w.week,
	w.day AS date,
	sq.cust_ord_hdr_number AS cust_ord,
	cod.stl_number AS style_id,
	sq.id AS qr_id,
	m.name AS stage,
	ISNULL(pa.line_id, qrl.line_id) AS line_id,
	ISNULL(la.name, l.name) AS line,
	sd.sz_dim_det_size AS size,
	pa.quantity,
	ISNULL(pa.date_scan, pa.date_after_stage) AS scan_date
FROM source_atomic_sfc.production_advance AS pa
INNER JOIN source_atomic_sfc.scan_qr AS sq
ON pa.sfc_scan_qr_id = sq.id
INNER JOIN source_atomic_sfc.scan_qr_detail AS sqd
ON sq.id = sqd.scan_qr_id
INNER JOIN source_atomic_sfc.size_detail AS sd
ON sqd.sz_dim_det_number = sd.sz_dim_det_number
INNER JOIN source_proaktiv.cust_ord_detail AS cod
ON sq.cust_ord_hdr_number = cod.cust_ord_hdr_number
AND sqd.sz_dim_det_number = cod.sz_dim_det_number
INNER JOIN source_atomic_sfc.microzone AS m
ON pa.microzone_id = m.id

LEFT JOIN (
	SELECT stp.sfc_scan_qr_id,
		MAX(stp.line_id) AS line_id
	FROM source_atomic_sfc.scan_transact_production AS stp
	WHERE stp.stage_id = 7
	AND stp.operation_id = 416
	AND stp.line_id <> 130
	GROUP BY stp.sfc_scan_qr_id
) AS qrl
ON pa.sfc_scan_qr_id = qrl.sfc_scan_qr_id
AND pa.microzone_id = 8

LEFT JOIN source_atomic.line AS l
ON qrl.line_id = l.id
LEFT JOIN source_atomic.line AS la
ON pa.line_id = la.id
INNER JOIN source_accesorios.weeks AS w
ON CONVERT(date, ISNULL(pa.date_scan, pa.date_after_stage)) = w.day
WHERE pa.microzone_id IN (8)

UNION ALL

SELECT w.year,
	w.week,
	w.day AS date,
	fohd.cust_ord_hdr_number AS cust_ord,
	fohd.stl_number AS style_id,
	NULL AS qr_id,
	'EMPAQUE' AS stage,
	fohd.line_number AS line_id,
	pl.line_desc AS line,
	sdd.sz_dim_det_size AS size,
	SUM(fohd.fgi_qty) AS quantity,
	MAX(fgi_production_date) AS scan_date
FROM source_proaktiv.fgi_output_hour_detail AS fohd
INNER JOIN source_proaktiv.prod_lines AS pl
ON fohd.line_number = pl.line_number
INNER JOIN source_proaktiv.sz_dim_detail AS sdd
ON fohd.sz_dim_det_number = sdd.sz_dim_det_number
INNER JOIN source_accesorios.weeks AS w
ON CONVERT(date, fohd.fgi_production_date) = w.day
GROUP BY w.year,
	w.week,
	w.day,
	fohd.cust_ord_hdr_number,
	fohd.stl_number,
	fohd.line_number,
	pl.line_desc,
	sdd.sz_dim_det_size