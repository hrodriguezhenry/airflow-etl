SELECT op."DocEntry" AS doc_entry,
    op."DocNum" AS doc_num,
    op."DocStatus" AS doc_status,
    op."CardCode" AS card_code,
    op."DocDate" AS doc_date,
    op."DocCur" AS doc_cur,
    op."UpdateDate" AS update_date,
    op."CreateDate" AS create_date,
    op."U_IdTrnExt" AS u_id_trn_ext
FROM SBO_TATA_GO_LIVE.OPDN AS op
WHERE op."CreateDate" >= ADD_DAYS(CURRENT_DATE, -7)
OR op."UpdateDate" >= ADD_DAYS(CURRENT_DATE, -7)