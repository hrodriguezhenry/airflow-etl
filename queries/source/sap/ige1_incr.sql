SELECT e1."DocEntry" AS doc_entry,
    e1."LineNum" AS line_num,
    e1."BaseRef" AS base_ref,
    e1."ItemCode" AS item_code,
    e1."Dscription" AS dscription,
    e1."Quantity" AS quantity,
    e1."Price" AS price,
    e1."Currency" AS currency,
    e1."Rate" AS rate,
    e1."AcctCode" AS acct_code,
    e1."DocDate" AS doc_date,
    e1."OcrCode" AS ocr_code,
    e1."unitMsr" AS unit_msr,
    e1."StockPrice" AS stock_price,
    e1."OcrCode2" AS ocr_code_2,
    e1."OcrCode3" AS ocr_code_3
FROM SBO_TATA_GO_LIVE.IGE1 AS e1
WHERE e1."DocDate" >= ADD_DAYS(CURRENT_DATE, -7)