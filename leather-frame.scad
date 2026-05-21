include <BOSL2/std.scad>

d_filament = 0.4;
t_layer = 0.2;

model = "glasses"; // ["glasses", "cross_section_test"]

debug_holes = false;
circular_holes = false;

spacing_hole = 5;
a_hole = 45;

w_inner = 2.5;
w_outer = 2.5;

t1_rib = t_layer * 2;
t2_rib = 1.2;
t_base = 1.2;

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
  l = 125;
  d = 40;
  a_tilt = 45;

  z_base = t2_rib * sin(a_tilt);
  echo(z_base=z_base);

  dz_base_mid = -w_inner * cos(a_tilt);
  echo(dz_base_mid=dz_base_mid);

  d_base_mid = d - 2 * w_inner * sin(a_tilt);
  d_base_outer = d_base_mid + t2_rib * cos(a_tilt);
  echo(d_base_outer=d_base_outer);

  d_base_inner = d_base_mid - t2_rib * cos(a_tilt);
  echo(d_base_inner=d_base_inner);

  echo("end to end", l + d_base_inner);

  module spars() {
    rotate(a=180)
      curve(a_sweep=180, a_tilt=a_tilt, d=d);

    translate(v=[0, l, 0])
      curve(a_sweep=180, a_tilt=a_tilt, d=d);

    translate(v=[d / 2, l / 2, 0])
      rotate(a=a_tilt, v=[0, 1, 0])
        line(l=l, hole_dir=1);

    translate(v=[-d / 2, l / 2, 0])
      rotate(a=-a_tilt, v=[0, 1, 0])
        line(l=l, hole_dir=-1);
  }

  module joining_base() {

    color(c="orange")
      translate(v=[0, 0, dz_base_mid])
        cyl(d1=d_base_outer, d2=d_base_inner, z_base);

    color(c="orange")
      translate(v=[0, l, 0])
        translate(v=[0, 0, dz_base_mid])
          cyl(d1=d_base_outer, d2=d_base_inner, z_base);

    color(c="green")
      translate(v=[0, l / 2, dz_base_mid])
        prismoid(
          size1=[d_base_outer, l],
          size2=[d_base_inner, l],
          h=z_base,
          anchor=CENTER,
        );
  }

  module extra_base() {
    z_base_extra = t_base - z_base;
    dz_base_extra = dz_base_mid - z_base_extra / 2 - z_base / 2;
    echo(z_base_extra=z_base_extra);

    color(c="pink")
      translate(v=[0, 0, dz_base_extra])
        cyl(d=d_base_outer, z_base_extra);

    color(c="pink")
      translate(v=[0, l, 0])
        translate(v=[0, 0, dz_base_extra])
          cyl(d=d_base_outer, z_base_extra);

    color(c="blue")
      translate(v=[0, l / 2, dz_base_extra])
        cuboid([d_base_outer, l, z_base_extra]);
  }

  spars();

  joining_base();

  if (t_base > z_base)
    extra_base();
}

render() {

  if (model == "glasses")
    glasses();

  if (model == "cross_section_test")
    cross_section_test();
}
