public class Dirty {
    Gain bus => HPF filter => LPF lowpass => Chorus chorus => dac;

    0.2 => bus.gain;
    400 => filter.freq;
    1.0 => filter.Q;
    3000 => lowpass.freq;
    1.0 => lowpass.Q;
    15::ms => chorus.baseDelay;
    0.5 => chorus.modFreq;
    0.25 => chorus.modDepth;
    0.5 => chorus.mix;

    fun void synth(float freq, Event off) {
        SawOsc osc => bus;
        SqrOsc tri => bus;

        freq => osc.freq;
        freq => tri.freq;
        0.2 => osc.gain;
        0.2 => tri.gain;

        off => now;
        osc =< bus;
        tri =< bus;
    }
}
