-- DWH_INSPECTIONS_EFFICIENCY
-- Update 2022-12-08

-- Consulta que me trae la efficiencia e inspecciones por empleado, operación,
-- etapa y línea, donde me trae la cantidad de unidades rechazadas y desperdiciadas.
SELECT *
FROM (
	-- DWH_EFFICIENCY
	-- Update 2023-02-02

	-- Consulta que me trae la efficiencia e inspecciones por empleado, operación,
	-- etapa y línea, donde me trae la cantidad de unidades rechazadas y desperdiciadas.
	SELECT ISNULL(ece.production_year, aic.inspection_year) AS "year",
			ISNULL(ece.production_week, aic.inspection_week) AS week,
			ISNULL(ece.production_date, aic.inspection_date) AS date,
			ISNULL(ece.cod_employee, aic.cod_employee) AS cod_employee,
			efe.name AS employee_name,
			efe.position,
			efe.cost_center,
			efe.cost_center_description,
			ISNULL(ece.operation_id, aic.operation_id) AS operation_id,
			ISNULL(op.operation, orm.operation) AS operation,
			ISNULL(op.max_rejection, orm.max_rejection) AS max_rejection,
			ISNULL(op.max_defect, orm.max_defect) AS max_defect,
			ISNULL(ece.stage_id, aic.stage_id) AS stage_id,
			s.name AS stage,
			ISNULL(ece.line_id, aic.line_id) AS line_id,
			l.name AS line,
			ISNULL(ece.employee_qty, 0) AS employee_qty,
			ISNULL(ece.operation_qty, 0) AS operation_qty,
			ISNULL(ece.time_worked, 0)AS time_worked,
			ISNULL(ece.time_out, 0) AS time_out,
			ISNULL(ece.time_lunch, 0) AS time_lunch,
			ISNULL(ece.time_event, 0) AS time_event,
			ISNULL(ece.time_featured, 0) AS time_featured,
			ISNULL(ece.time_off_standard, 0) AS time_off_standard,
			ISNULL(ece.time_with_worked, 0) AS time_with_worked,
			ISNULL(aic.daily_qty_full_inspections_employee, 0) AS daily_qty_full_inspections_employee,
			ISNULL(aic.daily_qty_first_inspections_employee, 0) AS daily_qty_first_inspections_employee,
			ISNULL(aic.weekly_qty_full_inspections_employee, 0) AS weekly_qty_full_inspections_employee,
			ISNULL(aic.weekly_qty_first_inspections_employee, 0) AS weekly_qty_first_inspections_employee,
			ISNULL(aic.rejected_qty_employee, 0) AS rejected_qty_employee,
			ISNULL(aic.waste_qty_employee, 0) AS waste_qty_employee,
			ISNULL(aic.daily_qty_full_inspections_operation, 0) AS daily_qty_full_inspections_operation,
			ISNULL(aic.daily_qty_first_inspections_operation, 0) AS daily_qty_first_inspections_operation,
			ISNULL(aic.weekly_qty_full_inspections_operation, 0) AS weekly_qty_full_inspections_operation,
			ISNULL(aic.weekly_qty_first_inspections_operation, 0) AS weekly_qty_first_inspections_operation,
			ISNULL(aic.rejected_qty_operation, 0) AS rejected_qty_operation,
			ISNULL(aic.waste_qty_operation, 0) AS waste_qty_operation,
			ISNULL(aic.daily_qty_full_inspections_line, 0) AS daily_qty_full_inspections_line,
			ISNULL(aic.daily_qty_first_inspections_line, 0) AS daily_qty_first_inspections_line,
			ISNULL(aic.weekly_qty_full_inspections_line, 0) AS weekly_qty_full_inspections_line,
			ISNULL(aic.weekly_qty_first_inspections_line, 0) AS weekly_qty_first_inspections_line,
			ISNULL(aic.daily_qty_full_inspections_stage, 0) AS daily_qty_full_inspections_stage,
			ISNULL(aic.daily_qty_first_inspections_stage, 0) AS daily_qty_first_inspections_stage,
			ISNULL(aic.weekly_qty_full_inspections_stage, 0) AS weekly_qty_full_inspections_stage,
			ISNULL(aic.weekly_qty_first_inspections_stage, 0) AS weekly_qty_first_inspections_stage

	-- Consulta que me trae por operario la cantidad que produjo, la cantidad producida por operación,
	-- y los tiempos que relizo de cada evento para su eficiencia
	FROM (
		SELECT w.year AS production_year,
			w.week AS production_week,
			CONVERT(date, ec.check_in) AS production_date,
			ec.cod_employee,
			ec.operation_id,
			ec.stage_id,
			ec.line_id,
			SUM(ec.quantity) AS employee_qty,
			SUM(ISNULL(mqo.operation_qty, 0)) AS operation_qty,
			SUM(ec.time_worked) AS time_worked,
			SUM(ec.time_out) AS time_out,
			SUM(ec.time_lunch) AS time_lunch,
			SUM(ec.time_event) AS time_event,
			SUM(ec.time_featured) AS time_featured,
			SUM(ec.time_off_standard) AS time_off_standard,
			SUM(ec.time_with_worked) AS time_with_worked
		FROM source_atomic_sfc.efficiency_consolidated AS ec
		
		LEFT JOIN (
			-- Consulta que me trae las unidades escaneadas por operación prorrateadas a nivel empleado
			SELECT gmr.mark_id,
				SUM(gqq.bundle_qty / IIF(gqq.quantity_checkin = 0, 1, gqq.quantity_checkin)) AS operation_qty
			FROM (
				-- Consulta gqq que me trae la cantidad de unidades escaneadas por grupo
				SELECT stp.group_mark_id,
					stp.quantity_checkin,
					SUM(stp.quantity) AS bundle_qty
				FROM source_atomic_sfc.scan_transact_production AS stp
				GROUP BY stp.group_mark_id,
					stp.quantity_checkin
			) AS gqq
			
			INNER JOIN source_atomic_sfc.group_mark_ref AS gmr
			ON gqq.group_mark_id = gmr.group_mark_id
			
			GROUP BY gmr.mark_id
		) AS mqo
		ON ec.mark_id = mqo.mark_id
		
		INNER JOIN source_accesorios.weeks w
		ON CONVERT(date, ec.check_in) = w.day

		GROUP BY w.year,
			w.week,
			CONVERT(date, ec.check_in),
			ec.cod_employee,
			ec.operation_id,
			ec.stage_id,
			ec.line_id
	) AS ece

	FULL OUTER JOIN process.atomic_inspections_consolidated AS aic	
	ON ece.production_date = aic.inspection_date
	AND ece.cod_employee = aic.cod_employee
	AND ece.stage_id = aic.stage_id
	AND ece.line_id = aic.line_id
	AND ece.operation_id = aic.operation_id

	LEFT JOIN "process".etalent_frozen_employees AS efe
	ON ISNULL(ece.cod_employee, aic.cod_employee) = efe.cod_employee
	AND ISNULL(ece.production_year, aic.inspection_year) = efe.year
	AND ISNULL(ece.production_week, aic.inspection_week) = efe.week

	LEFT JOIN source_atomic_sfc.operation_production AS op
	ON ISNULL(ece.operation_id, aic.operation_id) = op.id

	LEFT JOIN source_atomic_sfc.operation_rmi AS orm
	ON ISNULL(ece.operation_id, aic.operation_id) = orm.id

	LEFT JOIN source_atomic.stage AS s
	ON ISNULL(ece.stage_id, aic.stage_id) = s.id

	LEFT JOIN source_atomic.line AS l
	ON ISNULL(ece.line_id, aic.line_id) = l.id
) AS aie

WHERE aie.date >= CONVERT(date, GETDATE() -14)