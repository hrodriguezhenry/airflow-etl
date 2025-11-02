-- PROCESS_VARIABILITY
-- Update 2024-03-13

-- Consulta que me trae la cantidd de unidades producidas
-- en el sistema contable de atomic.
SELECT w.year,
	w.week,
	w.first_day_of_week,
	sq.cust_ord_hdr_number AS cust_ord,
	
	CASE
		WHEN s.name = 'CUERPOS' THEN 'COSTURA'
		ELSE s.name 
	END AS stage,
	
	SUM(ps.quantity) AS produced_quantity
FROM source_atomic_sfc.production_scan AS ps
INNER JOIN source_atomic_sfc.scan_qr AS sq
ON ps.sfc_scan_qr_id = sq.id
INNER JOIN source_atomic.stage AS s
ON ps.stage_id = s.id
INNER JOIN source_accesorios.weeks AS w
ON CONVERT(date, ps.created_at) = w.day
WHERE 
	CASE 
		WHEN ps.scan_type = 2 AND ps.stage_id = 2 THEN 'Y'
		WHEN ps.scan_type = 2 AND ps.stage_id = 3 THEN 'Y'
		WHEN ps.scan_type = 1 AND ps.stage_id = 4 THEN 'Y'
		WHEN ps.scan_type = 1 AND ps.stage_id = 11 THEN 'Y'
	END = 'Y'
AND w.day < CONVERT(date, GETDATE())
AND w.first_day_of_week >= CONVERT(date, GETDATE() -14)
GROUP BY w.year,
	w.week,
	w.first_day_of_week,
	sq.cust_ord_hdr_number,
	
	CASE
		WHEN s.name = 'CUERPOS' THEN 'COSTURA'
		ELSE s.name 
	END

UNION ALL

-- Consulta que me trae la cantidd de unidades producidas
-- en los grupos de operación de ingeniería.
SELECT w.year,
	w.week,
	w.first_day_of_week,
	sq.cust_ord_hdr_number,
	'TROQUEL' AS stage,
	SUM(apqge.group_close_quantity) AS produced_quantity
FROM process.atomic_production_qr_group_engineer AS apqge
INNER JOIN source_atomic_sfc.scan_qr AS sq
ON apqge.qr_id = sq.id
INNER JOIN source_accesorios.weeks AS w
ON CONVERT(date, apqge.group_close_date) = w.day
WHERE apqge.group_operation_id = 85
AND w.day < CONVERT(date, GETDATE())
AND w.first_day_of_week >= CONVERT(date, GETDATE() -14)
GROUP BY w.year,
	w.week,
	w.first_day_of_week,
	sq.cust_ord_hdr_number

UNION ALL

-- Consulta que me trae la cantidd de unidades producidas
-- en la etapa de empaque.
SELECT w.year,
	w.week,
	w.first_day_of_week,
	foh.cust_ord_hdr_number AS cust_ord,
	'EMPAQUE' AS stage,
	SUM(foh.fgi_qty) AS produced_quantity
FROM source_proaktiv.fgi_output_hour AS foh
INNER JOIN source_accesorios.weeks AS w
ON CONVERT(date, foh.fgi_production_date) = w.day
WHERE w.day < CONVERT(date, GETDATE())
AND w.first_day_of_week >= CONVERT(date, GETDATE() -14)
GROUP BY w.year,
	w.week,
	w.first_day_of_week,
	foh.cust_ord_hdr_number

UNION ALL

-- Consulta que me trae la cantidd de unidades producidas
-- en la etapa de ensamble.
SELECT w.year,
	w.week,
	w.first_day_of_week,
	sq.cust_ord_hdr_number AS cust_ord,
	'ENSAMBLE' AS stage,
	SUM(stpa.quantity) AS produced_quantity
FROM source_atomic_sfc.scan_transact_production AS stpa
INNER JOIN source_atomic_sfc.scan_qr AS sq
ON stpa.sfc_scan_qr_id = sq.id
AND stpa.operation_id = 787
LEFT JOIN source_atomic_sfc.scan_transact_production AS stpb
ON stpa.sfc_scan_qr_id = stpb.sfc_scan_qr_id
AND stpb.operation_id = 936
INNER JOIN source_accesorios.weeks AS w
ON stpa.created_at_short = w.day
WHERE w.day < CONVERT(date, GETDATE())
AND w.first_day_of_week >= CONVERT(date, GETDATE() -14)
GROUP BY w.year,
	w.week,
	w.first_day_of_week,
	sq.cust_ord_hdr_number