(SELECT A.cod_employee CODIGO, CONVERT(date, A.updated_at) FECHA, FORMAT(MIN(A.checkin),'yyyy-MM-dd HH:mm:ss') HORA, 0 TIPO, 'INGRESO' DESCRIPCION FROM SFC_Mark A WHERE CONVERT(date, A.updated_at) BETWEEN DATEADD(DAY, -25, GETDATE()) AND FORMAT(GETDATE(),'yyyy-MM-dd') GROUP BY A.cod_employee, CONVERT(date, A.updated_at))
UNION ALL
(SELECT A.cod_employee CODIGO, CONVERT(date, A.updated_at) FECHA, FORMAT(MAX(A.checkout),'yyyy-MM-dd HH:mm:ss') HORA, 1 TIPO, 'SALIDA' DESCRIPCION FROM SFC_Mark A WHERE CONVERT(date, A.updated_at) BETWEEN DATEADD(DAY, -25, GETDATE()) AND FORMAT(GETDATE(),'yyyy-MM-dd') GROUP BY A.cod_employee, CONVERT(date, A.updated_at))
ORDER BY
	CODIGO,
	FECHA	
ASC