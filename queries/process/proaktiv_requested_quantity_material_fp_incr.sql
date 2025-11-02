-- PROCESS_PROAKTIV_REQUESTED_QUANTITY_MATERIAL_FP
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
		SELECT cm.material_code,
			SUM(wp.quantity) AS requested_quantity_8_weeks
		FROM source_fast_react.weekly_planning AS wp
		INNER JOIN source_proaktiv.cust_ord_hdr AS coh
		ON wp.cust_ord = coh.cust_ord_hdr_number
		
		INNER JOIN (
			SELECT cod.cust_ord_hdr_number AS cust_ord,
				CONCAT(cod.stl_number, '-' , c.clr_desc) AS material_code
			FROM source_proaktiv.cust_ord_detail AS cod
			INNER JOIN source_proaktiv.colors AS c
			ON cod.clr_number = c.clr_number
			GROUP BY cod.cust_ord_hdr_number,
				cod.stl_number,
				c.clr_desc
		) AS cm
		ON wp.cust_ord = cm.cust_ord
		WHERE wp.planning_date BETWEEN CONVERT(date, GETDATE()) AND CONVERT(date, GETDATE() + 56)
		GROUP BY cm.material_code
	) AS mr8
	
	-- Consulta "mr16" que me trae la cantidad solicitado por material de
	-- 9 a 16 semanas.
	FULL OUTER JOIN (
		SELECT cm.material_code,
			SUM(wp.quantity) AS requested_quantity_16_weeks
		FROM source_fast_react.weekly_planning AS wp
		INNER JOIN source_proaktiv.cust_ord_hdr AS coh
		ON wp.cust_ord = coh.cust_ord_hdr_number
		
		INNER JOIN (
			SELECT cod.cust_ord_hdr_number AS cust_ord,
				CONCAT(cod.stl_number, '-' , c.clr_desc) AS material_code
			FROM source_proaktiv.cust_ord_detail AS cod
			INNER JOIN source_proaktiv.colors AS c
			ON cod.clr_number = c.clr_number
			GROUP BY cod.cust_ord_hdr_number,
				cod.stl_number,
				c.clr_desc
		) AS cm
		ON wp.cust_ord = cm.cust_ord
		WHERE wp.planning_date BETWEEN CONVERT(date, GETDATE() + 57) AND CONVERT(date, GETDATE() + 112)
		GROUP BY cm.material_code
	) AS mr16
	ON mr8.material_code = mr16.material_code
) AS mr

-- Consulta "mr24" que me trae la cantidad solicitado por material de
-- 17 a 24 semanas.
FULL OUTER JOIN (
		SELECT cm.material_code,
			SUM(wp.quantity) AS requested_quantity_24_weeks
		FROM source_fast_react.weekly_planning AS wp
		INNER JOIN source_proaktiv.cust_ord_hdr AS coh
		ON wp.cust_ord = coh.cust_ord_hdr_number
		
		INNER JOIN (
			SELECT cod.cust_ord_hdr_number AS cust_ord,
				CONCAT(cod.stl_number, '-' , c.clr_desc) AS material_code
			FROM source_proaktiv.cust_ord_detail AS cod
			INNER JOIN source_proaktiv.colors AS c
			ON cod.clr_number = c.clr_number
			GROUP BY cod.cust_ord_hdr_number,
				cod.stl_number,
				c.clr_desc
		) AS cm
		ON wp.cust_ord = cm.cust_ord
		WHERE wp.planning_date BETWEEN CONVERT(date, GETDATE() + 113) AND CONVERT(date, GETDATE() + 168)
		GROUP BY cm.material_code
) AS mr24
ON mr.material_code = mr24.material_code