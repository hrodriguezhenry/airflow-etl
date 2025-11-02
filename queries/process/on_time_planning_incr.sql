SELECT cpq.cust_ord,
	CASE
		WHEN cpq.planning_stage LIKE '%GUILLOTINA%' AND cpq.planning_stage LIKE '%CORTE PIEL%' THEN 'CORTE COMBINADO'
        WHEN cpq.planning_stage LIKE '%CORTE PIEL%' THEN 'CORTE COMBINADO'
		WHEN cpq.planning_stage LIKE '%GUILLOTINA%' THEN 'GUILLOTINA' 
		ELSE cpq.stage
	END AS planning_stage,
		
	cpq.stage,
	cpq.line,
	cpq.planning_date,
	cpq.planning_week,
	cpq.planned_quantity,
    cpq.first_day_of_week

FROM (
	SELECT wp.cust_ord,

		STRING_AGG(wp.stage, ',') AS planning_stage,
		
        CASE
            WHEN wp.stage IN ('CORTE','CORTE PIEL','GUILLOTINA') THEN 'CORTE'
            WHEN wp.stage = 'LAMINADO' THEN 'PEGADO'
            ELSE wp.stage
        END AS stage,

        MAX(wp.line) AS line,
        MAX(CONVERT(date, wp.planning_date)) AS planning_date,
        wp.week AS planning_week,
        SUM(wp.quantity) AS planned_quantity,
		w.first_day_of_week

    FROM source_fast_react.weekly_planning wp
    INNER JOIN source_accesorios.weeks AS w
    ON w.day = wp.planning_date
    INNER JOIN source_accesorios.weeks AS we
    ON we.day = CONVERT(date, GETDATE()-7)
    WHERE wp.stage IN (
        'CORTE',
        'CORTE PIEL',
        'GUILLOTINA',
        'TROQUEL',
        'ESTAMPADO',
        'COSTURA',
        'CUERPOS',
        'PASADORES',
        'LAMINADO',
        'CANTOS',
        'ENSAMBLE',
        'AZ46',
        'SETS',
        'PERFORADO',
        'ESFUMADO',
        'PREENTINTADO',
        'TROQUEL SETS'
    )
    AND wp.planning_date >=

	    CASE
	        WHEN we.day_name = 'LUNES' THEN DATEADD(DAY, -7, we.first_day_of_week)
	        ELSE we.first_day_of_week
	    END

    GROUP BY wp.cust_ord,

        CASE
            WHEN wp.stage IN ('CORTE','CORTE PIEL','GUILLOTINA') THEN 'CORTE'
            WHEN wp.stage = 'LAMINADO' THEN 'PEGADO'
            ELSE wp.stage
        END,
        wp.week,
        w.first_day_of_week
) AS cpq