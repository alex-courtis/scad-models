include <BOSL2/std.scad>
include <lib/colours.scad>
include <lib/geom.scad>

fold = false;
show_chamfers = true;
show_clamp = false;
show_sides = false;
show_points = false;

debug_stitches = false;

chamfer_clamp = 0.8; // [0.05:0.05:5]

t_leather = 0.8; // [0.05:0.05:5]
overhang_leather = 1.6; // [0:0.05:5]

l_boot = 65; // [1:1:100]
w_tab = 8; // [1:1:20]
a_tab = 40; // [0:1:90]
gap_tab = 0.4; // [0.05:0.05:5]

b_clamp = [150, 35, 20];
d_holes = [8, 8];
dx_holes = [18, 70];

$fn = 120;

module dbg_stiches() { if (debug_stitches) #children(); else children(); }
module point() { if (show_points) children(); }

// origin at x=l_boot, y=b_clamp.y/2, z=-b_clamp.z/2
module clamp() {
  module mask_cutout() {
    translate(v=[b_clamp.x / 2, 0, b_clamp.z / 2])
      chamfer_edge_mask(
        l=b_clamp.y,
        chamfer=b_clamp.z / 2,
        orient=FRONT,
      );

    if (show_chamfers) {
      for (dy = [-b_clamp.y / 2, b_clamp.y / 2])
        translate(v=[b_clamp.x / 2, dy, 0])
          rotate(a=[0, -45, 0])
            chamfer_edge_mask(
              l=b_clamp.z * 2,
              chamfer=chamfer_clamp,
            );

      // chamfer the 45 degree edges to the same width as the 90 degree edges
      w = chamfer_clamp * sqrt(2);
      d = w / 2 * tan(22.5);

      translate(v=[b_clamp.x / 2 - b_clamp.z / 2, 0, b_clamp.z / 2])
        rotate(a=[0, 22.5, 0])
          translate(v=[0, 0, b_clamp.z / 2 - d])
            cuboid(size=b_clamp);

      translate(v=[b_clamp.x / 2, 0, 0])
        rotate(a=[0, 90 - 22.5, 0])
          translate(v=[0, 0, b_clamp.z / 2 - d])
            cuboid(size=b_clamp);
    }
  }

  module mask_holes() {
    for (i = [0:1:len(d_holes) - 1])
      translate(v=[-b_clamp.x / 2 + dx_holes[i], 0, 0])
        cyl(d=d_holes[i], h=b_clamp.z, center=true);
  }

  translate(v=[-b_clamp.x / 2 + l_boot, 0, b_clamp.z / 2])
    difference() {
      cuboid(
        size=[b_clamp.x, b_clamp.y, b_clamp.z],
        chamfer=show_chamfers ? chamfer_clamp : 0,
      );

      mask_cutout();

      mask_holes();
    }
}

module mask_stitches() {
  translate(v=[-l_boot, 0, 0]) {
    for (
      x = [0:5:l_boot],
      y = [-b_clamp.y / 2, b_clamp.y / 2]
    ) {
      translate(v=[x, y, b_clamp.z * 3 / 4])
        rotate(a=[90, 0, 0])
          cylinder(h=t_leather * 5, r=0.5, center=true);
    }

    for (
      y = [-b_clamp.y / 2:5:b_clamp.y / 2],
      z = [b_clamp.z * 1 / 4, b_clamp.z * 2 / 4, b_clamp.z * 3 / 5]
    ) {
      translate(v=[l_boot, y, z])
        rotate(a=[0, 90, 0])
          cylinder(h=t_leather * 5, r=0.5, center=true);
    }

    for (
      x = [0:5:l_boot],
      y = [b_clamp.y * -1 / 3, b_clamp.y * 1 / 3]
    ) {
      translate(v=[x, y, b_clamp.z])
        rotate(a=[0, 0, 90])
          cylinder(h=t_leather * 5, r=0.5, center=true);
    }
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
      chamfer=show_chamfers ? t_leather : 0,
      edges=[
        TOP,
      ],
    );
  }

  module piece_trap(size, anchor, ang, anchor_trap) {
    intersection() {
      translate(v=[0, 0, -t_leather])
        linear_extrude(h=t_leather)
          trapezoid(
            h=size.y,
            w1=size.x,
            ang=ang,
            anchor=anchor_trap,
          );
      piece(size, anchor);
    }
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

    side(par=b_bottom, left=true);

    side(par=b_bottom, left=false);
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

  module side(par, left) {
    a = [left ? 90 : -90, 0, 0];
    cp = [0, left ? par.y / 2 : -par.y / 2, 0];

    if (show_sides)
      fold_unfold(a, cp)
        mirror(v=left ? [0, 0, 0] : [0, 1, 0])
          color(c=brown_pair(3)[left ? 0 : 1])
            piece_trap(b_side, LEFT + TOP + FRONT, ang=[90, a_tab], anchor_trap=LEFT + BOTTOM);
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
    // mask_stitches();
  }

  cp_bottom = [overhang_leather, overhang_leather, 0];
  point() point_marker(cp_bottom, r=0.1, h=50, t="cp_bottom", a_rot=90, v_rot=[1, 0, 0]);

  cp_front = cp_bottom + [b_bottom.x, 0, 0];
  point() point_marker(cp_front, r=0.1, h=50, t="cp_front", a_rot=90, v_rot=[1, 0, 0]);

  cp_chamfer = cp_front + [b_front.x, 0, 0];
  point() point_marker(cp_chamfer, r=0.1, h=50, t="cp_chamfer", a_rot=90, v_rot=[1, 0, 0]);

  cp_top = cp_chamfer + [b_chamfer.x, 0, 0];
  point() point_marker(cp_top, r=0.1, h=50, t="cp_top", a_rot=90, v_rot=[1, 0, 0]);

  cp_side = cp_bottom + [0, b_bottom.y / 2, 0];
  point() point_marker(cp_side, r=0.1, h=50, t="cp_side", a_rot=-90, v_rot=[0, 1, 0]);
  point() point_marker(-cp_side, r=0.1, h=50, t="cp_side", a_rot=-90, v_rot=[0, 1, 0]);

  module m_bottom(dy) {
    color(c="blue", alpha=0.5)
      clamp();
  }

  module m_front(dy) {
    rot(a=[0, 90, 0], cp=cp_front)
      translate(v=[overhang_leather * 2, 0, 0])
        m_bottom(dy=dy);
  }

  module m_chamfer(dy) {
    rot(a=[0, 45, 0], cp=cp_chamfer)
      translate(v=[overhang_leather * 2, 0, 0])
        m_front(dy=dy);
  }

  module m_top(dy) {
    rot(a=[0, 45, 0], cp=cp_top)
      translate(v=[overhang_leather * 2, 0, 0])
        m_chamfer(dy=dy);
  }

  module m_side(dir) {
    rot(a=[dir * -90, 0, 0], cp=dir * cp_side)
      translate(v=[0, dir * overhang_leather * 2, 0])
        m_bottom(dy=0);
  }

  m_bottom(dy=0);

  // m_front(dy=-20);
  //
  // m_chamfer(dy=-10);
  //
  // m_top(dy=-30);
  //
  // m_side(1);
  //
  // m_side(-1);
}

render() {
  if (show_clamp)
    color(c="darkgreen")
      clamp();

  leather();
}
