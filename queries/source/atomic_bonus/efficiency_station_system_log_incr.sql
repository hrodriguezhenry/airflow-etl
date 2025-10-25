SELECT bessl.id,
	bessl.station_system_id,
	bessl.bonus_efficiency_area_id,
	bessl.active,
	bessl.created_at
FROM Bonus_Efficiency_Station_System_Log AS bessl
WHERE bessl.deleted_at IS NULL