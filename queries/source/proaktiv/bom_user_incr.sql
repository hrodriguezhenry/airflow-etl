SELECT bu.StlNumber AS stl_number,
    bu.ClrNumber AS clr_number,
    bu.UsrNumber AS usr_number,
    IF(bu.BmRFecha = '0000-00-00 00:00:00', NULL, bu.BmRFecha) AS date,
    bu.PDMFormId AS form_id
FROM BOM_Usuario AS bu
WHERE DATE(bu.UpdateDate) >= DATE_SUB(CURDATE(), INTERVAL 2 DAY)