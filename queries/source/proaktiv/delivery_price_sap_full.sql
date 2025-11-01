SELECT pes.AgentNum AS agent_num,
    pes.U_IdTrnExt AS u_id_trn_ext,
    pes.ItemCode AS item_code,
    pes.DocDate AS doc_date,
    pes.PriceFOB AS price_fob,
    pes.PricAtWHFC AS pric_at_whfc,
    pes.Quantity AS quantity,
    pes.AddID AS add_id,
    pes.Total AS total,
    pes.PymntGroup AS pymnt_group,
    pes.Facturas AS bills,
    pes.DocCur AS doc_cur,
    pes.DocRate AS doc_rate
FROM PrecioEntregaSAP AS pes