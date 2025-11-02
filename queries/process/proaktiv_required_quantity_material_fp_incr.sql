-- PROCESS_PROAKTIV_REQUIRED_QUANTITY_MATERIAL_FP
-- Update 2023-06-02

-- Consulta que me trae la cantidad requerida por material en las
-- proximas 24 semanas.
SELECT ISNULL(mr.material_code, mr24.material_code) AS material_code,
	mr.required_quantity_8_weeks,
	mr.required_quantity_16_weeks,
	mr24.required_quantity_24_weeks,
	'N' AS delete_row


-- Consulta "mr" que me trae la cantidad requerida por material de
-- 1 a 8 semanas, y de 9 a 16 semanas.
FROM (
	SELECT ISNULL(mr8.material_code, mr16.material_code) AS material_code,
		mr8.required_quantity_8_weeks,
		mr16.required_quantity_16_weeks
	
	-- Consulta "mr8" que me trae la cantidad requerida por material de
	-- 1 a 8 semanas.
	FROM (
		SELECT CONCAT(cod.stl_number, '-', c.clr_desc) AS material_code, 
			SUM(cod.cust_ord_det_qty) AS required_quantity_8_weeks
		FROM source_proaktiv.cust_ord_hdr AS coh
		INNER JOIN source_proaktiv.cust_ord_detail AS cod
		ON coh.cust_ord_hdr_number = cod.cust_ord_hdr_number
		INNER JOIN source_proaktiv.colors AS c
		ON cod.clr_number = c.clr_number
		WHERE coh.cust_ord_hdr_status = 'O'
		AND coh.cust_ord_hdr_sales = 'Y'
		AND cod.cust_ord_det_price > 0
		AND coh.cust_ord_hdr_cust_ex_date BETWEEN CONVERT(date, GETDATE()) AND CONVERT(date, GETDATE()+56)
		GROUP BY cod.stl_number,
			c.clr_desc
	) AS mr8
	
	-- Consulta "mr16" que me trae la cantidad requerida por material de
	-- 9 a 16 semanas.
	FULL OUTER JOIN (
		SELECT CONCAT(cod.stl_number, '-', c.clr_desc) AS material_code, 
			SUM(cod.cust_ord_det_qty) AS required_quantity_16_weeks
		FROM source_proaktiv.cust_ord_hdr AS coh
		INNER JOIN source_proaktiv.cust_ord_detail AS cod
		ON coh.cust_ord_hdr_number = cod.cust_ord_hdr_number
		INNER JOIN source_proaktiv.colors AS c
		ON cod.clr_number = c.clr_number
		WHERE coh.cust_ord_hdr_status = 'O'
		AND coh.cust_ord_hdr_sales = 'Y'
		AND cod.cust_ord_det_price > 0
		AND coh.cust_ord_hdr_cust_ex_date BETWEEN CONVERT(date, GETDATE() + 57) AND CONVERT(date, GETDATE() + 112)
		GROUP BY cod.stl_number,
			c.clr_desc
	) AS mr16
	ON mr8.material_code = mr16.material_code
) AS mr

-- Consulta "mr24" que me trae la cantidad requerida por material de
-- 17 a 24 semanas.
FULL OUTER JOIN (
	SELECT CONCAT(cod.stl_number, '-', c.clr_desc) AS material_code, 
		SUM(cod.cust_ord_det_qty) AS required_quantity_24_weeks
	FROM source_proaktiv.cust_ord_hdr AS coh
	INNER JOIN source_proaktiv.cust_ord_detail AS cod
	ON coh.cust_ord_hdr_number = cod.cust_ord_hdr_number
	INNER JOIN source_proaktiv.colors AS c
	ON cod.clr_number = c.clr_number
	WHERE coh.cust_ord_hdr_status = 'O'
	AND coh.cust_ord_hdr_sales = 'Y'
	AND cod.cust_ord_det_price > 0
	AND coh.cust_ord_hdr_cust_ex_date BETWEEN CONVERT(date, GETDATE() + 113) AND CONVERT(date, GETDATE() + 168)
	GROUP BY cod.stl_number,
		c.clr_desc
) AS mr24
ON mr.material_code = mr24.material_code