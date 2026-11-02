include <BOSL2/std.scad>
include <lib/colours.scad>

b_clamp = [150, 35, 20];
chamfer_clamp = 0.8;
d_holes = [8, 8];
dx_holes = [18, 70];

t_leather = 0.8; // [0.05:0.05:5]
overhang_leather = 0; // [0:0.05:5]

l_boot = 65;
w_tab = 8;
a_tab = 40;
gap_tab = 0.4;

fold = true;
show_clamp = true;
show_sides = true;

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
        rotate(a=[0, -45, 0])
          chamfer_edge_mask(
            l=b_clamp.z * 2,
            chamfer=chamfer_clamp,
          );

    // chamfer the 45 degree edges to the same width as the 90 degree edges
    w = chamfer_clamp * sqrt(2);
    d = w / 2 * tan(22.5);

    translate(v=[b_clamp.x - b_clamp.z / 2, b_clamp.y / 2, b_clamp.z])
      rotate(a=[0, 22.5, 0])
        translate(v=[0, 0, b_clamp.z / 2 - d])
          cuboid(size=b_clamp);

    translate(v=[b_clamp.x, b_clamp.y / 2, b_clamp.z / 2])
      rotate(a=[0, 90 - 22.5, 0])
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

module mask_stitches() {
  for (
    x = [0:5:l_boot],
    y = [-b_clamp.y / 2, b_clamp.y / 2]
  ) {
    translate(v=[x, y, b_clamp.z * 3 / 4])
      rotate(a=[90, 0, 0])
        #cylinder(h=t_leather * 5, r=0.5, center=true);
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
  b_top_tab = [
    b_top.x,
    w_tab + overhang_leather,
    b_bottom.z,
  ];
  b_front_tab = [
    b_front.x,
    w_tab + overhang_leather,
    b_bottom.z,
  ];

  module piece(size, anchor) {
    cuboid(
      size=size,
      anchor=anchor,
      chamfer=t_leather,
      edges=[
        TOP,
      ],
    );
  }

  module fold_unfold(a, cp) {
    unfold(a, cp)
      fold(a, cp)
        children();
  }

  module fold(a, cp) {
    rot(a=a, cp=cp)
      translate(v=cp)
        children();
  }

  module unfold(a, cp) {
    rot(a=fold ? [0, 0, 0] : -a, cp=cp)
      children();
  }

  module bottom() {
    color(c=brown_pair(1)[0])
      piece(b_bottom, LEFT + TOP);

    front(par=b_bottom);

    side_left(par=b_bottom);

    side_right(par=b_bottom);
  }

  module front(par) {
    a = [0, -90, 0];
    cp = [par.x, 0, 0];

    fold_unfold(a, cp) {
      color(c=brown_pair(1)[1])
        piece(b_front, LEFT + TOP);

      chamfer(par=b_front);
    }
  }

  module chamfer(par) {
    a = [0, -45, 0];
    cp = [par.x, 0, 0];

    fold_unfold(a, cp) {
      color(c=brown_pair(2)[0])
        piece(b_chamfer, LEFT + TOP);

      top(par=b_chamfer);
    }
  }

  module top(par) {
    a = [0, -45, 0];
    cp = [par.x, 0, 0];

    fold_unfold(a, cp)
      color(c=brown_pair(2)[1])
        piece(b_top, LEFT + TOP);
  }

  module side_left(par) {
    a = [90, 0, 0];
    cp = [0, par.y / 2, 0];

    if (show_sides)
      fold_unfold(a, cp)
        color(c=brown_pair(3)[0])
          piece(b_side, LEFT + TOP + FRONT);
  }

  module side_right(par) {
    a = [-90, 0, 0];
    cp = [0, -par.y / 2, 0];

    if (show_sides)
      fold_unfold(a, cp)
        color(c=brown_pair(3)[1])
          piece(b_side, LEFT + TOP + BACK);
  }

  difference() {
    bottom();
    mask_stitches();
  }
}

render() {
  if (show_clamp) {
    color(c="darkgreen")
      translate(v=[-b_clamp.x + l_boot, -b_clamp.y / 2, 0])
        clamp();
  }

  leather();
}
