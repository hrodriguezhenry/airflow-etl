SELECT rrp.idReasonRemove AS id_reason_remove,
    rrp.ReasonRemove AS reason_remove,
    rrp.Factory AS factory,
    rrp.TypePeps AS types_peps,
    rrp.ActiveReason AS active_reason
FROM ReasonsRemovePeps AS rrp