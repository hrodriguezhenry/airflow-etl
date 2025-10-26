SELECT igmdd.id,
	igmdd.group_mark_id,
	igmdd.mark_id,
	igmdd.operation_id,
	igmdd.cod_employee,
	igmdd.created_at
FROM Inspection_Group_Mark_Defect_Detail AS igmdd
WHERE igmdd.deleted_at IS NULL