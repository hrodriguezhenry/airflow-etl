SELECT mc.MaterialCodeId AS material_code_id,
    mc.Code AS code,
    mc.MatType AS mat_type,
    mc.Description AS description,
    mc.Nature AS nature,
    mc.Width AS width,
    mc.Length AS length,
    mc.Thickness AS thickness,
    mc.Layers AS layers,
    mc.Gap AS gap,
    mc.ParentMaterialCodeId AS parent_material_code_id,
    mc.RowVersion AS row_version,
    mc.CostPerSqMt AS cost_per_sq_mt
FROM MaterialCodes AS mc