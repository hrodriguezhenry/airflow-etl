SELECT c.CutNumber AS cut_number,
    c.CustOrdHdrNumber AS cust_ord_hdr_number,
    c.CutStatus AS cut_status,
    c.CutProdDate AS cut_prod_date,
    IF(c.CutClosingDate = '0000-00-00', NULL, c.CutClosingDate) AS cut_closing_date
FROM Cuts AS c
WHERE c.CutNumber != ''