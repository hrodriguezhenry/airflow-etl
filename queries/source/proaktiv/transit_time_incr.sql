SELECT tt.CountryCode AS country_code,
    tt.ViaCode AS via_code,
    tt.VendNumber AS vend_number,
    tt.TTCustoms AS tt_customs,
    tt.TTTransit AS tt_transit
FROM TransitTime AS tt