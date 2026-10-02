public class Vocaloid {
    Gain bus => HPF filter => Chorus chorus => NRev reverb => dac;

    0.4 => bus.gain;
    250 => filter.freq;
    1.0 => filter.Q;
    8::ms => chorus.baseDelay;
    1.5 => chorus.modFreq;
    0.05 => chorus.modDepth;
    0.2 => chorus.mix;
    0.12 => reverb.mix;

    [[950.0, 1500.0, 3200.0],
     [330.0, 2700.0, 3400.0],
     [380.0, 1000.0, 2900.0],
     [550.0, 2300.0, 3100.0],
     [550.0,  950.0, 3000.0]] @=> float vowels[][];
    [1.0, 0.7, 0.5] @=> float levels[];
    [6.0, 9.0, 12.0] @=> float sharpness[];

    60::ms => dur glide;
    150::ms => dur vibratoDelay;
    250::ms => dur vibratoFade;
    5.5 => float vibratoRate;
    0.35 => float vibratoDepth;

    0 => float lastFreq;
    0 => int lastVowel;

    // slides pitch and mouth shape in from the previous note, then adds vibrato
    fun void sing(SawOsc osc, BPF formants[], float from, float to, int prev, int next) {
        now => time start;
        while (true) {
            now - start => dur t;
            Math.min(1.0, t / glide) => float slide;
            Math.max(0.0, Math.min(1.0, (t - vibratoDelay) / vibratoFade)) => float wobble;

            Math.sin(2 * pi * vibratoRate * (t / second)) * vibratoDepth * wobble => float bend;
            from * Math.pow(to / from, slide) * Math.pow(2, bend / 12) => float pitch;
            pitch => osc.freq;

            for (0 => int i; i < formants.size(); i++) {
                vowels[prev][i] + (vowels[next][i] - vowels[prev][i]) * slide => float f;
                // keep the first formant on top of the pitch so high notes don't thin out
                if (i == 0) Math.max(f, pitch) => f;
                f => formants[i].freq;
            }

            2::ms => now;
        }
    }

    fun void synth(float freq, Event off) {
        SawOsc osc => Gain source;
        Noise breath => source;
        ADSR env => bus;
        BPF formants[3];

        0.5 => osc.gain;
        0.02 => breath.gain;

        for (0 => int i; i < formants.size(); i++) {
            source => formants[i] => env;
            sharpness[i] => formants[i].Q;
            levels[i] => formants[i].gain;
        }

        // first note scoops up from two semitones below
        lastFreq => float from;
        if (from == 0) freq * Math.pow(2, -2.0 / 12) => from;
        lastVowel => int prev;
        Math.random2(0, vowels.size() - 1) => int next;
        freq => lastFreq;
        next => lastVowel;

        25::ms => env.attackTime;
        60::ms => env.decayTime;
        0.8 => env.sustainLevel;
        90::ms => env.releaseTime;

        spork ~ sing(osc, formants, from, freq, prev, next);

        env.keyOn();
        off => now;
        env.keyOff();

        env.releaseTime() => now;
        env =< bus;
    }
}
