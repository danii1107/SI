from sqlalchemy import create_engine, text
from pymongo import MongoClient

def create_mongodb_from_postgresqldb():
    try:

        # Conexión a MongoDB
        mongo_client = MongoClient("mongodb://localhost:27017/")
        if "si1" in mongo_client.list_database_names():
            print("Removing the old si1 database")
            mongo_client.drop_database('si1')

        # Conexión a PostgreSQL
        postgres_engine = create_engine("postgresql://alumnodb:1234@localhost/si1", echo=False)
        postgres_conn = postgres_engine.connect()

        # Consulta SQL para obtener información de películas francesas
        query = """
            SELECT
				m.movietitle AS title,
				ARRAY(SELECT genre FROM imdb_moviegenres WHERE movieid = m.movieid) AS genres,
				m.year,
				ARRAY(SELECT imd.directorname FROM imdb_directormovies idm NATURAL JOIN imdb_directors imd WHERE idm.movieid = m.movieid) AS directors,
				ARRAY(SELECT ima.actorname FROM imdb_actormovies iam NATURAL JOIN imdb_actors ima WHERE iam.movieid = m.movieid) AS actors
			FROM
				imdb_movies m
			JOIN
				imdb_moviecountries mc ON m.movieid = mc.movieid
			WHERE
				mc.country = 'France'
			ORDER BY
				m.year;
        """
        postgres_result = postgres_conn.execute(text(query))
        movies_data = list(postgres_result)

        # Ejemplo de documento del enunciado
        films = []
        for row in movies_data:
            title = row["title"][:row["title"].rfind("(") - 1]
            year = int(row["year"])
            pelicula = {
                "title": title,
                "genres": row["genres"],
                "year": year,
                "directors": row["directors"],
                "actors": row["actors"],
                "most_related_movies": [],
                "related_movies": []
            }
            films.append(pelicula)

        # Cálculo de películas relacionadas
        num_films = len(films)
        for i in range(num_films):
            for j in range(num_films):
                if i != j:
                    set1 = set(films[i]["genres"])
                    set2 = set(films[j]["genres"])
                    intersection = set1.intersection(set2)
                    if len(intersection) == len(set1):
                        films[i]["most_related_movies"].append(
                            {"title": films[j]["title"], "year": films[j]["year"]}
                        )
                    elif len(intersection) >= round(len(set1) / 2, 0):
                        films[i]["related_movies"].append(
                            {"title": films[j]["title"], "year": films[j]["year"]}
                        )
            if len(films[i]["most_related_movies"]) > 10:
                films[i]["most_related_movies"] = films[i]["most_related_movies"][:10]
            if len(films[i]["related_movies"]) > 10:
                films[i]["related_movies"] = films[i]["related_movies"][:10]

        postgres_conn.close()

        # Conexión y carga de datos en MongoDB
        mongodb_db = mongo_client["si1"]
        mongodb_collection = mongodb_db["france"]
        mongodb_collection.insert_many(films)

        mongo_client.close()
        print("Base de datos documental creada correctamente")
        return

    except Exception as e:
        print("Exception in DB access:")
        print("-" * 60)
        print(e)
        print("-" * 60)
        print("Error en la creación de la base de datos")
        return -1


def execute_postgresql_query(query):
    try:
        postgres_engine = create_engine("postgresql://alumnodb:1234@localhost/si1", echo=False)
        postgres_conn = postgres_engine.connect()

        result = postgres_conn.execute(text(query))
        rows = [dict(row) for row in result]

        return rows

    except Exception as e:
        print("Error al ejecutar la consulta en PostgreSQL:")
        print("-" * 60)
        print(e)
        print("-" * 60)
        return []

    finally:
        postgres_conn.close()

def compare_data_between_databases():
    try:
        postgres_engine = create_engine("postgresql://alumnodb:1234@localhost/si1", echo=False)
        postgres_conn = postgres_engine.connect()

        postgres_query = """
            SELECT
				m.movietitle AS title,
				ARRAY(SELECT genre FROM imdb_moviegenres WHERE movieid = m.movieid) AS genres,
				m.year,
				ARRAY(SELECT imd.directorname FROM imdb_directormovies idm NATURAL JOIN imdb_directors imd WHERE idm.movieid = m.movieid) AS directors,
				ARRAY(SELECT ima.actorname FROM imdb_actormovies iam NATURAL JOIN imdb_actors ima WHERE iam.movieid = m.movieid) AS actors
			FROM
				imdb_movies m
			JOIN
				imdb_moviecountries mc ON m.movieid = mc.movieid
			WHERE
				mc.country = 'France'
			ORDER BY
				m.year;
        """
        postgres_results = execute_postgresql_query(postgres_query)

        mongo_client = MongoClient("mongodb://localhost:27017/")
        mongodb_db = mongo_client["si1"]
        mongodb_collection = mongodb_db["france"]

        mongodb_results = list(mongodb_collection.find())

        # Comparación de resultados
        for postgres_row, mongodb_document in zip(postgres_results, mongodb_results):
            postgres_title_without_year = postgres_row["title"][:postgres_row["title"].rfind("(") - 1]

            if postgres_title_without_year != mongodb_document["title"]:
                print(f"Discrepancia en el título: {postgres_title_without_year} vs {mongodb_document['title']}")

        print("Los datos en Mongodb se han guardado correctamente")

    except Exception as e:
        print("Error en la comparación de datos:")
        print("-" * 60)
        print(e)
        print("-" * 60)

    finally:
        postgres_conn.close()
        mongo_client.close()

if __name__ == "__main__":
    create_mongodb_from_postgresqldb()
    compare_data_between_databases()
