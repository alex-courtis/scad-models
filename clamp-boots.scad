include <BOSL2/std.scad>
include <lib/colours.scad>
include <lib/geom.scad>

fold = false;
show_chamfers = false;
show_clamp = false;
show_sides = true;

debug_stitches = false;
debug_clamp = false;
debug_corner_holes = false;

chamfer_clamp = 0.8; // [0.05:0.05:5]

t_leather = 0.8; // [0.05:0.05:5]
overhang_leather = 0.4; // [0:0.05:5]

l_boot = 65; // [1:1:100]
w_tab = 4.5; // [1:0.1:20]
gap_tab = 1; // [0.05:0.05:5]
d_corner_holes = 2;

b_clamp = [150, 35, 20];
d_clamp_holes = [8, 8];
x_clamp_holes = [18, 70];

da_tab = 0; // [0:0.5:70]
a_tab_front = 80; // [0:0.5:90]
a_tab_top = 75; // [0:0.5:90]

l1_awl = 3.5;
l2_awl = 1.95;
stitch_inset = 2.5; // [0.00:0.05:5]
stitch_spacing = 4.3; // [0.05:0.05:5]
t_template = 1.6; // TODO scale z
scale_awl = 1.156; // TODO value is from 2.5, scale to t_template

function poly_awl(l1, l2) =
  [
    [0, l1 / 2],
    [-l2 / 2, 0],
    [0, -l1 / 2],
    [l2 / 2, 0],
  ];

$fn = 120;

module dbg_stitches() { if (debug_stitches) #children(); else children(); }
module dbg_corner_holes() { if (debug_corner_holes) #children(); else children(); }

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
  b_front.x - gap_tab * 2,
  w_tab + overhang_leather,
  b_bottom.z,
];
ang_front_tab = [a_tab_front, 135 / 2 - da_tab];
b_chamfer = [
  (b_clamp.z) / sqrt(2) + overhang_leather * 2,
  b_bottom.y,
  b_bottom.z,
];
b_chamfer_tab = [
  b_chamfer.x - gap_tab * 2,
  w_tab + overhang_leather,
  b_bottom.z,
];
ang_chamfer_tab = [135 / 2 - da_tab, 135 / 2 - da_tab];
b_top = [
  b_bottom.x - b_clamp.z / 2,
  b_bottom.y,
  b_bottom.z,
];
b_top_tab = [
  b_top.x - gap_tab,
  w_tab + overhang_leather,
  b_bottom.z,
];
ang_top_tab = [135 / 2 - da_tab, a_tab_top];
b_side = [
  l_boot,
  b_clamp.z + overhang_leather * 2,
  b_bottom.z,
];

// origin at x=l_boot, y=b_clamp.y/2, z=-b_clamp.z/2
module clamp() {
  module mask_chamfer() {
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
    for (i = [0:1:len(d_clamp_holes) - 1])
      translate(v=[-b_clamp.x / 2 + x_clamp_holes[i], 0, 0])
        cyl(d=d_clamp_holes[i], h=b_clamp.z, center=true);
  }

  translate(v=[-b_clamp.x / 2 + l_boot, 0, b_clamp.z / 2])
    difference() {
      cuboid(
        size=[b_clamp.x, b_clamp.y, b_clamp.z],
        chamfer=show_chamfers ? chamfer_clamp : 0,
      );

      mask_chamfer();

      mask_holes();
    }
}

module mask_awl(s = scale_awl, l1 = l1_awl, l2 = l2_awl, t) {
  extrude_from_to(
    [0, 0, -t / 2 - 0.00001],
    [0, 0, t / 2 + 0.00001],
    scale=s,
  )
    polygon(poly_awl(l1, l2));
}

// origin at x=l_boot, y=b_clamp.y/2, z=-b_clamp.z/2
module mask_stitches() {
  if (debug_clamp)
    #clamp();

  module mask_stitch(dir, a = -45) {
    translate(v=[0, dir * t_leather / 2, 0])
      rotate(a=[0, a, 0])
        rotate(a=[-dir * 90, 0, 0])
          mask_awl(t=t_leather);
  }

