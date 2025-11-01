SELECT otc.ticket_id,
    CONVERT(otc.subject, CHAR) AS subject,
    CONVERT(otc.priority, SIGNED) AS priority
FROM ost_ticket__cdata AS otc