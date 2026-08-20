include <BOSL2/std.scad>
include <lib/geom.scad>
include <lib/colours.scad>

// TODO 
// hinge clearance
// lid liner
// shorten lid

/* [Show] */
show_back = true;
show_front = false;
show_leather_main_back = true;
show_leather_main_front = false;
show_leather_main_left = true;
show_leather_main_right = false;
show_lid = true;
show_leather_lid_wall = true;
show_leather_lid_left = true;
show_leather_lid_right = false;
show_liner_template = false;
fold = true;

/* [Debug] */
debug_dx_lid = 0; // [0:0.1:180]
debug_lid_angle = 90; // [0:1:180]
debug_gaps = false;
debug_holes = false;
debug_int = false;
debug_magnet = false;
debug_hinge = true;
debug_lid_long = false;

/* [Dimensions] */

// interior target
// x excludes the rounded ends
// x, y quantized for linear hole spacing
// z quantized for curved hole spacing, arc outside of leather
int_main_target = [132, 70, 35];

t_side = 4.5; // [0:0.05:10]
t_wall = 4.5; // [0:0.05:10]

chamfer_outer = 0.6; // [0:0.05:2]
chamfer_int = 2; // [0:0.05:5]

t_leather = 0.8; // [0.05:0.05:5]
t_leather_overhang = 0.0; // [0:0.05:5]

t_foldover = 1.8; // [0:0.05:15]
w_foldover = 6.5; // [0:0.05:15]

chamfer_foldover = 0.8; // [0:0.05:2]

gap_half = 1; // [0:0.05:5]

/* [Leather Stitch Holes] */
hole_stitch_l = 3.5; // [0:0.1:5]
hole_stitch_w = 1.5; // [0:0.1:5]

// centre of hole to edge
hole_stitch_inset = 4; // [0:0.1:10]
hole_stitch_spacing = 5; // [0:0.1:10]

// sides and wall
a_stitch = -45; // [0:1:90]

/* [Liner Holes] */
hole_liner_d = 1.8;
channel_liner_xy = 0.4;

/* [Pins] */
d_pin = 2.3; // [0:0.05:5]
l_pin = 16; // [0:0.1:50]

/* [Magnets] */
d_magnet = 6.1; // [0:0.05:10]
t_magnet = 4.05; // [0:0.05:10]

/* [Hinges] */
d_hinge = 4; // [0:0.05:10]
l_hinge = 30; // [0:0.05:100]
// added to d_hinge/2 + t_leather
clearance_hinge = 2; // [-5:0.05:5]

/* [Liner] */
t_liner = 0.6; // [0:0.05:10]

// quantize external x - linear
x_quant = round_nearest(int_main_target.x, hole_stitch_spacing) - hole_stitch_spacing + hole_stitch_inset;
echo(x_quant=x_quant);

// quantize external y - linear
y_quant = round_nearest(int_main_target.y + 2 * t_side - 2 * hole_stitch_inset, hole_stitch_spacing) + 2 * hole_stitch_inset;
echo(y_quant=y_quant);

// quantize external z - end radius outside of leather
r_end = int_main_target.z / 2 + t_wall + t_leather;
echo(r_end=r_end);

// angle at spacing_hole
a_end = arc_angle(hole_stitch_spacing, r_end);
echo(a_end=a_end);

// round this angle to fit a clean divisor of 180
a_end_quant = 180 / round(180 / a_end);
echo(a_end_quant=a_end_quant);

// new total z
r_end_quant = arc_radius(a_end_quant, hole_stitch_spacing);
echo(r_end_quant=r_end_quant);

ext_main = [x_quant, y_quant, 2 * (r_end_quant - t_leather)];
echo(ext_main=ext_main);

int_main = ext_main - [0, 2 * t_side, 2 * t_wall];
echo(int_main_target=int_main_target);
echo(int_main=int_main);

ext_lid = [hole_stitch_inset + hole_stitch_spacing, ext_main.y, ext_main.z];
echo(ext_lid=ext_lid);

int_lid = ext_lid - [0, 2 * t_side, 2 * t_wall];
echo(int_lid=int_lid);

dx_hinge = d_hinge / 2 + t_leather + clearance_hinge;
echo(dx_hinge=dx_hinge);

dz_hinge = (t_wall + chamfer_int) / 2;
echo(dz_hinge=dz_hinge);

