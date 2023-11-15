CREATE OR REPLACE FUNCTION getTopActors(genre CHAR, OUT Actor CHAR,
    OUT Num INT, OUT Debut INT, OUT Film CHAR, OUT Director CHAR)
RETURNS SETOF RECORD
AS $$
DECLARE
    tupla RECORD;
BEGIN
    CREATE TEMPORARY TABLE RESULT
    AS (SELECT q.actorname, q.genremovies, q.genredebut,
            m.movietitle, d.directorname
        FROM (
            SELECT a.actorid, a.actorname, COUNT(a.actorid) AS genremovies,
                MIN(m.year) AS genredebut
            FROM imdb_moviegenres AS g
            JOIN imdb_movies AS m ON m.movieid = g.movieid
            JOIN imdb_actormovies AS am ON am.movieid = m.movieid
            JOIN imdb_actors AS a ON a.actorid = am.actorid
            WHERE g.genre LIKE $1
            GROUP BY a.actorid, a.actorname
            HAVING COUNT(a.actorid) > 4
        ) AS q
        JOIN imdb_actormovies AS am ON am.actorid = q.actorid
        JOIN imdb_movies AS m ON q.genredebut = m.year AND am.movieid = m.movieid
        JOIN imdb_directormovies AS dm ON dm.movieid = m.movieid
        JOIN imdb_directors AS d ON d.directorid = dm.directorid
        ORDER BY q.genremovies DESC);

    FOR tupla IN SELECT * FROM RESULT LOOP
        Actor := tupla.actorname;
        Num := tupla.genremovies;
        Debut := tupla.genredebut;
        Film := tupla.movietitle;
        Director := tupla.directorname;
        RETURN NEXT;
    END LOOP;

    DROP TABLE RESULT;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM getTopActors('Drama')

DROP FUNCTION IF EXISTS getTopActors(CHAR);


SELECT 
    imdb_actors.actorname
FROM 
    imdb_actors
JOIN 
    imdb_actormovies ON imdb_actors.actorid = imdb_actormovies.actorid
JOIN 
    imdb_movies ON imdb_actormovies.movieid = imdb_movies.movieid
JOIN 
    imdb_moviegenres ON imdb_movies.movieid = imdb_moviegenres.movieid
WHERE 
    imdb_actors.actorname = 'Lee, Spike'
    AND imdb_moviegenres.genre = 'Drama';