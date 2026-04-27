include <BOSL2/std.scad>
include <lib/geom.scad>

d_filament = 0.4;
t_layer = 0.2;

// show = "all"; // ["all", "padding", "core"]
show = "core"; // ["all", "padding", "core"]

d_peg = 19.2;
l_peg = 45;

t_cap = 15;
w_cap = 40;
chamfer_cap = d_filament * 3;

d_bolt = 4.05;
d_washer = 9.5;
l_bolt = 50;
l_bolt_inset = 4.5;
l_nut_inset = 4;

t_padding = chamfer_cap * 2;
t_rib = t_layer * 8;

rounding_peg = (d_peg - d_washer) / 4 - d_filament / 2;

$fn = 200;

module bolt_mask() {
  color(c="pink")
    translate(v=[0, 0, -l_peg])
      cyl(
        d=d_bolt,
        h=l_peg + t_cap,
        anchor=BOTTOM,
      );

  color(c="magenta")
    translate(v=[0, 0, t_cap - l_bolt_inset])
      cyl(
        d=d_washer,
        h=l_bolt_inset,
        anchor=BOTTOM,
      );

  color(c="hotpink")
    translate(v=[0, 0, t_cap - chamfer_cap])
      cyl(
        d1=d_washer,
        d2=d_washer + chamfer_cap * 2,
        h=chamfer_cap,
        anchor=BOTTOM,
      );

  color(c="deeppink")
    translate(v=[0, 0, t_cap - l_bolt + l_nut_inset])
      cyl(
        d=d_washer,
        h=l_peg,
        anchor=TOP,
      );

  color(c="slateblue")
    translate(v=[0, 0, -l_peg])
      rounding_hole_mask(
        d=d_washer,
        rounding=rounding_peg,
        excess=0.01,
        orient=DOWN,
      );
}

module cap(padding) {

  id = padding ? w_cap - 2 * t_padding : 0;
  wall = padding ? t_padding : w_cap / 2 - 0.0001;

  color(c=padding ? "lime" : "peru")
    back_half()
      tube(
        h=t_cap,
        od=w_cap,
        id=id,
        ochamfer2=chamfer_cap,
        anchor=BOTTOM,
      );

  color(c=padding ? "gold" : "burlywood")
    front_half()
      diff()
        rect_tube(
          h=t_cap,
          size=w_cap,
          wall=wall,
        )
          edge_profile(
            except=[
              BOTTOM,
              BACK,
            ],
          ) mask2d_chamfer(
              h=chamfer_cap,
            );

  n_ribs = round((t_cap - 1) / (t_rib * 2));
  echo(n_ribs=n_ribs);

  for (i = [1:1:n_ribs]) {
    translate(v=[0, 0, t_cap * (i / n_ribs - 1 / n_ribs / 2)]) {
      color(c="purple")
        back_half()
          tube(
            h=t_rib,
            od=w_cap - 2 * t_padding + 0.0001,
            id=w_cap - 4 * t_padding,
            anchor=CENTER,
          );

      color(c="olive")
        front_half()
          rect_tube(
            h=t_rib,
            size=w_cap - t_padding * 2 + 0.0001,
            wall=t_padding,
            anchor=CENTER,
          );
    }
  }
}

module peg() {
  color(c="saddlebrown")
    cyl(
      h=l_peg,
      d=d_peg,
      rounding1=rounding_peg,
      anchor=TOP,
    );
}

render() {

  if (show == "padding") {

    cap(padding=true);
  } else {

    difference() {
      peg();

      bolt_mask();
    }

    difference() {
      cap(padding=false);

      if (show == "core")
        cap(padding=true);

      bolt_mask();
    }
  }
}
