SELECT h.id id,
    h.date,
    h.code,
    h.description,
    h.invoice,
    h.policy,
    h.purchase_order,
    h.pallets,
    h.leathers,
    h.shipment,
    h.reception,
    h.measurement,
    h.difference,
    h.entry,
    h.supplier,
    h.partial,
    h.pending_validation,
    h.shade_band,
    h.style,
    h.swatch,
    h.preproduction,
    h.complete_order,
    h.production,
    h.status,
    d.name AS decision,
    d.english_name AS decision_english_value,
    h.rejection_ids,
    h.sampling_size,
    h.rejected_qty,
    h.handled_rejected_qty,
    da.id AS vendor_result_id,
    da.name vendor_result,
	da.english_name vendor_english_result,
    ir.reason,
	ir.english_reason
FROM source_inspec_cuero.headers AS h
INNER JOIN source_inspec_cuero.decisions AS d
ON h.status = d.id
LEFT JOIN (
	SELECT rh.header_id,
		STRING_AGG(r.reason, ',') AS reason,
		STRING_AGG(r.english_reason, ',') AS english_reason
	FROM source_inspec_cuero.rejection_header AS rh
	INNER JOIN source_inspec_cuero.rejections AS r
	ON rh.rejection_id = r.id
	GROUP BY rh.header_id
) AS ir
ON h.id = ir.header_id
LEFT JOIN source_inspec_cuero.decisions AS da
ON h.customer_status = da.id
ORDER BY h.id