WITH customer_orders_produced AS (
	SELECT coss.cust_ord,
		coss.style_id,
		coss.customer_style,
		coss.purchase_order,
		coss.shipment_date,
		coss.priority,
		coss.cust_number,
		coss.ret_number,
		coss.stage_id,
		coss.quantity AS required_quantity,
		ISNULL(coss.exported_quantity, 0) AS exported_quantity,
		(ISNULL(csqa.quantity, 0) / IIF(coss.stage_id = 2, coss.layers, 1)) AS quantity,
		coss.sequence
		
	FROM (
		SELECT sq.cust_ord_hdr_number AS cust_ord,
			CASE
				WHEN stp.operation_id = 2003 THEN 2
				WHEN stp.operation_id = 1995 THEN 3
				WHEN stp.operation_id = 1890 THEN 44
				WHEN stp.operation_id = 1891 THEN 46
				WHEN stp.operation_id = 1894 THEN 5
				WHEN stp.operation_id = 1879 THEN 4
				WHEN stp.operation_id = 1892 THEN 7
				WHEN stp.operation_id = 936 THEN 23
			END AS stage_id,
				
			SUM(stp.quantity) AS quantity
		FROM source_atomic_sfc.scan_transact_production AS stp
		INNER JOIN source_atomic_sfc.scan_qr AS sq
		ON stp.sfc_scan_qr_id = sq.id
		WHERE stp.operation_id IN (2003, 1995, 1890, 1891, 1894, 1879, 1892, 936)
		GROUP BY sq.cust_ord_hdr_number,
			stp.operation_id
	) AS csqa

	RIGHT JOIN (
		SELECT coh.cust_ord_hdr_number AS cust_ord,
			cosl.style_id,
			csq.customer_style,
			coh.cust_ord_hdr_cust_po AS purchase_order,
			coh.cust_ord_hdr_cust_ex_date AS shipment_date,
			coh.cust_ord_hdr_priority AS priority,
			coh.cust_number,
			coh.ret_number,
			cosl.quantity,
			ceq.exported_quantity,
			cosl.layers,
			ss.stage_id,
			ss.sequence
		FROM source_proaktiv.cust_ord_hdr AS coh
		INNER JOIN analysis.customer_order_style_layer AS cosl
		ON coh.cust_ord_hdr_number = cosl.cust_ord

		INNER JOIN (
		 	SELECT s.stl_number AS style_id,
				MAX(s.stl_cust_item) AS customer_style
			FROM source_proaktiv.styles AS s
			WHERE s.stl_active = 'Y'
			GROUP BY s.stl_number
		) AS csq
		ON cosl.style_id = csq.style_id
		
		LEFT JOIN (
			SELECT f.cust_ord_hdr_number AS cust_ord,
				SUM(f.fgi_qty) AS exported_quantity
			FROM source_proaktiv.fgi AS f
			WHERE f.fgi_ship_date IS NOT NULL
			GROUP BY f.cust_ord_hdr_number
		) AS ceq
		ON coh.cust_ord_hdr_number = ceq.cust_ord
		
		CROSS JOIN (
			SELECT 2 AS stage_id, 1 sequence
			UNION ALL
			SELECT 3 AS stage_id, 2 sequence
			UNION ALL
			SELECT 44 AS stage_id, 3 sequence
			UNION ALL
			SELECT 46 AS stage_id, 4 sequence
			UNION ALL
			SELECT 5 AS stage_id, 5 sequence
			UNION ALL
			SELECT 4 AS stage_id, 6 sequence
			UNION ALL
			SELECT 7 AS stage_id, 7 sequence
			UNION ALL
			SELECT 23 AS stage_id, 8 sequence
		) AS ss
		
		WHERE coh.cust_ord_hdr_status = 'O'
		AND coh.co_type_code != 'T'
	) AS coss
	ON csqa.cust_ord = coss.cust_ord
	AND csqa.stage_id = coss.stage_id
)

