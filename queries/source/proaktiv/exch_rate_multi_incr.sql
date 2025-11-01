SELECT erm.ExchCurrCodeOrig AS exch_curr_code_orig,
    erm.ExchCurrCodeDest AS exch_curr_code_dest,
    erm.ExchRate AS exch_rate,
    erm.ExchDate AS exch_date
FROM ExchRateMulti AS erm
WHERE erm.ExchDate >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)