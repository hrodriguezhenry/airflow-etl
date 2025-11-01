SELECT foh.StlNumber AS stl_number,
    foh.ClrNumber AS clr_number,
    foh.CustOrdHdrNumber AS cust_ord_hdr_number,
    foh.FGIProductionDate AS fgi_production_date,
    foh.FGIProductionTime AS fgi_production_time,
    foh.FGIQty AS fgi_qty,
    foh.LineNumber AS line_number
FROM FGIOutputHour AS foh