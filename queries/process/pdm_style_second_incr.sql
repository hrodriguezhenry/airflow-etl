SELECT DISTINCT psf.style_id,
	
	CASE
		WHEN psf.input_field_id = 15 THEN 'color'
		WHEN psf.input_field_id = 17 THEN 'class'
		WHEN psf.input_field_id = 20 THEN 'customer_style'
		WHEN psf.input_field_id = 29 THEN 'top_layer_width'
		WHEN psf.input_field_id = 33 THEN 'lining_layer_width'
		WHEN psf.input_field_id = 40 THEN 'filler_layer_width_1'
		WHEN psf.input_field_id = 41 THEN 'filler_layer_width_2'
		WHEN psf.input_field_id = 1502 THEN 'filler_layer_width_3'
		WHEN psf.input_field_id = 28 THEN 'top_layer_code'
		WHEN psf.input_field_id = 32 THEN 'lining_layer_code'
		WHEN psf.input_field_id = 38 THEN 'filler_layer_code_1'
		WHEN psf.input_field_id = 39 THEN 'filler_layer_code_2'
		WHEN psf.input_field_id = 1501 THEN 'filler_layer_code_3'
		WHEN psf.input_field_id = 1618 THEN 'top_glue'
		WHEN psf.input_field_id = 1619 THEN 'bottom_glue'
		WHEN psf.input_field_id = 1623 THEN 'glue_layers'
		WHEN psf.input_field_id = 1844 THEN 'glue_layers_2'
		WHEN psf.input_field_id = 1744 THEN 'ornamental_glue'
		WHEN psf.input_field_id = 1973 THEN 'sets_glue'
		WHEN psf.input_field_id = 1747 THEN 'super_wonder_glue'
		WHEN psf.input_field_id = 52 THEN 'punch_tip'
		WHEN psf.input_field_id = 53 THEN 'punch_holes'
		WHEN psf.input_field_id = 54 THEN 'punch_tail'
		WHEN psf.input_field_id = 55 THEN 'punch_sausage'
		WHEN psf.input_field_id = 64 THEN 'quantity_holes'
		WHEN psf.input_field_id = 76 THEN 'berth_type'
		WHEN psf.input_field_id = 79 THEN 'buckle'
		WHEN psf.input_field_id = 82 THEN 'printed'
		WHEN psf.input_field_id = 189 THEN 'punch_perforation'
		WHEN psf.input_field_id = 190 THEN 'feather_edge_roller'
		WHEN psf.input_field_id = 192 THEN 'size_1'
		WHEN psf.input_field_id = 193 THEN 'size_2'
		WHEN psf.input_field_id = 194 THEN 'size_3'
		WHEN psf.input_field_id = 195 THEN 'size_4'
		WHEN psf.input_field_id = 196 THEN 'size_5'
		WHEN psf.input_field_id = 197 THEN 'size_6'
		WHEN psf.input_field_id = 198 THEN 'size_7'
		WHEN psf.input_field_id = 199 THEN 'size_8'
		WHEN psf.input_field_id = 200 THEN 'size_9'
		WHEN psf.input_field_id = 201 THEN 'size_10'
		WHEN psf.input_field_id = 202 THEN 'size_11'
		WHEN psf.input_field_id = 203 THEN 'size_12'
		WHEN psf.input_field_id = 204 THEN 'size_1_measure'
		WHEN psf.input_field_id = 205 THEN 'size_2_measure'
		WHEN psf.input_field_id = 206 THEN 'size_3_measure'
		WHEN psf.input_field_id = 207 THEN 'size_4_measure'
		WHEN psf.input_field_id = 208 THEN 'size_5_measure'
		WHEN psf.input_field_id = 209 THEN 'size_6_measure'
		WHEN psf.input_field_id = 210 THEN 'size_7_measure'
		WHEN psf.input_field_id = 211 THEN 'size_8_measure'
		WHEN psf.input_field_id = 212 THEN 'size_9_measure'
		WHEN psf.input_field_id = 213 THEN 'size_10_measure'
		WHEN psf.input_field_id = 214 THEN 'size_11_measure'
		WHEN psf.input_field_id = 215 THEN 'size_12_measure'
		WHEN psf.input_field_id = 231 THEN 'buckle_2'
		WHEN psf.input_field_id = 336 THEN 'final_width'
		WHEN psf.input_field_id = 339 THEN 'point_armhole'
		WHEN psf.input_field_id = 658 THEN 'edge'
		WHEN psf.input_field_id = 725 THEN 'prints_quantity'
		WHEN psf.input_field_id = 747 THEN 'type_seams'
		WHEN psf.input_field_id = 1017 THEN 'type_belt'
		WHEN psf.input_field_id = 1369 THEN 'replacement_buckle'
		WHEN psf.input_field_id = 1707 THEN 'sets_1'
		WHEN psf.input_field_id = 1723 THEN 'leather_family'
		WHEN psf.input_field_id = 2121 THEN 'dutton_style_type'
		WHEN psf.input_field_id = 133 THEN 'ppp_top_edge'
	END AS "column",

	psf.final_value AS value
		
