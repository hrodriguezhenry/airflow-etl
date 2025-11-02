-- PROCESS_ATOMIC_PRODUCTION_QR_OPERATION_PERFORMED
-- Update 2024-02-16

WITH qr_operation_performed AS (
	SELECT sq.id AS qr_id,
		cosl.cust_ord,
		cosl.style_id,
		IIF(stp.stage_id = 39, 3, stp.stage_id) AS stage_id,
		stp.operation_id
	FROM source_atomic_sfc.scan_transact_production AS stp
	INNER JOIN source_atomic_sfc.scan_qr AS sq
	ON stp.sfc_scan_qr_id = sq.id
	INNER JOIN analysis.customer_order_style_layer AS cosl
	ON sq.cust_ord_hdr_number = cosl.cust_ord
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
		cosl.style_id,
		IIF(stp.stage_id = 39, 3, stp.stage_id),
		stp.operation_id
)

SELECT qcso.qr_id,
	qcso.cust_ord,
	qcso.style_id,
	qcso.stage_id,
	qcso.operation_id,
	op.operation,
	capqo.operations,
	qsop.operations_performed

FROM (
	SELECT DISTINCT qopa.qr_id,
		qopa.cust_ord,
		qopa.style_id,
		cso.stage_id,
		cso.operation_id
		
	FROM qr_operation_performed AS qopa
	
	INNER JOIN (
		SELECT DISTINCT qop.cust_ord,
			qop.stage_id,
			qop.operation_id
		FROM qr_operation_performed AS qop
	) AS cso
	ON qopa.cust_ord = cso.cust_ord
	AND qopa.stage_id = cso.stage_id
	
	INNER JOIN process.atomic_production_qr_operation AS arqo
	ON qopa.qr_id = arqo.qr_id
	AND cso.stage_id = arqo.stage_id
	AND cso.operation_id = arqo.operation_id
) AS qcso

INNER JOIN (
	SELECT apqo.qr_id,
		apqo.stage_id,
		COUNT(apqo.operation_id) AS operations
	FROM process.atomic_production_qr_operation AS apqo
	GROUP BY apqo.qr_id,
	apqo.stage_id
) AS capqo
ON qcso.qr_id = capqo.qr_id
AND qcso.stage_id = capqo.stage_id

INNER JOIN (
	SELECT qopb.qr_id,
		qopb.stage_id,
		COUNT(qopb.operation_id) AS operations_performed
	FROM qr_operation_performed AS qopb
	GROUP BY qopb.qr_id,
		qopb.stage_id
) AS qsop

ON qcso.qr_id = qsop.qr_id
AND qcso.stage_id = qsop.stage_id

INNER JOIN source_atomic_sfc.operation_production AS op
ON qcso.operation_id = op.id