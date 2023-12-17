alter table customers add promo integer;

CREATE OR REPLACE FUNCTION apply_promo() 
RETURNS TRIGGER AS $$
BEGIN
    UPDATE orders 
    SET totalamount = totalamount - (totalamount * NEW.promo / 100)
    FROM customers
    WHERE customers.customerid = NEW.customerid 
    AND orders.customerid = NEW.customerid 
    AND orders.status IS NULL;
    
    RETURN NEW;
	perform pg_sleep(20);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER updPromo 
AFTER UPDATE OR INSERT ON customers
FOR EACH ROW
EXECUTE FUNCTION apply_promo();