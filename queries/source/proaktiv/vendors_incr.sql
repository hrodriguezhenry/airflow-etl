SELECT v.VendNumber AS vend_number,
    v.VendName AS vend_name,
    v.CountryCode AS country_code,
    v.ViaCode AS via_code,
    v.VendMoldDaysProd AS vend_mold_days_prod,
    v.VendRevDaysProd AS vend_rev_days_prod,
    v.VendLTFabricationProd AS vend_lt_fabrication_prod,
    v.VendCreateDate AS vend_create_date
FROM Vendors AS v
WHERE DATE(v.UpdateDate) >= DATE_SUB(CURDATE(), INTERVAL 3 DAY)
