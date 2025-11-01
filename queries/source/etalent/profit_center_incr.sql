SELECT pccb.CEB_CODCIA AS cod_company,
    pccb.CEB_CODIGO AS cod_profit_center,
    pccb.CEB_DESCRIPCION AS cost_center_description,
    pccb.CEB_CC2 AS cost_center,
    'N' AS delete_row
FROM PAZ_CEB_CENTRO_BENEFICIO AS pccb