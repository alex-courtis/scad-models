include <BOSL2/std.scad>
include <lib/geom.scad>

d_filament = 0.6; // [0.2:0.2:0.8]
t_layer = 0.3; // [0.01:0.01:0.5]
$fn = 200; // [1:1:500]

/* [What] */
show = "all"; // ["all", "padding", "core"]

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

fil_rounding_cap = 6; // [1:1:20]
rounding_cap = d_filament * fil_rounding_cap;
echo(rounding_cap=rounding_cap);

fil_chamfer_cap_rod = 2; // [1:1:20]
chamfer_cap_rod = d_filament * fil_chamfer_cap_rod;
echo(chamfer_cap_rod=chamfer_cap_rod);

/* [Padding] */
fil_t_padding = 8; // [1:1:20]
t_padding = d_filament * fil_t_padding;
echo(t_padding=t_padding);

fil_w_rib = 6; // [1:1:20]
w_rib = d_filament * fil_w_rib;
echo(w_rib=w_rib);

layer_rib = 8; // [1:1:50]
t_rib = t_layer * layer_rib;
echo(t_rib=t_rib);

n_ribs = round((t_cap - 1) / (t_rib * 2));
echo(n_ribs=n_ribs);

module cap(padding) {

  module body(w) {
    color(c=padding ? "lime" : "peru")
      back_half()
        cyl(
          h=t_cap,
          d=w,
          anchor=BOTTOM,
        );

    color(c=padding ? "gold" : "burlywood")
      front_half()
        cuboid(
          [w, w, t_cap],
          anchor=BOTTOM,
          rounding=rounding_cap * w/w_cap,
          edges=[
            FRONT + LEFT,
            FRONT + RIGHT,
          ],
        );
  }

  module ribs() {
    od = w_cap - 2 * t_padding + 0.0001;
    id = od - w_rib * 2;

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
            );
      }
    }
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
    if (padding) {
      difference() {
        body(w=w_cap);
        body(w=w_cap - t_padding * 2);
      }
      ribs();
    } else {
        body(w=w_cap);
    }
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

render() {

  if (show == "all") {
    cap(padding=false);
    peg();
  } else if (show == "padding") {
    cap(padding=true);
  } else if (show == "core") {
    peg();
    difference() {
      cap(padding=false);
      cap(padding=true);
    }
  }
}
