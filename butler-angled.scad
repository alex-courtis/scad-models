include <stool.scad>

/* [Finishing] */

scale = 0.5; // [0.1:0.01:1]
d_dowel_v = 2.35; // [0:0.05:5]
h_dowel = 42; // [0:1:80]

$fn = 200; // [1:1:2000]

/* [Testing] */
show_wastes = false;
show_leg = true;
show_step_bottom = true;
show_step_top = true;
show_half = true;

box = true;
box_x = 250; // [0:1:800]
box_y = 350; // [0:1:800]
box_z = 200; // [0:1:800]

explode = 0; // [0:1:100]

/* [General Dimensions] */

l_step_top_abs = 215; // [100:1:1000]
w_step_top_abs = 147; // [50:1:500]
w_step_bottom_abs = 147; // [50:1:500]
d_step_abs = 23; // [5:1:50]
l_step_bottom_abs = 149; // [100:1:1000]
d_leg_abs = 23; // [5:1:50]
dy_step_bottom_abs = 220; // [100:1:500]

l_step_top = l_step_top_abs * scale;
w_step_top = w_step_top_abs * scale;
w_step_bottom = w_step_bottom_abs * scale;
d_step = d_step_abs * scale;
l_step_bottom = l_step_bottom_abs * scale;
d_leg = d_leg_abs * scale; // [5:1:50]
dy_step_bottom = dy_step_bottom_abs * scale; // [100:1:500]

a_leg_outer = 100;
a_leg_inner = 162.5;

a_legs = -8; // [-45:1:45]

/* [Dovetail] */

g_shoulder_dt = 0.035; // [0:0.001:5]
// g_shoulder_dt = 2; // [0:0.001:5]
g_cheek_dt = 0.12; // [0:0.001:5]
g_pin_dt = 0.001; // [0:0.001:5]
// g_pin_dt = 1; // [0:0.001:5]
r_edge_dt = 0.25; // [0:0.001:5]
a_tail = 12.5; // [0:0.5:30]
l_tail_top_ratio = 0.7;

/* [Hidden] */
test = "none";

// clockwise from origin
// added a d_step on top to allow leg angle
function leg_poly() =
  let (
    B = [75 * scale, 0],
    D = [0, 80 * scale],
    A = [
      cos(180 - a_leg_outer) * 433 * scale + B[0],
      sin(180 - a_leg_outer) * 433 * scale,
    ],
    E = line_intersect(P1=D, a1=a_leg_inner - 90, P2=A, a2=0),
  ) [
      [0, -d_step / 2],
      [0, 0],
      D,
      E,
      A,
      B,
      [B[0] - 1, B[1] - d_step / 2],
  ];

// extents from origin that will cover the model
bounding_x = 300;
bounding_y = 600;
bounding_z = 500;

module leg_body() {
  linear_extrude(h=d_leg, center=true)
    polygon(leg_poly());
}

// hull of 4 legs the entire top width
module legs_hull() {
  hull() {
    translate(v=[0, 0, 0])
      linear_extrude(h=l_step_top * 4, center=true) {
        polygon(leg_poly());
        mirror(v=[1, 0])
          polygon(leg_poly());
      }
  }
}

module step_half_bottom() {

  // rotate(a=a_legs, v=[1, 0, 0]) {
    // build joint at origin then shift to destination for planing
    translate(v=[0, dy_step_bottom, 0]) {

      // difference() {
      //   union() {
      // complete step body as a dovetail
      intersection() {
        translate(v=[w_step_bottom / 2, 0, 0])
          rotate(a=90, v=[0, 1, 0])
            dove_tail(
			a=a_tail,
              w=d_step,
              l=d_leg,
			  l_tail=l_tail_top_ratio * d_step,
              l1=(l_step_bottom - d_leg) / 2,
              d=w_step_bottom,
              ratio=0,
              d_dowel=0,
            );

        // #legs_hull();
      }
    }
  // }

  // TODO not manifold

  // fill in dovetail beyond step with a shoulder gap
  // difference() {
  //   {
  //     z = d_step;
  //     dz = z / 2 + g_shoulder_dt / 2;
  //     translate(v=[w_step_bottom / 4, 0, dz])
  //       cube([w_step_bottom / 2, d_step, z], center=true);
  //   }
  //
  //   // shoulder gap with the inner angle
  //   translate(v=[-g_shoulder_dt / cos(180 - a_leg_inner), -dy_step_bottom, d_step / 2])
  //     leg_body();
  // }

