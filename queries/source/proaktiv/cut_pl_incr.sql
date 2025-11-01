SELECT cp.CutNumber AS cut_number,
    cp.MatCode AS mat_code,
    cp.CutPlReqQty AS cut_pl_req_qty,
    cp.CutPlReqQtyOrig AS cut_pl_req_qty_orig,
    cp.POHdrNumber AS po_hdr_number,
    cp.IDManReq AS id_man_req,
    cp.CutPlGenPO AS cut_pl_gen_po,
    cp.CutPlUsedQty AS cut_pl_used_qty
FROM CutPl AS cp
WHERE DATE(cp.UpdateDate) >= DATE_SUB(CURDATE(), INTERVAL 2 DAY)