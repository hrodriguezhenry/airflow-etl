SELECT hth.HTransporte AS h_transport,
    hth.UsuarioCreacion AS creation_user,
    hth.FechaCreacion AS creation_date,
    hth.FechaAsignacion AS assignment_date,
    hth.Estado AS status
FROM HTransporteHdr AS hth