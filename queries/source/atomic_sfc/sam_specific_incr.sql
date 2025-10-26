SELECT sss.id,
	sss.standard_time,
	sss.active
FROM SFC_SAM_Specific AS sss
WHERE sss.deleted_at IS NULL
AND sss.active = 1