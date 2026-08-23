include <BOSL2/std.scad>
include <lib/geom.scad>
include <lib/colours.scad>

// TODO 
// shift corner holes in to hit twine in middle
// hinge magnets

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
show_hinges = false;
fold = true;

/* [Debug] */
debug_dx_lid = 0; // [0:0.1:180]
debug_lid_angle = 0; // [0:1:180]
debug_gaps = false;
debug_foldover = false;
debug_holes = false;
debug_magnet = false;
debug_hinge = false;

/* [Dimensions] */

// interior target
// x excludes the rounded ends
// x, y quantized for linear hole spacing
// z quantized for curved hole spacing, arc outside of leather
int_main_target = [132, 70, 36];

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

// shell to shell
clearance_lid = 2.4; // [-1.6:0.05:5]

// shell to shell
clearance_hinge = 2.2; // [-1.6:0.05:5]

// maximum angle lid can open
a_open = 100; // [0:1:180]

a_hinge_main = 6; // [0:1:50]
a_hinge_lid = 13; // [0:1:50]

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

ext_lid = [hole_stitch_inset + hole_stitch_spacing * 0, ext_main.y, ext_main.z];
echo(ext_lid=ext_lid);

int_lid = ext_lid - [0, 2 * t_side, 2 * t_wall];
echo(int_lid=int_lid);

// relative to +ext.x, -ext.z
pivot_hinge = [clearance_lid / 2, 0, (t_wall + chamfer_int) / 2];
echo(pivot_hinge=pivot_hinge);

// relative to pivot_hinge
hinge_chamfer_dz = a_open > 0 ? pivot_hinge.z + clearance_hinge / 2 / sin(a_open / 2) : 0;
echo(hinge_chamfer_dz=hinge_chamfer_dz);
hinge_chamfer_dx = hinge_chamfer_dz * tan(a_open / 2);
echo(hinge_chamfer_dx=hinge_chamfer_dx);

// relative to +ext.x
hinge_inset_dx = max(hinge_chamfer_dx - pivot_hinge.x, 0);
echo(hinge_inset_dx=hinge_inset_dx);
hinge_inset_dz = a_open > 0 ? hinge_inset_dx / tan(a_open / 2) : 0;
echo(hinge_inset_dz=hinge_inset_dz);
hinge_inset_stitches = round_nearest(hinge_inset_dx, hole_stitch_spacing);
echo(hinge_inset_stitches=hinge_inset_stitches);

w_foldover_hinge = w_foldover - hinge_inset_dx + hinge_inset_stitches;
echo(w_foldover_hinge=w_foldover_hinge);

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

module dbg_holes() { if (debug_holes) #children(); else children(); }
module dbg_gaps() { if (debug_gaps) #children(); else children(); }
module dbg_foldover() { if (debug_foldover) #children(); else children(); }
module dbg_hinge() { if (debug_hinge) #children(); else children(); }
module dbg_magnet() { if (debug_magnet) #children(); else children(); }

module mask_stitch(ax, ay, az) {

  module mask() {
    z_hole = sqrt(2 * hole_stitch_inset ^ 2) + sqrt((2 * hole_stitch_w / 2) ^ 2) + 2 * t_leather * sqrt(2);

    rotate(a=ay, v=[0, 1, 0])
      rotate(a=az, v=[0, 0, 1])
        rotate(a=ax, v=[1, 0, 0])
          cube(size=[hole_stitch_l, hole_stitch_w, z_hole], center=true);
  }

