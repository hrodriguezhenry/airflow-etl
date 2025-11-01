SELECT ot."RateDate" AS rate_date,
    ot."Currency" AS currency,
    ot."Rate" AS rate
FROM SBO_TATA_GO_LIVE.ORTT AS ot
WHERE ot."RateDate" >= ADD_DAYS(CURRENT_DATE, -7)