SELECT cc.nID AS id,
    cc.nSenderId AS sender_id,
    cc.strName AS `name`,
    cc.nMailingListId AS mailing_list_id,
    cc.bIsArchived AS is_archived,
    cc.nEndAction AS end_action,
    cc.bDeleted AS deleted
FROM cf_circulationform AS cc
WHERE cc.bDeleted = 0