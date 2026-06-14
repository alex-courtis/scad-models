include <BOSL2/std.scad>
include <lib/geom.scad>

d_filament = 0.4;
t_layer = 0.2;

model = "all"; // ["all", "front", "back", "lid", "lid+front", "lid+back", "cross_section_test"]

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

t_lid_side = 2.0; // [0:0.05:5]
t_lid = 1.6; // [0:0.05:5]

// aspirational, rounded to hole spacing
l_straight_target = 120; // [20:1:300]

// inside to inside
w_wall = 55; // [20:1:200]

t_wall = 1.8; // [0:0.05:5]

// of the end hole midpoints
d_side = 35; // [10:1:100]

d_rod = 2.2; // [0:0.05:5]
l_rod = 18; // [0:0.05:50]

d_liner_hole = 1.5; // [0:0.05:3]

d_hinge = 2.1; // [0:0.05:5]

d_side_magnet = 5; // [0:0.1:50]
d_lid_magnet = 5; // [0:0.1:50]
t_lid_magnet = 2; // [0:0.1:50]

a_lid_magnet = -6; // [-180:1:0]

gap_half = 1; // [0:0.1:5]
gap_lid_front = 3.0; // [0:0.1:5]
gap_lid_back = 4.0; // [0:0.1:5]

// inner side to outer lid
gap_w_lid = 1.2; // [0:0.1:15]

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

l_straight = round_num(l_straight_target, spacing_hole);
echo(l_straight=l_straight);

echo();
echo("SIDE PIECE, covers ribs");
echo(width=d_rib_inner + 2 * rib_inner + 2 * rib_outer);
echo(length=l_straight + d_rib_inner + 2 * rib_inner + 2 * rib_outer);

echo();
echo("WALL PIECE, covers ribs, flat + quarter round");
echo(width=w_wall + 2 * t_side - 2 * z_t2 + 2 * rib_inner + 2 * rib_outer);
echo(length=l_straight + PI * d_rib_outer / 4);

echo();
echo("# half circle holes at", spacing_hole_curve, "=", 180 / a_curve_hole + 1);
echo("# straight holes at", spacing_hole, "=", l_straight / spacing_hole + 1);
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

module top_holes_mask(t) {
  dz = w_wall / round(w_wall / spacing_hole);

  for (z = [dz / 2:dz:w_wall - dz / 2]) {
    translate(v=[0, 0, -z])
      cuboid([t, w_hole, l_hole]);
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

    translate(v=[0, l_straight, 0])
      rib_curve(a_sweep=180, rib_tilt=rib_tilt, d=d_side);
  }

  module lines() {
    translate(v=[d_side / 2, l_straight / 2, 0])
      rotate(a=rib_tilt, v=[0, 1, 0])
        rib_straight(l=l_straight, hole_dir=1);

    translate(v=[-d_side / 2, l_straight / 2, 0])
      rotate(a=-rib_tilt, v=[0, 1, 0])
        rib_straight(l=l_straight, hole_dir=-1);
  }

  module body() {
    translate(v=[0, 0, (t_side_min - z_t2) / 2])
      cyl(d=d_rib_outer, h=z_t2);

    translate(v=[0, l_straight, 0])
      cyl(d=d_rib_outer, t_side_min);

    translate(v=[0, l_straight / 2, 0])
      cuboid(
        [d_rib_outer, l_straight, t_side_min],
        chamfer=(t_side_min - z_t2),
        edges=[
          FRONT + BOTTOM,
          FRONT + LEFT,
        ],
      );
  }

  module rods_mask() {
    if (d_rod > 0 && l_rod > 0) {

      translate(v=[0, 0, t_side / 2]) {
        for (
          y = [
            -l_straight / 2 + d_rod * 2,
            0,
            l_straight / 2 - d_rod * 2,
          ]
        ) {
          translate(v=[0, y, 0])
            rotate(a=90, v=[0, 1, 0])
              cylinder(d=d_rod, h=l_rod, center=true);
        }
      }
    }
  }

  module hinge_socket_mask() {
    if (d_hinge) {
      translate(v=[-dir * (d_rib_outer - d_hinge) / 2, -l_straight / 2 + d_hinge / 2, t_side / 2 - 0.2])
        cyl(d=d_hinge, h=t_side, center=true);
    }
  }

  module magnet_mask() {
    translate(v=[dir * (d_rib_inner / 2 - d_side_magnet / 2), -l_straight / 2, t_side / 2])
      cyl(d=d_side_magnet, h=t_side * 2, center=true);
  }

