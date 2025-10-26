SELECT sgmr.id,
	sgmr.group_mark_id,
	sgmr.mark_id
FROM SFC_Group_Mark_Ref AS sgmr
WHERE sgmr.deleted_at IS NULL