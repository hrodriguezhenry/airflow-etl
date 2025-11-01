SELECT e.EmployeeID AS employee_id,
    e.AccessDate AS access_date,
    e.AccessDateShort AS access_date_short,
    e.AccessTime AS access_time,
    e.DeviceName AS device_name,
    e.DeviceSerial AS device_serial,
    e.PersonName AS person_name,
    e.EmployeeCode AS employee_code,
    e.Temperature AS temperature,
    e.Mask AS mask,
    e.Direction AS direction,
    e.Us AS us
FROM Employees2 AS e
WHERE e.AccessDateShort >= CONVERT(date, GETDATE() - 3)
ORDER BY e.AccessDateShort ASC
