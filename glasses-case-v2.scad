include <BOSL2/std.scad>
include <lib/geom.scad>
include <lib/colours.scad>
include <lib/joints.scad>

// TODO
// chamfer final stitch on lid long, missing hole
// smaller final stitch chamfers
// ensure t_leather_overhang functions correctly on ends
// leather lid side rewrite

/* [Show Shell] */
show_back = true;
show_front = false;
show_lid = true;

/* [Show Leather Main] */
show_leather_main_back = true;
show_leather_main_front = false;
show_leather_main_left = true;
show_leather_main_right = false;

/* [Show Leather Lid] */
show_leather_lid_wall = false;
show_leather_lid_left = false;
show_leather_lid_right = false;

/* [Show] */
show_liner_template = false;
show_hinge_jig = false;
fold = true;

/* [Debug] */
debug_dx_lid = 0; // [0:0.1:180]
debug_lid_angle = 0; // [0:1:180]
debug_stitches = false;
debug_hinges = false;
debug_magnets = false;
debug_pins = false;
debug_gaps = false;
debug_foldover = false;
debug_slice = false;
debug_dy_slice = 0; // [-50:0.1:0]
debug_dz_slice = 0; // [-50:0.1:0]

/* [Dimensions] */

// interior target
// x excludes the rounded ends
// x, y quantized for linear hole spacing
// z quantized for curved hole spacing, arc outside of leather
int_main_target = [125, 55, 36];

t_side = 4.0; // [0:0.05:10]
t_wall = 3.5; // [0:0.05:10]

chamfer_ext = 1; // [0:0.05:2]
chamfer_int_main = 2.0; // [0:0.05:5]
chamfer_int_lid = 0.4; // [0:0.05:5]

t_leather = 0.8; // [0.05:0.05:5]
t_leather_overhang = 0.0; // [0:0.05:5]

t_foldover = 1.8; // [0:0.05:15]
w_foldover = 6.5; // [0:0.05:15]

chamfer_foldover = 0.8; // [0:0.05:2]

gap_half = 1; // [0:0.05:5]
gap_inset_w = t_side + chamfer_int_main;
gap_inset_l_end = t_wall + chamfer_int_main;
gap_inset_l_open = w_foldover + chamfer_foldover * 2;

/* [Leather Stitch Holes] */
stitch_l = 3.7; // [0:0.1:5]
stitch_w = 1.7; // [0:0.1:5]

// centre of hole to edge
stitch_inset = 4; // [0:0.1:10]
stitch_spacing = 5.2; // [0:0.1:10]

// sides and wall
a_stitch = -45; // [0:1:90]

// back and front split at end mid
two_piece_wall = false;

/* [Liner Holes] */
sew_d = 1.8;

/* [Pins] */
d_pin = 2.3; // [0:0.05:5]
l_pin = 27; // [0:0.1:50]

/* [Magnets] */
d_magnet_front = 6.2; // [0:0.05:10]
t_magnet_front = 4.15; // [0:0.05:10]

n_magnets_back = 5; // [0:1:5]

magnet_back_disc = true;
d_magnet_back_disc = 4.2; // [0:0.05:10]
t_magnet_back_disc = 3; // [0:0.05:10]

magnet_back_bar = false;
b_magnet_back_bar = [2.2, 10.5, 5];

/* [Hinges] */
d_hinge = 3.55; // [0:0.05:10]
l_hinge = 22.5; // [0:0.05:100]

// shell to shell
clearance_lid = 2.4; // [-1.6:0.05:5]

// shell to shell
clearance_hinge = 2.2; // [-1.6:0.05:5]

// maximum angle lid can open
a_open = 110; // [0:1:180]

a_hinge_main = 2; // [0:1:50]
a_hinge_lid = 14; // [0:1:50]

gap_hinge_jig = 0.3; // [0:0.01:1]

// relative to ext.y/2
y_pivot_hinge = -3; // [0:0.01:5]

// relative to -ext.z/2
z_pivot_hinge = 2.75; // [0:0.01:5]

/* [Template] */
w_template_joiner = 0.4 * 40;
l_template_joiner = 0.4 * 30;
a_template_joiner = 12.5;
g_pin_template_joiner = 0.18; // [0:0.001:2]
g_shoulder_template_joiner = 0.055; // [0:0.001:2]

/* [Tuning] */

$fn = 200;

// quantize external x - linear
x_quant = round_nearest(int_main_target.x, stitch_spacing) - stitch_spacing + stitch_inset;
echo(x_quant=x_quant);

// quantize external y - linear
y_quant = round_nearest(int_main_target.y + 2 * t_side - 2 * stitch_inset, stitch_spacing) + 2 * stitch_inset;
echo(y_quant=y_quant);

// quantize external z - end radius outside of leather
r_end = int_main_target.z / 2 + t_wall + t_leather;
echo(r_end=r_end);

// angle at spacing
a_end = arc_angle(stitch_spacing, r_end);
echo(a_end=a_end);

// round this angle to fit a clean divisor of 180
a_end_quant = 180 / round(180 / a_end);
echo(a_end_quant=a_end_quant);

