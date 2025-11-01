SELECT lph.log_POHdr_id AS log_po_hdr_id,
    lph.POHdrNumber AS po_hdr_number,
    lph.razon AS reason,
    lph.commentForChangeDate AS comment_for_change_date,
    lph.campoAuditado AS audited_field,
    lph.add_fecha AS add_date
FROM log_POHdr AS lph
WHERE DATE(lph.add_fecha) >= DATE_SUB(CURDATE(), INTERVAL 3 DAY)