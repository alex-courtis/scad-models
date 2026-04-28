include <BOSL2/std.scad>
include <lib/geom.scad>

d_filament = 0.6; // [0.2:0.2:0.8]
t_layer = 0.3; // [0.01:0.01:0.5]
$fn = 200; // [1:1:500]

/* [What] */
show = "all"; // ["all", "padding", "core"]

/* [Rod] */
d_peg_rod = 5.2; // [1:0.05:50]

/* [Peg] */
d_peg = 19.2; // [1:0.05:50]
l_peg = 45; // [1:1:100]

fil_chamfer_rod_peg = 4; // [1:1:20]
chamfer_rod_peg = d_filament * fil_chamfer_rod_peg;
echo(chamfer_rod_peg=chamfer_rod_peg);

// between peg and rod chamfer
fil_peg_flat = 3; // [1:1:20]
rounding_peg = (d_peg - d_peg_rod - chamfer_rod_peg) / 2 - d_filament * fil_peg_flat;
echo(rounding_peg=rounding_peg);

/* [Cap] */
t_cap = 15; // [1:1:100]
w_cap = 40; // [1:1:100]

fil_chamfer_cap = 4; // [1:1:20]
chamfer_cap = d_filament * fil_chamfer_cap;
echo(chamfer_cap=chamfer_cap);

fil_chamfer_cap_rod = 4; // [1:1:20]
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

  module body() {
    color(c=padding ? "lime" : "peru")
      back_half()
        tube(
          h=t_cap,
          od=w_cap,
          id=padding ? w_cap - t_padding * 2 : 0,
          ochamfer2=chamfer_cap,
          anchor=BOTTOM,
        );

    color(c=padding ? "gold" : "burlywood")
      front_half()
        diff()
          rect_tube(
            h=t_cap,
            size=w_cap,
            wall=padding ? t_padding : w_cap / 2 - 0.0001,
          )
            edge_profile(
              except=[
                BOTTOM,
                BACK,
              ],
            ) mask2d_chamfer(
                h=chamfer_cap,
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
    union() {
      body();
      if (padding)
        ribs();
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
          rounding=chamfer_rod_peg,
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
