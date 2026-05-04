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

dx_large = 15;

dx_small = 10;

inner_ruler_large = ruler_large + 2 * ruler_gap;

inner_ruler_small = ruler_small + 2 * ruler_gap + [dx_large, 0, 0];

bottom_ruler_large = inner_ruler_large + outer_walls_ruler;

bottom_ruler_small = inner_ruler_small + outer_walls_ruler;

/* [Square Dimensions] */

square_large = [
  97.5,
  16.3,
  1.8,
];

// add thickness to width to account for chamfered inner
square_gap = [
  0,
  0.5 + square_large.z / 4,
  0.3,
];

outer_walls_square = [
  1 * d_filament * 3,
  2 * t_layer * 12,
  2 * d_filament * 8,
];

// just tune this to match outer_walls_square.z
a_square_large = 2;

dx_square_large = 10;

outer_chamfer_square = d_filament * 3;

inner_square_large = square_large + 2 * square_gap;

bottom_square_large = inner_square_large + outer_walls_square;

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

module holder(bottom, inner, chamfer, dx, chamfer_edges, a = 0) {
  difference() {
    cuboid(
      chamfer=chamfer,
      bottom,
      edges=chamfer_edges,
    );

    rotate(a=-a, v=[0, 1, 0])
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
      dx=dx_small,
      chamfer_edges=[
        LEFT,
        RIGHT + TOP,
        RIGHT + FRONT,
        RIGHT + BACK,
      ]
    );
}

module cutout_mask(bottom, inner, dx, dz) {
  mask = [dx, inner.y, bottom.z];

  translate(
    v=[
      bottom.x / 2 + mask.x / 2 - dx,
      0,
      mask.z / 2 + dz,
    ]
  )
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
        dx=dx_large,
        dz=0
      );

    color(c="brown")
      cutout_mask(
        bottom=bottom_ruler_large,
        inner=inner_ruler_large,
        dx=dx_large + dx_small,
        dz=bottom_ruler_large.z / 2 + bottom_ruler_small.z / 2 - outer_walls_ruler.z / 2,
      );
  }
}

module squares_large() {
  difference() {

    color(c="steelblue")
      holder(
        bottom=bottom_square_large,
        inner=inner_square_large,
        chamfer=outer_chamfer_square,
        chamfer_edges=EDGES_ALL,
        a=a_square_large,
      );

    color(c="orange")
      cutout_mask(
        bottom=bottom_square_large,
        inner=inner_square_large,
        dx=dx_square_large,
        dz=0,
      );
  }
}

render() {
  rotate(a=90, v=[1, 0, 0]) {
    translate(v=[bottom_ruler_large.x / 2, bottom_ruler_large.y / 2, 0])
      rulers();

    translate(v=[bottom_square_large.x / 2, bottom_square_large.y / 2, 20])
      squares_large();
  }
}
