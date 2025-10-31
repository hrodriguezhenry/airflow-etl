SELECT sp.id,
    sp.`code`,
    sp.`name`,
    sp.uom_units,
    sp.group_id,
    sp.`active`,
    sp.created_at,
    sp.updated_at
FROM Supply_Process AS sp
WHERE sp.deleted_at IS NULL