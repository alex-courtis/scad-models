include <BOSL2/std.scad>
include <lib/geom.scad>

d_filament = 0.4;
t_layer = 0.2;

model = "glasses"; // ["glasses", "cross_section_test"]

part = "all"; // ["all", "side", ]

debug_holes = false;
circular_holes = false;

t1_rib = 0.3; // [0.05:0.05:5]
t2_rib = 0.8; // [0.05:0.05:5]
rib_inner = 2.5; // [1:0.1:7.5]
rib_outer = 2.5; // [1:0.1:7.5]
rib_tilt = 45; // [0:1:90]

spacing_hole = 5; // [0.1:0.1:10]
a_hole = 0; // [0:1:90]
l_hole = 3.25; // [0.05:0.05:5]
w_hole = 1.8; // [0.05:0.05:5]

t_side = 2.4; // [0.05:0.05:5]

// aspirational, rounded to hole spacing
l_glasses = 100; // [20:1:300]

// inside to inside
w_wall = 30; // [20:1:200]
t_wall = 1.2; // [0.05:0.05:5]

// of the end holes
d_side = 30; // [10:1:100]

w_side = d_side - 2 * rib_inner * sin(rib_tilt) + t2_rib * cos(rib_tilt);
echo(w_side=w_side);

w_side_inner = w_side - 2 * t2_rib * cos(rib_tilt);
echo(w_side_inner=w_side_inner);

l_side_straight = round_num(l_glasses - w_side_inner, spacing_hole);
echo(l_side_straight=l_side_straight);

$fn = 200;

poly_rib = [
  [-t2_rib / 2, -rib_inner],
  [-t1_rib / 2, rib_outer],
  [t1_rib / 2, rib_outer],
  [t2_rib / 2, -rib_inner],
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

module rib_curve(a_sweep, rib_tilt, d) {

  // round number of holes to a clean divisor of 90
  a_isoc = 2 * asin(spacing_hole / d);
  a = 90 / round(90 / a_isoc);

  echo(curve_spacing_hole=chord_len(d / 2, a));

  difference() {
    rotate_extrude(a=a_sweep)
      translate(v=[d / 2, 0])
        rotate(a=-rib_tilt)
          rib_cross();

    for (i = [0:a:a_sweep]) {
      rotate(a=i)
        translate(v=[d / 2, 0, 0])
          rotate(a=rib_tilt, v=[0, 1, 0])
            rotate(a=90, v=[1, 0, 0])
              hole_mask(hole_dir=1);
    }
  }
}

module rib_straight(l, hole_dir) {
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
module glasses_side() {
  z_t2_lower = -rib_inner * cos(rib_tilt) - t2_rib / 2 * sin(rib_tilt);
  echo(z_t2_lower=z_t2_lower);

  t_joining = t2_rib * sin(rib_tilt);
  echo(t_joining=t_joining);

  t_remainder = t_side - t_joining;
  echo(t_remainder=t_remainder);

  module curves() {

    // possible bug - part of the circle is removed by the fill prismoid 
    translate(v=[0, 0, 0.00000001])
      rotate(a=180)
        rib_curve(a_sweep=180, rib_tilt=rib_tilt, d=d_side);

    translate(v=[0, l_side_straight, 0])
      rib_curve(a_sweep=180, rib_tilt=rib_tilt, d=d_side);
  }

  module lines() {
    translate(v=[d_side / 2, l_side_straight / 2, 0])
      rotate(a=rib_tilt, v=[0, 1, 0])
        rib_straight(l=l_side_straight, hole_dir=1);

    translate(v=[-d_side / 2, l_side_straight / 2, 0])
      rotate(a=-rib_tilt, v=[0, 1, 0])
        rib_straight(l=l_side_straight, hole_dir=-1);
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

      color(c="blue")
        side();
    }
  }
}

module glasses_wall() {
  translate(v=[0, 0, -w_wall / 2]) {
    color(c="brown")
      translate(v=[0, l_side_straight / 2, 0])
        back_half()
          tube(od=w_side, id=w_side - 2 * t_wall, w_wall);

    color(c="orange") {
      translate(v=[(w_side - t_wall) / 2, 0, 0])
        cuboid([t_wall, l_side_straight, w_wall]);

      translate(v=[-(w_side - t_wall) / 2, 0, 0])
        cuboid([t_wall, l_side_straight, w_wall]);
    }
  }
}

render() {

  if (model == "glasses") {
    left_half(s=1000) {
      glasses_side();

      glasses_wall();

      translate(v=[0, 0, -w_wall])
        rotate(a=180, v=[0, 1, 0])
          glasses_side();
    }
  }

  if (model == "cross_section_test")
    cross_section_test();
}
