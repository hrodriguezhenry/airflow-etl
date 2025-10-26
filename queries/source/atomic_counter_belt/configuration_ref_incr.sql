SELECT cbcr.id,
	cbcr.cut_leather_group_id,
	cbcr.customer_order_number,
	cbcr.sfc_scan_qr_id,
	cbcr.counter_belt_configuration_id,
	cbcr.counter_belt_configuration_laminated_id,
	cbcr.stage_id_generated,
	cbcr.dispatch_at,
	cbcr.printed,
	cbcr.created_at,
	cbcr.updated_at
FROM Counter_Belt_Configuration_Ref AS cbcr
WHERE cbcr.deleted_at IS NULL
AND cbcr.updated_at >= CONVERT(date, GETDATE() -3)