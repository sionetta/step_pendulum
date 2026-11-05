// ================================================================
//  Step pendulum — phone cradle v2 (streamlined)
//  part = "cradle" | "bolt" | "knob" | "assembly"
//  Axes: x — along the phone length, y — up (along the ruler),
//        z — out of the back plate towards the screen; z = 0 is the back face.
// ================================================================
part = "assembly";

// ---------- Phone (lies horizontally) ----------
phone_l = 165; phone_w = 80; phone_t = 14;
clr = 0.6;

// ---------- Ruler ----------
ruler_w = 30; ruler_t = 5;

// ---------- Cradle ----------
H_end   = 30;      // height at the ends
H_mid   = 80;      // height at the centre (ruler mount)
flat_hw = 22;      // half-width of the flat top in the centre
back    = 4;       // back plate thickness
wall_e  = 3;       // end walls
wall_b  = 3;       // bottom supports
support = 30;      // length of each bottom support
lip     = 10;      // lip width over the screen
lip_t   = 2;       // lip thickness
R2      = 6;       // outline corner rounding
Rf      = 4;       // inner corner fillet of the lips
Re      = 1.5;     // edge rounding (all faces)
rail_w  = 3;
rail_h  = ruler_t - 1;   // ruler stays proud of the rails -> knob clamps the ruler

// ---------- Thread / bolt / knob ----------
th_rc = 3.4; th_e = 0.6; th_pitch = 3; th_clr = 0.35;   // Ø8 round thread
hex_af = 13; head_t = 2;
knob_d = 25; knob_h = 12;

$fn = 48;

// ---------- Derived ----------
xi = phone_l/2 + clr;            // inner face of the end walls
X  = xi + wall_e;                // outer half width
pocket_t = phone_t + 0.5;
H_tot = back + pocket_t + lip_t; // overall depth
bolt_y = wall_b + phone_w/2 + 0.5;
bolt_len = (back - head_t) + ruler_t + knob_h - 1;

// ================================================================
function top_y(x) = abs(x) <= flat_hw ? H_mid
    : H_end + (H_mid - H_end) * (0.5 + 0.5 * cos(180 * (abs(x) - flat_hw) / (X - flat_hw)));

module back_outline() {
    n = 60;
    pts = concat(
        [[-X, 0], [X, 0]],
        [for (i = [0 : n]) let(x = X - 2*X*i/n) [x, top_y(x)]]
    );
    offset(r = R2) offset(delta = -R2) polygon(pts);
}

// L-shaped corner claw seen from the front (right-hand corner)
module claw_outline() {
    offset(r = -Rf) offset(delta = Rf)          // fillet the inner corner
    offset(r = R2/2) offset(delta = -R2/2)      // round outer corners
    union() {
        translate([xi - support, 0]) square([X - xi + support, wall_b + lip]);
        translate([xi - lip, 0])     square([X - xi + lip, H_end]);
    }
}

// extrude with all edges of both faces rounded (stack of slices)
module rext(h, r, steps = 6) {
    for (i = [0 : steps]) {
        a = 90 * i / steps;
        inset = r * (1 - cos(a));
        dz = r * (1 - sin(a));
        translate([0, 0, dz]) linear_extrude(h - 2*dz) offset(delta = -inset) children();
    }
}

module rounded_box(size, r) {
    hull() for (x = [r, size[0] - r], y = [r, size[1] - r], z = [r, size[2] - r])
        translate([x, y, z]) sphere(r = r, $fn = 16);
}

module thread(len, rc) {
    linear_extrude(height = len, twist = -360 * len / th_pitch,
                   slices = ceil(len / th_pitch * 36), convexity = 6)
        translate([th_e, 0]) circle(r = rc, $fn = 48);
}
module hex(af, h) { cylinder(d = af / cos(30), h = h, $fn = 6); }

module cradle() {
    difference() {
        union() {
            // back plate
            rext(back, Re) back_outline();
            // corner claws: end wall + bottom support + lips
            for (s = [-1, 1]) mirror([s < 0 ? 1 : 0, 0, 0])
                difference() {
                    rext(H_tot, Re) claw_outline();
                    translate([-xi - 1, wall_b, back]) cube([2*xi + 1, 200, pocket_t]);
                }
            // ruler guide rails on the back
            for (s = [-1, 1])
                translate([s * (ruler_w/2 + 0.3 + rail_w/2) - rail_w/2, 2, -rail_h])
                    rounded_box([rail_w, H_mid - 4, rail_h + Re + 0.5], 1.2);
        }
        // bolt hole + hex recess for the head (pocket side)
        translate([0, bolt_y, -rail_h - 1]) cylinder(r = th_rc + th_e + 0.4, h = back + rail_h + 2);
        translate([0, bolt_y, back - head_t]) rotate([0, 0, 90]) hex(hex_af + 0.5, head_t + 1);
    }
}

module bolt() {
    rotate([0, 0, 30]) hex(hex_af, head_t);
    difference() {
        translate([0, 0, head_t - 0.01]) thread(bolt_len, th_rc);
        translate([0, 0, head_t + bolt_len - 1.2])
            difference() { cylinder(r = 10, h = 3); cylinder(r1 = th_rc + th_e, r2 = th_rc - th_e - 0.3, h = 1.5); }
    }
}

module knob() {
    difference() {
        hull() {
            for (a = [0 : 360/6 : 359]) rotate([0, 0, a]) translate([knob_d/2 - 3.5, 0, 0]) {
                translate([0, 0, 1]) cylinder(r = 3.5, h = knob_h - 2);
                cylinder(r = 2.5, h = knob_h);
            }
        }
        // finger scallops between the lobes
        for (a = [30 : 60 : 359]) rotate([0, 0, a]) translate([knob_d/2 + 1.2, 0, -1]) cylinder(r = 3.2, h = knob_h + 2);
        translate([0, 0, -0.01]) thread(knob_h + 0.02, th_rc + th_clr);
        translate([0, 0, -0.01]) cylinder(r1 = th_rc + th_e + 1, r2 = th_rc + th_e - 0.2, h = 1.2);
        translate([0, 0, knob_h - 1.19]) cylinder(r1 = th_rc + th_e - 0.2, r2 = th_rc + th_e + 1, h = 1.2);
    }
}

// ================================================================
if (part == "cradle") {
    rotate([90, 0, 0]) cradle();        // print standing on the bottom edge
} else if (part == "bolt") {
    bolt();
} else if (part == "knob") {
    knob();
} else {
    color("orange") cradle();
    color("DimGray", 0.5) translate([-phone_l/2, wall_b + 0.3, back + 0.2]) cube([phone_l, phone_w, phone_t]);
    color("burlywood") translate([-ruler_w/2, -150, -ruler_t]) cube([ruler_w, 450, ruler_t]);
    color("gray") translate([0, bolt_y, back]) rotate([180, 0, 0]) bolt();
    color("teal") translate([0, bolt_y, -ruler_t]) rotate([180, 0, 0]) knob();
}
