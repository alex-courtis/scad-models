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
// z will be adjusted for even spacing_hole around curves
int_target = [130, 70, 35];

t_side = 3.6; // [0:0.05:10]
t_wall = 2.4; // [0:0.05:10]

t_leather = 0.8; // [0:0.05:5]
t_leather_overhang = 0.4; // [0:0.05:5]

t_foldover = 1.2; // [0:0.05:5]
w_foldover = 6; // [0:0.05:5]

gap_half = 1; // [0:0.05:5]
gap_lid = 2; // [0:0.05:5]

/* [Holes] */
hole_outer_l = 3.5; // [0:0.1:5]
hole_outer_w = 1.5; // [0:0.1:5]

// centre of hole to edge
hole_outer_inset = 4; // [0:0.1:10]
hole_outer_spacing = 5; // [0:0.1:10]

/* [Pins] */
d_pin = 2.2; // [0:0.05:5]
l_pin = 18; // [0:0.1:50]

// outside of leather
r_end = int_target.z / 2 + t_wall + t_leather;
echo(r_end=r_end);

// angle at spacing_hole
a_curve_hole = arc_angle(hole_outer_spacing, r_end);
echo(a_curve_hole=a_curve_hole);

// round this angle to fit a clean divisor of 180
a_curve_rounded = 180 / round(180 / a_curve_hole);
echo(a_curve_rounded=a_curve_rounded);

// new total z
r_end_rounded = arc_radius(a_curve_rounded, hole_outer_spacing);
echo(r_end_rounded=r_end_rounded);

ext = [int_target.x, int_target.y + 2 * t_side, 2 * (r_end_rounded - t_leather)];
echo(ext=ext);

int = [int_target.x, int_target.y, ext.z - 2 * t_wall];
echo(int_target=int_target);
echo(int=int);

leather_wall_flat = [ext.x - gap_lid, ext.y + t_leather_overhang * 2, t_leather];
echo(leather_wall_flat=leather_wall_flat);

leather_wall_end = [2 * r_end_rounded * PI / 4, leather_wall_flat.y, leather_wall_flat.z];
echo(leather_wall_end=leather_wall_end);

leather_d_side = ext.z + t_leather_overhang * 2;
echo(leather_d_side=leather_d_side);

$fn = 120;

module mask_shell_hole_outer(ay = 0) {

  module actual() {
    z_hole = sqrt(2 * hole_outer_inset ^ 2) + sqrt((2 * hole_outer_w / 2) ^ 2) + 2 * t_leather * sqrt(2);

    rotate(a=ay, v=[0, 1, 0])
      translate(v=[0, -hole_outer_inset / 2, -hole_outer_inset / 2])
        translate(v=[0, (ext.y) / 2, ext.z / 2])
          rotate(a=45, v=[1, 0, 0])
            cube(size=[hole_outer_l, hole_outer_w, z_hole], center=true);
  }

  if (debug_holes)
    #actual();
  else
    actual();
}

module mask_shell_hole_outers_half() {

  // clockwise looking from +y

  // +z
  translate(v=[ext.x / 2, 0, 0]) {
    for (i = [0:hole_outer_spacing:ext.x]) {
      translate(v=[-i, 0, 0]) {
        mask_shell_hole_outer(ay=0);
      }
    }
  }

  // -x 
  translate(v=[-ext.x / 2, 0, 0]) {
    for (ay = [0:-a_curve_rounded:-180]) {
      mask_shell_hole_outer(ay=ay);
    }
  }

  // -z
  translate(v=[-ext.x / 2, 0, 0]) {
    for (i = [0:hole_outer_spacing:ext.x]) {
      translate(v=[i, 0, 0]) {
        mask_shell_hole_outer(ay=180);
      }
    }
  }

  // +x
  translate(v=[ext.x / 2, 0, 0]) {
    for (ay = [180:-a_curve_rounded:0]) {
      mask_shell_hole_outer(ay=ay);
    }
  }
}

module mask_shell_hole_outers() {
  mask_shell_hole_outers_half();
  mirror(v=[0, 1, 0])
    mask_shell_hole_outers_half();
}

