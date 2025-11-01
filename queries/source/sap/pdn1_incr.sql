SELECT p1."DocEntry" AS doc_entry,
    p1."LineNum" AS line_num,
    p1."BaseRef" AS base_ref,
    p1."ItemCode" AS item_code,
    p1."DocDate" AS doc_date
FROM SBO_TATA_GO_LIVE.PDN1 AS p1
INNER JOIN SBO_TATA_GO_LIVE.OPDN AS op
ON p1."DocEntry" = op."DocEntry"
WHERE op."CreateDate" >= ADD_DAYS(CURRENT_DATE, -7)
OR op."UpdateDate" >= ADD_DAYS(CURRENT_DATE, -7)