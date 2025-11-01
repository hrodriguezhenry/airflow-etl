SELECT c.ClrNumber AS clr_number,
    c.ClrDesc AS clr_desc,
    c.ClrShortDesc AS clr_short_desc
FROM Colors AS c
WHERE DATE(c.UpdateDate) >= DATE_SUB(CURDATE(), INTERVAL 3 DAY)