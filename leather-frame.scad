include <BOSL2/std.scad>
include <lib/geom.scad>

d_filament = 0.4;
t_layer = 0.2;

model = "glasses"; // ["glasses", "cross_section_test"]

part = "all"; // ["all", "side", "wall_left", "wall_right"]

debug_holes = false;
circular_holes = false;

spacing_hole = 5;
a_hole = 45;

w_inner = 2.5;
w_outer = 2.5;

t1_rib = t_layer * 2;
t2_rib = 2.0;

l1_awl = 3.25;
l_hole = l1_awl;
w_hole = 1.2;

l_glasses = 160; // aspirational, rounded to hole spacing
d_glasses = 40; // of the holes
w_glasses = 54; // wall piece

t_side_glasses = 3.0;
t_wall_glasses = 2.4;
a_tilt_glasses = 45;

gap_side_wall = 0.2;

d_pin = 2;
d_liner_hole = 1.2;

d_magnet = 19.4;
t_magnet = 2 + t_layer;

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
  d_mid = d_glasses - 2 * w_inner * sin(a_tilt_glasses);
  d_outer = d_mid + t2_rib * cos(a_tilt_glasses);
  echo(d_outer=d_outer);

  d_inner = d_mid - t2_rib * cos(a_tilt_glasses);
  echo(d_inner=d_inner);

  l_wall = round_num(l_glasses - d_inner, spacing_hole);
  echo(l_wall=l_wall);

  z_t2_mid = -w_inner * cos(a_tilt_glasses);
  z_t2_upper = z_t2_mid + t2_rib / 2 * sin(a_tilt_glasses);
  z_t2_lower = z_t2_mid - t2_rib / 2 * sin(a_tilt_glasses);

  t_side_glasses_joining = z_t2_upper - z_t2_lower;
  echo(t_side_glasses_joining=t_side_glasses_joining);

  wall_outer = d_outer;
  wall_inner = d_outer - t_wall_glasses * 2;

  echo("top to bottom", wall_inner);

  module side_spars() {
    rotate(a=180)
      curve(a_sweep=180, a_tilt=a_tilt_glasses, d=d_glasses);

    translate(v=[0, l_wall, 0])
      curve(a_sweep=180, a_tilt=a_tilt_glasses, d=d_glasses);

    translate(v=[d_glasses / 2, l_wall / 2, 0])
      rotate(a=a_tilt_glasses, v=[0, 1, 0])
        line(l=l_wall, hole_dir=1);

    translate(v=[-d_glasses / 2, l_wall / 2, 0])
      rotate(a=-a_tilt_glasses, v=[0, 1, 0])
        line(l=l_wall, hole_dir=-1);
  }

  module side_join() {

    translate(v=[0, 0, z_t2_lower + t_side_glasses_joining / 2]) {

      color(c="orange")
        cyl(d1=d_outer, d2=d_inner, t_side_glasses_joining);

      color(c="orange")
        translate(v=[0, l_wall, 0])
          cyl(d1=d_outer, d2=d_inner, t_side_glasses_joining);

      color(c="green")
        translate(v=[0, l_wall / 2, 0])
          prismoid(
            size1=[d_outer, l_wall],
            size2=[d_inner, l_wall],
            h=t_side_glasses_joining,
            anchor=CENTER,
          );
    }
  }

  module side_flange() {

    translate(v=[0, 0, -t_side_glasses / 2 + z_t2_upper]) {
      cyl(h=t_side_glasses, d=wall_inner);

      translate(v=[0, l_wall, 0])
        cyl(h=t_side_glasses, d=wall_inner);

      translate(v=[0, l_wall / 2, 0])
        cuboid([wall_inner, l_wall, t_side_glasses]);
    }
  }

  module wall() {

    module pin() {
      rotate(a=90, v=[0, 1, 0])
        cyl(d=d_pin, h=wall_outer);
    }

    translate(v=[0, 0, -w_glasses / 2 + z_t2_lower]) {

      difference() {
        union() {
          front_half()
            tube(
              h=w_glasses,
              od=wall_outer + gap_side_wall * 2,
              id=wall_inner + gap_side_wall * 2,
            );

          translate(v=[(wall_outer - t_wall_glasses) / 2 + gap_side_wall, l_wall / 2, 0])
            cuboid([t_wall_glasses, l_wall, w_glasses]);

          translate(v=[-(wall_outer - t_wall_glasses) / 2 - gap_side_wall, l_wall / 2, 0])
            cuboid([t_wall_glasses, l_wall, w_glasses]);
        }

        translate(v=[0, -wall_outer / 2 + t_wall_glasses, -w_glasses / 3])
          pin();

        translate(v=[0, -wall_outer / 2 + t_wall_glasses, w_glasses / 3])
          pin();

        translate(v=[wall_inner / 2 + t_magnet / 2 + gap_side_wall, l_wall - d_magnet, 0])
          rotate(a=90, v=[0, 1, 0])
            cyl(h=t_magnet, d=d_magnet);

        z_hole_bottom = -w_glasses / 2 + spacing_hole;
        z_hole_top = w_glasses / 2 - spacing_hole;
        z_hole_total = (abs(z_hole_top) + abs(z_hole_bottom));
        z_spacing = z_hole_total / round(z_hole_total / spacing_hole);

        for (y = [spacing_hole,l_wall - spacing_hole])
          for (z = [z_hole_bottom:z_spacing:z_hole_top])
            translate(v=[0, y, z])
              rotate(a=90, v=[0, 1, 0])
                cyl(h=wall_outer * 2, d=d_liner_hole);

        for (z = [z_hole_bottom, z_hole_top])
          for (y = [spacing_hole:spacing_hole:l_wall - spacing_hole])
            translate(v=[0, y, z])
              rotate(a=90, v=[0, 1, 0])
                cyl(h=wall_outer * 2, d=d_liner_hole);
      }
    }
  }

  if (part == "side" || part == "all") {
    side_spars();

    side_join();

    side_flange();
  }

  if (part == "wall_left" || part == "all") {
    left_half(s=l_wall * 4)
      wall();
  }
  if (part == "wall_right" || part == "all") {
    right_half(s=l_wall * 4)
      wall();
  }
}

render() {

  if (model == "glasses")
    glasses();

  if (model == "cross_section_test")
    cross_section_test();
}
