SELECT ssd.SzDimDetNumber AS sz_dim_det_number,
	ssd.SzDimNumber AS sz_dim_number,
	ssd.SzDimDetSize AS sz_dim_det_size,
	ssd.SzDimDetOrder AS sz_dim_det_order,
	ssd.SzDimUnique AS sz_dim_udnique,
	ssd.SzDimForHanger AS sz_dim_for_hanger
FROM SFC_Size_Detail AS ssd