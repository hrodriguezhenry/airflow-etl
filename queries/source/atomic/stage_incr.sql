SELECT s.id,
	s.name,
	s.production_prefix,
	s.include_efficacy,
	s.reduce_bundle,
	'N' AS delete_row
FROM Stage AS s
WHERE s.deleted_at IS NULL