$fn = 100;

function poly_foldover_edge(b) =
  [
    [-b.x / 2, -b.y / 2],
    [-b.x / 2, b.y / 2],
    [-b.x / 2 + t_leather, b.y / 2],
    [b.x / 2, b.y / 2 - b.x + t_leather],
    [b.x / 2, -b.y / 2 + b.x - t_leather],
    [-b.x / 2 + t_leather, -b.y / 2],
  ];

module mask_stitch(ax, ay, az) {

  module mask() {
    z_hole = sqrt(2 * hole_stitch_inset ^ 2) + sqrt((2 * hole_stitch_w / 2) ^ 2) + 2 * t_leather * sqrt(2);

    rotate(a=ay, v=[0, 1, 0])
      rotate(a=az, v=[0, 0, 1])
        rotate(a=ax, v=[1, 0, 0])
          cube(size=[hole_stitch_l, hole_stitch_w, z_hole], center=true);
  }

  if (debug_holes)
    #mask();
  else
    mask();
}

// x0 -> x1
module mask_stitches_long(ax, az, x0, x1) {
  for (dx = [x0:hole_stitch_spacing:x1]) {
    translate(v=[dx, 0, 0]) {
      mask_stitch(ax=ax, ay=0, az=az);
    }
  }
}

module mask_stitches_wide(ext, az, dx, dz, az) {
  y = ext.y / 2 - hole_stitch_inset - hole_stitch_spacing;

  for (dy = [-y:hole_stitch_spacing:y])
    translate(v=[dx, dy, dz])
      mask_stitch(ax=0, ay=0, az=az);
}

module mask_stitches_deep(ext, ay, dy) {
  z = ext.z / 2 - hole_stitch_inset;

  spacing = z / round_nearest(z, hole_stitch_spacing) * hole_stitch_spacing;

  for (dz = [-z + spacing:spacing:z - spacing]) {
    translate(v=[ext.x / 2 - hole_stitch_inset, dy, dz])
      mask_stitch(ax=90, ay=ay, az=0);
  }
}

module mask_stitches_quartercircle(ax, ay, az, dy, dz) {
  for (a = [-180:a_end_quant:-90]) {
    rotate(a=a, v=[0, 1, 0]) {
      translate(v=[0, dy, dz])
        mask_stitch(ax=ax, ay=(a == -90 ? 0 : ay), az=(a == -90 ? 0 : -az));
    }
  }
}

module mask_foldover(ext, int, w_foldover, t_foldover) {
  mask_wide = [
    w_foldover,
    int.y + t_foldover * 2,
    int.z / 2 - chamfer_int,
  ];

  translate(v=[(ext.x - mask_wide.x) / 2, 0, -mask_wide.z / 2])
    cube(size=mask_wide, center=true);

  mask_deep = [
    w_foldover,
    int.y - chamfer_int * 2,
    int.z / 2 + t_foldover,
  ];

  translate(v=[(ext.x - mask_deep.x) / 2, 0, -mask_deep.z / 2])
    cube(size=mask_deep, center=true);

  translate(v=[ext.x / 2, 0, 0]) {
    translate(v=[0, 0, -ext.z / 2 + t_wall - t_foldover])
      chamfer_edge_mask(l=int.y - chamfer_int * 2, chamfer=chamfer_foldover, orient=FRONT, excess=0);

    translate(v=[0, 0, -ext.z / 2])
      chamfer_edge_mask(l=ext.y, chamfer=chamfer_foldover, orient=FRONT, excess=0);

    for (i = [-1, 1]) {
      translate(v=[0, i * (ext.y / 2 - t_side + t_foldover), 0])
        chamfer_edge_mask(l=int.z - chamfer_int * 2, chamfer=chamfer_foldover, orient=BOTTOM, excess=0);

      translate(v=[0, i * (ext.y / 2), 0])
        chamfer_edge_mask(l=ext.z, chamfer=chamfer_foldover, orient=BOTTOM, excess=0);
    }
  }

  translate(v=[ext.x / 2 - w_foldover, 0, 0]) {
    translate(v=[0, 0, -ext.z / 2 + t_wall])
      chamfer_edge_mask(l=int.y - 2 * chamfer_int, chamfer=chamfer_foldover, orient=FRONT, excess=0);

    for (i = [-1, 1])
      translate(v=[0, i * (ext.y / 2 - t_side), 0])
        chamfer_edge_mask(l=int.z - 2 * chamfer_int, chamfer=chamfer_foldover, orient=BOTTOM, excess=0);
  }
}

