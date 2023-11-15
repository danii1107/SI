from sqlalchemy import create_engine, text

# Establecer la conexión a la base de datos PostgreSQL
engine = create_engine('postgresql://alumnodb:1234@localhost:5432/si1')

# Ejecutar la función getTopSales con SQLAlchemy
with engine.connect() as con:
    query = text("SELECT * FROM getTopSales(:year1, :year2)")
    result = con.execute(query.bindparams(year1=2021, year2=2022))

    # Mostrar los resultados
    for row in result.fetchmany(10):  # Limitar a 10 filas
        print(row)
