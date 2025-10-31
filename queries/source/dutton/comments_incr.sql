SELECT c.id,
    c.commentable_type,
    c.commentable_id,
    c.comment,
    c.is_system,
    c.user_id,
    c.created_at,
    c.updated_at
FROM comments AS c
WHERE DATE(c.updated_at) >= CURDATE() - INTERVAL 3 DAY