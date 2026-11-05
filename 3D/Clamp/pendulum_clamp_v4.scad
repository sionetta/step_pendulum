// ================================================================
//  Step pendulum — table clamp v3 (30 mm wide, ESP32-C3 SuperMini)
//  part = "body" | "screw" | "pad" | "assembly"
//
//  Axes: x — along the table edge, y — into the table (+) / outward (-),
//        z — up; z = 0 is the table top surface, table edge at y = 0.
//  SG90 stands vertically, shaft horizontal and pointing outward (-y).
// ================================================================
part = "assembly";

// ---------- Clamp ----------
W         = 30;
table_max = 50;
jaw_depth = 45;
spine_t   = 20;
top_t     = 18;     // top jaw thickness at the root (was 11: far weaker than the lower jaw)
top_tip_t = 8;
top_flat  = 20;     // top surface stays flat this far from the table edge
low_t     = 14;
low_root_t = 17;
R_out     = 3.3;
R_top     = 8;
R_bot     = 14;
R_fillet  = 8;
R_edge    = 2.5;
R_inner   = 3;      // fillet in the inner top corner (was a relief notch = stress raiser)

// ---------- SG90, vertical, inserted from inside ----------
sg_l = 22.5;  sg_w = 12.0;
sg_tab_l = 32.5; sg_tab_t = 2.5;
sg_hole_pitch = 27.8;
sg_below_tab = 15.9;
sg_shaft_from_end = 5.9;     // shaft near the upper end of the body
sg_clr = 0.3;
z_ax = -12.5;                // shaft height (whole servo pocket stays below the table top)
bezel_h = 2; bezel_w = 3;
screw_tip = 1.6;            // the kit screws stick out this far past the bezel face
boss_cover = 1.0;           // plastic left in front of the screw tip
boss_R = 9;                 // footprint radius of each boss

// ---------- ESP32-C3 SuperMini on top (long side along the table edge, USB-C at +x) ----------
// Printed on the side with +x up: the USB-C end faces up, the board ridges are vertical.
mc_l = 22.5; mc_w = 18.0; mc_clr = 0.4;
mc_board_t = 1.2;
mc_seat = 2.4;               // top surface -> board underside
mc_under = 2.5;              // room under the board for solder joints
mc_y0 = -12.5;               // outer edge of the board pocket (clear of the rounded outer corner)
usb_w = 15;                  // recess in the end wall for the USB-C plug overmold
usb_below = 2.2;             // recess bottom below the board underside (plug body is taller than the board)

// ---------- 6x6 tact button on the top jaw ----------
btn_x = 6.1;                 // recess across the legs-free sides
btn_y = 7.0;                 // recess along the leg direction (legs bent out)
btn_depth = 3;
btn_cy = 13;                 // recess centre from the table edge
leg_slot_d = 5;              // extra depth under the soldered legs
wire_d = 3.2;                // hidden round wire channel to the board
wire_bend = 3;               // bend radius of the channel

// ---------- Clamp screw ----------
cs_rc = 6.2; cs_e = 1.3; cs_pitch = 4; cs_clr = 0.5;   // Ø15 round thread
cs_y  = 30;
cs_len = 56;
knob_d = 25; knob_h = 12;    // same knob as on the phone cradle
ball_d = 10; neck_d = 9; neck_l = 2;

// ---------- Pad ----------
pad_d = 28; pad_t = 3;
sock_clr = 0.3;              // socket = ball + clearance
sock_wall = 2;               // wall around the ball
entry_d = 9.3;               // narrower than the ball -> snap
slits = 4; slit_w = 1.2;

$fn = 64;

// ---------- Derived ----------
sock_d  = ball_d + sock_clr;
boss_d  = sock_d + 2*sock_wall;
ball_c  = 5.5;                       // ball centre above the boss bottom
boss_h  = ball_c + sock_d/2 + 0.3;
pad_h   = boss_h + pad_t;
stack   = neck_l + ball_d/2 + (pad_h - ball_c);   // from thread top to the table
opening = table_max + stack;
low_top = -opening;
low_bot = low_top - low_t;
y_out   = -spine_t;
tab_top_y = -(sg_below_tab + sg_tab_t);
sg_z0  = z_ax - (sg_l - sg_shaft_from_end);       // body bottom end
sg_z1  = z_ax + sg_shaft_from_end;                // body top end
sg_cz  = (sg_z0 + sg_z1) / 2;
tab_holes_z = [sg_cz - sg_hole_pitch/2, sg_cz + sg_hole_pitch/2];
mc_cy = mc_y0 + (mc_w + mc_clr)/2;
mc_floor = top_t - mc_seat - mc_under;

