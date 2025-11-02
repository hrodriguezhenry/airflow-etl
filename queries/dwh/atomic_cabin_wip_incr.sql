SELECT stpa.sfc_scan_qr_id AS qr_id,
	sq.cust_ord_hdr_number AS cust_ord,
	
	CASE
		WHEN stpa.operation_id = 2064 THEN 'CORTE'
		WHEN stpa.operation_id = 2062 THEN 'PEGADO'
		WHEN stpa.operation_id = 2056 THEN 'CUERPOS'
		WHEN stpa.operation_id = 2058 THEN 'CANTOS'
		WHEN stpa.operation_id = 2105 THEN 'CANTOS COSTCO'
		WHEN stpa.operation_id = 2060 THEN 'ENSAMBLE'
	END AS stage,
	
	stpa.operation_id,
	stpa.quantity,
	stpa.created_at AS scan_date,
	stpa.created_at_short AS date,
	'N' AS delete_row
FROM source_atomic_sfc.scan_transact_production AS stpa
INNER JOIN source_atomic_sfc.scan_qr AS sq
ON stpa.sfc_scan_qr_id = sq.id
INNER JOIN source_proaktiv.cust_ord_hdr AS coh
ON sq.cust_ord_hdr_number = coh.cust_ord_hdr_number

LEFT JOIN (
	SELECT stp.sfc_scan_qr_id AS qr_id,
		CASE
			WHEN stp.operation_id = 2065 THEN 2064
			WHEN stp.operation_id = 2063 THEN 2062
			WHEN stp.operation_id = 2057 THEN 2056
			WHEN stp.operation_id = 2059 THEN 2058
			WHEN stp.operation_id = 2106 THEN 2105
			WHEN stp.operation_id = 2061 THEN 2060
		END AS operation_id
	FROM source_atomic_sfc.scan_transact_production AS stp
	WHERE stp.operation_id IN (2065, 2063, 2057, 2059, 2106, 2061)
) AS stpb
ON stpa.sfc_scan_qr_id = stpb.qr_id
AND stpa.operation_id = stpb.operation_id

WHERE sq.production_prefix = 'T'
AND stpa.quantity != 0
AND coh.cust_ord_hdr_status = 'O'
AND coh.cust_ord_hdr_close_production = 'N'
AND stpa.operation_id IN (2064, 2062, 2056, 2058, 2105, 2060)
AND stpb.qr_id IS NULL