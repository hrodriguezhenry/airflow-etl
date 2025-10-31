SELECT sprd.id,
    sprd.process_repair_id,
    sprd.process_formula_id,
    sprd.proportion,
    sprd.factor_uom,
    sprd.general_supply,
    sprd.price_unit,
    sprd.general_cost,
    sprd.created_at,
    sprd.updated_at
FROM Supply_Process_Repair_Detail AS sprd
WHERE sprd.deleted_at IS NULL
AND DATE(sprd.updated_at) >= DATE_SUB(CURDATE(), INTERVAL 3 DAY)