SELECT cs.cust_ord,
	cs.style_id,
	cs.customer_style,
	ISNULL(cr.cut_number, rm.cut_number) AS cut_number,
	LEFT(ISNULL(cr.cut_number, rm.cut_number), 1) AS prefix,
	cs.order_status,
	ISNULL(cr.material_class_type, rm.material_class_type) AS material_class_type,
	ISNULL(cr.material_class, rm.material_class) AS material_class,
	ISNULL(cr.mat_code, rm.mat_code) AS material_code,
	ISNULL(cr.material_description, rm.material_description) AS material_description,
	ISNULL(cr.mat_yield, rm.mat_yield) AS standard_material_yield,
	ISNULL(cr.mat_curr_price, rm.mat_curr_price) AS proaktiv_material_price,
	rm.nesting_yield,
	cs.close_production_date,
	cr.required_quantity,
	cr.required_quantity / COUNT(*) OVER (PARTITION BY cr.mat_code, cr.cut_number) AS prorated_required_quantity,
	cr.original_required_quantity,
	cr.original_required_quantity / COUNT(*) OVER (PARTITION BY cr.mat_code, cr.cut_number) AS prorated_original_required_quantity,
	rm.purchase_order,
	rm.dispatched_quantity,
	rm.proaktiv_price,
	rm.proaktiv_invoiced_price,
	ISNULL(cr.sap_material_avg_price, rm.sap_material_avg_price) AS sap_material_avg_price,
	rm.sap_price,
	rm.freight_cost,
	rm.dispatched_quantity * rm.proaktiv_price AS total_proaktiv_price_dispatched,
	rm.dispatched_quantity * rm.proaktiv_invoiced_price AS total_proaktiv_invoiced_price_dispatched,
	rm.dispatched_quantity * ISNULL(cr.sap_material_avg_price, rm.sap_material_avg_price) AS total_sap_avg_material_price_dispatched,
	rm.dispatched_quantity * rm.sap_price AS total_sap_price_dispatched,
	cr.required_quantity / COUNT(*) OVER (PARTITION BY cr.mat_code, cr.cut_number) * rm.proaktiv_price AS total_proaktiv_price_required,
	cr.required_quantity / COUNT(*) OVER (PARTITION BY cr.mat_code, cr.cut_number) * rm.proaktiv_invoiced_price AS total_proaktiv_invoiced_price_required,
	cr.required_quantity / COUNT(*) OVER (PARTITION BY cr.mat_code, cr.cut_number) * ISNULL(cr.sap_material_avg_price, rm.sap_material_avg_price) AS total_sap_avg_material_price_required,
	cr.required_quantity / COUNT(*) OVER (PARTITION BY cr.mat_code, cr.cut_number) * rm.sap_price AS total_sap_price_required,
	cr.original_required_quantity / COUNT(*) OVER (PARTITION BY cr.mat_code, cr.cut_number) * rm.proaktiv_price AS total_proaktiv_price_original_required,
	cr.original_required_quantity / COUNT(*) OVER (PARTITION BY cr.mat_code, cr.cut_number) * rm.proaktiv_invoiced_price AS total_proaktiv_invoiced_price_original_required,
	cr.original_required_quantity / COUNT(*) OVER (PARTITION BY cr.mat_code, cr.cut_number) * ISNULL(cr.sap_material_avg_price, rm.sap_material_avg_price) AS total_sap_avg_material_price_original_required,
	cr.original_required_quantity / COUNT(*) OVER (PARTITION BY cr.mat_code, cr.cut_number) * rm.sap_price AS total_sap_price_original_required
	
FROM (
	SELECT cp.mat_code,
		mav.mat_desc AS material_description,
		mcit.mat_cls_inv_type_spa_desc AS material_class_type,
		mc.mat_cls_name AS material_class,
		mav.mat_yield,
		mav.mat_curr_price,
		c.cut_number,
		SUM(cp.cut_pl_req_qty) AS required_quantity,
		SUM(cp.cut_pl_req_qty_orig) AS original_required_quantity,
		ROUND(oit.avg_price / ort.rate, 4) AS sap_material_avg_price
	FROM source_proaktiv.cuts AS c
	INNER JOIN source_proaktiv.cut_pl AS cp
	ON c.cut_number = cp.cut_number
	INNER JOIN source_proaktiv.materials AS m
	ON cp.mat_code = m.mat_code
	INNER JOIN source_proaktiv.materials_alt_vendor AS mav
	ON m.mat_code = mav.mat_code
	AND mav.default_vendor = 'Y'
	INNER JOIN source_proaktiv.mat_cls AS mc
	ON m.mat_cls_number = mc.mat_cls_number
	INNER JOIN source_proaktiv.mat_cls_inv_type AS mcit
	ON mc.mat_cls_inv_type = mcit.mat_cls_inv_type
	LEFT JOIN source_sap_tata_go_live.oitm AS oit
	ON m.mat_cod_sap = oit.item_code
	LEFT JOIN source_sap_tata_go_live.ortt AS ort
	ON oit.create_date = ort.rate_date
	AND ort.currency = 'USD'
	WHERE LEFT(c.cut_number, 1) IN ('S', 'F', 'T')
	GROUP BY cp.mat_code,
		mav.mat_desc,
		mcit.mat_cls_inv_type_spa_desc,
		mc.mat_cls_name,
		mav.mat_yield,
		mav.mat_curr_price,
		c.cut_number,
		oit.avg_price / ort.rate
) AS cr

