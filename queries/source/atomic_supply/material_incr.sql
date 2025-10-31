SELECT sm.id,
    sm.`name`,
    sm.sap_code,
    sm.uom_code,
    sm.price,
    sm.`active`,
    sm.created_at,
    sm.updated_at
FROM Supply_Material AS sm
WHERE sm.deleted_at IS NULL
AND DATE(sm.updated_at) >= DATE_SUB(CURDATE(), INTERVAL 3 DAY)