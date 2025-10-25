SELECT bedhr.id,
	bedhr.cod_employee,
	bedhr."day",
	bedhr.operation_id,
	bedhr.operation_log_id,
	bedhr.limit_defect,
	bedhr.inspection_qty,
	bedhr.inspection_rejected_qty,
	bedhr.percent_inspection_rejected,
	bedhr.percent_inspection_represented,
	bedhr.expected_amount,
	bedhr.amount,
	bedhr.created_at
FROM Bonus_Efficiency_Daily_History_Reject AS bedhr
WHERE bedhr.deleted_at IS NULL