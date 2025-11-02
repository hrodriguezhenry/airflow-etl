WITH efficacy_qr AS (
	SELECT aes.cust_ord
	FROM process.atomic_efficacy_scan AS aes
	GROUP BY aes.cust_ord
)


SELECT qrogm.cust_ord,
	qrogm.qr_id,
	qrogm.stage_id,
	qrogm.operation_id,
	qrogm.operation_id_performed
FROM (
	SELECT csp.cust_ord,
		sq.id AS qr_id,
		csp.stage_id,
		
		CASE
			-- Si la operacion es individual se toma por defecto en cuenta para realizarla
			WHEN csp.single_operation = 1 THEN csp.operation_id
			-- Se valida que la operación grupal halla sido escaneada
			WHEN aesca.operation_id IS NOT NULL THEN csp.operation_id
			-- Se valida que la operación no halla sido escaneada en algun grupo 
			WHEN qgop.group_operations_performed IS NULL THEN csp.operation_id
			ELSE NULL
		END AS operation_id,
		
		CASE
			WHEN aesca.operation_id IS NOT NULL THEN csp.operation_id
			ELSE NULL
		END AS operation_id_performed
		
	FROM (
		SELECT DISTINCT aesc.cust_ord,
			aesc.stage_id,
			aesc.production_prefix,
			aesc.operation_id,
			
			CASE
				WHEN gop.group_operation_id IS NULL THEN 1
				ELSE 0
			END AS single_operation
			
		FROM efficacy_qr AS eq
		INNER JOIN process.atomic_efficacy_scan_close AS aesc
		ON eq.cust_ord = aesc.cust_ord
		
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
		ON aesc.operation_id = gop.operation_id
		
		WHERE aesc.first_day_of_week <= aesc.close_first_day_of_week
	) AS csp

	-- Otengo los qr's por orden y que operaciones se deben de realizar en la ruta actual
	INNER JOIN source_atomic_sfc.scan_qr AS sq
	ON csp.cust_ord = sq.cust_ord_hdr_number
	AND csp.production_prefix = sq.production_prefix
	
	-- Obtengo que operaciones ya se realizaron de lo que está en ruta
	LEFT JOIN process.atomic_efficacy_scan_close AS aesca
	ON csp.cust_ord = aesca.cust_ord
	AND csp.stage_id = aesca.stage_id
	AND csp.operation_id = aesca.operation_id
	AND sq.id = aesca.qr_id
	AND aesca.first_day_of_week <= aesca.close_first_day_of_week
	
	LEFT JOIN (
		-- Consulta que me trae todos los qr´s en donde se han realizado escaneos
		-- de los grupos de operaciones que asi mismo están incluidas otras operaciones
		SELECT DISTINCT qog.qr_id,
			gope.operation_id,
			qog.group_operations_performed
		
		FROM (
			-- Consulta que me da los qr's realizados y a que grupo pertence cada operación
			SELECT aescb.qr_id,
				aescb.operation_id,
				gorp.group_operation_id,
				1 AS group_operations_performed
			FROM process.atomic_efficacy_scan_close AS aescb
			INNER JOIN source_atomic_sfc.group_operation_ref_production AS gorp
			ON aescb.operation_id = gorp.operation_id
			WHERE aescb.first_day_of_week <= aescb.close_first_day_of_week
		) AS qog
				
		INNER JOIN (
			-- Consulta que me trae todas las operaciones sustitutas con sus grupos
			SELECT gorp.group_operation_id,
				gorp.operation_id
			FROM source_atomic_sfc.group_operation_ref_production AS gorp
			INNER JOIN source_atomic_sfc.group_operation_production AS gop
			ON gorp.group_operation_id = gop.id
			WHERE gop."type" = 'substitute'
		) AS gope
		ON qog.group_operation_id = gope.group_operation_id
	) AS qgop
	ON sq.id = qgop.qr_id
	AND csp.operation_id = qgop.operation_id
) AS qrogm
WHERE qrogm.operation_id IS NOT NULL
GROUP BY qrogm.cust_ord,
	qrogm.qr_id,
	qrogm.stage_id,
	qrogm.operation_id,
	qrogm.operation_id_performed