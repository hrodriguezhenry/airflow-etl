-- PROCESS_INSPECTIONS_TRANSACT_DETAIL
-- Update 2024-09-25

-- Consulta que me trae todas las inspecciones de calidad realizadas por
-- cada bulto escaneado en producción, con la cantidad de unidades rechazadas
-- y los defectos asignados.
SELECT ssdb.inspection_year,
	ssdb.inspection_week,
	ssdb.inspection_date,
	ssdb.scan_transact_id,
	ssdb.qr_id,
	ssdb.full_inspection,
	ISNULL(ssdc.first_inspection, 0) AS first_inspection,
	ISNULL(sdro.rejected_qty, 0) AS rejected_qty,
	ISNULL(sdwo.waste_qty, 0) AS waste_qty,
	ssdb.last_day_of_week

-- Consulta "ssdb" que me trae todas las inspecciones realizadas por 
-- bulto donde se toma en cuenta todos los marcajes de producción 
-- realizados antes de que se realice una inspección distinta por fecha.
FROM process.atomic_inspections_transact AS ssdb

-- Consulta "ssdc" que me trae las primeras inspecciones realizadas 
-- por bulto donde se toma en cuenta todos los marcajes de producción 
-- realizados antes de que se realice una insepcción distinta por fecha.
LEFT JOIN (
	SELECT DISTINCT CONVERT(date, ir.last_close_at) AS inspection_date,
		stpb.id AS scan_transact_id,
		ir.sfc_scan_qr_id AS qr_id,
		stpb.quantity AS first_inspection
	FROM source_atomic_qis.inspection_revision AS ir
	INNER JOIN source_atomic_sfc.scan_transact_production AS stpb
	ON ir.sfc_scan_qr_id = stpb.sfc_scan_qr_id
	AND ir.last_close_at >= stpb.created_at
	AND ir.no = 1
) AS ssdc
ON ssdb.inspection_date = ssdc.inspection_date
AND ssdb.scan_transact_id = ssdc.scan_transact_id

-- Consulta "sdro" que me trae la cantidad de unidades rechazadas
-- asignadas a un id de transacción.
LEFT JOIN (
	SELECT CONVERT(date, ir.last_close_at) AS inspection_date,
		igmd.scan_transact_id,
		SUM(id.qty_units) AS rejected_qty
	FROM source_atomic_qis.inspection_revision AS ir
	INNER JOIN source_atomic_qis.inspection_distribution AS id
	ON ir.id = id.revision_id
	INNER JOIN source_atomic_qis.inspection_distribution_defect AS idd
	ON id.id = idd.distribution_id
	INNER JOIN source_atomic_qis.inspection_group_mark_defect AS igmd
	ON idd.id = igmd.distribution_defect_id
	WHERE ir.no = 1
	GROUP BY CONVERT(date, ir.last_close_at),
		igmd.scan_transact_id
) AS sdro
ON ssdb.inspection_date = sdro.inspection_date
AND ssdb.scan_transact_id = sdro.scan_transact_id	

-- Consulta "sdwo" que me trae la cantidad de unidades desperdiciadas
-- asignadas a un id de transacción.
LEFT JOIN (
	SELECT CONVERT(date, ir.last_close_at) AS inspection_date,
		igmd.scan_transact_id,
		SUM(id.qty_units) AS waste_qty
	FROM source_atomic_qis.inspection_revision AS ir
	INNER JOIN source_atomic_qis.inspection_distribution AS id
	ON ir.id = id.revision_id
	INNER JOIN source_atomic_qis.inspection_distribution_defect AS idd
	ON id.id = idd.distribution_id
	INNER JOIN source_atomic_qis.inspection_group_mark_defect AS igmd
	ON idd.id = igmd.distribution_defect_id
	WHERE ir.no = 2
	GROUP BY CONVERT(date, ir.last_close_at),
		igmd.scan_transact_id
) AS sdwo
ON ssdb.inspection_date = sdwo.inspection_date
AND ssdb.scan_transact_id = sdwo.scan_transact_id