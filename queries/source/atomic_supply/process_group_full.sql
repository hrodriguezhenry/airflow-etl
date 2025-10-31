SELECT spg.id,
    spg.`name`,
    spg.`active`,
    spg.created_at,
    spg.updated_at
FROM Supply_Process_Group AS spg
WHERE spg.deleted_at IS NULL