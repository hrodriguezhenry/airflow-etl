SELECT coh.cust_ord_hdr_number AS cust_ord,
	cod.stl_number AS style_id,
	cod.clr_number AS color_id,
	cl.clr_short_desc AS color,
	s.stl_cls_number AS style_class_id,
	coh.cust_ord_hdr_cust_po AS cust_purchase_order,
	coh.cust_number AS cust_id,
	c.cust_name AS customer,
	s.stl_cust_item AS cust_style,
	c.cust_abr_name,
	c.cust_group,
	c.cust_group_total,
	coh.ret_number AS retailer_id,
	r.ret_name AS retailer,
	u.usr_number AS executive_id,
	u.usr_name AS executive,
	coh.cust_ord_hdr_status AS cust_ord_status,
	coh.co_type_code AS cust_ord_type_code,
	sdd.sz_dim_det_size AS size,
	ps.description AS special_type_packaging,
	pds.total_layers,
	pds.quantity_barrettes,
	pds.quantity_seams,
	pds.manual_berthing,
	pds.brooch,
	pds.ecological_glue,
	
	CASE 
		WHEN pds.type_seams = 'Costura en Capas' THEN 'Y'
		ELSE 'N'
	END hidden_seam,
	
	CASE
		WHEN pds.quantity_seams > 0 THEN 'Y'
		ELSE 'N'
	END seam,
	
	CASE 
		WHEN pds.sets_1 IS NOT NULL THEN 'Y'
		ELSE 'N'
	END sets,
	
	pds.leather_family,
	pds.type_belt,
	CONVERT(DECIMAL(6, 2), coh.cust_ord_hdr_holgura) AS slack,
	cod.cust_ord_det_qty AS cust_ord_qty,
	CONVERT(DECIMAL, ((100 - CONVERT(DECIMAL(6, 2), coh.cust_ord_hdr_holgura)) *
		(cod.cust_ord_det_qty / 100))) AS cust_ord_min_qty,
	cod.cust_ord_det_price AS sale_price,
	cod.cust_ord_det_qty * cod.cust_ord_det_price AS total_sale_price,
	coh.cust_ord_hdr_comment_0,
	coh.cust_ord_hdr_comment_1,
	coh.cust_ord_hdr_comment_2,
	coh.cust_ord_hdr_comment_3,
	coh.cust_ord_hdr_comment_4,
	coh.cust_ord_hdr_Comment_5,
	
	CASE
		WHEN coh.usr_number_of IS NULL THEN 'N'
		ELSE 'Y'
	END authorized_of,
	
	s.stl_active,
	coh.cust_ord_hdr_spec_pack AS cust_ord_special_packaging,
	coh.cust_ord_hdr_entry_date AS cust_ord_creation_date,
	cs.cut_prod_date AS production_start_date,
	coh.cust_ord_hdr_first_prod_ex_date AS first_production_end_date,
	coh.cust_ord_hdr_prod_ex_date AS production_end_date,
	coh.cust_Ord_hdr_prod_req AS cust_ord_production_required_end_date,
	coh.cust_ord_hdr_cust_ex_date AS cust_ord_export_date,
	coh.cust_confi_plan_date AS date_export_without_penalty,
	cm.manual_close_date,
	csf.cut_10 AS leather_layers,
	csf.cut_11 AS synthetic_layers,
	ua.usr_name AS vendor_name
FROM source_proaktiv.cust_ord_hdr AS coh
INNER JOIN source_proaktiv.cust_ord_detail AS cod
ON coh.cust_ord_hdr_number = cod.cust_ord_hdr_number
LEFT JOIN source_proaktiv.sz_dim_detail AS sdd
ON cod.sz_dim_det_number = sdd.sz_dim_det_number
LEFT JOIN source_proaktiv.styles AS s
ON cod.stl_number = s.stl_number
AND cod.clr_number = s.clr_number
LEFT JOIN source_proaktiv.colors AS cl
ON cod.clr_number = cl.clr_number
LEFT JOIN source_proaktiv.customers AS c
ON coh.cust_number = c.cust_number
LEFT JOIN source_proaktiv.retailers AS r
ON coh.ret_number = r.ret_number
LEFT JOIN source_proaktiv.users AS u
ON c.usr_number = u.usr_number
LEFT JOIN source_proaktiv.users AS ua
ON coh.usr_number_vendor = ua.usr_number
AND ua.is_vendor = 'Y'
LEFT JOIN source_proaktiv.cuts AS cs
ON REPLACE(coh.cust_ord_hdr_number, 'T', 'S') = cs.cut_number
LEFT JOIN source_proaktiv.packaging_specifications AS ps
ON coh.ps_id = ps.id
LEFT JOIN dwh.pdm_style AS pds
ON s.stl_number = pds.style_id
LEFT JOIN source_proaktiv.cut_style_fr AS csf
ON s.stl_cut_fr = csf.cut_id

LEFT JOIN (
	SELECT coa.cust_ord_hdr_number AS cust_ord,
		CONVERT(date, MIN(coa.co_aud_date)) AS manual_close_date
	FROM source_proaktiv.cust_ord_aud AS coa
	WHERE coa.co_aud_field = 'CustOrdHdrStatus'
	AND coa.co_aud_old_value = 'O'
	AND coa.co_aud_new_value = 'C'
	GROUP BY coa.cust_ord_hdr_number
) AS cm
ON coh.cust_ord_hdr_number = cm.cust_ord