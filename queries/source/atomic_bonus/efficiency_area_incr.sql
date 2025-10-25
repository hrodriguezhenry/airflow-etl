SELECT bea.id,
	bea.name,
	bea.daily,
	bea.type_qa,
	bea.limit_daily_units,
	bea.created_at
FROM Bonus_Efficiency_Area AS bea
WHERE bea.deleted_at IS NULL