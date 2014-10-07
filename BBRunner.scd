// **************************************
// load all the individual movement files
(
var theDir= (thisProcess.nowExecutingPath.dirname  ++ "/bubbleBass*.scd").pathMatch;

theDir.do({|item, i|
	item.load;
});
)



x = Synth.new(\buffPlayer, [\bufnum, ~theKickBuffers[0]]);
y = Synth.new(\buffPlayerStereo, [\bufnum, ~theBubbleBassBuffers[0]])



// tempo.sched(0,
// 	{
//
// 		x = Synth.new(\buffPlayer, [\bufnum, ~theKickBuffers[0]]);
// 		1
// 	}
// );
// y = Synth.new(\buffPlayerStereo, [\bufnum, ~theBubbleBassBuffers[0]])
//
//
// ~tempo = nil

(
var myTempo = TempoClock.new(150/60);
Ppar([
	// kick drums
	Pbind(
		\instrument, \buffPlayer,
		\bufnum, Prand(~theKickBuffers, inf),
		\dur,  1,
		\amp, 0.7
	),
	// bubble bass
	Pbind(
		\instrument, \buffPlayerStereo,
		\dur, 32,
		\bufnum, Prand(~theBubbleBassBuffers, 3)
	),
	// rolls
	Pbind(
		\instrument, \buffPlayer,
		\bufnum, ~rollBuffers[1],
		\dur,  Pseq([15, 1/4, 1/4, 1/4, 1/4],3),
		\amp, 0.7
	)
]).play(myTempo);
)


Pbind(
\instrument, \buffPlayer
\bufnum,
).play


Synth(\buffPlayer, [\bufnum, 0])

s.makeGui