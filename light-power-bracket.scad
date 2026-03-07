include <lib/geom.scad>
include <BOSL2/std.scad>

switch = [
  61.5,
  30.5,
  21 - 1, // protrudes a bit
];
g_switch = 0.4;

d_cable = 7;
g_cable = 0.8;

t_base = 2.0;
t_side = 4;
rounding = t_side;

t_rib = 2.3;
z_rib = 6.1 + 2;
dx_rib = 12.4 - t_rib;
g_rib = 0.4;

box = switch + [
  2 * (g_switch + t_side),
  2 * (g_switch + t_side),
  g_switch,
];

$fn = 200;

module base() {
  x = (t_rib + g_rib);

  base = [box[0], box[1], z_rib + t_base];
  rib = [x, base[1] + 1, z_rib];
  diamond = [x * sin(45), base[1] + 1, x * sin(45)];

  translate(
    v=[
      0,
      0,
      -(base[2] + box[2] + g_switch) / 2,
    ]
  ) {
    difference() {
      cuboid(base, rounding=rounding, except=[TOP, BOTTOM]);

      for (i = [-4:1:4]) {
        translate(v=[dx_rib * i, 0, 0]) {

          translate(v=[0, 0, -t_base / 2 - x / 2])
            cube(rib, center=true);

          translate(v=[0, 0, base[2] / 2 - x / 2 - t_base])
            rotate(a=45, v=[0, 1, 0])
              cube(diamond, center=true);
        }
      }
    }
  }
}

module body() {
  difference() {
    translate(
      v=[
        0,
        0,
        (switch[2] - box[2]) / 2,
      ]
    ) cuboid(
        box,
        rounding=rounding,
        except=[BOTTOM],
      );

    cube(vector_add(switch, 2 * g_switch), center=true);

    translate(
      v=[
        0,
        0,
        (switch[2] - d_cable) / 2 - g_cable,
      ]
    )
      cube(
        [
          box[0] * 2,
          d_cable + g_cable * 2,
          switch[2],
        ], center=true
      );
  }
}

render() {
  color(c="orange")
    cube(switch, center=true);

  color(c="green")
    body();

  color(c="steelblue")
    base();
}
