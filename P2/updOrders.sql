CREATE OR REPLACE FUNCTION updOrders() RETURNS TRIGGER AS $$
BEGIN
    PERFORM setOrderAmount();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER updOrders
AFTER INSERT OR DELETE OR UPDATE ON orderdetail
FOR EACH ROW
    EXECUTE PROCEDURE updOrders();



	

UPDATE orderdetail SET price = 200 WHERE orderid = 99997;

SELECT * FROM orders o WHERE o.orderid = 99997;

SELECT * FROM orderdetail od WHERE od.orderid = od.prod_id;


DELETE FROM orderdetail od WHERE od.orderid = od.prod_id AND od.orderid = 990990;

