CREATE OR REPLACE FUNCTION updRatings() 
RETURNS TRIGGER
AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE imdb_movies SET ratingmean = ((ratingcount * ratingmean) + NEW.rating) / (ratingcount + 1), ratingcount = ratingcount + 1;
    ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE imdb_movies SET ratingmean = ((ratingmean * ratingcount) + (NEW.rating - OLD.rating));
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE imdb_movies SET ratingmean = ((ratingcount * ratingmean) - OLD.rating) / (ratingcount - 1), ratingcount = ratingcount - 1;
    END IF;
    RETURN NULL;
END;
$$ 
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER updRatings
AFTER DELETE OR INSERT OR UPDATE ON ratings
FOR EACH ROW EXECUTE FUNCTION updRatings();






SELECT * FROM ratings 
SELECT ratingmean, ratingcount FROM imdb_movies WHERE movieid = 100

INSERT INTO ratings (ratingid, rating, customerid, movieid)
VALUES (13, 10.0, 4, 100);




INSERT INTO imdb_movies (movieid, movietitle, movierelease,
	movietype, year, issuspended, ratingmean, ratingcount)
VALUES (101, 'wow', 'ayer', 1, 2010, 0, 0.01, 1);