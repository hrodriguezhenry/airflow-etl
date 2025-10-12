SELECT bt.id,
	bt.nombre,
	bt.email,
	bt.fecha_registro
FROM big_table AS bt
WHERE bt.fecha_registro >= DATE_ADD(CURDATE(), INTERVAL 2 DAY)