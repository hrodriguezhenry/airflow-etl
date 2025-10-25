SELECT bel.id,
	bel.cod_employee,
	bel.type,
	bel.employee_area_id,
	bel.stage_id,
	bel.line_fr,
	bel.line_id,
	bel.line_pk,
	bel.cost_center,
	bel.calculable,
	bel.active,
	bel.created_at
FROM Bonus_Employee_Leader AS bel
WHERE bel.deleted_at IS NULL
AND bel.updated_at >= CONVERT(date, GETDATE() -3)