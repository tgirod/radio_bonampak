o = Server.local.options;
o.numInputBusChannels = 8;
s.boot;

SerialPort.devices;
~port = SerialPort.new("/dev/ttyACM1", 115200);
// https://www.youtube.com/watch?v=_NpivsEva5o

~readCurseur = Routine.new({
	var min = 63;
	var max = 201;
	var raw;
	{
		raw = ~port.read;
		~cursor = (raw - min) / (max - min);
		~cursor.postln;
	}.loop;
}).play;


(
SynthDef.new(\static, {
	arg prox = 1;
	var sig;
	sig = (BPF.ar(Saw.ar(100, 0.5), 200) + Crackle.ar(2)) * prox.lag(0.3);
	Out.ar(0, sig ! 2);
}).add;
)

(
SynthDef.new(\station, {
	arg source, prox = 0;
	var sig;
	sig = HPF.ar(
		source.ar() * prox.lag(0.3), // monter le vol quand on se rapproche
		(1 - prox.lag(0.3)) * 10000 // baisser le cutoff quand on se rapproche
	);
	Out.ar(0, sig ! 2);
}).add;
)

(
~st1 = Synth.new(\station, [\freq, 100]);
~st2 = Synth.new(\station, [\freq, 200]);
~st3 = Synth.new(\station, [\freq, 400]);
~static = Synth.new(\static, 1);

~cursor = 0;
~pouet = Routine.new({
	var v1,v2,v3,vs;
	{
		~cursor.postln;

		v1 = ~cursor.gaussCurve(a=1, b=0.2, c=0.02);
		v1.postln;
		~st1.set(\prox, v1);

		v2 = ~cursor.gaussCurve(a=1, b=0.5, c=0.02);
		v2.postln;
		~st2.set(\prox, v2);

		v3 = ~cursor.gaussCurve(a=1, b=0.7, c=0.02);
		v3.postln;
		~st3.set(\prox, v3);

		vs = (1-v1) * (1-v2) * (1-v3);
		vs.postln;
		~static.set(\prox, vs);

		1.yield;
	}.loop;
}).play;
)

~cursor = 0.20;
