SELECT scl.id,
	scl.stl_cls_number,
	scl.style_layer_id,
	scl.active,
	scl.created_at
FROM Style_Class_Layer AS scl
WHERE scl.deleted_at IS NULL