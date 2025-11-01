SELECT sd.StlNumber AS stl_number,
    sd.ClrNumber AS clr_number,
    sd.SzDimDetNumber AS sz_dim_det_number,
    sd.StDetActive AS st_det_active,
    sd.StDetUPC AS st_det_upc,
    sd.StDetCustItem AS st_det_cust_item,
    sd.StDetInnerPack AS st_det_inner_pack
FROM StyleDetails AS sd