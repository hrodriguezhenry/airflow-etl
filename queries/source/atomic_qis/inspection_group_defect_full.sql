SELECT igd.id,
	igd.`name`,
	igd.`active`,
	igd.created_at,
	igd.updated_at
FROM Inspection_Group_Defect AS igd
WHERE igd.deleted_at IS NULL