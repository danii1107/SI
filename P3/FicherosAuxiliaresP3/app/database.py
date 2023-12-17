# -*- coding: utf-8 -*-

import os
import sys, traceback, time

from sqlalchemy import create_engine, text
from pymongo import MongoClient

# configurar el motor de sqlalchemy
db_engine = create_engine("postgresql://alumnodb:1234@localhost/si1", echo=False, execution_options={"autocommit":False})

# Crea la conexión con MongoDB
mongo_client = MongoClient()

def getMongoCollection(mongoDB_client):
    mongo_db = mongoDB_client.si1
    return mongo_db.topUK

def mongoDBCloseConnect(mongoDB_client):
    mongoDB_client.close()

def dbConnect():
    return db_engine.connect()

def dbCloseConnect(db_conn):
    db_conn.close()
  
def delState(state, bFallo, bSQL, duerme, bCommit):
    # Array de trazas a mostrar en la página
    dbr=[]

    # TODO: Ejecutar consultas de borrado
    # - ordenar consultas según se desee provocar un error (bFallo True) o no
    # - ejecutar commit intermedio si bCommit es True
    # - usar sentencias SQL ('BEGIN', 'COMMIT', ...) si bSQL es True
    # - suspender la ejecución 'duerme' segundos en el punto adecuado para forzar deadlock
    # - ir guardando trazas mediante dbr.append()
    
    conn = dbConnect()
    
    try:
        # Begin transaction
        if bSQL:
            conn.execute("BEGIN")

        # Select customers from the given city
        stmt = text("SELECT customerid FROM customers WHERE city = :city")
        customers = conn.execute(stmt, city=state)
        # If no customers are found, no action is taken
        if not customers:
            dbr.append("No customers found in the specified city.")
            if bSQL:
                conn.execute("COMMIT")
            return dbr

        customer_ids = [c['customerid'] for c in customers]

        # Delete orders and order details
        stmt = text("DELETE FROM orderdetail WHERE orderid IN (SELECT orderid FROM orders WHERE customerid = ANY(:customer_ids))")
        conn.execute(stmt, customer_ids=customer_ids)
        stmt = text("DELETE FROM orders WHERE customerid = ANY(:customer_ids)")
        conn.execute(stmt, customer_ids=customer_ids)

        # If bFallo is True, attempt to delete customers before deleting their orders, which should cause an error due to foreign key constraints
        if bFallo:
            stmt = text("DELETE FROM customers WHERE customerid = ANY(:customer_ids)")
            conn.execute(stmt, customer_ids=customer_ids)
        # Intermediate commit if bCommit is True
        if bCommit:
            conn.execute("COMMIT")
            time.sleep(duerme)  # Sleep to simulate delay or deadlock
            if bSQL:
                conn.execute("BEGIN")

        # Final commit if no error occurred
        if not bFallo:
            conn.execute("COMMIT")
            dbr.append("All associated records with customers from the city have been deleted.")

    except Exception as e:
        # Rollback in case of error
        conn.execute("ROLLBACK")
        dbr.append(f"Transaction failed: {str(e)}. Rollback executed.")

    finally:
        # Close the database connection
        dbCloseConnect(conn)

    return dbr

