SELECT spg.id,
    spg.`name`,
    spg.`active`,
    spg.created_at,
    spg.updated_at
FROM Supply_Process_Group AS spg
WHERE spg.deleted_at IS NULL
AND DATE(spg.updated_at) >= DATE_SUB(CURDATE(), INTERVAL 3 DAY)