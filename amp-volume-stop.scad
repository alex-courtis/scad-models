include <lib/geom.scad>

// round part of the base
d_base = 7.75 + 0.25;

// thickness of the base
t_base = 1;

// entire length to point
l_base_left = 10.3 + 3.6;
// entire length to corner
l_base_right = 6.25 + 1;

// centre of the cutout
d_base_cutout = 23;

$fn = 400;

module base() {
  C_cutout = circle_centre(
    A=[-d_base / 2, -l_base_left + d_base / 2],
    B=[d_base / 2, -l_base_right + d_base / 2],
    r=d_base_cutout / 2
  )[0];

  linear_extrude(h=t_base, center=true) {
    difference() {
      union() {
        circle(d=d_base);

        #translate(v=[0, -l_base_left / 2])
          square([d_base, l_base_left], center=true);
      }

      translate(v=C_cutout)
        circle(d=d_base_cutout);
    }
  }
}

render() {
  base();
}
