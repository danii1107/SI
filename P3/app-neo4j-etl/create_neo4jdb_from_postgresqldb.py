from sqlalchemy import create_engine, text
from neo4j import GraphDatabase

def create_neo4jdb_from_postgresqldb():
    # Configuración de conexión a PostgreSQL
    postgres_engine = create_engine("postgresql://alumnodb:1234@localhost/si1", echo=False)
    postgres_conn = postgres_engine.connect()

    # Configuración de conexión a Neo4j
    neo4j_uri = "bolt://localhost:7687"
    neo4j_user = "neo4j"
    neo4j_password = "si1-password"

    # Crear la base de datos en Neo4j
    with GraphDatabase.driver(neo4j_uri, auth=(neo4j_user, neo4j_password)) as neo4j_driver:
        with neo4j_driver.session() as neo4j_session:
            # Consulta SQL para obtener las 20 películas estadounidenses más vendidas
            query = """
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
            """
            movies_result = postgres_conn.execute(text(query))
            movies_data = list(movies_result)

            # Crear nodos y relaciones en Neo4j para cada película
            for movie in movies_data:
                movie_id = movie["movieid"]
                movie_title = movie["movietitle"]

                # Crear nodo de película
                neo4j_session.run(
                    "MERGE (movie:Movie {id: $id, title: $title})",
                    id=movie_id, title=movie_title
                )

                # Consulta SQL para obtener actores de cada película
                actors_query = """
                    SELECT
                        ima.actorid,
                        ima.actorname
                    FROM
                        imdb_actormovies imam
                    JOIN imdb_actors ima ON imam.actorid = ima.actorid
                    WHERE imam.movieid = :movieid;
                """
                actors_data = postgres_conn.execute(text(actors_query), movieid=movie_id).fetchall()

                # Consulta SQL para obtener directores de cada película
                directors_query = """
                    SELECT
                        imd.directorid,
                        imd.directorname
                    FROM
                        imdb_directormovies imdm
                    JOIN imdb_directors imd ON imdm.directorid = imd.directorid
                    WHERE imdm.movieid = :movieid;
                """
                directors_data = postgres_conn.execute(text(directors_query), movieid=movie_id).fetchall()

                # Para cada actor, fusionar el nodo del actor y crear la relación ACTED_IN hacia la película
                for actor in actors_data:
                    neo4j_session.run(
                        "MERGE (actor:Person:Actor {id: $actor_id, name: $actor_name}) "
                        "WITH actor "
                        "MATCH (movie:Movie {id: $movie_id}) "
                        "MERGE (actor)-[:ACTED_IN]->(movie)",
                        actor_id=actor['actorid'], actor_name=actor['actorname'], movie_id=movie_id
                    )

                # Para cada director, fusionar el nodo del director y crear la relación DIRECTED hacia la película
                for director in directors_data:
                    neo4j_session.run(
                        "MERGE (director:Person:Director {id: $director_id, name: $director_name}) "
                        "WITH director "
                        "MATCH (movie:Movie {id: $movie_id}) "
                        "MERGE (director)-[:DIRECTED]->(movie)",
                        director_id=director['directorid'], director_name=director['directorname'], movie_id=movie_id
                    )
    # Cierre de conexiones
    print("BBDD basada en grafos creada correctamente.")
    postgres_conn.close()

if __name__ == "__main__":
    create_neo4jdb_from_postgresqldb()
