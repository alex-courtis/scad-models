include <BOSL2/std.scad>
include <lib/geom.scad>

d_filament = 0.4; // [0.2:0.2:0.8]
t_layer = 0.2; // [0.02:0.01:4]
$fn = 200; // [0:1:500]

/* [Ruler Dimensions] */

ruler_gap = [
  0,
  1.2,
  0.4,
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

// no top, one end
outer_walls_ruler = [
  1 * d_filament * 3,
  2 * t_layer * 8,
  2 * d_filament * 2,
];

outer_chamfer_ruler = outer_walls_ruler.z / 2;

dx_large = 15;

dx_small = 10;

inner_ruler_large = ruler_large + 2 * ruler_gap;

inner_ruler_small = ruler_small + 2 * ruler_gap + [dx_large, 0, 0];

bottom_ruler_large = inner_ruler_large + outer_walls_ruler;

bottom_ruler_small = inner_ruler_small + outer_walls_ruler;

/* [Square Dimensions] */

square_gap = [
  0,
  2,
  1,
];

square_large = [
  97.5,
  16.3,
  1.8,
];

// no top, one end
outer_walls_square = [
  0,
  // 1 * d_filament * 3,
  2 * t_layer * 12,
  2 * d_filament * 8,
];

outer_chamfer_square = outer_walls_square.z / 6;

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

module holder(bottom, inner, chamfer, dx, chamfer_edges) {
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
      RIGHT + TOP,
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
        TOP,
      ]
    );
}

module cutout_mask(dx, dz) {
  mask = [dx, bottom_ruler_large.y, 20];

  translate(
    v=[
      bottom_ruler_large.x / 2 + mask.x / 2 - dx,
      outer_walls_ruler.z,
      mask.z / 2 + dz,
    ]
  )
    cuboid(mask);
}

module holder_square_large() {
  holder(
    bottom=bottom_square_large,
    inner=inner_square_large,
    chamfer=outer_chamfer_square,
    chamfer_edges=EDGES_ALL,
    // chamfer_edges=[
    //   LEFT,
    //   RIGHT + TOP,
    //   RIGHT + BACK,
    // ]
  );
}

render() {
  difference() {
    union() {
      color(c="lightgray")
        holder_ruler_bottom();

      color(c="pink")
        holder_ruler_top();
    }

    color(c="orange")
      cutout_mask(
        dx=dx_large,
        dz=0
      );

    color(c="brown")
      cutout_mask(
        dx=dx_large + dx_small,
        dz=bottom_ruler_large.z / 2 + bottom_ruler_small.z / 2 - outer_walls_ruler.z / 2,
      );
  }

  translate(v=[0, 50, 0])
    color(c="lightblue")
      holder_square_large();
}