// new total z
r_end_quant = arc_radius(a_end_quant, stitch_spacing);
echo(r_end_quant=r_end_quant);

ext_main = [x_quant, y_quant, 2 * (r_end_quant - t_leather)];
echo(ext_main=ext_main);

int_main = ext_main - [0, 2 * t_side, 2 * t_wall];
echo(int_main_target=int_main_target);
echo(int_main=int_main);

ext_lid = [stitch_inset + stitch_spacing * 0, ext_main.y, ext_main.z];
echo(ext_lid=ext_lid);

int_lid = ext_lid - [0, 2 * t_side, 2 * t_wall];
echo(int_lid=int_lid);

// relative to +ext.x, -ext.z
pivot_hinge = [clearance_lid / 2, y_pivot_hinge, z_pivot_hinge];
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
hinge_inset_stitches = round_nearest(hinge_inset_dx, stitch_spacing);
echo(hinge_inset_stitches=hinge_inset_stitches);

// TODO remove
dx_magnet_back_disc = magnet_back_disc ? t_magnet_back_disc / 4 / cos(a_open / 2) : 0;
dy_magnet_back_disc = magnet_back_disc ? t_magnet_back_disc / 2 / sin(a_open / 2) : 0;

module dbg_stiches() { if (debug_stitches) #children(); else children(); }
module dbg_hinges() { if (debug_hinges) #children(); else children(); }
module dbg_magnets() { if (debug_magnets) #children(); else children(); }
module dbg_pins() { if (debug_pins) #children(); else children(); }
module dbg_gaps() { if (debug_gaps) #children(); else children(); }
module dbg_foldover() { if (debug_foldover) #children(); else children(); }

module mask_stitch(ax, ay, az) {

  module mask() {
    z_hole = sqrt(2 * stitch_inset ^ 2) + sqrt((2 * stitch_w / 2) ^ 2) + 2 * t_leather * sqrt(2);

    rotate(a=ay, v=[0, 1, 0])
      rotate(a=az, v=[0, 0, 1])
        rotate(a=ax, v=[1, 0, 0])
          cube(size=[stitch_l, stitch_w, z_hole], center=true);
  }

  dbg_stiches() mask();
}

// x0 -> x1
module mask_stitches_long(ax, az, x0, x1) {
  for (dx = [x0:(x0 < x1 ? stitch_spacing : -stitch_spacing):x1]) {
    translate(v=[dx, 0, 0]) {
      mask_stitch(ax=ax, ay=0, az=az);
    }
  }
}

module mask_stitches_wide(ext, az, dx, dz, az) {
  y = ext.y / 2 - stitch_inset - stitch_spacing;

  for (dy = [-y:stitch_spacing:y])
    translate(v=[dx, dy, dz])
      mask_stitch(ax=0, ay=0, az=az);
}

module mask_stitches_deep(ext, ay, dy) {
  z = ext.z / 2 - stitch_inset;

  spacing = z / round_nearest(z, stitch_spacing) * stitch_spacing;

  for (dz = [-z + spacing:spacing:z - spacing / 2]) {
    translate(v=[ext.x / 2 - stitch_inset, dy, dz])
      mask_stitch(ax=90, ay=ay, az=0);
  }
}

module mask_stitches_quartercircle(ax, ay, az, dy, dz, da_start = 0) {
  for (a = [-180 + da_start:a_end_quant:-90]) {
    rotate(a=a, v=[0, 1, 0]) {
      translate(v=[0, dy, dz])
        mask_stitch(ax=ax, ay=(a == -90 ? 0 : ay), az=(a == -90 ? 0 : -az));
    }
  }
}

module mask_foldover_wide(ext, int, w, t) {
  mask = [
    w,
    int.y - chamfer_int_main * 2,
    int.z / 2 + t,
  ];

  translate(v=[(ext.x - mask.x) / 2, 0, -mask.z / 2])
    cube(size=mask, center=true);

  translate(v=[ext.x / 2, 0, -ext.z / 2]) {
    translate(v=[0, 0, t_wall - t])
      chamfer_edge_mask(l=int.y - chamfer_int_main * 2, chamfer=chamfer_foldover, orient=FRONT, excess=0);

    translate(v=[-w, 0, 0]) {
      translate(v=[0, 0, t_wall])
        chamfer_edge_mask(l=int.y - 2 * chamfer_int_main, chamfer=chamfer_foldover, orient=FRONT, excess=0);
    }
  }
}

module mask_foldover_deep(ext, int, w, t) {
  mask = [
    w,
    int.y + t * 2,
    int.z / 2 - chamfer_int_main,
  ];

  translate(v=[(ext.x - mask.x) / 2, 0, -mask.z / 2])
    cube(size=mask, center=true);

