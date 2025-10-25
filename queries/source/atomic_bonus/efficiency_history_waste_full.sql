SELECT behw.id,
	behw.cod_employee,
	behw.week,
	behw."year",
	behw.operation_id,
	behw.operation_log_id,
	behw.inspection_qty,
	behw.inspection_wasted_qty,
	behw.percent_inspection_wasted,
	behw.percent_inspection_represented,
	behw.expected_amount,
	behw.amount,
	behw.created_at
FROM Bonus_Efficiency_History_Waste AS behw
WHERE behw.deleted_at IS NULL