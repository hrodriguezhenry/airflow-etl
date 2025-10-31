SELECT sgo.id,
    sgo.group_operation_id,
    sgo.operation_id,
    sgo.multiple_group
FROM SFC_Group_Operation_Ref AS sgo
WHERE sgo.deleted_at IS NULL