SELECT o."TransId" AS trans_id,
    o."RefDate" AS ref_date,
    o."Memo" AS memo,
    o."UpdateDate" AS update_date,
    o."CreateDate" AS create_date
FROM SBO_TATA_GO_LIVE.OJDT AS o
WHERE o."CreateDate" >= ADD_DAYS(CURRENT_DATE, -7)
OR o."UpdateDate" >= ADD_DAYS(CURRENT_DATE, -7)