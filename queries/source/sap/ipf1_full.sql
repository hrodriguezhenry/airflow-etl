SELECT ip1."DocEntry" AS doc_entry,
    ip1."LineNum" AS line_num,
    ip1."ItemCode" AS item_code,
    ip1."Quantity" AS quantity,
    ip1."PriceFOB" AS price_fob,
    ip1."Weight1" AS weight_1,
    ip1."CardCode" AS card_code,
    ip1."Reference" AS reference,
    ip1."FobValueFC" AS fob_value_fc
FROM "SBO_TATA_GO_LIVE".IPF1 AS ip1