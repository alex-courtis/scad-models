include <BOSL2/std.scad>
include <lib/geom.scad>

base = [140, 140, 12];

// total from base
height = 60;

// xy only, actual size reduces by inset
t_wall = 1.6;
t_bracket = 6;

round_base = 12;

// clockwise from corner
round_top = [90, 100, 50, 90];
inset_top = [
  [-35, -35],
  [-35, 30],
  [0, 30],
  [0, -35],
];

// clockwise from edge
cutouts = [
  [0, 0, 0],
  [-85, 25, 24],
  [0, 0, 0],
  [0, 0, 0],
];
cutout_rounding = 3;

inset_bolt = 7.5;
d_bolt = 6;

// clockwise signs for x/y corners
sxy = [[1, 1], [1, -1], [-1, -1], [-1, 1]];

$fn = 120;

module top(dt) {
  // some thickness is needed for hull
  h = 0.0001;

  for (i = [0:1:3])
    translate(
      v=[
        sxy[i].x * ( (base.x - round_top[i]) / 2 + inset_top[i][0]),
        sxy[i].y * ( (base.y - round_top[i]) / 2 + inset_top[i][1]),
        height - h / 2,
      ]
    )
      cylinder(d=round_top[i] - dt * 2, h=h, center=true);
}

module bottom(dt) {
  translate(v=[0, 0, base.z / 2])
    cuboid(
      size=base - [2 * dt, 2 * dt, 0],
      rounding=round_base,
      except=[
        BOTTOM,
      ],
    );
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
    }
}

module brackets() {
  for (a = [0, 90, 180, 270])
    rotate(a=a, v=[0, 0, 1])
      bracket();
}

module outer() {
  hull() {
    bottom(dt=0);
    top(dt=0);
  }
}

module inner() {
  hull() {
    bottom(dt=t_wall);
    top(dt=t_wall);
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
              rounding_edge_mask(l=base.y, r=cutout_rounding, excess=0);

        translate(v=[0, sxy[i].y * -base.y / 2, height])
          rotate(a=sxy[i].y * -90, v=[0, 0, 1])
            rotate(a=-90, v=[1, 0, 0])
              rounding_edge_mask(l=base.y, r=cutout_rounding, excess=0);
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
}
