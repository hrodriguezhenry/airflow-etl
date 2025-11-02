-- PROCESS_ATOMIC_PRODUCTION_QR_OPERATION
-- Update 2024-02-16

WITH qr_operation AS (
	-- Consulta que me trae todos los qr's escaneados que están dentro de la
	-- ruta y que no estan fuera del cálculo de eficacias
	SELECT sq.id AS qr_id,
		cosl.cust_ord,
		IIF(stp.stage_id = 39, 3, stp.stage_id) AS stage_id,
		stp.operation_id,
		'Y' AS operation_performed
	FROM source_atomic_sfc.scan_transact_production AS stp
	INNER JOIN source_atomic_sfc.scan_qr AS sq
	ON stp.sfc_scan_qr_id = sq.id
	INNER JOIN analysis.customer_order_style_layer AS cosl
	ON sq.cust_ord_hdr_number = cosl.cust_ord
	INNER JOIN source_atomic_sfc.style_route_production AS srp
	ON cosl.style_id = srp.style_id
	INNER JOIN source_atomic_sfc.sam AS sa
	ON srp.sfc_sam_id = sa.id
	AND stp.operation_id = sa.sfc_operation_id
	WHERE sq.production_prefix != 'R'
	AND stp.created_by != 1
	AND stp.operation_id NOT IN (
		-- Consulta que me trae los id de operaciones a excluir en eficacias
		SELECT op.id
		FROM source_atomic.stage AS s
		INNER JOIN source_atomic_sfc.operation_production AS op
		ON s.id = op.stage_id
		WHERE s.exception_efficacy = 1
		AND op.exception_efficacy = 1
	)
	GROUP BY sq.id,
		cosl.cust_ord,
		IIF(stp.stage_id = 39, 3, stp.stage_id),
		stp.operation_id
)

--Consulta que me trae el conteo de operaciones a relizar por orden y QR que se encuentran vigentes en la ruta actual.
SELECT qrogm.qr_id,
	qrogm.stage_id,
	qrogm.operation_id,
	qrogm.operation_id_performed

 -- Subconsulta "qrogm" que me trae todas las operaciones vigentes en la ruta por numero de orden y QR,
 -- y consigo los grupos sustitutos y si pertenecen a mutiples grupos sustitutos, se toma en cuenta para el conteo 
 -- de operaciones a relizar solo las que no pertenecen a los grupos sustitutos, las que si pertenecen solo se copian 
 -- en otra columna para posteriormente ser calculados.
FROM (
	SELECT sq.id AS qr_id,
		ogsc.stage_id,
		
		CASE
			-- Si la operacion es individual se toma por defecto en cuenta para realizarla
			WHEN ogsc.single_operation_performed = 'Y' THEN ogsc.operation_id
			-- Se valida que la operación grupal halla sido escaneada
			WHEN qoa.operation_performed = 'Y' THEN ogsc.operation_id
			-- Se valida que la operación no halla sido escaneada en algun grupo 
			WHEN qrgop.group_operations_performed IS NULL THEN ogsc.operation_id
			ELSE NULL
		END AS operation_id,
		
		CASE
			WHEN qoa.operation_performed = 'Y' THEN ogsc.operation_id
			ELSE NULL
		END AS operation_id_performed
		
	FROM (
		-- Consulta que me trae todas las operaciones realizadas en ruta, y me indica si estas
		-- son operaciones individuales o grupales
		SELECT DISTINCT qo.operation_id,
			gop.group_operation_id,
			qo.stage_id,
			qo.cust_ord,
			s.production_prefix,
			
			CASE
				WHEN gop.group_operation_id IS NULL THEN 'Y'
			END AS single_operation_performed
	        
		FROM qr_operation AS qo
		INNER JOIN source_atomic_sfc.operation_production AS op
		ON qo.operation_id = op.id
		INNER JOIN source_atomic.stage AS s
		ON op.stage_id = s.id
		
		LEFT JOIN (
			-- Consulta que me trae todas las operaciones sustitutas con sus grupos y si pertenecen
			-- a multiples grupos sustitutos
			SELECT gorp.group_operation_id,
				gorp.operation_id
			FROM source_atomic_sfc.group_operation_production AS gop
			INNER JOIN source_atomic_sfc.group_operation_ref_production AS gorp
			ON gop.id = gorp.group_operation_id
			WHERE gop.type = 'substitute'
		) AS gop
		ON qo.operation_id = gop.operation_id
	) AS ogsc
	
	-- Otengo los qr's por orden y que operaciones se deben de realizar en la ruta actual
	INNER JOIN source_atomic_sfc.scan_qr AS sq
	ON ogsc.cust_ord = sq.cust_ord_hdr_number
	AND ogsc.production_prefix = sq.production_prefix
	
	-- Obtengo que operaciones ya se realizaron de lo que está en ruta
	LEFT JOIN qr_operation AS qoa
	ON ogsc.cust_ord = qoa.cust_ord
	AND ogsc.stage_id = qoa.stage_id
	AND ogsc.operation_id = qoa.operation_id
	AND sq.id = qoa.qr_id
	
	LEFT JOIN (
		-- Consulta que me trae todos los qr´s en donde se han realizado escaneos
		-- de los grupos de operaciones que asi mismo están incluidas otras operaciones
		SELECT DISTINCT oqp.qr_id,
			goo.operation_id,
			oqp.group_operations_performed
		
		FROM (
			-- Consulta que me da los qr's realizados y a que grupo pertence cada operación
			SELECT qob.qr_id,
				qob.operation_id,
				gorp.group_operation_id,
				'Y' AS group_operations_performed
			FROM qr_operation AS qob
			LEFT JOIN source_atomic_sfc.group_operation_ref_production AS gorp
			ON qob.operation_id = gorp.operation_id
		) AS oqp
		
		INNER JOIN (
			-- Consulta que me trae todas las operaciones sustitutas con sus grupos
			SELECT gorp.group_operation_id,
				gorp.operation_id
			FROM source_atomic_sfc.group_operation_ref_production AS gorp
			INNER JOIN source_atomic_sfc.group_operation_production AS gop
			ON gorp.group_operation_id = gop.id
			WHERE gop."type" = 'substitute'
		) AS goo
		ON oqp.group_operation_id = goo.group_operation_id
	) AS qrgop
	ON sq.id = qrgop.qr_id
	AND ogsc.operation_id = qrgop.operation_id
) AS qrogm

WHERE qrogm.operation_id IS NOT NULL

GROUP BY qrogm.qr_id,
	qrogm.stage_id,
	qrogm.operation_id,
	qrogm.operation_id_performed