SELECT beh.id,
	beh.week,
	beh."year",
	beh.cod_employee,
	beh.type,
	beh.employee_leader_id,
	beh.employee_area_id,
	beh.name,
	beh.variability,
	beh.rejected,
	beh.efficiency,
	beh.stage_id,
	beh.line_fr,
	beh.cost_center,
	beh.expected_amount,
	beh.amount,
	beh.created_at
FROM Bonus_Employee_History AS beh
WHERE beh.deleted_at IS NULL