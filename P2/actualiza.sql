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
    rating DECIMAL(3, 1),
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

-- Crear las tablas adicionales
CREATE TABLE IF NOT EXISTS movie_countries (
    countryid SERIAL PRIMARY KEY,
    countryname VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS movie_genres (
    genreid SERIAL PRIMARY KEY,
    genrename VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS movie_languages (
    languageid SERIAL PRIMARY KEY,
    languagename VARCHAR(255) NOT NULL
);

-- Añadir las columnas de clave foránea a la tabla movies
ALTER TABLE IF EXISTS imdb_movies
ADD COLUMN IF NOT EXISTS countryid INTEGER REFERENCES movie_countries(countryid),
ADD COLUMN IF NOT EXISTS genreid INTEGER REFERENCES movie_genres(genreid),
ADD COLUMN IF NOT EXISTS languageid INTEGER REFERENCES movie_languages(languageid);

-- Eliminar las columnas antiguas multivaluadas
ALTER TABLE IF EXISTS imdb_movies
DROP COLUMN IF EXISTS moviecountries,
DROP COLUMN IF EXISTS moviegenres,
DROP COLUMN IF EXISTS movielanguages;

