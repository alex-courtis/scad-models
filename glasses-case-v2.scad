include <BOSL2/std.scad>
include <lib/geom.scad>
include <lib/colours.scad>
include <lib/joints.scad>

// TODO
// lid hinge glue leaks - normalise main and lid
// remove lid chamfer

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
show_leather_lid_wall = true;
show_leather_lid_left = true;
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
debug_dx_slice = 0; // [-200:0.1:200]
debug_dy_slice = 0; // [-50:0.1:0]
debug_dz_slice = 0; // [-50:0.1:0]

/* [Dimensions] */

// x excludes the rounded ends
// x, y quantized for linear hole spacing
// z quantized for curved hole spacing, arc outside of leather

int_main_target = [120, 55, 36];

t_side = 4.0; // [0:0.05:10]
t_wall = 3.5; // [0:0.05:10]

chamfer_ext = 0.7; // [0:0.05:5]
chamfer_int_main = 1.6; // [0:0.05:5]
chamfer_int_lid = 0.6; // [0:0.05:5]

// also rounded r=1.5
chamfer_ext_hinge = 2.8; // [0:0.05:5]

t_leather = 0.8; // [0.05:0.05:5]
t_leather_overhang_wall = 0.4; // [0:0.05:5]
t_leather_overhang_side = 0.4; // [0:0.05:5]

t_foldover = 1.8; // [0:0.05:15]
w_foldover = 6.5; // [0:0.05:15]

chamfer_foldover = 0.8; // [0:0.05:2]

n_lid_holes = 1; // [1:1:10]

gap_half = 0.6; // [0:0.05:5]
gap_inset_w = t_side + chamfer_int_main;
gap_inset_l_end = t_wall + chamfer_int_main;
gap_inset_l_open = w_foldover + chamfer_foldover * 2;

/* [Leather Stitch Holes] */
stitch_shell = [3.7, 2.1];
stitch_leather = [3.40, 1.4];

// centre of hole to edge
stitch_inset = 3.6; // [0:0.1:10]
stitch_spacing = 5.2; // [0:0.1:10]

// additional shell inset from edge
shell_stitch_inset = -0.2; // [-10:0.05:10]

// long sides and wall
a_stitch = -45; // [-90:1:90]

// back and front split at end mid
two_piece_wall = false;

/* [Liner Holes] */
d_liner_hole = 1.8;
liner_hole_spacing = 4; // [0:0.1:10]

/* [Pins] */
d_pin = 2.3; // [0:0.05:5]
l_pin = 27; // [0:0.1:50]

/* [Magnets] */
d_magnet_front = 6.25; // [0:0.05:10]
t_magnet_front = 4.30; // [0:0.05:10]

n_magnets_back = 5; // [0:1:5]

da_magnet_back = -10; // [-20:1:20]

magnet_back_disc = true;
d_magnet_back_disc = 5.3; // [0:0.05:10]
t_magnet_back_disc = 2.1; // [0:0.05:10]

magnet_back_bar = false;
b_magnet_back_bar = [2.2, 10.5, 5];

/* [Hinges] */
d_hinge = 3.50; // [0:0.05:10]
dd_hinge_pin_main = 0.05; // [0:0.05:1]
dd_hinge_pin_lid = 0.175; // [0:0.05:1]
dd_hinge_pin_jig = 0.30; // [0:0.05:1]
dr_hinge_pin_shroud = 0.8; // [0:0.05:5]
d_hinge_pin_main = d_hinge + dd_hinge_pin_main;
d_hinge_pin_lid = d_hinge + dd_hinge_pin_lid;
d_hinge_pin_jig = d_hinge + dd_hinge_pin_jig;
d_hinge_pin_shroud = d_hinge + dr_hinge_pin_shroud * 2;

d_hinge_pin_jig_hole = 2.4; // [0:0.05:5]

l_hinge = 20; // [0:0.05:100]
dl_hinge_pin_shell = 1.25; // [0:0.05:5]
dl_hinge_pin_jig = 0.325; // [0:0.05:1]
dl_hinge_pin_shroud = 1.2; // [0:0.05:5]
l_hinge_pin_shell = l_hinge + dl_hinge_pin_shell + d_hinge / 2;
l_hinge_pin_jig = l_hinge + dl_hinge_pin_jig + d_hinge / 2;
l_hinge_pin_shroud = l_hinge_pin_shell + dl_hinge_pin_shroud;

// shell to shell
clearance_lid = 1.6; // [-1.6:0.05:5]

// shell to shell
clearance_hinge = 2.0; // [-1.6:0.05:5]

// maximum angle lid can open
a_open = 110; // [0:1:180]

a_hinge_main = 2; // [0:1:50]
a_hinge_lid = 5; // [0:1:50]

gap_hinge_jig = 0.1; // [0:0.01:1]

// relative to ext.y/2
y_pivot_hinge = -3; // [-10:0.01:10]

// relative to -ext.z/2
z_pivot_hinge = 2.75; // [0:0.01:5]

/* [Template] */
t_template = 1.6; // [0.05:0.05:5]
t_template_line = 0.8; // [0.05:0.05:5]
w_template_joiner = 12; // [0:1:20]
l_template_joiner = 8; // [0:1:20]
a_template_joiner = 12.5; // [1:0.5:40]
g_pin_template_joiner = 0.020; // [0:0.001:0.2]
g_shoulder_template_joiner = 0.040; // [0:0.001:0.2]
r_edge_template_joiner = 0.5; // [0:0.001:2]

