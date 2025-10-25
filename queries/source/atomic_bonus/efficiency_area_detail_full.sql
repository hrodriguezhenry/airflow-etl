SELECT bead.id,
	bead.bonus_efficiency_area_id,
	bead."min",
	bead."max",
	bead.amount,
	bead."no",
	bead.active,
	bead.created_at
FROM Bonus_Efficiency_Area_Detail AS bead
WHERE bead.deleted_at IS NULL