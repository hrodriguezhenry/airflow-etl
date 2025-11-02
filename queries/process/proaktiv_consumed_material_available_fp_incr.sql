-- PROCESS_PROAKTIV_CONSUMED_MATERIAL_AVAILABLE_FP
-- Update 2023-06-02

-- Consulta que me trae la cantidad de material despachada y en inventario.
SELECT ISNULL(mc.material_code, mi.material_code) AS material_code,
	mc.consumed_quantity,
	mi.available_quantity,
	'N' AS delete_row

-- Cosulta "mc" que me trae la cantidad de material despachado en el lapso
-- de un año
FROM (
	SELECT CONCAT(f.stl_number, '-', c.clr_desc) AS material_code,
		SUM(f.fgi_qty) AS consumed_quantity
	FROM source_proaktiv.fgi AS f
	INNER JOIN source_proaktiv.colors AS c
	ON f.clr_number = c.clr_number
	WHERE f.fgi_status = 'U'
	AND f.fgi_ship_date BETWEEN CONVERT(date, GETDATE() - 365) AND CONVERT(date, GETDATE())
	GROUP BY f.stl_number,
		c.clr_desc
) AS mc

-- Consulta "mi" que me trae la cantidad de material disponible en invertario.
FULL OUTER JOIN (
	SELECT CONCAT(f.stl_number, '-', c.clr_desc) AS material_code,
		SUM(f.fgi_qty) AS available_quantity
	FROM source_proaktiv.fgi AS f
	INNER JOIN source_proaktiv.colors AS c
	ON f.clr_number = c.clr_number
	WHERE f.fgi_status = 'R'
	AND f.fgi_qty > 0 
	GROUP BY f.stl_number,
		c.clr_desc
) AS mi
ON mc.material_code = mi.material_code