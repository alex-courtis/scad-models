include <BOSL2/std.scad>
include <lib/geom.scad>
include <lib/colours.scad>

// TODO 
// d_hinge: 3 or 4 and position it
// lid
// liner holes
// liner template

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
debug_magnet = false;
debug_hinge = false;

/* [Dimensions] */

// interior target
// x excludes the rounded ends
// x, y quantized for linear hole spacing
// z quantized for curved hole spacing, arc outside of leather
int_target = [132, 70, 35];

t_side = 4; // [0:0.05:10]
t_wall = 4; // [0:0.05:10]

shell_chamfer = 0.6; // [0:0.05:2]

t_leather = 0.8; // [0:0.05:5]
t_leather_overhang = 0.0; // [0:0.05:5]

t_foldover = 1.6; // [0:0.05:5]
w_foldover = 6.5; // [0:0.05:5]

foldover_chamfer = 0.8; // [0:0.05:2]

gap_half = 1; // [0:0.05:5]

/* [Holes] */
hole_stitch_l = 3.5; // [0:0.1:5]
hole_stitch_w = 1.5; // [0:0.1:5]

// centre of hole to edge
hole_stitch_inset = 4; // [0:0.1:10]
hole_stitch_spacing = 5; // [0:0.1:10]

// sides and wall
a_stitch = -45; // [0:1:90]

/* [Pins] */
d_pin = 2.3; // [0:0.05:5]
l_pin = 16; // [0:0.1:50]

/* [Magnets] */
d_magnet = 6.1; // [0:0.05:10]
t_magnet = 4.05; // [0:0.05:10]

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

$fn = 120;

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

module mask_stitches_wide(az, dx, dz, az) {
  y = ext.y / 2 - hole_stitch_inset - hole_stitch_spacing;

  for (dy = [-y:hole_stitch_spacing:y])
    translate(v=[dx, dy, dz])
      mask_stitch(ax=0, ay=0, az=az);
}

module mask_stitches_foldover_deep(ay, dy) {
  z = ext.z / 2 - hole_stitch_inset;

  spacing = z / round_nearest(z, hole_stitch_spacing) * hole_stitch_spacing;

  for (dz = [-z + spacing:spacing:z - spacing]) {
    translate(v=[ext.x / 2 - hole_stitch_inset, dy, dz])
      mask_stitch(ax=90, ay=ay, az=0);
  }
}

module mask_stitches_semicircle(ax, ay, az, dy, dz) {
  for (a = [0:-a_end_quant:-180]) {
    rotate(a=a, v=[0, 1, 0]) {
      a_adj = (a == -90) ? 0 : (a < -90 ? -ay : ay);
      translate(v=[0, dy, dz])
        mask_stitch(ax=ax, ay=a_adj, az=-az);
    }
  }
}

module mask_magnet() {
  inset = [(ext.x - t_magnet) / 2, (ext.y - d_magnet) / 2, (ext.z - d_magnet) / 2];

  for (i = [-1, 1])
    translate(v=vector_multiply_vector(inset, [1, i, 1]))
      rotate(a=90, v=[0, 0, 1])
        teardrop(h=t_magnet, d=d_magnet, orient=DOWN, ang=60);
}

module mask_hinge() {
  inset = [ext.x / 2, (ext.y - t_side) / 2 - t_foldover, -(ext.z - t_wall) / 2 + t_foldover];

  for (i = [-1, 1])
    translate(v=vector_multiply_vector(inset, [1, i, 1]))
      rotate(a=90, v=[0, 0, 1])
        teardrop(h=l_hinge, d=d_hinge, ang=60);
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

