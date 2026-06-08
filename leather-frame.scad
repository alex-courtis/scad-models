include <BOSL2/std.scad>
include <lib/geom.scad>

d_filament = 0.4;
t_layer = 0.2;

model = "glasses"; // ["glasses", "cross_section_test"]

part = "all"; // ["all", "side", ]

debug_holes = false;
circular_holes = false;

w_inner = 2.5; // [1:0.1:7.5]
w_outer = 2.5; // [1:0.1:7.5]

t1_rib = 0.3; // [0.05:0.05:5]
t2_rib = 0.8; // [0.05:0.05:5]

spacing_hole = 5; // [0.1:0.1:10]
a_hole = 0; // [0:1:90]
l_hole = 3.25; // [0.05:0.05:5]
w_hole = 1.8; // [0.05:0.05:5]

t_side = 2; // [0.05:0.05:5]

// aspirational, rounded to hole spacing
l_glasses = 160; // [20:1:300]

// of the end holes
d_side = 40; // [10:1:100]

a_tilt = 45; // [0:1:90]

w_side = d_side - 2 * w_inner * sin(a_tilt) + t2_rib * cos(a_tilt);
echo(w_side=w_side);

w_side_inner = w_side - 2 * t2_rib * cos(a_tilt);
echo(w_side_inner=w_side_inner);

l_side_straight = round_num(l_glasses - w_side_inner, spacing_hole);
echo(l_side_straight=l_side_straight);

$fn = 200;

poly_rib = [
  [-t2_rib / 2, -w_inner],
  [-t1_rib / 2, w_outer],
  [t1_rib / 2, w_outer],
  [t2_rib / 2, -w_inner],
];

poly_rib_hole = [
  [-t2_rib / 2, -0.25],
  [-t2_rib / 2, 0.25],
  [t2_rib / 2, 0.25],
  [t2_rib / 2, -0.25],
];

module rib_cross() {
  difference() {
    polygon(poly_rib);
    if (debug_holes || model == "cross_section_test") {
      polygon(poly_rib_hole);
    }
  }
}

module hole_mask(hole_dir) {
  h = max(t1_rib, t2_rib);
  if (circular_holes)
    rotate(a=90, v=[0, 1, 0]) {
      #cylinder(h=h, d=1, center=true);
    }
  else
    rotate(a=hole_dir * a_hole, v=[1, 0, 0]) {
      if (debug_holes)
        #cuboid([h, w_hole * 1, l_hole]);
      else
        cuboid([h, w_hole * 1, l_hole]);
    }
}

module curve(a_sweep, a_tilt, d) {

  // round number of holes to a clean divisor of 90
  a_isoc = 2 * asin(spacing_hole / d);
  a = 90 / round(90 / a_isoc);

  echo(curve_spacing_hole=chord_len(d / 2, a));

  difference() {
    rotate_extrude(a=a_sweep)
      translate(v=[d / 2, 0])
        rotate(a=-a_tilt)
          rib_cross();

    for (i = [0:a:a_sweep]) {
      rotate(a=i)
        translate(v=[d / 2, 0, 0])
          rotate(a=a_tilt, v=[0, 1, 0])
            rotate(a=90, v=[1, 0, 0])
              hole_mask(hole_dir=1);
    }
  }
}

module line(l, hole_dir) {
  rotate(a=90, v=[1, 0, 0])
    difference() {
      linear_extrude(h=l, center=true)
        rib_cross();

      for (i = [-l / 2:spacing_hole:l / 2]) {
        translate(v=[0, 0, i])
          hole_mask(hole_dir=hole_dir);
      }
    }
}

module cross_section_test() {
  difference() {
    linear_extrude(h=10, center=true) {
      rib_cross();
    }
    hole_mask(hole_dir=1);
  }
}

// inside oriented at origin
module glasses() {
  z_t2_lower = -w_inner * cos(a_tilt) - t2_rib / 2 * sin(a_tilt);

  t_joining = t2_rib * sin(a_tilt);
  echo(t_joining=t_joining);

  t_remainder = t_side - t_joining;
  echo(t_remainder=t_remainder);

  module curves() {

    rotate(a=180)
      curve(a_sweep=180, a_tilt=a_tilt, d=d_side);

    translate(v=[0, l_side_straight, 0])
      curve(a_sweep=180, a_tilt=a_tilt, d=d_side);
  }

  module lines() {
    translate(v=[d_side / 2, l_side_straight / 2, 0])
      rotate(a=a_tilt, v=[0, 1, 0])
        line(l=l_side_straight, hole_dir=1);

    translate(v=[-d_side / 2, l_side_straight / 2, 0])
      rotate(a=-a_tilt, v=[0, 1, 0])
        line(l=l_side_straight, hole_dir=-1);
  }

  module fill() {
    if (t_joining > 0) {

      translate(v=[0, 0, z_t2_lower + t_joining / 2]) {

        cyl(d1=w_side, d2=w_side_inner, t_joining);

        translate(v=[0, l_side_straight, 0])
          cyl(d1=w_side, d2=w_side_inner, t_joining);

        translate(v=[0, l_side_straight / 2, 0])
          prismoid(
            size1=[w_side, l_side_straight],
            size2=[w_side_inner, l_side_straight],
            h=t_joining,
            anchor=CENTER,
          );
      }
    }
  }

  module side() {

    translate(v=[0, 0, -t_remainder / 2 + z_t2_lower]) {
      cyl(d=w_side, t_remainder);

      translate(v=[0, l_side_straight, 0])
        cyl(d=w_side, t_remainder);

      translate(v=[0, l_side_straight / 2, 0])
        cuboid([w_side, l_side_straight, t_remainder]);
    }
  }

  translate(v=[0, -l_side_straight / 2, -z_t2_lower + t_remainder]) {
    if (part == "side" || part == "all") {
      color(c="brown")
        curves();

      color(c="orange")
        lines();

      color(c="steelblue")
        fill();

      color(c="lightgray")
        side();
    }
  }
}

render() {

  if (model == "glasses")
    glasses();

  if (model == "cross_section_test")
    cross_section_test();
}
