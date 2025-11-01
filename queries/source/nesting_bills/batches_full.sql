SELECT b.BatchId AS batch_id,
    b.Name AS name,
    b.ParentBatchId AS parent_batch_id,
    b.MaterialCodeId AS material_code_id
FROM Batches AS b