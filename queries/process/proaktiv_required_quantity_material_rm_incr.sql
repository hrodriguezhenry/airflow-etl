-- PROCESS_PROAKTIV_REQUIRED_QUANTITY_MATERIAL_RM
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
		SELECT cp.mat_code AS material_code,
			
			SUM(
				CASE
					WHEN cp.cut_pl_req_qty - cp.cut_pl_used_qty > 0 THEN cp.cut_pl_req_qty - cp.cut_pl_used_qty
					ELSE NULL
				END
			) AS required_quantity_8_weeks
			
		FROM source_proaktiv.cuts AS c
		INNER JOIN source_proaktiv.cut_pl AS cp
		ON c.cut_number = cp.cut_number
		INNER JOIN source_proaktiv.materials AS m
		ON cp.mat_code = m.mat_code
		WHERE m.mat_cls_number NOT IN (500, 501, 502, 503, 504, 505)
		AND CASE
			WHEN cp.cut_pl_req_qty - cp.cut_pl_used_qty > 0 THEN cp.cut_pl_req_qty - cp.cut_pl_used_qty
			ELSE NULL
		END IS NOT NULL
		AND c.cut_prod_date BETWEEN CONVERT(date, GETDATE()) AND CONVERT(date, GETDATE()+56)
		GROUP BY cp.mat_code
	) AS mr8
	
	-- Consulta "mr16" que me trae la cantidad requerida por material de
	-- 9 a 16 semanas.
	FULL OUTER JOIN (
		SELECT cp.mat_code AS material_code,
			
			SUM(
				CASE
					WHEN cp.cut_pl_req_qty - cp.cut_pl_used_qty > 0 THEN cp.cut_pl_req_qty - cp.cut_pl_used_qty
					ELSE NULL
				END
			) AS required_quantity_16_weeks
			
		FROM source_proaktiv.cuts AS c
		INNER JOIN source_proaktiv.cut_pl AS cp
		ON c.cut_number = cp.cut_number
		INNER JOIN source_proaktiv.materials AS m
		ON cp.mat_code = m.mat_code
		WHERE m.mat_cls_number NOT IN (500, 501, 502, 503, 504, 505)
		AND CASE
			WHEN cp.cut_pl_req_qty - cp.cut_pl_used_qty > 0 THEN cp.cut_pl_req_qty - cp.cut_pl_used_qty
			ELSE NULL
		END IS NOT NULL
		AND c.cut_prod_date BETWEEN CONVERT(date, GETDATE() + 57) AND CONVERT(date, GETDATE() + 112)
		GROUP BY cp.mat_code
	) AS mr16
	ON mr8.material_code = mr16.material_code
) AS mr

-- Consulta "mr24" que me trae la cantidad requerida por material de
-- 17 a 24 semanas.
FULL OUTER JOIN (
	SELECT cp.mat_code AS material_code,
		
		SUM(
			CASE
				WHEN cp.cut_pl_req_qty - cp.cut_pl_used_qty > 0 THEN cp.cut_pl_req_qty - cp.cut_pl_used_qty
				ELSE NULL
			END
		) AS required_quantity_24_weeks
		
	FROM source_proaktiv.cuts AS c
	INNER JOIN source_proaktiv.cut_pl AS cp
	ON c.cut_number = cp.cut_number
	INNER JOIN source_proaktiv.materials AS m
	ON cp.mat_code = m.mat_code
	WHERE m.mat_cls_number NOT IN (500, 501, 502, 503, 504, 505)
	AND CASE
			WHEN cp.cut_pl_req_qty - cp.cut_pl_used_qty > 0 THEN cp.cut_pl_req_qty - cp.cut_pl_used_qty
			ELSE NULL
		END IS NOT NULL
	AND c.cut_prod_date BETWEEN CONVERT(date, GETDATE() + 113) AND CONVERT(date, GETDATE() + 168)
	GROUP BY cp.mat_code
) AS mr24
ON mr.material_code = mr24.material_code