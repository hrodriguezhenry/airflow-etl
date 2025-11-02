WITH efficacy_qr AS (
	SELECT aes.qr_id
	FROM process.atomic_efficacy_scan AS aes
	GROUP BY aes.qr_id
)

SELECT aesa.date,
	aesa.scan_transact_id,
	aesa.cust_ord,
	aesa.style_id,
	aesa.production_prefix,
	aesa.qr_id,
	aesa.stage_id,
	aesa.stage,
	aesa.line_id,
	aesa.line,
	aesa.operation_id,
	aesa.operation,
	aesa.cod_employee,
	aesa.employee_name,
	aesa.mark_type,
	aesa.quantity,
	aesa.single_operation,
	aesa.scan_date,
	MIN(LEAST(qs.scan_date_stage, qso.scan_date_exit_operation, qsq.scan_date_qis)) AS close_date,
	aesa.first_day_of_week,
	MIN(LEAST(qs.first_day_of_week, qso.first_day_of_week, qsq.first_day_of_week)) AS close_first_day_of_week
FROM efficacy_qr AS eq
INNER JOIN process.atomic_efficacy_scan AS aesa
ON eq.qr_id = aesa.qr_id
INNER JOIN source_atomic.stage_system_production AS sspa
ON aesa.stage_id = sspa.stage_id

LEFT JOIN (
	SELECT aesb.qr_id,
		sspb.efficacy_order,
		MIN(aesb.scan_date) AS scan_date_stage,
		MIN(aesb.first_day_of_week) AS first_day_of_week
	FROM efficacy_qr AS eqa
	INNER JOIN process.atomic_efficacy_scan AS aesb
	INNER JOIN source_atomic.stage_system_production AS sspb
	ON aesb.stage_id = sspb.stage_id
	ON eqa.qr_id = aesb.qr_id
	GROUP BY aesb.qr_id,
		sspb.efficacy_order
) AS qs
ON aesa.qr_id = qs.qr_id
AND sspa.efficacy_next_order <= qs.efficacy_order

LEFT JOIN (
	SELECT stp.sfc_scan_qr_id AS qr_id,
		oep.stage_close_id,
		MIN(stp.created_at) AS scan_date_exit_operation,
		MIN(w.first_day_of_week) AS first_day_of_week
	FROM source_atomic_sfc.scan_transact_production AS stp
	INNER JOIN source_atomic_sfc.operation_exit_production AS oep
	ON stp.operation_id = oep.operation_id
	INNER JOIN source_accesorios.weeks AS w
	ON stp.created_at_short = w.day
	GROUP BY stp.sfc_scan_qr_id,
		oep.stage_close_id	
) AS qso
ON aesa.qr_id = qso.qr_id
AND aesa.stage_id = qso.stage_close_id

LEFT JOIN (
		SELECT ir.sfc_scan_qr_id AS qr_id,
		ist.atomic_stage_id AS stage_id,
		MIN(ir.last_close_at) AS scan_date_qis,
		MIN(w.first_day_of_week) AS first_day_of_week
	FROM source_atomic_qis.inspection_revision AS ir
	INNER JOIN source_atomic_qis.inspection_station AS ist
	ON ir.station_id = ist.id
	INNER JOIN source_accesorios.weeks AS w
	ON CONVERT(date, ir.last_close_at) = w.day
	WHERE ist.atomic_stage_id IN (2, 4, 11)
	GROUP BY ir.sfc_scan_qr_id,
		ist.atomic_stage_id
) AS qsq
ON aesa.qr_id = qsq.qr_id
AND aesa.stage_id = qsq.stage_id
GROUP BY aesa.date,
	aesa.first_day_of_week,
	aesa.scan_transact_id,
	aesa.cust_ord,
	aesa.style_id,
	aesa.production_prefix,
	aesa.qr_id,
	aesa.stage_id,
	aesa.stage,
	aesa.line_id,
	aesa.line,
	aesa.operation_id,
	aesa.operation,
	aesa.cod_employee,
	aesa.employee_name,
	aesa.mark_type,
	aesa.quantity,
	aesa.single_operation,
	aesa.scan_date