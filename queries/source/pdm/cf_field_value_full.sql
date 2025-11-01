SELECT cf.nID AS id,
    cf.nInputFieldId AS input_field_id,
    cf.strFieldValue AS field_value,
    cf.nSlotId AS slot_id,
    cf.nFormId AS form_id,
    cf.nCirculationHistoryId AS circulation_history_id,
    cf.strFinalValue AS final_value,
    'N' AS delete_row
FROM cf_fieldvalue AS cf
INNER JOIN cf_circulationform AS cc
ON cc.nID = cf.nFormId
WHERE cc.bDeleted = 0
AND cf.nInputFieldId IN (
    14, 15, 17, 19, 20, 26, 28, 29, 32, 33, 38, 39, 40, 41, 47, 50, 52, 53, 54, 55, 60, 62, 64, 76, 79, 82, 133, 178, 183, 189,
    190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213,
    214, 215, 231, 305, 329, 336, 495, 496, 514, 524, 548, 566, 590, 655, 658, 725, 747, 748, 759, 769, 1017, 1307, 1369, 1501,
    1502, 1618, 1619, 1620, 1623, 1637, 1640, 1663, 1707, 1709, 1710, 1711, 1723, 1744, 1747, 1843, 1844, 1847, 1859, 1973,
    2121
)