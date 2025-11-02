-- PROCESS_ATOMIC_QIS_INSPECTIONS
-- Update 2025-06-27

-- Consulta que me trae todas las inspecciones de calidad, con la cantidad
-- de unidades rechazadas y los defectos asignados.
SELECT ir.id AS revision_id,
	ir.sfc_scan_qr_id AS qr_id,
	CONVERT(date, ir.last_close_at) AS inspection_date,
	CONVERT(time, ir.last_close_at) AS inspection_time,
	ir.station_id,
	ist.name as station,
	ist.atomic_line_id,
	ist.atomic_stage_id,
	ir.created_by AS inspector_user_number,
	ir.no AS inspection_number,
	ir.bundle_qty,
	
	CASE
		WHEN cid.cnt_distribution IS NOT NULL THEN
			(CONVERT(DECIMAL (12, 6), ir.bundle_qty) / 
			cid.cnt_distribution) /
			cidd.cnt_defect
		ELSE ir.bundle_qty
	END AS inspected_qty,
				
	ir.result,
	id.id AS distribution_id,
	
	ISNULL(CONVERT(DECIMAL (12, 6), id.qty_units) / cidd.cnt_defect, 0) AS rejected_qty,
		
	ISNULL(CONVERT(DECIMAL (12, 6), id.qty_units), 0) AS defect_qty,
	idd.id AS distribution_defect_id,
	idd.defect_id,
	ide.name AS defect,
	ide.reprocess,
	s.id AS defect_stage_id,
	s.name AS defect_stage_name,
	
	ir.last_close_at
FROM source_atomic_qis.inspection_revision AS ir

INNER JOIN source_atomic_qis.inspection_station AS ist
ON ir.station_id = ist.id
LEFT JOIN  source_atomic_qis.inspection_distribution AS id
ON ir.id = id.revision_id

-- Consulta "cid" que me trae el número de distribuciones de defectos
-- encontrados en una revisión
LEFT JOIN  (
	SELECT ida.revision_id,
		COUNT(ida.revision_id) AS cnt_distribution
	FROM source_atomic_qis.inspection_distribution AS ida
	GROUP BY ida.revision_id
) AS cid
ON id.revision_id = cid.revision_id

LEFT JOIN source_atomic_qis.inspection_distribution_defect AS idd
ON id.id = idd.distribution_id

-- Consulta "cidd" que me trae la cantidad de defectos asignados
-- asignados a una distribución
LEFT JOIN  (
	SELECT idda.distribution_id,
		COUNT(idda.distribution_id) AS cnt_defect
	FROM source_atomic_qis.inspection_distribution_defect AS idda
	GROUP BY idda.distribution_id
) AS cidd
ON idd.distribution_id = cidd.distribution_id

LEFT JOIN source_atomic_qis.inspection_defect AS ide
ON idd.defect_id = ide.id
LEFT JOIN source_atomic.stage AS s
ON ide.atomic_stage_id = s.id

WHERE ir.sfc_scan_qr_id IS NOT NULL