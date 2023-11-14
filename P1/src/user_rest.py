#!/bin/env python3

import os
import json
from quart import Quart, g, request, jsonify
from quart.helpers import make_response

# defaults
USERDIR="./build/users"

app = Quart(__name__)

@app.route('/', methods=["GET"])
async def hello():
  return 'hello'

# get/select
@app.get('/user/<username>')
async def user_get(username):
  resp={}
  with open (f"{USERDIR}/{username}/data.json", "r") as ff:
    resp=json.loads(ff.read())
  return await make_response(jsonify(resp), 200)

# create/insert
@app.put('/user/<username>')
async def user_put(username):
  resp={}
  try:
    os.mkdir(f"{USERDIR}/{username}")
  except Exception as e:
    resp["status"]= "KO"
    resp["error"] = f"Error creando user dir: {str(e)}"
    return await make_response(jsonify(resp), 400)
  data=await request.get_json()
  data["username"]=username
  with open (f"{USERDIR}/{username}/data.json", "w") as ff:
    ff.write(json.dumps(data))

  resp["status"]="OK"
  return await make_response(jsonify(resp), 200)

# delete user
@app.delete('/user/<username>')
async def user_delete(username):
  resp={}
  try:
    os.remove(f"{USERDIR}/{username}/data.json")
  except Exception as e:
    resp["status"]= "KO"
    resp["error"] = f"Error eliminando data.json: {str(e)}"
    return await make_response(jsonify(resp), 400)
  try:
    os.rmdir(f"{USERDIR}/{username}")
  except Exception as e:
    resp["status"]= "KO"
    resp["error"] = f"Error eliminando user dir: {str(e)}"
    return await make_response(jsonify(resp), 400)
  resp["status"]="OK"
  return await make_response(jsonify(resp), 200)

# change path
@app.patch('/user/<username>')
async def user_patch(username):
  resp={}
  try:
    with open(f"{USERDIR}/{username}/data.json", 'r') as dict:
      data = json.load(dict)
    new_data = await request.get_json()
    data['firstName'] = new_data['firstName']
    with open(f"{USERDIR}/{username}/data.json", 'w') as dict:
      json.dump(data, dict, indent=2)
  except Exception as e:
    resp["status"]= "KO"
    resp["error"] = f"Error actualizando firstName: {str(e)}"
    return await make_response(jsonify(resp), 400)
  resp["status"]="OK"
  return await make_response(jsonify(resp), 200)

if __name__ == "__main__":
    app.run(host='localhost', 
        port=5000)
        
#app.run()
