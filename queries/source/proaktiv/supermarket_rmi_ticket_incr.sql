SELECT srt.RMITicketNumber AS rmi_ticket_number,
    srt.matCode AS mat_code,
    srt.RMIQty AS rmi_qty,
    srt.RMIAvailableQty AS rmi_available_qty,
    srt.idStatus AS id_status,
    srt.idLocationCode AS id_location_code,
    srt.RMIReceptionCut AS rmi_reception_cut,
    srt.RMIUssuingCut AS rmi_ussuing_cut,
    srt.RMIEntryDate AS rmi_entry_date,
    srt.usrEntry AS usr_entry
FROM supermarket_RMI_Ticket AS srt
WHERE DATE(srt.RMIEntryDate) >= DATE_SUB(CURDATE(), INTERVAL 14 DAY)