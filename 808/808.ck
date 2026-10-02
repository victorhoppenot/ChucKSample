public class Kick {
    150.0 => float punch;
    48.0 => float tail;
    40::ms => dur sweep;
    200::ms => dur decay;
    0.6 => float level;
    800::ms => dur length;

    fun void hit() {
        SinOsc body => Gain amp => dac;

        now => time start;
        while (now - start < length) {
            now - start => dur t;
            tail + (punch - tail) * Math.exp(-(t / sweep)) => body.freq;
            level * Math.exp(-(t / decay)) * (1 - t / length) => amp.gain;
            1::ms => now;
        }

        amp =< dac;
    }
}
