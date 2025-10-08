// These keycodes are copied from the qmk project under the gpl2 license
const core = @import("../zigmkay/zigmkay.zig").core;
const us = @import("us.zig");

pub const AE = core.KeyCodeFire{ .tap_keycode = us.KC_SEMICOLON }; // ä
pub const OE = core.KeyCodeFire{ .tap_keycode = us.KC_QUOTE }; // ö
pub const UE = core.KeyCodeFire{ .tap_keycode = us.KC_QUOTE }; // ü