l_template_joiner_tail = l_template_joiner - r_edge_template_joiner - g_shoulder_template_joiner / 2;

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

ext_lid = [stitch_inset + stitch_spacing * (n_lid_holes - 1), ext_main.y, ext_main.z];
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

w_foldover_hinge = w_foldover - hinge_inset_dx + hinge_inset_stitches;
echo(w_foldover_hinge=w_foldover_hinge);

magnet_back_dx = -(magnet_back_bar ? b_magnet_back_bar.x : t_magnet_back_disc) / 4 / cos(a_open / 2);
echo(magnet_back_dx=magnet_back_dx);
magnet_back_dy = int_main.y / (n_magnets_back);
echo(magnet_back_dy=magnet_back_dy);

module dbg_stiches() { if (debug_stitches) #children(); else children(); }
module dbg_hinges() { if (debug_hinges) #children(); else children(); }
module dbg_magnets() { if (debug_magnets) #children(); else children(); }
module dbg_pins() { if (debug_pins) #children(); else children(); }
module dbg_gaps() { if (debug_gaps) #children(); else children(); }
module dbg_foldover() { if (debug_foldover) #children(); else children(); }

module mask_stitch(stitch, ax, ay, az) {

  module mask() {
    z_hole = sqrt(2 * stitch_inset ^ 2) + sqrt((2 * stitch.y / 2) ^ 2) + 2 * t_leather * sqrt(2);

    rotate(a=ay, v=[0, 1, 0])
      rotate(a=az, v=[0, 0, 1])
        rotate(a=ax, v=[1, 0, 0])
          cube(size=[stitch.x, stitch.y, z_hole], center=true);
  }

  dbg_stiches() mask();
}

// x0 -> x1
module mask_stitches_long(stitch, ax, az, x0, x1) {
  for (dx = [x0:(x0 < x1 ? stitch_spacing : -stitch_spacing):x1]) {
    translate(v=[dx, 0, 0]) {
      mask_stitch(stitch=stitch, ax=ax, ay=0, az=az);
    }
  }
}

module mask_stitches_wide(stitch, ext, az, dx, dz, az) {
  y = ext.y / 2 - stitch_inset - stitch_spacing;

  translate(v=[dx, 0, dz]) {

    if (stitch == stitch_shell)
      translate(v=[0, -y - stitch.x / 3, 0])
        mask_stitch(stitch=stitch, ax=0, ay=0, az=az);

    for (dy = [-y:stitch_spacing:y])
      translate(v=[0, dy, 0])
        mask_stitch(stitch=stitch, ax=0, ay=0, az=az);

    if (stitch == stitch_shell)
      translate(v=[0, y + stitch.x / 3, 0])
        mask_stitch(stitch=stitch, ax=0, ay=0, az=az);
  }
}

module mask_stitches_deep(stitch, ext, ay, dy) {
  z = ext.z / 2 - stitch_inset;

  spacing = z / round_nearest(z, stitch_spacing) * stitch_spacing;

