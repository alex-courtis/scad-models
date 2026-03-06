include <BOSL2/std.scad>

l_switch = 61.5;
w_switch = 30.5;
d_switch = 22 - 1;

// l only
g_l_switch = 1;

t = 2.0;
rounding = t * 2;

l = 82 + 2 + 2 * t;
w = w_switch + t;
d = d_switch + t;

d_cable = d_switch * 1 / 4;
w_cable = w_switch * 11 / 16;

$fn = 200;

module cable_void(left) {
  x = (l - l_switch) / 2 - t;
  dx = (l - x) / 2 - t * 2;

  y = d;
  dy = t * 2.5;

  z = w_cable;
  dz = (z - w_switch) / 2;

  translate(v=[left ? dx : -dx, dy, dz])
    cube([x, y, z], center=true);
}

render() {

  // color(c="orange")
  //   cube([l_switch, d_switch, w_switch], center=true);

  color(c="green") {
    difference() {
      translate(v=[0, t / 2, t / 2])
        cuboid([l, d, w], rounding=rounding, except=[TOP]);

      cube([l_switch + 2 * g_l_switch, d_switch, w_switch], center=true);

      cable_void(left=true);
      cable_void(left=false);
    }
  }
}
