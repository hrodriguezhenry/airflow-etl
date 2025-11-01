SELECT j."TransId" AS trans_id,
    j."Line_ID" AS line_id,
    j."Account" AS account,
    j."Debit" AS debit,
    j."Credit" AS credit,
    j."Ref1" AS ref_1,
    j."BaseRef" AS base_ref,
    j."ProfitCode" AS profit_code,
    j."OcrCode2" AS ocr_code_2,
    o."CreateDate" AS create_date
FROM SBO_TATA_GO_LIVE.JDT1 AS j
INNER JOIN SBO_TATA_GO_LIVE.OJDT AS o
ON j."TransId" = o."TransId"
WHERE o."CreateDate" >= ADD_DAYS(CURRENT_DATE, -7)
OR o."UpdateDate" >= ADD_DAYS(CURRENT_DATE, -7)