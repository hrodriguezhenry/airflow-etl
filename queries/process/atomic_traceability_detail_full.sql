SELECT sq.id AS qr_id,
	CASE
		WHEN s.sfc_operation_id = 2133 THEN 'cut_route'
		WHEN s.sfc_operation_id IN (1496, 1497, 2052) THEN 'glue_route'
		WHEN s.sfc_operation_id = 1998 THEN 'az46_route'
		WHEN s.sfc_operation_id = 2000 THEN 'perforated_route'
		WHEN s.sfc_operation_id = 1996 THEN 'blurred_route'
		WHEN s.sfc_operation_id = 2062 THEN 'glue_booth_route'
		WHEN s.sfc_operation_id = 2064 THEN 'cut_booth_route'
		WHEN s.sfc_operation_id = 1884 THEN 'die_route'
		WHEN s.sfc_operation_id = 1885 THEN 'print_route'
		WHEN s.sfc_operation_id = 1893 THEN 'seam_route'
		WHEN s.sfc_operation_id = 684 THEN 'body_route'
		WHEN s.sfc_operation_id = 1765 THEN 'edges_route'
		WHEN s.sfc_operation_id = 1821 THEN 'assembly_route'
	END AS column_name,
	
	'Si' AS value
	
FROM source_atomic_sfc.style_route_production AS srp
INNER JOIN source_atomic_sfc.sam AS s
ON srp.sfc_sam_id = s.id
INNER JOIN source_atomic_sfc.scan_qr AS sq
ON srp.style_id = sq.style_id
AND sq.production_prefix = 'T'
WHERE s.sfc_operation_id IN (2133, 1496, 1497, 2052, 1998, 2000, 1996, 2062, 2064, 1884, 1885, 1893, 684, 1765, 1821)
AND EXISTS (
	SELECT 1
	FROM process.atomic_traceability_customer_orders AS atco
	WHERE atco.qr_id = sq.id
)

GROUP BY sq.id,
	s.sfc_operation_id

UNION ALL

SELECT cv.qr_id,
	CONCAT(cv.column_name, '_', cv.column_value) AS column_name,
	cv.value
	
FROM (
	SELECT stp.sfc_scan_qr_id AS qr_id,

		CASE
			WHEN stp.operation_id = 2133 THEN 'cut_dispatch'
			WHEN stp.operation_id = 2003 THEN 'cut_count'
			WHEN stp.operation_id IN (1496, 1497, 2052) THEN 'glue_dispatch'
			WHEN stp.operation_id = 1995 THEN 'glue_count'
			WHEN stp.operation_id = 1998 THEN 'az46_dispatch'
			WHEN stp.operation_id = 1999 THEN 'az46_count'
			WHEN stp.operation_id = 2000 THEN 'perforated_dispatch'
			WHEN stp.operation_id = 2001 THEN 'perforated_count'
			WHEN stp.operation_id = 1996 THEN 'blurred_dispatch'
			WHEN stp.operation_id = 1997 THEN 'blurred_count'
			WHEN stp.operation_id = 2062 THEN 'glue_booth_dispatch'
			WHEN stp.operation_id = 2063 THEN 'glue_booth_count'
			WHEN stp.operation_id = 2064 THEN 'cut_booth_dispatch'
			WHEN stp.operation_id = 2065 THEN 'cut_booth_count'
			WHEN stp.operation_id = 1884 THEN 'die_dispatch'
			WHEN stp.operation_id = 1890 THEN 'die_count'
			WHEN stp.operation_id = 1941 THEN 'print_reception'
			WHEN stp.operation_id = 1885 THEN 'print_dispatch'
			WHEN stp.operation_id = 1891 THEN 'print_count'
			WHEN stp.operation_id = 1902 THEN 'seam_reception'
			WHEN stp.operation_id = 1893 THEN 'seam_dispatch'
			WHEN stp.operation_id = 684 THEN 'body_end'
			WHEN stp.operation_id = 1879 THEN 'edges_reception'
			WHEN stp.operation_id = 1765 THEN 'edges_dispatch'
			WHEN stp.operation_id = 1892 THEN 'edges_count'
			WHEN stp.operation_id = 1880 THEN 'assembly_reception'
			WHEN stp.operation_id = 1821 THEN 'assembly_dispatch'
			WHEN stp.operation_id = 936 THEN 'assembly_square'
			WHEN stp.operation_id = 787 THEN 'assembly_packing'
		END AS column_name,
		
		CONVERT(VARCHAR(100), stp.created_at_short, 120) AS date,
		CONVERT(VARCHAR(100), STRING_AGG(CONCAT(e.cod_employee, ' - ' , e.first_name, ' ', e.first_last_name), ' ,')) AS employee_name
	
	FROM (
		SELECT stp.sfc_scan_qr_id AS qr_id,
			stp.operation_id,
			MAX(stp.id) AS id
		FROM source_atomic_sfc.scan_transact_production stp
		WHERE stp.operation_id IN (
			2133, 2003, 1496, 1497, 2052, 1995, 1998, 1999, 2000, 2001, 1996, 1997,
			2062, 2063, 2064, 2065, 1884, 1890, 1941, 1885, 1891, 1902, 1893, 684,
			1879, 1765, 1892, 1880, 1821, 936, 787
		)
		
		AND EXISTS (
			SELECT 1
			FROM process.atomic_traceability_customer_orders AS atco
			WHERE atco.qr_id = stp.sfc_scan_qr_id
		)
		
		GROUP BY stp.sfc_scan_qr_id,
			stp.operation_id
	) AS qoi
	
	INNER JOIN source_atomic_sfc.scan_transact_production AS stp
	ON qoi.id = stp.id
	LEFT JOIN source_atomic_sfc.group_mark_ref AS gmr
	ON stp.group_mark_id = gmr.group_mark_id
	LEFT JOIN source_atomic_sfc.mark AS m
	ON gmr.mark_id = m.id
	LEFT JOIN source_etalent.employee AS e
	ON m.cod_employee = e.cod_employee
	GROUP BY stp.sfc_scan_qr_id,
		stp.operation_id,
		CONVERT(VARCHAR(100), stp.created_at_short, 120)
) AS qqde

