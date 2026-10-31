include <BOSL2/std.scad>
include <lib/colours.scad>

b_clamp = [150, 35, 20];
chamfer_clamp = 0.8;
d_holes = [8, 8];
dx_holes = [b_clamp.x - 18, b_clamp.x - 70];

$fn = 120;

module clamp() {
  module mask_cutout() {
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

    // chamfer the 45 degree edges to half the depth of the 90 degree edges
    // this still isn't quite right; the width of the chamfer should match
    d = chamfer_clamp / sqrt(2);
    a = 22.5;

    x1 = d / sin(90 - a);
    z1 = d / sin(a);
    translate(v=[0, 0, b_clamp.z / 2 + z1 / 2])
      rotate(a=-90, v=[1, 0, 0])
        linear_extrude(h=b_clamp.y, center=true)
          mask2d_chamfer(x=x1, y=z1);

    x2 = d / sin(a);
    z2 = d / sin(90 - a);
    translate(v=[b_clamp.z / 2 - x2 / 2, 0, b_clamp.z])
      rotate(a=-90, v=[1, 0, 0])
        linear_extrude(h=b_clamp.y, center=true)
          mask2d_chamfer(x=x2, y=z2);
  }

  module mask_holes() {
    translate(v=[0, 0, b_clamp.z / 2])for (i = [0:1:len(d_holes) - 1])
      translate(v=[dx_holes[i], 0, 0])
        cyl(d=d_holes[i], h=b_clamp.z);
  }

  difference() {
    translate(v=[b_clamp.x / 2, 0, b_clamp.z / 2])
      cuboid(
        size=[b_clamp.x, b_clamp.y, b_clamp.z],
        chamfer=chamfer_clamp,
      );

    mask_cutout();

    mask_holes();
  }
}

render() {
  color(c=brown_pair(0)[0])
    clamp();
}
