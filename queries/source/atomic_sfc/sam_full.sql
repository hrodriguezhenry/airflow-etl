SELECT ss.id,
	ss.sfc_operation_id,
	ss.pay_per_piece,
	ss.standard_time,
	ss.description,
	ss.hash,
	ss.active
FROM SFC_SAM AS ss
WHERE ss.deleted_at IS NULL
AND ss.active = 1