# MLP for Pima Indians Dataset saved to single file
from numpy import loadtxt
from keras.models import Sequential
from keras.layers import Dense
import argparse

if __name__ == "__main__":
	parser = argparse.ArgumentParser()
	parser.add_argument("--numbersFile",
		default="trainingFile0.csv", help="The file")
	parser.add_argument("--modelFile",
		default="crossModel0.h5", help="The file")
	args = parser.parse_args()

	# load the data set for one setting
	dataset = loadtxt(args.numbersFile, delimiter=",")

	# split into input (X) and output (Y) variables
	X = dataset[:,0:16]
	Y = dataset[:,16:20]

	# define the model
	model = Sequential()
	model.add(Dense(12, input_dim=4, activation='relu'))
	model.add(Dense(12, activation='relu'))
	model.add(Dense(12, activation='relu'))
	model.add(Dense(16, activation='sigmoid'))

	# compile model
	model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
	# Fit the model
	model.fit(Y, X, epochs=2000, batch_size=10, verbose=1)
	# evaluate the model
	scores = model.evaluate(Y, X, verbose=1)
	print("%s: %.2f%%" % (model.metrics_names[1], scores[1]*100))
	# save model and architecture to single file
	model.save(args.modelFile)
	print("Saved model to disk")