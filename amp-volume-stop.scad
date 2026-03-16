include <BOSL2/std.scad>
include <lib/geom.scad>

// round part (x) of the base
d_tongue_base = 7.75 + 0.25;

// round part (x) of the top
d_tongue_top = 5.75;

// thickness of the base
t_base = 1;

// thickness of the top including base
t_top = 2.5;

// centre to point
dy_tongue_left = 10.3 + 3.6;
// left point to shoulder
dy_tongue_brace = 4.5;
// center to corner
dy_tongue_right = 6.25 + 1;

// centre of the tongue to the edge
x_bottom_brace = d_tongue_base/ 2 + 3.5;

y_bottom_brace = 8;

// brace corner rounding
r_brace = 1.0;

// centre of the knob
d_knob = 23;

debug = false;

$fn = 400;

A = [-d_tongue_base / 2, -dy_tongue_left + d_tongue_base / 2];
B = [d_tongue_base / 2, -dy_tongue_right + d_tongue_base / 2];

D = A - [0, -dy_tongue_brace];

C_knob = circle_centre(
  A=A,
  B=B,
  r=d_knob / 2
)[0];

module knob() {

  color(c="red") {
    translate(v=C_knob)
      cylinder(d=d_knob, h=(t_base + t_top) * 2, center=true);
  }
}

module top() {

  tongue = [
    d_tongue_top,
    dy_tongue_left + d_tongue_top / 2,
    t_top,
  ];

  brace = [
    x_bottom_brace,
    y_bottom_brace,
    t_top,
  ];

  color(c="green")
    translate(v=[0, (d_tongue_top - tongue[1]) / 2, 0])
      cuboid(
        tongue,
        rounding=d_tongue_top / 2,
        edges=[
          LEFT + BACK,
          RIGHT + BACK,
        ]
      );

  color(c="blue")
    translate(
      v=[
        -brace[0] / 2,
        D[1] - brace[1] / 2,
        0,
      ]
    )
      cuboid(
        brace,
        rounding=r_brace,
        edges=[
          LEFT + BACK,
          LEFT + FRONT,
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
      v=[0, (d_tongue_base - tongue[1]) / 2, 0]
    )
      cuboid(
        tongue,
        rounding=d_tongue_base / 2,
        edges=[
          LEFT + BACK,
          RIGHT + BACK,
        ]
      );
  }
}

render() {
  if (debug) {
    color(c="red")
      translate(v=C_knob)
        cylinder(h=t_top + 1, r=0.05, center=false);
    color(c="green")
      translate(v=A)
        cylinder(h=t_top + 1, r=0.05, center=false);
    color(c="yellow")
      translate(v=B)
        cylinder(h=t_top + 1, r=0.05, center=false);
    color(c="orange")
      translate(v=D)
        cylinder(h=t_top + 1, r=0.05, center=false);
  }

  difference() {
    union() {
      translate(v=[0, 0, t_base / 2])
        base();
      translate(v=[0, 0, t_top / 2])
        top();
    }
    knob();
  }
}
