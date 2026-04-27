include <BOSL2/std.scad>
include <lib/geom.scad>

d_filament = 0.4;
t_layer = 0.2;

d_peg = 19.5;
l_peg = 45;

t_cap = 20;
w_cap = 40;
chamfer_cap = d_filament * 3;

d_bolt = 4;
d_washer = 9;
l_bolt = 50;
l_bolt_inset = 4;
l_nut_inset = 6;

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

module cap() {
  color(c="burlywood")

    translate(v=[0, -w_cap / 4, 0])
      cuboid(
        [w_cap, w_cap / 2, t_cap],
        anchor=BOTTOM,
        chamfer=chamfer_cap,
        except=[
          BOTTOM,
          BACK,
        ],
      );

  color(c="peru")
    back_half()
      cyl(
        h=t_cap,
        d=w_cap,
        anchor=BOTTOM,
        chamfer2=chamfer_cap,
      );
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

    bolt_mask();
  }
}

render() {
  difference() {
    union() {
      peg();
      cap();
    }
    bolt_mask();
  }
}
