include <BOSL2/std.scad>
include <lib/geom.scad>

/* [Show] */
show_lid = true;
show_back = true;
show_front = false;

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

r_holes = (int_target.z + 2 * t_wall) / 2 - hole_outer_inset;
echo(r_holes=r_holes);

// angle at spacing_hole
a_curve_hole = chord_angle(hole_outer_spacing, r_holes);
echo(a_curve_hole=a_curve_hole);

// round this angle to fit a clean divisor of 180
a_curve_rounded = 180 / round(180 / a_curve_hole);
echo(a_curve_rounded=a_curve_rounded);

// new z
r_holes_rounded = chord_radius(a_curve_rounded, hole_outer_spacing);
echo(r_holes_rounded=r_holes_rounded);
echo(d_holes_rounded=r_holes_rounded * 2);

ext_z_rounded = 2 * r_holes_rounded + hole_outer_inset * 2;
echo(ext_z_rounded=ext_z_rounded);

ext = [int_target.x, int_target.y + 2 * t_side, ext_z_rounded];
echo(ext=ext);

int = [int_target.x, int_target.y, ext_z_rounded - 2 * t_wall];
echo(int=int);
echo(int_target=int_target);

$fn = 120;

module mask_hole_outer(ay) {
  z_hole = sqrt(2 * hole_outer_inset ^ 2) + sqrt((2 * hole_outer_w / 2) ^ 2);

  rotate(a=ay, v=[0, 1, 0])
    translate(v=[0, -hole_outer_inset / 2, -hole_outer_inset / 2])
      translate(v=[0, (ext.y) / 2, ext.z / 2])
        rotate(a=45, v=[1, 0, 0])
          cube(size=[hole_outer_l, hole_outer_w, z_hole], center=true);
}

module mask_hole_outers() {

  // clockwise looking from +y

  // +z
  translate(v=[ext.x / 2, 0, 0]) {
    for (i = [0:hole_outer_spacing:ext.x]) {
      translate(v=[-i, 0, 0]) {
        mask_hole_outer(ay=0);
      }
    }
  }

  // -x 
  translate(v=[-ext.x / 2, 0, 0]) {
    for (ay = [0:-a_curve_rounded:-180]) {
      mask_hole_outer(ay=ay);
    }
  }

  // -z
  translate(v=[-ext.x / 2, 0, 0]) {
    for (i = [0:hole_outer_spacing:ext.x]) {
      translate(v=[i, 0, 0]) {
        mask_hole_outer(ay=180);
      }
    }
  }

  // +x
  translate(v=[ext.x / 2, 0, 0]) {
    for (ay = [180:-a_curve_rounded:0]) {
      mask_hole_outer(ay=ay);
    }
  }
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

module mask_pins() {
  for (i = [-1, 1]) {
    for (x = [-ext.x / 2 - r_holes / 3, 0, ext.x / 2 - r_holes / 2]) {
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

    if (debug_holes) {
      #mask_hole_outers();
      mirror(v=[0, 1, 0])
        #mask_hole_outers();
    } else {
      mask_hole_outers();
      mirror(v=[0, 1, 0])
        mask_hole_outers();
    }
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

    if (debug_holes)
      #mask_pins();
    else
      mask_pins();
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

render() {

  if (show_lid)
    lid();

  if (show_back)
    back();

  if (show_front)
    front();
}
