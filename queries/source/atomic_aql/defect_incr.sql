SELECT ad.id,
	ad.`name`,
	ad.`description`,
	ad.`type`,
	ad.etapa AS stage,
	ad.`level`,
	ad.created_at,
	ad.updated_at
FROM AQL_Defect AS ad
WHERE ad.deleted_at IS NULL