SELECT bedhw.id,
	bedhw.cod_employee,
	bedhw."day",
	bedhw.operation_id,
	bedhw.operation_log_id,
	bedhw.limit_defect,
	bedhw.inspection_qty,
	bedhw.inspection_wasted_qty,
	bedhw.percent_inspection_wasted,
	bedhw.percent_inspection_represented,
	bedhw.expected_amount,
	bedhw.amount,
	bedhw.created_at
FROM Bonus_Efficiency_Daily_History_Waste AS bedhw
WHERE bedhw.deleted_at IS NULL