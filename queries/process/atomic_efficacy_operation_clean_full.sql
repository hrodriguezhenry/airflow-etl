WITH efficacy_qr AS (
	SELECT DISTINCT aes.cust_ord
	FROM process.atomic_efficacy_scan AS aes
),
inactive_operations AS (
	SELECT DISTINCT eq.cust_ord,
		aep.operation_id
	FROM efficacy_qr AS eq
	INNER JOIN process.atomic_efficacy_operation AS aep
	ON eq.cust_ord = aep.cust_ord
	INNER JOIN source_atomic_sfc.operation_production AS op
	ON aep.operation_id = op.id
	INNER JOIN (
			SELECT DISTINCT aesc.cust_ord,
			aesc.qr_id,
			aesc.stage_id,
			aesc.close_date
		FROM efficacy_qr AS eq
		INNER JOIN process.atomic_efficacy_scan_close AS aesc
		ON eq.cust_ord = aesc.cust_ord
	) AS eqc
	ON aep.qr_id = eqc.qr_id
	AND aep.stage_id = eqc.stage_id
	AND eqc.close_date > op.inactive_efficacy_date
)

SELECT aeo.cust_ord,
	aeo.qr_id,
	aeo.stage_id,
	aeo.operation_id,
	aeo.operation_id_performed
FROM efficacy_qr AS eq
INNER JOIN process.atomic_efficacy_operation AS aeo
ON eq.cust_ord = aeo.cust_ord
WHERE NOT EXISTS (
	SELECT 1
	FROM inactive_operations AS io
	WHERE io.cust_ord = aeo.cust_ord
	AND io.operation_id = aeo.operation_id
)