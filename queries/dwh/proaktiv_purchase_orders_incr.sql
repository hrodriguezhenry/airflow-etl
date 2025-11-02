SELECT mcit.mat_cls_inv_type_spa_desc AS material_type,
	ph.po_hdr_number AS purchase_order,
	ISNULL(dps.doc_cur, mav.mat_currency) AS currency_code,
	ISNULL(dps.doc_rate, (CASE WHEN mav.mat_currency = 'GTQ' THEN 1 ELSE dcr.rate END)) AS exchange_rate,
	ph.po_hdr_status AS status,
	u.emp_code AS buyer_code,
	u.usr_name AS buyer_name,
	pd.mat_code AS material_code,
	pd.mat_desc AS material_description,
	pd.po_det_qty AS quantity,
	po_hdr_shipment AS shipment,
	ph.po_hdr_entry_date AS creation_date,
	ph.po_hdr_first_eta AS first_estimated_time_arrival,
	ph.po_hdr_eta AS current_estimated_arrival_time,
	pmr.rmi_reception_date AS order_arrival_date,
	
	CASE
		WHEN ISNULL(dps.price_fob, mav.mat_base_price) > ISNULL(dps.pric_at_whfc, pd.po_det_price) THEN ISNULL(dps.pric_at_whfc, pd.po_det_price)
		ELSE ISNULL(dps.price_fob, mav.mat_base_price)
	END AS cost_item_origin,
	
	dps.doc_date AS proration_date,
	ISNULL(dps.pric_at_whfc, pd.po_det_price) AS real_cost,
	ISNULL(dps.quantity, pd.po_det_inv_qty) AS quantity_received_warehouse,
	ISNULL(pd.po_det_inv_qty, 0) AS invoiced_amount,
	ich.id_imp_cod_hdr AS reception_warehouse,
	dps.add_id AS vendor_nit,
	ph.vend_number AS vendor_number,
	v.vend_name AS vendor_name,
	c.country_desc AS vendor_origin,
	dps.total AS total,
	uo.uom_desc AS unit_measurement,
	ph.po_hdr_invoice AS bills,
	pd.po_invoiced_price AS invoiced_price,
	ph.imp_cod_hdr AS policy,
	ISNULL(dps.pymnt_group, vin.credit) AS vendor_credit_days,
	pt.po_type_desc AS oder_type,
	ph.po_hdr_confirmation_date AS confirmation_date,
	vi.via_desc AS via,
	pdca.description AS last_reason_estimated_time_arrival,
	pdca.comment_for_change_date AS last_comment_estimated_time_arrival,
	pdca.add_date AS last_date_cahnge_estimated_time_arrival,
	ph.po_hdr_ex_vendor_factory AS vendor_plant_date,
	ph.update_date
	
FROM source_proaktiv.po_hdr AS ph
INNER JOIN source_proaktiv.po_detail AS pd
ON ph.po_hdr_number = pd.po_hdr_number
INNER JOIN source_proaktiv.materials_alt_vendor AS mav
ON pd.mat_code = mav.mat_code
AND ph.vend_number = mav.vend_number
INNER JOIN source_proaktiv.users AS u
ON ph.usr_number = u.usr_number
INNER JOIN source_proaktiv.vendors AS v
ON ph.vend_number = v.vend_number
INNER JOIN source_proaktiv.materials AS m
ON pd.mat_code = m.mat_code
INNER JOIN source_proaktiv.mat_cls AS mc
ON m.mat_cls_number = mc.mat_cls_number
INNER JOIN source_proaktiv.uom AS uo
ON m.uom_code = uo.uom_code
INNER JOIN source_proaktiv.mat_cls_inv_type AS mcit
ON mc.mat_cls_inv_type = mcit.mat_cls_inv_type
INNER JOIN source_proaktiv.po_type AS pt
ON ph.po_type_code = pt.po_type_code
INNER JOIN source_proaktiv.vias AS vi
ON ph.via_code = vi.via_code

LEFT JOIN (
	SELECT ers.date,
		ers.currency,
		ers.rate
	FROM source_proaktiv.exchange_rate_sap AS ers
	GROUP BY ers.date,
		ers.currency,
		ers.rate
) AS dcr
ON ph.po_hdr_entry_date = dcr.date
AND mav.mat_currency = dcr.currency

LEFT JOIN source_proaktiv.imp_cod_hdr AS ich
ON ph.imp_cod_hdr = ich.imp_cod_hdr
LEFT JOIN source_proaktiv.countries AS c
ON v.country_code = c.country_code

LEFT JOIN (
	SELECT d.doc_cur,
		d.add_id,
		d.pymnt_group,
		d.item_code,
		d.agent_num,
		d.u_id_trn_ext,
		d.doc_date,
		AVG(d.doc_rate) AS doc_rate,
		AVG(d.price_fob) AS price_fob,
		AVG(d.pric_at_whfc) AS pric_at_whfc,
		SUM(d.quantity) AS quantity,
		SUM(d.total) AS total
	FROM source_proaktiv.delivery_price_sap AS d
	GROUP BY d.doc_cur,
		d.add_id,
		d.pymnt_group,
		d.item_code,
		d.agent_num,
		d.u_id_trn_ext,
		d.doc_date
) AS dps
ON m.mat_cod_sap = dps.item_code
AND ph.imp_cod_hdr = dps.agent_num
AND ph.po_hdr_number = dps.u_id_trn_ext

LEFT JOIN source_proaktiv.vendors_information AS vin
ON CONVERT(CHAR, v.vend_number) = ISNULL(vin.cod_pk, vin.vend_number)

LEFT JOIN (
	SELECT lpha.po_hdr_number,
		r.description,
		lpha.comment_for_change_date,
		lpha.add_date
	FROM source_proaktiv.log_po_hdr AS lpha
	INNER JOIN (
		SELECT lph.po_hdr_number,
			MAX(lph.add_date) AS add_date,
			lph.audited_field
		FROM source_proaktiv.log_po_hdr AS lph
		WHERE lph.audited_field = 'POHdrETA'
		GROUP BY lph.po_hdr_number,
			lph.audited_field
	) AS paf
	ON lpha.po_hdr_number = paf.po_hdr_number
	AND lpha.add_date = paf.add_date
	AND lpha.audited_field = paf.audited_field
	INNER JOIN source_proaktiv.reasons AS r
	ON lpha.reason = r.reason
	WHERE lpha.audited_field = 'POHdrETA'
) AS pdca
ON ph.po_hdr_number = pdca.po_hdr_number

LEFT JOIN (
	SELECT rm.po_hdr_number,
		rm.mat_code,
		SUM(rm.rmi_qty) AS quantity,
		CONVERT(date, MAX(rm.rmi_reception_date)) AS rmi_reception_date
	FROM source_proaktiv.rmi AS rm 
	GROUP BY rm.po_hdr_number,
		rm.mat_code

) AS pmr
ON ph.po_hdr_number = pmr.po_hdr_number
AND pd.mat_code = pmr.mat_code

WHERE CONVERT(date, ph.update_date) >= CONVERT(date, GETDATE() -180)
OR ph.update_date IS NULL