  difference() {
    translate(v=[0, -l_straight / 2, 0]) {
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

    module flat(gap) {
      translate(v=[0, gap / 2, 0]) {
        cuboid(
          [t_wall, l_straight - gap, w_wall],
          rounding=t_wall / 2,
          edges=[
            FRONT + LEFT,
            FRONT + RIGHT,
          ],
        );
      }
    }

    translate(v=[0, 0, -w_wall / 2]) {
      color(c="tan")
        translate(v=[0, l_straight / 2, 0])
          back_half()
            tube(od=d_rib_outer, id=d_rib_outer - t_wall * 2, h=w_wall);

      color(c="beige") {
        translate(v=[dx_flat, 0, 0])
          flat(gap=gap_lid_back);

        translate(v=[-dx_flat, 0, 0])
          flat(gap=gap_lid_front);
      }
    }
  }

  module liner_holes_mask() {
    module straights_l(gap) {
      for (y = [l_straight / 2:-spacing_hole:-l_straight / 2 + gap + spacing_hole]) {
        translate(v=[0, y, 0])
          rotate(a=90, v=[0, 1, 0])
            cylinder(h=t_wall * 2, d=d_liner_hole, center=true);
      }
    }

    module curveds_l() {
      for (a = [0:a_curve_hole:180]) {
        rotate(a=-a)
          translate(v=[-(d_rib_outer - t_wall) / 2, 0, 0])
            rotate(a=90, v=[0, 1, 0])
              cylinder(h=t_wall * 2, d=d_liner_hole, center=true);
      }
    }

    module straights_w() {
      dz = (w_wall - d_liner_hole) / round((w_wall - d_liner_hole) / spacing_hole);
      for (z = [0:dz:w_wall])
        translate(v=[0, 0, -z])
          rotate(a=90, v=[0, 1, 0])
            cylinder(h=t_wall * 2, d=d_liner_hole, center=true);
    }

    if (d_liner_hole > 0) {

      dx_straights_l = (d_rib_outer - t_wall) / 2;
      dz_bottom = -w_wall + d_liner_hole;

      translate(v=[0, 0, -d_liner_hole / 2]) {

        translate(v=[0, l_straight / 2, 0]) {
          translate(v=[-dx_straights_l, 0, 0])
            straights_w();
          translate(v=[dx_straights_l, 0, 0])
            straights_w();
        }

        translate(v=[0, l_straight / 2, 0]) {
          rotate(a=90 - a_curve_hole)
            translate(v=[dx_straights_l, 0, 0])
              straights_w();

          rotate(a=90 + a_curve_hole)
            translate(v=[dx_straights_l, 0, 0])
              straights_w();
        }

        translate(v=[-dx_straights_l, 0, 0]) {
          straights_l(gap=gap_lid_back);
          translate(v=[0, 0, dz_bottom])
            straights_l(gap=gap_lid_back);
        }

        translate(v=[dx_straights_l, 0, 0]) {
          straights_l(gap=gap_lid_front);
          translate(v=[0, 0, dz_bottom])
            straights_l(gap=gap_lid_front);
        }

        translate(v=[0, l_straight / 2, 0]) {
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

    translate(v=[(d_rib_outer - t_wall) / 2, -l_straight / 2 + gap_lid_front + rib_outer, 0])
      top_holes_mask(t=t_wall * 2);

    translate(v=[-(d_rib_outer - t_wall) / 2, -l_straight / 2 + gap_lid_back + rib_outer, 0])
      top_holes_mask(t=t_wall * 2);
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
  w_lid_inner = w_wall - 2 * gap_w_lid - 2 * t_lid_side;

  module body() {
    front_half() {
      color(c="chocolate") {
        // overlap to ensure manifold
        z = w_lid_inner / 2 + t_lid_side;
        translate(v=[0, 0, -z / 2 + t_lid_side])
          tube(od=d_rib_outer, id=d_rib_outer - t_lid * 2, h=z);
      }

      color(c="maroon") {
        translate(v=[0, 0, t_lid_side / 2])
          cyl(d=d_rib_outer, h=t_lid_side);
      }
    }
  }

  module magnet_mask(a) {
    z = t_lid_magnet;
    dz = -z / 2 + t_lid_side;
    rotate(a=a)
      translate(v=[d_rib_inner / 2 - d_lid_magnet / 2, 0, dz])
        cyl(d=d_lid_magnet, h=z, center=true);
  }

  module front_holes_mask() {
    dz = w_lid_inner / round(w_lid_inner / spacing_hole);
    echo(front_holes_mask_dz=dz);
    translate(v=[0, -rib_outer, 0]) {
      for (z = [dz / 2:dz:w_lid_inner]) {
        for (x = [-1, 1]) {
          translate(v=[x * (d_rib_outer - t_lid) / 2, 0, -z])
            cuboid([t_lid * 2, w_hole, l_hole]);
        }
      }
    }
  }

  module curve() {
    dz = rib_inner * cos(rib_tilt) - z_t2 / 2 + t_lid_side;
    color(c="pink") {
      translate(v=[0, 0, dz])
        rotate(a=180)
          rib_curve(a_sweep=180, rib_tilt=rib_tilt, d=d_side);
    }
  }

  module half(dir) {
    translate(v=[0, 0, -gap_w_lid - t_lid_side]) {
      curve();
      difference() {
        body();
        magnet_mask(a=(dir == 1 ? a_lid_magnet : 180 - a_lid_magnet));
      }
    }
  }

  translate(v=[0, -l_straight / 2, 0]) {
    difference() {
      union() {
        half(dir=1);
        translate(v=[0, 0, -w_wall])
          rotate(a=180, v=[0, 1, 0])
            half(dir=-1);
      }
      for (a = [-a_curve_hole / 2, 180 + a_curve_hole / 2])
        rotate(a=a)
          translate(v=[d_rib_outer / 2 - t_lid / 2, 0, 0])
            top_holes_mask(t=t_lid * 2);
    }
  }
}

render() {

  if (model == "all") {
    lid();
    difference() {
      full();
      cube([gap_half, 1000, 1000], center=true);
    }
  }

  if (search("front", model))
    right_half(s=1000, x=gap_half / 2)
      full();

  if (search("back", model))
    left_half(s=1000, x=-gap_half / 2)
      full();

  if (search("lid", model))
    lid();

  if (model == "cross_section_test")
    cross_section_test();
}
