SELECT msc.ID AS id,
    msc.COMPANIA AS cod_company,
    msc.ACTIVO AS active,
    msc.DESCRIPCION AS description,
    'N' AS delete_row
FROM MOTIVO_SUSPENSION_CLINICA AS msc