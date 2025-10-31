SELECT sgo.id,
    sgo.name,
    sgo.type,
    sgo.sequence,
    sgo.active
FROM SFC_Group_Operation AS sgo
WHERE sgo.deleted_at IS NULL
AND sgo.active = 1
AND CONVERT(date, sgo.updated_at) >= CONVERT(date, GETDATE() - 1)