  // #translate(v=[0, 0, d_leg * 2])
  //   rotate(a=90, v=[0, 1, 0])
  //     cylinder(h=h_dowel, d=d_dowel_v, center=true);
  //   }
  // }
}

module step_bottom() {
  // intersection() {
  //   union() {
      step_half_bottom();
  //
  //     if (!show_half)
  //       translate(v=[0, 0, l_step_bottom])
  //         mirror(v=[0, 0, 1])
  //           step_half_bottom();
  //   }
  //
  //   // plane sides flush to legs
  //   legs_hull();
  // }
}

module step_half_top() {

  module body() {
    translate(v=[0, -d_step / 2, (l_step_bottom - l_step_top) / 2])
      cube([w_step_top, d_step, l_step_top / 2], center=false);
  }

  //
  //   difference() {
  //     union() {
  intersection() {
    body();

    // top tail covers entire width
    rotate(a=90, v=[0, 1, 0])
      mirror(v=[0, 1, 0])
        dove_socket(
          a=-a_legs,
          l=d_leg,
          w=d_step,
          l_tail=l_tail_top_ratio * d_step,
          l1=bounding_z,
          l2=bounding_z,
          d=bounding_x * 2,
          ratio=0,
          d_dowel=0,
        );

    // legs_hull();
  }
  //
  //     // fill in slot beyond step with a shoulder gap
  //     difference() {
  //       body();
  //       // x is exact, y not calculated and pushes it out a bit
  //       translate(v=[g_shoulder_dt / sin(180 - a_leg_outer), -r_edge_dt, 0])
  //         legs_hull();
  //     }
  //   }
  //
  //   #translate(v=[0, 0, d_leg * 2])
  //     rotate(a=90, v=[0, 1, 0])
  //       cylinder(h=h_dowel, d=d_dowel_v, center=true);
  // }
}

module step_top() {
  step_half_top();

  if (!show_half)
    translate(v=[0, 0, l_step_bottom])
      mirror(v=[0, 0, 1])
        step_half_top();
}

module leg() {
  // rotate(a=0, v=[1, 0, 0])
  rotate(a=a_legs, v=[1, 0, 0])
    difference() {
      intersection() {

        #leg_body();

        // // bottom socket covers entire leg
        // translate(v=[0, dy_step_bottom, 0])
        //   rotate(a=90, v=[0, 1, 0])
        //     rotate(a=90, v=[0, 0, -1])
        //       dove_socket(
        //         l=d_step,
        //         w=d_leg,
        //         l_tail=d_leg / 2,
        //         l1=bounding_y,
        //         l2=bounding_y,
        //         d=bounding_x * 2,
        //         ratio=0,
        //         d_dowel=0,
        //       );

        // top tail covers entire leg
        // shift down by an arbitrary d_step
        rotate(a=90, v=[-1, 0, 0])
          rotate(a=90, v=[0, 1, 0])
            dove_tail(
              a=a_legs,
              w=d_leg,
              l=d_step,
              l_tail=l_tail_top_ratio * d_step,
              l1=bounding_y,
              d=bounding_x * 2,
              ratio=0,
              d_dowel=0,
            );
      }

      // #translate(v=[0, d_step, 0])
      //   rotate(a=90, v=[0, 1, 0])
      //     cylinder(h=h_dowel, d=d_dowel_v, center=true);
      // #translate(v=[0, d_step * 3, 0])
      //   rotate(a=90, v=[0, 1, 0])
      //     cylinder(h=h_dowel, d=d_dowel_v, center=true);
    }
}

module butler() {
  if (show_step_bottom)
    color(COL[0][0])
      step_bottom();

  if (show_leg) {
    translate(v=[0, 0, -explode])
      color(COL[1][1])
        leg();

    if (!show_half)
      translate(v=[0, 0, explode])
        translate(v=[0, 0, l_step_bottom])
          mirror(v=[0, 0, 1])
            color(COL[2][1])
              leg();
  }

  if (show_step_top)
    color(COL[1][0])
      step_top();

  // color(c="lightgreen", alpha=0.25)
  //   cube([bounding_x, bounding_y, bounding_z], center = false);
}

render() {
  if (box) {
    intersection() {
      #cube([box_x * scale, box_y * scale, box_z * scale], center=true);
      butler();
    }
  } else {
    butler();
  }
}
