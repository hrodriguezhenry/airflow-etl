SELECT j.JobId AS job_id,
    j.Name AS name,
    j.Status AS status,
    j.JobDate AS job_date,
    j.ExplodeType AS explode_type,
    j.ParentJobId AS parent_job_id
FROM Jobs AS j