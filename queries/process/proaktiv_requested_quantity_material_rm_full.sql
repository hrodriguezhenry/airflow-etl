-- PROCESS_PROAKTIV_REQUESTED_QUANTITY_MATERIAL_RM
-- Update 2023-06-02

-- Consulta que me trae la cantidad solicitada en compras por material en las
-- proximas 24 semanas.
SELECT ISNULL(mr.material_code, mr24.material_code) AS material_code,
	mr.requested_quantity_8_weeks,
	mr.requested_quantity_16_weeks,
	mr24.requested_quantity_24_weeks,
	'N' AS delete_row

-- Consulta "mr" que me trae la cantidad solicitado por material de
-- 1 a 8 semanas, y de 9 a 16 semanas.
FROM (
	SELECT ISNULL(mr8.material_code, mr16.material_code) AS material_code,
		mr8.requested_quantity_8_weeks,
		mr16.requested_quantity_16_weeks
	
	-- Consulta "mr8" que me trae la cantidad solicitado por material de
	-- 1 a 8 semanas.
	FROM (
		SELECT pd.mat_code AS material_code,
			SUM(CASE WHEN pd.po_det_inv_qty = 0 THEN pd.po_det_qty ELSE pd.po_det_inv_qty END) AS requested_quantity_8_weeks
		FROM source_proaktiv.po_hdr AS ph
		INNER JOIN source_proaktiv.po_detail AS pd
		ON ph.po_hdr_number = pd.po_hdr_number
		INNER JOIN source_proaktiv.materials AS m
		ON pd.mat_code = m.mat_code
		WHERE ph.po_hdr_status IN ('O', 'A')
		AND m.mat_cls_number NOT IN (500, 501, 502, 503, 504, 505)
		AND ISNULL(ph.po_hdr_ex_vendor_factory, po_hdr_first_ex_vendor_factory)
		BETWEEN CONVERT(date, GETDATE()) AND CONVERT(date, GETDATE() + 56)
		GROUP BY pd.mat_code
	) AS mr8
	
	-- Consulta "mr16" que me trae la cantidad solicitado por material de
	-- 9 a 16 semanas.
	FULL OUTER JOIN (
		SELECT pd.mat_code AS material_code,
			SUM(CASE WHEN pd.po_det_inv_qty = 0 THEN pd.po_det_qty ELSE pd.po_det_inv_qty END) AS requested_quantity_16_weeks
		FROM source_proaktiv.po_hdr AS ph
		INNER JOIN source_proaktiv.po_detail AS pd
		ON ph.po_hdr_number = pd.po_hdr_number
		INNER JOIN source_proaktiv.materials AS m
		ON pd.mat_code = m.mat_code
		WHERE ph.po_hdr_status IN ('O', 'A')
		AND m.mat_cls_number NOT IN (500, 501, 502, 503, 504, 505)
		AND ISNULL(ph.po_hdr_ex_vendor_factory, po_hdr_first_ex_vendor_factory)
		BETWEEN CONVERT(date, GETDATE() + 57) AND CONVERT(date, GETDATE() + 112)
		GROUP BY pd.mat_code
	) AS mr16
	ON mr8.material_code = mr16.material_code
) AS mr

-- Consulta "mr24" que me trae la cantidad solicitado por material de
-- 17 a 24 semanas.
FULL OUTER JOIN (
		SELECT pd.mat_code AS material_code,
			SUM(CASE WHEN pd.po_det_inv_qty = 0 THEN pd.po_det_qty ELSE pd.po_det_inv_qty END) AS requested_quantity_24_weeks
		FROM source_proaktiv.po_hdr AS ph
		INNER JOIN source_proaktiv.po_detail AS pd
		ON ph.po_hdr_number = pd.po_hdr_number
		INNER JOIN source_proaktiv.materials AS m
		ON pd.mat_code = m.mat_code
		WHERE ph.po_hdr_status IN ('O', 'A')
		AND m.mat_cls_number NOT IN (500, 501, 502, 503, 504, 505)
		AND ISNULL(ph.po_hdr_ex_vendor_factory, po_hdr_first_ex_vendor_factory)
		BETWEEN CONVERT(date, GETDATE() + 113) AND CONVERT(date, GETDATE() + 168)
		GROUP BY pd.mat_code
) AS mr24
ON mr.material_code = mr24.material_code