UNPIVOT (
	value FOR column_value IN (date, employee_name)
) AS cv

UNION ALL

SELECT cv.qr_id,
	CONCAT(cv.column_name, '_', cv.column_value) AS column_name,
	cv.value
	
FROM (
	SELECT ira.sfc_scan_qr_id AS qr_id,
		'body_inspection' AS column_name,
		CONVERT(VARCHAR(100), CONVERT(date, ira.created_at)) AS date,
		CONVERT(VARCHAR(100), CONCAT(ISNULL(ira.emp_cod, ''), ' - ', u.usr_name)) AS employee_name,
		CONVERT(VARCHAR(100), l.name) AS location
		
	FROM (
		SELECT ir.sfc_scan_qr_id AS qr_id,
			ist.stage_id,
			MAX(ir.id) AS id
		FROM source_atomic_qis.inspection_revision AS ir
		INNER JOIN source_atomic_qis.inspection_station AS ist
		ON ir.station_id = ist.id
		WHERE ist.stage_id = 4
		AND EXISTS (
			SELECT 1
			FROM process.atomic_traceability_customer_orders AS atco
			WHERE atco.qr_id = ir.sfc_scan_qr_id 
		)
			GROUP BY ir.sfc_scan_qr_id,
			ist.stage_id
	) AS qsi
	INNER JOIN source_atomic_qis.inspection_revision AS ira
	ON qsi.id = ira.id
	INNER JOIN source_atomic_qis.inspection_station AS ista
	ON ira.station_id = ista.id
	INNER JOIN source_atomic.line AS l
	ON ista.atomic_line_id = l.id
	INNER JOIN source_proaktiv.users AS u
	ON ira.created_by = u.usr_number
) AS qcdel

UNPIVOT (
	value FOR column_value IN (date, employee_name, location)
) AS cv

UNION ALL

SELECT cv.qr_id,
	CONCAT(cv.column_name, '_', cv.column_value) AS column_name,
	cv.value

FROM (
	SELECT stpa.sfc_scan_qr_id AS qr_id,
	
		CASE
			WHEN stpa.stage_id = 3 THEN 'glue'
			WHEN stpa.stage_id = 50 THEN 'az46'
			WHEN stpa.stage_id = 58 THEN 'perforated'
			WHEN stpa.stage_id = 25 THEN 'blurred'
			WHEN stpa.stage_id = 44 THEN 'die'
			WHEN stpa.stage_id = 46 THEN 'print'
			WHEN stpa.stage_id =  5 THEN 'seam'
			WHEN stpa.stage_id =  7 THEN 'edges'
			WHEN stpa.stage_id =  6 THEN 'assembly'
		END AS column_name,
		
		CONVERT(VARCHAR(100), stpa.created_at_short, 120) AS operation_date,
		CONVERT(VARCHAR(100), op.operation) AS operation,
		CONVERT(VARCHAR(100), IIF(stpa.stage_id IN (44, 46), ma.name, l.name)) AS location,
		CONVERT(VARCHAR(100), STRING_AGG(CONCAT(e.cod_employee, ' - ' , e.first_name, ' ', e.first_last_name), ' ,')) AS operation_employee_name
		
	FROM (
		SELECT stp.sfc_scan_qr_id AS qr_id,
			IIF(stp.stage_id IN (6, 19, 23), 6, stp.stage_id) AS stage_id,
			MAX(stp.id) AS id
		FROM source_atomic_sfc.scan_transact_production stp
		WHERE stp.stage_id IN (3, 50, 58, 25, 44, 46, 5, 7, 6, 19, 23)
		AND EXISTS (
			SELECT 1
			FROM process.atomic_traceability_customer_orders AS atco
			WHERE atco.qr_id = stp.sfc_scan_qr_id 
		)
		GROUP BY stp.sfc_scan_qr_id,
			IIF(stp.stage_id IN (6, 19, 23), 6, stp.stage_id)
	) AS qi
	
	INNER JOIN source_atomic_sfc.scan_transact_production stpa
	ON stpa.id = qi.id
	INNER JOIN source_atomic_sfc.group_mark_ref AS gmr
	ON stpa.group_mark_id = gmr.group_mark_id
	INNER JOIN source_atomic_sfc.mark AS m
	ON gmr.mark_id = m.id
	INNER JOIN source_atomic_sfc.operation_production AS op
	ON stpa.operation_id = op.id
	INNER JOIN source_atomic.line AS l
	ON stpa.line_id = l.id
	LEFT JOIN source_atomic_sfc.machine AS ma
	ON stpa.machine_id = ma.id
	LEFT JOIN source_etalent.employee AS e
	ON m.cod_employee = e.cod_employee
	GROUP BY stpa.sfc_scan_qr_id,
		stpa.stage_id,
		CONVERT(VARCHAR(100), stpa.created_at_short, 120),
		CONVERT(VARCHAR(100), op.operation),
		CONVERT(VARCHAR(100), IIF(stpa.stage_id IN (44, 46), ma.name, l.name))
) AS qcole

UNPIVOT (
	value FOR column_value IN (operation_date, operation, location, operation_employee_name)
) AS cv