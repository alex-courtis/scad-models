include <BOSL2/std.scad>
include <lib/geom.scad>

// w = 210;
// l = 70;
// h = 15;
// d = [15, 2, 10, 3, 12, 6, 15, 5, 15];

w = 65;
l = 70;
h = 15;
d_magnets = [15, 6, 10, 3];

t_side = 3;
t_end = 3;

rat_up = 0.25;

rat_hole = 1.05;

echo(d_magnets=d_magnets);
d = vector_multiply(d_magnets, rat_hole);
echo(d=d);

sum_gaps = vector_sum(d) - d[0] / 2 - d[len(d) - 1] / 2;
echo(sum_gaps=sum_gaps);
actual_gaps = w - vector_sum(d) - t_side * 2;
echo(actual_gaps=actual_gaps);
ratio_gaps = actual_gaps / sum_gaps;
echo(ratio_gaps=ratio_gaps);

$fn = 200;

module hole(d) {
  translate(v=[0, t_end / 2, h / 2 - d / 2 + d / 2 * rat_up]) {
    rotate(a=90, v=[1, 0, 0]) {
      cylinder(h=l - t_end, d=d, center=true);
    }
  }
}

module h(i = 0) {
  if (i < len(d)) {

    half_gap_prev = (i == 0 ? 0 : d[i] / 2) * ratio_gaps;
    translate(v=[half_gap_prev, 0, 0]) {

      translate(v=[d[i] / 2, 0, 0]) {
        hole(d[i]);

        half_gap_next = d[i] / 2 * ratio_gaps;
        translate(v=[half_gap_next, 0, 0]) {

          translate(v=[d[i] / 2, 0, 0]) {
            h(i + 1);
          }
        }
      }
    }
  }
}

module outer() {
  cuboid(
    size=[w, l, h],
    rounding=1,
  );
}

render() {
  difference() {
    outer();
    translate(v=[-w / 2 + t_side, 0, 0])
      h();
  }
}
