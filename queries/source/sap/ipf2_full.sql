SELECT ip2."DocEntry" AS doc_entry,
    ip2."AlcCode" AS alc_code,
    ip2."CostType" AS cost_type,
    ip2."CostSumFC" AS cost_sum_fc
FROM "SBO_TATA_GO_LIVE"."IPF2" AS ip2
INNER JOIN "SBO_TATA_GO_LIVE"."OIPF" AS oi
ON ip2."DocEntry" = oi."DocEntry"