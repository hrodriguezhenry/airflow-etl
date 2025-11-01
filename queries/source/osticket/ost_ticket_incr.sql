SELECT ot.ticket_id,
    ot.number,
    ot.user_id,
    ot.status_id,
    ot.dept_id,
    ot.sla_id,
    ot.topic_id,
    ot.staff_id,
    ot.team_id,
    ot.created,
    ot.closed,
    ot.reopened
FROM ost_ticket AS ot
WHERE DATE(ot.created) >= DATE_SUB(CURDATE(), INTERVAL 3 DAY)