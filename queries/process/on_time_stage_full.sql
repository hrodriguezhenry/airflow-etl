SELECT cspq.cust_ord,
    cspq.planning_stage,
    cspq.stage,
    cspq.line,
    cspq.planning_date,
    cspq.planning_week,

    CASE
        WHEN cspq.stage = 'CORTE' THEN ((cspq.produced_quantity + ISNULL(cspf.produced_quantity, 0)) / cspq.total_layers)
        ELSE (cspq.produced_quantity + ISNULL(cspf.produced_quantity, 0))
    END AS produced_quantity,

    cspq.required_quantity,
    cspq.total_layers,
    cspf.scan_date,
    cspf.scan_week,
    cspq.first_day_of_week

FROM (
    SELECT potpa.cust_ord,
        potpa.planning_stage,
        potpa.stage,
        potpa.line,
        potpa.planning_date,
        potpa.planning_week,
        planned_quantity,
        ISNULL(cpf.produced_quantity, 0) AS produced_quantity,
        cq.required_quantity,
        cq.total_layers,
        potpa.first_day_of_week
    FROM process.on_time_planning AS potpa

    INNER JOIN (
        SELECT coh.cust_ord_hdr_number AS cust_ord,
            SUM(cod.cust_ord_det_qty) AS required_quantity,
            CASE WHEN sl.total_layers = 0 THEN 1
            ELSE sl.total_layers END AS total_layers
        FROM source_proaktiv.cust_ord_hdr AS coh
        INNER JOIN source_proaktiv.cust_ord_detail AS cod
        ON coh.cust_ord_hdr_number = cod.cust_ord_hdr_number

        LEFT JOIN (
            SELECT s.stl_number, 
                MAX(csf.cut_10) + MAX(csf.cut_11) AS total_layers
            FROM source_proaktiv.styles s 
            INNER JOIN source_proaktiv.cut_style_fr csf
            ON s.stl_cut_fr = csf.cut_id
            GROUP BY s.stl_number
        ) sl
        ON cod.stl_number = sl.stl_number

        WHERE LEFT(coh.cust_ord_hdr_number, 1) = 'T'
        GROUP BY coh.cust_ord_hdr_number,
        sl.total_layers
    ) AS cq
    ON potpa.cust_ord = cq.cust_ord

    LEFT JOIN (
        SELECT otp.cust_ord,
            otp.stage,
            SUM(otp.produced_quantity) AS produced_quantity,
            SUM(otp.produced_quantity_original) AS produced_quantity_original,
            potp.first_day_of_week
        FROM process.on_time_produced AS otp
        INNER JOIN process.on_time_planning AS potp
        ON otp.cust_ord = potp.cust_ord
        AND otp.stage = potp.stage
        AND otp.scan_date <  potp.first_day_of_week
        GROUP BY otp.cust_ord,
            otp.stage,
            potp.first_day_of_week
    ) AS cpf
    ON potpa.cust_ord = cpf.cust_ord
    AND potpa.stage = cpf.stage
    AND potpa.first_day_of_week = cpf.first_day_of_week

    WHERE CASE
            WHEN potpa.stage = 'CORTE' AND ((potpa.planned_quantity + ISNULL(cpf.produced_quantity_original, 0)) / cq.total_layers) >= cq.required_quantity THEN 'Y'
            WHEN potpa.stage != 'CORTE' AND (potpa.planned_quantity + ISNULL(cpf.produced_quantity_original, 0)) >= cq.required_quantity THEN 'Y'
            ELSE 'N'
        END ='Y'
) AS cspq

LEFT JOIN (
    SELECT otp.cust_ord,
        MAX(otp.scan_date) AS scan_date,
        MAX(otp.scan_week) AS scan_week,
        otp.stage,
        SUM(otp.produced_quantity) AS produced_quantity,
        fl.first_day_of_week
    FROM process.on_time_produced AS otp
    INNER JOIN (
        SELECT w.first_day_of_week,
        	DATEADD(DAY, 1, w.last_day_of_week) AS last_day_of_week
        FROM source_accesorios.weeks AS w
        GROUP BY  w.first_day_of_week,
        	DATEADD(DAY, 1, w.last_day_of_week)
    ) AS fl
    ON otp.scan_date BETWEEN fl.first_day_of_week
    AND fl.last_day_of_week
    GROUP BY otp.cust_ord,
        otp.stage,
        fl.first_day_of_week
) AS cspf
ON cspq.cust_ord = cspf.cust_ord
AND cspq.stage = cspf.stage
AND cspq.first_day_of_week = cspf.first_day_of_week