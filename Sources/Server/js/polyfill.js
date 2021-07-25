global.self = global;

import 'text-encoding/lib/encoding-indexes';
import 'text-encoding/lib/encoding';

if (!global.TextEncoder) {
    global.TextEncoder = require('text-encoding').TextEncoder;
}
if (!global.TextDecoder) {
    global.TextDecoder = require('text-encoding').TextDecoder;
}

if (!global.SharedArrayBuffer) {
    global.SharedArrayBuffer = {
        prototype: {
            get byteLength() { }
        }
    };
}