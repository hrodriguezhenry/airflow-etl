-- DWH_ATOMIC_QIS_INSPECTIONS
-- Update 2025-06-27

-- Consulta que me trae todas las inspecciones de calidad, donde los defectos
-- encotrodos tienen al empleado responsable
SELECT w.year AS inspection_year,
    w.week AS inspection_week,
	aqi.inspection_date,
	aqi.inspection_time,
    aqi.revision_id,
	aqi.qr_id,
	sq.cust_ord_hdr_number AS cust_ord,
	aqi.bundle_qty,
	aqi.station_id,
	aqi.station,
	aqi.atomic_stage_id AS inspection_stage_id,
	s.name AS inspection_stage,
	aqi.atomic_line_id AS inspection_line_id,
	l.name AS inspection_line,
	aqi.inspector_user_number,
	u.usr_name AS inspector_username,
	aqi.inspection_number,
	
	CASE
		WHEN stp.quantity_checkin IS NOT NULL THEN
			CONVERT(DECIMAL (12, 6), (aqi.inspected_qty / cigmd.cnt_df / stp.quantity_checkin))
		ELSE CONVERT(DECIMAL (12, 6), aqi.inspected_qty)
	END AS inspected_qty,
	
	aqi.result,
	aqi.distribution_id,
	
	CASE
		WHEN stp.quantity_checkin IS NOT NULL THEN
			CONVERT(DECIMAL (12, 6), (aqi.rejected_qty / cigmd.cnt_df / stp.quantity_checkin))
		ELSE CONVERT(DECIMAL (12, 6), aqi.rejected_qty)
	END AS rejected_qty,
	
	CASE
		WHEN stp.quantity_checkin IS NOT NULL THEN
			CONVERT(DECIMAL (12, 6), (aqi.defect_qty / cigmd.cnt_df /
			stp.quantity_checkin))
		ELSE CONVERT(DECIMAL (12, 6), aqi.defect_qty)
	END AS defect_qty,
	
	aqi.distribution_defect_id,
	aqi.defect_id,
	aqi.defect,
	aqi.reprocess,
	aqi.defect_stage_id,
	aqi.defect_stage_name,
	stp.group_mark_id,
	
	ISNULL(stp.stage_id, aqi.atomic_stage_id) AS stage_id,
	ISNULL(sa.name, s.name) AS stage,
	ISNULL(stp.line_id, aqi.atomic_line_id) AS line_id,
	ISNULL(la.name, l.name) AS line,
	stp.operation_id,
	op.operation,
	stp.mark_type,
	stp.quantity_checkin,
	gmr.mark_id,
	
	aqi.defect_qty AS defect_qty_employee,
	
	CASE
		WHEN stp.quantity_checkin IS NULL THEN aqi.defect_qty
		ELSE CONVERT(DECIMAL (12, 6), (aqi.defect_qty / stp.quantity_checkin))
	END AS defect_qty_operation,

	m.cod_employee,
	CONCAT(e.first_name, ' ', e.first_last_name) AS employee_name

FROM process.atomic_qis_inspections AS aqi
INNER JOIN source_atomic_sfc.scan_qr AS sq
ON aqi.qr_id = sq.id
LEFT JOIN source_atomic.stage AS s
ON aqi.atomic_stage_id = s.id
LEFT JOIN source_atomic.line AS l
ON aqi.atomic_line_id = l.id
INNER JOIN source_proaktiv.users AS u
ON aqi.inspector_user_number = u.usr_number
INNER JOIN source_accesorios.weeks AS w
ON aqi.inspection_date = w.day
LEFT JOIN source_atomic_qis.inspection_group_mark_defect AS igmd
ON aqi.distribution_defect_id = igmd.distribution_defect_id

-- Consulta que me trae la cantidad de marcas asignados
-- a una misma distribución de defectos
LEFT JOIN (
	SELECT igmda.distribution_defect_id,
		COUNT(igmda.distribution_defect_id) AS cnt_df
	FROM source_atomic_qis.inspection_group_mark_defect AS igmda
	GROUP BY igmda.distribution_defect_id
) AS cigmd
ON aqi.distribution_defect_id = cigmd.distribution_defect_id

LEFT JOIN source_atomic_sfc.scan_transact_production AS stp
ON igmd.scan_transact_id = stp.id
AND aqi.last_close_at >= stp.created_at
LEFT JOIN source_atomic.stage AS sa
ON stp.stage_id = sa.id
LEFT JOIN source_atomic.line AS la
ON stp.line_id = la.id
LEFT JOIN source_atomic_sfc.operation_production AS op
ON stp.operation_id = op.id
LEFT JOIN source_atomic_sfc.group_mark_ref AS gmr
ON stp.group_mark_id = gmr.group_mark_id
LEFT JOIN source_atomic_sfc.mark AS m
ON gmr.mark_id = m.id
LEFT JOIN source_etalent.employee AS e
ON m.cod_employee = e.cod_employee