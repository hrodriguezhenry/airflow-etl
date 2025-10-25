SELECT arrdbd.id,
	arrdbd.revision_detail_box_id,
	arrdbd.defect_id,
	arrdbd.quantity,
	arrdbd.created_at
FROM AQL_RMI_Revision_Detail_Box_Defect AS arrdbd
WHERE arrdbd.deleted_at IS NULL
AND DATE(arrdbd.created_at) >= DATE_SUB(CURDATE(), INTERVAL 3 DAY)