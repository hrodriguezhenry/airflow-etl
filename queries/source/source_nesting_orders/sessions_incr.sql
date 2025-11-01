SELECT s.SessionId AS session_id,
    s.JobId AS job_id,
    s.Name AS name,
    s.Status AS status,
    s.Priority AS priority,
    s.StrategyExecutableFileId AS strategy_executable_file_id,
    s.NestingParameterSetId AS nesting_parameter_set_id,
    s.OrderId AS order_id,
    s.MaterialCodeId AS material_code_id,
    s.CuttingMachineId AS cutting_machine_id,
    s.ServerId AS server_id,
    s.PostBuilderExecutableFileId AS post_builder_executable_file_id
FROM Sessions AS s