  translate(v=[ext.x / 2, 0, 0]) {
    for (i = [-1, 1]) {
      translate(v=[0, i * (ext.y / 2 - t_side + t), 0])
        chamfer_edge_mask(l=int.z - chamfer_int_main * 2, chamfer=chamfer_foldover, orient=BOTTOM, excess=0);

      translate(v=[-w, 0, 0]) {
        translate(v=[0, i * (ext.y / 2 - t_side), 0])
          chamfer_edge_mask(l=int.z - 2 * chamfer_int_main, chamfer=chamfer_foldover, orient=BOTTOM, excess=0);
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
    dy = gap_inset_w * 2;
    cube(size=gap - [0, dy, 0], center=true);

    translate(v=[-gap_inset_l_open / 2 + gap_inset_l_end / 2, 0, 0])
      cube(size=gap - [gap_inset_l_open + gap_inset_l_end + 0.005, 0, 0], center=true);
  }
}

module mask_magnets_front(ext) {
  inset = [(ext.x - t_magnet_front) / 2, (ext.y - t_side - chamfer_int_main) / 2, -( -ext.z + t_wall + chamfer_int_main) / 2];

  for (i = [-1, 1])
    translate(v=vector_multiply_vector(inset, [1, i, 1]))
      rotate(a=90, v=[0, 0, 1])
        teardrop(h=t_magnet_front, d=d_magnet_front, orient=DOWN, ang=55);
}

module mask_magnets_back_bar(ext, int) {
  dy = int.y / (n_magnets_back);

  for (y = [-int.y / 2 + dy / 2:dy:int.y / 2 - dy / 2])
    translate(v=[ext.x / 2 - hinge_inset_dx - stitch_inset / 2, 0, -ext.z / 2])
      translate(v=[0, y, 0])
        rotate(a=a_open / 2, v=[0, 1, 0])
          translate(v=[-b_magnet_back_bar.x / 2, 0, b_magnet_back_bar.z / 2])
            cube(size=b_magnet_back_bar, center=true);
}

module mask_magnets_back_disc(ext, int, dz) {
  dx = -t_magnet_back_disc / 4 / cos(a_open / 2);
  dy = int.y / (n_magnets_back);

  for (y = [-int.y / 2 + dy / 2:dy:int.y / 2 - dy / 2])
    translate(v=[ext.x / 2 - hinge_inset_dx + dx, y, -ext.z / 2 + dz])
      rotate(a=a_open / 2, v=[0, 1, 0])
        rotate(a=90, v=[0, 0, 1])
          teardrop(h=t_magnet_back_disc, d=d_magnet_back_disc, orient=UP, ang=90);
}

module mask_magnets_back(ext, int, dz) {
  if (magnet_back_bar)
    mask_magnets_back_bar(ext, int);

  if (magnet_back_disc)
    mask_magnets_back_disc(ext, int, dz);
}

module mask_hinge_pin(ext, d = d_hinge, ay, teardrop, channel) {
  tr = [
    ext.x / 2 + pivot_hinge.x,
    ext.y / 2 + pivot_hinge.y,
    -ext.z / 2 + pivot_hinge.z,
  ];

  for (i = [-1, 1]) {
    translate(v=vector_multiply_vector(tr, [1, i, 1])) {
      if (channel) {
        color(c="yellow")
          cube(size=[d, d, ext.z * 2], center=true);
      } else {
        color(c="limegreen")
          rotate(a=ay, v=[0, 1, 0])
            translate(v=[-l_hinge / 4 + 0, 0, 0])
              rotate(a=90, v=[0, 0, 1])
                teardrop(h=l_hinge / 2, d=d, ang=(teardrop ? 45 : 90));
      }

      color(c="red")
        sphere(d=d);
    }
  }
}

module mask_hinge_chamfer(ext, int) {

  mask = [
    hinge_inset_dx,
    int.y - chamfer_int_main * 2,
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
      translate(v=[x, i * ext.y / 2 + t_side / 4, -d_pin * 1.5])
        cube(size=[d_pin, t_side / 2, d_pin], center=true);
    }
  }
}

module mask_template_joiner_line(ext) {
  if (!fold && !two_piece_wall)
    for (i = [-1, 1])
      translate(v=[i * l_template_joiner * 2 / 3, 0, -ext.z / 2 - t_leather / 4])
        cube(size=[t_leather / 2, ext.y - stitch_inset * 2, t_leather / 2], center=true);
}

module mask_template_joiner_socket(ext) {
  if (!fold && !two_piece_wall)
    translate(v=[-l_template_joiner / 2, -ext.y / 5, ( -ext.z - t_leather) / 2]) {
      rotate(a=90, v=[0, 0, 1])
        dove_socket(a_tail=a_template_joiner, g_pin=g_pin_template_joiner, l=w_template_joiner, w=l_template_joiner, t=t_leather, l1=ext.y, l2=ext.y, ratio=0);
      translate(v=[-ext.x - l_template_joiner / 2, 0, 0])
        cube(size=[ext.x * 2, ext.y * 2, t_leather], center=true);
    }
  else
    cube(size=[ext.x * 3, ext.y * 2, ext.z * 2], center=true);
}

module mask_template_joiner_tongue(ext) {
  if (!fold && !two_piece_wall)
    translate(v=[l_template_joiner / 2, ext.y / 5, ( -ext.z - t_leather) / 2])
      dove_tail(a_tail=a_template_joiner, g_shoulder=g_shoulder_template_joiner, l=l_template_joiner, w=w_template_joiner, w1=ext.y, w2=ext.y, t=t_leather, l1=ext.x * 2, ratio=0);
  else
    cube(size=[ext.x * 3, ext.y * 2, ext.z * 2], center=true);
}

module template_joiner_tongue(ext, c) {
  if (!fold && !two_piece_wall)
    color(c=c)
      translate(v=[l_template_joiner / 2, ext.y / 5, ( -ext.z - t_leather) / 2])
        dove_tail(a_tail=a_template_joiner, g_shoulder=g_shoulder_template_joiner, l=l_template_joiner, w=w_template_joiner, w1=0, w2=0, t=t_leather, l1=2, ratio=0);
}

module mask_liner_holes_long(ext, int) {
  dy = (int.y) / 2 - chamfer_int_main - sew_d / 2;
  dz = -(int.z + t_wall) / 2;
  x0 = -ext.x / 2;
  x1 = ext.x / 2 - stitch_inset - stitch_spacing * 2;

