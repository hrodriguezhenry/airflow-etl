-- PROCESS_PROAKTIV_CONSUMED_MATERIAL_AVAILABLE_RM
-- Update 2023-06-02

-- Consulta que me trae la cantidad de material despachada y en inventario.
SELECT ISNULL(mc.material_code, mi.material_code) AS material_code,
	mc.consumed_quantity,
	mi.available_quantity,
	'N' AS delete_row

-- Cosulta "mc" que me trae la cantidad de material despachado en el lapso
-- de un año
FROM (
	SELECT r.mat_code AS material_code,
		SUM(r.rmi_qty) AS consumed_quantity
	FROM source_proaktiv.rmi AS r
	INNER JOIN source_proaktiv.materials AS m
	ON r.mat_code = m.mat_code
	WHERE r.rmi_status = 'U'
	AND m.mat_active = 'Y'
	AND m.mat_cls_number NOT IN (500, 501, 502, 503, 504, 505)
	AND CONVERT(date, r.rmi_issuing_date)
	BETWEEN CONVERT(date, GETDATE() - 365) AND CONVERT(date, GETDATE())
	GROUP BY r.mat_code
) AS mc

-- Consulta "mi" que me trae la cantidad de material disponible en invertario.
FULL OUTER JOIN (
	SELECT r.mat_code AS material_code,
		SUM(r.rmi_qty) AS available_quantity
	FROM source_proaktiv.rmi AS r
	INNER JOIN source_proaktiv.materials AS m
	ON r.mat_code = m.mat_code
	INNER JOIN source_proaktiv.locations AS l
	ON r.loc_code = l.loc_code
	WHERE r.rmi_status = 'R'
	AND m.mat_active = 'Y'
	AND r.rmi_destination IN (1,2,3)
	AND r.rmi_qty > 0
	AND m.mat_cls_number NOT IN (500, 501, 502, 503, 504, 505)
	GROUP BY r.mat_code
) AS mi
ON mc.material_code = mi.material_code