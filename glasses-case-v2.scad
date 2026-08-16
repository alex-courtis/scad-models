include <BOSL2/std.scad>
include <lib/geom.scad>
include <lib/colours.scad>

/* [Show] */
show_lid = false;
show_back = true;
show_front = true;
show_leather_wall_front = true;
show_leather_wall_back = false;
show_leather_side_left = true;
show_leather_side_right = false;
fold_leather = true;

/* [Debug] */
debug_gaps = false;
debug_holes = false;
debug_int = false;
debug_magnet = true;
debug_hinge = true;

/* [Dimensions] */

// interior target
// x excludes the rounded ends
// x, y quantized for linear hole spacing
// z quantized for curved hole spacing, arc outside of leather
int_target = [132, 70, 35];

t_side = 5; // [0:0.05:10]
t_wall = 5; // [0:0.05:10]

t_leather = 0.8; // [0:0.05:5]
t_leather_overhang = 0.4; // [0:0.05:5]

t_foldover = 1.2; // [0:0.05:5]
w_foldover = 6; // [0:0.05:5]

gap_half = 1; // [0:0.05:5]

/* [Holes] */
hole_stitch_l = 3.5; // [0:0.1:5]
hole_stitch_w = 1.5; // [0:0.1:5]

// centre of hole to edge
hole_stitch_inset = 4; // [0:0.1:10]
hole_stitch_spacing = 5; // [0:0.1:10]

/* [Pins] */
d_pin = 2.2; // [0:0.05:5]
l_pin = 18; // [0:0.1:50]

/* [Magnets] */
d_magnet = 6; // [0:0.05:10]
t_magnet = 4; // [0:0.05:10]

/* [hinges] */
d_hinge = t_wall; // [0:0.05:10]
l_hinge = 20; // [0:0.05:10]

// quantize external x - linear
x_quant = round_nearest(int_target.x, hole_stitch_spacing) - hole_stitch_spacing + hole_stitch_inset;
echo(x_quant=x_quant);

// quantize external y - linear
y_quant = round_nearest(int_target.y + 2 * t_side - 2 * hole_stitch_inset, hole_stitch_spacing) + 2 * hole_stitch_inset;
echo(y_quant=y_quant);

// quantize external z - end radius outside of leather
r_end = int_target.z / 2 + t_wall + t_leather;
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

ext = [x_quant, y_quant, 2 * (r_end_quant - t_leather)];
echo(ext=ext);

int = [x_quant, y_quant - 2 * t_side, ext.z - 2 * t_wall];
echo(int_target=int_target);
echo(int=int);

leather_wall_flat = [ext.x, ext.y + t_leather_overhang * 2, t_leather];
echo(leather_wall_flat=leather_wall_flat);

leather_wall_round_quarter = [2 * r_end_quant * PI / 4, leather_wall_flat.y, leather_wall_flat.z];
echo(leather_wall_round_quarter=leather_wall_round_quarter);

leather_side_d = ext.z + t_leather_overhang * 2;
echo(leather_side_d=leather_side_d);

$fn = 120;

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

// TODO evenly space
// x0 -> x1
module mask_stitches_long(ax, az, x0, x1) {
  for (dx = [x0:hole_stitch_spacing:x1]) {
    translate(v=[dx, 0, 0]) {
      mask_stitch(ax=ax, ay=0, az=az);
    }
  }
}

module mask_stitches_foldover_wide(dz) {
  y = ext.y / 2 - hole_stitch_inset - hole_stitch_spacing;

  for (dy = [-y:hole_stitch_spacing:y])
    translate(v=[ext.x / 2 - hole_stitch_inset, dy, dz])
      mask_stitch(ax=0, ay=0, az=90);
}

module mask_stitches_foldover_deep(dy) {
  z = ext.z / 2 - hole_stitch_inset - hole_stitch_spacing;

  for (dz = [-z:hole_stitch_spacing:z])
    translate(v=[ext.x / 2 - hole_stitch_inset, dy, dz])
      mask_stitch(ax=90, ay=90, az=0);
}

module mask_stitches_semicircle(ax, ay, dy, dz) {
  for (a = [-180:a_end_quant:0])
    rotate(a=a, v=[0, 1, 0])
      translate(v=[0, dy, dz])
        mask_stitch(ax=ax, ay=ay, az=0);
}

module shell() {

