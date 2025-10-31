SELECT s.id,
    s.event_type,
    s.event_identifier,
    s."system",
    s.created_at
FROM "Statistics" AS s
WHERE s.deleted_at IS NULL