// dome with a flat top and a cosine shoulder: tangent to the face it sits on
pod_h = bezel_h + screw_tip + boss_cover;
module boss() {
    n = 24; r0 = 2.5;
    rotate_extrude($fn = 64) polygon(concat(
        [[0, 0], [0, pod_h], [r0, pod_h]],
        [for (i = [1 : n]) let(t = i / n) [r0 + (boss_R - r0) * t, pod_h * (1 + cos(180 * t)) / 2]],
        [[boss_R, 0]]));
}

module tube(pts, d) {
    for (i = [0 : len(pts) - 2]) hull() {
        translate(pts[i]) sphere(d = d, $fn = 20);
        translate(pts[i + 1]) sphere(d = d, $fn = 20);
    }
}
module wire_channel() {
    zl = top_t - btn_depth - leg_slot_d;           // bottom of the leg slot
    zh = zl + wire_d/2 + 0.1;                      // channel axis
    yr = mc_y0 + mc_w + mc_clr - 1.2 - wire_d/2;   // riser position, inside the space under the board
    yc = yr + wire_bend; zc = zh + wire_bend;      // bend centre
    pts = concat(
        [[0, btn_cy - btn_y/2 + 1.0, zh]],
        [for (i = [0 : 6]) let(a = 90 * i / 6) [0, yc - wire_bend * sin(a), zc - wire_bend * cos(a)]],
        [[0, yr, mc_floor + 1.5]]);
    tube(pts, wire_d);
    // flared mouth where the channel leaves the leg slot
    translate([0, btn_cy - btn_y/2 + 0.6, zh]) rotate([90, 0, 0]) cylinder(d1 = wire_d + 1.6, d2 = wire_d, h = 1.4, $fn = 24);
}

// ================================================================
module thread(len, rc, e, pitch) {
    linear_extrude(height = len, twist = -360 * len / pitch,
                   slices = ceil(len / pitch * 36), convexity = 8)
        translate([e, 0]) circle(r = rc, $fn = 48);
}

module corner_cut(R, rot) {
    rotate(rot) difference() {
        translate([-0.01, -0.01]) square([R + 0.01, R + 0.01]);
        translate([R, R]) circle(r = R);
    }
}

module profile() {
    pts = [
        [y_out, top_t], [top_flat, top_t], [jaw_depth, top_tip_t], [jaw_depth, 0],
        [0, 0], [0, low_top], [jaw_depth, low_top], [jaw_depth, low_bot],
        [20, low_bot], [0, low_top - low_root_t], [y_out, low_top - low_root_t]
    ];
    difference() {
        union() {
            offset(r = R_out) offset(delta = -R_out) polygon(pts);
            translate([0, low_top]) difference() {
                square([R_fillet, R_fillet]);
                translate([R_fillet, R_fillet]) circle(r = R_fillet);
            }
            translate([0, -R_inner]) difference() {
                square([R_inner, R_inner]);
                translate([R_inner, 0]) circle(r = R_inner);
            }
        }
        translate([y_out, top_t]) corner_cut(R_top, 270);
        translate([y_out, low_top - low_root_t]) corner_cut(R_bot, 0);
    }
}

module rounded_extrude(w, r, steps = 5) {
    for (i = [0 : steps]) {
        a = 90 * i / steps;
        inset = r * (1 - cos(a));
        half  = w/2 - r * (1 - sin(a));
        rotate([90, 0, 90]) translate([0, 0, -half])
            linear_extrude(2 * half) offset(delta = -inset) children();
    }
}

