include <lib/geom.scad>
include <BOSL2/std.scad>

show_blade = false;
flat_blade = false;
show_holder = true;
half_holder = false;

x_blade = 38.4; // [0:0.01:100]
y_blade = 17.7; // [0:0.01:100]
z_blade_thick = 1.25; // [0:0.01:5]
z_blade_thin = 0.98; // [0:0.01:5]

x_handle = 20; // [0:0.01:200]
y_handle = 120; // [0:0.01:200]

y_blade_channel = 6.25; // [0:0.01:25]

x_cutout_mid = 2.1; // [0:0.01:100]
y_cutout_mid = 5.4; // [0:0.01:100]
dy_cutout_mid = 0; // [-10:0.001:10]

x_cutout_end = 4.5; // [0:0.01:25]
y_cutout_end = 3.1; // [0:0.01:25]

g_y_channel = 0.075; // [0:0.001:2]
g_y_edge = 0.25; // [0:0.001:2]
g_z_thin = 0.01; // [0:0.001:2]
g_z_thick = 0.05; // [0:0.001:2]
g_cutout = 0.1; // [0:0.001:2]

t_nub = 0.40; // [0:0.001:2]

t_y = 1.6; // [0:0.01:5]
t_z = 1.2; // [0:0.01:5]

ratio_rounding = 1; // [0:0.01:1]

$fn = 200;

module blade(cutouts, mask) {
  body = [
    x_blade,
    y_blade + (mask ? 2 * g_y_edge : 0),
    z_blade_thick + (mask ? 2 * g_z_thick : 0),
  ];

  channel = [
    x_blade,
    y_blade_channel - (mask ? 2 * g_y_channel : 0),
    z_blade_thick - (mask ? 2 * g_z_thin : 0), // use entire thickness to avoid non-manifold
  ];

  nub_mask = [
    x_blade,
    y_blade,
    z_blade_thin + g_z_thin * 2 - t_nub * 2,
  ];

  module cutout_end_mask(dir) {
    rect = [
      x_cutout_end - y_cutout_end,
      y_cutout_end - (mask ? 2 * g_cutout : 0),
      z_blade_thick,
    ];

    translate(v=[(x_blade - rect[0]) / 2 * dir, 0, 0])
      cube(rect, center=true);

    translate(v=[(x_blade / 2 - rect[0]) * dir, 0, 0])
      cylinder(d=rect[1], h=rect[2], center=true);
  }

  module cutout_mid_mask() {
    rect = [
      x_cutout_mid - (mask ? 2 * g_cutout : 0),
      y_cutout_mid - x_cutout_mid,
      z_blade_thick,
    ];

    translate(v=[0, dy_cutout_mid, 0]) {
      cube(rect, center=true);

      translate(v=[0, rect[1] / 2, 0])
        cylinder(d=rect[0], h=rect[2], center=true);

      translate(v=[0, -rect[1] / 2, 0])
        cylinder(d=rect[0], h=rect[2], center=true);
    }
  }

  difference() {
    cube(body, center=true);

    translate(v=[0, 0, (z_blade_thick + z_blade_thin) / 2])
      cube(channel, center=true);

    translate(v=[0, 0, -(z_blade_thick + z_blade_thin) / 2])
      cube(channel, center=true);

    difference() {
      union() {
        cutout_end_mask(dir=1);
        cutout_end_mask(dir=-1);
        cutout_mid_mask();
      }

      // cut off nubs
      if (mask)
        cube(nub_mask, center=true);
    }
  }
}

module holder() {
  body = [
    x_blade,
    y_blade + t_y + g_y_edge - g_y_channel - (y_blade - y_blade_channel) / 2,
    z_blade_thick + 2 * (g_z_thick + t_z),
  ];

  handle = [x_handle, y_handle, body[2]];

  rounding = ratio_rounding * body[2] / 2;

  difference() {
    union() {

      color(c="green")
        translate(v=[0, y_handle / 2, 0])
          cuboid(handle, rounding=rounding);

      color(c="slateblue")
        translate(v=[0, body[1] / 2 - y_blade_channel / 2 + g_y_channel, 0])
          cuboid(
            body,
            rounding=rounding,
            edges=[
              FRONT + TOP,
              FRONT + BOTTOM,
              BACK + TOP,
              BACK + BOTTOM,
            ]
          );
    }

    blade(cutouts=false, mask=true);
  }
}

render() {
  color(c="orange") {
    if (show_blade) {
      if (flat_blade) {
        top_half() {
          translate(v=[0, 0, z_blade_thin / 2])
            blade(cutouts=true, mask=false);
        }
      } else {
        blade(cutouts=true, mask=false);
      }
    }
  }

  bottom_half(z=(half_holder ? 0 : z_blade_thick * 3), s=y_handle * 3) {
    if (show_holder) {
      holder();
    }
  }
}
