/*
TODO
allow negative y - a circle arc, resizing to rad
*/

/* [Fixed] */
default_rad = 23 / 2;

knob_top = 7.8 * 1;
knob_rad = 6.05 / 2;

nut_height = 2.12 * 1;
nut_rad = 11.1 / 2;

guard_height = 2.8 * 1;
guard_rad = 24.75 / 2;

/* [Fitting] */
nut_top_clearance = 0.35; // [0:0.01:5]
nut_side_clearance = 0.30; // [0:0.01:5]

knob_top_clearance = 0.30; // [0:0.01:5]
knob_side_clearance = 0.130; // [0:0.001:5]

guard_side_clearance = 0.875; // [0:0.001:5]

/* [Shape] */
base_eccentricity = 0.5; // [0:0.01:0.99]

base_y = 1; // [0:0.01:10]

top_eccentricity = 0.2; // [0:0.01:0.99]

top_y = 2; // [0:0.01:10]

top_r = 9; // [0:0.01:15]

/* [Dev] */
rotation_angle = 180; // [0:1:360]

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

module nut_cross_section() {
  square([nut_rad + nut_side_clearance, nut_height + nut_top_clearance], center=false);
}

module knob_cross_section() {
  square([knob_rad + knob_side_clearance, knob_top + knob_top_clearance], center=false);
}

render()
  difference() {
    union() {
      color(c="darkgray", alpha=1)
        rotate_extrude(angle=rotation_angle)
          base_cross_section();

      color(c="lightgray", alpha=1)
        rotate_extrude(angle=rotation_angle)
          top_cross_section();
    }

    color(c="red", alpha=1)
      rotate_extrude(angle=rotation_angle)
        nut_cross_section();

    color(c="orange", alpha=1)
      rotate_extrude(angle=rotation_angle)
        knob_cross_section();
  }
