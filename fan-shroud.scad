include <BOSL2/std.scad>
include <lib/geom.scad>

debug_corners = false;
debug_edges = false;
debug_points = false;

base = [120, 120, 6];

// total from base
height = 50;

// xy only, actual size changes with curved hulls
t_wall = 1.6;
t_bracket = 6;

inset_bolt = 7.5;

// TODO M4
d_bolt = 5.5;

w_nut = 7.0; // M4
d_nut = w_nut * 2 / sqrt(3);
t_nut = 3;

// all quads are clockwise
// inset is from corner

sections = [
  object(
    round_corner=[inset_bolt, inset_bolt, inset_bolt, inset_bolt],
    round_edge=[15, 15, 0, 15],
    inset=[
      [0, 0],
      [0, 0],
      [0, 0],
      [0, 0],
    ],
    height=0,
  ),
  // object(
  //   round_corner=[inset_bolt, inset_bolt, inset_bolt, inset_bolt],
  //   round_edge=[15, 15, 0, 15],
  //   inset=[
  //     [0, 0],
  //     [0, 0],
  //     [0, 0],
  //     [0, 0],
  //   ],
  //   height=base.z,
  // ),
  object(
    round_corner=[20, 20, 30, 30],
    round_edge=[0, 0, 0, 0],
    inset=[
      [-50, -40],
      [-50, 30],
      [15, 45],
      [15, -40],
    ],
    height=50,
  ),
  // object(
  //   round_corner=[5, 5, 5, 5],
  //   round_edge=[0, 0, 0, 0],
  //   inset=[
  //     [0, 0],
  //     [0, 0],
  //     [0, 0],
  //     [0, 0],
  //   ],
  //   height=100,
  // ),
];

// clockwise from edge
cutouts = [
  [0, 0, 0],
  [0, 0, 0],
  [0, 0, 0],
  [0, 0, 0],
];
cutout_rounding = 3;

// clockwise signs for x/y corners
sxy = [[1, 1], [1, -1], [-1, -1], [-1, 1]];

$fn = 200;

module dbg_corners() {
  if (debug_corners)
    #children();
  else
    children();
}

module dbg_edges() {
  if (debug_edges)
    #children();
  else
    children();
}

module top(section, dt = 0) {
  // some volume is needed for hull
  eps = 0.0001;

  for (i = [0:1:3]) {
    // square when rounding less than wall
    r = section.round_corner[i] < t_wall * 2 ? eps : section.round_corner[i] - dt;
    translate(
      v=[
        sxy[i].x * (base.x / 2 - r + section.inset[i][0] - dt),
        sxy[i].y * (base.y / 2 - r + section.inset[i][1] - dt),
        section.height - eps / 2,
      ]
    ) {
      dbg_corners() {
        if (r == eps)
          cube(size=[r * 2, r * 2, eps], center=true);
        else
          cyl(r=r, h=eps);
      }
    }

    r_edge = section.round_edge[i] < t_wall * 2 ? eps : section.round_edge[i] - dt;
    if (r_edge > eps) {
      intersection() {
        translate(
          v=[
            sxy[i].x * (base.x / 2 - r_edge - dt),
            sxy[i].y * (base.y / 2 - r_edge - dt),
            // TODO allow this to be variable
            base.z,
          ]
        )
          dbg_edges()
            sphere(r=r_edge);

        // TODO intersect with current and previous section?
        translate(v=[0, 0, height / 2])
          cuboid(size=[base.x, base.y, height]);
      }
    }
  }
}

module bracket() {
  translate(v=[base.x / 2, base.y / 2, (t_bracket) / 2])

    difference() {
      cuboid(
        size=[inset_bolt * 4, inset_bolt * 4, t_bracket],
        rounding=inset_bolt,
        edges=[FRONT + LEFT],
      );

      translate(v=[-inset_bolt, -inset_bolt, 0])
        cyl(d=d_bolt, h=t_bracket);

      translate(v=[0, 0, (t_bracket - t_nut) / 2]) {
        translate(v=[-inset_bolt, -inset_bolt, 0])
          rotate(a=15, v=[0, 0, 1])
            cyl(d=d_nut, h=t_nut, $fn=6);

        translate(v=[-inset_bolt - d_nut * sqrt(2) / 4, -inset_bolt - d_nut * sqrt(2) / 4, 0])
          rotate(a=-45, v=[0, 0, 1])
            cuboid(size=[d_nut, d_nut, t_nut]);
      }
    }
}

module brackets() {
  for (a = [0, 90, 180, 270])
    rotate(a=a, v=[0, 0, 1])
      bracket();
}

module outer() {
  for (i = [1:1:len(sections) - 1]) {
    hull() {
      top(section=sections[i - 1]);
      top(section=sections[i]);
    }
  }
}

module inner() {
  for (i = [1:1:len(sections) - 1]) {
    hull() {
      top(section=sections[i - 1], dt=t_wall);
      top(section=sections[i], dt=t_wall);
    }
  }
}

module cutouts() {
  for (i = [0:1:3]) {
    if (cutouts[i] != [0, 0, 0]) {
      translate(
        v=[
          sxy[i].x * base.x + cutouts[i].x,
          sxy[i].y * base.y + cutouts[i].y,
          0,
        ]
      ) {
        translate(v=[0, 0, cutouts[i].z + height / 2])
          cuboid(
            size=[base.x, base.y, height],
            rounding=cutout_rounding,
          );

        translate(v=[sxy[i].x * -base.x / 2, 0, height])
          rotate(a=sxy[i].x == 1 ? 180 : 0, v=[0, 0, 1])
            rotate(a=-90, v=[1, 0, 0])
              rounding_edge_mask(l=base.y, r=cutout_rounding);

        translate(v=[0, sxy[i].y * -base.y / 2, height])
          rotate(a=sxy[i].y * -90, v=[0, 0, 1])
            rotate(a=-90, v=[1, 0, 0])
              rounding_edge_mask(l=base.y, r=cutout_rounding);
      }
    }
  }
}

module shroud() {
  difference() {
    union() {
      difference() {
        outer();

        inner();
      }

      intersection() {
        brackets();

        outer();
      }
    }

    cutouts();
  }
}

render() {
  shroud();

  if (debug_points) {
    point_marker(P=[30, -60, 40], h=5, r=1, t="B");
  }
}
