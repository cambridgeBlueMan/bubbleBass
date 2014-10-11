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
var pKick, pBass, pRolls; // PBinds
var kicksArray = Array.newClear(4);

// ************************************************************************************
//                                 MIXER CHANNELS
// ************************************************************************************



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


// ************************************************************************************
//                                 PATTERNS
// ************************************************************************************
kicksArray.do({|item, i|
	kicksArray[i] = ~theKickBuffers.asArray[~theKickBuffers.size.rand.postln]
});
kicksArray.postln;

~aliceBuffers = Pseq([
	~theBubbleBassBuffers["bubblebassA"].postln,
	~theBubbleBassBuffers["bubblebassBb"],
	~theBubbleBassBuffers["bubblebassA"],
	~theBubbleBassBuffers["bubblebassBb"],
	~theBubbleBassBuffers["bubblebassC"],
	~theBubbleBassBuffers["bubblebassEb"],
	~theBubbleBassBuffers["bubblebassF"],
	~theBubbleBassBuffers["bubblebassC"]
	//~theBubbleBassBuffers["bubblebassA"],
	//~theBubbleBassBuffers["bubblebassA"],
	//~theBubbleBassBuffers["bubblebassA"],

], 4);
~aliceDurs = Pseq([16,16,16,16,8,4,4,16], inf);

// pattern proxy for the rolls
~pRollBuffer = PatternProxy.new(~rollBuffers.asArray[1]);

// kick drums

pKick = Pbind(
	\instrument, \buffPlayer,
	\bufnum, Pseq(kicksArray, inf),
	\dur,  1,
	\amp, 0.7,
	\out, chanKick.inbus.index
	);
	// bubble bass
pBass = Pbind(
		\instrument, \buffPlayerStereo2,
		\dur, ~aliceDurs, //16,
		\bufnum, ~aliceBuffers, //Prand(~theBubbleBassBuffers.asArray, 3),
		\out, chanBubbleBass.inbus.index
	);
	// rolls
pRolls = 	Pbind(
		\instrument, \buffPlayer,
		\bufnum, ~pRollBuffer, // ~rollBuffers.asArray[1],
			\dur,  Pseq([Rest(15), 1/4, 1/4, 1/4, 1/4],8),
		\amp, 0.7,
		\out, chanRoll.inbus.index
	);



SystemClock.sched(2, {
Ppar([
	pKick,
	pBass,
	pRolls
]).play(myTempo);

}); // end clock
)



