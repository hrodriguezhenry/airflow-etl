SELECT pmml.MLD_CODIGO AS cod_reason_liquidation,
    pmml.MLD_CODCIA AS cod_company,
    pmml.MLD_NOMBRE AS name,
    'N' AS delete_row
FROM PAZ_MLD_MOTIVO_LIQUIDACION AS pmml