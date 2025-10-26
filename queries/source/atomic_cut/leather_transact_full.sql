SELECT clt.id,
	clt.cut_leather_group_size_id,
	clt.rmi_ticket_number,
	clt.quantity,
	clt.square_feet_gross,
	clt.square_feet_accept,
	clt.square_feet_rejected,
	clt.panel_number,
	clt.status,
	clt.created_at,
	clt.created_by
FROM Cut_Leather_Transact AS clt
WHERE clt.deleted_at IS NULL