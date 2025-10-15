const std = @import("std");

const microzig = @import("microzig");
const rp2xxx = microzig.hal;

const de = @import("../../keycodes/de.zig");
const us = @import("../../keycodes/us.zig");
const core = @import("../../zigmkay/core.zig");
const NONE = core.KeyDef.none;
const _______ = NONE;

pub const key_count = 30;

// zig fmt: off
//core.KeyDef.transparent;
const L_BASE:usize = 0;
const L_ARROWS:usize = 1;
const L_NUM:usize = 2;
const L_EMPTY: usize = 3;
const L_BOTH:usize = 4;
const L_WIN:usize = 5;

const L_LEFT = L_NUM;
const L_RIGHT = L_ARROWS;

const A_EAT_SIGNAL = 42;
const A_EAT = core.KeyDef{ .tap_hold = .{
    .tap = .{ .key_press = us.A },
    .hold = .{ .custom = A_EAT_SIGNAL },
    .tapping_term = tapping_term,
} };

pub const keymap = [_][key_count]core.KeyDef{
    .{
         T(us.Q),  AF(us.W), CTL(us.F),   T(us.P), T(us.B),                  T(us.J),   T(us.L),  CTL(us.U),       T(us.Y), T(us.SEMICOLON),
         A_EAT, ALT(us.R), GUI(us.S),         SFT(us.T), T(us.G),                  T(us.M), SFT(us.N),   GUI(us.E),     ALT(us.I),    CTL(us.O),
                    T(us.X),   T(us.C),         T(us.D), T(us.V),                  T(us.K),  T(us.H), T(us.COMMA), LT(L_WIN, us.DOT),
                                             LT(L_LEFT, us.SPACE),                  LT(L_RIGHT, us.ENTER)
    },
    // L_ARROWS
    .{
   T(us.TAB),    T(us.LBRC),    CTL(us.RBRC),          T(us.LCBR), T(us.RCBR),             T(us.GRAVE),  T(us.HOME),   AF(us.UP),    T(us.END),  T(us.COLON),
    CTL(us.BACKSPACE), ALT(us.LPRN), GUI(us.RPRN),   SFT(us.LABK), T(us.RABK),             T(us.PGUP), AF(us.LEFT), AF(us.DOWN), AF(us.RIGHT), T(us.PGDN),
                  T(us.EXLM),   T(us.TILD),  T(us.BACKSLASH),    T(us.PIPE),                T(us.QUES),  CTL(us.SLASH), T(us.QUOT), T(us.DQUO),
                                        LT(L_LEFT, us.SPACE),                _______
    },
    // L_NUM
    .{
       T(us.HASH),  T(us.DLR),    T(us.PERC),  T(us.CART), T(us.AMPR),                  T(us.MINUS),   T(us.N7),  CTL(us.N8),  T(us.N9),    T(us.PLUS),
       CTL(us.AT),     UNDO,          REDO, T(us.ENTER), T(us.ASTER),                T(us.UNDERLINE), SFT(us.N4),GUI(us.N5),ALT(us.N6), CTL(us.EQUAL),
               T(us.ESC), T(_Gui(us.C)),   T(us.DEL), T(_Gui(us.V)),              T(de.EUR),   T(us.N1),  T(us.N2),  T(us.N3),
                                        LT(L_LEFT, us.SPACE),             LT(L_RIGHT, us.N0)
    },
    // L_EMPTY
    .{
            _______, _______, _______, _______, _______,                _______, _______, _______, _______, _______,
            _______, _______, _______, _______, _______,                _______, _______, _______, _______, _______,
                     _______, _______, _______, _______,                _______, _______, _______, _______,
                                             LT(L_LEFT, us.ENTER),                  LT(L_RIGHT, us.SPACE)

    },
    // BOTH
    .{
    _Gui(us.TAB),   T(us.F7),   CTL(us.F8),   T(us.F9), T(us.F10),            T(de.SRPS), T(us.SPACE), CTL(us.SPACE), T(us.SPACE), T(de.OE),
    _Gui(us.GRAVE), ALT(us.F4), GUI(us.F5), SFT(us.F6), T(us.F11),             T(de.AE),  SFT(us.BS),  GUI(us.BS),  ALT(us.BS),   CTL(us.ESC),
                      T(us.F1),   T(us.F2),   T(us.F3), T(us.F12),            T(us.CART),   T(de.DEL),   T(us.DEL),   T(us.DEL),
                                                   _______,              T(us.N0)
    },
    .{
    WinNav(us.N7), _______, WinNav(us.N1), WinNav(us.N6), _______,             _______, _______, _______, _______, _______,
    WinNav(us.N4), _______, WinNav(us.N2), WinNav(us.N5), _______,             _______, _______, _______, _______, _______,
                   _______, WinNav(us.N3), WinNav(us.N8), _______,             _______, _______, _______, _______,
                                                          _______,             _______
   },

};
// zig fmt: on
const LEFT_THUMB = 1;
const RIGHT_THUMB = 2;

