include <lib/geom.scad>
include <BOSL2/std.scad>

x_blade = 38.6;
y_blade = 17.75;
z_blade = 1.3;

y_blade_channel = 6.3;
z_blade_channel = 0.96;

x_blade_end = 4.5;
y_blade_end = 3.1;

x_blade_mid = 2.1;
y_blade_mid = 5.4;

g_y = 0.1;
g_z = 0.1;

t_y = 1.6;
t_z = 1.6;

rounding = t_z;

$fn = 400;

module blade(cutouts = true, dy = 0, dz = 0) {
  difference() {
    body = [x_blade, y_blade + dy * 2, z_blade + dz * 2];
    cube(body, center=true);

    channel = [x_blade, y_blade_channel - 2 * dy, z_blade - z_blade_channel];

    translate(v=[0, 0, (body[2] - channel[2]) / 2])
      cube(channel, center=true);

    translate(v=[0, 0, -(body[2] - channel[2]) / 2])
      cube(channel, center=true);

    if (cutouts) {
      cutout = [x_blade_end, y_blade_end, z_blade];

      translate(v=[(x_blade - x_blade_end) / 2, 0, 0])
        cube(cutout, center=true);

      translate(v=[( -x_blade + x_blade_end) / 2, 0, 0])
        cube(cutout, center=true);

      mid = [x_blade_mid, y_blade_mid, z_blade];
      cube(mid, center=true);
    }
  }
}

render() {
  color(c="orange") {
    blade();
  }

  color(c="steelblue") {
    difference() {
      body = [
        x_blade,
        y_blade + t_y - (y_blade - y_blade_channel) / 2,
        z_blade + 2 * (g_z + t_z),
      ];

      translate(v=[0, body[1] / 2 - y_blade_channel / 2 + g_y, 0])
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

      blade(cutouts=false, dy=g_y, dz=g_z);
    }
  }
}
