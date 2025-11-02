SELECT stp.created_at_short AS date,
	s.name AS stage,
	l.name AS line,
	gop.name AS group_operation,
	gop.sequence,
	DATEPART(hour, stp.created_at) AS hour,
    SUM(stp.quantity) AS quantity
FROM source_atomic_sfc.scan_transact_production AS stp
INNER JOIN source_atomic_sfc.group_operation_ref_production AS gorp
ON stp.operation_id = gorp.operation_id
INNER JOIN source_atomic_sfc.group_operation_production AS gop
ON gorp.group_operation_id = gop.id
INNER JOIN source_atomic.stage AS s
ON stp.stage_id = s.id
INNER JOIN source_atomic.line AS l
ON stp.line_id = l.id
WHERE gop.type = 'engineer'
AND stp.created_at_short >= CONVERT(date, GETDATE() -14)
GROUP BY stp.created_at_short,
	s.name,
	stp.line_id,
	l.name,
	gop.name,
	gop.sequence,
	DATEPART(hour, stp.created_at)

UNION ALL

SELECT CONVERT(date, sasps.created_at) AS date,
    'ESCANEO CONTABLE' AS stage,
    p.name AS line,
    'CONTABLE' AS group_operation,
    5 AS secuence,
    DATEPART(HOUR, sasps.created_at) AS hour,
    SUM(ssqd.quantity) AS quantity
FROM source_atomic_sfc.production_scan AS sasps
INNER JOIN source_atomic.line AS l
ON sasps.line_id = l.id
INNER JOIN source_atomic_sfc.plant AS p
ON l.sfc_plant_id = p.id
AND sasps.scan_type = p.production_scan_type
INNER JOIN source_atomic_sfc.scan_qr AS ssq
ON sasps.sfc_scan_qr_id = ssq.id
INNER JOIN source_atomic_sfc.scan_qr_detail AS ssqd
ON ssq.id = ssqd.scan_qr_id
WHERE sasps.stage_id = 4
AND CONVERT(date, sasps.created_at) >= CONVERT(date, GETDATE() -14)
GROUP BY CONVERT(date, sasps.created_at),
    p.name,
    DATEPART(HOUR, sasps.created_at)