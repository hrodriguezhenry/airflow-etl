SELECT sgor.id,
    sgor.group_operation_id,
    sgor.operation_id,
    sgor.multiple_group
FROM SFC_Group_Operation_Ref AS sgor
WHERE sgor.deleted_at IS NULL
AND CONVERT(date, sgor.updated_at) >= CONVERT(date, GETDATE() - 1)