module mask_half_gap() {
  translate(v=[-ext.z / 4 - gap_lid / 2, 0, 0]) {
    gap = [
      ext.x + ext.z / 2 - gap_lid,
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

module mask_lid_gap() {
  translate(v=[(int.x - gap_lid) / 2, 0, 0])
    cube(size=[gap_lid, ext.y, ext.z], center=true);
}

module mask_shell_foldover() {
  gap = [
    w_foldover,
    int.y + t_foldover * 2,
    int.z + t_foldover * 2,
  ];

  translate(v=[(ext.x - gap.x) / 2 - gap_lid, 0, 0])
    cube(size=gap, center=true);
}

module mask_pins() {
  for (i = [-1, 1]) {
    for (x = [-ext.x / 2, 0, ext.x / 2 - gap_lid - w_foldover * 2]) {
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
      #mask_lid_gap();
    else
      mask_lid_gap();

    if (debug_gaps)
      #mask_shell_foldover();
    else
      mask_shell_foldover();

    if (debug_holes)
      #mask_pins();
    else
      mask_pins();

    mask_shell_hole_outers();
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

module mask_leather_wall_holes(a) {
  x_off = (180 / a_curve_rounded) % 2 == 1 ? hole_outer_spacing / 2 : 0;

  translate(v=[0, ext.y / 2 - hole_outer_inset, 0]) {
    for (i = [-ext.x / 2 - leather_wall_end.x + x_off:hole_outer_spacing:ext.x / 2 - gap_lid]) {
      translate(v=[i, 0, 0]) {
        rotate(a=a)
          cube([hole_outer_l, hole_outer_w, ext.z + t_leather * 2], center=true);
      }
    }
  }
}

module leather_wall(top) {
  color(c=brown_pair(top ? 0 : 1)[top ? 0 : 1])
    mirror(v=[0, 0, top ? 1 : 0])
      translate(v=[-gap_lid / 2, 0, 0])
        translate(v=[0, 0, -(ext.z + leather_wall_flat.z) / 2])
          cube(leather_wall_flat, center=true);

  color(c=brown_pair(top ? 0 : 1)[top ? 1 : 0])
    translate(
      v=[
        -(leather_wall_flat.x + leather_wall_end.x) / 2 - gap_lid / 2,
        0,
        (top ? 1 : -1) * (ext.z + t_leather) / 2,
      ]
    )
      cube(leather_wall_end, center=true);
}

module leather_wall_foldover(top) {
  size1 = [w_foldover, int.y, t_leather];
  size2 = [t_leather, int.y, t_wall + t_leather * 2 - t_foldover];

  color(c=brown_pair(top ? 0 : 1)[0]) {
    if (fold_leather) {
      translate(v=[(int.x - w_foldover) / 2 - gap_lid, 0, (int.z - t_leather) / 2 + t_foldover])
        cube(size1, center=true);
    } else {
      translate(v=[(ext.x + size1.x) / 2 + size2.z - gap_lid, 0, (ext.z + size1.z) / 2])
        cube(size1, center=true);
    }
  }

  color(c=brown_pair(top ? 0 : 1)[1]) {
    if (fold_leather) {
      translate(v=[(int.x + t_leather) / 2 - gap_lid, 0, (ext.z - size2.z) / 2 + t_leather])
        cube(size2, center=true);
    } else {
      translate(v=[(ext.x + size2.z) / 2 - gap_lid, 0, (ext.z + size2.x) / 2])
        rotate(a=90, v=[0, 1, 0])
          cube(size2, center=true);
    }
  }
}

module leather_back() {
  difference() {
    union() {
      leather_wall(top=false);
      mirror(v=[0, 0, 1])
        leather_wall_foldover(top=false);
    }
    mask_leather_wall_holes(a=45);
    mirror(v=[0, 1, 0])
      mask_leather_wall_holes(a=45);
  }
}

module leather_front() {
  difference() {
    union() {
      leather_wall(top=true);
      leather_wall_foldover(top=true);
    }
    mask_leather_wall_holes(a=45);
    mirror(v=[0, 1, 0])
      mask_leather_wall_holes(a=45);
  }
}

module mask_leather_side_hole(a) {
  rotate(a=a, v=[0, 1, 0])
    cube([hole_outer_w, ext.y + t_leather * 2 + 0.001, hole_outer_l], center=true);
}

module mask_leather_side_holes(a) {
  translate(v=[0, 0, ext.z / 2 - hole_outer_inset])for (i = [-ext.x / 2:hole_outer_spacing:ext.x / 2 - gap_lid])
    translate(v=[i, 0, 0])
      mask_leather_side_hole(a=a);

  translate(v=[0, 0, -ext.z / 2 + hole_outer_inset])for (i = [-ext.x / 2:hole_outer_spacing:ext.x / 2 - gap_lid])
    translate(v=[i, 0, 0])
      mask_leather_side_hole(a=a);

  translate(v=[-ext.x / 2, 0, 0])for (ay = [0:a_curve_rounded:180])
    rotate(a=ay, v=[0, 1, 0])
      translate(v=[0, 0, -ext.z / 2 + hole_outer_inset])
        mask_leather_side_hole(a=a);
}

module leather_side() {
  translate(v=[0, (ext.y + t_leather) / 2, 0]) {
    cube([ext.x, t_leather, leather_d_side], center=true);

    translate(v=[ext.x / 2, 0, 0])
      rotate(a=90, v=[1, 0, 0])
        cyl(h=t_leather, d=leather_d_side, center=true);

    translate(v=[-ext.x / 2, 0, 0])
      rotate(a=90, v=[1, 0, 0])
        cyl(h=t_leather, d=leather_d_side, center=true);
  }
}

module leather_side_left() {
  color(c=brown_pair(2)[0]) {
    left_half(s=ext.x * 2, x=ext.x / 2 - gap_lid) {
      difference() {
        leather_side();
        mask_leather_side_holes(a=-45);
      }
    }
  }
}

module leather_side_right() {
  color(c=brown_pair(2)[1]) {
    left_half(s=ext.x * 2, x=ext.x / 2 - gap_lid) {
      difference() {
        mirror(v=[0, 1, 0])
          leather_side();
        mask_leather_side_holes(a=-45);
      }
    }
  }
}

render() {

  if (show_lid)
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
