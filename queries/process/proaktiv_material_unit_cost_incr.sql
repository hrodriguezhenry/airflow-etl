WITH base AS (
	SELECT oi.doc_entry,
		oi.doc_date,
		oi.u_pol_date,
		oi.u_gei,
		ip.item_code,
		ip.card_code,
		ip.reference,
		ora.rate AS rate_usd,
		ore.rate AS rate_eur,
		AVG(ip.price_fob) AS price_fob,
		SUM(ip.quantity) AS quantity,
		SUM(ip.weight_1) AS "weight",
		SUM(ip.fob_value_fc) AS fob
	FROM source_sap_tata_go_live.oipf AS oi
	INNER JOIN source_sap_tata_go_live.ipf1 AS ip
	ON oi.doc_entry = ip.doc_entry
	INNER JOIN source_sap_tata_go_live.ortt AS ora
	ON oi.u_pol_date = ora.rate_date
	AND ora.currency = 'USD'
	INNER JOIN source_sap_tata_go_live.ortt AS ore
	ON oi.u_pol_date = ore.rate_date
	AND ore.currency = 'EUR'
	WHERE GREATEST(oi.doc_date, oi.update_date, oi.create_date, oi.u_pol_date) >= CONVERT(DATE, GETDATE() - 30)
	GROUP BY oi.doc_entry,
		oi.doc_date,
		ip.card_code,
		oi.u_pol_date,
		oi.u_gei,
		ip.item_code,
		ip.card_code,
		ip.reference,
		ora.rate,
		ore.rate
)

SELECT HASHBYTES('SHA1', 
		CONCAT(cs.doc_entry, '|', cs.item_code, '|', ISNULL(cs.purchase_order, ''))
	) AS row_hash,
	
	cs.doc_entry,
	cs.doc_date,
	cs.card_code,
	cs.item_code AS material_code,
	cs.u_pol_date AS purchase_order_date,
	cs.quantity,
	cs.purchase_order,
	cs.currency,
	ROUND(cs.price_fob * cs.rate_usd, 5) AS unit_price,
	
	ROUND(
		CASE
			WHEN cs.quantity > 0 THEN
				CASE
					WHEN cs."weight" > 0 THEN
						(
							(cs."weight" * ISNULL(g.u_freight, 0) / cs.weight_doc_client) +
							(cs."weight" * ISNULL(g.u_merchandise_handling, 0) / cs.weight_doc_client) +
							(cs."weight" * ISNULL(dc.cost_sum_fc, 0) / cs.weight_doc)
						) / cs.quantity
					WHEN cs.fob > 0 THEN
						(
							(cs.fob * ISNULL(g.u_freight, 0) / cs.fob_cod_client) +
							(cs.fob * ISNULL(g.u_merchandise_handling, 0) / cs.fob_cod_client) +
							(cs.fob * ISNULL(dc.cost_sum_fc, 0) / cs.fob_doc)
						) / cs.quantity
					ELSE 0
				END
			ELSE 0
		END * cs.rate_usd,
		5
	) AS unit_cost
	
FROM (
	SELECT DISTINCT tb.doc_entry,
		tb.doc_date,
		tb.u_pol_date,
		tb.u_gei,
		tb.item_code,
		tb.card_code,
		tb.price_fob,
		tb.quantity,
		tb."weight",
		tb.fob,
		op.u_id_trn_ext AS purchase_order,
		op.doc_cur AS currency,
		SUM(tb."weight") OVER (PARTITION BY tb.doc_entry, tb.doc_date, tb.card_code) AS weight_doc_client,
		SUM(tb.fob) OVER (PARTITION BY tb.doc_entry, tb.doc_date, tb.card_code) AS fob_cod_client,
		SUM(tb."weight") OVER (PARTITION BY tb.doc_entry, tb.doc_date) AS weight_doc,
		SUM(tb.fob) OVER (PARTITION BY tb.doc_entry, tb.doc_date) AS fob_doc,
		
		CASE
			WHEN op.doc_cur = 'USD' THEN 1
			WHEN op.doc_cur = 'EUR' THEN tb.rate_eur / tb.rate_usd
			WHEN op.doc_cur = 'QTZ' THEN tb.rate_usd
			ELSE NULL
		END AS rate_usd
		
	FROM base AS tb
	INNER JOIN source_sap_tata_go_live.opdn AS op
	ON tb.reference = op.doc_num
) AS cs

LEFT JOIN source_sap_tata_go_live.ges1 AS g
ON cs.u_gei = g.code
AND cs.card_code = g.u_supplier_code
LEFT JOIN (
	SELECT ip2.doc_entry,
		SUM(ip2.cost_sum_fc) AS cost_sum_fc
	FROM source_sap_tata_go_live.ipf2 AS ip2
	GROUP BY ip2.doc_entry
) AS dc 
ON cs.doc_entry = dc.doc_entry