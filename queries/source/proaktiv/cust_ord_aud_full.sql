SELECT coa.CustOrdAud_Corr AS cust_ord_aud_corr,
    coa.CustOrdHdrNumber AS cust_ord_hdr_number,
    coa.COAudField AS co_aud_field,
    coa.COAudOldValue AS co_aud_old_value,
    coa.COAudNewValue AS co_aud_new_value,
    coa.COAudDate AS co_aud_date
FROM CustOrdAud AS coa