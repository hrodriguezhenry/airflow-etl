SELECT spr.id,
    spr.process_id,
    spr.revision_repair_id,
    spr.revision_repair_detail_id,
    spr.cust_ord_hdr_number,
    spr.units,
    spr.supply_unit_cost,
    spr.created_at,
    spr.created_by,
    spr.updated_at
FROM Supply_Process_Repair AS spr
WHERE spr.deleted_at IS NULL