  module mask_half_gap() {
    translate(v=[-ext.z / 4, 0, 0]) {
      gap = [
        ext.x + ext.z / 2,
        ext.y,
        gap_half,
      ];

      dy = 3 * t_side;
      cube(size=gap - [0, dy, 0], center=true);

      dx = (3 * t_wall) / 2;
      translate(v=[dx / 2, 0, 0])
        cube(size=gap - [dx + 0, 0, 0], center=true);
    }
  }

  module mask_stitches() {
    dy = (ext.y) / 2 - hole_stitch_inset / 2;
    dz = (ext.z) / 2 - hole_stitch_inset / 2;

    for (i = [-1, 1]) {
      for (j = [-1, 1])
        translate(v=[0, i * dy, j * dz])
          mask_stitches_long(ax=i * j * 45, az=0, x0=-ext.x / 2, x1=ext.x / 2);

      translate(v=[-ext.x / 2, 0, 0])
        mask_stitches_semicircle(ax=i * 45, ay=0, dy=i * dy, dz=dz);

      mask_stitches_foldover_wide(dz=i * ext.z / 2);

      mask_stitches_foldover_deep(dy=i * dy);
    }
  }

  module mask_foldover() {
    mask_wide = [
      w_foldover,
      int.y + t_foldover * 2,
      int.z,
    ];

    translate(v=[(ext.x - mask_wide.x) / 2, 0, 0])
      cube(size=mask_wide, center=true);

    mask_deep = [
      w_foldover + 0.001,
      int.y,
      int.z + t_foldover * 2,
    ];

    translate(v=[(ext.x - mask_deep.x) / 2 + 0.001, 0, 0])
      cube(size=mask_deep, center=true);
  }

  module mask_pins() {
    for (i = [-1, 1]) {
      for (x = [-ext.x / 2, 0, ext.x / 2 - w_foldover * 1.5]) {
        translate(v=[x, i * (ext.y + int.y) / 4, 0])
          cylinder(d=d_pin, h=l_pin, center=true);
      }
    }
  }

  module mask_magnet() {
    inset = [(ext.x - t_magnet) / 2, (ext.y - d_magnet) / 2, (ext.z - d_magnet) / 2];

    for (i = [-1, 1])
      translate(v=vector_multiply_vector(inset, [1, i, 1]))
        rotate(a=90, v=[0, 1, 0])
          cylinder(h=t_magnet, d=d_magnet, center=true);
  }

  module mask_hinge() {
    inset = [ext.x / 2, (ext.y - t_side) / 2 - t_foldover, -(ext.z - t_wall) / 2 + t_foldover];

    for (i = [-1, 1])
      translate(v=vector_multiply_vector(inset, [1, i, 1]))
        rotate(a=90, v=[0, 1, 0])
          cylinder(h=l_hinge, d=d_hinge, center=true);
  }

  module mask_int() {
    cube(size=int, center=true);

    xz = int.z / sqrt(2);
    translate(v=[-int.x / 2, 0, 0])
      rotate(a=45, v=[0, 1, 0])
        cube(size=[xz, int.y, xz], center=true);
  }

  module body() {
    cube(size=ext, center=true);

    translate(v=[ext.x / 2, 0, 0]) {
      rotate(a=90, v=[1, 0, 0]) {
        cylinder(d=ext.z, h=ext.y, center=true);
      }
    }

    translate(v=[-ext.x / 2, 0, 0]) {
      rotate(a=90, v=[1, 0, 0]) {
        cylinder(d=ext.z, h=ext.y, center=true);
      }
    }
  }

  difference() {
    body();

    if (debug_int) #mask_int(); else mask_int();

    if (debug_gaps) #mask_half_gap(); else mask_half_gap();

    if (debug_gaps) #mask_foldover(); else mask_foldover();

    if (debug_holes) #mask_pins(); else mask_pins();

    if (debug_magnet) #mask_magnet(); else mask_magnet();

    if (debug_hinge) #mask_hinge(); else mask_hinge();

    mask_stitches();
  }
}

module lid() {
  color(c="slateblue")
    right_half(s=ext.y, x=ext.x / 2)
      shell();
}

module front() {
  color(c="royalblue")
    top_half(s=ext.x + ext.z, z=0)
      left_half(s=ext.x + ext.z, x=ext.x / 2)
        shell();
}

module back() {
  color(c="lightskyblue")
    bottom_half(s=ext.x + ext.z, z=0)
      left_half(s=ext.x + ext.z, x=ext.x / 2)
        shell();
}

module leather_wall(back) {
  dz = (back ? -1 : 1) * ext.z / 2;

