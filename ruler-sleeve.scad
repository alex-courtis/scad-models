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
echo(square_sliding_walls=square_sliding_walls);

square_sliding_inner = square_sliding + 2 * square_gap;
square_sliding_outer = square_sliding_inner + square_sliding_walls;
echo(square_sliding_outer=square_sliding_outer);

// just tune these to match outer
square_sliding_angle = 5.0;
square_sliding_cutout = 20;
square_sliding_shift = [1, 0, 1];

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
echo(square_small_outer=square_small_outer);

square_small_conjoined_outer = [square_small_outer.x, square_small_outer.y, square_sliding_outer.z];
echo(square_small_conjoined_outer=square_small_conjoined_outer);

// just tune these to match outer
square_small_angle = 6.5;
square_small_cutout = 7.5;
square_small_shift = [0.8, 0, 0.6];

square_small_conjoined_angle = 9.5;
square_small_conjoined_shift = [0.9, 0, 0];
square_small_conjoined_plate = 10;

/* [Pocket Inserts] */

insert_small_height = 44;
insert_small_width = 53;
insert_small_thickness = [9, 14];

insert_large_height = 85;
insert_large_width = 53;
insert_large_thickness = [9, 14];

insert_wall_side = d_filament * 6;
echo(insert_wall_side=insert_wall_side);

insert_wall_back = d_filament * 8;
echo(insert_wall_back=insert_wall_back);

insert_floor = t_layer * 5;
echo(insert_floor=insert_floor);

square_sliding_insert = [square_sliding_outer.x, insert_large_width - square_sliding_outer.y, square_sliding_outer.z];

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
      translate(v=dxz_inner + [0, 0, 0]) {

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
              inner.x / 2,
              0,
              outer.z / 4,
            ]
          )
            cuboid(
              [
                x_cutout * 2,
                inner.y,
                outer.z / 2,
              ]
            );
      }
  }
}

module insert(height, width, thickness) {

  difference() {
    color(c="peru")
      diff()
        prismoid(
          size1=[width, thickness[0]],
          size2=[width, thickness[1]],
          shift=[0, (thickness[0] - thickness[1]) / 2],
          h=height,
          orient=BACK,
          anchor=CENTER + BACK,
          rounding=insert_wall_side / 2,
        ) {
          edge_profile(
            edges=[
              TOP + LEFT,
              TOP + RIGHT,
              TOP + BACK,
            ],
          ) {
            mask2d_roundover(r=insert_wall_side * 2 / 3);
          }
          edge_profile(
            edges=[
              BOTTOM,
              TOP + FRONT,
            ],
            excess=2,
          ) {
            mask2d_roundover(r=insert_wall_back);
          }
        }
    ;

    color(c="sienna")
      translate(
        v=[0, insert_wall_back / 2, insert_floor]
      )
        cuboid(
          [width, height, thickness[1]] - [insert_wall_side * 2, insert_wall_back, 0],
          anchor=BOTTOM,
          rounding=insert_wall_side / 2,
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
  // rotate for print
  rotate(a=90, v=[1, 0, 0]) {

    // twin rulers
    translate(v=[ruler_long_outer.x / 2, ruler_long_outer.y / 2, 0])
      rulers();

    // large square
    translate(v=[square_large_outer.x / 2, square_large_outer.y / 2, 20])
      try_square(
        outer=square_large_outer,
        inner=square_large_inner,
        a=square_large_angle,
        x_cutout=square_large_cutout,
        dxz_inner=square_large_shift,
      );

    // small square
    translate(v=[square_small_outer.x / 2, square_small_outer.y / 2, 40])
      try_square(
        outer=square_small_outer,
        inner=square_small_inner,
        a=square_small_angle,
        x_cutout=square_small_cutout,
        dxz_inner=square_small_shift,
      );

    // sliding square
    translate(v=[square_sliding_outer.x / 2, square_sliding_outer.y / 2, 60])
      try_square(
        outer=square_sliding_outer,
        inner=square_sliding_inner,
        a=square_sliding_angle,
        x_cutout=square_sliding_cutout,
        dxz_inner=square_sliding_shift,
      );

    // sliding square with pocket
    translate(v=[square_sliding_outer.x / 2, 0, 80]) {
      pocket_outer = square_sliding_insert + [0, square_chamfer, 0];
      pocket_inner = pocket_outer - [insert_wall_side, insert_wall_side, square_chamfer];
      difference() {
        union() {
          translate(v=[0, square_sliding_outer.y / 2, 0])
            try_square(
              outer=square_sliding_outer,
              inner=square_sliding_inner,
              a=square_sliding_angle,
              x_cutout=square_sliding_cutout,
              dxz_inner=square_sliding_shift,
            );

          color(c="white")
            translate(
              v=[
                0,
                square_sliding_insert.y / 2 - square_chamfer / 2 + square_sliding_outer.y,
                0,
              ]
            )
              cuboid(
                pocket_outer,
                chamfer=square_chamfer,
                edges=[
                  BACK,
                  LEFT + TOP,
                  LEFT + BOTTOM,
                  RIGHT + TOP,
				  FRONT + RIGHT,
                ],
              );
        }

        translate(
          v=[
            insert_wall_side / 2,
            square_sliding_insert.y / 2 - square_chamfer / 2 + square_sliding_outer.y - insert_wall_side / 2,
            square_chamfer / 2,
          ]
        )
          cuboid(
            pocket_inner,
            chamfer=square_chamfer,
            edges=[
              BOTTOM + LEFT,
              BOTTOM + BACK,
              BOTTOM + FRONT,
              LEFT + FRONT,
              LEFT + BACK,
            ],
          );
      }
    }

    // conjoined sliding and small square
    translate(v=[0, 0, 100]) {
      translate(v=[square_sliding_outer.x / 2, square_sliding_outer.y / 2, 0])
        try_square(
          outer=square_sliding_outer,
          inner=square_sliding_inner,
          a=square_sliding_angle,
          x_cutout=square_sliding_cutout,
          dxz_inner=square_sliding_shift,
        );

      translate(v=[square_small_conjoined_outer.x / 2, square_small_conjoined_outer.y / 2 + square_sliding_outer.y - square_chamfer * 2, 0]) {
        try_square(
          outer=square_small_conjoined_outer,
          inner=square_small_inner,
          a=square_small_conjoined_angle,
          x_cutout=square_small_cutout,
          dxz_inner=square_small_conjoined_shift,
        );

        color(c="brown")
          translate(v=[0, (square_small_conjoined_outer.y + square_small_conjoined_plate) / 2 - square_chamfer, -square_small_conjoined_outer.z / 2 + square_chamfer * 3 / 2])
            cuboid(
              [square_small_conjoined_outer.x, square_small_conjoined_plate + square_chamfer * 2, square_chamfer * 3],
              chamfer=square_chamfer,
              edges=[
                TOP + LEFT,
                TOP + RIGHT,
                BOTTOM + LEFT,
                BOTTOM + RIGHT,
                BACK,
              ]
            );
      }
    }
  }

  // insert small
  translate(v=[0, 20, 0])
    translate(v=[insert_small_width / 2, insert_small_height / 2, 0])
      insert(
        height=insert_small_height,
        width=insert_small_width,
        thickness=insert_small_thickness,
      );

  // insert large
  translate(v=[0, 80, 0])
    translate(v=[insert_large_width / 2, insert_large_height / 2, 0])
      insert(
        height=insert_large_height,
        width=insert_large_width,
        thickness=insert_large_thickness,
      );
}
