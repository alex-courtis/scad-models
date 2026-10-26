include <BOSL2/std.scad>
include <lib/geom.scad>

$fn = 120;

l_short = 10;
l_long = 20;

d_hole = 2.1;
w_long = 1.6;
w_short = 1.6;

margin = 2;

body = [200 + (w_long / 2 + margin) * 2, l_long + margin * 2, 1];

module holes() {
  for (i = [-1, 1]) {
    for (dx = [0:10:body.x / 2]) {
      if (dx % 50 != 0) {
        translate(v=[i * dx, 0, 0])
          cylinder(d=d_hole, h=body.z, center=true);
      }
    }

    for (dx = [0:50:body.x / 2]) {
      if (dx % 100 != 0) {
        translate(v=[i * dx, 0, 0])
          cube([w_short, l_short, body.z], center=true);
      }
    }

    for (dx = [0:100:body.x / 2]) {
      translate(v=[i * dx, 0, 0])
        cube([w_long, l_long, body.z], center=true);
    }
  }
}

render() {
  difference() {
    cube(body, center=true);
    holes();
  }
}
