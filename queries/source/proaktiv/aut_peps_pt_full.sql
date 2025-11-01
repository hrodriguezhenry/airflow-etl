SELECT app.idAutorizacion AS id_authorization,
    app.autcorrelativo AS correlative,
    app.autEstado AS status,
    app.autReason AS reason,
    app.autUserSolicitante AS requesting_user,
    app.autUserSolAutoriza AS requesting_user_authorizing,
    app.autUserAutoriza AS authorizing_user,
    app.autUserRechaza AS rejecting_user,
    app.autDateAutorizado AS authorization_date,
    app.autDateRechazado AS rejection_date,
    app.autDatePendiente AS pending_date,
    app.autDateMto AS mto_date,
    app.UpdateDate AS update_date
FROM autPepsPt AS app