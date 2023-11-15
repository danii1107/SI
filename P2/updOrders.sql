CREATE OR REPLACE FUNCTION updOrders() 
RETURNS TRIGGER as $$
DECLARE
    extra int4;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        extra := (select o.netamount from orders o where o.orderid = new.orderid);
        UPDATE orders set netamount = extra + (new.price*new.quantity) where orders.orderid = new.orderid;
        UPDATE orders set totalamount = (netamount + (netamount*tax/100)) where orders.orderid = new.orderid;
    ELSEIF (TG_OP = 'DELETE') THEN
        extra := (select o.netamount from orders o where o.orderid = old.orderid);
        UPDATE orders set netamount = extra - (old.price*old.quantity) where orders.orderid = old.orderid;
        UPDATE orders set totalamount = (netamount + (netamount*tax/100)) where orders.orderid = old.orderid;
    ELSEIF (TG_OP = 'UPDATE') THEN
        extra := (select o.netamount from orders o where o.orderid = old.orderid);
        extra := extra - (old.price*old.quantity);
        UPDATE orders set netamount = extra + (new.price*new.quantity) where orders.orderid = new.orderid;
        UPDATE orders set totalamount = (netamount + (netamount*tax/100)) where orders.orderid = new.orderid;
    END IF;
    RETURN NULL;
END;
    $$ 
LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER updOrders
AFTER DELETE OR INSERT OR UPDATE ON orderdetail
FOR EACH ROW
EXECUTE PROCEDURE updOrders();


UPDATE orderdetail SET price = 33 WHERE orderid = 99997;

SELECT * FROM orders o WHERE o.orderid = 99997;

SELECT * FROM orderdetail od WHERE od.orderid = od.prod_id;


DELETE FROM orderdetail od WHERE od.orderid = od.prod_id AND od.orderid = 990990;

