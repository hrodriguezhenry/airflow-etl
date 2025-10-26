SELECT idd.id,
	idd.distribution_id,
	idd.defect_id,
	idd.created_at
FROM Inspection_Distribution_Defect as idd
WHERE idd.deleted_at IS NULL