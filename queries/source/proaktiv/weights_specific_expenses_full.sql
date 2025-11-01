SELECT pgs.IdDoc AS id_doc,
    pgs.MatCode AS mat_code,
    pgs.Cantidad AS quantity,
    pgs.Weight AS weight,
    pgs.TipoDoc AS doc_type,
    pgs.`AddDate` AS add_date
FROM PesosGastosEspecificos AS pgs