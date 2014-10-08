(
// ********************************
// declare the file array variables

var theKickFiles, theBubbleBassFiles, rollFiles; // an array of file names derived using .pathMatch method

// ********************************
// initialise Dictionarys for the buffers
~theKickBuffers = Dictionary.new(0);
~theBubbleBassBuffers = Dictionary.new(0);
~rollBuffers = Dictionary.new(0);

// ***********************
// now get the file arrays

theKickFiles= ("~/SC/DEV/bubblebass/kicks/res*.wav").pathMatch;
theBubbleBassFiles= ("~/SC/DEV/bubblebass/licks/*.wav").pathMatch;
rollFiles = ("~/SC/DEV/bubblebass/rolls/*.WAV").pathMatch;

// **************************************
// load buffers and organise housekeeping

CmdPeriod.add({
	~theKickBuffers.do ({|item, i|
		item.free;
	});
	~theBubbleBassBuffers.do ({|item, i|
		item.free;
 	});
	~rollBuffers.do ({|item, i|
		item.free;
 	});
});

s.waitForBoot({
	theKickFiles.do({|path, i|
		Buffer.read(
			s,
			path,
			action:{|buffer|
				~theKickBuffers.put(path.basename.splitext[0], buffer).postln;
				if (i == (theKickFiles.size-1),
					{ "kicks loaded".postln;}
				); // end if
			} // end action
		);
	});
}); // end wait for boot
s.waitForBoot({
	theBubbleBassFiles.do({|path, i|
		Buffer.read(
			s,
			path,
			action:{|buffer|
				~theBubbleBassBuffers.put(path.basename.splitext[0], buffer);
				if (i == (theBubbleBassFiles.size-1),
					{ "bubbleBases loaded".postln;}
				); // end if
			} // end action
		);
	});
}); // end wait for boot
s.waitForBoot({
	rollFiles.do({|path, i|
		Buffer.read(
			s,
			path,
			action:{|buffer|
				~rollBuffers.put(path.basename.splitext[0], buffer);
				if (i == (rollFiles.size-1),
					{ "rolls loaded".postln;}
				); // end if
			} // end action
		);
	});
}); // end wait for boot

// *********
// synthdefs

SynthDef(\buffPlayerStereo, {| out = 0, bufnum = 0 |
    Out.ar(out,
        PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), doneAction:2)
    )
}).add;


// *************
// buffer player
SynthDef(\buffPlayer, {|out=0, bufnum = 0, loop = 0, amp = 0.7,  pan = 0|
	var sig = Pan2.ar(PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), loop: loop, doneAction: 2), pan)*amp;
		Out.ar( out, sig);
}).add; // end synth def

// **************************
// mkae the desired mixer gui

TwoPFMixerDef.new
)



