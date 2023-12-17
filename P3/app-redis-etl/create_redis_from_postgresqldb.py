import redis
import random
from sqlalchemy import create_engine, MetaData, Table, select

# Conexión a la base de datos PostgreSQL
print("Conectando a la base de datos PostgreSQL...")
db_url = 'postgresql://alumnodb:1234@localhost/si1'
engine = create_engine(db_url)
connection = engine.connect()

print("Conexión exitosa.")

metadata = MetaData()

# Cargar la estructura de la tabla desde PostgreSQL
print("Cargando la estructura de la tabla 'customers'...")
customers = Table('customers', metadata, autoload_with=engine, schema='public')
print("Estructura de la tabla cargada correctamente.")

# Consulta para obtener usuarios de España
query = select(customers).where(customers.c.country == 'Spain')

result = connection.execute(query)
users_spain = result.fetchall()

# Cerrar la conexión a PostgreSQL
connection.close()

# Conexión a Redis
redis_db = redis.StrictRedis(host='localhost', port=6379, db=0)

# Iterar sobre los usuarios de España obtenidos de PostgreSQL y almacenar en Redis
for user in users_spain:
    email = user[10]  # Índice de la columna 'email'
    name = f"{user[1]} {user[2]}"  # Índices de 'firstname' y 'lastname'
    phone = user[11]  # Índice de la columna 'phone'
    visits = random.randint(1, 99)  # Generar número aleatorio de visitas

    # Crear el hash en Redis con email, nombre, teléfono y visitas
    data = {'email': email, 'name': name, 'phone': phone, 'visits': visits}
    redis_db.hmset(f'customers:{email}', data)

# Función para incrementar una visita dado el correo electrónico
def increment_by_email(email):
    key = f'customers:{email}'
    redis_db.hincrby(key, 'visits', 1)

# Función para obtener el email del usuario con más visitas
def customer_most_visits():
    keys = redis_db.keys('customers:*')
    max_visits = -1
    email_max_visits = None

    for key in keys:
        visits = redis_db.hget(key, 'visits')
        if visits and int(visits) > max_visits:
            max_visits = int(visits)
            email_max_visits = key.split(':')[-1]  # Obtener el email del key

    return email_max_visits

# Función para mostrar nombre, teléfono y número de visitas dado el email
def get_field_by_email(email):
    key = f'customers:{email}'
    data = redis_db.hmget(key, 'name', 'phone', 'visits')
    if all(data):
        return {
            'name': data[0].decode(),
            'phone': data[1].decode(),
            'visits': int(data[2])
        }
    return None

# Mostrar datos recuperados de Redis
print("Datos recuperados de Redis:")
keys = redis_db.keys('customers:*')
for key in keys:
    data = redis_db.hgetall(key)
    decoded_data = {key.decode(): value.decode() for key, value in data.items()}
    print(decoded_data)

