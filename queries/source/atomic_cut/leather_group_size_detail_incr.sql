SELECT clgsd.id,
	clgsd.cut_leather_detail_id,
	clgsd.cut_leather_group_size_id,
	clgsd.parent_id,
	clgsd.adjustment_unit,
	clgsd.created_at
FROM Cut_Leather_Group_Size_Detail AS clgsd
WHERE clgsd.deleted_at IS NULL
AND clgsd.updated_at >= CONVERT(date, GETDATE() -3)