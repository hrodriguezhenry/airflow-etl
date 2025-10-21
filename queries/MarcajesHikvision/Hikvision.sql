(SELECT 
	CAST(d.EmployeeCode AS INT) AS CodigoEmpleado,
	d.PersonName,
	d.AccessDateShort,
	MIN(d.AccessTime) AS AccessTime,
	d.Temperature,
	d.Mask,
	MIN(CAST(CONCAT(d.AccessDateShort,' ',d.AccessTime) AS DATETIME)) AS HoraCompleta
FROM Employees2 d 
WHERE 
	d.EmployeeCode NOT LIKE '1844%' 
	AND 
	d.AccessDateShort BETWEEN DATEADD(DAY, -35, GETDATE()) AND FORMAT(GETDATE(), 'yyyy-MM-dd')
GROUP BY
	CAST(d.EmployeeCode AS INT),
	d.PersonName,
	d.AccessDateShort,
	d.Temperature,
	d.Mask)
	
UNION ALL

(SELECT 
	CAST(d.EmployeeCode AS INT) AS CodigoEmpleado,
	d.PersonName,
	d.AccessDateShort,
	MAX(d.AccessTime) AS AccessTime,
	d.Temperature,
	d.Mask,
	MAX(CAST(CONCAT(d.AccessDateShort,' ',d.AccessTime) AS DATETIME)) AS HoraCompleta
FROM Employees2 d 
WHERE 
	d.EmployeeCode NOT LIKE '1844%' 
	AND 
	d.AccessDateShort BETWEEN DATEADD(DAY, -35, GETDATE()) AND FORMAT(GETDATE(), 'yyyy-MM-dd')
GROUP BY
	CAST(d.EmployeeCode AS INT),
	d.PersonName,
	d.AccessDateShort,
	d.Temperature,
	d.Mask
HAVING
	COUNT(CAST(d.EmployeeCode AS INT)) > 1)