module body() {
    bx = sg_w/2 + sg_clr + bezel_w;
    bz0 = min(sg_z0, tab_holes_z[0] - 2.5) - sg_clr - bezel_w + 1;
    bz1 = max(sg_z1, tab_holes_z[1] + 2.5) + sg_clr + bezel_w - 1;
    difference() {
        union() {
            rounded_extrude(W, R_edge) profile();
            // bezel around the servo on the outer face
            hull() for (x = [-bx + 2, bx - 2], z = [bz0 + 2, bz1 - 2])
                translate([x, y_out + 0.5, z]) rotate([90, 0, 0]) cylinder(r = 2, h = bezel_h + 0.5, $fn = 24);
            // streamlined pod over the servo: smooth bosses that hide the screw tips, joined by a hull
            hull() for (z = tab_holes_z) translate([0, y_out + 0.01, z]) rotate([90, 0, 0]) boss();
        }
        // --- servo: tab cavity open to the inner face (servo goes in from the table side)
        translate([-sg_w/2 - sg_clr, tab_top_y, sg_cz - sg_tab_l/2 - sg_clr])
            cube([sg_w + 2*sg_clr, -tab_top_y + 1, sg_tab_l + 2*sg_clr]);
        // body opening through the outer wall + bezel
        translate([-sg_w/2 - sg_clr, y_out - pod_h - 1, sg_z0 - sg_clr])
            cube([sg_w + 2*sg_clr, tab_top_y - (y_out - pod_h - 1) + 0.01, sg_l + 2*sg_clr]);
        // soft lead-in around the servo opening in the pod
        translate([0, y_out - pod_h - 0.01, sg_z0 + sg_l/2]) rotate([-90, 0, 0])
            linear_extrude(1.2, scale = [(sg_w + 2*sg_clr) / (sg_w + 2*sg_clr + 2.4), (sg_l + 2*sg_clr) / (sg_l + 2*sg_clr + 2.4)])
                square([sg_w + 2*sg_clr + 2.4, sg_l + 2*sg_clr + 2.4], center = true);
        // blind holes for the kit screws, driven from inside through the servo tabs
        for (z = tab_holes_z) translate([0, tab_top_y + 0.01, z]) rotate([90, 0, 0])
            cylinder(d = 2.0, h = (tab_top_y - y_out) + bezel_h + screw_tip + 0.3, $fn = 16);
        // cable channel: servo pocket (upper end, where the cable exits) -> under the board
        translate([-4.03, -9.07, sg_z1 - 1.03]) cube([8.06, 6.1, mc_floor - sg_z1 + 1.6]);

        // --- ESP32-C3 pocket on top (board long side along x, USB-C at +x)
        translate([-(mc_l + mc_clr)/2, mc_y0, top_t - mc_seat]) cube([mc_l + mc_clr, mc_w + mc_clr, mc_seat + 1]);
        translate([-(mc_l + mc_clr)/2 + 1.2, mc_y0 + 1.2, mc_floor])
            cube([mc_l + mc_clr - 2.4, mc_w + mc_clr - 2.4, mc_under + 0.01]);
        // slot in the +x end wall for the USB-C plug (straight cable exit along the table edge)
        hull() for (dy = [-usb_w/2 + 2.5, usb_w/2 - 2.5]) {
            translate([(mc_l + mc_clr)/2 - 0.01, mc_cy + dy, top_t - mc_seat - usb_below + 2.5]) rotate([0, 90, 0]) cylinder(r = 2.5, h = W, $fn = 32);
            translate([(mc_l + mc_clr)/2 - 0.01, mc_cy + dy - 2.5, top_t + 5]) cube([W, 5, 0.01]);
        }

        // --- 6x6 button recess on the top jaw
        translate([-btn_x/2, btn_cy - btn_y/2, top_t - btn_depth]) cube([btn_x, btn_y, btn_depth + 1]);
        // slot under the soldered legs (board side of the button)
        translate([-btn_y/2, btn_cy - btn_y/2 - 0.3, top_t - btn_depth - leg_slot_d]) cube([btn_y, 2.6, leg_slot_d + 0.01]);
        // hidden round wire channel: leg slot -> smooth bend -> up into the space under the board
        wire_channel();

        // --- threaded hole for the clamp screw, printed in place
        translate([0, cs_y, low_bot - 0.01]) thread(low_t + 0.02, cs_rc + cs_clr, cs_e, cs_pitch);
        translate([0, cs_y, low_bot - 0.01]) cylinder(r1 = cs_rc + cs_e + 1.2, r2 = cs_rc + cs_e, h = 1.21);
        translate([0, cs_y, low_top - 1.2])   cylinder(r1 = cs_rc + cs_e, r2 = cs_rc + cs_e + 1.2, h = 1.21);
    }
    // snap ridges on the long walls (vertical when printed on the side)
    for (xx = [-(mc_l + mc_clr)/2 + 4, (mc_l + mc_clr)/2 - 9], yw = [mc_y0, mc_y0 + mc_w + mc_clr])
        translate([xx, yw, top_t - mc_seat + mc_board_t + 0.7]) rotate([0, 90, 0]) cylinder(r = 0.6, h = 5, $fn = 16);
}

