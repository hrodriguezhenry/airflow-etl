SELECT htd.HTransporteHdr AS h_transport_hdr,
    htd.RMITicketNumber AS rmi_ticket_number,
    htd.FechaRecepcionPlantaCorte AS date_reception_plant_cut
FROM HTransporteDetail AS htd
WHERE DATE(htd.UpdateDate) >= DATE_SUB(CURDATE(), INTERVAL 2 DAY)