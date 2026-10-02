public class Bass {
    Gain bus => LPF filter => Chorus chorus => NRev reverb => dac;

    0.5 => bus.gain;
    2000 => filter.freq;
    1.0 => filter.Q;
    15::ms => chorus.baseDelay;
    0.5 => chorus.modFreq;
    0.25 => chorus.modDepth;
    0.5 => chorus.mix;
    0.00 => reverb.mix;

    fun void synth(float freq, Event off) {
        SawOsc osc1 => ADSR env1 => bus;
        SawOsc osc2 => ADSR env => bus;
        SqrOsc sub => env;

        freq * 4 => osc1.freq;
        freq / 2 * Math.pow(2, 0.2 / 12) => osc2.freq;
        freq / 2 => sub.freq;

        0.1 => osc1.gain;
        0.2 => osc2.gain;
        0.2 => sub.gain;

        5::ms => env.attackTime;
        300::ms => env.decayTime;
        0.2 => env.sustainLevel;

        5::ms => env1.attackTime;
        200::ms => env1.decayTime;
        0.1 => env1.sustainLevel;
        
        400::ms => env.releaseTime => env1.releaseTime;

        env.keyOn();
        env1.keyOn();
        off => now;
        env.keyOff();
        env1.keyOff();


        env.releaseTime() => now;
        env =< bus;
        env1 =< bus;
    }
}
