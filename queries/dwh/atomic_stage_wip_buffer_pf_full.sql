WITH cust_ord AS (
	SELECT coh.cust_ord_hdr_number AS cust_ord
	FROM source_proaktiv.cust_ord_hdr AS coh
	WHERE coh.cust_ord_hdr_status = 'O'
	AND coh.cust_ord_hdr_close_production = 'N'
	AND LEFT(coh.cust_ord_hdr_number, 1) = 'T'
	GROUP BY coh.cust_ord_hdr_number
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
			('CORTE',        'WIP',    2133, 2003, 1,  2),  ('DIVIDIDO',     'WIP',    2241, 1496, 2,  3),
			('DIVIDIDO',     'WIP',    2241, 1497, 2,  3),  ('DIVIDIDO',     'WIP',    2241, 2052, 2,  3),
			('PEGADO',       'WIP',    1496, 1995, 3,  4),  ('PEGADO',       'WIP',    1497, 1995, 3,  4),
			('PEGADO',       'WIP',    2052, 1995, 3,  4),  ('PLANTA FAJAS', 'BUFFER', 2013, 2002, 4,  5),
			('AZ46',         'BUFFER', 2202, 1998, 5,  6),  ('AZ46',    	 'WIP',    1998, 1999, 6,  7),
			('PERFORADO',    'BUFFER', 2203, 2000, 7,  8),  ('PERFORADO',    'WIP',    2000, 2001, 8,  9),
			('ESFUMADO',     'BUFFER', 2204, 1996, 9,  10), ('ESFUMADO',     'WIP',    1996, 1997, 10, NULL)
		) AS ts(name, stock, input_operation_id, output_operation_id, sequence, next_sequence)
	) AS ts
	ON stpa.operation_id IN (ts.input_operation_id, ts.output_operation_id)
	WHERE sq.production_prefix = 'T'
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
	tsa.quantity AS quantity,
	tsa.scan_date,
	'N' AS delete_row
FROM traffic_stage AS tsa

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