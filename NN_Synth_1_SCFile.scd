//make sure the NN_Synth_1 SynthDef has been load from the NN_Synth_1_SynthDef - this only needs to be done once

//place the cursor inside the parenthesis below and press cmd-return

(
s.waitForBoot{
	var configure, xs, ys, zs, multiBallList, synthVals, pythonAddrs, lemurAddr, whichModel, valList, allValsList, saveFile, modelFile, synth, sliders, buttons, win, path, hasControl, zValsOnOff, predictOnOff, setSlidersAndMultis, currentPoint, setMultiBalls, setSlidersAndSynth, envChoice, envOnOff, sizeOfNN, trainingList, numModels, pythonPath, ports, reloadNN;

	pythonPath = "/usr/local/Cellar/python/3.7.5/Frameworks/Python.framework/Versions/3.7/bin/python3.7";

	"killall Terminal".unixCmd;

	numModels = 8;

	ports = List.fill(numModels, {|i| 5005+i});

	pythonAddrs = List.fill(numModels, {|i| NetAddr("127.0.0.1", ports[i])});
	lemurAddr = NetAddr("127.0.0.1", 8000);

	sizeOfNN = 16;

	hasControl = Array.fill(sizeOfNN, {0});
	predictOnOff = 0;
	zValsOnOff = 0;
	currentPoint = 0;

	path = Document.current.dir++"/";

	//(pythonPath+path++"NN_Synth_1_Predict.py"+"--path"+path).postln.runInTerminal;
	numModels.do{|i|
		(pythonPath+path++"NN_Synth_1_Predict.py"+"--path"+path+"--port"+ports[i].asString+"--num"+i.asString+"&").unixCmd;
	};

	CmdPeriod.add({pythonAddrs.do{|i|i.sendMsg('/close')}});

	synth = Synth("NN_Synth_1");

	OSCFunc({arg ...msg;
		"prime".postln;
		msg.postln;
		allValsList.put(msg[0][1], msg[0].copyRange(2, msg[0].size-1).addAll([0,0,0,0]).asList);
		allValsList.postln;
	}, \prime);

	//prime the pump
	OSCFunc({arg ...msg;
		msg.postln;
		({
			1.wait;
			100.do{
				pythonAddrs[numModels.rand].sendMsg(*['/predict'].addAll(Array.fill(4, {1.0.rand})));
				0.01.wait
			};
			numModels.do{|i|
				pythonAddrs[i].sendMsg(*['/prime'].addAll(Array.fill(4, {0})));
				0.01.wait
			};
		}.fork)
	}, \loaded);

	whichModel = 0;

	multiBallList = List[[0,0],[0,0]];

	configure = {
		2.do{|i| multiBallList.put(i, [xs[i], ys[i]])};
		if(predictOnOff==1){pythonAddrs[whichModel].sendMsg(*['/predict'].addAll(multiBallList.flatten))};
	};

	xs = List.fill(2, {0});
	ys = List.fill(2, {0});
	zs = List.fill(2, {0});

	['/MultiBall/', 'MultiBall2/'].do{|item, i|

		OSCFunc({arg ...msg;
			xs.put(i, msg[0][1]);
			configure.value;
		}, item++'x');

		OSCFunc({arg ...msg;
			ys.put(i, msg[0][1]);
			configure.value;
		}, item++'y');

		OSCFunc({arg ...msg;
			zs.put(i, msg[0][1]);
			switch(envChoice,
				0, {synth.set(\onOff, 1, \envOnOff, 0)},
				1, {synth.set(\onOff, zs[zs.maxIndex], \envOnOff, 0)},
				2, {"env".postln; synth.set(\onOff, zs[zs.maxIndex], \envOnOff, 1)}
			);
		}, item++'z');
	};

	OSCFunc({arg ...msg;
		allValsList.put(whichModel, valList.addAll(multiBallList.flatten));
		whichModel = (msg[0].copyRange(1,numModels)*Array.series(numModels)).sum.asInteger;
		valList = allValsList[whichModel].copyRange(0,sizeOfNN-1);
		setSlidersAndSynth.value(valList);
		setMultiBalls.value(allValsList[whichModel].copyRange(sizeOfNN,sizeOfNN+4));
		whichModel.postln;
	}, '/Switches/x');

	lemurAddr.sendMsg(*['/Switches/x'].addAll([1]).addAll(Array.fill(numModels-1, {0})));

	synthVals = [['/Fader/', \freq1, ControlSpec(1, 10000, \exp)],
		['/Fader2/', \freq2, ControlSpec(5, 10000, \exp)],
		['/Fader3/', \modVol1, ControlSpec(0, 3000)],
		['/Fader4/', \modVol2, ControlSpec(0, 3000)],
		['/Fader5/', \noiseVol, ControlSpec(0, 3000)],
		['/Fader6/', \impulse, ControlSpec(100, 20000, \exp)],
		['/Fader7/', \filterFreq, ControlSpec(100, 20000, \exp)],
		['/Fader8/', \rq, ControlSpec(0.1, 2)],
		['/Fader9/', \fold, ControlSpec(0.1, 1)],
		['/Fader10/', \dustRate, ControlSpec(1000, 1)],
		['/Fader11/', \attack, ControlSpec(0.001, 0.01, \exp)],
		['/Fader12/', \release, ControlSpec(0.001, 0.01, \exp)],
		['/Fader13/', \outFilterFreq, ControlSpec(20, 20000, \exp)],
		['/Fader14/', \outFilterRQ, ControlSpec(0.1, 2, \exp)],
		['/Fader15/', \filtModFreq, ControlSpec(0, 30, \lin)],
		['/Fader16/', \filtModAmp, ControlSpec(0, 1, \amp)],
		['/Fader17/', \vol, ControlSpec(0, 0.2, \amp)],
		['/Fader18/', \envRise, ControlSpec(0.01, 1, \exp)],
		['/Fader19/', \envFall, ControlSpec(0.01, 1, \exp)]

	];

	setSlidersAndSynth = {|vals|
		//vals.postln;
		vals.do{|item, i|
			if(i<sizeOfNN,{
				if(hasControl[i]==0,{
					synth.set(synthVals[i][1], synthVals[i][2].map(item));
					lemurAddr.sendMsg(*[synthVals[i][0]++'x'].addAll(item));
				});
			});
		};
	};

	(17..19).do{|i|
		lemurAddr.sendMsg('/Fader'++i.asSymbol++'/x', 0);
	};

	setMultiBalls = {|vals|
		//vals.postln;
		lemurAddr.sendMsg('MultiBall/x', vals[0]);
		lemurAddr.sendMsg('MultiBall/y', vals[1]);
		lemurAddr.sendMsg('MultiBall2/x', vals[2]);
		lemurAddr.sendMsg('MultiBall2/y', vals[3]);
		multiBallList = vals.clump(2).postln;
	};

	OSCFunc.new({arg ...msg;
		//msg.postln;
		setSlidersAndSynth.value(msg[0].copyRange(1,sizeOfNN));
		valList = msg[0].copyRange(1,sizeOfNN).asList;
	}, '/nnOutputs');

	sliders = List.newClear(0);

	valList = List.fill(sizeOfNN, {0});
	allValsList = List.fill(8, {List[0,0,0,0,0,1,1,1,1,0,0,0,1,1,0,0,0,0,0,0]});

	synthVals.do{arg item, i;
		sliders.add(QtEZSlider(item[1], item[2], {arg val; synth.set(item[1], val.value)}));
		OSCFunc({arg ...msg;
			var val;
			val = msg[0][1];
			if(i<sizeOfNN){valList.put(i, val)};
			synth.set(item[1], item[2].map(val));
		}, item[0]++'x');

		OSCFunc({arg ...msg;
			if(i<sizeOfNN){
				hasControl.put(i, msg[0][1]);
				hasControl.postln
			};
		}, item[0]++'z');
	};

	/*win = Window("neuralNet");

	sliders.postln;
	win.layout=HLayout(*sliders.collect≥({|x| x.layout}));*/

	trainingList = List.newClear(0);

	setSlidersAndMultis = {
		if(trainingList.size>0){
			setSlidersAndSynth.value(trainingList[currentPoint].copyRange(0,sizeOfNN-1));
			setMultiBalls.value(trainingList[currentPoint].copyRange(sizeOfNN,sizeOfNN+4));
		};
	};

	OSCFunc({arg ...msg;
		"load".postln;
		trainingList = CSVFileReader.read(path++"trainingFile"++whichModel++".csv");
		trainingList = trainingList.collect({arg item; item.collect({arg item2; item2.asFloat})}).asList;
		currentPoint = 0;
		setSlidersAndMultis.value;
	}, '/CustomButton/x');

	OSCFunc({arg ...msg;
		currentPoint = (currentPoint+1).wrap(0, trainingList.size-1).postln;
		setSlidersAndMultis.value;
	}, '/CustomButton2/x');

	OSCFunc({arg ...msg;
		trainingList.size.postln;
		if(trainingList.size>0){
			trainingList.removeAt(currentPoint);
			currentPoint = max(currentPoint-1, 0);
			//setSlidersAndMultis.value;
		};
		trainingList.size.postln;
	}, '/CustomButton3/x');

	//make a point
	OSCFunc({arg ...msg;
		trainingList.size.postln;
		trainingList.add(valList.copyRange(0,sizeOfNN-1).addAll(multiBallList.flatten.postln));
		trainingList.size.postln;
	}, '/CustomButton4/x');

	//train the NN
	OSCFunc({arg ...msg;
		msg.postln;
		{
			saveFile = File(path++"trainingFile"++whichModel++".csv", "w");

			trainingList.do{arg item;
				item.do{|item2, i|
					if(i!=0){saveFile.write(", ")};
					item2 = item2.asString;
					saveFile.write(item2);

				};
				saveFile.write("\n");
			};
			saveFile.close;
			1.wait;

			saveFile = path++"trainingFile"++whichModel++".csv";
			modelFile = path++"modelFile"++whichModel++".h5";
			(pythonPath+path++"NN_Synth_1_Save.py"+"--numbersFile"+saveFile+"--modelFile"+modelFile+"--num"+whichModel.asString+"&").postln.unixCmd;
		}.fork;
		OSCFunc({
			reloadNN.value(whichModel);
			"trained".postln;
		}, '/trained').oneShot;
	}, '/CustomButton5/x');

	reloadNN = {arg num;
		{
			"close".postln;
			pythonAddrs[num].sendMsg('/close');
			1.wait;
			"reload ".post; num.postln;
			(pythonPath+path++"NN_Synth_1_Predict.py"+"--path"+path+"--port"+(ports[whichModel]).asString+"--num"+num.asString+"&").postln.unixCmd;
			//(pythonPath+path++"NN_Synth_1_Predict.py"+"--path"+path+"--port"+(5005+i).asString+"--num"+i.asString+"&").unixCmd;
			1.wait;
			10.do{
				pythonAddrs[num].sendMsg(*['/predict'].addAll(Array.fill(4, {1.0.rand})));
				0.01.wait
			};
		}.fork;
	};

	OSCFunc({arg ...msg;
			reloadNN.value(whichModel);
	}, '/CustomButton6/x');

	OSCFunc({arg ...msg;
		predictOnOff = msg[0][1];
	}, '/CustomButton7/x');

	lemurAddr.sendMsg('/CustomButton7/x', 0);

	/*OSCFunc({arg ...msg;
	zValsOnOff = msg[0][1];
	}, '/CustomButton8/x');*/
	envChoice = 0;
	OSCFunc({arg ...msg;
		envChoice = (msg[0].copyRange(1,3)*Array.series(3)).sum.asInteger;
		switch(envChoice,
			0, {synth.set(\onOff, 1, \envOnOff, 0)},
			1, {synth.set(\onOff, zs[zs.maxIndex], \envOnOff, 0)},
			2, {"env".postln; synth.set(\onOff, zs[zs.maxIndex], \envOnOff, 1)}
		);
	}, '/Switches2/x');
	lemurAddr.sendMsg('/Switches2/x', 1, 0, 0);
}
)
