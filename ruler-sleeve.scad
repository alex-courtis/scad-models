include <BOSL2/std.scad>
include <lib/geom.scad>

d_filament = 0.4; // [0.2:0.2:0.8]
t_layer = 0.2; // [0.02:0.01:4]
$fn = 200; // [0:1:500]

/* [Ruler Dimensions] */

ruler_gap = [
  0,
  0.5,
  0.3,
];

ruler_small = [
  110,
  15,
  0.5,
];

ruler_large = [
  160,
  15,
  0.5,
];

outer_walls_ruler = [
  1 * d_filament * 3,
  2 * t_layer * 10,
  2 * d_filament * 3,
];

outer_chamfer_ruler = outer_walls_ruler.z / 2;

dxz_inner_ruler_large = 15;

dxz_inner_ruler_small = 10;

inner_ruler_large = ruler_large + 2 * ruler_gap;

inner_ruler_small = ruler_small + 2 * ruler_gap + [dxz_inner_ruler_large, 0, 0];

bottom_ruler_large = inner_ruler_large + outer_walls_ruler;

bottom_ruler_small = inner_ruler_small + outer_walls_ruler;

/* [Square Dimensions] */

square_gap = [
  0,
  0.8,
  0.2,
];

outer_chamfer_square = d_filament * 3;

/* [Square Large] */
square_large = [
  97.5,
  16.3,
  1.8,
];

outer_walls_square_large = [
  1 * d_filament * 3,
  2 * t_layer * 12,
  2 * d_filament * 10,
];

inner_square_large = square_large + 2 * square_gap;
outer_square_large = inner_square_large + outer_walls_square_large;

// just tune these to match outer
a_square_large = 4.5;
x_cutout_square_large = 20;
dxz_inner_square_large = [1, 0, 1];

/* [Square Small] */

square_small = [
  35,
  16.3,
  1.8,
];

outer_walls_square_small = [
  1 * d_filament * 3,
  2 * t_layer * 12,
  2 * d_filament * 5,
];

inner_square_small = square_small + 2 * square_gap;
outer_square_small = inner_square_small + outer_walls_square_small;

// just tune these to match outer
a_square_small = 5.5;
x_cutout_square_small = 10;
dxz_inner_square_small = [1, 0, 0.6];

/* [Square Sliding] */

square_sliding = [
  74,
  16.3,
  2,
];

outer_walls_square_sliding = [
  1 * d_filament * 3,
  2 * t_layer * 12,
  2 * d_filament * 10,
];

inner_square_sliding = square_sliding + 2 * square_gap;
outer_square_sliding = inner_square_sliding + outer_walls_square_sliding;

// just tune these to match outer
a_square_sliding = 5.0;
x_cutout_square_sliding = 20;
dxz_inner_square_sliding = [1, 0, 1];

module inner_mask(inner, outer) {
  translate(
    v=[
      (outer.x - inner.x) / 2,
      0,
      0,
    ]
  )
    cuboid(
      inner,
      chamfer=inner.z / 2,
      edges=[
        BACK + TOP,
        BACK + BOTTOM,
      ],
    );
}

module holder(bottom, inner, chamfer, chamfer_edges) {
  difference() {
    cuboid(
      chamfer=chamfer,
      bottom,
      edges=chamfer_edges,
    );
    inner_mask(inner, bottom);
  }
}

module holder_ruler_bottom() {
  holder(
    bottom=bottom_ruler_large,
    inner=inner_ruler_large,
    chamfer=outer_chamfer_ruler,
    chamfer_edges=[
      LEFT,
      RIGHT + BOTTOM,
      RIGHT + FRONT,
      RIGHT + BACK,
    ]
  );
}

module holder_ruler_top() {
  translate(
    v=[
      (bottom_ruler_large.x - bottom_ruler_small.x) / 2,
      0,
      bottom_ruler_large.z - outer_walls_ruler.z / 2,
    ]
  )
    holder(
      bottom=bottom_ruler_small,
      inner=inner_ruler_small,
      chamfer=outer_chamfer_ruler,
      chamfer_edges=[
        LEFT,
        RIGHT + TOP,
        RIGHT + FRONT,
        RIGHT + BACK,
      ]
    );
}

module cutout_mask(bottom, inner, dx, dz = 0, a = 0) {
  mask = [dx, inner.y, bottom.z];

  translate(
    v=[
      bottom.x / 2 + mask.x / 2 - dx,
      0,
      mask.z / 2 + dz,
    ]
  )
    rotate(a=-a, v=[0, 1, 0])
      cuboid(mask);
}

module rulers() {
  difference() {
    union() {
      color(c="darkgray")
        holder_ruler_bottom();

      color(c="pink")
        holder_ruler_top();
    }

    color(c="orange")
      cutout_mask(
        bottom=bottom_ruler_large,
        inner=inner_ruler_large,
        dx=dxz_inner_ruler_large,
      );

    color(c="brown")
      cutout_mask(
        bottom=bottom_ruler_large,
        inner=inner_ruler_large,
        dx=dxz_inner_ruler_large + dxz_inner_ruler_small,
        dz=bottom_ruler_large.z / 2 + bottom_ruler_small.z / 2 - outer_walls_ruler.z / 2,
      );
  }
}

module square(outer, inner, a, x_cutout, dxz_inner) {
  difference() {

    color(c="steelblue")
      cuboid(
        outer,
        chamfer=outer_chamfer_square,
        edges=EDGES_ALL,
      );

    rotate(a=-a, v=[0, 1, 0])
      translate(v=dxz_inner) {

        color(c="orange")
          cuboid(
            inner,
            rounding=inner.z / 2,
            edges=[
              BACK + BOTTOM,
              BACK + TOP,
            ],
          );

        color(c="blue")
          translate(
            v=[
              (inner.x - x_cutout) / 2,
              0,
              outer.z / 4,
            ]
          )
            cuboid(
              [
                x_cutout,
                inner.y,
                outer.z / 2,
              ]
            );
      }
  }
}

render() {
  rotate(a=90, v=[1, 0, 0]) {
    translate(v=[bottom_ruler_large.x / 2, bottom_ruler_large.y / 2, 0])
      rulers();

    translate(v=[outer_square_large.x / 2, outer_square_large.y / 2, 20])
      square(
        outer=outer_square_large,
        inner=inner_square_large,
        a=a_square_large,
        x_cutout=x_cutout_square_large,
        dxz_inner=dxz_inner_square_large,
      );

    translate(v=[outer_square_small.x / 2, outer_square_small.y / 2, 40])
      square(
        outer=outer_square_small,
        inner=inner_square_small,
        a=a_square_small,
        x_cutout=x_cutout_square_small,
        dxz_inner=dxz_inner_square_small,
      );

    translate(v=[outer_square_sliding.x / 2, outer_square_sliding.y / 2, 60])
      square(
        outer=outer_square_sliding,
        inner=inner_square_sliding,
        a=a_square_sliding,
        x_cutout=x_cutout_square_sliding,
        dxz_inner=dxz_inner_square_sliding,
      );
  }
}
