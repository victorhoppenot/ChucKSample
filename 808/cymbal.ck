public class Cymbal {
    [205.3, 304.4, 369.6, 522.7, 540.0, 800.0] @=> float pitches[];
    7000.0 => float brightness;
    120::ms => dur decay;
    0.3 => float level;
    500::ms => dur length;

    fun void hit() {
        SqrOsc metal[pitches.size()];
        HPF filter => Gain amp => dac;

        for (0 => int i; i < metal.size(); i++) {
            metal[i] => filter;
            pitches[i] => metal[i].freq;
            1.0 / metal.size() => metal[i].gain;
        }
        brightness => filter.freq;

        now => time start;
        while (now - start < length) {
            now - start => dur t;
            level * Math.exp(-(t / decay)) * (1 - t / length) => amp.gain;
            1::ms => now;
        }

        amp =< dac;
    }
}
