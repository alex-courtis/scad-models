include <BOSL2/std.scad>
include <lib/geom.scad>

// round part (x) of the base
d_tongue_base = 7.75 + 0.25;

// round part (x) of the top
d_tongue_top = 5.75;

// thickness of the base
t_base = 2;

// thickness of the top including base
t_top = 4;

// including base and top
t_shroud = 8;

// centre to point
dy_tongue_left = 10.3 + 3.6;

// center to corner
dy_tongue_right = 6.25 + 1;

// centre of the knob
d_knob = 23.250;

// from centre of knob
d_shroud = 24.875;

debug = true;

$fn = 400;

A = [-d_tongue_base / 2, -dy_tongue_left + d_tongue_base / 2];
B = [d_tongue_base / 2, -dy_tongue_right + d_tongue_base / 2];

C_knob = circle_centre(
  A=A,
  B=B,
  r=d_knob / 2
)[0];

module top() {

  tongue = [
    d_tongue_top,
    dy_tongue_left + d_tongue_top / 2,
    t_top,
  ];

  color(c="lightblue")
    translate(v=[0, (d_tongue_top - tongue[1]) / 2, tongue[2] / 2])
      cuboid(
        tongue,
        rounding=d_tongue_top / 2,
        edges=[
          LEFT + BACK,
          RIGHT + BACK,
        ]
      );
}

module base() {

  color(c="gray") {

    tongue = [
      d_tongue_base,
      dy_tongue_left + d_tongue_base / 2,
      t_base,
    ];

    translate(
      v=[0, (d_tongue_base - tongue[1]) / 2, tongue[2] / 2]
    )
      cuboid(
        tongue,
        rounding=d_tongue_base / 2,
        edges=[
          LEFT + BACK,
          RIGHT + BACK,
        ],
      );
  }
}

module shroud() {
  color(c="royalblue")
    translate(v=C_knob) {
      tube(
        od=d_shroud,
        id=d_knob,
        h=t_shroud,
        rounding2=(d_shroud - d_knob) / 4,
        center=false,
      );
    }
}

module knob_mask() {
  color(c="red")
    translate(v=C_knob)
      cylinder(d=d_shroud, h=t_shroud, center=false);
}

render() {
  if (debug) {
    color(c="red")
      translate(v=C_knob)
        cylinder(h=t_shroud + 1, r=0.05, center=false);
    color(c="green")
      translate(v=A)
        cylinder(h=t_shroud + 1, r=0.05, center=false);
    color(c="yellow")
      translate(v=B)
        cylinder(h=t_shroud + 1, r=0.05, center=false);
  }

  difference() {
    union() {
      base();
      top();
    }
    knob_mask();
  }
  shroud();
}
