include <BOSL2/std.scad>
include <lib/geom.scad>

d_filament = 0.6; // [0.2:0.2:0.8]
t_layer = 0.3; // [0.01:0.01:0.5]
$fn = 200; // [1:1:500]

/* [What] */
show = "all"; // ["all", "padding", "core", "intersect"]

/* [Rod] */
d_peg_rod = 5.25; // [1:0.05:50]

/* [Peg] */
d_peg = 19.2; // [1:0.05:50]
l_peg = 45; // [1:1:100]

fil_rounding_rod_peg = 2; // [1:1:20]
rounding_rod_peg = d_filament * fil_rounding_rod_peg;
echo(rounding_rod_peg=rounding_rod_peg);

fil_rounding_peg = 6; // [1:1:20]
rounding_peg = d_filament * fil_rounding_peg;
echo(rounding_peg=rounding_peg);

/* [Cap] */
t_cap = 15; // [1:1:100]
w_cap = 40; // [1:1:100]

fil_chamfer_cap_rod = 2; // [1:1:20]
chamfer_cap_rod = d_filament * fil_chamfer_cap_rod;
echo(chamfer_cap_rod=chamfer_cap_rod);

/* [Padding] */
fil_t_padding = 8; // [1:1:20]
t_padding = d_filament * fil_t_padding;
echo(t_padding=t_padding);

fil_w_padding = 8; // [1:1:20]
w_padding = d_filament * fil_w_padding;
echo(w_padding=w_padding);

rounding_padding = w_padding * 1.25;
echo(rounding_padding=rounding_padding);

fil_w_rib = 6; // [1:1:20]
w_rib = d_filament * fil_w_rib;
echo(w_rib=w_rib);

layer_rib = 8; // [1:1:50]
t_rib = t_layer * layer_rib;
echo(t_rib=t_rib);

n_ribs = round((t_cap - 1) / (t_rib * 2));
echo(n_ribs=n_ribs);

module cap_round(id) {
  back_half()
    tube(
      h=t_cap,
      od=w_cap,
      id=id,
      anchor=BOTTOM,
    );
}

module cap_square(wall = w_cap / 2 - 0.1) {
  front_half()
    rect_tube(
      h=t_cap,
      size=w_cap,
      wall=wall,
      anchor=BOTTOM,
      rounding=rounding_padding,
    );
}

module padding() {
  od = w_cap - 2 * t_padding + 0.0001;
  id = od - w_rib * 2;

  color("lime")
    cap_round(id=w_cap - w_padding * 2);

  color(c="gold")
    cap_square(wall=w_padding);

  for (i = [1:1:n_ribs]) {
    translate(v=[0, 0, t_cap * (i / n_ribs - 1 / n_ribs / 2)]) {
      color(c="purple")
        back_half()
          tube(
            h=t_rib,
            od=od,
            id=id,
            anchor=CENTER,
          );

      color(c="olive")
        front_half()
          rect_tube(
            h=t_rib,
            size=od,
            wall=w_rib,
            anchor=CENTER,
            irounding=od - id - rounding_padding,
          );
    }
  }
}

module cap() {

  module body() {
    color(c="peru")
      cap_round(id=0);

    color(c="burlywood")
      cap_square();
  }

  module rod_mask() {
    color(c="magenta")
      cyl(
        d=d_peg_rod,
        h=t_cap,
        anchor=BOTTOM,
      );

    color(c="pink")
      translate(v=[0, 0, t_cap - chamfer_cap_rod])
        cyl(
          d1=d_peg_rod,
          d2=d_peg_rod + chamfer_cap_rod * 2,
          h=chamfer_cap_rod,
          anchor=BOTTOM,
        );
  }

  difference() {
    body();
    rod_mask();
  }
}

module peg() {
  difference() {
    color(c="saddlebrown")
      cyl(
        h=l_peg,
        d=d_peg,
        rounding1=rounding_peg,
        anchor=TOP,
      );
    color(c="magenta")
      cyl(
        d=d_peg_rod,
        h=l_peg,
        anchor=TOP,
      );
    color(c="pink")
      translate(v=[0, 0, -l_peg])
        rounding_hole_mask(
          d=d_peg_rod,
          rounding=rounding_rod_peg,
          orient=DOWN,
        );
  }
}

module all() {
  cap();
  peg();
}

module core() {
  difference() {
    cap();
    padding();
  }
  peg();
}

module intersect() {
  intersection() {
    core();
    padding();
  }
}

render() {

  if (show == "all") {
    all();
  } else if (show == "padding") {
    padding();
  } else if (show == "core") {
    core();
  } else if (show == "intersect") {
    intersect();
  }
}
