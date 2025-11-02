-- PROCESS_ATOMIC_PRODUCTION_QR_GROUP_ENGINEER
-- Update 2023-05-04

-- Consulta que me trae por qr los grupos de operación
-- que pertenecen a ingeniería, y me muestra información
-- si estos grupos ya se cerraron en producción.
SELECT apqge.qr_id,
	apqge.group_operation_id,
	
	CASE
		WHEN apqge.open_group_operation = 'Y' THEN NULL
		ELSE apqge.quantity
	END AS group_close_quantity,
	
	CASE
		WHEN apqge.open_group_operation = 'Y' THEN NULL
		ELSE apqge.stage_id
	END AS group_close_stage_id,
	
	CASE
		WHEN apqge.open_group_operation = 'Y' THEN NULL
		ELSE apqge.line_id
	END AS group_close_line_id,
	
	CASE
		WHEN apqge.open_group_operation = 'Y' THEN NULL
		ELSE apqge.created_at
	END AS group_close_date,
	
	'N' AS delete_row
	
-- Consulta "apqge" que me trae por qr el grupo de ingeniería y la cantidad
-- del bulto, etapa, linea, fecha e indica si el grupo sigue
-- abierto o ya se cerro.
FROM (
	SELECT qrgod.qr_id,
		qrgod.group_operation_id,
		MAX(qrgod.open_group_operation) AS open_group_operation,
		MAX(qrgod.quantity) AS quantity,
		MAX(qrgod.stage_id) AS stage_id,
		MAX(qrgod.line_id) AS line_id,
		MAX(qrgod.created_at) AS created_at
	
	-- Consulta "qrgod" que me trae por qr el grupo de operaciones de ingeniería  
	-- que se encuentran en la ruta actual y a su vez que operaciones ya se realizaron
	-- y cuales no.
	FROM (
		SELECT DISTINCT sq.id AS qr_id,
			gop.id AS group_operation_id,
			gorp.operation_id,
			
			CASE 
				WHEN qrgo.operation_id IS NULL THEN 'Y'
				ELSE NULL
			END AS open_group_operation,
			
			qrgo.quantity,
			qrgo.stage_id,
			qrgo.line_id,
			qrgo.created_at
			
		FROM source_atomic_sfc.scan_qr AS sq
		INNER JOIN source_atomic_sfc.scan_qr_detail AS sqd
		ON sq.id = sqd.scan_qr_id
		INNER JOIN source_proaktiv.cust_ord_detail AS cod
		ON sq.cust_ord_hdr_number = cod.cust_ord_hdr_number
		AND sqd.sz_dim_det_number = cod.sz_dim_det_number
		INNER JOIN source_atomic_sfc.style_route_production AS srp
		ON cod.stl_number = srp.style_id
		INNER JOIN source_atomic_sfc.sam AS sa
		ON srp.sfc_sam_id = sa.id
		INNER JOIN source_atomic_sfc.group_operation_ref_production AS gorp
		ON sa.sfc_operation_id = gorp.operation_id
		INNER JOIN source_atomic_sfc.group_operation_production AS gop
		ON gorp.group_operation_id = gop.id
		AND gop.type = 'engineer'
		
		-- Consulta "qrgo" que me trae por qr las operaciones tanto sustitutas
		-- como no realizadas que pertenecen al grupo de ingeniería.
		LEFT JOIN (
			SELECT stp.sfc_scan_qr_id AS qr_id,
				stp.created_at,
				stp.quantity,
				stp.stage_id,
				stp.line_id,
				gorpa.group_operation_id,
				
				CASE
					WHEN gorpb.operation_id IS NULL THEN stp.operation_id
					ELSE gorpb.operation_id
				END AS operation_id
				
			FROM source_atomic_sfc.scan_transact_production AS stp
			INNER JOIN source_atomic_sfc.group_operation_ref_production AS gorpa
			ON stp.operation_id = gorpa.operation_id
			INNER JOIN source_atomic_sfc.group_operation_production AS gopa
			ON gorpa.group_operation_id = gopa.id
			AND gopa.type = 'engineer'
			
			-- Consulta "sgo" que me trae las operaciones que son sustitutas.
			LEFT JOIN (
				SELECT gop.id AS substitute_group_operation_id,
					gorp.operation_id
				FROM source_atomic_sfc.group_operation_ref_production AS gorp
				INNER JOIN source_atomic_sfc.group_operation_production AS gop
				ON gorp.group_operation_id = gop.id
				WHERE gop.type = 'substitute'
			) AS sgo
			ON stp.operation_id = sgo.operation_id
			
			LEFT JOIN source_atomic_sfc.group_operation_ref_production AS gorpb
			ON sgo.substitute_group_operation_id = gorpb.group_operation_id
		) AS qrgo
		ON sq.id = qrgo.qr_id
		AND gop.id = qrgo.group_operation_id
		AND gorp.operation_id = qrgo.operation_id
		
		WHERE sq.stage_id = 6
	) AS qrgod
	
	GROUP BY qrgod.qr_id,
		qrgod.group_operation_id
) AS apqge