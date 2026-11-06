include <BOSL2/std.scad>
include <lib/colours.scad>
include <lib/geom.scad>

fold = false;
show_chamfers = true;
show_clamp = false;
show_sides = true;

debug_stitches = false;
debug_clamp = false;

chamfer_clamp = 0.8; // [0.05:0.05:5]

t_leather = 0.8; // [0.05:0.05:5]
overhang_leather = 0.4; // [0:0.05:5]

l_boot = 65; // [1:1:100]
w_tab = 5; // [1:0.1:20]
a_tab = 60; // [0:1:90]
gap_tab = 0.4; // [0.05:0.05:5]

b_clamp = [150, 35, 20];
d_holes = [8, 8];
dx_holes = [18, 70];

$fn = 120;

module dbg_stitches() { if (debug_stitches) #children(); else children(); }

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
  if (debug_clamp)
    #clamp();

  dbg_stitches() {
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
  b_front_tab = [
    b_front.x,
    w_tab + overhang_leather,
    b_bottom.z,
  ];
  b_chamfer = [
    (b_clamp.z) / sqrt(2) + overhang_leather * 2,
    b_bottom.y,
    b_bottom.z,
  ];
  b_chamfer_tab = [
    b_chamfer.x,
    w_tab + overhang_leather,
    b_bottom.z,
  ];
  b_top = [
    b_bottom.x - b_clamp.z / 2,
    b_bottom.y,
    b_bottom.z,
  ];
  b_top_tab = [
    b_top.x,
    w_tab + overhang_leather,
    b_bottom.z,
  ];
  b_side = [
    b_bottom.x,
    b_clamp.z + overhang_leather * 2,
    b_bottom.z,
  ];

  module piece(size, anchor = LEFT + TOP) {
    cuboid(
      size=size,
      anchor=anchor,
      chamfer=show_chamfers ? min(overhang_leather, t_leather) : 0,
      edges=[
        TOP,
      ],
    );
  }

  // fold/unfold a piece
  module fold_unfold(a) {
    x =
      a.y > 0 ? -1
      : a.y < 0 ? 1
      : 0;
    y =
      a.x > 0 ? 1
      : a.x < 0 ? -1
      : 0;

    rot(a=fold ? [0, 0, 0] : -a, cp=fold ? [0, 0, 0] : [x * overhang_leather, y * overhang_leather, 0])
      translate(v=fold ? [0, 0, 0] : [x * overhang_leather * 2, y * overhang_leather * 2, 0])

        translate(v=[x * -overhang_leather * 2, y * -overhang_leather * 2, 0])
          rot(a=a, cp=[x * overhang_leather, y * overhang_leather, 0])

            children();
  }

  // specific piece fold/unfold, does not perform previous folds first

  module tr_bottom() {
    children();
  }

  module tr_front() {
    translate(v=[b_bottom.x, 0, 0])
      fold_unfold(a=[0, -90, 0])
        children();
  }

  module tr_front_tab(dir) {
    translate(v=[0, dir * b_bottom.y / 2, 0])
      fold_unfold(a=[dir * 90, 0, 0])
        children();
  }

  module tr_chamfer_tab(dir) {
    translate(v=[0, dir * b_bottom.y / 2, 0])
      fold_unfold(a=[dir * 90, 0, 0])
        children();
  }

  module tr_side(dir) {
    translate(v=[0, dir * b_bottom.y / 2, 0])
      fold_unfold(a=[dir * 90, 0, 0])
        children();
  }

  module tr_chamfer() {
    translate(v=[b_front.x, 0, 0])
      fold_unfold(a=[0, -45, 0])
        children();
  }

  module tr_top() {
    translate(v=[b_chamfer.x, 0, 0])
      fold_unfold(a=[0, -45, 0])
        children();
  }

  // specific stitch mask folds, performs previous transforms first

  module tr_mask_bottom() {
    children();
  }

  module tr_mask_front() {
    rotate(a=[0, 90, 0])
      translate(v=[-l_boot, 0, 0])
        children();
  }

  module tr_mask_front_tab(dir) {
    rotate(a=[-dir * 90, 0, 0])
      translate(v=[0, -dir * b_clamp.y / 2, 0])
        tr_mask_front()
          children();
  }

  module tr_mask_chamfer() {
    rotate(a=[0, 45, 0])
      translate(v=[-b_front.x + 2 * overhang_leather, 0, 0])
        tr_mask_front()
          children();
  }

  module tr_mask_chamfer_tab(dir) {
    rotate(a=[-dir * 90, 0, 0])
      translate(v=[0, -dir * b_clamp.y / 2, 0])
        tr_mask_chamfer()
          children();
  }

  module tr_mask_top() {
    rotate(a=[0, 45, 0])
      translate(v=[-b_chamfer.x + 2 * overhang_leather, 0, 0])
        tr_mask_chamfer()
          children();
  }

  module tr_mask_side(dir) {
    rotate(a=[-dir * 90, 0, 0])
      translate(v=[0, -dir * b_clamp.y / 2, 0])
        children();
  }

  // pieces

  module bottom() {
    tr_bottom()
      difference() {
        piece(b_bottom);
        tr_mask_bottom()
          mask_stitches();
      }
  }

  module front() {
    tr_front()
      difference() {
        piece(b_front);
        translate(v=[overhang_leather, 0, 0])
          tr_mask_front()
            mask_stitches();
      }
  }

  module front_tab(dir) {
    tr_front()
      tr_front_tab(dir)
        difference() {
          translate(v=[b_front_tab.x / 2, dir * b_front_tab.y / 2, -t_leather])
            linear_extrude(h=t_leather)
              mirror(v=[0, -min(dir, 0), 0])
                trapezoid(w1=b_front_tab.x, h=w_tab + overhang_leather, ang=a_tab);

          translate(v=[overhang_leather, dir * overhang_leather, 0])
            tr_mask_front_tab(dir)
              mask_stitches();
        }
  }

  module chamfer() {
    tr_front()
      tr_chamfer()
        difference() {
          piece(b_chamfer);
          translate(v=[overhang_leather, 0, 0])
            tr_mask_chamfer()
              mask_stitches();
        }
  }

  module chamfer_tab(dir) {
    tr_front()
      tr_chamfer()
        tr_chamfer_tab(dir)
          difference() {
            translate(v=[b_chamfer_tab.x / 2, dir * b_chamfer_tab.y / 2, -t_leather])
              linear_extrude(h=t_leather)
                mirror(v=[0, -min(dir, 0), 0])
                  trapezoid(w1=b_chamfer_tab.x, h=w_tab + overhang_leather, ang=a_tab);

            translate(v=[overhang_leather, dir * overhang_leather, 0])
              tr_mask_chamfer_tab(dir)
                mask_stitches();
          }
  }

  module top() {
    tr_front()
      tr_chamfer()
        tr_top()
          difference() {
            piece(b_top);
            translate(v=[overhang_leather, 0, 0])
              tr_mask_top()
                mask_stitches();
          }
  }

  module side(dir) {
    tr_side(dir=dir)
      difference() {
        piece(b_side, LEFT + TOP + (dir == 1 ? FRONT : BACK));

        translate(v=[b_side.x - b_clamp.z / 2 + overhang_leather * 2 / sqrt(2), dir * b_clamp.z, 0])
          rotate(a=[0, 0, dir * 45])
            translate(v=[l_boot / 2, 0, 0])
              cuboid(size=l_boot);

        translate(v=[0, dir * overhang_leather, 0])
          tr_mask_side(dir)
            mask_stitches();
      }
  }

  color(c=brown_pair(1)[0])
    bottom();

  color(c=brown_pair(1)[1])
    front();

  color(c=brown_pair(5)[0])
    front_tab(dir=-1);

  color(c=brown_pair(5)[1])
    front_tab(dir=1);

  color(c=brown_pair(0)[0])
    chamfer();

  color(c=brown_pair(6)[0])
    chamfer_tab(dir=1);

  color(c=brown_pair(6)[1])
    chamfer_tab(dir=-1);

  color(c=brown_pair(2)[1])
    top();

  if (show_sides) {
    color(c=brown_pair(3)[0])
      side(dir=1);

    color(c=brown_pair(3)[1])
      side(dir=-1);
  }
}

render() {
  if (show_clamp)
    color(c="darkgreen")
      clamp();

  leather();
}
