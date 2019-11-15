//place the cursor inside the parenthesis below and press cmd-return

(
SynthDef("NN_Synth_1",{
	var localIn, noise1, osc1, osc1a, osc1b, osc2, out, foldNum, dust, trigEnv, filtMod, filterFreq;

	localIn = LocalIn.ar(1);

	noise1 = RLPF.ar(
		Latch.ar(WhiteNoise.ar(\noiseVol.kr(0).clip(0, 3000)), Impulse.ar(\impulse.kr(10000).clip(100, 20000))),
		Lag.kr(\filterFreq.kr(10000), 0.05).clip(200, 20000), Lag.kr(\rq.kr(0.5), 0.05).clip(0.2, 2));

	osc1 = SinOscFB.ar(\freq1.kr(300, 0.05).clip(2, 10000)+(localIn*\modVol1.kr(1).clip(0, 3000))+noise1, \freq1.kr.linlin(100, 300, 2, 0.0));

	osc1 = SelectX.ar(\freq1.kr.linlin(15.0, 25.0, 0.0, 1.0), [osc1.linlin(-1.0,1.0, 0.0, 1.0), osc1]);

	osc2 = LFTri.ar(\freq2.kr(500, 0.05).clip(2, 10000)+(osc1*\modVol2.kr(1).clip(0, 3000)));

	osc2 = LeakDC.ar(osc2);

	LocalOut.ar(osc2);

	foldNum = \fold.kr(1).clip(0.1,1);

	out = [osc2.fold2(foldNum), osc2.fold2(foldNum*0.99)]/foldNum;

	dust = LagUD.ar(Trig1.ar(Dust.ar(\dustRate.kr(1000).clip(1, 1000)), \attack.kr(0.001).clip(0.001, 0.01)+\release.kr(0.001).clip(0.001, 0.01)), \attack.kr, \release.kr);

	out = SelectX.ar((\dustRate.kr<800), [out, out*dust]);

	out = out*\vol.kr(0, 0.05).clip(0,1)*Lag.kr(\onOff.kr(1), 0.01);

	trigEnv = LagUD.ar(LFPulse.ar(1/(\envRise.kr(0.5).clip(0.001, 2)+\envFall.kr(0.5).clip(0.001, 2)), 0, \envRise.kr/(\envRise.kr+\envFall.kr)), \envRise.kr, \envFall.kr);

	trigEnv = SelectX.ar(\envOnOff.kr(0), [K2A.ar(1), trigEnv]);

	filterFreq = \outFilterFreq.kr(20000).clip(20, 20000);

	filterFreq = (LFTri.ar(\filtModFreq.kr(0))*(\filtModAmp.kr(0).clip(0,1))).linexp(-1.0, 1.0, (filterFreq/2).clip(20, 20000), (filterFreq*2).clip(20, 20000));

	out = RLPF.ar(out, filterFreq, \outFilterRQ.kr(1).clip(0.1, 1));

	Out.ar(0, out*trigEnv);
}).load(s);
)