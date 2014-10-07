(
// ********************************
// declare the file array variables

var theKickFiles, theBubbleBassFiles, rollFiles; // an array of file names derived using .pathMatch method

// ********************************
// initialise lists for the buffers
~theKickBuffers = List.new(0);
~theBubbleBassBuffers = List.new(0);
~rollBuffers = List.new(0);

// ***********************
// now get the file arrays

theKickFiles= ("~/SC/DEV/bubblebass/kicks/res*.wav").pathMatch.postln;
theBubbleBassFiles= ("~/SC/DEV/bubblebass/licks/*.wav").pathMatch.postln;
rollFiles = ("~/SC/DEV/bubblebass/rolls/*.WAV").pathMatch.postln;

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
				~theKickBuffers.add(buffer);
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
				~theBubbleBassBuffers.add(buffer);
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
				~rollBuffers.add(buffer);
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

)



