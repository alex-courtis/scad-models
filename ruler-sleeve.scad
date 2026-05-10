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

ruler_short = [
  110,
  15,
  0.5,
];

ruler_long = [
  160,
  15,
  0.5,
];

ruler_walls = [
  1 * d_filament * 3,
  2 * t_layer * 10,
  2 * d_filament * 3,
];
echo(ruler_walls=ruler_walls);

ruler_chamfer = ruler_walls.z / 2;
echo(ruler_chamfer=ruler_chamfer);

ruler_long_cutout = 15;

ruler_short_cutout = 10;

ruler_long_inner = ruler_long + 2 * ruler_gap;

ruler_short_inner = ruler_short + 2 * ruler_gap + [ruler_long_cutout, 0, 0];

ruler_long_outer = ruler_long_inner + ruler_walls;

ruler_short_outer = ruler_short_inner + ruler_walls;

/* [Square Dimensions] */

square_gap = [
  0,
  0.75,
  0.15,
];

square_chamfer = d_filament * 3;
echo(square_chamfer=square_chamfer);

/* [Square Large] */

square_large = [
  97.5 + 1,
  16.3,
  1.8,
];

square_large_walls = [
  1 * d_filament * 3,
  2 * t_layer * 12,
  2 * d_filament * 10,
];
echo(square_large_walls=square_large_walls);

square_large_inner = square_large + 2 * square_gap;
square_large_outer = square_large_inner + square_large_walls;

// just tune these to match outer
square_large_angle = 4.5;
square_large_cutout = 20;
square_large_shift = [1, 0, 1];

/* [Square Small] */

square_small = [
  35 + 1,
  16.3,
  1.8,
];

square_small_walls = [
  1 * d_filament * 3,
  2 * t_layer * 12,
  2 * d_filament * 7,
];
echo(square_small_walls=square_small_walls);

square_small_inner = square_small + 2 * square_gap;
square_small_outer = square_small_inner + square_small_walls;

// just tune these to match outer
square_small_angle = 6.5;
square_small_cutout = 7.5;
square_small_shift = [0.8, 0, 0.6];

/* [Square Sliding] */

square_sliding = [
  74 + 1,
  19.6,
  2,
];

square_sliding_walls = [
  1 * d_filament * 3,
  2 * t_layer * 12,
  2 * d_filament * 10,
];

square_sliding_inner = square_sliding + 2 * square_gap;
square_sliding_outer = square_sliding_inner + square_sliding_walls;

// just tune these to match outer
square_sliding_angle = 5.0;
square_sliding_cutout = 20;
square_sliding_shift = [1, 0, 1];

/* [Pocket Inserts] */

insert_small_height = 37;
insert_small_width = 54;
insert_small_bottom_thickness = 8;
insert_small_top_thickness = 12;
insert_wall = d_filament * 3;
insert_floor = t_layer * 5;

echo(insert_wall=insert_wall);
echo(insert_floor=insert_floor);

module ruler(outer, inner, chamfer, chamfer_edges) {
  difference() {
    cuboid(
      chamfer=chamfer,
      outer,
      edges=chamfer_edges,
    );
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
}

module rulers() {
  module cutout_mask(outer, inner, dx, dz = 0, a = 0) {
    mask = [dx, inner.y, outer.z];

    translate(
      v=[
        outer.x / 2 + mask.x / 2 - dx,
        0,
        mask.z / 2 + dz,
      ]
    )
      rotate(a=-a, v=[0, 1, 0])
        cuboid(mask);
  }

  difference() {
    union() {
      color(c="darkgray")
        ruler(
          outer=ruler_long_outer,
          inner=ruler_long_inner,
          chamfer=ruler_chamfer,
          chamfer_edges=[
            LEFT,
            RIGHT + BOTTOM,
            RIGHT + FRONT,
            RIGHT + BACK,
          ]
        );

      color(c="pink")
        translate(
          v=[
            (ruler_long_outer.x - ruler_short_outer.x) / 2,
            0,
            ruler_long_outer.z - ruler_walls.z / 2,
          ]
        )
          ruler(
            outer=ruler_short_outer,
            inner=ruler_short_inner,
            chamfer=ruler_chamfer,
            chamfer_edges=[
              LEFT,
              RIGHT + TOP,
              RIGHT + FRONT,
              RIGHT + BACK,
            ]
          );
    }

    color(c="orange")
      cutout_mask(
        outer=ruler_long_outer,
        inner=ruler_long_inner,
        dx=ruler_long_cutout,
      );

    color(c="brown")
      cutout_mask(
        outer=ruler_long_outer,
        inner=ruler_long_inner,
        dx=ruler_long_cutout + ruler_short_cutout,
        dz=ruler_long_outer.z / 2 + ruler_short_outer.z / 2 - ruler_walls.z / 2,
      );
  }
}

module try_square(outer, inner, a, x_cutout, dxz_inner) {
  difference() {

    color(c="steelblue")
      cuboid(
        outer,
        chamfer=square_chamfer,
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

module insert_small() {

  difference() {
    color(c="peru")
      diff()
        prismoid(
          size1=[insert_small_width, insert_small_bottom_thickness],
          size2=[insert_small_width, insert_small_top_thickness],
          shift=[0, (insert_small_bottom_thickness - insert_small_top_thickness) / 2],
          h=insert_small_height,
          orient=BACK,
          anchor=CENTER + BACK,
          rounding=insert_wall / 2,
        ) {
          edge_profile(
            edges=[
              FRONT + TOP,
              FRONT + BOTTOM,
              BACK + BOTTOM,
            ],
            excess=2,
          ) {
            mask2d_roundover(r=insert_wall / 2);
          }
        }
    ;

    color(c="sienna")
      translate(
        v=[0, insert_wall / 2, insert_floor]
      )
        cuboid(
          [insert_small_width, insert_small_height, insert_small_top_thickness] - [insert_wall * 2, insert_wall, 0],
          anchor=BOTTOM,
          rounding=insert_wall / 2,
          edges=[
            BOTTOM + FRONT,
            BOTTOM + LEFT,
            BOTTOM + RIGHT,
            FRONT + RIGHT,
            FRONT + LEFT,
          ],
        );
  }
}

render() {
  rotate(a=90, v=[1, 0, 0]) {
    translate(v=[ruler_long_outer.x / 2, ruler_long_outer.y / 2, 0])
      rulers();

    translate(v=[square_large_outer.x / 2, square_large_outer.y / 2, 20])
      try_square(
        outer=square_large_outer,
        inner=square_large_inner,
        a=square_large_angle,
        x_cutout=square_large_cutout,
        dxz_inner=square_large_shift,
      );

    translate(v=[square_small_outer.x / 2, square_small_outer.y / 2, 40])
      try_square(
        outer=square_small_outer,
        inner=square_small_inner,
        a=square_small_angle,
        x_cutout=square_small_cutout,
        dxz_inner=square_small_shift,
      );

    translate(v=[square_sliding_outer.x / 2, square_sliding_outer.y / 2, 60])
      try_square(
        outer=square_sliding_outer,
        inner=square_sliding_inner,
        a=square_sliding_angle,
        x_cutout=square_sliding_cutout,
        dxz_inner=square_sliding_shift,
      );
  }

  translate(v=[insert_small_width / 2, insert_small_height, 0])
   insert_small();
}
