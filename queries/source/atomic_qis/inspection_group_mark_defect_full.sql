SELECT igmd.id,
	igmd.scan_transact_id,
	igmd.scan_transact_date,
	igmd.group_mark_id,
	igmd.distribution_defect_id,
	igmd.created_at
FROM Inspection_Group_Mark_Defect AS igmd
WHERE igmd.deleted_at IS NULL