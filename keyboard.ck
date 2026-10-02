// z / x shift down / up an octave

@import "Pinch.ck"

// The synth to play
Pinch bass;

0 => int device;
if (me.args()) me.arg(0) => Std.atoi => device;

Hid hi;
HidMsg msg;
if (!hi.openKeyboard(device)) me.exit();
<<< "keyboard '" + hi.name() + "' ready", "" >>>;

"awsedftgyhujkolp" => string keys;
"z".charAt(0) => int OCTAVE_DOWN;
"x".charAt(0) => int OCTAVE_UP;

Event off[keys.length()];

// MIDI note of a
60 => int root;

while (true) {
    hi => now;
    while (hi.recv(msg)) {
        msg.ascii => int c;
        if (c >= 65 && c <= 90) 32 +=> c;

        if (msg.isButtonDown()) {
            if (c == OCTAVE_DOWN && root > 12) 12 -=> root;
            else if (c == OCTAVE_UP && root < 96) 12 +=> root;
        }

        keys.find(c) => int note;
        if (note < 0) continue;

        if (msg.isButtonDown()) {
            <<< "midi note:", root + note >>>;
            spork ~ bass.synth(Std.mtof(root + note), off[note]);
        } else if (msg.isButtonUp()) {
            off[note].broadcast();
        }
    }
}
