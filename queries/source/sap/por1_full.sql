SELECT p1."DocEntry" AS doc_entry,
    p1."ItemCode" AS item_code,
    p1."Quantity" AS quantity,
    p1."Price" AS price,
    p1."OpenInvQty" AS open_inv_qty
FROM SBO_TATA_GO_LIVE.POR1 AS p1
INNER JOIN SBO_TATA_GO_LIVE.OPOR AS op
ON p1."DocEntry" = op."DocEntry"