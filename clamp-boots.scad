include <BOSL2/std.scad>
include <lib/colours.scad>

b_clamp = [150, 35, 20];
chamfer_clamp = 0.6;
d_holes = [8, 8];
dx_holes = [b_clamp.x - 18, b_clamp.x - 70];

$fn = 120;

module clamp() {
  difference() {
    translate(v=[b_clamp.x / 2, 0, b_clamp.z / 2])
      cuboid(
        size=[b_clamp.x, b_clamp.y, b_clamp.z],
        chamfer=chamfer_clamp,
      );

    translate(v=[0, 0, b_clamp.z])
      chamfer_edge_mask(
        l=b_clamp.y,
        chamfer=b_clamp.z / 2,
        orient=FRONT,
      );

    for (i = [-1, 1])
      translate(v=[0, i * b_clamp.y / 2, b_clamp.z / 2])
        rotate(a=45, v=[0, 1, 0])
          chamfer_edge_mask(
            l=b_clamp.z * 2,
            chamfer=chamfer_clamp,
          );

    translate(v=[b_clamp.z / 2, 0, b_clamp.z])
      rotate(a=-22.5, v=[0, 1, 0])
        cuboid(size=[b_clamp.z, b_clamp.y, chamfer_clamp]);

    translate(v=[0, 0, b_clamp.z / 2])
      rotate(a=-67.5, v=[0, 1, 0])
        cuboid(size=[b_clamp.z, b_clamp.y, chamfer_clamp]);

    translate(v=[0, 0, b_clamp.z / 2]) {
      for(i=[0:1:len(d_holes) - 1]) {
        translate(v=[dx_holes[i], 0, 0])
          cyl(d=d_holes[i], h=b_clamp.z);
      }
    }
  }
}

render() {
  color(c=brown_pair(0)[0])
    clamp();
}
