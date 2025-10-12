SELECT r.review_id,
	r.school_id,
	r.user_id,
	r.rating,
	r.`comment`,
	r.cost,
	r.created_at,
	r.updated_at
FROM review AS r