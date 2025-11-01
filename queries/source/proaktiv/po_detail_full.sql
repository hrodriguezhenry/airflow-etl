SELECT pd.POHdrNumber AS po_hdr_number,
    pd.CutNumber AS cut_number,
    pd.MatCode AS mat_code,
    pd.MatDesc AS mat_desc,
    pd.PODetPrice AS po_det_price,
    pd.PODetQty AS po_det_qty,
    pd.PODetInvQty AS po_det_inv_qty,
    pd.POPrecFact AS po_invoiced_price
FROM PODetail AS pd