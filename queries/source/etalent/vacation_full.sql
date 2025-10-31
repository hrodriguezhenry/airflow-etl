SELECT pdvc.DVCON_VBCODE AS cod_vacation,
    pdvc.DVCON_CODCIA AS cod_company,
    pdvc.DVCON_CODEMP AS cod_employee,
    pdvc.DVCON_PERIODO AS cod_payroll,
    pdvc.DVCON_DESDE AS start_date,
    pdvc.DVCON_HASTA AS end_date,
    pdvc.DVCON_DIAS AS days
FROM PAZ_DVCON_DET_VACACION AS pdvc