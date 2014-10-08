// **************************************
// load all the individual movement files
(
var theDir= (thisProcess.nowExecutingPath.dirname  ++ "/bubbleBass*.scd").pathMatch;

theDir.do({|item, i|
	item.load;
});
)

// ~verbose = "a"


(
// *****
// clock

var myTempo = TempoClock.new(150/60);

// *************
// MixerChannels

var chanKick = MixerChannel.newFromDef("kick", \twoPF1X2, s);
var chanBubbleBass = MixerChannel.newFromDef("bass", \twoPF2X2, s);
var chanRoll = MixerChannel.newFromDef("roll",  \twoPF1X2, s);

// ***********
// master block


// ******************
// add master channel
var master = MixerChannel.newFromDef("master", \mix2x2, s);
// masters["master"].level = 1;
// ************************************************************
// add destination channels and functionaility for send effects
var reverb  = MixerChannel(\rvb, s, 2, 2, level:1,
	outbus:master,
	completionFunc: { |chan|
	"creating reverb synth".postln;
	chan.playfx({ |outbus|
		var	sig = In.ar(outbus, 2);  // read from channel's bus
		FreeVerb2.ar(sig[0], sig[1], 1, 0.6, 0.5)
	});
});
var chorus = MixerChannel.new("chorus", s,2,2,outbus:master);

// ************
// mixing board
var theMixer = MixingBoard.new("Neve", mixers: [chanKick, chanRoll, chanBubbleBass, reverb, chorus, master]);
chorus.playfx(Instr.at(#[\busfx, \chorus2]));

// *****************************
// allocate the post fader sends

chanKick.newPostSend(reverb, 0.5);
chanKick.newPostSend(chorus, 0.5);

chanBubbleBass.newPostSend(reverb, 0.5);
chanBubbleBass.newPostSend(chorus, 0.5);

chanRoll.newPostSend(reverb, 0.5);
chanRoll.newPostSend(chorus, 0.5);

CmdPeriod.add( {
	MixerChannel.freeAll(s);
}); // end CmdPeriod

SystemClock.sched(2, {
Ppar([
	// kick drums
	Pbind(
		\instrument, \buffPlayer,
		\bufnum, Prand(~theKickBuffers.asArray, inf),
		\dur,  1,
		\amp, 0.7,
		\out, chanKick.inbus.index
	),
	// bubble bass
	Pbind(
		\instrument, \buffPlayerStereo,
		\dur, 32,
		\bufnum, Prand(~theBubbleBassBuffers.asArray, 3),
		\out, chanBubbleBass.inbus.index
	),
	// rolls
	Pbind(
		\instrument, \buffPlayer,
		\bufnum, ~rollBuffers.asArray[1],
			\dur,  Pseq([Rest(15), 1/4, 1/4, 1/4, 1/4],3),
		\amp, 0.7,
		\out, chanRoll.inbus.index
	)
]).play(myTempo);
}); // end clock
)



