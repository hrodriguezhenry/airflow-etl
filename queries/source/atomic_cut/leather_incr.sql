SELECT cl.id,
	cl.cust_ord_hdr_number,
	cl.cut_leather_group_id,
	cl.stl_number,
	cl.clr_number,
	cl.layer,
	cl."status",
	cl.created_at
FROM Cut_Leather cl
WHERE cl.deleted_at IS NULL
AND CONVERT(date, cl.updated_at) >= CONVERT(date, GETDATE() -3)