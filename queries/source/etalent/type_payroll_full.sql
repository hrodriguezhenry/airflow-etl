SELECT pttp.TPLNA_CODCIA AS cod_company,
    pttp.TPLNA_CODIGO AS cod_type_payroll,
    pttp.TPLNA_DESCRIPCION AS description,
    pttp.TPLNA_TIPO AS type,
    'N' AS delete_row
FROM PAZ_TPLNA_TIPO_PLANILLA AS pttp