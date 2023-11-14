ALTER TABLE imdb_actormovies
ADD CONSTRAINT "imdb_actormovies_actorid_fkey"
FOREIGN KEY ("actorid")
REFERENCES imdb_actors("actorid");

ALTER TABLE imdb_actormovies
ADD CONSTRAINT "imdb_actormovies_movieid_fkey"
FOREIGN KEY ("movieid")
REFERENCES imdb_movies("movieid");

ALTER TABLE orderdetail
ADD CONSTRAINT "imdb_orderdetail_orderid_fkey"
FOREIGN KEY ("orderid")
REFERENCES orders("orderid");

ALTER TABLE orderdetail
ADD CONSTRAINT "imdb_orderdetail_prod_id_fkey"
FOREIGN KEY ("prod_id")
REFERENCES products("prod_id");

ALTER TABLE orders
ADD CONSTRAINT "imdb_orders_customerid_fkey"
FOREIGN KEY ("customerid")
REFERENCES customers("customerid");

ALTER TABLE inventory
ADD CONSTRAINT "imdb_inventory_prod_id_fkey"
FOREIGN KEY ("prod_id")
REFERENCES products("prod_id");

ALTER TABLE customers
ADD COLUMN balance DECIMAL(10, 2);  

CREATE TABLE ratings (
    ratingid SERIAL PRIMARY KEY,
    customerid INTEGER REFERENCES customers("customerid"),
    movieid INTEGER REFERENCES imdb_movies("movieid"),
    rating INTEGER,
    -- Asegurarse de que un usuario no pueda valorar dos veces la misma película
    CONSTRAINT unique_user_movie_rating UNIQUE ("customerid", "movieid")
);

ALTER TABLE imdb_movies
ADD COLUMN ratingmean DECIMAL(3, 2),
ADD COLUMN ratingcount INTEGER;

ALTER TABLE customers
ALTER COLUMN password TYPE VARCHAR(96);

-- Crear o reemplazar el procedimiento almacenado
CREATE OR REPLACE FUNCTION setCustomersBalance(IN initialBalance bigint)
RETURNS void AS $$
DECLARE
    random_balance bigint;
BEGIN
    -- Generar un número aleatorio entre 0 y N
    random_balance := floor(random() * (initialBalance + 1));

    -- Actualizar el campo balance en la tabla customers con el valor aleatorio
    UPDATE customers
    SET balance = random_balance;

    RAISE NOTICE 'Balances actualizados aleatoriamente.';
END;
$$ LANGUAGE plpgsql;

-- Llamar al procedimiento con un valor específico para initialBalance 
SELECT setCustomersBalance(200);
