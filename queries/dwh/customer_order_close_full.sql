WITH CTE AS (
    SELECT coha.parent_order_reposition AS primary_parent_order_reposition,
        coha.parent_order_reposition,
        coha.cust_ord_hdr_number,
        CAST(coha.parent_order_reposition + ' -> ' + coha.cust_ord_hdr_number AS VARCHAR(MAX)) AS cust_ord_list
    FROM source_proaktiv.cust_ord_hdr AS coha
    INNER JOIN source_proaktiv.cust_ord_hdr AS cohb
    ON coha.parent_order_reposition = cohb.cust_ord_hdr_number
    WHERE coha.is_reposition_flag = 'Y'
    AND cohb.is_reposition_flag = 'N'
    
	UNION ALL 
	
    SELECT cte.primary_parent_order_reposition,
        coh.parent_order_reposition,
        coh.cust_ord_hdr_number,
        CAST(cte.cust_ord_list + ' -> ' + coh.cust_ord_hdr_number AS VARCHAR(MAX)) AS cust_ord_list
    FROM source_proaktiv.cust_ord_hdr AS coh
    INNER JOIN CTE cte ON coh.parent_order_reposition = cte.cust_ord_hdr_number
    WHERE coh.is_reposition_flag = 'Y'
)



SELECT os.cust_ord_hdr_number AS cust_ord,
	os.style_id AS style_id,
	csc.color,
	CONCAT(coty.co_type_code, '. ', coty.co_type_desc) AS cust_ord_type,
	csc.customer_style,
	coh.is_reposition_flag AS is_reposition,
	coh.parent_order_reposition AS primary_cust_ord,
	pc.cust_ord_list,
	cpd.planning_date,
	os.order_created_date AS cust_ord_created_date,
	u.usr_name AS executive,
	os.customer_number,
	os.customer_name AS customer,
	r.ret_number AS retailer_number,
	r.ret_name AS retailer,
	os.style_description AS style_description,
	os.production_close,
	os.production_close_date,
	cp.scan_date_packing,
	cp.original_produced_quantity_packing,
	cp.produced_quantity_packing,
	cp.original_produced_quantity_packing - cp.produced_quantity_packing AS bad_produced_quantity_packing,
	IIF(cpa.cust_ord IS NULL, 0, 1) AS packing_final_scan,
	cpa.produced_quantity_final_scan,
	cpa.original_produced_quantity_final_scan,
	cpa.scan_date_final_scan,
	cf.scan_date_fgi,
	os.required_units_qr,
	os.produced_units_pt,
	os.complete_finish_product,
	doa.total_boxes AS total_boxes_devolution,
	doa.classified_boxes AS classified_boxes_devolution,
	os.completed_devolution,
	os.devolution_date,
	os.completed_devolution_fgi,
	dob.total_boxes_fgi,
	dob.classified_boxes AS classified_boxes_devolution_fgi,
	os.devolution_date_fgi,
	os.administrative_close,
	os.administrative_close_date,
	os.order_status,
	os.updated_at
FROM source_atomic_sfc.order_status AS os
INNER JOIN source_proaktiv.cust_ord_hdr AS coh
ON os.cust_ord_hdr_number = coh.cust_ord_hdr_number
INNER JOIN (
	SELECT cod.cust_ord_hdr_number,
		cod.stl_number AS style_id,
		s.stl_cust_item AS customer_style,
		MAX(cl.clr_desc) AS color
	FROM source_proaktiv.cust_ord_detail AS cod
	LEFT JOIN source_proaktiv.styles AS s
	ON cod.stl_number = s.stl_number
	AND cod.clr_number = s.clr_number
	LEFT JOIN source_proaktiv.colors AS cl
	ON cod.clr_number = cl.clr_number
	WHERE LEFT(cod.cust_ord_hdr_number, 1) = 'T'
	GROUP BY cod.cust_ord_hdr_number,
		cod.stl_number,
		s.stl_cust_item
) AS csc
ON os.cust_ord_hdr_number = csc.cust_ord_hdr_number
INNER JOIN source_proaktiv.cust_ord_type AS coty
ON coh.co_type_code = coty.co_type_code
LEFT JOIN source_atomic_sfc.devolution_order AS doa
ON os.cust_ord_hdr_number = doa.cust_ord_hdr_number
AND doa.scan_type = 'qr_bundle'
LEFT JOIN source_atomic_sfc.devolution_order AS dob
ON os.cust_ord_hdr_number = dob.cust_ord_hdr_number
AND doa.scan_type = 'fgi_ticket'
LEFT JOIN source_proaktiv.customers AS c
ON os.customer_number = c.cust_number
LEFT JOIN source_proaktiv.retailers AS r
ON coh.ret_number = r.ret_number
LEFT JOIN source_proaktiv.users AS u
ON c.usr_number = u.usr_number
LEFT JOIN (
	SELECT f.cust_ord_hdr_number,
		MIN(f.fgi_production_date) AS scan_date_fgi
	FROM source_proaktiv.fgi AS f
	GROUP BY f.cust_ord_hdr_number
) AS cf
ON csc.cust_ord_hdr_number = cf.cust_ord_hdr_number

LEFT JOIN (
	SELECT sq.cust_ord_hdr_number AS cust_ord,
		SUM(stp.quantity) produced_quantity_packing,
		SUM(sqd.quantity_original) original_produced_quantity_packing,
		MIN(stp.created_at) AS scan_date_packing
	FROM source_atomic_sfc.scan_transact_production AS stp
	INNER JOIN source_atomic_sfc.scan_qr AS sq
	ON stp.sfc_scan_qr_id = sq.id
	INNER JOIN source_atomic_sfc.scan_qr_detail AS sqd
	ON stp.sfc_scan_qr_id = sqd.scan_qr_id
	WHERE LEFT(sq.cust_ord_hdr_number, 1) = 'T'
	AND stp.operation_id = 787
	GROUP BY sq.cust_ord_hdr_number
) AS cp
ON csc.cust_ord_hdr_number = cp.cust_ord

LEFT JOIN (
	SELECT sq.cust_ord_hdr_number AS cust_ord,
		SUM(stp.quantity) produced_quantity_final_scan,
		SUM(sqd.quantity_original) original_produced_quantity_final_scan,
		MIN(stp.created_at) AS scan_date_final_scan
	FROM source_atomic_sfc.scan_transact_production AS stp
	INNER JOIN source_atomic_sfc.scan_qr AS sq
	ON stp.sfc_scan_qr_id = sq.id
	INNER JOIN source_atomic_sfc.scan_qr_detail AS sqd
	ON stp.sfc_scan_qr_id = sqd.scan_qr_id
	WHERE LEFT(sq.cust_ord_hdr_number, 1) = 'T'
	AND stp.operation_id = 786
	GROUP BY sq.cust_ord_hdr_number
) AS cpa
ON csc.cust_ord_hdr_number = cpa.cust_ord

LEFT JOIN (
	SELECT wp.cust_ord,
		MAX(wp.planning_date) AS planning_date
	FROM source_fast_react.weekly_planning AS wp
	GROUP BY wp.cust_ord
) AS cpd
ON os.cust_ord_hdr_number = cpd.cust_ord

LEFT JOIN (
	SELECT primary_parent_order_reposition,
	    MAX(cust_ord_list) AS cust_ord_list
	FROM CTE
	GROUP BY primary_parent_order_reposition
) AS pc
ON pc.cust_ord_list LIKE '%'+coh.cust_ord_hdr_number+'%'