include <BOSL2/std.scad>
include <lib/geom.scad>
include <lib/colours.scad>

/* [Show] */
show_lid = false;
show_back = false;
show_front = true;
show_leather_front = true;
show_leather_back = false;
show_leather_side_left = false;
show_leather_side_right = false;
fold_leather = true;

/* [Debug] */
debug_gaps = false;
debug_holes = false;
debug_int = false;

/* [Dimensions] */

// interior target
// x excludes the rounded ends
// x, y quantized for linear hole spacing
// z quantized for curved hole spacing, arc outside of leather
int_target = [132, 70, 35];

t_side = 3.6; // [0:0.05:10]
t_wall = 2.4; // [0:0.05:10]

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

// quantize external x - linear
x_quant = round_num(int_target.x, hole_stitch_spacing) - hole_stitch_spacing + hole_stitch_inset;
echo(x_quant=x_quant);

// quantize external y - linear
y_quant = round_num(int_target.y + 2 * t_side - 2 * hole_stitch_inset, hole_stitch_spacing) + 2 * hole_stitch_inset;
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

module mask_hole_stitch(ax, ay, az) {

  module actual() {
    z_hole = sqrt(2 * hole_stitch_inset ^ 2) + sqrt((2 * hole_stitch_w / 2) ^ 2) + 2 * t_leather * sqrt(2);

    rotate(a=ay, v=[0, 1, 0])
      rotate(a=az, v=[0, 0, 1])
        rotate(a=ax, v=[1, 0, 0])
          cube(size=[hole_stitch_l, hole_stitch_w, z_hole], center=true);
  }

  if (debug_holes)
    #actual();
  else
    actual();
}

// x0 -> x1
module mask_hole_stitchs_long(ax, az, x0, x1) {
  for (dx = [x0:hole_stitch_spacing:x1]) {
    translate(v=[dx, 0, 0]) {
      mask_hole_stitch(ax=ax, ay=0, az=az);
    }
  }
}

module mask_hole_stitchs_foldover_wide(dz) {
  y = ext.y / 2 - hole_stitch_inset - hole_stitch_spacing;

  for (dy = [-y:hole_stitch_spacing:y])
    translate(v=[ext.x / 2 - hole_stitch_inset, dy, dz])
      mask_hole_stitch(ax=0, ay=0, az=90);
}

module mask_hole_stitchs_foldover_deep(dy) {
  z = ext.z / 2 - hole_stitch_inset - hole_stitch_spacing;

  for (dz = [-z:hole_stitch_spacing:z])
    translate(v=[ext.x / 2 - hole_stitch_inset, dy, dz])
      mask_hole_stitch(ax=90, ay=90, az=0);
}

module mask_hole_stitchs_round(ax, ay, dy, dz) {
  for (a = [0:-a_end_quant:-180])
    rotate(a=a, v=[0, 1, 0])
      translate(v=[0, dy, dz])
        mask_hole_stitch(ax=ax, ay=ay, az=0);
}

module mask_shell_hole_stitchs() {
  dy = (ext.y) / 2 - hole_stitch_inset / 2;
  dz = (ext.z) / 2 - hole_stitch_inset / 2;

  for (i = [-1, 1]) {
    for (j = [-1, 1])
      translate(v=[0, i * dy, j * dz])
        mask_hole_stitchs_long(ax=i * j * 45, az=0, x0=-ext.x / 2, x1=ext.x / 2);

    translate(v=[-ext.x / 2, 0, 0])
      mask_hole_stitchs_round(ax=i * 45, ay=0, dy=i * dy, dz=dz);

    mask_hole_stitchs_foldover_wide(dz=i * ext.z / 2);

    mask_hole_stitchs_foldover_deep(dy=i * dy);
  }
}

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

module mask_shell_foldover() {
  mask = [
    w_foldover + 0.001,
    int.y + t_foldover * 2,
    int.z + t_foldover * 2,
  ];

  translate(v=[(ext.x - mask.x) / 2 + 0.001, 0, 0])
    cube(size=mask, center=true);
}

module mask_pins() {
  for (i = [-1, 1]) {
    for (x = [-ext.x / 2, 0, ext.x / 2 - w_foldover * 1.5]) {
      translate(v=[x, i * (ext.y + int.y) / 4, 0])
        cylinder(d=d_pin, h=l_pin, center=true);
    }
  }
}

module shell_ext() {
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

module shell_int() {
  cube(size=int, center=true);