module mask_half_gap(ext) {
  gap = [
    ext.x + ext.z / 2,
    ext.y,
    gap_half / 2,
  ];

  translate(v=[-ext.z / 4, 0, -gap.z / 2]) {
    dy = 3 * t_side;
    cube(size=gap - [0, dy, 0], center=true);

    dx = (3 * t_wall);
    translate(v=[0, 0, 0])
      cube(size=gap - [dx + 0, 0, 0], center=true);
  }
}

module mask_magnet(ext) {
  inset = [(ext.x - t_magnet) / 2, (ext.y - t_side - chamfer_int) / 2, -( -ext.z + t_wall + chamfer_int) / 2];

  for (i = [-1, 1])
    translate(v=vector_multiply_vector(inset, [1, i, 1]))
      rotate(a=90, v=[0, 0, 1])
        teardrop(h=t_magnet, d=d_magnet, orient=DOWN, ang=45);
}

module mask_hinge(ext) {
  tr = [
    ext.x / 2 + dx_hinge,
    (ext.y - t_side - chamfer_int) / 2,
    -ext_main.z / 2 + dz_hinge,
  ];

  for (i = [-1, 1]) {
    translate(v=vector_multiply_vector(tr, [1, i, 1])) {
      translate(v=[-l_hinge / 4 + 0, 0, 0])
        rotate(a=90, v=[0, 0, 1])
          teardrop(h=l_hinge / 2, d=d_hinge, ang=60);
      sphere(d=d_hinge);
    }
  }
}

module mask_pins(ext, int) {
  for (i = [-1, 1]) {
    for (x = [-ext.x / 2 + d_pin / 2, 0, ext.x / 2 - w_foldover * 2]) {
      translate(v=[x, i * (ext.y + int.y) / 4, -l_pin / 4])
        cylinder(d=d_pin, h=l_pin / 2, center=true);
    }
  }
}

module mask_liner_holes_long(ext, int) {
  dy = (int.y) / 2 - chamfer_int - hole_liner_d / 2;
  dz = -(int.z + t_wall) / 2;
  x0 = -ext.x / 2;
  x1 = ext.x / 2 - hole_stitch_inset - hole_stitch_spacing * 2;

  for (i = [-1, 1]) {
    translate(v=[0, i * dy, 0]) {

      // long channels
      for (zc = [-ext.z / 2, -ext.z / 2 + t_wall]) {
        translate(v=[-ext.x / 2 + (x1 - x0) / 2, 0, zc])
          rotate(a=45, v=[1, 0, 0])
            cube(size=[x1 - x0, channel_liner_xy, channel_liner_xy], center=true);
      }

      // long holes
      for (dx = [x0:hole_stitch_spacing:x1]) {
        translate(v=[dx, 0, dz])
          cylinder(d=hole_liner_d, h=t_wall, center=true);
      }
    }
  }
}

module mask_liner_holes_quartercircle(ext, int) {
  dx = -ext.x / 2;
  dy = (int.y) / 2 - chamfer_int - hole_liner_d / 2;
  dz = (int.z + t_wall) / 2;

  for (a = [0:a_end_quant:90 - a_end_quant])
    for (i = [-1, 1])
      translate(v=[dx, i * dy, 0])
        rotate(a=a, v=[0, 1, 0])
          translate(v=[0, 0, -dz])
            cylinder(d=hole_liner_d, h=t_wall * 2, center=true);
}

module shell_end(ext, int) {

  module mask_stitches() {
    dx = -ext.x / 2;
    dy = (ext.y) / 2 - hole_stitch_inset / 2 + t_leather / 2;
    dz = (ext.z) / 2 - hole_stitch_inset / 2 + t_leather / 2;

    for (i = [-1, 1]) {
      translate(v=[dx, 0, 0])
        mask_stitches_quartercircle(ax=i * 45, ay=0, az=0, dy=i * dy, dz=dz);
    }
  }

  module mask_int() {
    translate(v=[-int.x / 2, 0, 0])
      rotate(a=90, v=[1, 0, 0])
        cyl(h=int.y, d=int.z, chamfer=chamfer_int);
  }

