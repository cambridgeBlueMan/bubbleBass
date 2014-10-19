(

// get the root directory for the app
var appDir= thisProcess.nowExecutingPath.dirname;

// there will be a folder called "audio", and within that folder there
// will be a series of directories to hold samples
// the names of the folder will be in a literal array thus:

// add the name of all directories here


// now the whole job can be done by iterating the ~folders array
~folders = ["kicks", "licks", "rolls", "leaKick"];

// make a dictionary for pathmatches

~paths = Dictionary.new(0);

// and a dictioary for buffers

~buffers = Dictionary.new(0);


// now do the work

s.waitForBoot({
	// for each folder
	~folders.do({|folder, i|

		// ******************************************************
		// make the dictonary to hold the buffers for this folder
		~buffers[folder] = Dictionary.new(0);

		// get the file names held in the folder into an array
		~paths[folder] = (appDir ++ "/" ++ "/" ++ folder ++ "/*.*" ).pathMatch;

		// *************************************************************
		// now iterate the files in this folder and load them to buffers
		~paths[folder].do({|path, j|
			Buffer.read(
				s,
				path,
				action:{|buffer|
					~buffers[folder].put(path.basename.splitext[0], buffer);
					if (j == (~paths[folder].size-1),
						{(folder + "is loaded").postln;}
					); // end if
				} // end action
			);
		});

		// now set up the housekeeping
		CmdPeriod.add({
			~buffers[folder].do ({|item, i|
				item.free;
			});
		});
	}); // end folder do
}); // end wait for boot


// *********
// synthdefs

SynthDef(\buffPlayerStereo, {| out = 0, bufnum = 0 |
	Out.ar(out,
		PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), doneAction:2)
	)
}).add;

// another go at this, this time to enter anywhere and
// finish anywhere via he use of envelopes

SynthDef(\buffPlayerStereo2, {| out = 0, bufnum = 0, dur = 32|
	Out.ar(out,
		PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), doneAction:2)
		*
		EnvGen.ar(Env.linen(0.01, dur*0.4, 0.01, 1))
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



