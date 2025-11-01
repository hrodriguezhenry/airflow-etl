SELECT om."ItemCode" AS item_code,
    om."ItemName" AS item_name,
    om."FrgnName" AS frgn_name,
    om."ItmsGrpCod" AS itms_grp_cod,
    om."SalUnitMsr" AS sal_unit_msr,
    om."InvntryUom" AS invntry_uom,
    om."AvgPrice" AS avg_price,
    om."U_Moneda" AS currency,
    om."U_PrecioBase" AS base_price,
    om."CreateDate" AS create_date,
    om."UpdateDate" AS update_date
FROM SBO_TATA_GO_LIVE.OITM AS om
WHERE om."CreateDate" >= ADD_DAYS(CURRENT_DATE, -7)
OR om."UpdateDate" >= ADD_DAYS(CURRENT_DATE, -7)