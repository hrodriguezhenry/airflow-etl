SELECT DISTINCT
    CRC32(CONCAT_WS(
        COALESCE(cpr.CutNumber, 'N/A'),
        COALESCE(cpr.MatCode, 'N/A')
    )) AS unique_id,
    cpr.CutNumber AS cut_number,
    cpr.MatCode AS mat_code,
    cpr.MatCreatedSAP AS mat_created_sap,
    cpr.CutPlReqQty AS cut_pl_req_qty,
    cpr.CutPlManMat AS cut_pl_man_mat,
    cpr.CutPlReqQtyOrig AS cut_pl_req_qty_orig,
    cpr.CutPlBalance AS cut_pl_balance,
    cpr.POHdrNumber AS po_hdr_number,
    cpr.IDManReq AS id_man_req,
    cpr.CutPlGenerar AS cut_pl_generate,
    cpr.CutPlGenPO AS cut_pl_gen_po,
    cpr.CutPl2ndClassInv AS cut_pl_2nd_classs_inv,
    cpr.CutPlReqTheorist AS cut_pl_req_theorist,
    cpr.CutPlUsedQty AS cut_pl_used_qty,
    cpr.MatCodeOrigSus AS mat_code_orig_sus,
    cpr.UpdateDate AS update_date
FROM CutPlReposition AS cpr