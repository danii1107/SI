from pymongo import MongoClient

def query_a(mongodb_collection):
    query = {
        "genres": "Sci-Fi",
        "year": {"$gte": 1994, "$lte": 1998}
    }
    result = list(mongodb_collection.find(query))
    return result

def query_b(mongodb_collection):
    query = {
        "genres": "Drama",
        "year": 1998,
        "title": {"$regex": ", The", "$options": "i"}
    }
    result = list(mongodb_collection.find(query))
    return result

def query_c(mongodb_collection):
    query = {
        "actors": {"$all": ["Dunaway, Faye", "Mortensen, Viggo"]}
    }
    result = list(mongodb_collection.find(query))
    return result

if __name__ == "__main__":
    mongo_client = MongoClient("mongodb://localhost:27017/")
    mongodb_db = mongo_client["si1"]
    mongodb_collection = mongodb_db["france"]

    print("Consulta A: Películas de ciencia ficción entre 1994 y 1998")
    result_a = query_a(mongodb_collection)
    for movie in result_a:
        print(movie)
        print

    print("\nConsulta B: Dramas que empiezan con 'The' en 1998")
    result_b = query_b(mongodb_collection)
    for movie in result_b:
        print(movie)

    print("\nConsulta C: Películas en las que Faye Dunaway y Viggo Mortensen compartieron reparto")
    result_c = query_c(mongodb_collection)
    for movie in result_c:
        print(movie)

    mongo_client.close()