FROM process.pdm_style_first AS psf
WHERE psf.input_field_id IN (
	15, 17, 20, 28, 29, 32, 33, 38, 39, 40, 41, 52, 53, 54, 55, 64, 76, 79, 82, 133, 189, 190, 192, 193,
	194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212,
	213, 214, 215, 231, 336, 339, 658, 725, 747, 1017, 1369, 1501, 1502, 1618, 1619, 1623, 1707, 1723,
	1744, 1747, 1844, 1973, 2121
)

UNION ALL

SELECT upps.style_id,
	upps."column",
	upps.value
FROM (
	SELECT ptps.style_id,
		
		CONVERT(VARCHAR,
			CASE 
				WHEN CHARINDEX('desvira', ptps."47") >  CHARINDEX('pegado', ptps."47") THEN 'Y'
				WHEN CHARINDEX('refila', ptps."47") >  CHARINDEX('pegado', ptps."47") THEN 'Y'
				ELSE 'N'
			END) AS edge_trimming_glued,
		
		CONVERT(VARCHAR,
			CASE 
				WHEN ptps."50" LIKE '%sisa de cuerpo en superficie%' THEN 'Y'
				WHEN ptps."50" LIKE '%siza del cuerpo en superficie%' THEN 'Y'
				WHEN ptps."50" LIKE '%siza del cuerpo en superficie%' THEN 'Y'
				ELSE 'N'
			END) AS filch_body_top,
		
		CONVERT(VARCHAR,
			CASE 
				WHEN ptps."50" LIKE '%sisa de cuerpo en el respaldo%' THEN 'Y'
				WHEN ptps."50" LIKE '%isa en el cuerpo en respaldo%' THEN 'Y'
				WHEN ptps."50" LIKE '%siza del cuerpo en superficie y respaldo%' THEN 'Y'
				ELSE 'N'
			END) AS filch_body_lining,
		
		CONVERT(VARCHAR,
			CASE
				WHEN ptps."178" IS NULL OR ptps."178" = 'N/A' THEN '0'
				ELSE ptps."178"
			END) AS quantity_barrettes,
		
		CONVERT(VARCHAR,
			CASE
				WHEN ptps."329" IS NULL THEN 'N'
				ELSE 'Y'
			END) AS hanger,
		
		CONVERT(VARCHAR,
			CASE WHEN ptps."495" IS NULL OR ptps."495" = 'No' THEN 'N' ELSE 'Y'
			END) AS first_edge_inking,
		
		CONVERT(VARCHAR,
			CASE WHEN ptps."496" IS NULL OR ptps."496" = 'No' THEN 'N' ELSE 'Y'
			END) AS second_edge_inking,
		
		CONVERT(VARCHAR,
			CASE WHEN ptps."590" IS NULL OR ptps."590" = 'No' THEN 'N' ELSE 'Y'
			END) AS brooch,
		
		CONVERT(VARCHAR,
			CASE WHEN ptps."655" IS NULL OR ptps."655" = 'No' THEN 'N' ELSE 'Y'
			END) AS scumble,
		
		CONVERT(VARCHAR,
			CASE WHEN ptps."748" IS NULL OR ptps."748" = 'N/A' THEN '0' ELSE ptps."748"
			END) AS quantity_seams,
		
		CONVERT(VARCHAR,
			CASE WHEN ptps."759" IS NULL OR ptps."759" = 'No' THEN 'N' ELSE 'Y'
			END) AS manual_berthing,
		
		CONVERT(VARCHAR,
			CASE 
				WHEN ptps."769" LIKE '%No quitar la bolsa protectora que trae la hebilla%' THEN 'Y'
				WHEN (ptps."769" LIKE '%forra%' OR ptps."769" LIKE '%forro%' 
				OR ptps."769" LIKE '%NO retirar%'
				OR ptps."769" LIKE '%NO quitar%')
				AND ptps."769" NOT LIKE '%cuero%' 
				AND  ptps."769" NOT LIKE '% TRENZA%'
				AND ptps."769" LIKE '%hebilla%' THEN 'Y'
				WHEN ptps."769" IS NULL THEN 'N'
				ELSE 'N'
			END) AS buckle_lining,
		
		CONVERT(VARCHAR,
			CASE 
				WHEN ptps."769" LIKE '%Quitar la bolsa despues de QA antes de empaque%' THEN 'Y'
				WHEN ptps."769" LIKE '%QA%' AND ptps."769" LIKE '%bolsa%' 
				AND (ptps."769" LIKE '%quitar%' OR ptps."769" LIKE '%retirar%') THEN 'Y'
				WHEN ptps."769" IS NULL THEN 'N'
				ELSE 'N'
			END) AS remove_buckle_lining,
		
		CONVERT(VARCHAR,
			CASE
				WHEN (ptps."769" LIKE '%bolsa%' OR ptps."769" LIKE '%pol%')
				AND ptps."769" LIKE '%10"%'
				AND ptps."769" NOT LIKE '%No lleva polybag de 10%'
				AND ptps."769" NOT LIKE '%No llevara poly%'
				AND ptps."769" NOT LIKE '%No debe de llevar Polybag de 10%'
				AND ptps."769" NOT LIKE '%No debe llevar poly%'
				AND ptps."769" NOT LIKE '%No aplica poly%'
				AND ptps."769" NOT LIKE '%No debe de utilizar bolsa polibag de 10%'
				AND ptps."769" NOT LIKE '%No debe de lleva polybag%'
				AND ptps."769" NOT LIKE '%No debe de llevar Poly%' THEN 'Y'
				WHEN ptps."769" IS NULL THEN 'N'
				ELSE 'N'
			END) AS place_bag_10,
			
		CONVERT(VARCHAR,
			IIF(ptps."1618" IS NULL, 0, 1) +
			IIF(ptps."1619" IS NULL, 0, 1) +
			IIF(ptps."1623" IS NULL, 0, 1) +
			IIF(ptps."1844" IS NULL, 0, 1)) AS couplings,
			
		CONVERT(VARCHAR,
			CASE WHEN ptps."1620" IS NULL OR ptps."1620" = 'No' THEN 'N' ELSE 'Y'
			END) AS third_edge_inked,
		
		CONVERT(VARCHAR,
			CASE WHEN ptps."1663" IS NULL OR ptps."1663" = 'No' THEN 'N' ELSE 'Y'
			END) AS ecological_glue,
		
		CONVERT(VARCHAR,
			IIF(ptps."1859" IS NULL, 0, 1)) AS prelaminated
		
	FROM (
		SELECT DISTINCT psf.style_id,
			psf.input_field_id,
			psf.final_value AS value	
		FROM process.pdm_style_first AS psf
		WHERE psf.input_field_id IN (
			47, 50, 178, 329, 495, 496, 590, 655, 748, 759, 769, 1618, 1619,
			1620, 1623, 1663, 1844, 1859
		)
		
	) AS ps
	PIVOT (
		MAX(value)
		FOR input_field_id IN (
			[47], [50], [178], [329], [495], [496], [590], [655], [748], [759], [769], [1618], [1619],
			[1620], [1623], [1663], [1844], [1859]
		)
	) AS ptps
) AS psfs
UNPIVOT (
	value FOR "column" IN (
		edge_trimming_glued, filch_body_top, filch_body_lining, quantity_barrettes, hanger,
		first_edge_inking, second_edge_inking, brooch, scumble, quantity_seams, manual_berthing,
		buckle_lining, remove_buckle_lining, place_bag_10, couplings, third_edge_inked,
		ecological_glue, prelaminated
	)
) AS upps
 