  dbg_stitches() {
    x_back = stitch_inset;

    x_top = l_boot - b_clamp.z / 2 - stitch_inset * cos(67.5);
    z_top = b_clamp.z - stitch_inset * sin(67.7);

    x_chamfer = l_boot - stitch_inset * cos(22.5);
    z_chamfer = b_clamp.z / 2 - stitch_inset * sin(22.5);

    x_front = x_chamfer;
    z_front = stitch_inset;

    spacing_top = (x_top - x_back) / round((x_top - x_back) / stitch_spacing);

    spacing_front = (z_chamfer - z_front) / round((z_chamfer - z_front) / stitch_spacing);

    len_chamfer = sqrt((x_front - x_top) ^ 2 + (z_top - z_chamfer) ^ 2);
    stitches_chamfer = round(len_chamfer / stitch_spacing);
    spacing_chamfer = len_chamfer / stitches_chamfer;
    dxz_chamfer = spacing_chamfer / sqrt(2);

    for (dir = [-1, 1]) {
      translate(v=[0, dir * b_clamp.y / 2, 0]) {
        for (x = [x_back:spacing_top:x_top]) {
          translate(v=[x, 0, z_top])
            mask_stitch(dir, a=-45);
        }

        for (i = [1:1:stitches_chamfer]) {
          translate(v=[x_top + i * dxz_chamfer, 0, z_top - i * dxz_chamfer])
            mask_stitch(dir, a=0);
        }

        for (z = [z_front:spacing_front:z_chamfer - spacing_front]) {
          translate(v=[x_front, 0, z])
            mask_stitch(dir, a=45);
        }
      }
    }
  }
}

module mask_corner_holes() {
  for (
    x = [
      b_bottom.x,
      b_bottom.x + b_front.x,
      b_bottom.x + b_front.x + b_chamfer.x,
    ],
    y = [-b_clamp.y / 2 - overhang_leather, b_clamp.y / 2 + overhang_leather],
  ) {
    translate(v=[x, y, 0])
      cylinder(d=d_corner_holes, h=b_clamp.z, center=true);
  }
}

module leather() {

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

  module tr_chamfer() {
    translate(v=[b_front.x, 0, 0])
      fold_unfold(a=[0, -45, 0])
        children();
  }

  module tr_chamfer_tab(dir) {
    translate(v=[0, dir * b_bottom.y / 2, 0])
      fold_unfold(a=[dir * 90, 0, 0])
        children();
  }

  module tr_top() {
    translate(v=[b_chamfer.x, 0, 0])
      fold_unfold(a=[0, -45, 0])
        children();
  }

  module tr_top_tab(dir) {
    translate(v=[0, dir * b_bottom.y / 2, 0])
      fold_unfold(a=[dir * 90, 0, 0])
        children();
  }

  module tr_side(dir) {
    translate(v=[0, dir * b_bottom.y / 2, 0])
      fold_unfold(a=[dir * 90, 0, 0])
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

  module tr_mask_top_tab(dir) {
    rotate(a=[-dir * 90, 0, 0])
      translate(v=[0, -dir * b_clamp.y / 2, 0])
        tr_mask_top()
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
          translate(v=[gap_tab, 0, -t_leather])
            linear_extrude(h=t_leather)
              mirror(v=[0, -min(dir, 0), 0])
                trapezoid(w1=b_front_tab.x, h=w_tab + overhang_leather, ang=ang_front_tab, anchor=LEFT + BOTTOM);

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
            translate(v=[gap_tab, 0, -t_leather])
              linear_extrude(h=t_leather)
                mirror(v=[0, -min(dir, 0), 0])
                  trapezoid(w1=b_chamfer_tab.x, h=w_tab + overhang_leather, ang=ang_chamfer_tab, anchor=LEFT + BOTTOM);

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

  module top_tab(dir) {
    tr_front()
      tr_chamfer()
        tr_top()
          tr_top_tab(dir)
            difference() {
              translate(v=[gap_tab, 0, -t_leather])
                linear_extrude(h=t_leather)
                  mirror(v=[0, -min(dir, 0), 0])
                    trapezoid(w1=b_top_tab.x, h=w_tab + overhang_leather, ang=ang_top_tab, anchor=LEFT + BOTTOM);

              translate(v=[overhang_leather, dir * overhang_leather, 0])
                tr_mask_top_tab(dir)
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

  color(c=brown_pair(7)[0])
    top_tab(dir=1);

  color(c=brown_pair(7)[1])
    top_tab(dir=-1);

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

  difference() {
    leather();
    if (!fold)
      dbg_corner_holes() mask_corner_holes();
  }
}
