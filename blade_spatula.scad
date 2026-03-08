include <lib/geom.scad>
include <BOSL2/std.scad>

show_blade = true;
show_holder = true;
half_holder = false;

x_blade = 38.6; // [0:0.01:100]
y_blade = 17.75; // [0:0.01:100]
z_blade = 1.3; // [0:0.01:5]

y_blade_channel = 6.25; // [0:0.01:25]
z_blade_channel = 1; // [0:0.01:5]

x_cutout_mid = 2.1; // [0:0.01:100]
y_cutout_mid = 5.4; // [0:0.01:100]

x_cutout_end = 4.5; // [0:0.01:25]
y_cutout_end = 3.1; // [0:0.01:25]

g_y_channel = 0.075; // [0:0.001:2]
g_y_edge = 0.2; // [0:0.001:2]
g_z = 0.09; // [0:0.001:2]

t_y = 1.6; // [0:0.01:5]
t_z = 1.6; // [0:0.01:5]

ratio_rounding = 1; // [0:0.01:10]

rounding = t_z * ratio_rounding;

$fn = 400;

module blade(cutouts = true, dy_channel = 0, dy_edge = 0, dz = 0) {
  difference() {
    body = [x_blade, y_blade + dy_edge * 2, z_blade + dz * 2];
    cube(body, center=true);

    channel = [x_blade, y_blade_channel - 2 * dy_channel, z_blade - z_blade_channel];

    translate(v=[0, 0, (body[2] - channel[2]) / 2])
      cube(channel, center=true);

    translate(v=[0, 0, -(body[2] - channel[2]) / 2])
      cube(channel, center=true);

    if (cutouts) {
      cutout = [x_cutout_end, y_cutout_end, z_blade];

      translate(v=[(x_blade - x_cutout_end) / 2, 0, 0])
        cube(cutout, center=true);

      translate(v=[( -x_blade + x_cutout_end) / 2, 0, 0])
        cube(cutout, center=true);

      mid = [x_cutout_mid, y_cutout_mid, z_blade];
      cube(mid, center=true);
    }
  }
}

module holder() {
  difference() {
    body = [
      x_blade,
      y_blade + t_y + g_y_edge - g_y_channel - (y_blade - y_blade_channel) / 2,
      z_blade + 2 * (g_z + t_z),
    ];

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

    blade(cutouts=false, dy_channel=g_y_channel, dy_edge=g_y_edge, dz=g_z);
  }
}

render() {
  color(c="orange") {
    if (show_blade) {
      blade();
    }
  }

  color(c="steelblue") {
    bottom_half(z=(half_holder ? 0 : 50), s=100) {
      if (show_holder) {
        holder();
      }
    }
  }
}
