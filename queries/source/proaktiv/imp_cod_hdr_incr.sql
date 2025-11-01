SELECT ich.IDImpCodHdr AS id_imp_cod_hdr,
    ich.ImpCodHdr AS imp_cod_hdr
FROM ImpCodHdr AS ich
WHERE DATE(ich.UpdateDate) >= DATE_SUB(CURDATE(), INTERVAL 3 DAY)