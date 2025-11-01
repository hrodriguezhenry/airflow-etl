SELECT a.AuditCorr AS audit_corr,
    a.AuditTable AS audit_table,
    a.AuditField AS audit_field,
    a.AuditKey1 AS audit_key_1,
    a.AuditKey2 AS audit_key_2,
    a.AuditKey3 AS audit_key_3,
    a.AuditKey4 AS audit_key_4,
    a.AuditKey5 AS audit_key_5,
    a.AuditOldValue AS audit_old_value,
    a.AuditNewValue AS audit_new_value,
    a.AuditDateTime AS audit_date_time,
    a.UsrNumber AS usr_number,
    a.AuditIP AS audit_ip,
    a.MenuId AS menu_id,
    a.AutoUpdate AS auto_update
FROM Audit AS a
WHERE a.AutoUpdate >= DATE_SUB(CURDATE(), INTERVAL 2 DAY)