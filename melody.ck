@import "LCDSS-Dance_Yrself-Clean/bass.ck"
@import "808/808.ck"
@import "808/snare.ck"
@import "808/cymbal.ck"
@import "dirty.ck"
@import "lead.ck"
@import "vocaloid.ck"


Dirty dirty;
Lead lead;
Vocaloid vocaloid;
Bass bass;
Kick kick;
Snare snare;
Cymbal cymbal;

0.8 => dac.gain;

140 => float bpm;
10 => int repeats;
(60 / bpm)::second => dur beat;

1 => int playing;


// Percussive Loops


fun void kicks() {
    while (playing) {
        spork ~ kick.hit();
        1::beat => now;
    }
    kick.length => now;
}
spork ~ kicks();

// fun void snares() {
//     0.5::beat => now;
//     while (playing) {
//         spork ~ snare.hit();
//         2::beat => now;
//     }
//     snare.length => now;
// }
// spork ~ snares();

fun void cymbals() {
    0.5::beat => now;
    while (playing) {
        spork ~ cymbal.hit();
        1::beat => now;
        Math.random2(1, 3)::beat / 2 => now;
    }
    cymbal.length => now;
}
spork ~ cymbals();


// Melody Loop


fun void bass1() {
    Event off;
    [40,  0,  40,  42,  37,  37, 37, 37, 35] @=> int notes[];
    [1.0, 2.5, 0.5, 0.5, 1.0, 1.0, 1.0, 1.0, 0.5] @=> float beats[];
    0.8 => float hold;
    while (playing) {
        for (0 => int i; i < notes.size(); i++) {
            beats[i]::beat => dur step;

            if (notes[i] == 0) {
                step => now;
                continue;
            }

            spork ~ bass.synth(Std.mtof(notes[i]), off);
            step * hold => now;
            off.broadcast();
            step * (1 - hold) => now;
        }
    }
}
spork ~ bass1();


fun void bass2() {
    Event off;
    [28, 25] @=> int notes[];
    [4.5, 4.5] @=> float beats[];
    1.0 => float hold;
    while (playing) {
        for (0 => int i; i < notes.size(); i++) {
            beats[i]::beat => dur step;

            if (notes[i] == 0) {
                step => now;
                continue;
            }

            spork ~ dirty.synth(Std.mtof(notes[i]), off);
            step * hold => now;
            off.broadcast();
            step * (1 - hold) => now;
        }
    }
}
spork ~ bass2();


fun void lead1() {
    Event off;
    // E major pentatonic, fits both the E and C# bass notes
    [0, 2, 4, 7, 9] @=> int scale[];
    76 => int root;
    7 => int maxDegree;
    [0.5, 0.5, 1.0] @=> float beats[];
    0.7 => float hold;
    0.15 => float restChance;
    Math.random2(0, maxDegree) => int degree;
    while (playing) {
        beats[Math.random2(0, beats.size() - 1)]::beat => dur step;

        if (Math.randomf() < restChance) {
            step => now;
            continue;
        }

        // random walk so the line moves by steps instead of jumping around
        Math.random2(-2, 2) +=> degree;
        Math.max(0, Math.min(maxDegree, degree)) $ int => degree;
        root + 12 * (degree / scale.size()) + scale[degree % scale.size()] => int note;

        spork ~ vocaloid.synth(Std.mtof(note), off);
        step * hold => now;
        off.broadcast();
        step * (1 - hold) => now;
    }
}
spork ~ lead1();


100::second => now;

0 => playing;
