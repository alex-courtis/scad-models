include <BOSL2/std.scad>
include <lib/geom.scad>

// round part (x) of the base
d_tongue_base = 7.75 + 0.25;

// round part (x) of the top
d_tongue_top = 5.75;

// thickness of the base
z_base = 1.38;

// thickness of the top including base
z_top = 2.8;

// including base and top
z_shroud_lower = z_top + 0.20;

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
d_shroud_upper = d_shroud_lower + 1.55;

// thickness of the top of the tongue including base
z_tongue_top = z_shroud_lower;

// height of the rim
z_rim = 0.80;

// from base to mid rim
dz_rim = z_shroud_upper - z_rim / 2 - 2.05;

// inset of the rim
d_rim = d_knob - 1.0;

// from base
dz_clip = z_shroud_lower;

// width of clip far from rim
x_clip_left = 5.5;

// width of clip far from rim
x_clip_right = 5.5;

// from centre
dx_clip_right = -1.05;

// height of the clip far end
z_clip_right = 3.5;

// top sides of the clip
rounding_clip = 1.25;

// inner bolt
d_clip_bolt = 2;

// outer bolt
d_clip_head = 3.6;

// from base of clip
z_clip_head = 2;

// centre of knob to bolt
dy_clip_bolt = 15.0;

// from centre of bolt to edge of clip
dy_clip_outer = -2.1;

// from x axis
a_cutout_start = [315.5, 142.5];

// clockwise
a_cutout_sweep = [82.0, 77.5];

// clockwise from x axis
a_cutout = [
  37.5,
  142.5,
  220,
  315.5,
];

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

t_shroud_upper = (d_shroud_upper - d_knob) / 2;

r_shroud_mid = (d_knob + d_shroud_upper) / 4;
M = [
  r_shroud_mid * cos(a_cutout[3]),
  r_shroud_mid * sin(a_cutout[3]),
];
N = [
  r_shroud_mid * cos(a_cutout[0]),
  r_shroud_mid * sin(a_cutout[0]),
];
Q = [
  r_shroud_mid * cos(a_cutout[1]),
  r_shroud_mid * sin(a_cutout[1]),
];
R = [
  r_shroud_mid * cos(a_cutout[2]),
  r_shroud_mid * sin(a_cutout[2]),
];

T = [
  dx_clip_right,
  -dy_clip_bolt,
];
U = [
  T[0],
  T[1] + dy_clip_outer,
];
V = [
  T[0],
  min(M[1], R[1]),
];

W = [
  0,
  min(N[1], Q[1]),
];
X = [
  0,
  -U[1],
];

module tongue() {

  back_half(y=Q[1]) {

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
      // TODO reinstate after testing fits
      // color(c="gray") {
      //   translate(v=[0, -base[1] / 2, base[2] / 2])
      //     cuboid(
      //       base,
      //       rounding=rounding_base_top,
      //       edges=[
      //         TOP,
      //       ],
      //     );
      //
      //   cyl(
      //     h=z_base,
      //     d=d_tongue_base,
      //     rounding2=rounding_base_top,
      //     center=false
      //   );
      // }

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
}

module shroud() {

  shroud_lower();

  color(c="royalblue")
    translate(v=[0, 0, z_shroud_lower])
      tube(
        od=d_shroud_upper,
        id=d_knob,
        h=z_shroud_upper - z_shroud_lower,
        rounding2=(d_shroud_upper - d_knob) / 4,
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

module shroud_lower() {
  color(c="pink")
    tube(
      od=d_shroud_lower,
      id=d_knob,
      h=z_shroud_lower,
      center=false,
    );
}

module shroud_left() {

  intersection() {

    shroud();

    rotate(a_cutout[0])
      pie_slice(
        d=d_shroud_upper,
        h=z_shroud_upper * 2,
        ang=a_cutout[1] - a_cutout[0],
        center=true,
      );
  }

  translate(v=Q)
    cutout_edge();
  translate(v=N)
    cutout_edge();
}

module shroud_right() {

  intersection() {

    shroud();

    rotate(a_cutout[2])
      pie_slice(
        d=d_shroud_upper,
        h=z_shroud_upper * 2,
        ang=a_cutout[3] - a_cutout[2],
        center=true,
      );
  }

  translate(v=M)
    cutout_edge();
  translate(v=R)
    cutout_edge();
}

module clip_right() {

  inner = [M[0] - R[0], z_shroud_upper - z_clip_right];
  outer = [x_clip_right, z_clip_right];

  h = V[1] - U[1];

  shift = [T[0], (outer[1] - inner[1]) / 2];

  color(c="yellow") {
    top_half(z=dz_clip) {
      hull() {
        shroud_right();

        translate(v=[dx_clip_right, 0, 0]) {
          translate([-T[0], V[1], inner[1] / 2 + dz_clip]) {
            diff() {
              prismoid(
                size1=inner,
                size2=outer,
                h=h,
                shift=shift,
                orient=FRONT,
              )
                edge_profile(
                  [
                    BACK + TOP,
                    TOP + LEFT,
                    TOP + RIGHT,
                  ],
                  excess=10,
                ) {
                  mask2d_roundover(h=rounding_clip, mask_angle=$edge_angle);
                }
            }
          }
        }
      }
    }
  }
}

module bolt_hole_mask() {
  translate(v=[dx_clip_right, 0, 0]) {
    color(c="deeppink") {
      translate(v=[0, -dy_clip_bolt, 0])
        cylinder(h=z_shroud_upper, d=d_clip_bolt, center=false);
      translate(v=[0, -dy_clip_bolt, z_shroud_lower + z_clip_head])
        cylinder(h=z_shroud_upper, d=d_clip_head, center=false);
    }
  }
}

module left() {
  difference() {
    tongue();
    knob_mask();
  }
  shroud_left();
}

module right() {
  difference() {
    union() {
      difference() {
        clip_right();
        knob_mask();
      }
      shroud_right();
    }
    bolt_hole_mask();
  }
}

module knob_mask() {
  color(c="deeppink")
    cylinder(d=d_shroud_lower, h=z_shroud_upper + t_shroud_upper / 2, center=false);
}

module cutout_edge() {
  z_upper = z_shroud_upper - t_shroud_upper / 2;

  // upper
  translate(v=[0, 0, 0])
    cylinder(h=z_upper, d=t_shroud_upper, center=false);

  translate(v=[0, 0, z_upper])
    sphere(d=t_shroud_upper);
}

render() {
  if (debug) {
    h = z_shroud_upper + 2;
    r = 0.075;
    translate(v=vector_multiply(C_knob, -1)) {
      point_marker(P=A, h=h, r=r, t="A");
      point_marker(P=B, h=h, r=r, t="B");
      point_marker(P=C_knob, h=h, r=r, t="C");
    }
    point_marker(P=M, h=h, r=r, t="M");
    point_marker(P=N, h=h, r=r, t="N");
    point_marker(P=Q, h=h, r=r, t="Q");
    point_marker(P=R, h=h, r=r, t="R");
    point_marker(P=T, h=h, r=r, t="T");
    point_marker(P=U, h=h, r=r, t="U");
    point_marker(P=V, h=h, r=r, t="V");
    point_marker(P=W, h=h, r=r, t="W");
    point_marker(P=X, h=h, r=r, t="X");
  }

  left();
  right();
  shroud_lower();
}
