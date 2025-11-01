SELECT om."TransNum" AS trans_num,
    om."ItemCode" AS item_code,
    om."InQty" AS in_qty,
    om."OutQty" AS out_qty,
    om."Warehouse" AS warehouse,
    om."CreateDate" AS create_date
FROM SBO_TATA_GO_LIVE.OINM AS om