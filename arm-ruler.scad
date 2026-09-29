include <BOSL2/std.scad>
include <lib/geom.scad>

$fn = 120;

body = [200, 20, 1.2];
d_hole = 2.1;

module holes() {
  for (dx = [0:10:body.x - 0])
    translate(v=[dx, 0, 0])
      cylinder(d=d_hole, h=body.z, center=true);

  for (dx = [0:50:body.x])
    translate(v=[dx, 0, 0])
      cube([d_hole, 7.5, body.z], center=true);

  for (dx = [0:100:body.x])
    translate(v=[dx, 0, 0])
      cube([d_hole, 15, body.z], center=true);
}

render() {
  difference() {
    translate(v=[body.x / 2, 0, 0])
      cube(body + [d_hole * 4, 0, 0], center=true);
    holes();
  }
}