  // long holes
  for (i = [-1, 1])
    for (dx = [x0:stitch_spacing:x1])
      translate(v=[0, i * dy, 0])
        translate(v=[dx, 0, dz])
          cylinder(d=sew_d, h=t_wall, center=true);
}

module mask_liner_holes_quartercircle(ext, int) {
  dx = -ext.x / 2;
  dy = (int.y) / 2 - chamfer_int_main - sew_d / 2;
  dz = (int.z + t_wall) / 2;

  for (a = [0:a_end_quant:90 - a_end_quant])
    for (i = [-1, 1])
      translate(v=[dx, i * dy, 0])
        rotate(a=a, v=[0, 1, 0])
          translate(v=[0, 0, -dz])
            cylinder(d=sew_d, h=t_wall * 2, center=true);
}

module shell_end(ext, int, chamfer_int, da_stitches_start = 0) {

  module mask_stitches() {
    dx = -ext.x / 2;
    dy = (ext.y) / 2 - stitch_inset / 2 + t_leather / 2;
    dz = (ext.z) / 2 - stitch_inset / 2 + t_leather / 2;

    for (i = [-1, 1]) {
      translate(v=[dx, 0, 0])
        mask_stitches_quartercircle(ax=i * 45, ay=0, az=0, dy=i * dy, dz=dz, da_start=da_stitches_start);
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
            cyl(d=ext.z, h=ext.y, chamfer=chamfer_ext);
  }

  difference() {
    body();

    mask_int();

    mask_stitches();
  }
}

module shell_long(ext, int, hinge, chamfer_int, stitches) {

  module mask_stitches() {
    dyz_long = ( -stitch_inset + t_leather) / 2;
    dyz_end = (stitch_w / 2) / sqrt(2);
    x0 = ext.x / 2 - stitch_inset - stitch_spacing;
    x1 = -ext.x / 2;

    for (i = [-1, 1]) {
      translate(v=[0, i * ext.y / 2, -ext.z / 2]) {
        translate(v=[0, i * dyz_long, -dyz_long])
          mask_stitches_long(ax=i * -45, az=0, x0=x0 - stitch_spacing, x1=x1);

        // last two are partial with the end shaved off
        translate(v=[x0, -i * dyz_end, dyz_end])
          mask_stitch(ax=i * -45, ay=0, az=0);

        translate(v=[x0 + stitch_spacing, -i * dyz_end, dyz_end])
          mask_stitch(ax=i * -45, ay=0, az=0);

        translate(v=[x0 + stitch_spacing + stitch_l, -i * dyz_end, dyz_end])
          mask_stitch(ax=i * -45, ay=0, az=0);
      }

      mask_stitches_deep(ext=ext, ay=90, dy=i * (ext.y - t_side + t_foldover) / 2);
    }

    dx = ext.x / 2 - stitch_inset - (hinge ? hinge_inset_stitches : 0);
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
        chamfer=chamfer_ext,
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

