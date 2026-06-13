include <BOSL2/std.scad>
include <lib/geom.scad>

d_filament = 0.4;
t_layer = 0.2;

model = "glasses"; // ["glasses", "glasses-side", "cross_section_test"]

debug_holes = false;
circular_holes = false;

t1_rib = 0.4; // [0.05:0.05:5]
t2_rib = 2.0; // [0.05:0.05:5]
rib_inner = 2.5; // [1:0.1:7.5]
rib_outer = 2.5; // [1:0.1:7.5]
rib_tilt = 45; // [0:1:90]

spacing_hole = 5; // [0.1:0.1:10]
a_hole = 0; // [0:1:90]
l_hole = 3.25; // [0.05:0.05:5]
w_hole = 1.8; // [0.05:0.05:5]

t_side = 3.0; // [0:0.05:5]

// aspirational, rounded to hole spacing
l_glasses = 100; // [20:1:300]

// inside to inside
w_wall = 60; // [20:1:200]
t_wall = 1.6; // [0:0.05:5]

// of the end hole midpoints
d_side = 40; // [10:1:100]

z_t2 = t2_rib * sin(rib_tilt);
echo(z_t2=z_t2);
t_side_min = max(t_side, z_t2);
echo(t_side_min=t_side_min);

// round number of holes to a clean divisor of 90
a_curve_hole = 90 / round(90 / asin(spacing_hole / d_side) / 2);
echo(a_curve_hole=a_curve_hole);
spacing_hole_curve = chord_len(d_side / 2, a_curve_hole);
echo(spacing_hole_curve=spacing_hole_curve);

d_rib_outer = d_side - 2 * rib_inner * sin(rib_tilt) + t2_rib * cos(rib_tilt);
echo(d_rib_outer=d_rib_outer);

d_rib_inner = d_rib_outer - 2 * t2_rib * cos(rib_tilt);
echo(d_rib_inner=d_rib_inner);

l_side_straight = round_num(l_glasses - d_rib_inner, spacing_hole);
echo(l_side_straight=l_side_straight);

echo();
echo("SIDE PIECE, covers ribs");
echo(width=d_rib_inner + 2 * rib_inner + 2 * rib_outer);
echo(length=l_side_straight + d_rib_inner + 2 * rib_inner + 2 * rib_outer);

echo();
echo("WALL PIECE, covers ribs, flat + quarter round");
echo(width=w_wall + 2 * t_side - 2 * z_t2 + 2 * rib_inner + 2 * rib_outer);
echo(length=l_side_straight + PI * d_rib_outer / 4);

echo();
echo("# half circle holes at", spacing_hole_curve, "=", 180 / a_curve_hole + 1);
echo("# straight holes at", spacing_hole, "=", l_side_straight / spacing_hole + 1);
echo("    ^ above intersect");

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

  difference() {
    rotate_extrude(a=a_sweep)
      translate(v=[d / 2, 0])
        rotate(a=-rib_tilt)
          rib_cross();

    for (i = [0:a_curve_hole:a_sweep]) {
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

// mid t2 at origin
module glasses_side() {

  // bottom of rib is at z 0
  dz_rib = rib_inner * cos(rib_tilt) - z_t2 / 2 + t_side_min;

  module curves() {
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

  module side() {
    cyl(d=d_rib_outer, t_side_min);

    translate(v=[0, l_side_straight, 0])
      cyl(d=d_rib_outer, t_side_min);

    translate(v=[0, l_side_straight / 2, 0])
      cube([d_rib_outer, l_side_straight, t_side_min], center=true);
  }

  translate(v=[0, -l_side_straight / 2, 0]) {
    color(c="brown")
      translate(v=[0, 0, dz_rib])
        curves();

    color(c="tan")
      translate(v=[0, 0, dz_rib])
        lines();

    color(c="blue")
      translate(v=[0, 0, t_side_min / 2])
        side();
  }
}

module glasses_wall() {
  dx_flat = (t_wall - d_rib_outer) / 2;

  translate(v=[0, 0, -w_wall / 2]) {
    color(c="tan")
      translate(v=[0, l_side_straight / 2, 0])
        back_half()
          tube(od=d_rib_outer, id=d_rib_outer - t_wall * 2, h=w_wall);

    color(c="brown") {
      translate(v=[dx_flat, 0, 0])
        cuboid([t_wall, l_side_straight, w_wall]);

      translate(v=[-dx_flat, 0, 0])
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
