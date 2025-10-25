SELECT arrdb.id,
	arrdb.revision_detail_id,
	arrdb.RMITicketNumber AS rmi_ticket_number,
	arrdb.revision_detail_batch_id,
	arrdb.`no`,
	arrdb.units,
	arrdb.audit_units,
	arrdb.`status`,
	IF(arrdb.last_close_at = '0000-00-00', NULL, arrdb.last_close_at) AS last_close_at,
	arrdb.last_close_by,
	arrdb.created_at
FROM AQL_RMI_Revision_Detail_Box AS arrdb
WHERE arrdb.deleted_at IS NULL