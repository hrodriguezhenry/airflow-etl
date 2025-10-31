SELECT puu.UND_CODGRLC AS cod_company,
    puu.UND_CODIGO AS cod_unit,
    puu.UND_NOMBRE AS cost_center_description,
    puu.UND_VAR1 AS cost_center,
    'N' AS delete_row
FROM PAZ_UND_UNIDAD AS puu