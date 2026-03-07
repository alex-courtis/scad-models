include <lib/geom.scad>
include <BOSL2/std.scad>

switch = [61.5, 30.5, 21];

d_cable = 7;

t = 2.0;
rounding = 1.6;

g_switch = 0.8;
g_cable = 0.8;
// g_cable = 0;

box = vector_add(switch, g_switch + t) + [t + g_switch, 0, 0];

$fn = 200;

render() {
  color(c="orange")
    cube(switch, center=true);

  difference() {
    color(c="green")
      translate(
        v=[
          0,
          -(switch[1] - box[1]) / 2,
          (switch[2] - box[2]) / 2,
        ]
      ) cuboid(
          box, rounding=rounding,
          edges=[TOP + BACK, TOP + LEFT, TOP + RIGHT, TOP + FRONT],
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
