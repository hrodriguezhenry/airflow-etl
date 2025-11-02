WITH material_detail AS (
	SELECT m.mat_code AS material_code,
		m.uom_code AS unit_measurement,
		mav.mat_desc AS material_description,
		mav.mat_base_price AS price,
		v.vend_name AS customer,
		mcit.mat_cls_inv_type_eng_desc AS material_type,
		m.mat_active
	FROM source_proaktiv.materials AS m
	INNER JOIN source_proaktiv.materials_alt_vendor AS mav
	ON m.mat_code = mav.mat_code
	AND mav.default_vendor = 'Y'
	INNER JOIN source_proaktiv.mat_cls AS mc
	ON m.mat_cls_number = mc.mat_cls_number
	INNER JOIN source_proaktiv.vendors AS v
	ON mav.vend_number = v.vend_number
	INNER JOIN source_proaktiv.mat_cls_inv_type AS mcit
	ON mc.mat_cls_inv_type = mcit.mat_cls_inv_type
--	WHERE m.mat_active = 'Y'
)
 
SELECT 'Inventario' AS "order",
	'Inventario' AS stage,
	NULL AS style_id,
	NULL AS color,
	md.material_code,
	md.material_description,
	md.price,
	md.customer,
	CONVERT(date, GETDATE()) AS stage_start_date,
	CONVERT(date, GETDATE()) AS creation_date,
	SUM(r.rmi_qty) AS requerid_quantity,
	md.material_type,
	NULL AS export_date,
	md.unit_measurement,
	'N' AS delete_row
FROM source_proaktiv.rmi AS r
INNER JOIN material_detail AS md
ON r.mat_code = md.material_code
INNER JOIN source_proaktiv.locations AS l
ON r.loc_code = l.loc_code
WHERE r.rmi_status = 'R'
AND r.rmi_destination = 3
AND r.quality_code = '1'
AND l.loc_kardex = 'Y'
AND r.rmi_qty > 0
GROUP BY md.material_code,
	md.material_description,
	md.price,
	md.customer,
	md.material_type,
	md.unit_measurement

UNION ALL

SELECT ph.po_hdr_number AS "order",
	ph.po_hdr_status AS stage,
	NULL AS style_id,
	NULL AS color,
	md.material_code,
	md.material_description,
	md.price,
	md.customer,
	ph.po_hdr_eta AS stage_start_date,
	ph.po_hdr_entry_date AS creation_date,

	CASE
		WHEN ISNULL(pd.po_det_inv_qty, 0) >= ISNULL(pd.po_det_qty, 0) THEN ISNULL(pd.po_det_inv_qty, 0)
		ELSE ISNULL(pd.po_det_qty, 0)
	END - ISNULL(SUM(r.rmi_qty), 0) requerid_quantity,
	
	md.material_type,
	NULL AS export_date,
	md.unit_measurement,
	'N' AS delete_row
FROM source_proaktiv.po_hdr AS ph
INNER JOIN source_proaktiv.po_detail AS pd
ON ph.po_hdr_number = pd.po_hdr_number
INNER JOIN material_detail AS md
ON pd.mat_code = md.material_code
LEFT JOIN source_proaktiv.rmi AS r
ON pd.po_hdr_number = r.po_hdr_number
AND pd.mat_code = r.mat_code
WHERE ph.po_hdr_status IN ('O', 'A')
AND ph.po_type_code = 'O'
AND ph.po_hdr_eta IS NOT NULL
GROUP BY ph.po_hdr_number,
	ph.po_hdr_status,
	md.material_code,
	md.material_description,
	md.price,
	md.customer,
	ph.po_hdr_eta,
	ph.po_hdr_entry_date,
	ISNULL(pd.po_det_inv_qty, 0),
	ISNULL(pd.po_det_qty, 0),
	md.material_type,
	md.unit_measurement
	
UNION ALL

SELECT "order",
	cp.cut_number AS stage,
	cd.style_id,
	cd.color,
	md.material_code,
	md.material_description,
	md.price,
	cd.customer,
	c.cut_prod_date AS stage_start_date, 
	cd.creation_date, 

	CASE
		WHEN ISNULL(SUM(r.rmi_qty), 0) - cp.cut_pl_req_qty > 0 THEN 0
		ELSE ISNULL(SUM(r.rmi_qty), 0) - cp.cut_pl_req_qty
	END AS requerid_quantity,
	
	md.material_type,
	cd.export_date,
	md.unit_measurement,
	'N' AS delete_row

FROM (
	SELECT coh.cust_ord_hdr_number AS "order",
		cod.stl_number AS style_id,
		c.clr_desc AS color,
		cu.cust_name AS customer,
		coh.cust_ord_hdr_entry_date AS creation_date,
		ISNULL(coh.cust_ord_hdr_cust_ex_date, coh.cust_ord_hdr_first_cust_ex_date) AS export_date
	FROM source_proaktiv.cust_ord_hdr AS coh
	INNER JOIN source_proaktiv.customers AS cu
	ON coh.cust_number = cu.cust_number
	LEFT JOIN source_proaktiv.cust_ord_detail AS cod
	ON coh.cust_ord_hdr_number = cod.cust_ord_hdr_number
	LEFT JOIN source_proaktiv.colors AS c
	ON cod.clr_number = c.clr_number
	WHERE coh.cust_ord_hdr_status = 'O'
	AND coh.cust_number != 200
	AND coh.co_type_code != 'T'
	AND LEFT(coh.cust_ord_hdr_number, 1) IN ('T', 'P')
	GROUP BY coh.cust_ord_hdr_number,
		cod.stl_number,
		c.clr_desc,
		cu.cust_name,
		coh.cust_ord_hdr_entry_date,
		ISNULL(coh.cust_ord_hdr_cust_ex_date, coh.cust_ord_hdr_first_cust_ex_date)
) AS cd

INNER JOIN source_proaktiv.cut_pl AS cp
ON cd."order" = 
	CASE
		WHEN LEFT(cp.cut_number, 2) IN ('PS', 'PF', 'PT') THEN REPLACE(cp.cut_number, LEFT(cp.cut_number, 2), 'P')
		WHEN LEFT(cp.cut_number, 1) IN ('S', 'F', 'T') THEN REPLACE(cp.cut_number, LEFT(cp.cut_number, 1), 'T')
	END 

INNER JOIN source_proaktiv.cuts AS c
ON c.cut_number = cp.cut_number
INNER JOIN material_detail AS md
ON cp.mat_code = md.material_code
LEFT JOIN source_proaktiv.rmi AS r
ON cp.cut_number = r.rmi_issuing_cut
AND cp.mat_code = r.mat_code
AND r.rmi_destination = 3
WHERE c.cut_status = 'O'
AND cp.cut_pl_req_qty > 0
AND c.cut_prod_date >= CONVERT(date, GETDATE() -30)
GROUP BY cd."order",
	cp.cut_number,
	cd.style_id,
	cd.color,
	md.material_code,
	md.material_description,
	md.price,
	cd.customer,
	c.cut_prod_date,
	cd.creation_date,
	cp.cut_pl_req_qty,
	md.material_type,
	cd.export_date,
	md.unit_measurement
	
HAVING CASE
		WHEN ISNULL(SUM(r.rmi_qty), 0) - cp.cut_pl_req_qty > 0 THEN 0
		ELSE ISNULL(SUM(r.rmi_qty), 0) - cp.cut_pl_req_qty
	END != 0