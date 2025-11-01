SELECT pllc.LDC_CODCIA AS cod_company,
    pllc.LDC_CODEPDO AS cod_employee,
    pllc.LDC_FECHA_RETIRO AS withdrawal_date,
    pllc.fecha_envio_poliza AS shipping_policy_date
FROM PAZ_LDC_LIQUIDACION_COLABORADOR AS pllc
WHERE pllc.LDC_FECHA_RETIRO >= CONVERT(date, GETDATE() - 14)