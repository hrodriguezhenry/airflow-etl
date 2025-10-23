SELECT pr.id,
	pr."name",
	pr.stage_id,
	pr."order",
	pr.scan_type_id,
	pr.required_scan,
	pr.sfc_block_route_id,
	pr."active",
	pr.created_at,
	pr.updated_at
FROM Production_Route AS pr
WHERE pr.deleted_at IS NULL