  module body() {
    translate(v=[-ext.x / 2, 0, 0])
      rotate(a=90, v=[1, 0, 0])
        front_half()
          left_half()
            cyl(d=ext.z, h=ext.y, chamfer=chamfer_outer);
  }

  difference() {
    body();

    if (debug_int) #mask_int(); else mask_int();

    mask_stitches();
  }
}

module shell_long(ext, int) {

  module mask_stitches() {
    dy = (ext.y - hole_stitch_inset + t_leather) / 2;
    dz = -(ext.z - hole_stitch_inset + t_leather) / 2;

    for (i = [-1, 1]) {
      translate(v=[0, i * dy, dz])
        mask_stitches_long(ax=i * -45, az=0, x0=-ext.x / 2, x1=ext.x / 2);

      mask_stitches_deep(ext=ext, ay=90, dy=i * (ext.y - t_side + t_foldover) / 2);
    }

    mask_stitches_wide(ext=ext, az=90, dx=ext.x / 2 - hole_stitch_inset, dz=( -ext.z + t_wall - t_foldover) / 2);
  }

  module mask_int() {
    translate(v=[0, 0, -int.z / 4])
      cuboid(
        size=[int.x, int.y, int.z / 2],
        chamfer=chamfer_int,
        edges=[
          BOTTOM + FRONT,
          BOTTOM + BACK,
        ],
      );
  }

  module body() {
    translate(v=[0, 0, -ext.z / 4])
      cuboid(
        size=[ext.x, ext.y, ext.z / 2],
        chamfer=chamfer_outer,
        edges=[
          BOTTOM + FRONT,
          BOTTOM + BACK,
        ],
      );
  }

  difference() {
    body();

    if (debug_int) #mask_int(); else mask_int();

    mask_stitches();
  }
}

module shell_main() {
  ext = ext_main;
  int = int_main;

  difference() {
    union() {
      shell_end(ext=ext_main, int=int);
      shell_long(ext=ext_main, int=int);
    }

    if (debug_holes) #mask_liner_holes_long(ext=ext, int=int); else mask_liner_holes_long(ext=ext, int=int);

    if (debug_holes) #mask_liner_holes_quartercircle(ext=ext, int=int); else mask_liner_holes_quartercircle(ext=ext, int=int);

    if (debug_gaps) #mask_half_gap(ext=ext); else mask_half_gap(ext=ext);

    if (debug_holes) #mask_pins(ext=ext, int=int); else mask_pins(ext=ext, int=int);

    if (debug_gaps) #mask_foldover(ext=ext, int=int, w_foldover=w_foldover, t_foldover=t_foldover); else mask_foldover(ext=ext, int=int, w_foldover=w_foldover, t_foldover=t_foldover);
  }
}

module shell_lid() {
  ext = ext_lid;
  int = int_lid;

  difference() {
    union() {
      shell_end(ext=ext, int=int);
      if (debug_lid_long) #shell_long(ext=ext, int=int); else shell_long(ext=ext, int=int);
    }

    if (debug_gaps) #mask_foldover(ext=ext, int=int, w_foldover=0, t_foldover=0); else mask_foldover(ext=ext, int=int, w_foldover=0, t_foldover=0);
  }
}

module lid() {
  difference() {
    union() {
      shell_lid();
      mirror(v=[0, 0, 1])
        shell_lid();
    }

    if (debug_magnet) #mask_magnet(ext=ext_lid); else mask_magnet(ext=ext_lid);

    if (debug_hinge) #mask_hinge(ext=ext_lid); else mask_hinge(ext=ext_lid);
  }
}

module lid_position() {
  tr = [-ext_lid.x / 2 - dx_hinge, 0, ext_lid.z / 2 - dz_hinge];

  mirror(v=[1, 0, 0])
    translate(v=[-debug_dx_lid + ( -ext_main.x + ext_lid.x) / 2 + tr.x, tr.y, -tr.z])
      rotate(a=-debug_lid_angle, v=[0, 1, 0])
        translate(v=tr)
          children();
}

module lid_leather_wall(cp) {
  ext = ext_lid;
  int = int_lid;

  leather_wall_end(ext=ext, cp=cp, wide_stitches=false);
  leather_wall_long(ext=ext, int=int, cp=cp);
  color(c=cp[1])
    leather_wall_foldover_edge(ext=ext, hinge=true);

