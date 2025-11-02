SELECT stph.created_at_short AS date,
    6 AS stage_id,
    p.name AS plant,
    l.name AS line,
    DATEPART(hour, stph.created_at) AS hour,
    SUM(stph.quantity) AS quantity
FROM source_atomic_sfc.scan_transact_production AS stph
INNER JOIN source_atomic_sfc.scan_transact_production AS stpl
ON stph.sfc_scan_qr_id = stpl.sfc_scan_qr_id
INNER JOIN source_atomic.line AS l
ON stpl.line_id = l.id
INNER JOIN source_atomic_sfc.plant AS p
ON l.sfc_plant_id = p.id
WHERE stph.operation_id = 787
AND stpl.operation_id = 936
GROUP BY stph.created_at_short,
    l.name,
    p.name,
    DATEPART(hour, stph.created_at) 

UNION ALL

SELECT CONVERT(date, sasps.created_at) AS date,
    sasps.stage_id,
    p.name AS plant,
    l.name AS line,
    DATEPART(hour, sasps.created_at) AS hour,
    SUM(sasps.quantity) AS quantity
FROM source_atomic_sfc.production_scan AS sasps
INNER JOIN source_atomic_sfc.scan_qr AS sq
ON sasps.sfc_scan_qr_id = sq.id
INNER JOIN source_atomic.line AS l
ON sasps.line_id = l.id
INNER JOIN source_atomic_sfc.plant AS p
ON l.sfc_plant_id = p.id
AND sasps.scan_type = p.production_scan_type
WHERE sasps.stage_id IN (3, 4)
GROUP BY CONVERT(date, sasps.created_at),
    sasps.stage_id,
    p.name,
    l.name,
    DATEPART(HOUR, sasps.created_at)


UNION ALL

SELECT stp.created_at_short AS date,
    stp.stage_id,
    
    CASE
    	WHEN stp.operation_id IN (693, 1691, 1689, 1904) THEN 'Corte'
    	WHEN stp.operation_id IN (824, 841) THEN 'Pasadores'
    END AS plant,
    
    l.name AS line,
    DATEPART(hour, stp.created_at) AS hour,
    SUM(stp.quantity) AS quantity
FROM source_atomic_sfc.scan_transact_production AS stp
INNER JOIN source_atomic.line AS l
ON stp.line_id = l.id
WHERE stp.operation_id IN (693, 1691, 1689, 1904, 824, 841)
GROUP BY stp.created_at_short,
	stp.stage_id,
    CASE
    	WHEN stp.operation_id IN (693, 1691, 1689, 1904) THEN 'Corte'
    	WHEN stp.operation_id IN (824, 841) THEN 'Pasadores'
    END,
    l.name,
    DATEPART(hour, stp.created_at)