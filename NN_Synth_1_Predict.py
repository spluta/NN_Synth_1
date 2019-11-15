"""
Neural Net for SC Cross-Feedback Synthesis Model
"""
import argparse
import math
import os

from pythonosc import dispatcher
from pythonosc import osc_server
from pythonosc import udp_client
from typing import List, Any
from keras.layers import Dense
from keras.models import Sequential
import numpy as np
from keras.models import load_model
from keras import backend as K

def closeProgram(unused_addr, *args: List[Any]):
  #print("closing")
  os._exit(1)

def predict_handler(unused_addr, *args: List[Any]):
  whichModel = args[0:1][0]

  jammer = np.array([np.array(args[1:5])])
  
  if models[whichModel]!=None:
    output = models[whichModel].predict(jammer)
    client.send_message("/nnOutputs", output[0].astype(float))
  else:
    print("No model")

def prime_arrays(unused_addr, *args: List[Any]):
  whichModel = args[0:1][0]
  print(whichModel)

  jammer = np.array([np.array(args[1:5])])
  if models[whichModel]!=None:
    output = models[whichModel].predict(jammer)
    output = np.append(np.array(whichModel), output[0].astype(float))
    client.send_message("/prime", output)
  else:
    print("No model")

if __name__ == "__main__":
  parser = argparse.ArgumentParser()
  parser.add_argument("--ip",
      default="127.0.0.1", help="The ip to listen on")
  parser.add_argument("--port",
      type=int, default=5005, help="The port to listen on")
  parser.add_argument("--path",
      default="/Users/spluta/Documents/SC/aiControls/", help="The path")
  args = parser.parse_args()

  models = []
  for x in range(6):
    try:
      string = args.path+"modelFile"+str(x)+".h5"
      temp = load_model(string)
      #print("loading model", x)
      models.append(temp)
    except:
      models.append(None)
  print (models)

  #code that deals with the incoming OSC messages
  dispatcher = dispatcher.Dispatcher()
  dispatcher.map("/predict", predict_handler)
  dispatcher.map("/close", closeProgram)
  dispatcher.map("/prime", prime_arrays)

  server = osc_server.ThreadingOSCUDPServer(
      (args.ip, args.port), dispatcher)
  client = udp_client.SimpleUDPClient(args.ip, 57120)

  client.send_message("/loaded", 1)

  print("Serving on {}".format(server.server_address))
  server.serve_forever()