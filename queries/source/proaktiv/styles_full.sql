SELECT s.StlNumber AS stl_number,
    s.ClrNumber AS clr_number,
    s.StlClsNumber AS stl_cls_number,
    s.StlCustItem AS stl_cust_item,
    s.StlActive AS stl_active,
    s.StlDesc AS stl_desc,
    s.StlCutFr AS stl_cut_fr,
    s.StlGender AS stl_gender,
    s.StlSeasonal AS stl_seasonal,
    s.StlCustDesc AS stl_cust_desc,
    s.StlCustDept AS stl_cust_dept,
    s.StlCustClass AS stl_cust_class,
    s.CustNumber AS cust_number
FROM Styles AS s