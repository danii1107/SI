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
  
def delCity(city, bFallo, bSQL, duerme, bCommit):
	dbr=[]
	
	db_conn = db_engine.connect()
	
	try:
		if bSQL:
			dbr.append("Se ejecuta a traves de SQL")
			result = db_conn.execute("BEGIN;")
			dbr.append("BEGIN")
			result = db_conn.execute("delete from orderdetail where exists orderid in (select orderid from orders where exists customerid in (select customerid from customers where city = "+city+")")
			dbr.append("Se borrarán los datos de los pedidos del cliente de la ciudad: "+city)
			
			if bCommit:
				result = db_conn.execute("COMMIT;")
				dbr.append("Commit intermedio. Se inicia otra transaccion")
				result = db_conn.execute("BEGIN;")
			if not bFallo:
				result = db_conn.execute("delete from orders where exists customerid in (select custormeid from custormers where city ="+city+")")
				dbr.append("Se borrarán los pedidos del cliente de la ciudad: "+city)
			result = db_conn.execute("delete from customers where city ="+city)
			dbr.append("Se borrará el cliente de la ciudad indicada")
			result = db_conn.execute("COMMIT;")
			dbr.append("Transaccion finalizada correctamente.")
		else:
			dbr.append("Se ejecuta a traves de SQL ALCHEMY")
			alchemy = db_conn.begin()
			dbr.append("BEGIN")
			result = db_conn.execute("delete from orderdetail where exists orderid in (select orderid from orders where exists customerid in (select customerid from customers where city = "+city+")")			
			dbr.append("Datos de los pedidos del cliente de la ciudad "+city+" borrados.")
			
			if bCommit:
				alchemy.commit()
				dbr.append("Commit intermedio. Se inicia otra transaccion")
				alchemy = db_conn.begin()
			if not bFallo:
				result = db_conn.execute("delete from orders where exists customerid in (select custormeid from custormers where city ="+city+")")
				dbr.append("Pedidos del cliente de la ciudad "+city+" borrados.")
			result = db_conn.execute("delete from customers where ccity ="+city)
			dbr.append("Cliente borrado")
			alchemy.commit()
			dbr.append("Transaccion finalizada correctamente.")

	except Exception as e:
		dbr.append("Error en la transaccion. Haciendo rollback.")
		if bSQL:
			result = db_conn.execute("rollback;")
		else:
			alchemy.rollback()
			
	dbr.append("Cerramos la conexión con la base de datos.")
	db_conn.close()

	return dbr