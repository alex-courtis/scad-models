include <BOSL2/std.scad>
include <lib/geom.scad>

w = 150;
t_side = 3;
t_end = 6;

font = "Inter"; //:style=Bold";
font_size = 4;
text_depth = 0.6;

// l = 75;
// h = 15;
// n_holes = 4;
// magnets = [2, 3, 4, 5, 6, 6, 8, 10, 10, 12, 12];

l = 75;
h = 15;
n_holes = 5;
magnets = [2, 3, 4, 5, 6, 8, 8, [10, 5], 10, 10, 12];

// l = 75;
// h = 27.5;
// n_holes = 4;
// magnets = [20, 15, 20, 15, 20];
// // magnets = [15, 20, 15, 20, 15];

// l = 112.5;
// h = 27.5;
// n_holes = 4;
// magnets = [25, 25, 25];

// l = 75;
// h = 40;
// n_holes = 5;
// magnets = [[15, 25], [10, 20], [10, 30], [10, 20], [15, 25]];

d_hole = 2.25;
// t_base_hole = 1.2;
t_base_hole = 0;

// shift circular slot up by d * rat_up
rat_up = 0.25;

// prismoid lip for rect slots, half removed from lip_w
lip_w = 3;
lip_h = 3;

// enlarge: slots / magnets
rat_slot = 1.03;

echo(magnets=magnets);
slots = magnets * rat_slot;
echo(slots=slots);

w_slots = [for (s = magnets) is_list(s) ? s.x : s] * rat_slot;
echo(w_slots=w_slots);
sum_gaps = vector_sum(w_slots) - w_slots[0] / 2 - w_slots[len(w_slots) - 1] / 2;
echo(sum_gaps=sum_gaps);
actual_gaps = w - vector_sum(w_slots) - t_side * 2;
echo(actual_gaps=actual_gaps);
ratio_gaps = actual_gaps / sum_gaps;
echo(ratio_gaps=ratio_gaps);

$fn = 200;

module slot_cyl(i) {
  d = slots[i];
  translate(v=[0, -t_end / 2, -d / 2 + d / 2 * rat_up]) {
    rotate(a=-90, v=[1, 0, 0]) {
      cylinder(h=l - t_end, d=d, center=true);
    }
  }
}

module slot_rect(i) {
  x = slots[i].x;
  y = l - t_end;
  z = slots[i].y;

  translate(v=[0, -t_end / 2, 0]) {
    translate(v=[0, 0, -z / 2 - lip_h]) {
      cuboid(
        size=[x, y, z],
      );
    }

    z_lip = lip_h + 0.001;
    translate(v=[0, 0, -z_lip]) {
      prismoid(
        size1=[x, y],
        size2=[x - lip_w * 2, y],
        h=z_lip,
      );
    }

    translate(v=[0, 0, -lip_h / 2]) {
      cuboid(size=[x - lip_w, y, lip_h]);
    }
  }
}

module txt(i) {
  magnet = magnets[i];
  s = is_list(magnet) ? str(magnet.x, "x", magnet.y) : str(magnet);

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
  l_slot = l - t_end;
  translate(v=[0, -l_slot / 2 - t_end / 2 + d_hole, -h + t_base_hole]) {
    for (i = [0:n_holes - 1]) {
      translate(v=[0, i * l_slot / n_holes, 0])
        cylinder(h=h, d=d_hole);
    }
  }
}

module slots(i = 0) {
  if (i < len(slots)) {

    rect = is_list(slots[i]);

    x = rect ? slots[i].x : slots[i];

    half_gap_prev = (i == 0 ? 0 : x / 2) * ratio_gaps;
    translate(v=[half_gap_prev, 0, 0]) {

      translate(v=[x / 2, 0, 0]) {
        if (rect) {
          slot_rect(i);
        } else {
          slot_cyl(i);
        }
        txt(i);
        holes();

        half_gap_next = x / 2 * ratio_gaps;
        translate(v=[half_gap_next, 0, 0]) {
          translate(v=[x / 2, 0, 0]) {
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