    if (stitches)
      mask_stitches();
  }
}

module shell_main(hinge) {
  difference() {
    union() {
      shell_end(ext=ext_main, int=int_main, chamfer_int=chamfer_int_main);
      shell_long(ext=ext_main, int=int_main, hinge=hinge, chamfer_int=chamfer_int_main, stitches=true);
    }

    mask_liner_holes_long(ext=ext_main, int=int_main);

    mask_liner_holes_quartercircle(ext=ext_main, int=int_main);

    dbg_gaps() mask_half_gap(ext=ext_main);

    dbg_pins() mask_pins(ext=ext_main, int=int_main);
  }
}

module shell_lid_front(cp) {
  difference() {
    union() {
      color(c=cp[0])
        shell_end(ext=ext_lid, int=int_lid, chamfer_int=chamfer_int_lid);
      color(c=cp[1])
        shell_long(ext=ext_lid, int=int_lid, hinge=false, chamfer_int=chamfer_int_lid, stitches=false);
    }

    dbg_foldover() mask_foldover_wide(ext=ext_lid, int=int_lid, w=0, t=t_wall);

    mask_stitches_wide(ext=ext_lid, az=90, dx=ext_lid.x / 2 - stitch_inset, dz=( -ext_lid.z + t_wall - t_foldover) / 2);
  }
}

module shell_lid_back(cp) {
  difference() {
    union() {
      color(c=cp[1])
        shell_end(ext=ext_lid, int=int_lid, chamfer_int=chamfer_int_lid, da_stitches_start=a_end_quant);
      color(c=cp[0])
        shell_long(ext=ext_lid, int=int_lid, hinge=true, chamfer_int=chamfer_int_lid, stitches=false);

      for (i = [-1, 1])
        intersection() {
          translate(v=[-int_lid.z / 2 + int_lid.x / 2, 0, 0])
            cube(size=[int_lid.z, int_lid.y, int_lid.z], center=true);

          l_sheath = l_hinge * 1.4;
          translate(v=[ext_lid.x / 2 + pivot_hinge.x, i * (ext_lid.y / 2 + pivot_hinge.y), -ext_lid.z / 2 + pivot_hinge.z])
            rotate(a=a_hinge_lid - 90, v=[0, 1, 0])
              translate(v=[0, 0, l_sheath / 2])
                cyl(d1=t_side + chamfer_int_main, d2=0, l=l_sheath);
        }
    }

    translate(v=[-hinge_inset_dx, 0, 0])
      dbg_foldover() mask_foldover_wide(ext=ext_lid, int=int_lid, w=0, t=t_wall);

    
    mask_stitches_wide(ext=ext_lid, az=90, dx=ext_lid.x / 2 - stitch_inset - hinge_inset_stitches, dz=( -ext_lid.z + t_wall - t_foldover) / 2);
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

    dbg_magnets() mask_magnets_front(ext=ext_lid);

    dbg_magnets() mask_magnets_back(ext=ext_lid, int=int_lid, dz=t_wall / 2);

    dbg_hinges() mask_hinge_pin(ext=ext_lid, d=d_hinge, ay=a_hinge_lid, teardrop=false);

    dbg_gaps() mask_hinge_chamfer(ext=ext_lid, int=int_lid);

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

  module back() {
    tr_back =
      fold ? [0, 0, 0]
      : [ext.x / 2 + r_end_quant * PI / 2, 0, ext.z + t_leather];

    rotate(a=fold ? 0 : 180, v=[0, 0, 1])
      translate(v=tr_back) {
        difference() {
          leather_wall_end(ext=ext, cp=cp);
          mask_stitches_wide(ext=ext, az=a_stitch, dx=ext.x / 2 - stitch_inset - hinge_inset_stitches, dz=-ext.z / 2);
        }

        translate(v=[-hinge_inset_dx / 4, 0, 0])
          leather_wall_long(
            ext=[ext.x - hinge_inset_dx / 2, ext.y, ext.z],
            cp=cp,
            a_wide=-a_stitch
          );

        leather_wall_foldover(cp=cp, ext=ext, int=int, hinge=true, t_foldover=0, chamfer_int=chamfer_int_lid, a_hinge=a_hinge_lid);
      }
  }

  module front() {
    tr_front =
      fold ? [0, 0, 0]
      : [ext.x / 2 + r_end_quant * PI / 2, 0, 0];

    translate(v=tr_front) {
      mirror(v=[0, 0, 1]) {
        difference() {
          leather_wall_end(ext=ext, cp=cp);
          mask_stitches_wide(ext=ext, az=a_stitch, dx=ext.x / 2 - stitch_inset, dz=-ext.z / 2);
        }
        leather_wall_long(ext=ext, cp=cp, a_wide=a_stitch);

        leather_wall_foldover(cp=cp, ext=ext, int=int, hinge=false, t_foldover=0, chamfer_int=chamfer_int_lid, a_hinge=a_hinge_lid);
      }
    }
  }

  // approximate, a bit long, needs manually marked holes
  module interior(cp) {
    s = [
      int.z * PI / 2 - hinge_inset_stitches,
      int.y - chamfer_int_lid,
      t_leather,
    ];

    color(c=cp[0])
      translate(
        v=[
          s.x / 2 + r_end_quant * PI / 2 + int.x + t_leather + t_wall + w_foldover + t_leather,
          0,
          (ext.z + s.z) / 2,
        ]
      )
        cube(size=s, center=true);
  }

  front();

  back();

  if (!fold)
    interior(cp=cp);
}

module front() {
  difference() {
    mirror(v=[0, 0, 1])
      shell_main(hinge=false);

    dbg_magnets() mask_magnets_front(ext=ext_main);

    mirror(v=[0, 0, 1]) {
      dbg_foldover() mask_foldover_wide(ext=ext_main, int=int_main, w=w_foldover, t=t_foldover);

      dbg_foldover() mask_foldover_deep(ext=ext_main, int=int_main, w=w_foldover, t=t_foldover);
    }
  }
}

module back() {
  difference() {
    shell_main(hinge=true);

    dbg_hinges() mask_hinge_pin(ext=ext_main, d=d_hinge, ay=a_hinge_main, teardrop=true);

    dbg_gaps() mask_hinge_chamfer(ext=ext_main, int=int_main);

    dbg_magnets() mask_magnets_back(ext=ext_main, int=int_main, dz=t_foldover / 2);

    translate(v=[-hinge_inset_dx, 0, 0]) {
      dbg_foldover() mask_foldover_wide(ext=ext_main, int=int_main, w=w_foldover, t=t_foldover);
      dbg_foldover() mask_foldover_wide(ext=ext_main, int=int_main, w=0, t=t_wall);
    }

    dbg_foldover() mask_foldover_deep(ext=ext_main, int=int_main, w=w_foldover, t=t_foldover);
  }
}

module leather_wall_end(ext, cp) {
  b_end = [2 * r_end_quant * PI / 4 + t_leather_overhang, ext.y + t_leather_overhang * 2, t_leather];

