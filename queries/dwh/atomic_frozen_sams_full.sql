SELECT DATEPART(YEAR, GETDATE()) AS "year",
	DATEPART(MONTH, GETDATE()) AS "month",
	GETDATE() AS execute_time,
	srp.style_id,
	op.id, op.operation,
	op.stage_id,
	s.name AS stage,
	SUM(sa.standard_time) AS sah,
	SUM(sa.standard_time) * 60 AS sam
FROM source_atomic_sfc.style_route_production AS srp
INNER JOIN source_atomic_sfc.sam AS sa
ON sa.id = srp.sfc_sam_id
INNER JOIN source_atomic_sfc.operation_production AS op
ON op.id = sa.sfc_operation_id
INNER JOIN source_atomic.stage AS s
ON op.stage_id = s.id
WHERE srp.active = 1
AND sa.active = 1 AND op.active = 1
AND sa.standard_time > 0
GROUP BY srp.style_id,
	op.id,
	op.operation,
	op.stage_id,
	s.name