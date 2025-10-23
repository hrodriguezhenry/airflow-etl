SELECT dr.id,
	dr.id_reposition AS reposition_id,
	dr.id_operation AS operation_id,
	dr.sz_dim_det_number,
	dr.suggest_qyt,
	dr.request_qyt,
	dr.created_at,
	dr.updated_at
FROM Detail_Reposition AS dr
WHERE dr.deleted_at IS NULL