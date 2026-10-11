include <BOSL2/std.scad>
include <lib/geom.scad>

// base
x = 140;
y = 140;

// total from base
z = 60;

// xy only, actual size reduces by inset
t_wall = 1.6;
t_bracket = 6;

round_base = 12;

// clockwise from corner
round_top = [60, 80, 60, 60];
inset_top = [
  [-35, -30],
  [-35, 5],
  [5, 5],
  [5, -30],
];

// clockwise from edge
cutouts = [
  [0, 0, 0],
  [-90, 25, 30],
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
        sxy[i].x * ( (x - round_top[i]) / 2 + inset_top[i][0]),
        sxy[i].y * ( (y - round_top[i]) / 2 + inset_top[i][1]),
        z - h / 2,
      ]
    )
      cylinder(d=round_top[i] - dt * 2, h=h, center=true);
}

module base(dt) {
  translate(v=[0, 0, round_base / 2])
    cuboid(
      size=[x - dt * 2, y - dt * 2, round_base],
      rounding=round_base,
      except=[
        BOTTOM,
      ],
    );
}

module bracket() {
  translate(v=[x / 2, y / 2, (t_bracket) / 2])

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
    base(dt=0);
    top(dt=0);
  }
}

module inner() {
  hull() {
    base(dt=t_wall);
    top(dt=t_wall);
  }
}

module cutouts() {
  translate(v=[0, 0, z / 2]) {
    for (i = [0:1:3]) {
      if (cutouts[i] != [0, 0, 0]) {
        translate(
          v=[
            sxy[i].x * x + cutouts[i].x,
            sxy[i].y * y + cutouts[i].y,
            cutouts[i].z,
          ]
        ) {
          cuboid(
            size=[x, y, z],
            rounding=cutout_rounding,
          );

          translate(v=[sxy[i].x * -x / 2, 0, 0])
            rotate(a=sxy[i].x == 1 ? 180 : 0, v=[0, 0, 1])
              rotate(a=-90, v=[1, 0, 0])
                rounding_edge_mask(l=y, r=cutout_rounding, excess=0);

          translate(v=[0, sxy[i].y * -y / 2, 0])
            rotate(a=sxy[i].y * -90, v=[0, 0, 1])
              rotate(a=-90, v=[1, 0, 0])
                rounding_edge_mask(l=y, r=cutout_rounding, excess=0);
        }
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
