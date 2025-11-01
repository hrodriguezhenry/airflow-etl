SELECT pdlc.DLC_CODCIA AS cod_company,
    pdlc.DLC_CODEPDO AS cod_employee,
    pdlc.DLC_FECHA_RETIRO AS withdrawal_date,
    pdlc.DLC_COD_CDEV_CDESC AS cod_concept,
    pdlc.DLC_VALOR AS value
FROM PAZ_DLC_DETLIQUIDACION_COLABORADOR AS pdlc
WHERE pdlc.DLC_FECHA_RETIRO >= CONVERT(date, GETDATE() - 14)