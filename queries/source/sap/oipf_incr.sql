SELECT oi."DocEntry" AS doc_entry,
    oi."DocDate" AS doc_date,
    oi."UpdateDate" AS update_date,
    oi."CreateDate" AS create_date,
    oi."U_FecPol" AS u_pol_date,
    oi."U_GEI" AS u_gei
FROM "SBO_TATA_GO_LIVE".OIPF AS oi
WHERE oi."CreateDate" >= ADD_DAYS(CURRENT_DATE, -7)
OR oi."UpdateDate" >= ADD_DAYS(CURRENT_DATE, -7)