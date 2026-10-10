include <BOSL2/std.scad>
include <lib/geom.scad>

// base.z is rounding
base = [140, 140, 12];
h = 40;

// xy only, actual size reduces by inset
t_wall = 1.6;
t_bracket = 6;

// clockwise
round_top = [40, 50, 10, 20];
inset_top = [-10, -35, 10, 10];

inset_bolt = 7.5;
d_bolt = 6;

$fn = 200;

module shroud() {

  module top(inner) {
    rounding = round_top[0] + (inner ? -t_wall : 0);

    b = base - (inner ? [t_wall * 2, t_wall * 2, 0] : [0, 0, 0]);

    translate(v=[0, 0, h - base.z / 2]) {

      translate(v=[inset_top[1], inset_top[0], 0]) {
        cuboid(
          size=[b.x, b.y, 0],
          rounding=rounding,
		  except = [TOP, BOTTOM],
        );
      }
    }
  }

  module bas(inner) {
    s = base + (inner ? [-t_wall * 2, -t_wall * 2, 0] : [0, 0, 0]);

    difference() {
      cuboid(
        size=s,
        rounding=s.z,
        except=[
          BOTTOM,
        ],
      );
    }
  }

  module bracket() {
    intersection() {
      bas(inner=false);

      translate(v=[base.x / 2 - inset_bolt, base.y / 2 - inset_bolt, ( -base.z + t_bracket) / 2])

        difference() {
          cuboid(
            size=[inset_bolt * 2, inset_bolt * 2, t_bracket],
            rounding=t_bracket,
            edges=[FRONT + LEFT],
          );
          cyl(d=d_bolt, h=t_bracket);
        }
    }
  }

  module brackets() {
    for (a = [0, 90, 180, 270]) {
      rotate(a=a, v=[0, 0, 1])
        bracket();
    }
  }

  difference() {
    hull() {
      bas(inner=false);

      top(inner=false);
    }

    hull() {
      bas(inner=true);

      top(inner=true);
    }
  }

  brackets();
}

render() {

  shroud();
}
