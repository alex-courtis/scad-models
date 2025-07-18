/*
TODO
allow negative y - a circle arc, resizing to rad
*/

/* [Fixed] */
default_rad = 23 / 2;

shaft_top = 7.8 * 1;
shaft_rad = 6.05 / 2;

nut_height = 2.12 * 1;
nut_rad = 11.1 / 2;

guard_height = 2.8 * 1;
guard_rad = 24.75 / 2;

/* [Fitting] */
nut_top_clearance = 0.35; // [0:0.01:5]
nut_side_clearance = 0.30; // [0:0.01:5]

shaft_top_clearance = 0.35; // [0:0.01:5]
shaft_side_clearance = 0.130; // [0:0.001:5]

guard_side_clearance = 0.875; // [0:0.001:5]

/* [Shape] */
base_eccentricity = 0.5; // [0:0.01:0.99]

base_y = 1; // [0:0.01:10]

top_eccentricity = 0.2; // [0:0.01:0.99]

top_y = 2; // [0:0.01:10]

top_r = 9; // [0:0.01:15]

indicator_angle = 5; // [0:0.01:15]
indicator_dr = 0.1; // [-5:0.01:5]

/* [Piece] */
piece = "both"; // ["both", "knob", "indicator"]

half = true;

rotation_angle = half ? 180 : 360;

$fn = 200; // [100:1:600]

module elipse_quadrant_cross_section(r, e, y) {
  intersection() {
    translate(v=[0, y]) {

      // elipse
      scale(v=[r, r * (1 - e)])
        circle();

      // maybe square base
      translate(v=[0, -y])
        square(size=[r, y], center=false);
    }

    // cut to the quadrant
    square(size=[r, r + y], center=false);
  }
}

module base_cross_section() {
  elipse_quadrant_cross_section(r=guard_rad - guard_side_clearance, e=base_eccentricity, y=base_y);
}

module top_cross_section() {
  elipse_quadrant_cross_section(r=top_r, e=top_eccentricity, y=top_y + base_y);
}

module all_cross_section() {
  base_cross_section();
  top_cross_section();
}

module nut_cross_section() {
  square([nut_rad + nut_side_clearance, nut_height + nut_top_clearance], center=false);
}

module shaft_cross_section() {
  square([shaft_rad + shaft_side_clearance, shaft_top + shaft_top_clearance], center=false);
}

module indicator() {
  color(c="red", alpha=1)
    rotate_extrude(angle=indicator_angle)
      resize(newsize=[guard_rad - guard_side_clearance + indicator_dr, 0])
        all_cross_section();
}

module knob() {
  color(c="lightgray", alpha=1)
    rotate_extrude(angle=rotation_angle - indicator_angle, start=indicator_angle)
      all_cross_section();
}

render()
  difference() {

    if (piece == "knob") {
      difference() {
        knob();
        indicator();
      }
    } else if (piece == "indicator") {
      indicator();
    } else if (piece == "both") {
      union() {
        knob();
        indicator();
      }
    }

    color(c="coral", alpha=1)
      rotate_extrude(angle=rotation_angle)
        nut_cross_section();

    color(c="tomato", alpha=1)
      rotate_extrude(angle=rotation_angle)
        shaft_cross_section();
  }
