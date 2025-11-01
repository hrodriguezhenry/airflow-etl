SELECT rr.RMI_ReposTicketNumber AS rmi_repos_ticket_number,
    rr.LocCode AS loc_code,
    rr.MatCode AS mat_code,
    rr.RMI_ReposReceptionCut AS rmi_repos_reception_cut,
    rr.RMI_ReposIssuingCut AS rmi_repos_issuing_cut,
    rr.RMI_ReposReceptionDate AS rmi_repos_reception_date,
    rr.RMI_ReposIssuingDate AS rmi_repos_issuing_date,
    rr.RMI_ReposQty AS rmi_repos_qty,
    rr.RMI_ReposStatus AS rmi_repos_status,
    rr.UsrNumber AS usr_number,
    rr.RMI_LastTicketScanDate AS rmi_last_ticket_scan_date
FROM RMI_Repos AS rr
