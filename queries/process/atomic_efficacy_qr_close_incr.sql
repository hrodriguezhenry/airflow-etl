WITH efficacy_qr AS (
	SELECT DISTINCT aes.qr_id
	FROM process.atomic_efficacy_scan AS aes
	WHERE aes.date >= CONVERT(date, GETDATE() -9)
)

SELECT qsc.cust_ord,
	qsc.style_id,
	qsc.qr_id,
	qsc.stage_id,
	qsc.stage,
	aescb.line_id AS close_line_id,
	aescb.line AS close_line,
	aescb.quantity AS close_quantity,
	qsc.close_year,
	qsc.close_week,
	qsc.close_date,
	qsc.close_first_day_of_week
	
FROM (
	SELECT aesc.cust_ord,
		aesc.style_id,
		aesc.qr_id,
		aesc.stage_id,
		aesc.stage,
		w.year AS close_year,
		w.week AS close_week,
		aesc.close_date,
		aesc.close_first_day_of_week
	FROM efficacy_qr AS eq
	INNER JOIN process.atomic_efficacy_scan_close AS aesc
	ON eq.qr_id = aesc.qr_id
	INNER JOIN source_accesorios.weeks AS w
	ON CONVERT(date, aesc.close_date) = w.day
	WHERE aesc.close_date IS NOT NULL
	GROUP BY aesc.cust_ord,
		aesc.style_id,
		aesc.qr_id,
		aesc.stage_id,
		aesc.stage,
		w.year,
		w.week,
		aesc.close_date,
		aesc.close_first_day_of_week
) AS qsc

LEFT JOIN (
	SELECT aesca.qr_id,
		aesca.stage_id,
		MAX(aesca.scan_transact_id) AS scan_transact_id
	FROM efficacy_qr AS eq
	INNER JOIN process.atomic_efficacy_scan_close AS aesca
	ON eq.qr_id = aesca.qr_id
	WHERE aesca.first_day_of_week <= aesca.close_first_day_of_week
	GROUP BY aesca.qr_id,
		aesca.stage_id
) AS qss
ON qsc.qr_id = qss.qr_id
AND qsc.stage_id = qss.stage_id

LEFT JOIN process.atomic_efficacy_scan_close AS aescb
ON qss.scan_transact_id = aescb.scan_transact_id