  translate(v=[ext.x / 2 - stitch_inset, dy, 0]) {
    if (stitch == stitch_shell)
      translate(v=[0, 0, -z + spacing - stitch.x / 3])
        mask_stitch(stitch=stitch, ax=90, ay=ay, az=0);

    for (dz = [-z + spacing:spacing:z - spacing / 2])
      translate(v=[0, 0, dz])
        mask_stitch(stitch=stitch, ax=90, ay=ay, az=0);

    if (stitch == stitch_shell)
      translate(v=[0, 0, z - spacing + stitch.x / 3])
        mask_stitch(stitch=stitch, ax=90, ay=ay, az=0);
  }
}

module mask_stitches_quartercircle(stitch, ax, ay, az, dy, dz, da_start = 0, da_end = 0) {
  for (a = [-180 + da_start:a_end_quant:-90 - da_end]) {
    rotate(a=a, v=[0, 1, 0]) {
      translate(v=[0, dy, dz])
        mask_stitch(stitch=stitch, ax=ax, ay=(a == -90 ? 0 : ay), az=(a == -90 ? 0 : -az));
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

module mask_foldover_deep(ext, int, w, t, hinge) {
  mask = [
    w,
    int.y + t * 2,
    hinge ?
      int.z / 2 - t_side + chamfer_int_main
    : int.z / 2 - chamfer_int_main,
  ];

  translate(v=[(ext.x - mask.x) / 2, 0, -mask.z / 2])
    cube(size=mask, center=true);

  for (i = [-1, 1]) {
    translate(v=[ext.x / 2, 0, 0]) {
      translate(v=[0, i * (ext.y / 2 - t_side + t), -mask.z / 2])
        chamfer_edge_mask(l=mask.z, chamfer=chamfer_foldover, orient=BOTTOM, excess=0);

      translate(v=[-w, 0, 0])
        translate(v=[0, i * (ext.y / 2 - t_side), -mask.z / 2])
          chamfer_edge_mask(l=mask.z, chamfer=chamfer_foldover, orient=BOTTOM, excess=0);

      if (hinge)
        translate(v=[-mask.x / 2, 0, 0])
          translate(
            v=[
              0,
              i * int.y / 2,
              -int.z / 2 + chamfer_int_main * 2,
            ]
          )
            rotate(a=90, v=[0, 1, 0])
              chamfer_edge_mask(l=mask.x, chamfer=chamfer_int_main, orient=BOTTOM, excess=0);
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

module mask_magnets_front(ext, teardrop) {
  inset = [(ext.x - t_magnet_front) / 2, (ext.y - t_side - chamfer_int_main) / 2, -( -ext.z + t_wall + chamfer_int_main) / 2];

  for (i = [-1, 1]) {
    translate(v=vector_multiply_vector(inset, [1, i, 1])) {
      rotate(a=90, v=[0, 0, 1])
        teardrop(h=t_magnet_front, d=d_magnet_front, orient=DOWN, ang=teardrop);
      translate(v=[0, i * d_magnet_front / 4, d_magnet_front / 4])
        cube([t_magnet_front, d_magnet_front / 2, d_magnet_front / 2], center=true);
    }
  }
}

module mask_magnets_back_bar(ext, int, dz) {
  for (y = [-int.y / 2 + magnet_back_dy / 2:magnet_back_dy:int.y / 2 - magnet_back_dy / 2])
    translate(v=[ext.x / 2 - hinge_inset_dx + magnet_back_dx, y, -ext.z / 2 + dz])
      rotate(a=a_open / 2 + da_magnet_back, v=[0, 1, 0])
        cube(size=b_magnet_back_bar, center=true);
}

module mask_magnets_back_disc(ext, int, dz) {
  for (y = [-int.y / 2 + magnet_back_dy / 2:magnet_back_dy:int.y / 2 - magnet_back_dy / 2])
    translate(v=[ext.x / 2 - hinge_inset_dx + magnet_back_dx, y, -ext.z / 2 + dz])
      rotate(a=a_open / 2 + da_magnet_back, v=[0, 1, 0])
        rotate(a=90, v=[0, 0, 1])
          teardrop(h=t_magnet_back_disc, d=d_magnet_back_disc, orient=UP, ang=45);
}

module mask_magnets_back(ext, int, dz) {
  if (magnet_back_bar)
    mask_magnets_back_bar(ext, int, dz);
  else if (magnet_back_disc)
    mask_magnets_back_disc(ext, int, dz);
}

module magnet_shroud_back(ext, int, dz) {
  if (magnet_back_bar || magnet_back_disc) {
    difference() {
      intersection() {
        cube(size=ext, center=true);

        translate(v=[ext.x / 2 - hinge_inset_dx + magnet_back_dx, 0, -ext.z / 2 + dz])
          rotate(a=a_open / 2 + da_magnet_back, v=[0, 1, 0]) {
            cube(
              size=[
                (magnet_back_bar ? b_magnet_back_bar.x : t_magnet_back_disc) * 0.99,
                int.y - chamfer_int_main * 2,
                (magnet_back_bar ? b_magnet_back_bar.z * 0.999 : d_magnet_back_disc),
              ], center=true
            );
          }
      }

      mask_magnets_back(ext, int, dz);
    }
  }
}

module mask_hinge_pin(ext, ay, teardrop, d, l, channel = false) {
  tr = [
    ext.x / 2 + pivot_hinge.x,
    ext.y / 2 + pivot_hinge.y,
    -ext.z / 2 + pivot_hinge.z,
  ];

  for (i = [-1, 1]) {
    translate(v=vector_multiply_vector(tr, [1, i, 1])) {
      rotate(a=ay, v=[0, 1, 0]) {
        if (channel) {
          color(c="yellow")
            cube(size=[l, d, d], center=true);
        } else {
          color(c="limegreen")
            translate(v=[-l / 4 + 0, 0, 0])
              rotate(a=90, v=[0, 0, 1])
                teardrop(h=l / 2, d=d, ang=(teardrop ? 55 : 90));
        }
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

      dr = d_pin / 2 * 0.35;
      translate(v=[x, i * (ext.y + int.y) / 4, -(dr + gap_half) / 2])
        cylinder(d1=d_pin, d2=d_pin + dr * 2, h=dr, center=true);

      translate(v=[x, i * (ext.y / 2 - t_side / 4), -d_pin * 1.5])
        rotate(a=45, v=[0, 1, 0])
          cube(size=[d_pin, t_side / 2, d_pin], center=true);
    }
  }
}

module mask_template_joiner_line(ext) {
  if (!fold && !two_piece_wall)
    for (i = [-1, 1])
      translate(v=[i * l_template_joiner * 2 / 3, 0, -ext.z / 2 + t_template_line / 2 - t_template])
        cube(size=[t_template_line, ext.y - stitch_inset * 4, t_template_line], center=true);
}

module mask_template_joiner_socket(ext) {
  t = (t_template + t_template_line) * 2;
  mirror(v=[1, 0, 0])
    translate(v=[-l_template_joiner / 2, -ext.y / 5, ( -ext.z - t_template) / 2]) {
      rotate(a=90, v=[0, 0, 1])
        dove_socket(
          l=w_template_joiner,
          l_tail=l_template_joiner_tail,
          l1=ext.y,
          l2=ext.y,
          w=l_template_joiner,
          t=t,
          a_tail=a_template_joiner,
          ratio=0,
          g_shoulder=g_shoulder_template_joiner,
          g_pin=g_pin_template_joiner,
          r_edge=r_edge_template_joiner,
        );
      translate(v=[-ext.x - l_template_joiner / 2, 0, 0])
        cube(size=[ext.x * 2, ext.y * 2 + w_template_joiner, t], center=true);
    }
}

module template_joiner_tongue(ext, mask) {
  mirror(v=[1, 0, 0])
    translate(v=[l_template_joiner / 2, ext.y / 5, ( -ext.z - t_template) / 2])
      dove_tail(
        l=l_template_joiner,
        l_tail=l_template_joiner_tail,
        l1=mask ? ext.x * 2 : 2,
        w=w_template_joiner,
        w1=mask ? ext.y : 0,
        w2=mask ? ext.y : 0,
        t=mask ? t_template * 2 : t_template,
        a_tail=a_template_joiner,
        ratio=0,
        g_shoulder=mask ? g_shoulder_template_joiner / 2 : g_shoulder_template_joiner, // only half to the edge as we only want g_shoulder_template_joiner between edges
        r_edge=r_edge_template_joiner,
      );
}

module template_joiners(cp, ext) {
  if (!fold && !two_piece_wall) {
    difference() {
      union() {
        intersection() {
          children();

          template_joiner_tongue(ext=ext, mask=true);

          mask_template_joiner_socket(ext=ext);
        }

        color(c=cp[1])
          template_joiner_tongue(ext=ext);
      }

      mask_template_joiner_line(ext=ext);
    }
  } else {
    children();
  }
}

module mask_liner_holes_long(ext, int, hinge) {
  dy = (int.y) / 2 - chamfer_int_main - d_liner_hole / 2;
  dz = -(int.z + t_wall) / 2;
  x0 = -ext.x / 2;
  x1 = ext.x / 2 - stitch_inset - stitch_spacing * (hinge ? 2 : 1);

  // long holes
  for (i = [-1, 1])
    for (dx = [x0:liner_hole_spacing:x1])
      translate(v=[0, i * dy, 0])
        translate(v=[dx, 0, dz])
          cylinder(d=d_liner_hole, h=t_wall, center=true);
}

module mask_liner_holes_quartercircle(ext, int) {
  dx = -ext.x / 2;
  dy = (int.y) / 2 - chamfer_int_main - d_liner_hole / 2;
  dz = (int.z + t_wall) / 2;

  module hole(a) {
    for (i = [-1, 1])
      translate(v=[dx, i * dy, 0])
        rotate(a=a, v=[0, 1, 0])
          translate(v=[0, 0, -dz])
            cylinder(d=d_liner_hole, h=t_wall * 2, center=true);
  }

  for (a = [0:chord_angle(liner_hole_spacing, int.z / 2):90])
    hole(a);

  hole(90);
}

module mask_chamfer_ext_hinge(ext, l) {
  translate(v=[(ext.x - l) / 2, 0, 0]) {
    rotate(a=90, v=[0, 1, 0]) {
      chamfer_edge_mask(l=l, chamfer=chamfer_ext_hinge, orient=BOTTOM, excess=0);

      rounding_edge_mask(l=l, r=chamfer_ext_hinge * 1.5, orient=BOTTOM, excess=0);
    }
  }
}

module shell_end(ext, int, chamfer_int, da_stitches_start = 0, da_stitches_end = 0) {

  module mask_stitches() {
    dx = -ext.x / 2;
    dy = (ext.y) / 2 - stitch_inset / 2 - shell_stitch_inset / 2;
    dz = (ext.z) / 2 - stitch_inset / 2 - shell_stitch_inset / 2;

    for (i = [-1, 1]) {
      translate(v=[dx, 0, 0])
        mask_stitches_quartercircle(stitch=stitch_shell, ax=i * 45, ay=0, az=0, dy=i * dy, dz=dz, da_start=da_stitches_start, da_end=da_stitches_end);
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
    dyz = -stitch_inset / 2 - shell_stitch_inset / 2;
    x0 = ext.x / 2 - stitch_inset - stitch_spacing - (hinge ? hinge_inset_stitches : 0);
    x1 = -ext.x / 2;
    x_chamfer = ext.x / 2 - x0 - stitch_spacing + stitch_shell.x / 2;

    for (i = [-1, 1]) {
      translate(v=[0, i * ext.y / 2, -ext.z / 2]) {
        if (stitches)
          if (x1 < x0 + stitch_spacing)
            translate(v=[0, i * dyz, -dyz])
              mask_stitches_long(stitch=stitch_shell, ax=i * -45, az=0, x0=x0, x1=x1);

        if (hinge)
          mirror(v=[0, i == 1 ? 1 : 0, 0])
            mask_chamfer_ext_hinge(ext=ext, l=x_chamfer);
      }

      mask_stitches_deep(stitch=stitch_shell, ext=ext, ay=90, dy=i * (ext.y - t_side + t_foldover) / 2);
    }

    dx = ext.x / 2 - stitch_inset - (hinge ? hinge_inset_stitches : 0);
    mask_stitches_wide(stitch=stitch_shell, ext=ext, az=90, dx=dx, dz=( -ext.z + t_wall - t_foldover) / 2);
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

    mask_stitches();
  }
}

module shell_main(hinge) {
  difference() {
    union() {
      shell_end(ext=ext_main, int=int_main, chamfer_int=chamfer_int_main);
      shell_long(ext=ext_main, int=int_main, hinge=hinge, chamfer_int=chamfer_int_main, stitches=true);
    }

    mask_liner_holes_long(ext=ext_main, int=int_main, hinge=hinge);

    mask_liner_holes_quartercircle(ext=ext_main, int=int_main);

    dbg_gaps() mask_half_gap(ext=ext_main);

    dbg_pins() mask_pins(ext=ext_main, int=int_main);
  }
}

module shell_lid_front(cp) {
  difference() {
    union() {
      color(c=cp[0])
        shell_end(ext=ext_lid, int=int_lid, chamfer_int=chamfer_int_lid, da_stitches_start=a_end_quant);
      color(c=cp[1])
        shell_long(ext=ext_lid, int=int_lid, hinge=false, chamfer_int=chamfer_int_lid);
    }

    dbg_foldover() mask_foldover_wide(ext=ext_lid, int=int_lid, w=0, t=t_wall);

    mask_stitches_wide(stitch=stitch_shell, ext=ext_lid, az=90, dx=ext_lid.x / 2 - stitch_inset, dz=( -ext_lid.z + t_wall - t_foldover) / 2);
  }
}

module shell_lid_back(cp) {
  difference() {
    union() {
      color(c=cp[1])
        shell_end(ext=ext_lid, int=int_lid, chamfer_int=chamfer_int_lid, da_stitches_start=a_end_quant * 2);
      color(c=cp[0])
        shell_long(ext=ext_lid, int=int_lid, hinge=true, chamfer_int=chamfer_int_lid);

      for (i = [-1, 1]) {
        intersection() {
          union() {
            cube(size=int_lid, center=true);
            translate(v=[-int_lid.x / 2, 0, 0])
              rotate(a=90, v=[1, 0, 0])
                left_half()
                  cylinder(d=ext_lid.z, h=ext_lid.y, center=true);
          }

          mask_hinge_pin(ext=ext_lid, ay=a_hinge_lid, d=d_hinge_pin_shroud, l=l_hinge_pin_shroud, teardrop=false);
        }
      }
    }

    for (i = [-1, 1])
      translate(v=[-ext_lid.x / 2, i * ext_lid.y / 2, -ext_lid.z / 2])
        mirror(v=[0, i == 1 ? 1 : 0, 0])
          mask_chamfer_ext_hinge(ext=ext_lid, l=ext_lid.z);

    mask_stitches_wide(stitch=stitch_shell, ext=ext_lid, az=90, dx=ext_lid.x / 2 - stitch_inset - hinge_inset_stitches, dz=( -ext_lid.z + t_wall - t_foldover) / 2);
  }
}

module lid(cp) {
  difference() {
    union() {
      mirror(v=[0, 0, 1])
        shell_lid_front(cp);
      shell_lid_back(cp);
    }

    dbg_magnets() mask_magnets_front(ext=ext_lid, teardrop=90);

    dbg_magnets() mask_magnets_back(ext=ext_lid, int=int_lid, dz=t_wall / 2);

    dbg_hinges() mask_hinge_pin(ext=ext_lid, ay=a_hinge_lid, d=d_hinge_pin_lid, l=l_hinge_pin_shell, teardrop=false);

    dbg_gaps() mask_hinge_chamfer(ext=ext_lid, int=int_lid);

    for (i = [-1, 1])
      mask_stitches_deep(stitch=stitch_shell, ext=ext_lid, ay=90, dy=i * (ext_lid.y - t_side + t_foldover) / 2);
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

  t = fold ? t_leather : t_template;

  module back() {
    tr_back =
      fold ? [0, 0, 0]
      : [ext.x / 2 + r_end_quant * PI / 2, 0, ext.z + t];

    rotate(a=fold ? 0 : 180, v=[0, 0, 1])
      translate(v=tr_back) {
        difference() {
          leather_wall_end(ext=ext, cp=cp, az_long=-a_stitch, line=false);
          mask_stitches_wide(stitch=stitch_leather, ext=ext, az=-a_stitch, dx=ext.x / 2 - stitch_inset - hinge_inset_stitches, dz=-ext.z / 2);
        }

        translate(v=[-hinge_inset_dx / 4, 0, 0])
          leather_wall_long(
            ext=[ext.x - hinge_inset_dx / 2, ext.y, ext.z],
            cp=cp,
            az_wide=-a_stitch,
            az_long=-a_stitch,
            line=false,
          );

        leather_wall_foldover(cp=cp, ext=ext, int=int, hinge=true, t_foldover=0, chamfer_int=chamfer_int_main, a_hinge=a_hinge_lid, az_wide=a_stitch);
      }
  }

  module front() {
    tr_front =
      fold ? [0, 0, 0]
      : [ext.x / 2 + r_end_quant * PI / 2, 0, 0];

    translate(v=tr_front) {
      mirror(v=[0, 0, 1]) {
        difference() {
          leather_wall_end(ext=ext, cp=cp, az_long=-a_stitch, line=true);
          mask_stitches_wide(stitch=stitch_leather, ext=ext, az=a_stitch, dx=ext.x / 2 - stitch_inset, dz=-ext.z / 2);
        }
        leather_wall_long(ext=ext, cp=cp, az_wide=a_stitch, az_long=-a_stitch, line=true);

        leather_wall_foldover(cp=cp, ext=ext, int=int, hinge=false, t_foldover=0, chamfer_int=chamfer_int_lid, a_hinge=a_hinge_lid, az_wide=-a_stitch);
      }
    }
  }

  // approximate, a bit long, needs manually marked holes
  module interior(cp) {
    s = [
      int.z * PI / 2 - hinge_inset_stitches,
      int.y - chamfer_int_lid,
      t,
    ];

    translate(
      v=[
        s.x / 2 + r_end_quant * PI / 2 + int.x + t_leather + t_wall + w_foldover + t_leather,
        0,
        (ext.z + s.z) / 2,
      ]
    ) {
      color(c=cp[0])
        cube(size=s, center=true);
      if (!fold)
        color(c=cp[1])
          translate(v=[-1, 0, (t_template + t_template_line) / 2])
            cube([s.x, t_template_line, t_template_line], center=true);
    }
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

    dbg_magnets() mask_magnets_front(ext=ext_main, teardrop=55);

    mirror(v=[0, 0, 1]) {
      dbg_foldover() mask_foldover_wide(ext=ext_main, int=int_main, w=w_foldover, t=t_foldover);

      dbg_foldover() mask_foldover_deep(ext=ext_main, int=int_main, w=w_foldover, t=t_foldover, hinge=false);
    }
  }
}

module back() {
  difference() {
    shell_main(hinge=true);

    dbg_hinges() mask_hinge_pin(ext=ext_main, ay=a_hinge_main, d=d_hinge_pin_main, l=l_hinge_pin_shell, teardrop=true);

    dbg_gaps() mask_hinge_chamfer(ext=ext_main, int=int_main);

    dbg_magnets() mask_magnets_back(ext=ext_main, int=int_main, dz=t_foldover / 2);

    translate(v=[-hinge_inset_dx, 0, 0]) {
      dbg_foldover() mask_foldover_wide(ext=ext_main, int=int_main, w=w_foldover_hinge, t=t_foldover);
      dbg_foldover() mask_foldover_wide(ext=ext_main, int=int_main, w=0, t=t_wall);
    }

    dbg_foldover() mask_foldover_deep(ext=ext_main, int=int_main, w=w_foldover, t=t_foldover, hinge=true);
  }

  magnet_shroud_back(ext=ext_main, int=int_main, dz=t_foldover / 2);
}

module leather_wall_end(ext, cp, az_long, line) {
  b_end = [2 * r_end_quant * PI / 4 + t_leather_overhang_wall, ext.y + t_leather_overhang_wall * 2, t_leather];

  module mask_end_stitches_folded() {
    for (i = [-1, 1])
      translate(v=[-ext.x / 2, 0, 0])
        mask_stitches_quartercircle(stitch=stitch_leather, ax=0, ay=0, az=i * az_long, dy=i * (ext.y / 2 - stitch_inset), dz=ext.z / 2);

    if (two_piece_wall)
      translate(v=[-ext.x / 2, 0, 0])
        rotate(a=-90 - a_end_quant / 2, v=[0, 1, 0])
          mask_stitches_wide(stitch=stitch_leather, ext=ext, az=90, dx=0, dz=ext.z / 2);
  }

  module mask_end_stitches_unfolded() {
    x0 = -ext.x / 2 - round_nearest(b_end.x, stitch_spacing);
    x1 = -ext.x / 2;

    for (i = [-1, 1])
      translate(v=[0, i * ( (ext.y) / 2 - stitch_inset), -ext.z / 2])
        mask_stitches_long(stitch=stitch_leather, ax=0, az=i * az_long, x0=x0, x1=x1);

    if (two_piece_wall)
      mask_stitches_wide(stitch=stitch_leather, ext=ext, az=90, dx=-ext.x / 2 - b_end.x + stitch_spacing / 2 + t_leather_overhang_wall, dz=-ext.z / 2);
  }

  module mask_end_stitches() {
    if (fold)
      mask_end_stitches_folded();
    else
      mask_end_stitches_unfolded();
  }

  module end_unfolded() {
    translate(v=[-(ext.x + b_end.x) / 2, 0, ( -t_template + t_leather) / 2])
      cube([b_end.x, b_end.y, t_template], center=true);
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
    union() {
      translate(v=[0, 0, ( -ext.z - t_leather) / 2])
        color(c=cp[0])
          end();

      if (!fold && line)
        color(c=cp[1])
          translate(v=[( -ext.x - b_end.x + t_leather_overhang_wall) / 2, 0, -ext.z / 2 - t_template_line / 2 - t_template])
            cube([b_end.x - t_leather_overhang_wall, t_template_line, t_template_line], center=true);
    }

    mask_end_stitches();
  }
}

module leather_wall_foldover(cp, ext, int, hinge, t_foldover, chamfer_int, a_hinge, az_wide) {
  y_edge_bottom = ext.y + t_leather_overhang_wall * 2;
  y_edge_top = y_edge_bottom - 2 * t_side - chamfer_int;

  t = fold ? t_leather : t_template;

  b_fedge = [
    t_wall + chamfer_int / 2,
    y_edge_bottom,
    t,
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
    (hinge ? w_foldover_hinge : w_foldover) + t_leather + dw_inner,
    y_edge_top,
    t,
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
      ( -ext.z - t) / 2,
    ];

    // fold, mask, unfold if necessary
    translate(v=fold ? [0, 0, 0] : shifted)
      rotate(a=fold ? 0 : 90, v=[0, 1, 0])
        translate(v=fold ? [0, 0, 0] : -folded)
          difference() {
            translate(v=folded) {
              difference() {
                rotate(a=-90, v=[0, 1, 0])
                  linear_extrude(h=t, center=true)
                    polygon(p_fedge);
              }
            }
            if (hinge)
              mask_hinge_pin(ext=ext, ay=a_hinge, d=d_hinge_pin_main, l=l_hinge_pin_shell, teardrop=false);
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
            mask_stitches_wide(stitch=stitch_leather, ext=ext, az=az_wide, dx=ext.x / 2 - stitch_inset + (hinge ? -hinge_inset_stitches : 0), dz=( -ext.z + t_wall) / 2);
          }
  }

  color(c=cp[0])
    edge();

  color(c=cp[1])
    inner();
}

module leather_wall_long(ext, cp, hinge, az_wide, az_long, line) {
  module mask_stitches() {
    x0 = -ext.x / 2;
    x1 = ext.x / 2;

    for (i = [-1, 1])
      translate(v=[0, i * ( (ext.y) / 2 - stitch_inset), -ext.z / 2])
        mask_stitches_long(stitch=stitch_leather, ax=0, az=i * az_long, x0=x0, x1=x1);

    mask_stitches_wide(stitch=stitch_leather, ext=ext, az=az_wide, dx=ext.x / 2 - stitch_inset + (hinge ? -hinge_inset_stitches : 0), dz=-ext.z / 2);
  }

  module body() {
    t = fold ? t_leather : t_template;

    // midway up hinge chamfer, overhanging end by 1 leather
    dx = hinge ? -hinge_inset_dx / 2 : 0;
    translate(v=[(dx + t_leather) / 2, 0, ( -ext.z - t) / 2])
      cube([ext.x + dx + t_leather, ext.y + t_leather_overhang_wall * 2, t], center=true);
  }

  difference() {
    union() {
      color(c=cp[1])
        body();

      if (!fold && line)
        color(c=cp[0])
          translate(v=[0, 0, -ext.z / 2 - t_template_line / 2 - t_template])
            cube([ext.x, t_template_line, t_template_line], center=true);
    }

    mask_stitches();
  }
}

module leather_wall_front(cp) {
  ext = ext_main;
  int = int_main;

  rotate(a=fold ? 0 : 180, v=[0, 0, 1])
    rotate(a=fold ? 180 : 0, v=[1, 0, 0])
      template_joiners(cp=cp, ext)
        translate(v=fold ? [0, 0, 0] : [ext.x / 2 + r_end_quant * PI / 2, 0, 0]) {
          leather_wall_end(ext=ext_main, cp=cp, az_long=a_stitch);
          leather_wall_long(ext=ext_main, cp=cp, hinge=false, az_wide=a_stitch, az_long=a_stitch, line=true);

          leather_wall_foldover(cp=cp, ext=ext, int=int, hinge=false, t_foldover=t_foldover, chamfer_int=chamfer_int_main, a_hinge=a_hinge_main, az_wide=-a_stitch);
        }
}

module leather_wall_back(cp) {
  ext = ext_main;
  int = int_main;

  template_joiners(cp=cp, ext)
    translate(v=fold ? [0, 0, 0] : [ext.x / 2 + r_end_quant * PI / 2, 0, 0]) {
      leather_wall_end(ext=ext, cp=cp, az_long=a_stitch);
      leather_wall_long(ext=ext, cp=cp, hinge=true, az_wide=a_stitch, az_long=a_stitch, line=true);

      leather_wall_foldover(cp=cp, ext=ext, int=int, hinge=true, t_foldover=t_foldover, chamfer_int=chamfer_int_main, a_hinge=a_hinge_main, az_wide=-a_stitch);
    }
}

module leather_side_foldover(cp, ext, int, t_foldover, ay_hinge, chamfer_int, ay_deep) {
  l_out = ext.z + t_leather_overhang_side * 2;
  l_in = l_out - 2 * t_wall - chamfer_int;

  t = fold ? t_leather : t_template;

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
    t,
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
      (ext.y + t) / 2,
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
                  linear_extrude(h=t, center=true)
                    polygon(p_fedge);
            mask_hinge_pin(ext=ext, ay=ay_hinge, d=d_hinge_pin_main, l=l_hinge_pin_shell, teardrop=false);
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
      (ext.y + t) / 2,
      0,
    ];

    translate(v=fold ? [0, 0, 0] : shifted)
      rotate(a=fold ? 0 : 180, v=[0, 1, 0])
        translate(v=fold ? [0, 0, 0] : -folded)
          difference() {
            translate(v=folded)
              cube(b_finner, center=true);
            mask_stitches_deep(stitch=stitch_leather, ext=ext, ay=fold ? -ay_deep : ay_deep, dy=(ext.y - t_side) / 2);
          }
  }

  color(c=cp[0])
    edge();

  color(c=cp[1])
    inner();
}

module leather_side(ext, int, cp, ay_deep, ayz_long) {
  t = fold ? t_leather : t_template;

  d = ext.z + t_leather_overhang_side * 2;

  dz_stitch = ext.z / 2 - stitch_inset;

  module mask_stitches() {
    for (i = [-1, 1])
      translate(v=[0, ext.y / 2, i * dz_stitch])
        rotate(a=-90, v=[1, 0, 0])
          mask_stitches_long(stitch=stitch_leather, ax=0, az=i * -ayz_long, x0=-ext.x / 2, x1=ext.x / 2);

    translate(v=[-ext.x / 2, 0, 0]) {
      mask_stitches_quartercircle(stitch=stitch_leather, ax=90, ay=ayz_long, az=0, dy=ext.y / 2, dz=dz_stitch);
      mirror(v=[0, 0, 1])
        mask_stitches_quartercircle(stitch=stitch_leather, ax=90, ay=ayz_long, az=0, dy=ext.y / 2, dz=dz_stitch);
    }

    mask_stitches_deep(stitch=stitch_leather, ext=ext, ay=ay_deep, dy=ext.y / 2);
  }

  module body() {
    translate(v=[0, (ext.y + t) / 2, 0]) {
      translate(v=[t_leather / 2, 0, 0])
        cube([ext.x + t_leather, t, d], center=true);

      translate(v=[-ext.x / 2, 0, 0])
        rotate(a=90, v=[1, 0, 0])
          left_half()
            cyl(h=t, d=d, center=true);
    }
  }

  difference() {
    union() {
      color(c=cp[1])
        body();

      if (!fold)
        color(c=cp[0])
          translate(v=[-d / 4, ext.y / 2 + t_template_line / 2 + t_template, 0])
            cube([ext.x + d / 2, t_template_line, t_template_line], center=true);
    }

    mask_stitches();
  }
}

module leather_main_side(cp, ay_deep, ayz_long) {
  leather_side(ext=ext_main, int=int_main, cp=cp, ay_deep=ay_deep, ayz_long=ayz_long);

  leather_side_foldover(cp=cp, ext=ext_main, int=int_main, t_foldover=t_foldover, ay_hinge=a_hinge_main, chamfer_int=chamfer_int_main, ay_deep=ay_deep);
}

module leather_main_side_left(cp) {
  leather_main_side(cp, ay_deep=-a_stitch, ayz_long=-a_stitch);
}

module leather_main_side_right(cp) {
  mirror(v=[0, 1, 0])
    leather_main_side(cp, ay_deep=a_stitch, ayz_long=-a_stitch);
}

module leather_lid_side(cp, ay_deep) {
  ext = ext_lid;
  int = int_lid;

  t = fold ? t_leather : t_template;

  module interior() {
    folded = [0, (int.y - t_leather) / 2, 0];
    shifted = [ext.x + t_side + t_leather * 2, (ext.y + t) / 2, 0];

    translate(v=fold ? [0, 0, 0] : shifted)
      rotate(a=fold ? 0 : 180, v=[0, 0, 1])
        translate(v=fold ? [0, 0, 0] : -folded)
          translate(v=folded)
            difference() {
              color(c=cp[0])
                translate(v=[-int.x / 2, 0, 0])
                  rotate(a=90, v=[1, 0, 0])
                    left_half()
                      cylinder(h=t, d=int.z - chamfer_int_lid, center=true);
              mask_stitches_deep(stitch=stitch_leather, ext=ext, ay=-ay_deep, dy=0);
            }
  }

  leather_side(ext=ext, int=int, cp=cp, ay_deep=ay_deep, ayz_long=a_stitch);

  intersection() {
    leather_side_foldover(cp=cp, ext=ext, int=int, t_foldover=0, ay_hinge=a_hinge_lid, chamfer_int=chamfer_int_lid + t_leather_overhang_side * 2, ay_deep=ay_deep);
    union() {
      interior();
      if (fold) {
        translate(v=[t_leather / 2, 0, 0])
          cube(size=ext + [t_leather, t_leather * 2, 0], center=true);
      } else {
        x = 2 * (ext.x + t_leather) + t_side;
        translate(v=[(x - ext.x) / 2, 0, 0])
          cube(size=[x, 2 * ext.y, 2 * ext.z], center=true);
      }
    }
  }

  interior();
}

module leather_lid_side_left(cp) {
  leather_lid_side(cp, ay_deep=a_stitch);
}

module leather_lid_side_right(cp) {
  mirror(v=[0, 1, 0])
    leather_lid_side(cp, ay_deep=-a_stitch);
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
  a = 50; // try to stop any slippage when inserting

  ext = ext_main;
  int = int_main;

  body = [l_hinge_pin_jig / 2, ext.y + d_hinge_pin_jig, ext.z / 2];

  color(c="tan")
    difference() {
      translate(v=[ext.x / 2 + body.x / 2 + gap_hinge_jig, 0, -body.z / 2])
        cube(size=body, center=true);

      translate(v=[ext.x / 2 + gap_hinge_jig, 0, -body.z])
        rotate(a=90, v=[1, 0, 0])
          linear_extrude(h=body.y, center=true)
            polygon(
              [
                [-0.0001, 0],
                [-0.0001, hinge_inset_dz],
                [hinge_inset_dx, 0],
              ]
            );

      translate(v=[ext.x / 2 + gap_hinge_jig, 0, 0])
        rotate(a=90, v=[1, 0, 0])
          linear_extrude(h=body.y, center=true)
            polygon(
              [
                [0, 0],
                [body.x + 0.0001, 0],
                [body.x + 0.0001, -body.x / tan(a)],
              ]
            );

      translate(v=[ext.x / 2 + gap_hinge_jig + body.x, 0, -body.z])
        rotate(a=90, v=[1, 0, 0])
          linear_extrude(h=body.y, center=true)
            polygon(
              [
                [0.0001, 0],
                [0.0001, body.z - body.x / tan(a)],
                [-body.x + hinge_inset_dx, 0],
              ]
            );

      dbg_hinges() mask_hinge_pin(ext=ext_main, ay=180 - a, d=d_hinge_pin_jig, l=l_hinge_pin_jig, teardrop=false);

      dbg_hinges() mask_hinge_pin(ext=ext_main, ay=180 - a, d=d_hinge_pin_jig_hole, l=l_hinge_pin_jig * 2, teardrop=false);

      translate(v=[0, 0, d_hinge_pin_jig / 2])
        dbg_hinges() mask_hinge_pin(ext=ext_main, ay=90 - a, d=d_hinge_pin_jig, l=l_hinge_pin_jig * 2, teardrop=false, channel=true);
    }
}

module slice() {
  if (debug_slice) {
    bottom_half(z=ext_main.z / 2 + t_leather + debug_dz_slice, s=ext_main.x * 5)
      back_half(y=-ext_main.y / 2 - t_leather_overhang_wall - debug_dy_slice, s=ext_main.x * 5)
        left_half(x=ext_main.x / 2 + debug_dx_slice, s=ext_main.x * 5)
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
