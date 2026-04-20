include <BOSL2/std.scad>
include <lib/geom.scad>

d_filament = 0.4; // [0.2:0.2:0.8]
t_layer = 0.2; // [0.02:0.01:4]

/* [Inner Dimensions] */

ruler_gap = [
  0,
  1.5,
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

inner_large = ruler_large + 2 * ruler_gap;

inner_small = ruler_small + 2 * ruler_gap;

/* [Outer Dimensions] */

t_wall_end = d_filament * 3;
t_wall_side = t_layer * 4;
t_wall_long = d_filament * 2;

outer_chamfer = t_wall_long;

// no top, one end
outer_walls = [
  t_wall_end,
  t_wall_side * 2,
  t_wall_long * 2,
];
bottom_large = inner_large + outer_walls;

bottom_small = inner_small + outer_walls;

dx_large = 15;
dx_small = 10;

$fn = 200; // [0:1:500]

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

module holder(bottom, inner, dx, chamfer_edges) {
  difference() {
    cuboid(
      chamfer=outer_chamfer,
      bottom,
      edges=chamfer_edges,
    );

    inner_mask(inner, bottom);

    translate(
      v=[
        bottom.x - dx,
        t_wall_side,
        t_wall_long,
      ]
    )
      cuboid(bottom);
  }
}

render() {
  color(c="green")
    holder(
      bottom=bottom_large,
      inner=inner_large,
      dx=dx_large,
      chamfer_edges=[
        // LEFT + TOP,
        // LEFT + BOTTOM,
        // LEFT + FRONT,
        // LEFT + BACK,
        // RIGHT + BACK,
        // RIGHT + TOP,
		BOTTOM,
		LEFT,
		RIGHT + BACK,
		// TOP,
      ]
    );

  color(c="orange")
    translate(
      v=[
        (bottom_large.x - bottom_small.x) / 2 - dx_large,
        0,
        bottom_large.z - t_wall_long,
      ]
    )
      holder(
        bottom=bottom_small,
        inner=inner_small,
        dx=dx_small,
        chamfer_edges=[
		TOP + FRONT,
		TOP + BACK,
		TOP + LEFT,
		// FRONT,
          // LEFT + TOP,
          // LEFT + FRONT,
          // LEFT + BACK,
          // RIGHT + BACK,
          // RIGHT + TOP,
        ]
      );
}
