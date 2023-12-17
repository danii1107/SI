SELECT
    m.movieid,
    m.movietitle,
    SUM(od.quantity) AS total_quantity
FROM 
    imdb_movies m
JOIN
    imdb_moviecountries imm ON m.movieid = imm.movieid
JOIN 
    products p ON m.movieid = p.movieid
JOIN 
    orderdetail od ON p.prod_id = od.prod_id
WHERE 
    imm.country = 'USA'
GROUP BY 
    m.movieid, m.movietitle
ORDER BY 
    total_quantity DESC
LIMIT 20;

-- QUERY 1
SELECT a.actorname 
FROM imdb_actors a
JOIN imdb_actormovies am ON a.actorid = am.actorid
JOIN imdb_actormovies am2 ON am.movieid = am2.movieid AND am.actorid != am2.actorid
JOIN imdb_actors a2 ON am2.actorid = a2.actorid
WHERE a2.actorname != 'Winston, Hattie'
AND a2.actorid NOT IN (
    SELECT am3.actorid
    FROM imdb_actormovies am3
    JOIN imdb_actors a3 ON am3.actorid = a3.actorid
    WHERE a3.actorname = 'Winston, Hattie'
)
AND am.movieid IN (
    SELECT m.movieid
    FROM imdb_movies m
    JOIN imdb_moviecountries imm ON m.movieid = imm.movieid
    JOIN products p ON m.movieid = p.movieid
    JOIN orderdetail od ON p.prod_id = od.prod_id
    WHERE imm.country = 'USA'
    GROUP BY m.movieid, m.movietitle
    ORDER BY SUM(od.quantity) DESC
    LIMIT 20
)
GROUP BY a.actorname
HAVING COUNT(DISTINCT am2.actorid) > 1
ORDER BY a.actorname
LIMIT 10;

-- QUERY 2
WITH TopMovies AS (
    SELECT
        m.movieid
    FROM 
        imdb_movies m
    JOIN
        imdb_moviecountries imm ON m.movieid = imm.movieid
    JOIN 
        products p ON m.movieid = p.movieid
    JOIN 
        orderdetail od ON p.prod_id = od.prod_id
    WHERE 
        imm.country = 'USA'
    GROUP BY 
        m.movieid
    ORDER BY 
        SUM(od.quantity) DESC
    LIMIT 20
)
SELECT 
    a1.actorname AS Person1, 
    a2.actorname AS Person2, 
    COUNT(DISTINCT am1.movieid) AS NumberOfMovies
FROM 
    imdb_actormovies am1
JOIN 
    imdb_actormovies am2 ON am1.movieid = am2.movieid AND am1.actorid != am2.actorid
JOIN 
    imdb_actors a1 ON am1.actorid = a1.actorid
JOIN 
    imdb_actors a2 ON am2.actorid = a2.actorid
JOIN 
    TopMovies tm ON am1.movieid = tm.movieid
WHERE 
    a1.actorid < a2.actorid
GROUP BY 
    a1.actorname, a2.actorname
HAVING 
    COUNT(DISTINCT am1.movieid) > 1
ORDER BY 
    NumberOfMovies DESC, 
    Person1, 
    Person2

-- QUERY 3


