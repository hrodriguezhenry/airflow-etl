SELECT u.UsrNumber AS usr_number,
    u.EmpCode AS emp_code,
    u.UsrLogin AS usr_login,
    u.UsrName AS usr_name,
    u.PepsUseID AS pep_use_id,
    u.IsVendor AS is_vendor
FROM Users AS u