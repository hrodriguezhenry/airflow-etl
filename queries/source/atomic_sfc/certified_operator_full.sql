SELECT sco.id,
	sco.cod_employee,
	sco.certification,
	sco.created_at
FROM SFC_Certified_Operator AS sco
WHERE sco.deleted_at IS NULL