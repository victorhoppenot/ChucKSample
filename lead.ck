public class Lead {
    Gain bus => LPF filter => Chorus chorus => NRev reverb => dac;

    0.15 => bus.gain;
    6000 => filter.freq;
    1.5 => filter.Q;
    10::ms => chorus.baseDelay;
    2.0 => chorus.modFreq;
    0.1 => chorus.modDepth;
    0.3 => chorus.mix;
    0.15 => reverb.mix;

    fun void synth(float freq, Event off) {
        SqrOsc osc1 => ADSR env => bus;
        SawOsc osc2 => env;
        TriOsc top => env;

        freq => osc1.freq;
        freq * Math.pow(2, 0.1 / 12) => osc2.freq;
        freq * 2 => top.freq;

        0.2 => osc1.gain;
        0.15 => osc2.gain;
        0.1 => top.gain;

        5::ms => env.attackTime;
        80::ms => env.decayTime;
        0.5 => env.sustainLevel;
        150::ms => env.releaseTime;

        env.keyOn();
        off => now;
        env.keyOff();

        env.releaseTime() => now;
        env =< bus;
    }
}