  module mask_end_stitches_folded() {
    for (i = [-1, 1])
      translate(v=[-ext.x / 2, 0, 0])
        mask_stitches_quartercircle(ax=0, ay=0, az=i * a_stitch, dy=i * (ext.y / 2 - stitch_inset), dz=ext.z / 2);

    if (two_piece_wall)
      translate(v=[-ext.x / 2, 0, 0])
        rotate(a=-90 - a_end_quant / 2, v=[0, 1, 0])
          mask_stitches_wide(ext=ext, az=90, dx=0, dz=ext.z / 2);
  }

  module mask_end_stitches_unfolded() {
    x0 = -ext.x / 2 - round_nearest(b_end.x, stitch_spacing);
    x1 = -ext.x / 2;

    for (i = [-1, 1])
      translate(v=[0, i * ( (ext.y) / 2 - stitch_inset), -ext.z / 2])
        mask_stitches_long(ax=0, az=i * a_stitch, x0=x0, x1=x1);

    if (two_piece_wall)
      mask_stitches_wide(ext=ext, az=90, dx=-ext.x / 2 - b_end.x + stitch_spacing / 2 + t_leather_overhang, dz=-ext.z / 2);
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

module leather_wall_foldover(cp, ext, int, hinge, t_foldover, chamfer_int, a_hinge) {
  y_edge_bottom = ext.y + t_leather_overhang * 2;
  y_edge_top = y_edge_bottom - 2 * t_side - chamfer_int;

  b_fedge = [
    t_wall + chamfer_int / 2,
    y_edge_bottom,
    t_leather,
  ];
  p_fedge = [
    [b_fedge.x / 2, -y_edge_top / 2],
    [b_fedge.x / 2, y_edge_top / 2],
    [-b_fedge.x / 2, y_edge_bottom / 2],
    [-b_fedge.x / 2, -y_edge_bottom / 2],
  ];

  // midway up hinge chamfer
  dx = hinge ? -hinge_inset_dx / 2 : 0;

  // subtract edge overhang
  dw_inner = -chamfer_int / 2 - t_foldover;

  b_finner = [
    w_foldover + t_leather + dw_inner,
    y_edge_top,
    t_leather,
  ];

  module edge() {

    folded = [
      (ext.x + t_leather) / 2 + dx,
      0,
      ( -ext.z + b_fedge.x) / 2,
    ];
    shifted = [
      (ext.x + b_fedge.x) / 2 + dx + t_leather,
      0,
      ( -ext.z - t_leather) / 2,
    ];

    // fold, mask, unfold if necessary
    translate(v=fold ? [0, 0, 0] : shifted)
      rotate(a=fold ? 0 : 90, v=[0, 1, 0])
        translate(v=fold ? [0, 0, 0] : -folded)
          difference() {
            translate(v=folded) {
              difference() {
                rotate(a=-90, v=[0, 1, 0])
                  linear_extrude(h=t_leather, center=true)
                    polygon(p_fedge);
              }
            }
            if (hinge)
              mask_hinge_pin(ext=ext, d=d_hinge, ay=a_hinge, teardrop=false);
          }
  }

  module inner() {

    folded = [
      (ext.x + b_finner.x) / 2 - b_finner.x + t_leather + dw_inner - (hinge ? hinge_inset_dx : 0),
      0,
      ( -ext.z + b_finner.z) / 2 + t_wall - t_foldover,
    ];
    shifted = [
      (ext.x + b_finner.x) / 2 + t_wall + chamfer_int / 2 + t_leather + dx,
      0,
      ( -ext.z - b_finner.z) / 2,
    ];

    translate(v=fold ? [0, 0, 0] : shifted)
      rotate(a=fold ? 0 : 180, v=[0, 1, 0])
        translate(v=fold ? [0, 0, 0] : -folded)
          difference() {
            translate(v=folded)
              cube(b_finner, center=true);
            mask_stitches_wide(ext=ext, az=-a_stitch, dx=ext.x / 2 - stitch_inset + (hinge ? -hinge_inset_stitches : 0), dz=( -ext.z + t_wall) / 2);
          }
  }

