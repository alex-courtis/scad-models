include <BOSL2/std.scad>
include <lib/geom.scad>

d_filament = 0.4;
t_layer = 0.2;

model = "all"; // ["all", "glasses", "lid", "cross_section_test"]

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
l_straight = 120; // [20:1:300]

// inside to inside
w_wall = 45; // [20:1:200]

t_wall = 1.6; // [0:0.05:5]

// of the end hole midpoints
d_side = 35; // [10:1:100]

d_rod = 2.15; // [0:0.05:5]
l_rod = 29; // [0:0.05:50]

d_liner_hole = 1.5; // [0:0.05:3]
spacing_liner_hole = 6; // [0:0.05:3]

d_hinge = 2.1; // [0:0.05:5]

d_magnet = 10; // [0:0.1:50]

a_lid_magnet = -20; // [-180:1:0]

gap_half = 1; // [0:0.1:5]
gap_top = 2.0; // [0:0.1:5]
gap_w_lid = 3; // [0:0.1:15]

z_t2 = t2_rib * sin(rib_tilt);
echo(z_t2=z_t2);
t_side_min = max(t_side, z_t2);
echo(t_side_min=t_side_min);

// round number of holes to a clean divisor of 90
a_curve_hole = 90 / round(90 / asin(spacing_hole / d_side) / 2);
echo(a_curve_hole=a_curve_hole);
spacing_hole_curve = chord_len(d_side / 2, a_curve_hole);
echo(spacing_hole_curve=spacing_hole_curve);

a_curve_liner_hole = 90 / round(90 / asin(spacing_liner_hole / d_side) / 2);
echo(a_curve_liner_hole=a_curve_liner_hole);
spacing_liner_hole_curve = chord_len(d_side / 2, a_curve_liner_hole);
echo(spacing_liner_hole_curve=spacing_liner_hole_curve);

d_rib_outer = d_side - 2 * rib_inner * sin(rib_tilt) + t2_rib * cos(rib_tilt);
echo(d_rib_outer=d_rib_outer);

d_rib_inner = d_rib_outer - 2 * t2_rib * cos(rib_tilt);
echo(d_rib_inner=d_rib_inner);

l_straight_adj = round_num(l_straight, spacing_hole);
echo(l_straight_adj=l_straight_adj);

echo();
echo("SIDE PIECE, covers ribs");
echo(width=d_rib_inner + 2 * rib_inner + 2 * rib_outer);
echo(length=l_straight_adj + d_rib_inner + 2 * rib_inner + 2 * rib_outer);

echo();
echo("WALL PIECE, covers ribs, flat + quarter round");
echo(width=w_wall + 2 * t_side - 2 * z_t2 + 2 * rib_inner + 2 * rib_outer);
echo(length=l_straight_adj + PI * d_rib_outer / 4);

echo();
echo("# half circle holes at", spacing_hole_curve, "=", 180 / a_curve_hole + 1);
echo("# straight holes at", spacing_hole, "=", l_straight_adj / spacing_hole + 1);
echo("    ^ above intersect");

$fn = 50;

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
module side(dir) {

  // to put bottom of side at z 0
  dz = rib_inner * cos(rib_tilt) - z_t2 / 2 + t_side_min;

  module curves() {
    rotate(a=180)
      rib_curve(a_sweep=180, rib_tilt=rib_tilt, d=d_side);

    translate(v=[0, l_straight_adj, 0])
      rib_curve(a_sweep=180, rib_tilt=rib_tilt, d=d_side);
  }

  module lines() {
    translate(v=[d_side / 2, l_straight_adj / 2, 0])
      rotate(a=rib_tilt, v=[0, 1, 0])
        rib_straight(l=l_straight_adj, hole_dir=1);

    translate(v=[-d_side / 2, l_straight_adj / 2, 0])
      rotate(a=-rib_tilt, v=[0, 1, 0])
        rib_straight(l=l_straight_adj, hole_dir=-1);
  }

