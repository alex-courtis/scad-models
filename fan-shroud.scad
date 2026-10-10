include <BOSL2/std.scad>
include <lib/geom.scad>

base = [140, 140];
h = 40;

// xy only, actual size reduces by inset
t_wall = 1.6;
t_bracket = 6;

round_base = 12;

// clockwise
round_top = [40, 50, 10, 20];
inset_top = [-10, -35, 10, 10];

inset_bolt = 7.5;
d_bolt = 6;

$fn = 120;

module shroud() {

  module top(inner) {
    rounding = round_top[0] + (inner ? -t_wall : 0);

    size =
      inner ?
        [base.x - t_wall * 2, base.y - t_wall * 2, 0]
      : [base.x, base.y, 0];

    translate(v=[0, 0, h - round_base / 2]) {
      translate(v=[inset_top[1], inset_top[0], 0]) {
        cuboid(
          size=size,
          rounding=rounding,
          except=[TOP, BOTTOM],
        );
      }
    }
  }

  module bas(inner) {
    size =
      inner ?
        [base.x - t_wall * 2, base.y - t_wall * 2, round_base]
      : [base.x, base.y, round_base];

    cuboid(
      size=[size.x, size.y, size.z],
      rounding=round_base,
      except=[
        BOTTOM,
      ],
    );
  }

  module bracket() {
    translate(v=[base.x / 2, base.y / 2, ( -round_base + t_bracket) / 2])

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
      bas(inner=false);

      top(inner=false);
    }
  }

  module inner() {
    hull() {
      bas(inner=true);

      top(inner=true);
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
