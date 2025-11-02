SELECT atco.cust_ord,
	atco.style_id,
	atco.qr_id,
	atco.quantity,
	atco.employee_name,
	atco.operation,
	atco.date,
	cns.stage,
	cns.column_name,
	'N' AS delete_row
	
FROM process.atomic_traceability_customer_orders_zero_box AS atco

CROSS JOIN (
	SELECT 'Cantidad QRs' AS stage, 'qr_total' AS column_name UNION ALL
	SELECT 'Troquel' AS stage, 'die_route' AS column_name UNION ALL
	SELECT 'Troquel' AS stage, 'die_dispatch_date' AS column_name UNION ALL
	SELECT 'Troquel' AS stage, 'die_dispatch_employee_name' AS column_name UNION ALL
	SELECT 'Troquel' AS stage, 'die_operation' AS column_name UNION ALL
	SELECT 'Troquel' AS stage, 'die_operation_date' AS column_name UNION ALL
	SELECT 'Troquel' AS stage, 'die_operation_employee_name' AS column_name UNION ALL
	SELECT 'Troquel' AS stage, 'die_location' AS column_name UNION ALL
	SELECT 'Troquel' AS stage, 'die_count_date' AS column_name UNION ALL
	SELECT 'Troquel' AS stage, 'die_count_employee_name' AS column_name UNION ALL
	SELECT 'Estampado' AS stage, 'print_route' AS column_name UNION ALL
	SELECT 'Estampado' AS stage, 'print_reception_date' AS column_name UNION ALL
	SELECT 'Estampado' AS stage, 'print_reception_employee_name' AS column_name UNION ALL
	SELECT 'Estampado' AS stage, 'print_dispatch_date' AS column_name UNION ALL
	SELECT 'Estampado' AS stage, 'print_dispatch_employee_name' AS column_name UNION ALL
	SELECT 'Estampado' AS stage, 'print_operation' AS column_name UNION ALL
	SELECT 'Estampado' AS stage, 'print_operation_date' AS column_name UNION ALL
	SELECT 'Estampado' AS stage, 'print_operation_employee_name' AS column_name UNION ALL
	SELECT 'Estampado' AS stage, 'print_location' AS column_name UNION ALL
	SELECT 'Estampado' AS stage, 'print_count_date' AS column_name UNION ALL
	SELECT 'Estampado' AS stage, 'print_count_employee_name' AS column_name UNION ALL
	SELECT 'Costura' AS stage, 'seam_route' AS column_name UNION ALL
	SELECT 'Costura' AS stage, 'seam_reception_date' AS column_name UNION ALL
	SELECT 'Costura' AS stage, 'seam_reception_employee_name' AS column_name UNION ALL
	SELECT 'Costura' AS stage, 'seam_dispatch_date' AS column_name UNION ALL
	SELECT 'Costura' AS stage, 'seam_dispatch_employee_name' AS column_name UNION ALL
	SELECT 'Costura' AS stage, 'seam_operation' AS column_name UNION ALL
	SELECT 'Costura' AS stage, 'seam_operation_date' AS column_name UNION ALL
	SELECT 'Costura' AS stage, 'seam_operation_employee_name' AS column_name UNION ALL
	SELECT 'Costura' AS stage, 'seam_location' AS column_name UNION ALL
	SELECT 'Cuerpos' AS stage, 'body_route' AS column_name UNION ALL
	SELECT 'Cuerpos' AS stage, 'body_end_date' AS column_name UNION ALL
	SELECT 'Cuerpos' AS stage, 'body_end_employee_name' AS column_name UNION ALL
	SELECT 'Cuerpos' AS stage, 'body_inspection_date' AS column_name UNION ALL
	SELECT 'Cuerpos' AS stage, 'body_inspection_employee_name' AS column_name UNION ALL
	SELECT 'Cuerpos' AS stage, 'body_inspection_location' AS column_name UNION ALL
	SELECT 'Cantos' AS stage, 'edges_route' AS column_name UNION ALL
	SELECT 'Cantos' AS stage, 'edges_reception_date' AS column_name UNION ALL
	SELECT 'Cantos' AS stage, 'edges_reception_employee_name' AS column_name UNION ALL
	SELECT 'Cantos' AS stage, 'edges_dispatch_date' AS column_name UNION ALL
	SELECT 'Cantos' AS stage, 'edges_dispatch_employee_name' AS column_name UNION ALL
	SELECT 'Cantos' AS stage, 'edges_operation' AS column_name UNION ALL
	SELECT 'Cantos' AS stage, 'edges_operation_date' AS column_name UNION ALL
	SELECT 'Cantos' AS stage, 'edges_operation_employee_name' AS column_name UNION ALL
	SELECT 'Cantos' AS stage, 'edges_location' AS column_name UNION ALL
	SELECT 'Cantos' AS stage, 'edges_count_date' AS column_name UNION ALL
	SELECT 'Cantos' AS stage, 'edges_count_employee_name' AS column_name UNION ALL
	SELECT 'Ensamble' AS stage, 'assembly_route' AS column_name UNION ALL
	SELECT 'Ensamble' AS stage, 'assembly_reception_date' AS column_name UNION ALL
	SELECT 'Ensamble' AS stage, 'assembly_reception_employee_name' AS column_name UNION ALL
	SELECT 'Ensamble' AS stage, 'assembly_dispatch_date' AS column_name UNION ALL
	SELECT 'Ensamble' AS stage, 'assembly_dispatch_employee_name' AS column_name UNION ALL
	SELECT 'Ensamble' AS stage, 'assembly_operation' AS column_name UNION ALL
	SELECT 'Ensamble' AS stage, 'assembly_operation_date' AS column_name UNION ALL
	SELECT 'Ensamble' AS stage, 'assembly_operation_employee_name' AS column_name UNION ALL
	SELECT 'Ensamble' AS stage, 'assembly_location' AS column_name UNION ALL
	SELECT 'Ensamble' AS stage, 'assembly_inspection_date' AS column_name UNION ALL
	SELECT 'Ensamble' AS stage, 'assembly_inspection_employee_name' AS column_name UNION ALL
	SELECT 'Ensamble' AS stage, 'assembly_inspection_location' AS column_name
) AS cns