const UNDO = T(_Gui(us.Z));
const REDO = T(.{ .tap_keycode = us.KC_Z, .tap_modifiers = .{ .left_shift = true, .left_gui = true } });

fn _Ctl(fire: core.KeyCodeFire) core.KeyCodeFire {
    var copy = fire;
    if (copy.tap_modifiers) |mods| {
        mods.left_ctrl = true;
    } else {
        copy.tap_modifiers = .{ .left_ctrl = true };
    }
    return copy;
}

fn _Gui(fire: core.KeyCodeFire) core.KeyCodeFire {
    var copy = fire;
    if (copy.tap_modifiers) |mods| {
        mods.left_gui = true;
    } else {
        copy.tap_modifiers = .{ .left_gui = true };
    }
    return copy;
}

fn _Alt(fire: core.KeyCodeFire) core.KeyCodeFire {
    var copy = fire;
    if (copy.tap_modifiers) |mods| {
        mods.left_alt = true;
    } else {
        copy.tap_modifiers = .{ .left_alt = true };
    }
    return copy;
}

fn _Sft(fire: core.KeyCodeFire) core.KeyCodeFire {
    var copy = fire;
    if (copy.tap_modifiers) |mods| {
        mods.left_shift = true;
    } else {
        copy.tap_modifiers = .{ .left_shift = true };
    }
    return copy;
}
fn C(key_press: core.KeyCodeFire, custom_hold: u8) core.KeyDef {
    return core.KeyDef{
        .tap_hold = .{
            .tap = .{ .key_press = key_press },
            .hold = .{ .custom = custom_hold },
            .tapping_term = tapping_term,
        },
    };
}

pub const dimensions = core.KeymapDimensions{ .key_count = key_count, .layer_count = keymap.len };
const PrintStats = core.KeyDef{ .tap_only = .{ .key_press = .{ .tap_keycode = us.KC_PRINT_STATS } } };
const tapping_term = core.TimeSpan{ .ms = 250 };
const combo_timeout = core.TimeSpan{ .ms = 40 };
pub const combos = [_]core.Combo2Def{
    Combo_Tap(.{ 1, 2 }, L_BASE, de.SRPS),
    Combo_Tap_HoldMod(.{ 20, 21 }, L_BASE, us.Z, .{ .right_ctrl = true }),
    Combo_Tap(.{ 22, 23 }, L_BASE, _Alt(us.U)),
    Combo_Tap(.{ 24, 25 }, L_BASE, _Alt(us.U)),

    // Combo_Tap_HoldMod(.{ 12, 13 }, L_BASE, us.V, .{ .left_ctrl = true, .left_shift = true }),
    Combo_Tap_HoldMod(.{ 12, 13 }, L_NUM, _Ctl(us.V), .{ .left_ctrl = true, .left_shift = true }),
    Combo_Tap_HoldMod(.{ 11, 12 }, L_NUM, _Ctl(us.X), .{ .left_ctrl = true, .left_shift = true }),
    Combo_Tap_HoldMod(.{ 12, 13 }, L_ARROWS, us.AMPR, .{ .left_ctrl = true, .left_shift = true }),

    Combo_Tap(.{ 13, 16 }, L_BOTH, core.KeyCodeFire{ .tap_keycode = us.KC_F4, .tap_modifiers = .{ .left_alt = true } }),

    Combo_Tap(.{ 23, 24 }, L_BASE, us.BOOT),
    Combo_Tap(.{ 0, 4 }, L_BASE, us.BOOT),
    Combo_Tap(.{ 5, 4 }, L_BASE, us.BOOT),
    Combo_Tap(.{ 6, 7 }, L_BASE, de.AE),
    Combo_Tap(.{ 6, 8 }, L_BASE, de.OE),
    Combo_Tap(.{ 7, 8 }, L_BASE, de.UE),

    Combo_Tap(.{ 7, 8 }, L_ARROWS, us.QUES),
    Combo_Tap(.{ 7, 8 }, L_BOTH, us.QUES),

    Combo_Tap(.{ 1, 2 }, L_ARROWS, us.EXLM),
    Combo_Tap(.{ 1, 2 }, L_BOTH, us.EXLM),

    Combo_Tap_HoldMod(.{ 17, 18 }, L_BASE, us.MINS, .{ .left_ctrl = true, .left_alt = true }),
    Combo_Tap(.{ 17, 18 }, L_ARROWS, us.PLUS),
    Combo_Tap(.{ 16, 17 }, L_ARROWS, us.PIPE),

    Combo_Tap(.{ 20, 21 }, L_ARROWS, us.BSLS),
};

