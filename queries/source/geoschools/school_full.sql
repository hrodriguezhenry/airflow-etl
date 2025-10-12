SELECT s.school_id,
	s.`name`,
	s.sector,
	s.address_text,
	s.municipality_id,
	s.school_level_id,
	s.geom,
	s.created_at,
	s.updated_at
FROM school AS s