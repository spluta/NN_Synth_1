# NN_Synth_1

NN_Synth_1 is cross-feedback synthesis engine built in SuperCollider which uses a keras/tensorflow neural network to map the four dimensional vector of two x-y pads to a 16 dimensional vector of the synthesis engine. The model loads six simultaneous neural networks, which each give specific mappings of the data from the x-y controls to the synth. The user can quickly switch between active neural nets and also make their own mappings by training each NN in the system individually.

Dependencies:

numpy
tensorflow
keras
pythonosc

File Structure:

All files should be in the same folder. "python3" needs to be in the path of the OS.

To run the program:

1) The first time the program is run you need to load the SynthDef of the Synth that makes the sound. Open the "NN_Synth_1_SynthDef.scd" file, place the cursor inside the first parenthesis and press cmd-return.

2) Lemur needs to be installed on an iPad or Adroid device and the file "NN_Synth_1_Lemur" needs to be loaded. It must be sending data from "Osc 0" in Lemur to SC on port 57120. It will receive data from SC on port 8000. Currently, the ip address of Lemur is hardcoded to 127.0.0.1. If the user is sending OSC data over a network, this should be changed to the ip address of the Lemur app.

3) The main SC program is in the NN_Synth_1_SCFile.scd. To run the program, open the file in SC, place the cursor inside the parenthesis and press cmd-return. To stop the program, press cmd-period. This will also stop the Python program.