// For now, all these shortcuts are placed in the custom keymap to let the user know how they are defined
// but maybe there should be some sort of helper module containing all of these
fn Combo_Tap(key_indexes: [2]core.KeyIndex, layer: core.LayerIndex, keycode_fire: core.KeyCodeFire) core.Combo2Def {
    return core.Combo2Def{
        .key_indexes = key_indexes,
        .layer = layer,
        .timeout = combo_timeout,
        .key_def = core.KeyDef{ .tap_only = .{ .key_press = keycode_fire } },
    };
}
fn Combo_Tap_HoldMod(key_indexes: [2]core.KeyIndex, layer: core.LayerIndex, keycode_fire: core.KeyCodeFire, mods: core.Modifiers) core.Combo2Def {
    return core.Combo2Def{
        .key_indexes = key_indexes,
        .layer = layer,
        .timeout = combo_timeout,
        .key_def = core.KeyDef{ .tap_hold = .{ .tap = .{ .key_press = keycode_fire }, .hold = .{ .hold_modifiers = mods }, .tapping_term = tapping_term } },
    };
}
// autofire
const one_shot_shift = core.KeyDef{ .tap_only = .{ .one_shot = .{ .hold_modifiers = .{ .left_shift = true } } } };
fn AF(keycode_fire: core.KeyCodeFire) core.KeyDef {
    return core.KeyDef{
        .tap_with_autofire = .{
            .tap = .{ .key_press = keycode_fire },
            .repeat_interval = .{ .ms = 50 },
            .initial_delay = .{ .ms = 150 },
        },
    };
}
fn MO(layer_index: core.LayerIndex) core.KeyDef {
    return core.KeyDef{
        .hold = .{ .hold_layer = layer_index },
    };
}
fn LT(layer_index: core.LayerIndex, keycode_fire: core.KeyCodeFire) core.KeyDef {
    return core.KeyDef{
        .tap_hold = .{
            .tap = .{ .key_press = keycode_fire },
            .hold = .{ .hold_layer = layer_index },
            .tapping_term = tapping_term,
        },
    };
}
// T for 'Tap-only'
fn WinNav(keycode: core.KeyCodeFire) core.KeyDef {
    return core.KeyDef{
        .tap_only = .{ .key_press = .{ .tap_keycode = keycode.tap_keycode, .tap_modifiers = .{ .left_gui = true } } },
    };
}
fn T(keycode_fire: core.KeyCodeFire) core.KeyDef {
    return core.KeyDef{
        .tap_only = .{ .key_press = keycode_fire },
    };
}
fn GUI(keycode_fire: core.KeyCodeFire) core.KeyDef {
    return core.KeyDef{
        .tap_hold = .{
            .tap = .{ .key_press = keycode_fire },
            .hold = core.HoldDef{ .hold_modifiers = .{ .left_gui = true } },
            .tapping_term = .{ .ms = 750 },
        },
    };
}
fn CTL(keycode_fire: core.KeyCodeFire) core.KeyDef {
    return core.KeyDef{
        .tap_hold = .{
            .tap = .{ .key_press = keycode_fire },
            .hold = core.HoldDef{ .hold_modifiers = .{ .left_ctrl = true } },
            .tapping_term = tapping_term,
        },
    };
}
fn ALT(keycode_fire: core.KeyCodeFire) core.KeyDef {
    return core.KeyDef{
        .tap_hold = .{
            .tap = .{ .key_press = keycode_fire },
            .hold = core.HoldDef{ .hold_modifiers = .{ .left_alt = true } },
            .tapping_term = tapping_term,
        },
    };
}
fn SFT(keycode_fire: core.KeyCodeFire) core.KeyDef {
    return core.KeyDef{
        .tap_hold = .{
            .tap = .{ .key_press = keycode_fire },
            .hold = core.HoldDef{ .hold_modifiers = .{ .left_shift = true } },
            .tapping_term = tapping_term,
        },
    };
}

fn on_event(event: core.ProcessorEvent, layers: *core.LayerActivations, output_queue: *core.OutputCommandQueue) void {
    switch (event) {
        .OnHoldEnterAfter => |data| {
            layers.set_layer_state(L_BOTH, layers.is_layer_active(L_LEFT) and layers.is_layer_active(L_RIGHT));
            if (data.hold.custom == A_EAT_SIGNAL) {
                const eat_word = core.KeyCodeFire{ .tap_keycode = us.KC_BACKSPACE, .tap_modifiers = .{ .left_alt = true } };
                output_queue.tap_key(eat_word) catch {};
            }
        },
        .OnHoldExitAfter => |_| {
            layers.set_layer_state(L_BOTH, layers.is_layer_active(L_LEFT) and layers.is_layer_active(L_RIGHT));
        },
        .OnTapExitAfter => |data| {
            if (data.tap.key_press) |key_fire| {
                if (key_fire.dead) {
                    output_queue.tap_key(us.SPACE) catch {};
                }
            }
        },
        else => {},
    }
}
pub const custom_functions = core.CustomFunctions{
    .on_event = on_event,
};
