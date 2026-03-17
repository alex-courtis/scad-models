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

// from base
dz_rim = z_shroud_upper - 2.25;

// height of the rim
z_rim = 0.10;

// inset of the rim
d_rim = d_knob - 0.40;

// around centre
y_cutout = 16;

// from base
z1_cutout = z_shroud_lower; // + (d_shroud_upper - d_shroud_lower);

// from base
z2_cutout = dz_rim;

// from base
dz_clip = z_shroud_lower;

// width of clip close to rim
x1_clip = 14;

// width of clip far from rim
x2_clip = 6.5;

// from centre
dx_clip = -1;

// additional to d_rim
y_clip = 8.0;

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

debug = false;

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
          irounding=z_rim / 2,
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
  cutout = [d_shroud_upper, y_cutout, z2_cutout - z1_cutout];

  color(c="blue")
    translate(v=C_knob)
      translate(v=[0, 0, cutout[2] / 2 + z1_cutout])
        cube(cutout, center=true);
}

render() {
  if (debug) {
    color(c="red")
      translate(v=C_knob)
        cylinder(h=z_shroud_lower + 1, r=0.05, center=false);
    color(c="green")
      translate(v=A)
        cylinder(h=z_shroud_lower + 1, r=0.05, center=false);
    color(c="yellow")
      translate(v=B)
        cylinder(h=z_shroud_lower + 1, r=0.05, center=false);
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
