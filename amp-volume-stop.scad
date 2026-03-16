include <BOSL2/std.scad>
include <lib/geom.scad>

// round part (x) of the base
d_tongue_base = 7.75 + 0.25;

// round part (x) of the top
d_tongue_top = 5.75;

// thickness of the base
z_base = 1.35;

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
dz_rim = z_shroud - 1.75;

// height of the rim
z_rim = 0.60;

// inset of the rim
d_rim = d_knob - 0.40;

// from base
dz_clip = z_shroud - 5;

// width of clip close to rim
x1_clip = 15;

// width of clip far from rim
x2_clip = 5.5;

// additional to d_rim
y_clip = 9;

// from knob centre to left of clip
dy_clip = 9.5;

// height of the clip
z_clip = 3;

// top sides of the clip
rounding_clip = 0.75;

// inner bolt
d_clip_bolt = 2;

// centre of knob to bolt
dy_clip_bolt = 15.5;

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

module clip() {

  translate(v=C_knob)
    difference() {
      color(c="pink") {
        translate([0, -dy_clip, z_clip / 2 + dz_clip])
          diff() {
            prismoid(
              size1=[x1_clip, z_clip],
              size2=[x2_clip, z_clip],
              h=y_clip,
              orient=FRONT,
            )

              edge_profile(
                [
                  BACK + TOP,
                  BACK + LEFT,
                  BACK + RIGHT,
                  TOP + LEFT,
                  TOP + RIGHT,
                ],
                excess=10,
              ) {
                mask2d_roundover(h=rounding_clip, mask_angle=$edge_angle);
              }
          }
      }

      color(c="red") {
        translate(v=[0, -dy_clip_bolt, 0])
          cylinder(h=z_shroud, d=d_clip_bolt, center=false);
      }
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
      clip();
    }
    knob_mask();
  }
  shroud();
}