FULL JOIN (
	SELECT r.mat_code,
		r.rmi_issuing_cut AS cut_number,
		r.po_hdr_number AS purchase_order,
		mav.mat_desc AS material_description,
		mcit.mat_cls_inv_type_spa_desc AS material_class_type,
		mc.mat_cls_name AS material_class,
		mav.mat_yield,
		mav.mat_curr_price,
		AVG(tn.nesting_yield) AS nesting_yield,
		SUM(r.rmi_qty) AS dispatched_quantity,
		pd.po_det_price AS proaktiv_price,
		pd.po_invoiced_price AS proaktiv_invoiced_price,
		pmuc.unit_price AS sap_price,
		pmuc.unit_cost AS freight_cost,
		ROUND(oit.avg_price / ort.rate, 4) AS sap_material_avg_price
	FROM source_proaktiv.rmi AS r
	INNER JOIN source_proaktiv.materials AS m
	ON r.mat_code = m.mat_code
	INNER JOIN source_proaktiv.materials_alt_vendor AS mav
	ON m.mat_code = mav.mat_code
	AND mav.default_vendor = 'Y'
	INNER JOIN source_proaktiv.mat_cls AS mc
	ON m.mat_cls_number = mc.mat_cls_number
	INNER JOIN source_proaktiv.mat_cls_inv_type AS mcit
	ON mc.mat_cls_inv_type = mcit.mat_cls_inv_type
	LEFT JOIN source_sap_tata_go_live.oitm AS oit
	ON m.mat_cod_sap = oit.item_code
	LEFT JOIN source_sap_tata_go_live.ortt AS ort
	ON oit.create_date = ort.rate_date
	AND ort.currency = 'USD'
	LEFT JOIN source_proaktiv.po_detail AS pd
	ON r.mat_code = pd.mat_code
	AND r.po_hdr_number = pd.po_hdr_number
	LEFT JOIN process.proaktiv_material_unit_cost AS pmuc
	ON m.mat_cod_sap = pmuc.material_code
	AND r.po_hdr_number = pmuc.purchase_order
	
	LEFT JOIN (
		SELECT REPLACE(m.material_file, '.hid', '') AS ticket_number,
			AVG(l.yield) AS nesting_yield
		FROM source_nesting_orders.materials AS m
		INNER JOIN source_nesting_orders.layouts AS l
		ON m.material_id = l.material_id
		AND M.session_id = l.session_id
		GROUP BY REPLACE(m.material_file, '.hid', '')
	) AS tn
	ON r.rmi_ticket_number = tn.ticket_number
	
	WHERE LEFT(r.rmi_issuing_cut, 1) IN ('S', 'F', 'T')
	GROUP BY r.mat_code,
		mav.mat_desc,
		mcit.mat_cls_inv_type_spa_desc,
		mc.mat_cls_name,
		mav.mat_yield,
		mav.mat_curr_price,
		r.rmi_issuing_cut,
		r.po_hdr_number,
		pd.po_det_price,
		pd.po_invoiced_price,
		pmuc.unit_price,
		pmuc.unit_cost,
		ROUND(oit.avg_price / ort.rate, 4)
) AS rm
ON cr.cut_number = rm.cut_number
AND cr.mat_code = rm.mat_code
	
INNER JOIN (
	SELECT DISTINCT coh.cust_ord_hdr_number AS cust_ord,
		s.stl_number AS style_id,
		s.stl_cust_item AS customer_style,
		coh.cust_ord_hdr_status AS order_status,
		coh.cust_ord_hdr_close_production_date AS close_production_date
	FROM source_proaktiv.cust_ord_hdr AS coh
	INNER JOIN source_proaktiv.cust_ord_detail AS cod
	ON coh.cust_ord_hdr_number = cod.cust_ord_hdr_number
	INNER JOIN source_proaktiv.styles AS s
	ON cod.stl_number = s.stl_number
	AND cod.clr_number = s.clr_number
	WHERE coh.cust_ord_hdr_prefix = 'T'
) AS cs
ON cs.cust_ord = REPLACE(ISNULL(cr.cut_number, rm.cut_number), LEFT(ISNULL(cr.cut_number, rm.cut_number), 1), 'T')