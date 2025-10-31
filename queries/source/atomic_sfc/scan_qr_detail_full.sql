SELECT ssqd.id,
    ssqd.scan_qr_id,
    ssqd.quantity,
    ssqd.quantity_original,
    ssqd.sz_dim_det_number
FROM SFC_Scan_QR_Detail AS ssqd
WHERE ssqd.deleted_at IS NULL