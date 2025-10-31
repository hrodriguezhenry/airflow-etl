SELECT sdd.id,
    sdd.sfc_devolution_id,
    sdd.surplus_inventory_id,
    sdd.type,
    sdd.material_code,
    sdd.approved_units,
    sdd.rejected_units,
    sdd.returned_units,
    sdd.created_at,
    sdd.updated_at
FROM SFC_Devolution_Detail AS sdd
WHERE sdd.deleted_at IS NULL
AND CONVERT(date, sdd.updated_at) >= CONVERT(date, GETDATE() -3)