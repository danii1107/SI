SELECT COUNT(DISTINCT c.state) AS estados_distintos
FROM public.customers c
JOIN public.orders o ON c.customerid = o.customerid
WHERE EXTRACT(YEAR FROM o.orderdate) = 2017
AND c.country = 'Peru';

EXPLAIN
SELECT COUNT(DISTINCT c.state) AS estados_distintos
FROM public.customers c
JOIN public.orders o ON c.customerid = o.customerid
WHERE EXTRACT(YEAR FROM o.orderdate) = 2017
AND c.country = 'Peru';

-- Borra el índice si ya existe
DROP INDEX IF EXISTS idx_orders_customerid_orderdate;

-- Crea un nuevo índice compuesto
CREATE INDEX idx_orders_customerid_orderdate 
ON public.orders(customerid, orderdate);

-- Borra el índice si ya existe
DROP INDEX IF EXISTS idx_customers_customerid_country;

-- Crea un nuevo índice compuesto
CREATE INDEX idx_customers_customerid_country 
ON public.customers(customerid, country);

