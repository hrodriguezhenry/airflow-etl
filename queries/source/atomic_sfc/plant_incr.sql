SELECT sp.id,
	sp.name,
	sp.production_scan_type
FROM SFC_Plant AS sp
WHERE sp.active = 1