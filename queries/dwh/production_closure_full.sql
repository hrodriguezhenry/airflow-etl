WITH cust_ord_production AS (
	SELECT coh.cust_ord_hdr_number AS cust_ord,
		cp.planning_date,
		CONCAT(c.cust_number ,' - ', c.cust_name) AS customer,
		u.usr_name AS executive,
		coh.cust_ord_hdr_cust_ex_date AS export_date,
		coh.cust_ord_hdr_status AS status,
		SUM(cod.cust_ord_det_qty) AS requerid_quantity,
		coh.cust_ord_hdr_close_production_date AS close_production
	FROM source_proaktiv.cust_ord_hdr AS coh
	INNER JOIN (
		SELECT wp.cust_ord,
			MAX(wp.planning_date) AS planning_date
		FROM source_fast_react.weekly_planning AS wp
		GROUP BY wp.cust_ord
	) AS cp
	ON coh.cust_ord_hdr_number = cp.cust_ord
	INNER JOIN source_proaktiv.cust_ord_detail AS cod
	ON coh.cust_ord_hdr_number = cod.cust_ord_hdr_number
	INNER JOIN source_proaktiv.customers AS c
	ON coh.cust_number = c.cust_number
	INNER JOIN source_proaktiv.users AS u 
	ON c.usr_number = u.usr_number
	WHERE coh.co_type_code IN ('O', 'S', 'V')
	AND coh.cust_ord_hdr_status IN ('C', 'O')
	GROUP BY coh.cust_ord_hdr_number,
		cp.planning_date,
		CONCAT(c.cust_number ,' - ', c.cust_name),
		u.usr_name,
		coh.cust_ord_hdr_cust_ex_date,
		coh.cust_ord_hdr_status,
		coh.cust_ord_hdr_close_production_date
)

SELECT cop.cust_ord,
	cop.customer,
	cop.executive,
	CONVERT(date, cop.export_date) AS export_date,
	cop.planning_date,
	cop.status,
	cop.requerid_quantity,
	cpa.original_produced_quantity_atomic,
	cpa.produced_quantity_atomic,
	cpa.original_produced_quantity_atomic - cpa.produced_quantity_atomic AS bad_produced_quantity_atomic,
	cpa.scanned_qrs,
	cpt.total_qrs,
	cop.close_production,
	cpp.produced_quantity_proaktiv
FROM cust_ord_production AS cop
INNER JOIN (
	SELECT f.cust_ord_hdr_number AS cust_ord,
		SUM(f.fgi_qty) AS produced_quantity_proaktiv
	FROM source_proaktiv.fgi AS f
	GROUP BY f.cust_ord_hdr_number
) AS cpp
ON cop.cust_ord = cpp.cust_ord
INNER JOIN (
	SELECT sq.cust_ord_hdr_number AS cust_ord,
		sq.production_prefix,
		COUNT(stp.sfc_scan_qr_id) AS scanned_qrs,
		SUM(stp.quantity) produced_quantity_atomic,
		SUM(sqd.quantity_original) original_produced_quantity_atomic
	FROM source_atomic_sfc.scan_transact_production AS stp
	INNER JOIN source_atomic_sfc.scan_qr AS sq
	ON stp.sfc_scan_qr_id = sq.id
	INNER JOIN source_atomic_sfc.scan_qr_detail AS sqd
	ON stp.sfc_scan_qr_id = sqd.scan_qr_id
	WHERE stp.operation_id = 787
	GROUP BY sq.cust_ord_hdr_number,
		sq.production_prefix
) AS cpa
ON cop.cust_ord = cpa.cust_ord
INNER JOIN (
	SELECT sq.cust_ord_hdr_number AS cust_ord,
		sq.production_prefix,
		COUNT(sq.id) AS total_qrs
	FROM source_atomic_sfc.scan_qr AS sq
	WHERE sq.stage_id IN (6, 19)
	GROUP BY sq.cust_ord_hdr_number,
		sq.production_prefix
) AS cpt
ON cpa.cust_ord = cpt.cust_ord
AND cpa.production_prefix = cpt.production_prefix