include <BOSL2/std.scad>

d_filament = 0.4;
t_layer = 0.2;

model = "glasses"; // ["glasses", "cross_section_test"]

debug_holes = false;
circular_holes = false;

spacing_hole = 5;
a_hole = 45;

w_inner = 5;
w_outer = 3.0;

t1_rib = t_layer * 2;
t2_rib = 2.4;

l1_awl = 3.25;
l_hole = l1_awl;
w_hole = 1.2;

$fn = 200;

poly_rib = [
  [-t2_rib / 2, -w_inner],
  [-t1_rib / 2, w_outer],
  [t1_rib / 2, w_outer],
  [t2_rib / 2, -w_inner],
];

poly_rib_hole = [
  [-t2_rib / 2, -0.5],
  [-t2_rib / 2, 0.5],
  [t2_rib / 2, 0.5],
  [t2_rib / 2, -0.5],
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
  if (circular_holes)
    rotate(a=90, v=[0, 1, 0]) {
      #cylinder(h=t2_rib * 3, d=1, center=true);
    }
  else
    rotate(a=hole_dir * a_hole, v=[1, 0, 0]) {
      if (debug_holes)
        #cuboid([t2_rib * 3, w_hole * 1, l_hole]);
      else
        cuboid([t2_rib * 3, w_hole * 1, l_hole]);
    }
}

module curve(a_sweep, a_tilt, d) {

  // round number of holes to a clean divisor of 90
  a_isoc = 2 * asin(spacing_hole / d);
  a = 90 / round(90 / a_isoc);

  difference() {
    rotate_extrude(a=a_sweep)
      translate(v=[d / 2, 0])
        rotate(a=-a_tilt)
          rib_cross();

    for (i = [0:a:a_sweep]) {
      rotate(a=i)
        translate(v=[d / 2, 0, 0])
          rotate(a=a_tilt, v=[0, 1, 0])
            hole_mask(hole_dir=-1);
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

module glasses() {
  l = 50;
  d = 30;
  a_tilt = 45;

  curve(a_sweep=180, a_tilt=a_tilt, d=d);

  translate(v=[d / 2, -l / 2, 0])
    rotate(a=a_tilt, v=[0, 1, 0])
      line(l=l, hole_dir=1);

  translate(v=[-d / 2, -l / 2, 0])
    rotate(a=-a_tilt, v=[0, 1, 0])
      line(l=l, hole_dir=-1);
}

render() {

  if (model == "glasses")
    glasses();

  if (model == "cross_section_test")
    cross_section_test();
}
