SELECT spf.id,
    spf.process_id,
    spf.material_id,
    spf.proportion,
    spf.price,
    spf.`active`,
    spf.created_at,
    spf.updated_at
FROM Supply_Process_Formula AS spf
WHERE spf.deleted_at IS NULL
AND DATE(spf.updated_at) >= DATE_SUB(CURDATE(), INTERVAL 3 DAY)