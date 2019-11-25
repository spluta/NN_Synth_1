# NN_Synth_1

NN_Synth_1 is cross-feedback synthesis engine built in SuperCollider which uses a keras/tensorflow neural network to map the four dimensional vector of two x-y pads to a 16 dimensional vector of the synthesis engine. The model loads eight simultaneous neural networks, which each give specific mappings of the data from the x-y controls to the synth. The user can quickly switch between active neural nets and also make their own mappings by training each NN in the system individually.

Dependencies:

numpy
tensorflow
keras
pythonosc

File Structure:

All files should be in the same folder. The user will ned to manually set the path to python3 in the NN_Synth_1_SCFile.scd file.

To run the program:

1) The first time the program is run you need to load the SynthDef of the Synth that makes the sound. Open the "NN_Synth_1_SynthDef.scd" file, place the cursor inside the first parenthesis and press cmd-return.

2) Lemur needs to be installed on an iPad or Adroid device and the file "NN_Synth_1_Lemur" needs to be loaded. It must be sending data from "Osc 0" in Lemur to SC on port 57120. It will receive data from SC on port 8000. Currently, the ip address of Lemur is hardcoded to 127.0.0.1. If the user is sending OSC data over a network, this should be changed to the ip address of the Lemur app.

3) The main SC program is in the NN_Synth_1_SCFile.scd. To run the program, open the file in SC, place the cursor inside the parenthesis and press cmd-return. To stop the program, press cmd-period. This will also stop the Python program.

Some Things:

1) When the program starts, it will boot the server, load the keras models, and then prime the models. This will send 100 random values to the different models. If I don't do this, the models will be unresponsive. When the models are primed, the faders on Lemur should jump around for a couple of seconds. If this doesn't happen, SC does not have the correct NetAddr for your Lemur app.

2) Make sure to press the predictOn button on the Lemur. This will turn messaging between SC and python on.

Training a Model:

Each model is made of a number of points. 4 is a good minimum. To train the model:

1) Press the predict button so it says predictOff. This will stop the models from working.
2) Set the model to the one you want to train.
3) Press load points to load the points of the model.
4) You can flip through the points settings of the current model by pressing next point. This makes more sense with prediction on.
5) Clear point will clear the current point.
6) Make point will make a new point.
7) Once the points are all made, press train. 
8) The neural net model should reload automatically and be reprimed (the faders will jump around a bit).