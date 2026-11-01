include <BOSL2/std.scad>
include <lib/colours.scad>
include <lib/geom.scad>

b_clamp = [150, 35, 20];
chamfer_clamp = 0.8;
d_holes = [8, 8];
dx_holes = [18, 70];

t_leather = 0.8; // [0.05:0.05:5]
overhang_leather = 0.3; // [0:0.05:5]

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
    l_boot + overhang_leather,
    b_clamp.y + overhang_leather * 2,
    t_leather,
  ];
  b_front = [
    b_clamp.z / 2 + overhang_leather * 2,
    b_bottom.y,
    b_bottom.z,
  ];
  b_chamfer = [
    (b_clamp.z) / sqrt(2) + overhang_leather * 2,
    b_bottom.y,
    b_bottom.z,
  ];
  b_top = [
    b_bottom.x - b_clamp.z / 2,
    b_bottom.y,
    b_bottom.z,
  ];
  b_side = [
    b_bottom.x,
    b_clamp.z + overhang_leather * 2,
    b_bottom.z,
  ];

  module fold_unfold(tr_fold, tr_pos, a_rot, v_rot) {
    if (fold)
      translate(v=tr_fold)
        rotate(a=a_rot, v=v_rot)
          children();
    else
      translate(v=tr_pos)
        rotate(a=-a_rot, v=v_rot)
          translate(v=vector_multiply_vector(tr_fold, [-1, -1, -1]))
            translate(v=tr_fold)
              rotate(a=a_rot, v=v_rot)
                children();
  }

  module leather_bottom() {
    cuboid(
      size=b_bottom,
      anchor=LEFT + TOP,
      chamfer=overhang_leather,
      edges=[
        TOP,
      ],
    );
  }

  module leather_front() {
    tr_fold = [l_boot + t_leather / 2, 0, -overhang_leather];
    tr_pos = [b_bottom.x, 0, -t_leather / 2];

    fold_unfold(tr_fold, tr_pos, -90, [0, 1, 0])
      cuboid(
        size=b_front,
        anchor=LEFT,
        chamfer=overhang_leather,
        edges=[
          TOP,
        ],
      );
  }

  module leather_chamfer() {
    tr_fold = [l_boot - b_clamp.z / 4 + t_leather / 2 / sqrt(2), 0, b_clamp.z * 3 / 4 + t_leather / 2 / sqrt(2)];
    tr_pos = [b_bottom.x + b_front.x + b_chamfer.x / 2, 0, -t_leather / 2];

    fold_unfold(tr_fold, tr_pos, -135, [0, 1, 0])
      cuboid(
        size=b_chamfer,
        chamfer=overhang_leather,
        edges=[
          TOP,
        ],
      );
  }

  module leather_top() {
    tr_fold = [0, 0, b_clamp.z + t_leather / 2];
    tr_pos = [b_bottom.x + b_front.x + b_chamfer.x, 0, -t_leather / 2];

    fold_unfold(tr_fold, tr_pos, 180, [1, 0, 0])
      cuboid(
        size=b_top,
        anchor=LEFT,
        chamfer=overhang_leather,
        edges=[
          TOP,
        ],
      );
  }

  module leather_side() {
    tr_fold = [0, b_clamp.y / 2 + t_leather / 2, b_clamp.z / 2];
    tr_pos = [0, (b_bottom.y + b_side.y) / 2, -t_leather / 2];

    fold_unfold(tr_fold, tr_pos, 90, [1, 0, 0])
      diff()
        cuboid(
          size=b_side,
          anchor=LEFT,
          chamfer=overhang_leather,
          edges=[
            TOP,
          ],
        )
          edge_profile([BACK + RIGHT]) {
            mask2d_chamfer(h=b_side.y / 2 - overhang_leather);
          }
    ;
  }

  color(c=brown_pair(1)[0])
    leather_bottom();

  color(c=brown_pair(1)[1])
    leather_front();

  color(c=brown_pair(2)[0])
    leather_chamfer();

  color(c=brown_pair(2)[1])
    leather_top();

  color(c=brown_pair(3)[0])
    leather_side();

  color(c=brown_pair(3)[1])
    mirror(v=[0, 1, 0])
      leather_side();
}

render() {
  color(c=brown_pair(0)[0])
    translate(v=[-b_clamp.x + l_boot, -b_clamp.y / 2, 0])
      clamp();

  leather();
}
