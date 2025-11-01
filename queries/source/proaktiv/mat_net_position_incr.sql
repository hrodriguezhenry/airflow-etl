SELECT mnp.MatCode AS mat_code,
    mnp.RMIQtyProd AS rmi_qty_prod,
    mnp.PODetQtyProd AS po_det_qty_prod,
    mnp.CutPlReqQtyProd AS cut_pl_req_qty_prod,
    mnp.RMIQtyPrepro AS rmi_qty_prepro,
    mnp.PODetQtyPrepro AS po_det_qty_prepro,
    mnp.CutPlReqQtyPrepro AS cut_pl_req_qty_prepro,
    mnp.RMIQtyDev AS rmi_qty_dev,
    mnp.PODetQtyDev AS po_det_qty_dev,
    mnp.CutPlReqQtyDev AS cut_pl_req_qty_dev,
    mnp.RMILandedCostUSD AS rmi_landed_cost_usd,
    mnp.RMIQtyGen AS rmi_qty_gen,
    mnp.PODetQtyGen AS po_det_qty_gen,
    mnp.CutPlReqQtyGen AS cut_pl_req_qty_gen
FROM MatNetPosition AS mnp
WHERE DATE(mnp.UpdateDate) >= DATE_SUB(CURDATE(), INTERVAL 3 DAY)