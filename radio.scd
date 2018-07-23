// démarrer le serveur. C'est ici qu'on dit combien d'entrées audio on veut.
(
o = Server.local.options;
o.numInputBusChannels = 8;
s.boot;
)

// définition des instruments
(
SynthDef.new(\static, {
	arg prox = 1;
	var sig;
	sig = (BPF.ar(Saw.ar(100, 0.5), 200) + Crackle.ar(2)) * prox.lag(0.3);
	Out.ar(0, sig ! 2);
}).add;

SynthDef.new(\station, {
	arg channel, prox = 0;
	var sig;
	sig = HPF.ar(
		AudioIn.ar(channel) * prox.lag(0.3), // monter le vol quand on se rapproche
		(1 - prox.lag(0.3)) * 10000 // baisser le cutoff quand on se rapproche
	);
	Out.ar(0, sig ! 2);
}).add;
)

// création des instruments
(
~st1 = Synth.new(\station, [\channel, 1]);
~st2 = Synth.new(\station, [\channel, 2]);
~st3 = Synth.new(\station, [\channel, 3]);
~static = Synth.new(\static, 1);
)


// ouverture de la communication avec l'arduino
SerialPort.devices;
~port = SerialPort.new("/dev/ttyACM1", 115200);
// https://www.youtube.com/watch?v=_NpivsEva5o


// modification en fonction de la position du curseur
(
~readCurseur = Routine.new({
	var min = 63;
	var max = 201;
	var raw;

	var v1,v2,v3,vs;

	{
		// lecture du curseur
		raw = ~port.read;
		~cursor = (raw - min) / (max - min);
		raw.postln;
		~cursor.postln;

		// radio 1
		v1 = ~cursor.gaussCurve(a=1, b=0.2, c=0.02);
		~st1.set(\prox, v1);

		// radio 2
		v2 = ~cursor.gaussCurve(a=1, b=0.5, c=0.02);
		~st2.set(\prox, v2);

		// radio 3
		v3 = ~cursor.gaussCurve(a=1, b=0.7, c=0.02);
		~st3.set(\prox, v3);

		// static
		vs = (1-v1) * (1-v2) * (1-v3);
		~static.set(\prox, vs);
	}.loop;
}).play;
)