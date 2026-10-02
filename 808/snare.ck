public class Snare {
    180.0 => float tone;
    60::ms => dur thump;
    1500.0 => float brightness;
    120::ms => dur decay;
    0.15 => float level;
    400::ms => dur length;

    fun void hit() {
        SinOsc body => Gain bodyAmp => Gain amp => dac;
        Noise rattle => HPF filter => Gain rattleAmp => amp;

        tone => body.freq;
        brightness => filter.freq;
        level => amp.gain;

        now => time start;
        while (now - start < length) {
            now - start => dur t;
            Math.exp(-(t / thump)) * (1 - t / length) => bodyAmp.gain;
            Math.exp(-(t / decay)) * (1 - t / length) => rattleAmp.gain;
            1::ms => now;
        }

        amp =< dac;
    }
}
