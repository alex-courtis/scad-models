include <lib/geom.scad>
include <BOSL2/std.scad>

show_blade = false;
show_holder = true;
half_holder = false;

x_blade = 38.4; // [0:0.01:100]
y_blade = 17.7; // [0:0.01:100]
z_blade_thick = 1.25; // [0:0.01:5]
z_blade_thin = 0.98; // [0:0.01:5]

y_blade_channel = 6.25; // [0:0.01:25]

x_cutout_mid = 2.1; // [0:0.01:100]
y_cutout_mid = 5.4; // [0:0.01:100]

x_cutout_end = 4.5; // [0:0.01:25]
y_cutout_end = 3.1; // [0:0.01:25]

g_y_channel = 0.075; // [0:0.001:2]
g_y_edge = 0.25; // [0:0.001:2]
g_z = 0.01; // [0:0.001:2]

z_nub = 0.25; // [0:0.001:2]
ratio_rounding_nub = 2.0; // [0:0.001:2]
rounding_nub = z_nub * ratio_rounding_nub;

t_y = 1.6; // [0:0.01:5]
t_z = 0.8; // [0:0.01:5]

ratio_rounding = 1; // [0:0.01:10]

rounding = t_z * ratio_rounding;

$fn = 200;

module blade(cutouts, gaps) {
  body = [
    x_blade,
    y_blade + (gaps ? 2 * g_y_edge : 0),
    z_blade_thick + (gaps ? 2 * g_z : 0),
  ];

  channel = [
    x_blade,
    y_blade_channel - (gaps ? 2 * g_y_channel : 0),
    z_blade_thick - (gaps ? 2 * g_z : 0), // use entire thickness to avoid non-manifold
  ];

  cutout_end = [x_cutout_end, y_cutout_end, z_blade_thick];

  cutout_mid = [x_cutout_mid, y_cutout_mid, z_blade_thick];

  dx_end = (x_blade - x_cutout_end) / 2;
  dz_nub = cutout_mid[2] - z_nub;

  difference() {
    cube(body, center=true);

    translate(v=[0, 0, (z_blade_thick + z_blade_thin) / 2])
      cube(channel, center=true);

    translate(v=[0, 0, -(z_blade_thick + z_blade_thin) / 2])
      cube(channel, center=true);

    if (cutouts) {

      // end
      translate(v=[dx_end, 0, 0])
        cube(cutout_end, center=true);

      // end
      translate(v=[-dx_end, 0, 0])
        cube(cutout_end, center=true);

      // mid
      cube(cutout_mid, center=true);
    } else if (gaps) {

      // end
      translate(v=[dx_end, 0, dz_nub])
        cuboid(cutout_end, rounding=rounding_nub);
      translate(v=[dx_end, 0, -dz_nub])
        cuboid(cutout_end, rounding=rounding_nub);

      // end
      translate(v=[-dx_end, 0, dz_nub])
        cuboid(cutout_end, rounding=rounding_nub);
      translate(v=[-dx_end, 0, -dz_nub])
        cuboid(cutout_end, rounding=rounding_nub);

      // mid
      translate(v=[0, 0, dz_nub])
        cuboid(cutout_mid, rounding=rounding_nub);
      translate(v=[0, 0, -dz_nub])
        cuboid(cutout_mid, rounding=rounding_nub);
    }
  }
}

module holder() {
  difference() {
    body = [
      x_blade,
      y_blade + t_y + g_y_edge - g_y_channel - (y_blade - y_blade_channel) / 2,
      z_blade_thick + 2 * (g_z + t_z),
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

    blade(cutouts=false, gaps=true);
  }
}

render() {
  color(c="orange") {
    if (show_blade) {
      blade(cutouts=true, gaps=false);
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
