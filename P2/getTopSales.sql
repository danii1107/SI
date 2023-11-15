CREATE OR REPLACE FUNCTION getTopSales(year1 INT, year2 INT,
    OUT Year INT, OUT Film CHAR, OUT sales BIGINT)
RETURNS SETOF RECORD
AS $$
DECLARE
    tupla RECORD;
BEGIN
    CREATE TEMPORARY TABLE ventas AS
        (SELECT mzovieid, sum(q.salesperyear) AS salesperyear,
            q.yearofsale
        FROM (SELECT od.prod_id, sum(quantity) AS salesperyear,
                extract(YEAR FROM orderdate) AS yearOfSale
                FROM orderdetail AS od NATURAL JOIN orders
                GROUP BY yearOfSale, od.prod_id) AS q NATURAL JOIN
            products
        GROUP BY movieid, yearofsale);
    CREATE TEMPORARY TABLE res AS
        (SELECT q.year, m.movietitle, q.maxsales
        FROM (SELECT s2.yearofsale AS year,
                min(s1.movieid) AS movieid, s2.maxsales
                FROM ventas AS s1,
                    (SELECT max(s.salesperyear) AS maxsales,
                        s.yearofsale
                    FROM ventas AS s
                    GROUP BY s.yearofsale) AS s2
                WHERE s2.maxsales = s1.salesperyear AND
                        s2.yearofsale = s1.yearofsale
                GROUP BY year, s2.maxsales) AS q
            JOIN imdb_movies AS m ON m.movieid = q.movieid
        WHERE q.year >= year1 AND q.year <= year2
        ORDER BY q.maxsales DESC);
    FOR tupla IN SELECT * FROM res LOOP
        Year := tupla.year;
        Film := tupla.movietitle;
        sales := tupla.maxsales;
        RETURN NEXT;
    END LOOP;
    DROP TABLE ventas;
    DROP TABLE res;
    RETURN;
END; $$
LANGUAGE plpgsql;

-- Invocación al procedimiento
SELECT * FROM getTopSales(2019, 2021);
