# -*- coding: utf-8 -*-

import os
import sys, traceback, time

from sqlalchemy import create_engine, text
from pymongo import MongoClient

# configurar el motor de sqlalchemy
db_engine = create_engine("postgresql://alumnodb:1234@localhost/si1p3", echo=False, execution_options={"autocommit":False})

# Crea la conexión con MongoDB
mongo_client = MongoClient()

def getMongoCollection(mongoDB_client):
    mongo_db = mongoDB_client.si1p3
    return mongo_db.topUK

def mongoDBCloseConnect(mongoDB_client):
    mongoDB_client.close();

def dbConnect():
    db_conn = db_engine.connect()
    print("Conexión establecida con la base de datos.")
    return db_conn

def dbCloseConnect(db_conn):
    db_conn.close()
  
def delState(state, bFallo, bCommit):
    dbr = []
    db_conn = None
    try:
        db_conn = dbConnect()
        db_trans = db_conn.begin()

        # Borrado de información asociada al cliente en orden inverso para evitar conflictos
        # Borrar pedidos con su detalle
        db_conn.execute(text("DELETE FROM orderdetail WHERE orderid IN "
                             "(SELECT orderid FROM orders WHERE customerid IN "
                             "(SELECT customerid FROM customers WHERE city = :city))"), city=state)

        # Borrar historial
        db_conn.execute(text("DELETE FROM historial WHERE customerid IN "
                             "(SELECT customerid FROM customers WHERE city = :city)"), city=state)

        # Borrar carrito
        db_conn.execute(text("DELETE FROM carrito WHERE customerid IN "
                             "(SELECT customerid FROM customers WHERE city = :city)"), city=state)

        # Borrar clientes de la ciudad especificada
        db_conn.execute(text("DELETE FROM customers WHERE city = :city"), city=state)

        if bCommit:
            db_conn.execute("COMMIT")

        if bFallo:
            raise Exception("Simulación de un error durante la eliminación")

        db_trans.commit()
        dbr.append("Cambios confirmados exitosamente")

    except Exception as e:
        if db_trans:
            db_trans.rollback()
        dbr.append(f"Error: {str(e)}")
    finally:
        if db_conn:
            dbCloseConnect(db_conn)

    return dbr

def delStateIncorrectOrder(state, bFallo, bCommit):
    dbr = []
    db_conn = None
    try:
        db_conn = dbConnect()
        db_trans = db_conn.begin()

        db_conn.execute(text("DELETE FROM carrito WHERE customerid IN "
                             "(SELECT customerid FROM customers WHERE city = :city)"), city=state)

        # Otras operaciones de borrado en un orden incorrecto
        # ...

        if bCommit:
            db_conn.execute("COMMIT")

        if bFallo:
            raise Exception("Simulación de un error durante la eliminación")

        db_trans.commit()
        dbr.append("Cambios confirmados exitosamente")

    except Exception as e:
        if db_trans:
            db_trans.rollback()
        dbr.append(f"Error: {str(e)}")
    finally:
        if db_conn:
            dbCloseConnect(db_conn)

    return dbr

def delStateCorrectOrder(state, bFallo, bCommit):
    dbr = []
    db_conn = None
    try:
        db_conn = dbConnect()
        db_trans = db_conn.begin()

        db_conn.execute(text("DELETE FROM historial WHERE customerid IN "
                             "(SELECT customerid FROM customers WHERE city = :city)"), city=state)

        # Otras operaciones de borrado en un orden correcto
        # ...

        if bCommit:
            db_conn.execute("COMMIT")

        if bFallo:
            raise Exception("Simulación de un error durante la eliminación")

        db_trans.commit()
        dbr.append("Cambios confirmados exitosamente")

    except Exception as e:
        if db_trans:
            db_trans.rollback()
        dbr.append(f"Error: {str(e)}")
    finally:
        if db_conn:
            dbCloseConnect(db_conn)

    return dbr

def showDataBeforeDeletion(state):
    db_conn = None
    try:
        db_conn = dbConnect()

        # Consulta para obtener datos antes del borrado
        query = text("SELECT * FROM customers WHERE city = :city")
        result = db_conn.execute(query.params(city=state))
        customers_data = result.fetchall()

        # Mostrar los datos de los clientes antes del borrado
        print("Datos de los clientes a borrar:")
        for row in customers_data:
            print(row)  # Aquí puedes imprimir o procesar los datos según sea necesario

        # Consultas para otras tablas asociadas (carrito, historial, orderdetail)
        # ...

    except Exception as e:
        print(f"Error al obtener los datos antes del borrado: {str(e)}")
    finally:
        if db_conn:
            dbCloseConnect(db_conn)

