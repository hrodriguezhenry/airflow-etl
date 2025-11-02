SELECT srp.id AS route_id,
	srp.style_id,
	sa.id AS sam_id,
	ssox.sam_specific_id,
	
	CASE
		WHEN srp.stage_id IS NULL THEN 'ENSAMBLE'
		ELSE 'CORTE'
	END AS stage,
	
	ssox.operation_id,
	op.operation,
	s.name AS stage_operation,
	ssox.priority,
	ssfxa.value AS "format",
	ssfxb.value AS width,
	ssfxb.max_value AS max_width,
	ssfxc.value AS material_class,
	ssfxd.value AS long,
	ssfxd.max_value AS max_long,
	ssfxe.value AS class_group_id,
	mcg.name AS class_group,
	mcgr.mat_cls_number,
	ss.standard_time AS sah,
	ss.standard_time * 60 AS sam,
	'N' AS delete_row
FROM source_atomic_sfc.style_route_production AS srp
INNER JOIN source_atomic_sfc.sam AS sa
ON srp.sfc_sam_id = sa.id
INNER JOIN source_atomic_sfc.sam_specific_operation_xref AS ssox
ON sa.sfc_operation_id = ssox.operation_id
INNER JOIN source_atomic_sfc.sam_specific AS ss
ON ssox.sam_specific_id = ss.id
INNER JOIN source_atomic_sfc.operation_production AS op
ON ssox.operation_id = op.id
INNER JOIN source_atomic.stage AS s
ON op.stage_id = s.id

LEFT JOIN source_atomic_sfc.sam_specific_field_xref AS ssfxa
ON ss.id = ssfxa.sam_specific_id
AND ssfxa.field_id = 1

LEFT JOIN source_atomic_sfc.sam_specific_field_xref AS ssfxb
ON ss.id = ssfxb.sam_specific_id
AND ssfxb.field_id = 2

LEFT JOIN source_atomic_sfc.sam_specific_field_xref AS ssfxc
ON ss.id = ssfxc.sam_specific_id
AND ssfxc.field_id = 3

LEFT JOIN source_atomic_sfc.sam_specific_field_xref AS ssfxd
ON ss.id = ssfxd.sam_specific_id
AND ssfxd.field_id = 4

LEFT JOIN source_atomic_sfc.sam_specific_field_xref AS ssfxe
ON ss.id = ssfxe.sam_specific_id
AND ssfxe.field_id = 5
LEFT JOIN source_atomic_sfc.material_class_group AS mcg
ON ssfxe.value = CONVERT(CHAR, mcg.id)
LEFT JOIN source_atomic_sfc.material_class_group_ref AS mcgr
ON mcg.id = mcgr.material_class_group_id

WHERE srp.active = 1
AND sa.active = 1
AND ssox.active = 1
AND op.active = 1