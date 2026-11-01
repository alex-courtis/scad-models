include <BOSL2/std.scad>
include <lib/colours.scad>
include <lib/geom.scad>

b_clamp = [150, 35, 20];
chamfer_clamp = 0.8;
d_holes = [8, 8];
dx_holes = [18, 70];

t_leather = 2; // [0.05:0.05:5]
t_leather_overhang = 0.4; // [0:0.05:5]

l_boot = 65;

fold = true;

$fn = 120;

module clamp() {
  module mask_cutout() {
    translate(v=[b_clamp.x, b_clamp.y / 2, b_clamp.z])
      chamfer_edge_mask(
        l=b_clamp.y,
        chamfer=b_clamp.z / 2,
        orient=FRONT,
      );

    for (dy = [0, b_clamp.y])
      translate(v=[b_clamp.x, dy, b_clamp.z / 2])
        rotate(a=-45, v=[0, 1, 0])
          chamfer_edge_mask(
            l=b_clamp.z * 2,
            chamfer=chamfer_clamp,
          );

    // chamfer the 45 degree edges to the same width as the 90 degree edges
    w = chamfer_clamp * sqrt(2);
    d = w / 2 * tan(22.5);

    translate(v=[b_clamp.x - b_clamp.z / 2, b_clamp.y / 2, b_clamp.z])
      rotate(a=22.5, v=[0, 1, 0])
        translate(v=[0, 0, b_clamp.z / 2 - d])
          cuboid(size=b_clamp);

    translate(v=[b_clamp.x, b_clamp.y / 2, b_clamp.z / 2])
      rotate(a=90 - 22.5, v=[0, 1, 0])
        translate(v=[0, 0, b_clamp.z / 2 - d])
          cuboid(size=b_clamp);
  }

  module mask_holes() {
    for (i = [0:1:len(d_holes) - 1])
      translate(v=[dx_holes[i], b_clamp.y / 2, 0])
        cyl(d=d_holes[i], h=b_clamp.z, center=false);
  }

  difference() {
    cuboid(
      size=[b_clamp.x, b_clamp.y, b_clamp.z],
      chamfer=chamfer_clamp,
      anchor=LEFT + FRONT + BOT,
    );

    mask_cutout();

    mask_holes();
  }
}

module leather() {

  b_bottom = [
    l_boot + t_leather / 2,
    b_clamp.y + t_leather,
    t_leather,
  ];
  b_front = [
    b_clamp.z / 2 + t_leather,
    b_clamp.y + t_leather,
    t_leather,
  ];
  b_chamfer = [
    (b_clamp.z) / sqrt(2) + t_leather,
    b_clamp.y + t_leather,
    t_leather,
  ];
  b_top = [
    b_bottom.x - b_clamp.z / 2,
    b_clamp.y + t_leather,
    t_leather,
  ];

  module leather_bottom() {

    cuboid(
      size=b_bottom,
      anchor=LEFT + TOP,
      chamfer=t_leather / 2,
      edges=[
        TOP,
      ],
    );
  }

  module leather_front() {
    tr_fold = [b_bottom.x, 0, -t_leather / 2];
    tr_pos = [b_bottom.x, 0, -t_leather / 2];

    module fold() {
      translate(v=tr_fold)
        rotate(a=-90, v=[0, 1, 0])
          children();
    }

    module unfold() {
      if (fold)
        children();
      else
        translate(v=tr_pos)
          rotate(a=90, v=[0, 1, 0])
            translate(v=vector_multiply_vector(tr_fold, [-1, -1, -1]))
              children();
    }

    unfold()
      fold()
        cuboid(
          size=b_front,
          anchor=LEFT,
          chamfer=t_leather / 2,
          edges=[
            TOP,
          ],
        );
  }

  module leather_chamfer() {
    tr_fold = [l_boot - b_clamp.z / 4 + t_leather / 2 / sqrt(2), 0, b_clamp.z * 3 / 4 + t_leather / 2 / sqrt(2)];
    tr_pos = [b_bottom.x + b_front.x + b_chamfer.x / 2, 0, -t_leather / 2];

    module fold() {
      translate(v=tr_fold)
        rotate(a=-135, v=[0, 1, 0])
          children();
    }

    module unfold() {
      if (fold)
        children();
      else
        translate(v=tr_pos)
          rotate(a=135, v=[0, 1, 0])
            translate(v=vector_multiply_vector(tr_fold, [-1, -1, -1]))
              children();
    }

    unfold()
      fold()
        cuboid(
          size=b_chamfer,
          chamfer=t_leather / 2,
          edges=[
            TOP,
          ],
        );
  }

  module leather_top() {

    tr_fold = [0, 0, b_clamp.z + t_leather / 2];
    tr_pos = [b_bottom.x + b_front.x + b_chamfer.x, 0, -t_leather / 2];

    module fold() {
      translate(v=tr_fold)
        mirror(v=[0, 0, 1])
          children();
    }

    module unfold() {
      if (fold)
        children();
      else
        translate(v=tr_pos)
          mirror(v=[0, 0, 1])
            translate(v=vector_multiply_vector(tr_fold, [-1, -1, -1]))
              children();
    }

    unfold()
      fold()
        cuboid(
          size=b_top,
          anchor=LEFT,
          chamfer=t_leather / 2,
          edges=[
            TOP,
          ],
        );
  }

  color(c=brown_pair(1)[0])
    leather_bottom();

  color(c=brown_pair(1)[1])
    leather_front();

  color(c=brown_pair(2)[0])
    leather_chamfer();

  color(c=brown_pair(2)[1])
    leather_top();
}

render() {
  color(c=brown_pair(0)[0])
    translate(v=[-b_clamp.x + l_boot, -b_clamp.y / 2, 0])
      clamp();

  leather();
}
