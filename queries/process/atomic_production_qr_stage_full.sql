-- PROCESS_ATOMIC_PRODUCTION_QR_STAGE
-- Update 2024-02-16

WITH qr_stage AS (
	SELECT sq.id AS qr_id,
		sq.cust_ord_hdr_number AS cust_ord,
		IIF(stp.stage_id = 39, 3, stp.stage_id) AS stage_id,
		ssp."order",
		ssp.next_order,
		ssp.co_next_order,

		MAX(CASE
			WHEN qs.exit_operation IS NULL THEN NULL
			ELSE 'Y' 
		END) AS exit_operation,

		MAX(stp.id) as scan_transact_id
		
	FROM source_atomic_sfc.scan_transact_production AS stp
	INNER JOIN source_atomic_sfc.scan_qr AS sq
	ON stp.sfc_scan_qr_id = sq.id
	INNER JOIN source_atomic.stage_system_production AS ssp
	ON IIF(stp.stage_id = 39, 3, stp.stage_id) = ssp.stage_id
	LEFT JOIN (
		SELECT stp.sfc_scan_qr_id AS qr_id,
			oep.stage_close_id,
			'Y' AS exit_operation
		FROM source_atomic_sfc.scan_transact_production AS stp
		INNER JOIN source_atomic_sfc.operation_exit_production AS oep
		ON stp.operation_id = oep.operation_id
		GROUP BY stp.sfc_scan_qr_id,
			oep.stage_close_id	
	) AS qs
	ON sq.id = qs.qr_id
	AND stp.stage_id = qs.stage_close_id
	WHERE sq.production_prefix != 'R'
	AND stp.created_by != 1
	AND stp.operation_id IN (
		SELECT op.id
		FROM source_atomic_sfc.operation_production AS op
		WHERE op.include_efficacy = 1
	)
	GROUP BY sq.id,
		sq.cust_ord_hdr_number,
		IIF(stp.stage_id = 39, 3, stp.stage_id),
		ssp."order",
		ssp.next_order,
		ssp.co_next_order
)

SELECT qsa.qr_id,
	qsa.stage_id,
	
	CASE
		WHEN COALESCE(qsao.after_operation, qsas.accounting_scan, qsaoo.after_operation_ord, qsa.exit_operation) IS NULL THEN NULL
		ELSE stp.line_id
	END AS stage_close_line_id,
	
	CASE
		WHEN COALESCE(qsao.after_operation, qsas.accounting_scan, qsaoo.after_operation_ord, qsa.exit_operation) IS NULL THEN NULL
		ELSE stp.quantity
	END AS stage_close_quantity,
	
	CASE
		WHEN COALESCE(qsao.after_operation, qsas.accounting_scan, qsaoo.after_operation_ord, qsa.exit_operation) IS NULL THEN NULL
		ELSE stp.created_at
	END AS stage_close_date
	
FROM qr_stage AS qsa
INNER JOIN source_atomic_sfc.scan_transact_production AS stp
ON qsa.scan_transact_id = stp.id

LEFT JOIN (
	SELECT DISTINCT qsb.qr_id,
		qsb.stage_id,
		'Y' AS after_operation
	FROM qr_stage AS qsb
	INNER JOIN	qr_stage AS qsc
	ON qsb.qr_id = qsc.qr_id
	AND qsb.next_order <= qsc."order"
) AS qsao
ON qsa.qr_id = qsao.qr_id
AND qsa.stage_id = qsao.stage_id

LEFT JOIN (
	SELECT DISTINCT qsd.cust_ord,
		qsd.stage_id,
		'Y' AS after_operation_ord
	FROM qr_stage AS qsd
	INNER JOIN	qr_stage AS qse
	ON qsd.qr_id = qse.qr_id
	AND qsd.co_next_order <= qse."order"
) AS qsaoo
ON qsa.cust_ord = qsaoo.cust_ord
AND qsa.stage_id = qsaoo.stage_id

LEFT JOIN (
	SELECT DISTINCT qsf.qr_id,
		qsf.stage_id,
		'Y' AS accounting_scan
	FROM qr_stage AS qsf
	
	INNER JOIN (
		SELECT ps.sfc_scan_qr_id AS qr_id,
			ps.stage_id
		FROM source_atomic_sfc.production_scan AS ps
		WHERE CASE
				WHEN ps.scan_type = 1 AND ps.stage_id = 11 THEN 'Y'
				WHEN ps.scan_type = 2 AND ps.stage_id IN (2, 3) THEN 'Y'
				ELSE 'N'
			END = 'Y'
	) AS qsaa
	ON qsf.qr_id = qsaa.qr_id
	AND qsf.stage_id = qsaa.stage_id
) AS qsas
ON qsa.qr_id = qsas.qr_id
AND qsa.stage_id = qsas.stage_id