UNION ALL

SELECT upps.style_id,
	upps."column",
	upps.value
FROM (
	SELECT ptps.style_id,
		
		CONVERT(VARCHAR,
			CASE
				WHEN ptps."47" LIKE '%feather edge en superficie y respaldo%' THEN 'Y'
				WHEN ptps."47" LIKE '%feather edge en superficie y en respaldo%' THEN 'Y'
				WHEN ptps."47" LIKE '%CONSTRUCCION FEATHER EDGE STRETCH%' THEN 'Y'
				WHEN ptps."47" LIKE '%PROCESO PARA FEATHER EDGE NORMAL 4 CAPAS CON COSTURA%' THEN 'Y'
				WHEN ptps."47" LIKE '%feather edge en ambas capas%' THEN 'Y'
				WHEN ptps."47" LIKE '%feather edge en ambas capas%' THEN 'Y'
				WHEN ptps."47" LIKE '%feather edge a superficie y respaldo%' THEN 'Y'
				WHEN ptps."47" LIKE '%feather edge en orillas en superficie y respaldo%' THEN 'Y'
				WHEN ptps."47" LIKE '%CONSTRUCCION FEATHER EDGE STRETCH%' THEN 'Y'
				WHEN ptps."47" LIKE '%PROCESO PARA FEATHER EDGE NORMAL 4 CAPAS CON COSTURA%' THEN 'Y'
				WHEN ptps."47" LIKE '%feather edge en ambas capas%' THEN 'Y'
				WHEN ptps."47" LIKE '%feather Edge solo en capa de superficie%' THEN 'Y'
				WHEN ptps."47" LIKE '%feather Edge solo en capa de superficie%' THEN 'Y'
				WHEN ptps."47" LIKE '%feather edge solo en superficie%' THEN 'Y'
				WHEN ptps."47" LIKE '%vaciado en superficie con rodillo feather%' THEN 'Y'
				ELSE 'N'
			END) AS feather_edge_top,
		
		CONVERT(VARCHAR,
			CASE 
				WHEN ptps."47" LIKE '%feather edge en superficie y respaldo%' THEN 'Y'
				WHEN ptps."47" LIKE '%feather edge en superficie y en respaldo%' THEN 'Y'
				WHEN ptps."47" LIKE '%CONSTRUCCION FEATHER EDGE STRETCH%' THEN 'Y'
				WHEN ptps."47" LIKE '%PROCESO PARA FEATHER EDGE NORMAL 4 CAPAS CON COSTURA%' THEN 'Y'
				WHEN ptps."47" LIKE '%feather edge en ambas capas%' THEN 'Y'
				WHEN ptps."47" LIKE '%feather edge en ambas capas%' THEN 'Y'
				WHEN ptps."47" LIKE '%feather edge a superficie y respaldo%' THEN 'Y'
				WHEN ptps."47" LIKE '%feather edge en orillas en superficie y respaldo%' THEN 'Y'
				WHEN ptps."47" LIKE '%CONSTRUCCION FEATHER EDGE STRETCH%' THEN 'Y'
				WHEN ptps."47" LIKE '%PROCESO PARA FEATHER EDGE NORMAL 4 CAPAS CON COSTURA%' THEN 'Y'
				WHEN ptps."47" LIKE '%feather edge en ambas capas%' THEN 'Y'
				WHEN ptps."47" LIKE '%feather edge solo en respaldo%' THEN 'Y'
				WHEN ptps."47" LIKE '%feather edge solo en capa de respaldo%' THEN 'Y'
				WHEN ptps."47" LIKE '%feather edge solo en la capa de respaldo%' THEN 'Y'
				WHEN ptps."47" LIKE '%feather edge solo en la capa de respaldo%' THEN 'Y'
				WHEN ptps."47" LIKE '%feather Edge en respaldo%' THEN 'Y'
				ELSE 'N'
			END) AS feather_edge_lining,
		
		CONVERT(VARCHAR,
			CASE WHEN ptps."47" LIKE '%desbast%' THEN 'Y' ELSE 'N'
			END)AS roughing_glued,
		
		CONVERT(VARCHAR,
			CASE WHEN ptps."50" LIKE '%planchar%' THEN 'Y' ELSE 'N'
			END) AS to_iron_body,
		
		CONVERT(VARCHAR,
			CASE WHEN ptps."50" LIKE '%bombea%' THEN 'Y' ELSE 'N'
			END) AS to_pump_body,
		
		CONVERT(VARCHAR,
			CASE WHEN ptps."50" LIKE '%siza de punta%' THEN 'Y' ELSE 'N'
			END) AS filch_tip,
		
		CONVERT(VARCHAR,
			CASE WHEN ptps."50" LIKE '%siza de cuerpo%' THEN 'Y' ELSE 'N'
			END) AS filch_body,
		
		CONVERT(VARCHAR,
			CASE WHEN ptps."50" LIKE '%siza de punta%' AND ptps."50" LIKE '%superficie%'
			AND ptps."50" NOT LIKE '%estampar%' THEN 'Y' ELSE 'N'
			END) AS filch_tip_top,
		
		CONVERT(VARCHAR,
			CASE WHEN ptps."50" LIKE '%siza de punta%' AND ptps."50" LIKE '%respaldo%'
			AND ptps."50" NOT LIKE '%estampar%' THEN 'Y' ELSE 'N'
			END) AS filch_tip_lining,
		
		CONVERT(VARCHAR,
			CASE WHEN ptps."305" IS NULL OR ptps."305" = 'No' THEN 'N' ELSE 'Y'
			END) AS floating_barrette,
		
			
		CONVERT(VARCHAR, ptps."1723") AS leather_family_short_name,
		CONVERT(VARCHAR, ptps."1847") AS blurred_edges

	FROM (
		SELECT DISTINCT psf.style_id,
			psf.input_field_id,
			psf.field_value AS value
		FROM process.pdm_style_first AS psf
		WHERE psf.input_field_id IN (
			47, 50, 305, 1723, 1847
		)
	) AS ps
	PIVOT (
		MAX(value)
		FOR input_field_id IN (
			[47], [50], [305], [1723], [1847]
		)
	) AS ptps
) AS psfs
UNPIVOT (
	value FOR "column" IN (
		feather_edge_top, feather_edge_lining, roughing_glued, to_iron_body, to_pump_body,
		filch_tip, filch_body, filch_tip_top, filch_tip_lining, floating_barrette,
		leather_family_short_name, blurred_edges
	)
) AS upps