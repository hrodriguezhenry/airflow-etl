SELECT am.id,
	am.aql_level,
	am.lot_min,
	am.lot_max,
	am.accept,
	am.reject,
	am.created_at
FROM AQL_Military AS am
WHERE am.deleted_at IS NULL