  module body() {
    cyl(d=d_rib_outer, h=t_side_min, rounding1=t_side_min / 2);

    translate(v=[0, l_straight_adj, 0])
      cyl(d=d_rib_outer, t_side_min);

    translate(v=[0, l_straight_adj / 2, 0])
      cuboid([d_rib_outer, l_straight_adj, t_side_min]);
  }

  module rods_mask() {
    if (d_rod > 0 && l_rod > 0) {

      translate(v=[0, 0, t_side / 2]) {

        y_rod_start = -l_straight_adj / 2 + d_rod * 3;
        y_rod_end = l_straight_adj / 2 + d_rib_inner / 2;
        y_rod_gap = (y_rod_end - y_rod_start) / 3 - d_rod * 1;

        for (y = [y_rod_start:y_rod_gap:y_rod_end]) {
          translate(v=[0, y, 0])
            rotate(a=90, v=[0, 1, 0])
              cylinder(d=d_rod, h=l_rod / 2, center=true);
        }
      }
    }
  }

  module hinge_socket_mask() {
    if(d_hinge) {
      translate(v=[-dir * (d_rib_outer - d_hinge) / 2, -l_straight_adj / 2, t_side / 2 - 0.2])
        cyl(d=d_hinge, h=t_side, center=true);
    }
  }

  module magnet_mask() {
    translate(v=[dir * (d_rib_inner / 2 - d_magnet / 2), -l_straight_adj / 2, t_side / 2])
      cyl(d=d_magnet, h=t_side * 2, center=true);
  }

  difference() {
    translate(v=[0, -l_straight_adj / 2, 0]) {
      color(c="brown")
        translate(v=[0, 0, dz])
          curves();

      color(c="tan")
        translate(v=[0, 0, dz])
          lines();

      color(c="blue")
        translate(v=[0, 0, t_side_min / 2])
          body();
    }

    rods_mask();

    hinge_socket_mask();

    magnet_mask();
  }
}

module wall() {

  module body() {
    dx_flat = (t_wall - d_rib_outer) / 2;
    dy_flat = gap_top / 2;

    module flat() {
      cuboid(
        [t_wall, l_straight_adj - gap_top, w_wall],
        rounding=t_wall / 2,
        edges=[
          FRONT + LEFT,
          FRONT + RIGHT,
        ],
      );
    }

    translate(v=[0, 0, -w_wall / 2]) {
      color(c="tan")
        translate(v=[0, l_straight_adj / 2, 0])
          back_half()
            tube(od=d_rib_outer, id=d_rib_outer - t_wall * 2, h=w_wall);

      color(c="beige") {
        translate(v=[0, dy_flat, 0]) {
          translate(v=[dx_flat, 0, 0])
            flat();

          translate(v=[-dx_flat, 0, 0])
            flat();
        }
      }
    }
  }

  module liner_holes_mask() {
    module straights_l() {
      for (y = [-l_straight_adj / 2 + spacing_liner_hole:spacing_liner_hole:l_straight_adj / 2 - spacing_liner_hole]) {
        translate(v=[0, y, 0])
          rotate(a=90, v=[0, 1, 0])
            cylinder(h=t_wall * 2, d=d_liner_hole, center=true);
      }
    }

    module curveds_l() {
      for (a = [0:a_curve_liner_hole:180]) {
        rotate(a=-a)
          translate(v=[-(d_rib_outer - t_wall) / 2, 0, 0])
            rotate(a=90, v=[0, 1, 0])
              cylinder(h=t_wall * 2, d=d_liner_hole, center=true);
      }
    }

    module straights_w() {
      dz = (w_wall - d_liner_hole) / spacing_liner_hole;
      for (z = [0:dz:w_wall - dz])
        translate(v=[0, 0, -z])
          rotate(a=90, v=[0, 1, 0])
            cylinder(h=t_wall * 2, d=d_liner_hole, center=true);
    }

