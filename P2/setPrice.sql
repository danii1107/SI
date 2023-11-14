-- Actualizar la columna 'price' en la tabla 'orderdetail'
UPDATE orderdetail
SET price = products.price * POWER(1.02, EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM orders.orderdate))
FROM products, orders
WHERE orderdetail.prod_id = products.prod_id AND orderdetail.orderid = orders.orderid;

