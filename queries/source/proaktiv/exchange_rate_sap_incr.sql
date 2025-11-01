SELECT tcs.Id AS id,
    tcs.FECHA AS date,
    tcs.Currency AS currency,
    tcs.Rate AS rate
FROM TipoCambioSAP AS tcs
WHERE DATE(tcs.FECHA) >= DATE_SUB(CURDATE(), INTERVAL 3 DAY)