    if (d_liner_hole > 0) {

      dx_straights_l = (d_rib_outer - t_wall) / 2;
      dz_bottom = -w_wall + d_liner_hole;

      translate(v=[0, 0, -d_liner_hole / 2]) {

        translate(v=[0, l_straight_adj / 2, 0]) {
          translate(v=[-dx_straights_l, 0, 0])
            straights_w();
          translate(v=[dx_straights_l, 0, 0])
            straights_w();
        }

        translate(v=[0, -l_straight_adj / 2 + spacing_liner_hole, 0]) {
          translate(v=[-dx_straights_l, 0, 0])
            straights_w();
          translate(v=[dx_straights_l, 0, 0])
            straights_w();
        }

        translate(v=[0, l_straight_adj / 2, 0]) {
          rotate(a=90 - a_curve_liner_hole)
            translate(v=[dx_straights_l, 0, 0])
              straights_w();

          rotate(a=90 + a_curve_liner_hole)
            translate(v=[dx_straights_l, 0, 0])
              straights_w();
        }

        translate(v=[-dx_straights_l, 0, 0]) {
          straights_l();
          translate(v=[0, 0, dz_bottom])
            straights_l();
        }

        translate(v=[dx_straights_l, 0, 0]) {
          straights_l();
          translate(v=[0, 0, dz_bottom])
            straights_l();
        }

        translate(v=[0, l_straight_adj / 2, 0]) {
          curveds_l();
          translate(v=[0, 0, dz_bottom])
            curveds_l();
        }
      }
    }
  }

  difference() {
    body();
    liner_holes_mask();
  }
}

module full() {
  side(dir=1);

  wall();

  translate(v=[0, 0, -w_wall])
    rotate(a=180, v=[0, 1, 0])
      side(dir=-1);
}

module lid() {
  module body() {
    front_half() {
      color(c="chocolate") {
        translate(v=[0, 0, -w_wall / 4])
          tube(od=d_rib_outer, id=d_rib_outer - t_wall * 2, h=w_wall / 2);
      }
      color(c="maroon") {
        // translate(v=[0, 0, -w_wall - t_side / 2])
        //   cyl(d=d_rib_outer, h=t_side);
        translate(v=[0, 0, t_side / 2])
          cyl(d=d_rib_outer, h=t_side);
      }
    }
  }

  module magnet_mask() {
    z = w_wall * 2;
    rotate(a=a_lid_magnet)
      translate(v=[d_rib_inner / 2 - d_magnet / 2, 0, -w_wall / 2])
        cyl(d=d_magnet, h=z, center=true);
  }

  module hinge_socket_mask() {
    if (d_hinge) {
      translate(v=[-(d_rib_outer - d_hinge) / 2, 0, 0])

        cyl(d=d_hinge, h=t_side * 100, center=true);
    }
  }

  module curve() {
    rotate(a=180)
      rib_curve(a_sweep=180, rib_tilt=rib_tilt, d=d_side);
  }

  module curves() {
    // to put bottom of inner at z 0
    dz = rib_inner * cos(rib_tilt) - z_t2 / 2 + t_side_min;

    translate(v=[0, 0, dz])
      curve();
  }

  module half() {
    translate(v=[0, 0, -gap_w_lid - t_side]) {
      body();
      curves();
    }
  }

  translate(v=[0, -l_straight_adj / 2, 0]) {
    difference() {
      union() {
        half();
        translate(v=[0, 0, -w_wall])
          rotate(a=180, v=[0, 1, 0])
            half();
      }
      magnet_mask();
      hinge_socket_mask();
    }
  }
}

render() {

  if (model == "glasses" || model == "all") {
    left_half(s=1000, x=-gap_half / 2) {
      full();
    }
    right_half(s=1000, x=gap_half / 2) {
      full();
    }
  }

  if (model == "lid" || model == "all") {
    lid();
  }

  if (model == "cross_section_test")
    cross_section_test();
}
