/* CREATE OR REPLACE FUNCTION getTopSales(year1 INTEGER, year2 INTEGER)
RETURNS TABLE(year_ INTEGER, movie_ CHARACTER VARYING(255), top_ BIGINT, id_ INTEGER) AS $$
BEGIN
    -- Obtener todas las películas vendidas y el año en el que se vendieron
    RETURN QUERY
    SELECT 
        EXTRACT(YEAR FROM orders.orderdate)::INTEGER AS year_,
        imdb_movies.movietitle AS movie_,
        MAX(imdb_movies.movieid) AS id_,
        SUM(orderdetail.quantity) AS top_
    FROM 
        products
        JOIN orderdetail ON products.prod_id = orderdetail.prod_id
        JOIN orders ON orderdetail.orderid = orders.orderid
        JOIN imdb_movies ON products.movieid = imdb_movies.movieid
    WHERE 
        EXTRACT(YEAR FROM orders.orderdate) BETWEEN year1 AND year2
    GROUP BY
        year_, movie_
    ORDER BY
        top_ DESC
    LIMIT 1; -- Limitamos a una fila para evitar el empate en la respuesta.

END;
$$ LANGUAGE plpgsql; */

CREATE OR REPLACE FUNCTION getTopVentas(year1 INTEGER, year2 INTEGER)
RETURNS TABLE(year_ DOUBLE PRECISION, movie_ CHARACTER VARYING(255), top_ BIGINT, id_ INTEGER) AS $$
BEGIN
    -- Creamos una view para obtener todas las películas vendidas y el
    -- año en el que se vendieron
    CREATE OR REPLACE VIEW MoviesYear AS
        SELECT 
            extract(year FROM orders.orderdate) as year_, 
            imdb_movies.movietitle as movie_,
            imdb_movies.movieid as id_,
            orderdetail.quantity as quantity_
        FROM 
            products, 
            orders, 
            orderdetail, 
            imdb_movies
        WHERE 
            products.prod_id = orderdetail.prod_id AND
            products.movieid = imdb_movies.movieid AND
            orderdetail.orderid = orders.orderid
    ;

    -- Creamos una view que cuenta cuántas veces una película fue
    -- vendida cada año
    CREATE OR REPLACE VIEW CountYear AS
        SELECT
            year_, movie_, sum(quantity_) as frequency_, id_
        FROM
            MoviesYear
        GROUP BY
            year_, movie_, id_
    ;

    -- Creamos una view para obtener el número de veces que ha sido vendida
    -- la película más vendida de cada año
    CREATE OR REPLACE VIEW CountTop AS
        SELECT
            year_, max(frequency_) AS top_
        FROM
            CountYear
        GROUP BY
            year_
    ;

    -- Procedimiento que consigue las películas más vendidas de cada año
    -- y varias en caso de empate
    RETURN QUERY
	SELECT
        CountYear.year_, CountYear.movie_,
        CountTop.top_, CountYear.id_
    FROM
        CountTop, CountYear
    WHERE
        CountTop.year_ = CountYear.year_ AND
        CountTop.top_ = CountYear.frequency_ AND
        CountTop.year_ >= year1 AND
        CountTop.year_ <= year2
    ORDER BY
        CountTop.top_ DESC;

END;
$$ LANGUAGE plpgsql;

-- Invocación al procedimiento
SELECT * FROM getTopSales(2020, 2021);