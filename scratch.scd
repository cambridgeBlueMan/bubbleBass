EIRMixerDef.new

m = MixerChannel.newFromDef("test", \eir, s);
b = MixingBoard.new("ssl", mixers: m)