  dbg_holes() mask();
}

// x0 -> x1
module mask_stitches_long(ax, az, x0, x1) {
  for (dx = [x0:(x0 < x1 ? hole_stitch_spacing : -hole_stitch_spacing):x1]) {
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

module mask_foldover_wide(ext, int, w, t) {
  mask = [
    w,
    int.y - chamfer_int * 2,
    int.z / 2 + t,
  ];

  translate(v=[(ext.x - mask.x) / 2, 0, -mask.z / 2])
    cube(size=mask, center=true);

  translate(v=[ext.x / 2, 0, -ext.z / 2]) {
    translate(v=[0, 0, t_wall - t])
      chamfer_edge_mask(l=int.y - chamfer_int * 2, chamfer=chamfer_foldover, orient=FRONT, excess=0);

    translate(v=[-w, 0, 0]) {
      translate(v=[0, 0, t_wall])
        chamfer_edge_mask(l=int.y - 2 * chamfer_int, chamfer=chamfer_foldover, orient=FRONT, excess=0);
    }
  }
}

module mask_foldover_deep(ext, int, w, t) {
  mask = [
    w,
    int.y + t * 2,
    int.z / 2 - chamfer_int,
  ];

  translate(v=[(ext.x - mask.x) / 2, 0, -mask.z / 2])
    cube(size=mask, center=true);

  translate(v=[ext.x / 2, 0, 0]) {
    for (i = [-1, 1]) {
      translate(v=[0, i * (ext.y / 2 - t_side + t), 0])
        chamfer_edge_mask(l=int.z - chamfer_int * 2, chamfer=chamfer_foldover, orient=BOTTOM, excess=0);

      translate(v=[-w, 0, 0]) {
        translate(v=[0, i * (ext.y / 2 - t_side), 0])
          chamfer_edge_mask(l=int.z - 2 * chamfer_int, chamfer=chamfer_foldover, orient=BOTTOM, excess=0);
      }
    }
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

module mask_hinge_pin(ext, ay) {
  tr = [
    ext.x / 2 + pivot_hinge.x,
    (ext.y - t_side - chamfer_int) / 2,
    -ext_main.z / 2 + pivot_hinge.z,
  ];

  for (i = [-1, 1]) {
    translate(v=vector_multiply_vector(tr, [1, i, 1])) {
      rotate(a=ay, v=[0, 1, 0])
        translate(v=[-l_hinge / 4 + 0, 0, 0])
          rotate(a=90, v=[0, 0, 1])
            teardrop(h=l_hinge / 2, d=d_hinge, ang=60);
      sphere(d=d_hinge);
    }
  }
}

module mask_hinge_chamfer(ext, int) {

  mask = [
    hinge_inset_dx,
    int.y - chamfer_int * 2,
    ext.z / 2,
  ];

  translate(v=[(ext.x - mask.x) / 2, 0, ( -ext.z + mask.z) / 2])
    cube(size=mask, center=true);

  translate(v=[ext.x / 2, 0, -ext.z / 2]) {
    rotate(a=90, v=[1, 0, 0])
      linear_extrude(h=ext.y, center=true)
        polygon(
          [
            [0, hinge_inset_dz],
            [0, 0],
            [0 - hinge_inset_dx, 0],
          ]
        );
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
      translate(v=[-ext.x / 2 + (x1 - x0) / 2, 0, -ext.z / 2])
        rotate(a=45, v=[1, 0, 0])
          cube(size=[x1 - x0, channel_liner_xy, channel_liner_xy], center=true);

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

    mask_int();

    mask_stitches();
  }
}

module shell_long(ext, int, hinge) {

  module mask_stitches() {
    dy = (ext.y - hole_stitch_inset + t_leather) / 2;
    dz = -(ext.z - hole_stitch_inset + t_leather) / 2;

    for (i = [-1, 1]) {
      translate(v=[0, i * dy, dz])
        mask_stitches_long(ax=i * -45, az=0, x0=ext.x / 2 - hole_stitch_inset, x1=-ext.x / 2);

      mask_stitches_deep(ext=ext, ay=90, dy=i * (ext.y - t_side + t_foldover) / 2);
    }

    dx = ext.x / 2 - hole_stitch_inset - (hinge ? hinge_inset_stitches : 0);
    mask_stitches_wide(ext=ext, az=90, dx=dx, dz=( -ext.z + t_wall - t_foldover) / 2);
  }

  module mask_int() {
    mask = [int.x, int.y, int.z / 2 + 0.0001];
    translate(v=[0, 0, -mask.z / 2 + 0.0001])
      cuboid(
        size=mask,
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
          RIGHT + BACK,
          RIGHT + FRONT,
          RIGHT + BOTTOM,
        ],
      );
  }

  difference() {
    body();

    mask_int();

    mask_stitches();
  }
}

module shell_main(hinge) {
  difference() {
    union() {
      shell_end(ext=ext_main, int=int_main);
      shell_long(ext=ext_main, int=int_main, hinge=hinge);
    }

    dbg_holes() mask_liner_holes_long(ext=ext_main, int=int_main);

    dbg_holes() mask_liner_holes_quartercircle(ext=ext_main, int=int_main);

    dbg_gaps() mask_half_gap(ext=ext_main);

    dbg_holes() mask_pins(ext=ext_main, int=int_main);
  }
}

module shell_lid_front(cp) {
  difference() {
    union() {
      color(c=cp[0])
        shell_end(ext=ext_lid, int=int_lid);
      color(c=cp[1])
        shell_long(ext=ext_lid, int=int_lid, hinge=false);
    }

    dbg_foldover() mask_foldover_wide(ext=ext_lid, int=int_lid, w=0, t=t_wall);

    mask_stitches_wide(ext=ext_lid, az=90, dx=ext_lid.x / 2 - hole_stitch_inset, dz=( -ext_lid.z + t_wall - t_foldover) / 2);
  }
}

module shell_lid_back(cp) {
  difference() {
    union() {
      color(c=cp[1])
        shell_end(ext=ext_lid, int=int_lid);
      color(c=cp[0])
        shell_long(ext=ext_lid, int=int_lid, hinge=true);
    }

    translate(v=[-hinge_inset_dx, 0, 0])
      dbg_foldover() mask_foldover_wide(ext=ext_lid, int=int_lid, w=0, t=t_wall);

    
    mask_stitches_wide(ext=ext_lid, az=90, dx=ext_lid.x / 2 - hole_stitch_inset - hinge_inset_stitches, dz=( -ext_lid.z + t_wall - t_foldover) / 2);
  }
}

module lid(cp) {
  difference() {
    union() {
      mirror(v=[0, 0, 1]) {
        shell_lid_front(cp);
      }
      shell_lid_back(cp);
    }

    dbg_foldover() mask_foldover_deep(ext=ext_lid, int=int_lid, w=0, t=0);

    dbg_magnet() mask_magnet(ext=ext_lid);

    dbg_hinge() mask_hinge_pin(ext=ext_lid, ay=a_hinge_lid);

    dbg_hinge() mask_hinge_chamfer(ext=ext_lid, int=int_lid);

    for (i = [-1, 1])
      mask_stitches_deep(ext=ext_lid, ay=90, dy=i * (ext_lid.y - t_side + t_foldover) / 2);
  }
}

module lid_position() {
  tr = [-ext_lid.x / 2 - pivot_hinge.x, 0, ext_lid.z / 2 - pivot_hinge.z];

  mirror(v=[1, 0, 0])
    translate(v=[-debug_dx_lid + ( -ext_main.x + ext_lid.x) / 2 + tr.x, tr.y, -tr.z])
      rotate(a=-debug_lid_angle, v=[0, 1, 0])
        translate(v=tr)
          children();
}

module leather_lid_wall(cp) {
  ext = ext_lid;
  int = int_lid;

  module exterior_back() {
    tr_back =
      fold ? [0, 0, 0]
      : [hinge_inset_dx - int.z * PI / 2 - ext.x / 2 - t_wall - t_leather * 2, 0, ext.z + t_leather];

    rotate(a=fold ? 0 : 180, v=[0, 0, 1])
      translate(v=tr_back) {
        difference() {
          leather_wall_end(ext=ext, cp=cp, wide_stitches=true);
          mask_stitches_wide(ext=ext, az=-a_stitch, dx=ext.x / 2 - hole_stitch_inset - hinge_inset_stitches, dz=-ext.z / 2);
          translate(v=[ext.x - hinge_inset_dx, 0, 0])
            cube(size=[ext.x, ext.y, ext.z + t_leather * 2], center=true);
        }

        color(c=cp[1])
          leather_wall_foldover_edge(ext=ext, hinge=true, w=t_wall + 2 * t_leather);
      }
  }

  module exterior_front() {
    tr_front =
      fold ? [0, 0, 0]
      : [-ext.x / 2 - t_wall - t_leather * 2 - int.x, 0, 0];

    translate(v=tr_front) {
      mirror(v=[0, 0, 1]) {
        difference() {
          leather_wall_end(ext=ext, cp=cp, wide_stitches=true);
          mask_stitches_wide(ext=ext, az=-a_stitch, dx=ext.x / 2 - hole_stitch_inset, dz=-ext.z / 2);
        }
        leather_wall_long(ext=ext, int=int, cp=cp, a_wide=-a_stitch);

        color(c=cp[0])
          leather_wall_foldover_edge(ext=ext, hinge=false, w=t_wall + 2 * t_leather);
      }
    }
  }

  module interior_front() {
    folded = [0, 0, int.z / 2 - t_leather / 2];
    shifted = [-int.x / 2, 0, (ext.z + t_leather) / 2];

    translate(v=fold ? [0, 0, 0] : shifted)
      rotate(a=fold ? 0 : 180, v=[0, 1, 0])
        translate(v=fold ? [0, 0, 0] : -folded)
          difference() {
            translate(v=folded)
              cube(size=[int.x, int.y, t_leather], center=true);

            mask_stitches_wide(ext=ext, az=a_stitch, dx=ext.x / 2 - hole_stitch_inset, dz=(ext.z - t_wall) / 2);
          }
  }

  module interior_folded() {
    difference() {
      translate(v=[-int.x / 2, 0, 0])
        rotate(a=90, v=[1, 0, 0])
          left_half() {
            difference() {
              cylinder(h=int.y, d=int.z, center=true);
              cylinder(h=int.y * 2, d=int.z - t_leather * 2, center=true);
            }
          }
      mask_stitches_wide(ext=ext, az=a_stitch, dx=ext.x / 2 - hole_stitch_inset, dz=(ext.z - t_wall) / 2);
      mask_stitches_wide(ext=ext, az=a_stitch, dx=ext.x / 2 - hole_stitch_inset - hinge_inset_stitches, dz=-(ext.z) / 2 + t_wall);
    }
  }

  module interior_unfolded() {
    s = [int.z * PI / 2, int.y, t_leather];

    difference() {
      translate(v=[s.x / 2, 0, (ext.z + s.z) / 2]) {
        difference() {
          cube(size=s, center=true);

          mask_stitches_wide(ext=ext, az=-a_stitch, dx=-s.x / 2, dz=0);
          mask_stitches_wide(ext=ext, az=-a_stitch, dx=s.x / 2 - hinge_inset_stitches, dz=0);
        }
      }
    }
  }

  exterior_front();

  exterior_back();

  color(c=cp[1])
    interior_front();

  color(c=cp[0]) {
    if (fold)
      interior_folded();
    else
      interior_unfolded();
  }
}

module front() {
  difference() {
    mirror(v=[0, 0, 1])
      shell_main(hinge=false);

    dbg_magnet() mask_magnet(ext=ext_main);

    mirror(v=[0, 0, 1]) {
      dbg_foldover() mask_foldover_wide(ext=ext_main, int=int_main, w=w_foldover, t=t_foldover);

      dbg_foldover() mask_foldover_deep(ext=ext_main, int=int_main, w=w_foldover, t=t_foldover);
    }
  }
}

module back() {
  difference() {
    shell_main(hinge=true);

    dbg_hinge() mask_hinge_pin(ext=ext_main, ay=a_hinge_main);

    dbg_hinge() mask_hinge_chamfer(ext=ext_main, int=int_main);

    translate(v=[-hinge_inset_dx, 0, 0]) {
      dbg_foldover() mask_foldover_wide(ext=ext_main, int=int_main, w=w_foldover_hinge, t=t_foldover);
      dbg_foldover() mask_foldover_wide(ext=ext_main, int=int_main, w=0, t=t_wall);
    }

    dbg_foldover() mask_foldover_deep(ext=ext_main, int=int_main, w=w_foldover, t=t_foldover);
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

module leather_wall_foldover_edge(ext, hinge, w) {
  dy = hinge ? -2 * (t_side + chamfer_int) : t_leather_overhang * 2;

  b_fedge = [w, ext.y + dy, t_leather];
  p_fedge = poly_foldover_edge(b_fedge);

  dx_hinge = hinge ? -hinge_inset_dx : 0;

  folded = [
    (ext.x + t_leather) / 2 + dx_hinge,
    0,
    ( -ext.z + b_fedge.x) / 2 - t_leather,
  ];
  shifted = [
    (ext.x + b_fedge.x) / 2 + dx_hinge,
    0,
    ( -ext.z - t_leather) / 2,
  ];

  // fold, mask, unfold if necessary
  translate(v=fold ? [0, 0, 0] : shifted)
    rotate(a=fold ? 0 : 90, v=[0, 1, 0])
      translate(v=fold ? [0, 0, 0] : -folded)
        difference() {
          translate(v=folded)
            rotate(a=-90, v=[0, 1, 0]) if (hinge)
              cube(size=b_fedge, center=true);
            else
              linear_extrude(h=t_leather, center=true)
                polygon(p_fedge);
        }
}

module leather_wall_foldover_inner(ext, int, hinge) {
  dx = hinge ? -hinge_inset_dx : 0;

  b_finner = [hinge ? w_foldover_hinge : w_foldover, int.y, t_leather];

  folded = [
    (ext.x + b_finner.x) / 2 - b_finner.x + dx,
    0,
    ( -ext.z + b_finner.z) / 2 + t_wall - t_foldover,
  ];
  shifted = [
    (ext.x + b_finner.x) / 2 + t_wall - t_foldover + t_leather * 2 + dx,
    0,
    ( -ext.z - b_finner.z) / 2,
  ];

  translate(v=fold ? [0, 0, 0] : shifted)
    rotate(a=fold ? 0 : 180, v=[0, 1, 0])
      translate(v=fold ? [0, 0, 0] : -folded)
        difference() {
          translate(v=folded)
            cube(b_finner, center=true);
          mask_stitches_wide(ext=ext, az=-a_stitch, dx=ext.x / 2 - hole_stitch_inset + (hinge ? -hinge_inset_stitches : 0), dz=( -ext.z + t_wall) / 2);
        }
}

module leather_wall_long(ext, int, cp, hinge, a_wide) {
  module mask_stitches() {
    x0 = -ext.x / 2;
    x1 = ext.x / 2;

    for (i = [-1, 1])
      translate(v=[0, i * ( (ext.y) / 2 - hole_stitch_inset), -ext.z / 2])
        mask_stitches_long(ax=0, az=i * a_stitch, x0=x0, x1=x1);

    mask_stitches_wide(ext=ext, az=a_wide, dx=ext.x / 2 - hole_stitch_inset + (hinge ? -hinge_inset_stitches : 0), dz=-ext.z / 2);
  }

  module body() {
    dx = hinge ? -hinge_inset_dx : 0;
    translate(v=[dx / 2, 0, ( -ext.z - t_leather) / 2])
      cube([ext.x + dx, ext.y + t_leather_overhang * 2, t_leather], center=true);
  }

  difference() {
    color(c=cp[1])
      body();

    mask_stitches();
  }
}

module leather_wall_front(cp) {
  mirror(v=[0, 0, 1]) {
    leather_wall_end(ext=ext_main, cp=cp, wide_stitches=true);
    leather_wall_long(ext=ext_main, int=int_main, cp=cp, hinge=false, a_wide=a_stitch);

    color(c=cp[0])
      leather_wall_foldover_edge(ext=ext_main, hinge=false, w=t_wall + t_leather);

    color(c=cp[1])
      leather_wall_foldover_inner(ext=ext_main, int=int_main, hinge=false);
  }
}

module leather_wall_back(cp) {
  leather_wall_end(ext=ext_main, cp=cp, wide_stitches=true);
  leather_wall_long(ext=ext_main, int=int_main, cp=cp, hinge=true, a_wide=a_stitch);

  color(c=cp[0])
    leather_wall_foldover_edge(ext=ext_main, hinge=true, w=t_wall - t_foldover + 2 * t_leather);

  color(c=cp[1])
    leather_wall_foldover_inner(ext=ext_main, int=int_main, hinge=true);
}

module foldover_edge(ext, ay_hinge) {
  b_fedge = [t_side + t_leather * 2, ext.z + t_leather_overhang * 2];
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
          mask_hinge_pin(ext=ext, ay=ay_hinge);
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

module leather_main_side(cp) {
  leather_side(ext=ext_main, int=int_main, cp=cp);

  color(c=cp[0])
    foldover_edge(ext=ext_main, ay_hinge=a_hinge_main);

  color(c=cp[1])
    foldover_inner(ext=ext_main, int=int_main);
}

module leather_lid_side(cp) {
  ext = ext_lid;
  int = int_lid;

  module interior() {
    folded = [0, (int.y - t_leather) / 2, 0];
    shifted = [ext.x + t_side + t_leather * 2, (ext.y + t_leather) / 2, 0];

    translate(v=fold ? [0, 0, 0] : shifted)
      rotate(a=fold ? 0 : 180, v=[0, 0, 1])
        translate(v=fold ? [0, 0, 0] : -folded)
          translate(v=folded)
            difference() {
              union() {
                color(c=cp[1])
                  translate(v=[0, 0, 0])
                    cube(size=[int.x, t_leather, int.z], center=true);

                color(c=cp[0])
                  translate(v=[-int.x / 2, 0, 0])
                    rotate(a=90, v=[1, 0, 0])
                      left_half()
                        cylinder(h=t_leather, d=int.z, center=true);
              }
              mask_stitches_deep(ext=ext, ay=-a_stitch, dy=0);
            }
  }

  leather_side(ext=ext, int=int, cp=cp);

  color(c=cp[0])
    foldover_edge(ext=ext, ay_hinge=a_hinge_lid);

  interior();
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

module hinges() {

  dz_third = 0.05;
  z_third = d_hinge / 3 + dz_third;

  dz_half = 0.05;

  d_core = 2.1;
  l_core = 8.5;

  module pin() {
    difference() {
      union() {
        translate(v=[l_hinge / 4, 0, 0])
          rotate(a=90, v=[0, 1, 0])
            cylinder(h=l_hinge / 2, d=d_hinge, center=true);

        sphere(d=d_hinge);
      }

      cylinder(h=d_hinge, d=d_core, center=true);

      translate(v=[(d_hinge * 3 / 4 + l_hinge / 2) / 2, 0, 0])
        chamfer_edge_mask(l=l_core, chamfer=sqrt(2) * d_core / 2, orient=LEFT, anchor=CENTER, excess=0);
    }
  }

  module male() {
    difference() {
      pin();

      translate(v=[0, 0, d_hinge - z_third])
        cube(size=[d_hinge * 1.5, d_hinge, d_hinge], center=true);

      translate(v=[0, 0, -d_hinge + z_third])
        cube(size=[d_hinge * 1.5, d_hinge, d_hinge], center=true);
    }
  }

  module female() {
    difference() {
      pin();

      cube(size=[d_hinge * 1.5, d_hinge, z_third], center=true);
    }
  }

  module half() {
    difference() {
      pin();

      translate(v=[0, 0, -d_hinge + d_hinge / 2 + dz_half])
        cube(size=[d_hinge * 1.5, d_hinge, d_hinge], center=true);
    }
  }

  top_half(z=dz_half)
    half();

  translate(v=[0, d_hinge * 1.5, 0])
    mirror(v=[0, 0, 1])
      bottom_half(z=dz_half)
        half();

  mirror(v=[1, 0, 0]) {
    translate(v=[0, d_hinge * 3, 0])
      top_half(z=-d_hinge / 2 + z_third)
        male();

    translate(v=[0, d_hinge * 4.5, 0])
      bottom_half(z=-d_hinge / 2 + z_third - 0.00001)
        male();
  }

  translate(v=[0, d_hinge * 6.0, 0])
    bottom_half(z=-z_third / 2 + dz_third)
      female();

  translate(v=[0, d_hinge * 7.5, 0])
    top_half(z=z_third / 2 - dz_third)
      female();

  translate(v=[0, d_hinge * 9.0, 0])
    top_half(z=-z_third / 2 + 0.00001)
      bottom_half(z=z_third / 2 - 0.00001)
        female();
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
    leather_main_side(cp=brown_pair(2));

  if (show_leather_main_right)
    mirror(v=[0, 1, 0])
      leather_main_side(cp=brown_pair(3));

  lid_position() {
    if (show_lid)
      lid(cp=["mediumvioletred", "darkviolet"]);

    if (show_leather_lid_wall)
      leather_lid_wall(cp=brown_pair(4));

    if (show_leather_lid_left)
      leather_lid_side(cp=brown_pair(5));

    if (show_leather_lid_right)
      mirror(v=[0, 1, 0])
        leather_lid_side(cp=brown_pair(6));
  }

  if (show_liner_template)
    translate(v=[-ext_main.x * 2, 0, 0])
      liner_template(int=int_main, cp=brown_pair(11));

  if (show_hinges)
    hinges();
}
