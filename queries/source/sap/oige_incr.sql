SELECT oe."DocEntry" AS doc_entry,
    oe."DocNum" AS doc_num,
    oe."DocDate" AS doc_date,
    oe."CreateDate" AS create_date,
    oe."UpdateDate" AS update_date
FROM SBO_TATA_GO_LIVE.OIGE AS oe
WHERE oe."CreateDate" >= ADD_DAYS(CURRENT_DATE, -7)
OR oe."UpdateDate" >= ADD_DAYS(CURRENT_DATE, -7)