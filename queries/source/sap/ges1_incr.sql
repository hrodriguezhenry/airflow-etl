SELECT g."Code" AS code,
    g."LineId" AS line_id,
    g."U_CodProveedor" AS u_supplier_code,
    g."U_Felete" AS u_freight,
    g."U_ManejoMerc" AS u_merchandise_handling
FROM "SBO_TATA_GO_LIVE"."@GES1" AS g