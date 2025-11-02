SELECT DISTINCT sc.style_id,
	cfva.input_field_id,
	cfva.field_value,
	cfva.final_value
FROM (
	SELECT CONVERT(INT, cfv.final_value) AS style_id,
		MAX(cfv.circulation_history_id) AS circulation_history_id
	FROM source_pdm.cf_field_value AS cfv
	INNER JOIN source_pdm.cf_field_value AS cfvac
	ON cfv.form_id = cfvac.form_id
	AND cfv.circulation_history_id = cfvac.circulation_history_id
	AND cfvac.input_field_id = 1307
	WHERE cfv.input_field_id = 14
	AND cfvac.final_value IS NOT NULL
	GROUP BY cfv.final_value
) AS sc
LEFT JOIN source_pdm.cf_field_value AS cfva
ON sc.circulation_history_id = cfva.circulation_history_id
AND cfva.input_field_id IN (
	15,   -- Color
	17,   -- Clase
	20,   -- Estilo del Cliente
	28,   -- Código capa superior
	29,   -- Ancho capa superior
	32,   -- Código capa respaldo
	33,   -- Ancho capa respaldo
	38,   -- Código capa relleno 1
	39,   -- Código capa relleno 2
	40,   -- Ancho capa relleno 1
	41,   -- Ancho capa relleno 2
	47,   -- Observaciones de anchos de capas
	50,   -- Acabado del cuerpo
	52,   -- Troquelar punta
	53,   -- Troquelar agujeros
	54,   -- Troquelar cola
	55,   -- Troquelar salchicha
	64,   -- Cantidad de agujeros
	76,   -- Tipo atraque
	79,   -- Hebilla
	82,   -- Estamapado
	133,  -- PPP Orillas superior
	178,  -- Cantidad de pasadores
	189,  -- Troquelar perforado
	190,  -- Rodillo para Feather Edge
	192,  -- Talla 1
	193,  -- Talla 2
	194,  -- Talla 3
	195,  -- Talla 4
	196,  -- Talla 5
	197,  -- Talla 6
	198,  -- Talla 7
	199,  -- Talla 8
	200,  -- Talla 9
	201,  -- Talla 10
	202,  -- Talla 11
	203,  -- Talla 12
	204,  -- Talla 1 Medida
	205,  -- Talla 2 Medida
	206,  -- Talla 3 Medida
	207,  -- Talla 4 Medida
	208,  -- Talla 5 Medida
	209,  -- Talla 6 Medida
	210,  -- Talla 7 Medida
	211,  -- Talla 8 Medida
	212,  -- Talla 9 Medida
	213,  -- Talla 10 Medida
	214,  -- Talla 11 Medida
	215,  -- Talla 12 Medida
	231,  -- Hebilla 2
	305,  -- Pasador flotante
	329,  -- Hanger
	336,  -- B) Ancho final
	339,  -- Siza de punta
	495,  -- Cantos 1er entintado
	496,  -- Cantos 2do entintado
	590,  -- Atraque con Broches
	655,  -- Esfumado
	658,  -- Orilla
	725,  -- Cantidad de Estampados
	747,  -- Tipo costura
	748,  -- Cantidad de costuras
	759,  -- Atraque manual
	769,  -- Observaciones de Herrajes
	1017, -- Tipo de cincho
	1369, -- Hebilla Sustituta
	1501, -- Código capa relleno 3
	1502, -- Ancho capa relleno 3
	1618, -- Pegamento Superior
	1619, -- Pegamento Inferior
	1620, -- Cantos 3er entintado
	1623, -- Pegamento Capas
	1663, -- Pegamento ecológico
	1707, -- Sets 1
	1723, -- Familia de cuero
	1744, -- Pegamento Ornamento
	1747, -- Pegamento Super Wonder
	1844, -- Pegamento Capas 2
	1847, -- Esfumado Orillas
	1859, -- Pre-laminado
	1973, -- Pegamento Sets
	2121  -- Tipo de Estilo Dutton
)