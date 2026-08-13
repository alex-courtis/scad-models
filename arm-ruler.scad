include <BOSL2/std.scad>
include <lib/geom.scad>

$fn = 120;

body = [200, 25, 1.2];
d_hole = 2.5;

module holes() {
  for (dx = [10:20:body.x - 10])
    translate(v=[dx, 0, 0])
      cylinder(d=d_hole, h=body.z, center=true);

  for (dx = [20:20:body.x - 20])
    translate(v=[dx, 0, 0])
      cube([d_hole, 10, body.z], center=true);

  for (dx = [0:100:body.x])
    translate(v=[dx, 0, 0])
      cube([d_hole, 20, body.z], center=true);
}

render() {
  difference() {
    translate(v=[body.x / 2, 0, 0])
      cube(body + [5, 0, 0], center=true);
    holes();
  }
}
