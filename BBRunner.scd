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
var pKick, pBass, pRolls, pKickLea, pHatLea; // PBinds
var kicksArray = Array.newClear(4);


// ************************************************************************************
//                                 MIXER CHANNELS
// ************************************************************************************
// ***********
// master block

var masters = Dictionary.new;
var channels; // for the channels, excluding masters
var myMixer;

// ******************
// add master channel
masters["master"] = MixerChannel.newFromDef("master", \mix2x2, s);

// masters["master"].level = 1;

// ************************************************************
// add destination channels and functionaility for send effects

masters["reverb"] = MixerChannel(\rvb, s, 2, 2, level:1,
	outbus:masters["master"],
	completionFunc: { |chan|
	"creating reverb synth".postln;
	chan.playfx({ |outbus|
		var	sig = In.ar(outbus, 2);  // read from channel's bus
		FreeVerb2.ar(sig[0], sig[1], 1, 0.6, 0.5)
	});
});
masters["chorus"] = MixerChannel.new("chorus", s,2,2,outbus:masters["master"]);
masters["chorus"].playfx(Instr.at(#[\busfx, \chorus2]));


// ************************************************************************
//                       first do mono mixer channels
// ************************************************************************

channels = ["kick", "roll", "kickLea", "hatLea"].collectAs({|item, i|
	// put mixer channel in Dictionary
	item -> MixerChannel.newFromDef(item, \twoPF1X2, s, outbus:masters["master"]);

}, Dictionary); // end collect

// ************************************************************************
//                       then do stereo channels
// ************************************************************************


channels = channels ++ ["bubbleBass"].collectAs({|item, i|
	// put mixer channel in Dictionary
	item -> MixerChannel.newFromDef(item, \twoPF1X2, s, outbus:masters["master"]);

}, Dictionary); // end collect

// *******************
// make a mixing board
myMixer = MixingBoard.new("my Mixer", nil, channels);


// *****************************
// add these to the mixing board
myMixer.add(masters["chorus"]);
myMixer.add(masters["reverb"]);
myMixer.add(masters["master"]);

// ************************
// add the post fader sends
channels.do({|item, i|
	//"adding this stuff here!!!".postln;
	//item.newPostSend(chanReverb, 0.0);
	item.newPostSend(masters["reverb"], 0.0);
	item.newPostSend(masters["chorus"], 0.0)
	// item.mute(true, true);
});

// *************
// housekkeeping

CmdPeriod.add( {
	MixerChannel.freeAll(s);
}); // end CmdPeriod


// ************************************************************************************
//                                 PATTERNS
// ************************************************************************************
kicksArray.do({|item, i|
	kicksArray[i] = ~buffers["kicks"].asArray[~buffers["kicks"].size.rand.postln]
});
kicksArray.postln;

~aliceBuffers = Pseq([
	~buffers["licks"]["bubblebassA"].postln,
	~buffers["licks"]["bubblebassBb"],
	~buffers["licks"]["bubblebassA"],
	~buffers["licks"]["bubblebassBb"],
	~buffers["licks"]["bubblebassC"],
	~buffers["licks"]["bubblebassEb"],
	~buffers["licks"]["bubblebassF"],
	~buffers["licks"]["bubblebassC"]
	//~buffers["licks"]["bubblebassA"],
	//~buffers["licks"]["bubblebassA"],
	//~buffers["licks"]["bubblebassA"],

], 4);
~aliceDurs = Pseq([16,16,16,16,8,4,4,16], inf);

// pattern proxy for the rolls
~pRollBuffer = PatternProxy.new(~buffers["rolls"].asArray[1]);
// roll Patterns
~rollDurA = Pseq([1,1, Rest(3/2) , 1/4, 1/4], 1);
~rollDurB = Pseq([3.5, 1/4, 1/4], 1);
~rollDurC = Pseq([2,1/4,1/4,1/4,1/4,1/4,1/4, 1/4, 1/4], 1);
~compositeRoll1 = Place([
	~rollDurA, [~rollDurB, ~rollDurC]
], 100);

pKick = Pbind(
	\instrument, \buffPlayer,
	\bufnum, Pseq(kicksArray, inf),
	\dur,  1,
	\amp, 0.7,
	\out, channels["kick"].inbus.index
);

// leas kick drum

pKickLea = Pbind(
	\instrument, \buffPlayer,
	\bufnum, ~buffers["kicks"]["leasOrigKick"],
	\dur,  1,
	\amp, 0.7,
	\out, channels["kickLea"].inbus.index
);
pHatLea = Pbind(
	\instrument, \buffPlayer,
	\bufnum, ~buffers["kicks"]["leasOrigOhh"],
	\dur,  Pseq([Rest(1/2), Pseq([1], inf)], 1),
	\amp, 0.7,
	\out, channels["hatLea"].inbus.index
);
// bubble bass
pBass = Pbind(
	\instrument, \buffPlayerStereo2,
	\dur, ~aliceDurs, //16,
	\bufnum, ~aliceBuffers, //Prand(~buffers["licks"].asArray, 3),
	\out, channels["bubbleBass"].inbus.index
);
// rolls
pRolls = 	Pbind(
	\instrument, \buffPlayer,
	\bufnum, ~pRollBuffer,
	\dur, ~compositeRoll1,
	\amp, 0.7,
	\out, channels["roll"].inbus.index
);



SystemClock.sched(2, {
	Ppar([
		/*pKick,*/
		pKickLea,
		pHatLea,
		pBass,
		pRolls
	]).play(myTempo);

}); // end clock
)



