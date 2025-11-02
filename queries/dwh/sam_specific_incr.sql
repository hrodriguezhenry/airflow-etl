WITH sam_specific_detail AS (
	SELECT fss.route_id,
		fss.style_id,
		fss.sam_id,
		fss.sam_specific_id,
		fss.stage,
		fss.operation_id,
		fss.operation,
		fss.stage_operation,
		fss.layer,
		fss.size,
		fss.size_order,
		fss.priority,
		fss."format",
		fss.width,
		fss.max_width,
		fss.material_class,
		fss.material_class_group,
		fss.long,
		fss.max_long,
		fss.class_group,
		fss.sah,
		fss.sam
		
	FROM (
		SELECT ssa.route_id,
			ssa.style_id,
			ssa.sam_id,
			ssa.sam_specific_id,
			ssa.stage,
			ssa.operation_id,
			ssa.operation,
			ssa.stage_operation,
			ssbp.layer,
			ssbp.size,
			ssbp.size_order,
			ssa.priority,
			ssa."format",
			ssa.width,
			ssa.max_width,
			ssa.material_class,
			ssa.long,
			ssa.max_long,
			ssa.class_group,
			IIF(ssa.class_group IS NULL, NULL, ssbp.material_class) AS material_class_group,
			ssa.sah,
			ssa.sam,
			
			CASE
				WHEN ssa.format IS NULL THEN 1
				WHEN ssa.format = ssbp."format" THEN 1
				ELSE 0
			END AS flag_format,
			
			CASE
				WHEN ssa.width IS NULL THEN 1
				WHEN CONVERT(DECIMAL, ssbp.width) BETWEEN CONVERT(DECIMAL, ssa.width) 
					AND CONVERT(DECIMAL, ssa.max_width) THEN 1
				ELSE 0
			END AS flag_with,
			
			CASE
				WHEN ssa.material_class IS NULL THEN 1
				WHEN ssa.material_class = ssbp.material_class THEN 1
				ELSE 0
			END AS flag_material_class,
			
			CASE
				WHEN ssa.long IS NULL THEN 1
				WHEN CONVERT(DECIMAL, ssbp.long) BETWEEN CONVERT(DECIMAL, ssa.long) 
					AND CONVERT(DECIMAL, ssa.max_long) THEN 1
				ELSE 0
			END AS flag_long,
			
			CASE
				WHEN ssa.mat_cls_number IS NULL THEN 1
				WHEN ssa.mat_cls_number = ssbp.mat_cls_number THEN 1
				ELSE 0
			END AS flag_class_group
			
		FROM "process".sam_specific_all AS ssa
		INNER JOIN (
			SELECT ssb.style_id,
				ssb.layer,
				ssb.size,
				ssb.size_order,
				ssb.format,
				ssp.width,
				ssb.material_class,
				ssp.measure_a AS long,
				ssb.mat_cls_number
			FROM process.sam_specific_bom AS ssb
			INNER JOIN process.sam_specific_pdm AS ssp
			ON CONVERT(CHAR, ssb.style_id) = ssp.style_id
			AND ssb.sz_dim_det_number = ssp.sz_dim_det_number
			AND ssb.input_field_with_id = ssp.input_field_with_id
		) AS ssbp
		ON ssa.style_id = ssbp.style_id
	) AS fss
	
	WHERE (fss.flag_format + fss.flag_with + flag_material_class + flag_long + flag_class_group) = 5
)

SELECT ssd.route_id,
	ssd.style_id,
	ssd.sam_id,
	ssd.sam_specific_id,
	ssd.stage,
	ssd.operation_id,
	ssd.operation,
	ssd.stage_operation,
	ssd.layer,
	ssd.size,
	ssd.priority,
	ssd."format",
	ssd.width,
	ssd.max_width,
	ssd.material_class,
	ssd.long,
	ssd.max_long,
	ssd.class_group,
	ssd.material_class_group,
	ssd.sah,
	ssd.sam,
	'N' AS delete_row
FROM sam_specific_detail AS ssd
INNER JOIN (
	SELECT ssda.style_id,
		ssda.operation_id,
		MIN(ssda.priority) AS priority,
		ssda.layer,
		MIN(ssda.size_order) AS size_order
	FROM sam_specific_detail AS ssda
	GROUP BY ssda.style_id,
		ssda.operation_id,
		ssda.layer
) AS kss
ON ssd.style_id = kss.style_id
AND ssd.operation_id = kss.operation_id
AND ssd.priority = kss.priority
AND ssd.layer = kss.layer
AND ssd.size_order = kss.size_order
GROUP BY ssd.route_id,
	ssd.style_id,
	ssd.sam_id,
	ssd.sam_specific_id,
	ssd.stage,
	ssd.operation_id,
	ssd.operation,
	ssd.stage_operation,
	ssd.layer,
	ssd.size,
	ssd.priority,
	ssd."format",
	ssd.width,
	ssd.max_width,
	ssd.material_class,
	ssd.long,
	ssd.max_long,
	ssd.class_group,
	ssd.material_class_group,
	ssd.sah,
	ssd.sam