  color(c=cp[0])
    edge();

  color(c=cp[1])
    inner();
}

module leather_wall_long(ext, cp, hinge, a_wide) {
  module mask_stitches() {
    x0 = -ext.x / 2;
    x1 = ext.x / 2;

    for (i = [-1, 1])
      translate(v=[0, i * ( (ext.y) / 2 - stitch_inset), -ext.z / 2])
        mask_stitches_long(ax=0, az=i * a_stitch, x0=x0, x1=x1);

    mask_stitches_wide(ext=ext, az=a_wide, dx=ext.x / 2 - stitch_inset + (hinge ? -hinge_inset_stitches : 0), dz=-ext.z / 2);
  }

  module body() {
    // midway up hinge chamfer, overhanging end by 1 leather
    dx = hinge ? -hinge_inset_dx / 2 : 0;
    translate(v=[(dx + t_leather) / 2, 0, ( -ext.z - t_leather) / 2])
      cube([ext.x + dx + t_leather, ext.y + t_leather_overhang * 2, t_leather], center=true);
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

  intersection() {
    difference() {
      rotate(a=fold ? 0 : 180, v=[1, 0, 0])
        rotate(a=fold ? 0 : 180, v=[0, 0, 1])
          translate(v=fold ? [0, 0, 0] : [ext.x / 2 + r_end_quant * PI / 2, 0, 0]) {
            mirror(v=[0, 0, 1]) {
              leather_wall_end(ext=ext_main, cp=cp);
              leather_wall_long(ext=ext_main, cp=cp, hinge=false, a_wide=a_stitch);

              leather_wall_foldover(cp=cp, ext=ext, int=int, hinge=false, t_foldover=t_foldover, chamfer_int=chamfer_int_main, a_hinge=a_hinge_main);
            }
          }

      mask_template_joiner_line(ext);
    }

    mask_template_joiner_tongue(ext);

    mask_template_joiner_socket(ext);
  }

  difference() {
    template_joiner_tongue(ext, c=cp[0]);
    mask_template_joiner_line(ext);
  }
}

module leather_wall_back(cp) {
  ext = ext_main;
  int = int_main;

  intersection() {
    difference() {
      translate(v=fold ? [0, 0, 0] : [ext.x / 2 + r_end_quant * PI / 2, 0, 0]) {
        leather_wall_end(ext=ext, cp=cp);
        leather_wall_long(ext=ext, cp=cp, hinge=true, a_wide=a_stitch);

        leather_wall_foldover(cp=cp, ext=ext, int=int, hinge=true, t_foldover=t_foldover, chamfer_int=chamfer_int_main, a_hinge=a_hinge_main);
      }

      mask_template_joiner_line(ext);
    }

    rotate(a=180, v=[0, 0, 1])
      mask_template_joiner_tongue(ext);

    rotate(a=180, v=[0, 0, 1])
      mask_template_joiner_socket(ext);
  }

  rotate(a=180, v=[0, 0, 1])
    difference() {
      template_joiner_tongue(ext, c=cp[1]);
      mask_template_joiner_line(ext);
    }
}

module leather_side_foldover(cp, ext, int, ay_hinge, chamfer_int) {
  l_out = ext.z + t_leather_overhang * 2;
  l_in = l_out - 2 * t_wall - chamfer_int;

  w_side = t_side + chamfer_int / 2;

  p_fedge = [
    [w_side / 2, -l_in / 2],
    [w_side / 2, l_in / 2],
    [-w_side / 2, l_out / 2],
    [-w_side / 2, -l_out / 2],
  ];

  // subtract edge overhang
  dw_inner = -chamfer_int / 2 - t_foldover;

  b_finner = [
    w_foldover + t_leather + dw_inner,
    t_leather,
    l_in,
  ];

  module edge() {

    folded = [
      (ext.x + t_leather) / 2,
      (ext.y - w_side) / 2,
      0,
    ];
    shifted = [
      (ext.x + w_side) / 2 + t_leather,
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
            mask_hinge_pin(ext=ext, d=d_hinge, ay=ay_hinge, teardrop=false);
          }
  }

  module inner() {
    folded = [
      (ext.x + b_finner.x) / 2 - b_finner.x + dw_inner + t_leather,
      (ext.y - b_finner.y) / 2 - t_side + t_foldover,
      0,
    ];
    shifted = [
      (ext.x + b_finner.x) / 2 + t_side + chamfer_int / 2 + t_leather,
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

  color(c=cp[0])
    edge();

  color(c=cp[1])
    inner();
}

module leather_side(ext, int, cp) {
  d = ext.z + t_leather_overhang * 2;

  dz_stitch = ext.z / 2 - stitch_inset;

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
      translate(v=[t_leather / 2, 0, 0])
        cube([ext.x + t_leather, t_leather, d], center=true);

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

  leather_side_foldover(cp=cp, ext=ext_main, int=int_main, ay_hinge=a_hinge_main, chamfer_int=chamfer_int_main);
}

module leather_main_side_left(cp) {
  leather_main_side(cp);
}

module leather_main_side_right(cp) {
  mirror(v=[0, 1, 0])
    leather_main_side(cp);
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

