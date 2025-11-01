SELECT fohd.StlNumber AS stl_number,
    fohd.ClrNumber AS clr_number,
    fohd.SzDimDetNumber AS sz_dim_det_number,
    fohd.CustOrdHdrNumber AS cust_ord_hdr_number,
    fohd.FGIProductionDate AS fgi_production_date,
    fohd.FGIQty AS fgi_qty,
    fohd.LineNumber AS line_number
FROM FGIOutputHourDetail AS fohd