SELECT t.cust_ord,
	c.cust_name AS customer,
	r.ret_name AS retailer,
	u.usr_name AS executive,
	t.style_id,
	t.customer_style,
	t.purchase_order,
	t.shipment_date,
	t.priority,
	t.required_quantity,
	t.exported_quantity,
	CONVERT(INT, t."2") AS cut_quantity,
	CONVERT(INT, t."3") AS glued_quantity,
	CONVERT(INT, t."44") AS die_quantity,
	CONVERT(INT, t."46") AS print_quantity,
	CONVERT(INT, t."5") AS seam_quantity,
	CONVERT(INT, t."4") AS body_quantity,
	CONVERT(INT, t."7") AS edges_quantity,
	CONVERT(INT, t."23") AS berth_quantity,
	'N' AS delete_row
	
FROM (
	SELECT cpsq.cust_ord,
		cpsq.style_id,
		cpsq.customer_style,
		cpsq.purchase_order,
		cpsq.shipment_date,
		cpsq.priority,
		cpsq.cust_number,
		cpsq.ret_number,
		cpsq.stage_id,
		cpsq.required_quantity,
		cpsq.exported_quantity,
		
		IIF(ss.stage_id IS NULL, NULL,
			IIF(
				IIF(cpsq.quantity > cpsq.after_quantity, cpsq.quantity, cpsq.after_quantity) > cpsq.required_quantity,
				cpsq.required_quantity,
				IIF(cpsq.quantity > cpsq.after_quantity, cpsq.quantity, cpsq.after_quantity)
			)
		) AS quantity
		
	FROM (
		SELECT copa.cust_ord,
			copa.style_id,
			copa.customer_style,
			copa.purchase_order,
			copa.shipment_date,
			copa.priority,
			copa.cust_number,
			copa.ret_number,
			copa.stage_id,
			copa.required_quantity,
			copa.exported_quantity,
			MAX(copa.quantity) AS quantity,
			MAX(ISNULL(copb.quantity, 0)) AS after_quantity
		FROM customer_orders_produced AS copa
		LEFT JOIN customer_orders_produced AS copb
		ON copa.cust_ord = copb.cust_ord
		AND copa.sequence < copb.sequence
		GROUP BY copa.cust_ord,
			copa.style_id,
			copa.customer_style,
			copa.purchase_order,
			copa.shipment_date,
			copa.priority,
			copa.cust_number,
			copa.ret_number,
			copa.stage_id,
			copa.required_quantity,
			copa.exported_quantity
	) AS cpsq
	
	LEFT JOIN (
		SELECT DISTINCT srp.style_id,
			CASE
				WHEN s.sfc_operation_id = 2003 THEN 2
				WHEN s.sfc_operation_id = 1995 THEN 3
				WHEN s.sfc_operation_id = 1890 THEN 44
				WHEN s.sfc_operation_id = 1891 THEN 46
				WHEN s.sfc_operation_id = 1894 THEN 5
				WHEN s.sfc_operation_id = 1879 THEN 4
				WHEN s.sfc_operation_id= 1892 THEN 7
				WHEN s.sfc_operation_id = 936 THEN 23
			END AS stage_id
		FROM source_atomic_sfc.style_route_production AS srp
		INNER JOIN source_atomic_sfc.sam AS s
		ON srp.sfc_sam_id = s.id
		WHERE s.sfc_operation_id IN (2003, 1995, 1890, 1891, 1894, 1879, 1892, 936)
	) AS ss
	ON cpsq.style_id = ss.style_id
	AND cpsq.stage_id = ss.stage_id
) AS cd

PIVOT (
	SUM(cd.quantity)
	FOR cd.stage_id IN ([2], [3], [44], [46], [5], [4], [7], [23])
) AS t

INNER JOIN source_proaktiv.customers AS c
ON t.cust_number = c.cust_number
INNER JOIN source_proaktiv.users AS u
ON c.usr_number = u.usr_number
LEFT JOIN source_proaktiv.retailers AS r
ON t.ret_number = r.ret_number