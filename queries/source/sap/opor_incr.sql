SELECT op."DocEntry" AS doc_entry,
    op."DocNum" AS doc_num,
    op."DocStatus" AS doc_status,
    op."DocDate" AS doc_date,
    op."CardCode" AS card_code,
    op."CardName" AS card_name,
    op."UpdateDate" AS update_date,
    op."CreateDate" AS create_date,
    op."U_IdTrnExt" AS u_id_trn_ext
FROM SBO_TATA_GO_LIVE.OPOR AS op
WHERE op."CreateDate" >= ADD_DAYS(CURRENT_DATE, -7)
OR op."UpdateDate" >= ADD_DAYS(CURRENT_DATE, -7)