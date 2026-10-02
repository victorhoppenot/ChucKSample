public class Landline {
    Gain bus => dac;

    0.5 => bus.gain;

    fun void synth(float freq, Event off) {
        SqrOsc high => Gain drive => SinOsc distort => Envelope attack => bus;
        TriOsc low => drive;

        freq => high.freq;
        freq * (3/4) => low.freq;
        0.2 => high.gain;
        0.2 => low.gain;

        1 => distort.sync;
        0.55 => drive.gain;
        0.4 => distort.gain;

        30::ms => attack.duration;

        attack.keyOn();
        off => now;
        attack =< bus;
    }
}
