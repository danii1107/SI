--c
EXPLAIN SELECT COUNT(*)
FROM orders
WHERE status IS NULL;

EXPLAIN SELECT COUNT(*)
FROM orders
WHERE status ='Shipped';

--d
CREATE INDEX idx_status ON orders(status);

--e
EXPLAIN SELECT COUNT(*)
FROM orders
WHERE status IS NULL;

EXPLAIN SELECT COUNT(*)
FROM orders
WHERE status ='Shipped';

--f
ANALYZE orders;

--g
EXPLAIN SELECT COUNT(*)
FROM orders
WHERE status IS NULL;

EXPLAIN SELECT COUNT(*)
FROM orders
WHERE status ='Shipped';

--h
EXPLAIN SELECT COUNT(*)
FROM orders
WHERE status ='Paid';

EXPLAIN SELECT COUNT(*)
FROM orders
WHERE status ='Processed';