  mirror(v=[0, 0, 1]) {
    leather_wall_end(ext=ext, cp=cp, wide_stitches=false);
    leather_wall_long(ext=ext, int=int, cp=cp);
    color(c=cp[0])
      leather_wall_foldover_edge(ext=ext, hinge=false);
  }
}

module front() {
  difference() {
    mirror(v=[0, 0, 1])
      shell_main();

    if (debug_magnet) #mask_magnet(ext=ext_main); else mask_magnet(ext=ext_main);
  }
}

module back() {
  difference() {
    shell_main();

    if (debug_hinge) #mask_hinge(ext=ext_main); else mask_hinge(ext=ext_main);
  }
}

module leather_wall_end(ext, cp, wide_stitches) {
  b_end = [2 * r_end_quant * PI / 4 + t_leather_overhang, ext.y + t_leather_overhang * 2, t_leather];

  module mask_end_stitches_folded() {
    for (i = [-1, 1])
      translate(v=[-ext.x / 2, 0, 0])
        mask_stitches_quartercircle(ax=0, ay=0, az=i * a_stitch, dy=i * (ext.y / 2 - hole_stitch_inset), dz=ext.z / 2);

    if (wide_stitches)
      translate(v=[-ext.x / 2, 0, 0])
        rotate(a=-90 - a_end_quant / 2, v=[0, 1, 0])
          mask_stitches_wide(ext=ext, az=90, dx=0, dz=ext.z / 2);
  }

  module mask_end_stitches_unfolded() {
    x0 = -ext.x / 2 - round_nearest(b_end.x, hole_stitch_spacing);
    x1 = -ext.x / 2;

    for (i = [-1, 1])
      translate(v=[0, i * ( (ext.y) / 2 - hole_stitch_inset), -ext.z / 2])
        mask_stitches_long(ax=0, az=i * a_stitch, x0=x0, x1=x1);

    if (wide_stitches)
      mask_stitches_wide(ext=ext, az=90, dx=-ext.x / 2 - b_end.x + hole_stitch_spacing / 2 + t_leather_overhang, dz=-ext.z / 2);
  }

  module mask_end_stitches() {
    if (fold)
      mask_end_stitches_folded();
    else
      mask_end_stitches_unfolded();
  }

  module end_unfolded() {
    translate(v=[-(ext.x + b_end.x) / 2, 0, 0])
      cube(b_end, center=true);
  }

  module end_folded() {
    translate(v=[-(ext.x) / 2, 0, r_end_quant - t_leather / 2])
      rotate(a=90, v=[1, 0, 0])
        left_half()
          front_half()
            difference() {
              cylinder(h=b_end.y, r=r_end_quant, center=true);
              cylinder(h=b_end.y, r=r_end_quant - t_leather, center=true);
            }
  }

  module end() {
    if (fold)
      end_folded();
    else
      end_unfolded();
  }

  difference() {
    translate(v=[0, 0, ( -ext.z - t_leather) / 2]) {
      color(c=cp[0])
        end();
    }

    mask_end_stitches();
  }
}

module leather_wall_foldover_edge(ext, hinge) {
  b_fedge = [t_wall + t_leather, ext.y + t_leather_overhang * 2];
  p_fedge = poly_foldover_edge(b_fedge);

  folded = [
    (ext.x + t_leather) / 2,
    0,
    ( -ext.z + b_fedge.x) / 2 - t_leather,
  ];
  shifted = [
    (ext.x + b_fedge.x) / 2,
    0,
    ( -ext.z - t_leather) / 2,
  ];

  // fold, mask, unfold if necessary
  translate(v=fold ? [0, 0, 0] : shifted)
    rotate(a=fold ? 0 : 90, v=[0, 1, 0])
      translate(v=fold ? [0, 0, 0] : -folded)
        difference() {
          translate(v=folded)
            rotate(a=-90, v=[0, 1, 0])
              linear_extrude(h=t_leather, center=true)
                polygon(p_fedge);
          if (hinge)
            mask_hinge(ext=ext);
        }
}

module leather_wall_foldover_inner(ext, int) {
  b_finner = [w_foldover, int.y, t_leather];

  folded = [
    (ext.x + b_finner.x) / 2 - b_finner.x,
    0,
    ( -ext.z + b_finner.z) / 2 + t_wall - t_foldover,
  ];
  shifted = [
    (ext.x + b_finner.x) / 2 + t_wall - t_foldover + t_leather * 2,
    0,
    ( -ext.z - b_finner.z) / 2,
  ];

