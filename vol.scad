/* [Fixed] */
default_r = 23 / 2;

shaft_top = 7.8 * 1;
shaft_r = 6.05 / 2;

nut_height = 2.12 * 1;
nut_r = 11.1 / 2;

guard_height = 2.8 * 1;
guard_r = 24.75 / 2;

slot_width = 0.9 * 1;
slot_height = 4.0 * 1;

/* [Fitting] */
nut_top_clearance = 0.35; // [0:0.01:5]
nut_side_clearance = 0.30; // [0:0.01:5]

shaft_top_clearance = 0.35; // [0:0.01:5]
shaft_side_clearance = 0.130; // [-0.5:0.001:0.5]

guard_side_clearance = 0.025; // [0:0.001:5]

slot_width_clearance = 0.25; // [0:0.001:1]
slot_height_clearance = 1; // [0:0.01:4]
slot_angle = 0; // [0:1:360]

/* [Shape] */
base_eccentricity = 0.5; // [0:0.01:1]

base_y = 1; // [0:0.01:10]

top_eccentricity = 0.2; // [0:0.01:1]

top_y = 2; // [0:0.01:10]

top_r = 9; // [0:0.01:25]

indicator_top_dr = 0.1; // [-5:0.01:5]
indicator_base_dr = 0.1; // [-5:0.01:5]
indicator_top_dh = 0.1; // [-5:0.01:5]
indicator_base_dh = 0.1; // [-5:0.01:5]
indicator_width = 1; // [0:0.01:5]

/* [Piece] */
piece = "both"; // ["both", "knob", "indicator"]

half = true;

rotation_angle = half ? 180 : 360;

$fn = 200; // [100:1:600]

// sanity check values
echo();
knob_r = guard_r - guard_side_clearance;
echo(knob_r=knob_r, guard_r=guard_r, knob_r / guard_r);
echo(top_r=top_r, top_r / knob_r);

echo();
nut_hole_r = nut_r + nut_side_clearance;
echo(nut_hole_r=nut_hole_r, nut_hole_r / nut_r);
nut_hole_height = nut_height + nut_top_clearance;
echo(nut_hole_height=nut_hole_height, nut_hole_height / nut_height);

echo();
shaft_hole_r = shaft_r + shaft_side_clearance;
echo(shaft_hole_r=shaft_hole_r, shaft_hole_r / shaft_r);
shaft_hole_height = shaft_top + shaft_top_clearance;
echo(shaft_hole_height=shaft_hole_height, shaft_hole_height / shaft_top);

echo();
base_height_calc = knob_r * (1 - base_eccentricity) + base_y;
echo(base_height_calc=base_height_calc);
indicator_base_h_mult = (base_height_calc + indicator_base_dh) / base_height_calc;
echo(indicator_height=base_height_calc * indicator_base_h_mult);
echo(indicator_base_h_mult=indicator_base_h_mult);
indicator_base_r_mult = (knob_r + indicator_base_dr) / knob_r;
echo(indicator_base_r_mult=indicator_base_r_mult);

echo();
top_height_calc = top_r * (1 - top_eccentricity) + base_y + top_y;
echo(top_height_calc=top_height_calc);
indicator_top_h_mult = (top_height_calc + indicator_top_dh) / top_height_calc;
echo(indicator_height=top_height_calc * indicator_top_h_mult);
echo(indicator_top_h_mult=indicator_top_h_mult);
indicator_top_r_mult = (top_r + indicator_top_dr) / top_r;
echo(indicator_top_r_mult=indicator_top_r_mult);

echo();

module elipse_quadrant_cross_section(r, e, y) {
  intersection() {
    translate(v=[0, y]) {

      if (e < 1) {
        scale(v=[r, r * (1 - e)])
          circle();
      }

      // maybe square base
      translate(v=[0, -y])
        square(size=[r, y], center=false);
    }

    // cut to the quadrant
    square(size=[r, r + y], center=false);
  }
}

module base_cross_section() {
  elipse_quadrant_cross_section(r=knob_r, e=base_eccentricity, y=base_y);
}

module top_cross_section() {
  elipse_quadrant_cross_section(r=top_r, e=top_eccentricity, y=top_y + base_y);
}

module nut_cross_section() {
  square([nut_hole_r, nut_hole_height], center=false);
}

module shaft_cross_section() {
  square([shaft_hole_r, shaft_hole_height], center=false);
}

module indicator(scale) {
  color(c="blue", alpha=1)
    rotate(a=90, v=[1, 0, 0])
      linear_extrude(height=indicator_width, center=true)
        union() {
          scale([scale ? indicator_base_r_mult : 1, scale ? indicator_base_h_mult : 1])
            base_cross_section();
          scale([scale ? indicator_top_r_mult : 1, scale ? indicator_top_h_mult : 1])
            top_cross_section();
        }
}

module knob() {
  color(c="lightgray", alpha=1)
    rotate_extrude(angle=rotation_angle, start=0) {
      base_cross_section();
      top_cross_section();
    }
}

module slot() {
  color(c="green", alpha=1)
    rotate(a=slot_angle, v=[0, 0, 1])
      translate(v=[0, 0, shaft_hole_height - slot_height / 2 + slot_height_clearance / 2])
        cube([slot_width - slot_width_clearance, shaft_hole_r * 2, slot_height - slot_height_clearance], center=true);
}

module holes() {
  color(c="coral", alpha=1)
    rotate_extrude(angle=rotation_angle)
      nut_cross_section();

  color(c="tomato", alpha=1)
    rotate_extrude(angle=rotation_angle)
      shaft_cross_section();
}

module piece_knob() {
  difference() {
    knob();
    indicator(scale=false);
    holes();
  }
  slot();
}

module piece_indicator() {
  difference() {
    indicator(scale=true);
    holes();
  }
}

render() {
  if (piece == "knob") {
    piece_knob();
  } else if (piece == "indicator") {
    piece_indicator();
  } else if (piece == "both") {
    piece_indicator();
    piece_knob();
  }
}
