SELECT behr.id,
	behr.cod_employee,
	behr.week,
	behr."year",
	behr.operation_id,
	behr.operation_log_id,
	behr.first_inspection_qty,
	behr.inspection_rejected_qty,
	behr.percent_inspection_rejected,
	behr.percent_inspection_represented,
	behr.expected_amount,
	behr.amount,
	behr.created_at
FROM Bonus_Efficiency_History_Reject AS behr
WHERE behr.deleted_at IS NULL
AND behr.updated_at >= CONVERT(date, GETDATE() -3)