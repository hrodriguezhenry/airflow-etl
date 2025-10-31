SELECT ssq.id,
    ssq.fgi_ticket_number,
    ssq.location_id,
    ssq.stage_id,
    ssq.layer,
    ssq.rfid_tag_nbr,
    ssq.bundle_nbr,
    ssq.cust_ord_hdr_number,
    ssq.style_id,
    ssq.production_prefix,
    ssq.color_id,
    ssq.cut_number,
    ssq.created_at
FROM SFC_Scan_QR AS ssq
WHERE ssq.deleted_at IS NULL