  translate(v=fold ? [0, 0, 0] : shifted)
    rotate(a=fold ? 0 : 180, v=[0, 1, 0])
      translate(v=fold ? [0, 0, 0] : -folded)
        difference() {
          translate(v=folded)
            cube(b_finner, center=true);
          mask_stitches_wide(ext=ext, az=-a_stitch, dx=ext.x / 2 - hole_stitch_inset, dz=( -ext.z + t_wall) / 2);
        }
}

module leather_wall_long(ext, int, cp) {

  module mask_stitches() {
    x0 = -ext.x / 2;
    x1 = ext.x / 2;

    for (i = [-1, 1])
      translate(v=[0, i * ( (ext.y) / 2 - hole_stitch_inset), -ext.z / 2])
        mask_stitches_long(ax=0, az=i * a_stitch, x0=x0, x1=x1);

    mask_stitches_wide(ext=ext, az=a_stitch, dx=ext.x / 2 - hole_stitch_inset, dz=-ext.z / 2);
  }

  module body() {
    translate(v=[0, 0, ( -ext.z - t_leather) / 2])
      cube([ext.x, ext.y + t_leather_overhang * 2, t_leather], center=true);
  }

  difference() {
    color(c=cp[1])
      body();

    mask_stitches();
  }
}

module leather_wall_front(cp) {
  ext = ext_main;
  int = int_main;

  mirror(v=[0, 0, 1]) {
    leather_wall_end(ext=ext, cp=cp, wide_stitches=true);
    leather_wall_long(ext=ext, int=int, cp=cp);

    color(c=cp[0])
      leather_wall_foldover_edge(ext=ext, hinge=false);

    color(c=cp[1])
      leather_wall_foldover_inner(ext=ext, int=int);
  }
}

module leather_wall_back(cp) {
  ext = ext_main;
  int = int_main;

  leather_wall_end(ext=ext, cp=cp, wide_stitches=true);
  leather_wall_long(ext=ext, int=int, cp=cp);

  color(c=cp[0])
    leather_wall_foldover_edge(ext=ext, hinge=true);

  color(c=cp[1])
    leather_wall_foldover_inner(ext=ext, int=int);
}

module foldover_edge(ext) {
  b_fedge = [t_side + t_leather, ext.z + t_leather_overhang * 2];
  p_fedge = poly_foldover_edge(b_fedge);

  folded = [
    (ext.x + t_leather) / 2,
    (ext.y - b_fedge.x) / 2 + t_leather,
    0,
  ];
  shifted = [
    (ext.x + b_fedge.x) / 2,
    (ext.y + t_leather) / 2,
    0,
  ];

  // fold, mask, unfold if necessary
  translate(v=fold ? [0, 0, 0] : shifted)
    rotate(a=fold ? 0 : 90, v=[0, 0, 1])
      translate(v=fold ? [0, 0, 0] : -folded)
        difference() {
          translate(v=folded)
            rotate(a=-90, v=[0, 0, 1])
              rotate(a=90, v=[1, 0, 0])
                linear_extrude(h=t_leather, center=true)
                  polygon(p_fedge);
          mask_hinge(ext=ext);
        }
}

module foldover_inner(ext, int) {
  b_finner = [w_foldover, t_leather, int.z];

  b_fedge = [t_side + t_leather, ext.z + t_leather_overhang * 2];
  p_fedge = poly_foldover_edge(b_fedge);

  folded = [
    (ext.x + b_finner.x) / 2 - b_finner.x,
    (ext.y - b_finner.y) / 2 - t_side + t_foldover,
    0,
  ];
  shifted = [
    (ext.x + b_finner.x) / 2 + t_wall - t_foldover + t_leather * 2,
    (ext.y + t_leather) / 2,
    0,
  ];

  translate(v=fold ? [0, 0, 0] : shifted)
    rotate(a=fold ? 0 : 180, v=[0, 1, 0])
      translate(v=fold ? [0, 0, 0] : -folded)
        difference() {
          translate(v=folded)
            cube(b_finner, center=true);
          mask_stitches_deep(ext=ext, ay=fold ? -a_stitch : a_stitch, dy=(ext.y - t_side) / 2);
        }
}

