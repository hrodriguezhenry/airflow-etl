SELECT ow."ItemCode" AS item_code,
    ow."WhsCode" AS whs_code,
    ow."OnHand" AS on_hand,
    ow."OnOrder" AS on_order,
    ow."createDate" AS create_date,
    ow."updateDate" AS update_date
FROM SBO_TATA_GO_LIVE.OITW AS ow