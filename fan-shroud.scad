include <BOSL2/std.scad>
include <lib/geom.scad>

length = 140; // x
width = 140; // y
h = 40;

// xy only, actual size reduces by inset
t_wall = 1.6;
t_bracket = 6;

round_base = 12;

// clockwise
round_top = [80, 80, 80, 80];
inset_top = [
  [-35, -10],
  [-35, 10],
  [35, 10],
  [35, -10],
];

inset_bolt = 7.5;
d_bolt = 6;

// clockwise signs for x/y corners
sxy = [ [1, 1], [1, -1], [-1, -1], [-1, 1], ];

$fn = 120;

module shroud() {

  module top(dt) {
    // some thickness is needed for hull
    z = 0.0001;

    for (i = [0:1:3])
      translate(
        v=[
          sxy[i][0] * ( (length - round_top[i]) / 2 + inset_top[i][0]),
          sxy[i][1] * ( (width - round_top[i]) / 2 + inset_top[i][1]),
          h - round_base / 2 - z / 2,
        ]
      )
        cylinder(d=round_top[i] - dt * 2, h=z, center=true);
  }

  module base(dt) {
    cuboid(
      size=[length - dt * 2, width - dt * 2, round_base],
      rounding=round_base,
      except=[
        BOTTOM,
      ],
    );
  }

  module bracket() {
    translate(v=[length / 2, width / 2, ( -round_base + t_bracket) / 2])

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

  difference() {
    outer();

    inner();
  }

  intersection() {
    brackets();

    outer();
  }
}

render() {

  shroud();
}
