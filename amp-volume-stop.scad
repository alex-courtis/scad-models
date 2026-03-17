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
z_shroud_lower = z_top + 0.15;

// including base and top
z_shroud_upper = 12.35;

// upper base and top
rounding_base_top = 0.4;

// centre to point
dy_tongue_long = 10.3 + 3.6;

// center to corner
dy_tongue_short = 6.25 + 1;

// centre of the knob
d_knob = 23.250;

// from centre of knob
d_shroud_lower = 24.875;

// from centre of knob
d_shroud_upper = d_shroud_lower + 0.5;

// height of the rim
z_rim = 0.80;

// from base to mid rim
dz_rim = z_shroud_upper - z_rim / 2 - 2.05;

// inset of the rim
d_rim = d_knob - 0.7;

// from x axis
a_cutout_1 = [40, 320];

// from x axis
a_cutout_2 = a_cutout_1 + [180, 180];

// from base
dz_clip = z_shroud_lower;

// width of clip close to rim
x1_clip = 13.5;

// width of clip far from rim
x2_clip = 5.5;

// from centre
dx_clip = -1.05;

// additional to d_rim
y_clip = 7.6;

// from knob centre to left of clip
dy_clip = 9.5;

// height of the clip
z_clip = 3;

// top sides of the clip
rounding_clip = 1.25;

// inner bolt
d_clip_bolt = 2;

// centre of knob to bolt
dy_clip_bolt = 15.0;

// above z_top, meets shroud chamfer
dz_tongue_top = z_shroud_lower - z_top + (d_shroud_upper - d_shroud_lower) / 2;

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

// TODO centre the whole thing 
// cutout 1
M = [6 * sin(a_cutout_1[0]), 6 * cos(a_cutout_1[0])];

module top() {

  tongue = [
    d_tongue_top,
    dy_tongue_long - d_tongue_top / 2,
    z_top + dz_tongue_top,
  ];

  color(c="orange") {
    translate(v=[0, -tongue[1] / 2, tongue[2] / 2])
      cuboid(
        tongue,
        rounding=rounding_base_top,
        edges=[
          TOP,
        ]
      );

    cyl(
      d=tongue[0],
      h=tongue[2],
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
    color(c="pink")
      tube(
        od=d_shroud_lower,
        id=d_knob,
        h=z_shroud_lower,
        center=false,
      );

    color(c="royalblue")
      translate(v=[0, 0, z_shroud_lower])
        tube(
          od=d_shroud_upper,
          id=d_knob,
          h=z_shroud_upper - z_shroud_lower,
          rounding2=(d_shroud_upper - d_knob) / 4,
          ochamfer1=(d_shroud_upper - d_shroud_lower) / 2,
          center=false,
        );

    color(c="maroon")
      translate(v=[0, 0, dz_rim])
        tube(
          od=d_knob,
          id=d_rim,
          h=z_rim,
          irounding=(d_knob - d_rim) / 2,
          center=false
        );
  }
}

module clip() {

  translate(v=C_knob)
    translate(v=[dx_clip, 0, 0])
      difference() {
        color(c="yellow") {
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
            cylinder(h=z_shroud_upper, d=d_clip_bolt, center=false);
        }
      }
}

module knob_mask() {
  color(c="red")
    translate(v=C_knob)
      cylinder(d=d_shroud_lower, h=z_shroud_upper, center=false);
}

module cutout_mask() {
  translate(v=C_knob) {

    color(c="blue")
      rotate(-a_cutout_1[0])
        pie_slice(
          d=d_shroud_upper * 2,
          h=z_shroud_upper * 2,
          ang=a_cutout_1[0] + 360 - a_cutout_1[1],
          center=true,
        );

    color(c="green")
      rotate(-a_cutout_2[0])
        pie_slice(
          d=d_shroud_upper * 2,
          h=z_shroud_upper * 2,
          ang=a_cutout_2[0] + 360 - a_cutout_2[1],
          center=true,
        );
  }
}

render() {
  if (debug) {
    h = z_shroud_upper + 2;
    r = 0.075;
    point_marker(P=C_knob, h=h, r=r, t="C");
    point_marker(P=A, h=h, r=r, t="A");
    point_marker(P=B, h=h, r=r, t="B");
    point_marker(P=M, h=h, r=r, t="M");
  }

  difference() {
    union() {
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
    cutout_mask();
  }
}
