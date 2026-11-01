include <BOSL2/std.scad>
include <lib/colours.scad>

b_clamp = [150, 35, 20];
chamfer_clamp = 0.8;
d_holes = [8, 8];
dx_holes = [-b_clamp.x + 18, -b_clamp.x + 70];

t_leather = 0.8; // [0.05:0.05:5]
t_leather_overhang = 0.4; // [0:0.05:5]

l_boot = 100;

$fn = 120;

module clamp() {
  module mask_cutout() {
    translate(v=[b_clamp.x / 2, 0, b_clamp.z / 2])
      chamfer_edge_mask(
        l=b_clamp.y,
        chamfer=b_clamp.z / 2,
        orient=FRONT,
      );

    for (i = [-1, 1])
      translate(v=[b_clamp.x / 2, i * b_clamp.y / 2, 0])
        rotate(a=-45, v=[0, 1, 0])
          chamfer_edge_mask(
            l=b_clamp.z * 2,
            chamfer=chamfer_clamp,
          );

    // chamfer the 45 degree edges to the same width as the 90 degree edges
    w = chamfer_clamp * sqrt(2);
    d = w / 2 * tan(22.5);

    translate(v=[(b_clamp.x - b_clamp.z) / 2, 0, b_clamp.z / 2])
      rotate(a=22.5, v=[0, 1, 0])
        translate(v=[0, 0, b_clamp.z / 2 - d])
          cuboid(size=b_clamp);

    translate(v=[b_clamp.x / 2, 0, 0])
      rotate(a=90 - 22.5, v=[0, 1, 0])
        translate(v=[0, 0, b_clamp.z / 2 - d])
          cuboid(size=b_clamp);
  }

  module mask_holes() {
    for (i = [0:1:len(d_holes) - 1])
      translate(v=[b_clamp.x / 2 + dx_holes[i], 0, 0])
        cyl(d=d_holes[i], h=b_clamp.z);
  }

  difference() {
    cuboid(
      size=[b_clamp.x, b_clamp.y, b_clamp.z],
      chamfer=chamfer_clamp,
    );

    mask_cutout();

    mask_holes();
  }
}

module leather_bottom() {
  // b_base = [l_boot, b_clamp.y
}

render() {
  color(c=brown_pair(0)[0])
    clamp();

  color(c=brown_pair(1)[0])
    leather_bottom();
}