  // lid cylinder
  translate(v=[int.x / 2, 0, 0]) {
    rotate(a=90, v=[1, 0, 0]) {
      cylinder(d=int.z, h=int.y, center=true);
    }
  }

  // body square
  xz = int.z / sqrt(2);
  translate(v=[-int.x / 2, 0, 0])
    rotate(a=45, v=[0, 1, 0])
      cube(size=[xz, int.y, xz], center=true);
}

module shell() {
  difference() {
    shell_ext();

    if (debug_int)
      #shell_int();
    else
      shell_int();
  }
}

module body() {
  difference() {
    shell();

    if (debug_gaps)
      #mask_half_gap();
    else
      mask_half_gap();

    if (debug_gaps)
      #mask_shell_foldover();
    else
      mask_shell_foldover();

    if (debug_holes)
      #mask_pins();
    else
      mask_pins();

    mask_shell_hole_stitchs();
  }
}

module lid() {
  color(c="slateblue")
    right_half(s=ext.y, x=ext.x / 2)
      body();
}

module front() {
  color(c="royalblue")
    top_half(s=ext.x + ext.z, z=0)
      left_half(s=ext.x + ext.z, x=ext.x / 2)
        body();
}

module back() {
  color(c="lightskyblue")
    bottom_half(s=ext.x + ext.z, z=0)
      left_half(s=ext.x + ext.z, x=ext.x / 2)
        body();
}

module leather_wall(back) {
  color(c=brown_pair(back ? 0 : 1)[back ? 0 : 1])
    mirror(v=[0, 0, back ? 0 : 1])
      translate(v=[0, 0, -(ext.z + leather_wall_flat.z) / 2])
        cube(leather_wall_flat, center=true);

  color(c=brown_pair(back ? 0 : 1)[back ? 1 : 0])
    translate(
      v=[
        -(leather_wall_flat.x + leather_wall_round_quarter.x) / 2,
        0,
        (back ? -1 : 1) * (ext.z + t_leather) / 2,
      ]
    )
      cube(leather_wall_round_quarter, center=true);
}

module mask_leather_side_hole_stitchs(left) {
  dy = (left ? 1 : -1) * ext.y / 2;
  dz = ext.z / 2 - hole_stitch_inset;

  for (i = [-1, 1])
    translate(v=[0, dy, i * dz])
      rotate(a=90, v=[1, 0, 0])
        mask_hole_stitchs_long(ax=0, az=45, x0=-ext.x / 2, x1=ext.x / 2);

  translate(v=[-ext.x / 2, 0, 0])
    mask_hole_stitchs_round(ax=90, ay=-45, dy=dy, dz=dz);

  mask_hole_stitchs_foldover_deep(dy=dy);
}

module leather_side() {
  translate(v=[0, (ext.y + t_leather) / 2, 0]) {
    cube([ext.x, t_leather, leather_side_d], center=true);

    translate(v=[-ext.x / 2, 0, 0])
      rotate(a=90, v=[1, 0, 0])
        cyl(h=t_leather, d=leather_side_d, center=true);
  }
}

module mask_leather_wall_hole_stitchs(az, dz, back) {
  dy = (ext.y) / 2 - hole_stitch_inset;
  dz = (back ? -1 : 1) * ext.z / 2;

  x0 = -ext.x / 2 - round_num(leather_wall_round_quarter.x, hole_stitch_spacing);
  x1 = ext.x / 2;

  for (i = [-1, 1])
    translate(v=[0, i * dy, dz])
      mask_hole_stitchs_long(ax=0, az=i * (back ? 45 : -45), x0=x0, x1=x1);

  mask_hole_stitchs_foldover_wide(dz=dz);
}

module leather_back() {
  difference() {
    leather_wall(back=true);
    mask_leather_wall_hole_stitchs(az=45, back=true);
  }
}

module leather_front() {
  difference() {
    leather_wall(back=false);
    mask_leather_wall_hole_stitchs(az=45, back=false);
  }
}

module leather_side_left() {
  color(c=brown_pair(2)[0]) {
    difference() {
      leather_side();
      mask_leather_side_hole_stitchs(left=true);
    }
  }
}

module leather_side_right() {
  color(c=brown_pair(2)[1]) {
    difference() {
      mirror(v=[0, 1, 0])
        leather_side();
      mask_leather_side_hole_stitchs(left=false);
    }
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

  if (show_leather_front)
    leather_front();

  if (show_leather_back)
    leather_back();

  if (show_leather_side_left)
    leather_side_left();

  if (show_leather_side_right)
    leather_side_right();
}
