CREATE OR REPLACE FUNCTION updInventoryAndCustomer()
RETURNS TRIGGER
AS $$
DECLARE
    prod record;
BEGIN
    FOR prod IN
        SELECT
            od.prod_id, i.sales, od.quantity, i.stock
        FROM
            public.orderdetail od,
            public.inventory i
        WHERE
            OLD.orderid = od.orderid AND
            i.prod_id = od.prod_id

    LOOP
        UPDATE inventory i
        SET
            stock = prod.stock - prod.quantity,
            sales = prod.sales + prod.quantity
        WHERE
            i.prod_id = prod.prod_id;

		IF (prod.quantity >= prod.stock) THEN
            INSERT INTO alertas VALUES (prod.prod_id, NOW(), prod.stock - prod.quantity);
        END IF;
	END LOOP;
    UPDATE customers SET balance = balance - NEW.totalamount;
    NEW.orderdate = 'NOW()';
    RETURN NEW;
END; $$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER updInventoryAndCustomer
BEFORE UPDATE OF STATUS ON orders
FOR EACH ROW
    WHEN (NEW.status = 'Paid')
    EXECUTE PROCEDURE updInventoryAndCustomer();


SELECT * FROM orders o WHERE o.orderid = 95
SELECT * FROM orderdetail o WHERE o.orderid = 95

UPDATE orders SET status = 'Paid' WHERE orderid = 95;
UPDATE orders SET status = 'Processed' WHERE orderid = 95;

UPDATE customers SET balance = 50 where customerid = 9329

SELECT * FROM customers WHERE customerid = 9329
SELECT * FROM inventory WHERE inventory.prod_id = 1072
