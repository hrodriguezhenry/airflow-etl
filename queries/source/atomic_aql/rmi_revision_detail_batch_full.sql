SELECT arrdb.id,
	arrdb.revision_detail_id,
	arrdb.`no`,
	arrdb.created_at
FROM AQL_RMI_Revision_Detail_Batch AS arrdb
WHERE arrdb.deleted_at IS NULL