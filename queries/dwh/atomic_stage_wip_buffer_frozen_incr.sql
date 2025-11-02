WITH cust_ord AS (
	SELECT coh.cust_ord_hdr_number AS cust_ord,
		coh.cust_number,
		MAX(CASE WHEN op.stage_id = 46 THEN 1 END) AS print_route,
		MAX(CASE WHEN op.stage_id = 5 THEN 1 END) AS seam_route
	FROM source_proaktiv.cust_ord_hdr AS coh
	LEFT JOIN source_atomic_sfc.scan_qr AS sq
	ON coh.cust_ord_hdr_number = sq.cust_ord_hdr_number
	AND sq.production_prefix = 'T'
	LEFT JOIN source_atomic_sfc.style_route_production AS srp
	ON srp.style_id = sq.style_id
	LEFT JOIN source_atomic_sfc.sam AS s
	ON srp.sfc_sam_id = s.id
	LEFT JOIN source_atomic_sfc.operation_production AS op
	ON s.sfc_operation_id = op.id
	AND op.stage_id IN (46, 5)
	WHERE coh.cust_ord_hdr_status = 'O'
	AND coh.cust_ord_hdr_close_production = 'N'
	AND LEFT(coh.cust_ord_hdr_number, 1) = 'T'
	GROUP BY coh.cust_ord_hdr_number,
		coh.cust_number
),
traffic_stage AS (
	SELECT stpa.sfc_scan_qr_id AS qr_id,
		sq.cust_ord_hdr_number AS cust_ord,
		ts.name AS stage,
		ts.stock,
		ts.sequence,
		ts.next_sequence,
		ts.output_operation_id,
		MAX(stpa.quantity) AS quantity,
		MAX(stpa.created_at) AS scan_date,
		MAX(stpa.created_at_short) AS date
	FROM source_atomic_sfc.scan_transact_production AS stpa
	INNER JOIN source_atomic_sfc.scan_qr AS sq
	ON stpa.sfc_scan_qr_id = sq.id
	INNER JOIN cust_ord AS co
	ON sq.cust_ord_hdr_number = co.cust_ord
	INNER JOIN (
		SELECT name, stock, input_operation_id, output_operation_id, sequence, next_sequence
		FROM (
			VALUES
			('TROQUEL',      'BUFFER', 2013, 1884, 1,  2),  ('TROQUEL',      'WIP',    1884, 1890, 2,  3),
			('ESTAMPADO',    'BUFFER', 1890, 1885, 3,  4),  ('ESTAMPADO',    'WIP',    1885, 1891, 4,  5),
			('COSTURA',      'BUFFER', 1890, 1893, 5,  6),  ('COSTURA',      'BUFFER', 1891, 1893, 5,  6),
			('COSTURA',      'WIP',    1893, 684,  6,  7),  ('PREENTINTADO', 'BUFFER', 1879, 1765, 7,  8),
			('PREENTINTADO', 'WIP',    1765, 2358, 8,  9),  ('CANTOS',       'BUFFER', 2358, 2123, 9,  10),
			('CANTOS',       'WIP',    2123, 1892, 10, 11), ('ATRAQUE',      'BUFFER', 1892, 1821, 11, 12),
			('ATRAQUE',      'WIP',    1821, 936,  12, NULL)
		) AS ts(name, stock, input_operation_id, output_operation_id, sequence, next_sequence)
	) AS ts
	ON stpa.operation_id IN (ts.input_operation_id, ts.output_operation_id)
	WHERE sq.production_prefix = 'T'
	AND CASE
		WHEN co.print_route IS NULL AND ts.name = 'ESTAMPADO' THEN 0
		WHEN co.seam_route IS NULL AND ts.name = 'COSTURA' THEN 0
		WHEN co.print_route IS NOT NULL AND ts.input_operation_id = 1890 AND ts.name = 'COSTURA' THEN 0
		WHEN ts.name = 'ATRAQUE' AND co.cust_number = 980 THEN 0
		ELSE stpa.quantity
	END != 0
	GROUP BY stpa.sfc_scan_qr_id,
		sq.cust_ord_hdr_number,
		ts.name,
		ts.stock,
		ts.sequence,
		ts.next_sequence,
		ts.output_operation_id
)

SELECT tsa.qr_id,
	tsa.stage,
	tsa.stock,
	tsa.cust_ord,
	tsa.quantity,
	tsa.scan_date,
	yw."year",
	yw.week,
	yw.last_day_of_week
FROM traffic_stage AS tsa
CROSS JOIN (
	SELECT DISTINCT w.year,
		w.week,
		w.last_day_of_week
	FROM source_accesorios.weeks AS w
	WHERE w.day = CONVERT(date, GETDATE()-1)
) AS yw

LEFT JOIN source_atomic_sfc.scan_transact_production AS stpb
ON tsa.qr_id = stpb.sfc_scan_qr_id
AND tsa.output_operation_id = stpb.operation_id

LEFT JOIN (
	SELECT DISTINCT tsb.qr_id,
		tsb.sequence
	FROM traffic_stage AS tsb
	INNER JOIN traffic_stage AS tsc
	ON tsb.qr_id = tsc.qr_id
	AND tsb.next_sequence <= tsc.sequence
) AS qs
ON tsa.qr_id = qs.qr_id
AND tsa.sequence = qs.sequence

LEFT JOIN (
	SELECT ir.sfc_scan_qr_id AS qr_id
	FROM source_atomic_qis.inspection_revision AS ir
	INNER JOIN source_atomic_qis.inspection_station AS iss
	ON ir.station_id = iss.id
	WHERE ir.no = 1
	AND iss.atomic_stage_id = 6
	GROUP BY ir.sfc_scan_qr_id
) AS qrml
ON tsa.qr_id = qrml.qr_id

WHERE COALESCE(stpb.sfc_scan_qr_id, qs.qr_id, qrml.qr_id) IS NULL