      dx = (3 * t_wall);
      translate(v=[0, 0, 0])
        cube(size=gap - [dx + 0, 0, 0], center=true);
    }
  }

  module mask_stitches() {
    dy = (ext.y) / 2 - hole_stitch_inset / 2 + t_leather / 2;
    dz = (ext.z) / 2 - hole_stitch_inset / 2 + t_leather / 2;

    for (i = [-1, 1]) {
      for (j = [-1, 1])
        translate(v=[0, i * dy, j * dz])
          mask_stitches_long(ax=i * j * 45, az=0, x0=-ext.x / 2, x1=ext.x / 2);

      translate(v=[-ext.x / 2, 0, 0])
        mask_stitches_semicircle(ax=i * 45, ay=0, az=0, dy=i * dy, dz=dz);

      mask_stitches_wide(az=90, dx=ext.x / 2 - hole_stitch_inset, dz=i * (ext.z - t_wall + t_foldover) / 2);

      mask_stitches_foldover_deep(ay=90, dy=i * (ext.y - t_side + t_foldover) / 2);
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

    translate(v=[ext.x / 2, 0, 0]) {
      for (i = [-1, 1]) {
        translate(v=[0, 0, i * (ext.z / 2 - t_wall + t_foldover)])
          chamfer_edge_mask(l=int.y, chamfer=foldover_chamfer, orient=FRONT);

        translate(v=[0, 0, i * (ext.z / 2)])
          chamfer_edge_mask(l=ext.y, chamfer=foldover_chamfer, orient=FRONT);

        translate(v=[0, i * (ext.y / 2 - t_side + t_foldover), 0])
          chamfer_edge_mask(l=int.z, chamfer=foldover_chamfer, orient=BOTTOM);

        translate(v=[0, i * (ext.y / 2), 0])
          chamfer_edge_mask(l=ext.z, chamfer=foldover_chamfer, orient=BOTTOM);
      }
    }

    translate(v=[ext.x / 2 - w_foldover, 0, 0]) {
      for (i = [-1, 1]) {
        translate(v=[0, 0, i * (ext.z / 2 - t_wall)])
          chamfer_edge_mask(l=int.y, chamfer=foldover_chamfer, orient=FRONT);

        translate(v=[0, i * (ext.y / 2 - t_side), 0])
          chamfer_edge_mask(l=int.z, chamfer=foldover_chamfer, orient=BOTTOM);
      }
    }
  }

  module mask_pins() {
    for (i = [-1, 1]) {
      for (x = [-ext.x / 2, 0, ext.x / 2 - w_foldover * 2]) {
        translate(v=[x, i * (ext.y + int.y) / 4, 0])
          cylinder(d=d_pin, h=l_pin, center=true);
      }
    }
  }

  module mask_int() {
    cube(size=int, center=true);

    translate(v=[-int.x / 2, 0, 0])
      rotate(a=90, v=[1, 0, 0])
        cylinder(h=int.y, d=int.z, center=true);
  }

  module body() {
    cuboid(
      size=ext,
      chamfer=shell_chamfer,
      edges=[
        TOP + FRONT,
        BOTTOM + FRONT,
        TOP + BACK,
        BOTTOM + BACK,
      ],
    );

    translate(v=[-ext.x / 2, 0, 0]) {
      rotate(a=90, v=[1, 0, 0]) {
        left_half()
          cyl(d=ext.z, h=ext.y, chamfer=shell_chamfer);
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

module leather_wall(c, front) {
  b_flat = [ext.x, ext.y + t_leather_overhang * 2, t_leather];

  b_end = [2 * r_end_quant * PI / 4 + t_leather_overhang, b_flat.y, b_flat.z];

  b_finner = [w_foldover, int.y, t_leather];

  b_fedge = [t_wall - t_foldover + t_leather * 2, ext.y + t_leather_overhang * 2];
  p_fedge = poly_foldover_edge(b_fedge);

  module mask_flat_stitches() {
    x0 = -ext.x / 2;
    x1 = ext.x / 2;

    for (i = [-1, 1])
      translate(v=[0, i * ( (ext.y) / 2 - hole_stitch_inset), ext.z / 2])
        mask_stitches_long(ax=0, az=i * a_stitch, x0=x0, x1=x1);
  }

  module mask_end_stitches_folded() {
    for (i = [-1, 1])
      translate(v=[-ext.x / 2, 0, 0])
        mask_stitches_semicircle(ax=0, ay=0, az=i * -a_stitch, dy=i * (ext.y / 2 - hole_stitch_inset), dz=ext.z / 2);

    translate(v=[-ext.x / 2, 0, 0])
      rotate(a=-90 + a_end_quant / 2, v=[0, 1, 0])
        mask_stitches_wide(az=90, dx=0, dz=ext.z / 2);
  }

  module mask_end_stitches_unfolded() {
    x0 = -ext.x / 2 - round_nearest(b_end.x, hole_stitch_spacing);
    x1 = -ext.x / 2;

    for (i = [-1, 1])
      translate(v=[0, i * ( (ext.y) / 2 - hole_stitch_inset), ext.z / 2])
        mask_stitches_long(ax=0, az=i * a_stitch, x0=x0, x1=x1);

    mask_stitches_wide(az=90, dx=-ext.x / 2 - b_end.x + hole_stitch_spacing / 2 + t_leather_overhang, dz=ext.z / 2);
  }

  module mask_end_stitches() {
    if (fold_leather)
      mask_end_stitches_folded();
    else
      mask_end_stitches_unfolded();
  }

  module end_unfolded() {
    translate(v=[-(b_flat.x + b_end.x) / 2, 0, 0])
      cube(b_end, center=true);
  }

  module end_folded() {
    translate(v=[-(b_flat.x) / 2, 0, -r_end_quant + t_leather / 2])
      rotate(a=90, v=[1, 0, 0])
        left_half()
          back_half()
            difference() {
              cylinder(h=b_end.y, r=r_end_quant, center=true);
              cylinder(h=b_end.y, r=r_end_quant - t_leather, center=true);
            }
  }

  module end() {
    if (fold_leather)
      end_folded();
    else
      end_unfolded();
  }

  module foldover_edge() {
    folded = [
      (ext.x + t_leather) / 2,
      0,
      (ext.z - b_fedge.x) / 2 + t_leather,
    ];
    shifted = [
      (ext.x + b_fedge.x) / 2,
      0,
      (ext.z + t_leather) / 2,
    ];

    if (fold_leather)
      translate(v=folded)
        rotate(a=90, v=[0, 1, 0])
          linear_extrude(h=t_leather, center=true)
            polygon(p_fedge);
    else
      translate(v=shifted)
        linear_extrude(h=t_leather, center=true)
          polygon(p_fedge);
  }

  module foldover_inner() {
    folded = [
      (ext.x + b_finner.x) / 2 - b_finner.x,
      0,
      (ext.z - b_finner.z) / 2 - t_wall + t_foldover,
    ];
    shifted = [
      (ext.x + b_finner.x) / 2 + b_fedge.x,
      0,
      (ext.z + b_finner.z) / 2,
    ];

    translate(v=fold_leather ? [0, 0, 0] : shifted)
      rotate(a=fold_leather ? 0 : 180, v=[0, 1, 0])
        translate(v=fold_leather ? [0, 0, 0] : -folded)
          difference() {
            translate(v=folded)
              cube(b_finner, center=true);
            mask_stitches_wide(az=a_stitch, dx=ext.x / 2 - hole_stitch_inset, dz=(ext.z - t_wall) / 2);
            if (front)
              mask_magnet();
            else
              mirror(v=[0, 0, 1])
                mask_hinge();
          }
  }

  difference() {
    translate(v=[0, 0, (ext.z + b_flat.z) / 2]) {
      color(c=c[1])
        cube(b_flat, center=true);
      color(c=c[0])
        end();
    }

    mask_flat_stitches();

    mask_end_stitches();

    mask_stitches_wide(az=a_stitch, dx=ext.x / 2 - hole_stitch_inset, dz=ext.z / 2);
  }

  color(c=c[0])
    foldover_edge();

  color(c=c[1])
    foldover_inner();
}

module leather_side(c) {
  d = ext.z + t_leather_overhang * 2;

  b_finner = [w_foldover, t_leather, int.z];

  b_fedge = [t_side - t_foldover + t_leather * 2, ext.z + t_leather_overhang * 2];
  p_fedge = poly_foldover_edge(b_fedge);

  dz_stitch = ext.z / 2 - hole_stitch_inset;

  module mask_long_stitches() {
    for (i = [-1, 1])
      translate(v=[0, ext.y / 2, i * dz_stitch])
        rotate(a=-90, v=[1, 0, 0])
          mask_stitches_long(ax=0, az=i * a_stitch, x0=-ext.x / 2, x1=ext.x / 2);
  }

  module mask_round_stitches() {
    translate(v=[-ext.x / 2, 0, 0])
      mask_stitches_semicircle(ax=90, ay=a_stitch, az=0, dy=ext.y / 2, dz=dz_stitch);
  }

  module foldover_edge() {
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

    if (fold_leather)
      translate(v=folded)
        rotate(a=-90, v=[0, 0, 1])
          rotate(a=90, v=[1, 0, 0])
            linear_extrude(h=t_leather, center=true)
              polygon(p_fedge);
    else
      translate(v=shifted)
        rotate(a=90, v=[1, 0, 0])
          linear_extrude(h=t_leather, center=true)
            polygon(p_fedge);
  }

  module foldover_inner() {
    folded = [
      (ext.x + b_finner.x) / 2 - b_finner.x,
      (ext.y - b_finner.y) / 2 - t_side + t_foldover,
      0,
    ];
    shifted = [
      (ext.x + b_finner.x) / 2 + b_fedge.x,
      (ext.y + t_leather) / 2,
      0,
    ];

    translate(v=fold_leather ? [0, 0, 0] : shifted)
      rotate(a=fold_leather ? 0 : 180, v=[0, 1, 0])
        translate(v=fold_leather ? [0, 0, 0] : -folded)
          difference() {
            translate(v=folded)
              cube(b_finner, center=true);
            mask_stitches_foldover_deep(ay=a_stitch, dy=(ext.y - t_side) / 2);
            mask_magnet();
            mask_hinge();
          }
  }

  module body() {
    translate(v=[0, (ext.y + t_leather) / 2, 0]) {
      cube([ext.x, t_leather, d], center=true);

      translate(v=[-ext.x / 2, 0, 0])
        rotate(a=90, v=[1, 0, 0])
          cyl(h=t_leather, d=d, center=true);
    }
  }

  difference() {
    color(c=c[1])
      body();

    mask_long_stitches();

    mask_round_stitches();

    mask_stitches_foldover_deep(ay=a_stitch, dy=ext.y / 2);
  }

  color(c=c[0])
    foldover_edge();

  color(c=c[1])
    foldover_inner();
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
    leather_wall(c=brown_pair(0), front=true);

  if (show_leather_wall_back)
    mirror(v=[0, 0, 1])
      leather_wall(c=brown_pair(1), front=false);

  if (show_leather_side_right)
    leather_side(c=brown_pair(2));

  if (show_leather_side_left)
    mirror(v=[0, 1, 0])
      leather_side(c=brown_pair(3));
}
