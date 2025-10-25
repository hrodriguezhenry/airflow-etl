SELECT bea.id,
	bea.name,
	bea.type,
	bea.active,
	bea.created_at
FROM Bonus_Employee_Area AS bea
WHERE bea.deleted_at IS NULL