  // TODO use leather_side_foldover
  color(c=cp[0])
    foldover_edge(ext=ext, ay_hinge=a_hinge_lid, chamfer_int=chamfer_int_main);

  interior();
}

module leather_lid_side_left(cp) {
  leather_lid_side(cp);
}

module leather_lid_side_right(cp) {
  mirror(v=[0, 1, 0])
    leather_lid_side(cp);
}

module liner_template(ext, int, cp) {
  module straight() {
    translate(v=[0, 0, -(int.z - t_leather) / 2])
      cube(size=[int.x, int.y, t_leather], center=true);

    if (fold) {
      translate(v=[-int.x / 2, 0, 0])
        rotate(a=90, v=[1, 0, 0])
          left_half()
            front_half()
              difference() {
                cylinder(d=int.z, h=int.y, center=true);
                cylinder(d=int.z - 2 * t_leather, h=int.y, center=true);
              }
    } else {
      x = int.z * PI / 4;
      translate(v=[-(int.x + x) / 2, 0, -(int.z - t_leather) / 2])
        cube(size=[x, int.y, t_leather], center=true);
    }
  }

  module side() {
    module body() {
      cube(size=[int.x, int.z / 2, t_leather], center=true);
      translate(v=[-int.x / 2, -int.z / 4, 0])
        left_half()
          back_half()
            cylinder(d=int.z, h=t_leather, center=true);
    }

    if (fold) {
      translate(v=[0, (int.y - t_leather) / 2, -int.z / 4])
        rotate(a=-90, v=[1, 0, 0])
          body();
    } else {
      translate(v=[0, -int.y / 2 - int.z / 4, -(int.z - t_leather) / 2]) {
        body();
      }
    }
  }

  module gap_end() {
    b = [t_wall + t_leather, ext.y - gap_inset_w * 2, t_leather];
    if (fold)
      translate(v=[( -int.x - int.z - b.x) / 2 + t_leather, 0, -b.z / 2])
        cube(size=b, center=true);
    else
      translate(v=[( -int.x - b.x - int.z * PI / 2) / 2, 0, ( -int.z + b.z) / 2])
        cube(size=b, center=true);
  }

  module gap_side() {
    b = [ext.x + ext.z / 2 - gap_inset_l_end - gap_inset_l_open, t_side + t_leather, t_leather];
    if (fold)
      translate(v=[-ext.z / 4 - gap_inset_l_open / 2 + gap_inset_l_end / 2, (ext.y - b.y) / 2, -b.z / 2])
        cube(size=b, center=true);
    else
      translate(v=[-ext.z / 4, (int.y + int.z + b.y) / 2, ( -int.z + b.z) / 2])
        cube(size=b, center=true);
  }

  color(c=cp[0])
    straight();

  color(c=cp[1]) {
    side();
    mirror(v=[0, 1, 0])
      side();
  }

  color(c=cp[1]) {
    gap_end();
  }

  color(c=cp[0]) {
    gap_side();
    mirror(v=[0, 1, 0])
      gap_side();
  }
}

module hinge_jig() {
  ext = ext_main;

  body = [d_hinge * 1.5, ext.y + gap_hinge_jig * 2, ext.z];
  side = [body.x * 2, d_hinge * 1.5, body.z];

  difference() {
    translate(v=[ext.x / 2 + body.x / 2, 0, -ext.z / 2 + body.z / 4]) {
      cube(size=body, center=true);

      translate(v=[(body.x - side.x) / 2, 0, 0]) {
        translate(v=[0, (body.y + side.y) / 2, 0])
          cube(size=side, center=true);
        translate(v=[0, -(body.y + side.y) / 2, 0])
          cube(size=side, center=true);
      }
    }

    mask_hinge_pin(ext=ext, d=d_hinge + gap_hinge_jig, ay=-90, teardrop=false, channel=true);
  }
}

module slice() {
  if (debug_slice) {
    bottom_half(z=ext_main.z / 2 + t_leather + debug_dz_slice, s=ext_main.x * 5)
      back_half(y=-ext_main.y / 2 - t_leather_overhang - debug_dy_slice, s=ext_main.x * 5)
        children();
  } else {
    children();
  }
}

render() {
  slice() {
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
      leather_main_side_left(cp=brown_pair(2));

    if (show_leather_main_right)
      leather_main_side_right(cp=brown_pair(3));

    lid_position() {
      if (show_lid)
        lid(cp=["mediumvioletred", "darkviolet"]);

      if (show_leather_lid_wall)
        leather_lid_wall(cp=brown_pair(4));

      if (show_leather_lid_left)
        leather_lid_side_left(cp=brown_pair(5));

      if (show_leather_lid_right)
        leather_lid_side_right(cp=brown_pair(6));
    }

    if (show_liner_template)
      liner_template(ext=ext_main, int=int_main, cp=brown_pair(11));

    if (show_hinge_jig)
      hinge_jig();
  }
}
