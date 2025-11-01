SELECT pgs.IdDoc AS id_doc,
    pgs.MatCode AS mat_code,
    pgs.Cantidad AS quantity,
    pgs.Weight AS weight,
    pgs.TipoDoc AS doc_type,
    pgs.`AddDate` AS add_date
FROM PesosGastosEspecificos AS pgs
WHERE DATE(pgs.`AddDate`) >= DATE_SUB(CURDATE(), INTERVAL 14 DAY)