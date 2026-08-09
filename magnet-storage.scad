include <BOSL2/std.scad>
include <lib/geom.scad>

w = 150;

t_end = 6;
font = "Inter"; //:style=Bold";
font_size = 4;
text_depth = 0.6;

// l = 75;
// h = 15;
// d_magnets = [2, 3, 4, 5, 6, 6, 8, 10, 10, 12, 12];
// t_side = 3;

l = 75;
h = 27.5;
t_side = 3;
d_magnets = [20, 15, 20, 15, 20];
// d_magnets = [15, 20, 15, 20, 15];

d_hole = 2.15;
n_holes = 4;
t_base_hole = 1.2;

// shift slot up by d * rat_up
rat_up = 0.25;

// d_slots / d_magnets
rat_slot = 1.03;

echo(d_magnets=d_magnets);
d_slots = vector_multiply(d_magnets, rat_slot);
echo(d_slots=d_slots);

sum_gaps = vector_sum(d_slots) - d_slots[0] / 2 - d_slots[len(d_slots) - 1] / 2;
echo(sum_gaps=sum_gaps);
actual_gaps = w - vector_sum(d_slots) - t_side * 2;
echo(actual_gaps=actual_gaps);
ratio_gaps = actual_gaps / sum_gaps;
echo(ratio_gaps=ratio_gaps);

$fn = 200;

module slot(d) {
  translate(v=[0, -t_end / 2, -d / 2 + d / 2 * rat_up]) {
    rotate(a=-90, v=[1, 0, 0]) {
      cylinder(h=l - t_end, d=d, center=true);
    }
  }
}

module txt(s) {
  translate(v=[0, (l - t_end) / 2, -text_depth / 2]) {
    linear_extrude(h=text_depth, center=true) {
      text(
        font=font,
        size=font_size,
        text=s,
        valign="center",
        halign="center",
      );
    }
  }
}

module holes() {
  translate(v=[0, -l / 2 + t_end, -h + t_base_hole]) {
    for (i = [0:n_holes - 1]) {
      translate(v=[0, i * l / n_holes, 0])
        cylinder(h=h, d=d_hole);
    }
  }
}

module slots(i = 0) {
  if (i < len(d_slots)) {

    d = d_slots[i];

    half_gap_prev = (i == 0 ? 0 : d / 2) * ratio_gaps;
    translate(v=[half_gap_prev, 0, 0]) {

      translate(v=[d / 2, 0, 0]) {
        slot(d=d);
        txt(s=str(d_magnets[i]));
        holes();

        half_gap_next = d / 2 * ratio_gaps;
        translate(v=[half_gap_next, 0, 0]) {

          translate(v=[d / 2, 0, 0]) {
            slots(i + 1);
          }
        }
      }
    }
  }
}

module outer() {
  translate(v=[w / 2, 0, h / 2]) {
    cuboid(
      size=[w, l, h],
      rounding=1.2,
    );
  }
}

render() {
  difference() {
    outer();
    translate(v=[t_side, 0, h])
      slots();
  }
}
