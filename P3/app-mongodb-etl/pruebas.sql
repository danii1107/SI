-- QUERY A
SELECT imm.movietitle
FROM imdb_movies imm NATURAL JOIN imdb_moviecountries imc NATURAL JOIN imdb_moviegenres img 
WHERE
	imc.country = 'France' and img.genre = 'Sci-Fi' AND CAST(imm.year AS INT) BETWEEN 1994 AND 1998

-- QUERY B
SELECT imm.*
FROM imdb_movies imm
NATURAL JOIN imdb_moviecountries imc
NATURAL JOIN imdb_moviegenres img
WHERE
    imc.country = 'France'
    AND img.genre = 'Drama'
    AND imm.year = '1998'
    AND imm.movietitle LIKE '%, The%';

-- QUERY C
SELECT DISTINCT m.*
FROM imdb_movies m
NATURAL JOIN imdb_moviecountries mc
NATURAL JOIN imdb_actormovies af
NATURAL JOIN imdb_actors a
WHERE
	mc.country = 'France'
    AND m.movieid IN (
        SELECT maux.movieid
        FROM imdb_movies maux
        NATURAL JOIN imdb_actormovies af
        NATURAL JOIN imdb_actors a
        WHERE a.actorname = 'Dunaway, Faye'
    )
    AND m.movieid IN (
        SELECT maux.movieid
        FROM imdb_movies maux
        NATURAL JOIN imdb_actormovies af
        NATURAL JOIN imdb_actors a
        WHERE a.actorname = 'Mortensen, Viggo'
    )