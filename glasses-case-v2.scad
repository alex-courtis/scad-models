include <BOSL2/std.scad>
include <lib/geom.scad>

d_filament = 0.4;
t_layer = 0.2;

model = "all"; // ["all", "front", "back", "lid", "lid_insert", "lid+lid_insert",]

half = false;

debug_holes = false;
circular_holes = false;

// interior target
// x excludes the rounded ends
// z will be adjusted for even spacing_hole around curves
int_target = [130, 70, 35];

t_side = 3.6;
t_wall = 2.4;

x_hole = 3.5;
y_hole = 1.5;

// centre of hole to edge
dxy_hole = 4;
spacing_hole = 5;

d_pin = 2.2; // [0:0.05:5]
l_pin = 18; // [0:0.05:50]

// d_liner_hole = 2.0; // [0:0.05:3]

gap_half = 1; // [0:0.1:5]
gap_lid = 2;

r_holes = (int_target.z + 2 * t_wall) / 2 - dxy_hole;
echo(r_holes=r_holes);

// angle at spacing_hole
a_curve_hole = chord_angle(spacing_hole, r_holes);
echo(a_curve_hole=a_curve_hole);

// round this angle to fit a clean divisor of 180
a_curve_rounded = 180 / round(180 / a_curve_hole);
echo(a_curve_rounded=a_curve_rounded);

// new z
r_holes_rounded = chord_radius(a_curve_rounded, spacing_hole);
echo(r_holes_rounded=r_holes_rounded);

ext_z_rounded = 2 * r_holes_rounded + dxy_hole * 2;
echo(ext_z_rounded=ext_z_rounded);

ext = [int_target.x, int_target.y + 2 * t_side, ext_z_rounded];
echo(ext=ext);

int = [int_target.x, int_target.y, ext_z_rounded - 2 * t_wall];
echo(int=int);
echo(int_target=int_target);

$fn = 120;

module shell_ext() {
  cuboid(size=ext);

  translate(v=[ext.x / 2, 0, 0]) {
    rotate(a=90, v=[1, 0, 0]) {
      cyl(d=ext.z, h=ext.y);
    }
  }

  translate(v=[-ext.x / 2, 0, 0]) {
    rotate(a=90, v=[1, 0, 0]) {
      cyl(d=ext.z, h=ext.y);
    }
  }
}

module shell_int() {
  cuboid(size=int);

  translate(v=[int.x / 2, 0, 0]) {
    rotate(a=90, v=[1, 0, 0]) {
      cyl(d=int.z, h=int.y);
    }
  }

  translate(v=[-int.x / 2, 0, 0]) {
    rotate(a=90, v=[1, 0, 0]) {
      cyl(d=int.z, h=int.y);
    }
  }

  // xz = int.z / sqrt(2);
  //
  // translate(v=[int.x / 2, 0, 0])
  //   rotate(a=45, v=[0, 1, 0])
  //     cuboid(size=[xz, int.y, xz]);
  //
  // translate(v=[-int.x / 2, 0, 0])
  //   rotate(a=45, v=[0, 1, 0])
  //     cuboid(size=[xz, int.y, xz]);
}

module hole_outer(ay) {
  rotate(a=ay, v=[0, 1, 0])
    translate(v=[0, -dxy_hole / 2, -dxy_hole / 2])
      translate(v=[0, (ext.y) / 2, ext.z / 2])
        rotate(a=45, v=[1, 0, 0])
          cuboid(size=[x_hole, y_hole, 20]);
}

module hole_outers() {

  // clockwise looking from +y

  // +z
  translate(v=[ext.x / 2, 0, 0]) {
    for (i = [0:spacing_hole:ext.x]) {
      translate(v=[-i, 0, 0]) {
        hole_outer(ay=0);
      }
    }
  }

  // -x 
  translate(v=[-ext.x / 2, 0, 0]) {
    for (ay = [0:-a_curve_rounded:-180]) {
      hole_outer(ay=ay);
    }
  }

  // -z
  translate(v=[-ext.x / 2, 0, 0]) {
    for (i = [0:spacing_hole:ext.x]) {
      translate(v=[i, 0, 0]) {
        hole_outer(ay=180);
      }
    }
  }

  // +x
  translate(v=[ext.x / 2, 0, 0]) {
    for (ay = [180:-a_curve_rounded:0]) {
      hole_outer(ay=ay);
    }
  }
}

module body() {
  difference() {
    shell_ext();
    shell_int();
    hole_outers();
    mirror(v=[0, 1, 0])
      hole_outers();
  }
}

module gap_half() {
  translate(v=[-ext.z / 4 - gap_lid / 4, 0, 0]) {
    gap = [
      ext.x + ext.z / 2 - gap_lid / 2,
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

module gap_lid() {
  translate(v=[int.x / 2, 0, 0])
    cube(size=[gap_lid, ext.y, ext.z], center=true);
}

module pins() {
  for (i = [-1, 1]) {
    for (x = [-ext.x / 2 - r_holes / 3, 0, ext.x / 2 - r_holes / 2]) {
      translate(v=[x, i * (ext.y + int.y) / 4, 0])
        cylinder(d=d_pin, h=l_pin, center=true);
    }
  }
}

render() {
  right_half(s=500, x=model == "lid" ? ext.x / 2 : -250) {
    bottom_half(s=300, z=half ? 0 : 150) {
      difference() {
        body();

        gap_half();

        gap_lid();

        pins();
      }
    }
  }
}
