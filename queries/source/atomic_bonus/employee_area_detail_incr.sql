SELECT bead.id,
	bead.employee_area_id,
	bead.min_variability,
	bead.max_variability,
	bead.min_efficiency,
	bead.max_reject,
	bead.amount,
	bead.created_at
FROM Bonus_Employee_Area_Detail AS bead
WHERE bead.deleted_at IS NULL