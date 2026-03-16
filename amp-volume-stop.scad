include <BOSL2/std.scad>
include <lib/geom.scad>

// round part (x) of the base
d_tongue_base = 7.75 + 0.25;

// round part (x) of the top
d_tongue_top = 5.75;

// thickness of the base
z_base = 1.5;

// thickness of the top including base
z_top = 2.8;

// including base and top
z_shroud = 12.35;

// upper base and top
rounding_base_top = 0.4;

// centre to point
dy_tongue_long = 10.3 + 3.6;

// center to corner
dy_tongue_short = 6.25 + 1;

// centre of the knob
d_knob = 23.250;

// from centre of knob
d_shroud = 24.875;

// from base
dz_rim = z_shroud - 2;

// height of the rim
z_rim = 0.60;

// inset of the rim
d_rim = d_knob - 0.60;

debug = true;

$fn = 400;

// knob with top of tongue
A = [-d_tongue_base / 2, -dy_tongue_long + d_tongue_base / 2];

// knob with top of tongue
B = [d_tongue_base / 2, -dy_tongue_short + d_tongue_base / 2];

C_knob = circle_centre(
  A=A,
  B=B,
  r=d_knob / 2
)[0];

module top() {

  tongue = [
    d_tongue_top,
    dy_tongue_long - d_tongue_top / 2,
    z_top,
  ];

  color(c="lightblue") {
    translate(v=[0, -tongue[1] / 2, tongue[2] / 2])
      cuboid(
        tongue,
        rounding=rounding_base_top,
        edges=[
          TOP,
        ]
      );

    cyl(
      h=z_top,
      d=d_tongue_top,
      rounding2=rounding_base_top,
      center=false
    );
  }
}

module base() {

  color(c="gray") {

    tongue = [
      d_tongue_base,
      dy_tongue_long - d_tongue_base / 2,
      z_base,
    ];

    translate(
      v=[0, -tongue[1] / 2, tongue[2] / 2]
    )
      cuboid(
        tongue,
        rounding=rounding_base_top,
        edges=[
          TOP,
        ],
      );

    cyl(
      h=z_base,
      d=d_tongue_base,
      rounding2=rounding_base_top,
      center=false
    );
  }
}

module shroud() {
  translate(v=C_knob) {
    color(c="royalblue")
      tube(
        od=d_shroud,
        id=d_knob,
        h=z_shroud,
        rounding2=(d_shroud - d_knob) / 4,
        center=false,
      );

    color(c="green")
      translate(v=[0, 0, dz_rim])
        tube(
          od=d_knob,
          id=d_rim,
          h=z_rim,
          irounding=z_rim / 2,
          center=false
        );
  }
}

module knob_mask() {
  color(c="red")
    translate(v=C_knob)
      cylinder(d=d_shroud, h=z_shroud, center=false);
}

render() {
  if (debug) {
    color(c="red")
      translate(v=C_knob)
        cylinder(h=z_shroud + 1, r=0.05, center=false);
    color(c="green")
      translate(v=A)
        cylinder(h=z_shroud + 1, r=0.05, center=false);
    color(c="yellow")
      translate(v=B)
        cylinder(h=z_shroud + 1, r=0.05, center=false);
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
