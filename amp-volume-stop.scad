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

// thickness of the top of the tongue including base
z_tongue_top = 5;

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

// from x axis
a_cutout_start = [320, 140];

// clockwise
a_cutout_sweep = [80, 80];

debug = false;

$fn = 400;

t_shroud_upper = (d_shroud_upper - d_knob) / 2;

r_shroud_mid = (d_knob + d_shroud_upper) / 4;
M = [
  r_shroud_mid * cos(a_cutout_start[0]),
  r_shroud_mid * sin(a_cutout_start[0]),
];
N = [
  r_shroud_mid * cos(a_cutout_start[0] + a_cutout_sweep[0]),
  r_shroud_mid * sin(a_cutout_start[0] + a_cutout_sweep[0]),
];
Q = [
  r_shroud_mid * cos(a_cutout_start[1]),
  r_shroud_mid * sin(a_cutout_start[1]),
];
R = [
  r_shroud_mid * cos(a_cutout_start[1] + a_cutout_sweep[1]),
  r_shroud_mid * sin(a_cutout_start[1] + a_cutout_sweep[1]),
];

module tongue() {

  // knob with top of tongue
  A = [-d_tongue_base / 2, -dy_tongue_long + d_tongue_base / 2];

  // knob with top of tongue
  B = [d_tongue_base / 2, -dy_tongue_short + d_tongue_base / 2];

  C_knob = circle_centre(
    A=A,
    B=B,
    r=d_knob / 2
  )[0];

  base = [
    d_tongue_base,
    dy_tongue_long - d_tongue_base / 2,
    z_base,
  ];

  top = [
    d_tongue_top,
    dy_tongue_long - d_tongue_top / 2,
    z_tongue_top,
  ];

  translate(v=vector_multiply(C_knob, -1)) {
    color(c="gray") {
      translate(v=[0, -base[1] / 2, base[2] / 2])
        cuboid(
          base,
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

    color(c="orange") {
      translate(v=[0, -top[1] / 2, top[2] / 2])
        cuboid(
          top,
          rounding=rounding_base_top,
          edges=[
            TOP,
          ]
        );

      cyl(
        d=top[0],
        h=top[2],
        rounding2=rounding_base_top,
        center=false
      );
    }
  }
}

module shroud() {
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

module clip() {

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

      color(c="deeppink") {
        translate(v=[0, -dy_clip_bolt, 0])
          cylinder(h=z_shroud_upper, d=d_clip_bolt, center=false);
      }
    }
}

module knob_mask() {
  color(c="deeppink")
    cylinder(d=d_shroud_lower, h=z_shroud_upper, center=false);
}

module cutout_mask() {
  color(c="deeppink") {
    rotate(a_cutout_start[0])
      pie_slice(
        d=d_shroud_upper * 2,
        h=z_shroud_upper * 2,
        ang=a_cutout_sweep[0],
        center=true,
      );

    rotate(a_cutout_start[1])
      pie_slice(
        d=d_shroud_upper * 2,
        h=z_shroud_upper * 2,
        ang=a_cutout_sweep[1],
        center=true,
      );
  }
}

module cutout_edge() {
  z_upper = z_shroud_upper - t_shroud_upper / 2;

  // upper
  translate(v=[0, 0, 0])
    cylinder(h=z_upper, d=t_shroud_upper, center=false);

  translate(v=[0, 0, z_upper])
    sphere(d=t_shroud_upper);
}

module cutout_edges() {
  translate(v=M)
    cutout_edge();
  translate(v=N)
    cutout_edge();
  translate(v=Q)
    cutout_edge();
  translate(v=R)
    cutout_edge();
}

render() {
  if (debug) {
    h = z_shroud_upper + 2;
    r = 0.075;
    point_marker(P=M, h=h, r=r, t="M");
    point_marker(P=N, h=h, r=r, t="N");
    point_marker(P=Q, h=h, r=r, t="Q");
    point_marker(P=R, h=h, r=r, t="R");
  }

  difference() {
    union() {
      difference() {
        union() {
          tongue();
          // base();
          // top();
          clip();
        }
        knob_mask();
      }
      shroud();
    }
    cutout_mask();
  }
  cutout_edges();
}