  module mask_long_stitches() {
    x0 = -ext.x / 2 - round_nearest(leather_wall_round_quarter.x, hole_stitch_spacing);
    x1 = ext.x / 2;

    for (i = [-1, 1])
      translate(v=[0, i * ( (ext.y) / 2 - hole_stitch_inset), dz])
        mask_stitches_long(ax=0, az=i * (back ? 45 : -45), x0=x0, x1=x1);
  }

  module end() {
    translate(v=[-(leather_wall_flat.x + leather_wall_round_quarter.x) / 2, 0, 0])
      cube(leather_wall_round_quarter, center=true);
  }

  module foldover_edge() {
    body = [t_leather, int.y, t_leather + t_wall - t_foldover];

    folded = [
      (ext.x + body.x) / 2,
      0,
      (back ? -1 : 1) * ( (ext.z - body.z) / 2 + t_leather),
    ];
    shifted = [
      (ext.x + body.z) / 2,
      0,
      (back ? -1 : 1) * (ext.z + body.x) / 2,
    ];

    if (fold_leather)
      translate(v=folded)
        cube(body, center=true);
    else
      translate(v=shifted)
        rotate(a=90, v=[0, 1, 0])
          cube(body, center=true);
  }

  module foldover_inner() {
    body = [t_leather + w_foldover, int.y, t_leather];

    folded = [
      (ext.x + body.x) / 2 - body.x + t_leather,
      0,
      (back ? -1 : 1) * ( (ext.z - body.z) / 2 - t_wall + t_foldover),
    ];
    shifted = [
      (ext.x + body.x) / 2 + t_leather + t_foldover,
      0,
      (back ? -1 : 1) * (ext.z + body.z) / 2,
    ];

    translate(v=fold_leather ? [0, 0, 0] : shifted)
      rotate(a=fold_leather ? 0 : 180, v=[0, 1, 0])
        translate(v=fold_leather ? [0, 0, 0] : -folded)
          difference() {
            translate(v=folded)
              cube(body, center=true);
            mask_stitches_foldover_wide(dz=dz);
          }
  }

  difference() {
    translate(v=[0, 0, (back ? -1 : 1) * (ext.z + leather_wall_flat.z) / 2]) {
      color(c=brown_pair(back ? 0 : 1)[back ? 0 : 1])
        cube(leather_wall_flat, center=true);
      color(c=brown_pair(back ? 0 : 1)[back ? 1 : 0])
        end();
    }

    mask_long_stitches();

    mask_stitches_foldover_wide(dz=dz);
  }

  color(c=brown_pair(back ? 0 : 1)[back ? 1 : 0])
    foldover_edge();

  color(c=brown_pair(back ? 0 : 1)[back ? 0 : 1])
    foldover_inner();
}

module leather_side(a, c0, c1) {
  // stitches
  dy = ext.y / 2;
  dz = ext.z / 2 - hole_stitch_inset;

  module mask_long_stitches() {
    for (i = [-1, 1])
      translate(v=[0, dy, i * dz])
        rotate(a=-90, v=[1, 0, 0])
          mask_stitches_long(ax=0, az=a, x0=-ext.x / 2, x1=ext.x / 2);
  }

  module mask_round_stitches() {
    translate(v=[-ext.x / 2, 0, 0])
      mask_stitches_semicircle(ax=90, ay=a, dy=dy, dz=dz);
  }

  module body() {
    translate(v=[0, (ext.y + t_leather) / 2, 0]) {
      cube([ext.x, t_leather, leather_side_d], center=true);

      translate(v=[-ext.x / 2, 0, 0])
        rotate(a=90, v=[1, 0, 0])
          cyl(h=t_leather, d=leather_side_d, center=true);
    }
  }

  difference() {
    color(c=c0)
      body();

    mask_long_stitches();

    mask_round_stitches();

    mask_stitches_foldover_deep(dy=dy);
  }
}

render() {

  if (show_lid)
    translate(v=[20, 0, 0])
      lid();

  if (show_back)
    back();

  if (show_front)
    front();

  if (show_leather_wall_front)
    leather_wall(back=false);

  if (show_leather_wall_back)
    leather_wall(back=true);

  if (show_leather_side_left)
    leather_side(a=-45, c0=brown_pair(2)[0], c1=brown_pair(2)[1]);

  if (show_leather_side_right)
    rotate(a=180, v=[1, 0, 0])
      leather_side(a=45, c0=brown_pair(2)[1], c1=brown_pair(2)[0]);
}