module leather_side(ext, int, cp) {
  d = ext.z + t_leather_overhang * 2;

  dz_stitch = ext.z / 2 - hole_stitch_inset;

  module mask_stitches() {
    for (i = [-1, 1])
      translate(v=[0, ext.y / 2, i * dz_stitch])
        rotate(a=-90, v=[1, 0, 0])
          mask_stitches_long(ax=0, az=i * a_stitch, x0=-ext.x / 2, x1=ext.x / 2);

    translate(v=[-ext.x / 2, 0, 0]) {
      mask_stitches_quartercircle(ax=90, ay=-a_stitch, az=0, dy=ext.y / 2, dz=dz_stitch);
      mirror(v=[0, 0, 1])
        mask_stitches_quartercircle(ax=90, ay=-a_stitch, az=0, dy=ext.y / 2, dz=dz_stitch);
    }

    mask_stitches_deep(ext=ext, ay=a_stitch, dy=ext.y / 2);
  }

  module body() {
    translate(v=[0, (ext.y + t_leather) / 2, 0]) {
      cube([ext.x, t_leather, d], center=true);

      translate(v=[-ext.x / 2, 0, 0])
        rotate(a=90, v=[1, 0, 0])
          left_half()
            cyl(h=t_leather, d=d, center=true);
    }
  }

  difference() {
    color(c=cp[1])
      body();

    mask_stitches();
  }
}

module leather_side_main(cp) {
  ext = ext_main;
  int = int_main;

  leather_side(ext=ext, int=int, cp=cp);

  color(c=cp[0])
    foldover_edge(ext=ext);

  color(c=cp[1])
    foldover_inner(ext=ext, int=int);
}

module leather_side_lid(cp) {
  ext = ext_lid;
  int = int_lid;

  leather_side(ext=ext, int=int, cp=cp);

  color(c=cp[0])
    foldover_edge(ext=ext);
}

module liner_template(int, cp) {

  module straight() {
    translate(v=[0, 0, -(int.z - t_liner) / 2])
      cube(size=[int.x, int.y, t_liner], center=true);

    if (fold) {
      translate(v=[-int.x / 2, 0, 0])
        rotate(a=90, v=[1, 0, 0])
          left_half()
            front_half()
              difference() {
                cylinder(d=int.z, h=int.y, center=true);
                cylinder(d=int.z - 2 * t_liner, h=int.y, center=true);
              }
    } else {
      x = int.z * PI / 4;
      translate(v=[-(int.x + x) / 2, 0, -(int.z - t_liner) / 2])
        cube(size=[x, int.y, t_liner], center=true);
    }
  }

  module side() {
    module body() {
      cube(size=[int.x, int.z / 2, t_liner], center=true);
      translate(v=[-int.x / 2, -int.z / 4, 0])
        left_half()
          back_half()
            cylinder(d=int.z, h=t_liner, center=true);
    }

    if (fold) {
      translate(v=[0, (int.y - t_liner) / 2, -int.z / 4])
        rotate(a=-90, v=[1, 0, 0])
          body();
    } else {
      translate(v=[0, -int.y / 2 - int.z / 4, -(int.z - t_liner) / 2]) {
        body();
      }
    }
  }

  color(c=cp[0])
    straight();

  color(c=cp[1]) {
    side();
    mirror(v=[0, 1, 0])
      side();
  }
}

render() {
  if (show_back)
    color(c="lightskyblue")
      back();

  if (show_front)
    color(c="royalblue")
      front();

  if (show_leather_main_back)
    leather_wall_back(cp=brown_pair(1));

  if (show_leather_main_front)
    leather_wall_front(cp=brown_pair(0));

  if (show_leather_main_left)
    mirror(v=[0, 1, 0])
      leather_side_main(cp=brown_pair(2));

  if (show_leather_main_right)
    leather_side_main(cp=brown_pair(3));

  lid_position() {
    if (show_lid)
      color(c="slateblue")
        lid();

    if (show_leather_lid_wall)
      lid_leather_wall(cp=brown_pair(4));

    if (show_leather_lid_left)
      mirror(v=[0, 1, 0])
        leather_side_lid(cp=brown_pair(5));

    if (show_leather_lid_right)
      leather_side_lid(cp=brown_pair(6));
  }

  if (show_liner_template)
    liner_template(int=int_main, cp=brown_pair(11));
}
