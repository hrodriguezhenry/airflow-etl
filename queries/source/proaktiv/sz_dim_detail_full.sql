SELECT sdd.SzDimDetNumber AS sz_dim_det_number,
    sdd.SzDimNumber AS sz_dim_number,
    sdd.SzDimDetSize AS sz_dim_det_size,
    sdd.SzDimDetOrder AS sz_dim_det_order,
    sdd.SzDimUnique AS sz_dim_unique,
    sdd.SzDimForHanger AS sz_dim_for_hanger,
    sdd.SzDimSizeForRanda AS sz_dim_size_for_randa
FROM SzDimDetail AS sdd