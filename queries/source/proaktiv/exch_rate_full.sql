SELECT DISTINCT
    CRC32(CONCAT_WS(
        COALESCE(er.CurrCode, 'N/A'),
        COALESCE(er.ExchRate, 'N/A'),
        COALESCE(er.ExchDate, 'N/A')
    )) AS unique_id,
    er.CurrCode AS curr_code,
    er.ExchRate AS exch_rate,
    er.ExchDate AS exch_date
FROM ExchRate AS er