SELECT c.CustNumber AS cust_number,
    c.CustName AS cust_name,
    c.CustAbrName AS cust_abr_name,
    c.UsrNumber AS usr_number,
    c.CustGroup AS cust_group,
    c.CustGroupTot AS cust_group_total,
    c.CustActive AS cust_active
FROM Customers AS c