SELECT ssr.id,
    ssr.style_id,
    ssr.stage_id,
    ssr.sfc_sam_id,
    ssr.sequence,
    ssr.active,
    ssr.created_at
FROM SFC_Style_Route AS ssr
WHERE ssr.deleted_at IS NULL
AND ssr.active = 1