// knob identical to the one of the phone cradle (Ø25, 6 lobes)
module knob_shape() {
    difference() {
        hull() for (a = [0 : 60 : 359]) rotate([0, 0, a]) translate([knob_d/2 - 3.5, 0, 0]) {
            translate([0, 0, 1]) cylinder(r = 3.5, h = knob_h - 2);
            cylinder(r = 2.5, h = knob_h);
        }
        for (a = [30 : 60 : 359]) rotate([0, 0, a]) translate([knob_d/2 + 1.2, 0, -1]) cylinder(r = 3.2, h = knob_h + 2);
    }
}

module screw() {
    knob_shape();
    translate([0, 0, knob_h - 0.01]) thread(cs_len, cs_rc, cs_e, cs_pitch);
    top = knob_h + cs_len;
    translate([0, 0, top - 0.01]) cylinder(d1 = 2*(cs_rc - cs_e), d2 = neck_d, h = 0.8);
    translate([0, 0, top]) cylinder(d = neck_d, h = neck_l + ball_d/2);
    translate([0, 0, top + neck_l + ball_d/2]) sphere(d = ball_d, $fn = 48);
}

// pad: contact face on top, socket opens downward
module pad() {
    difference() {
        union() {
            translate([0, 0, boss_h]) hull() {
                translate([0, 0, 1]) cylinder(d = pad_d, h = pad_t - 1);
                cylinder(d = pad_d - 2, h = pad_t);
            }
            cylinder(d = boss_d, h = boss_h + 0.01);
        }
        translate([0, 0, ball_c]) sphere(d = sock_d, $fn = 48);
        translate([0, 0, -0.01]) cylinder(d = entry_d, h = ball_c);
        translate([0, 0, -0.01]) cylinder(d1 = entry_d + 1.6, d2 = entry_d, h = 0.8);
        // slits: let the socket fingers spring open
        for (i = [0 : slits - 1]) rotate([0, 0, i * 360 / slits])
            translate([0, -slit_w/2, -0.01]) cube([boss_d, slit_w, ball_c + 2.5]);
    }
}

// ================================================================
if (part == "body") {
    translate([0, 0, W/2]) rotate([0, -90, 0]) body();
} else if (part == "screw") {
    screw();
} else if (part == "pad") {
    translate([0, 0, pad_h]) rotate([180, 0, 0]) pad();
} else if (part == "assembly") {
    color("orange") body();
    %translate([-100, 0, -40]) cube([200, 250, 40]);
    pad_z = -40 - pad_h;
    color("teal") translate([0, cs_y, pad_z]) pad();
    color("gray") translate([0, cs_y, pad_z + ball_c - (knob_h + cs_len + neck_l + ball_d/2)]) screw();
    color("DarkBlue", 0.8) translate([-mc_l/2, mc_y0 + mc_clr/2, top_t - mc_seat]) cube([mc_l, mc_w, mc_board_t]);
    color("silver") translate([mc_l/2 - 7.3, mc_cy - 4.5, top_t - mc_seat + mc_board_t]) cube([7.5, 9, 3.2]);
    color("black") translate([-3, btn_cy - 3, top_t - btn_depth]) cube([6, 6, 3.5]);
    color("black") translate([0, btn_cy, top_t - btn_depth + 3.5]) cylinder(d = 3.5, h = 1.5);
    color("blue", 0.5) {
        translate([-sg_w/2, -sg_below_tab, sg_z0]) cube([sg_w, sg_below_tab, sg_l]);
        translate([-sg_w/2, tab_top_y, sg_cz - sg_tab_l/2]) cube([sg_w, sg_tab_t, sg_tab_l]);
        translate([-sg_w/2, tab_top_y - 4.3, sg_z0]) cube([sg_w, 4.3, sg_l]);
        translate([0, tab_top_y - 4.3, z_ax]) rotate([90, 0, 0]) cylinder(d = 11.8, h = 4);
    }
    color("burlywood") translate([0, tab_top_y - 10, z_ax]) rotate([0, 25, 0]) translate([-15, -2, -330]) cube([30, 2, 342]);
}
