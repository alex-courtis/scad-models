include <stool.scad>

/* [Finishing] */

scale = 1; // [0.1:0.01:1]

$fn = 200; // [1:1:2000]

/* [Testing] */
show_wastes = false;
show_leg = true;
show_step_bottom = true;
show_step_top = true;

box = false;
box_x = 250; // [0:1:800]
box_y = 80; // [0:1:800]
box_z = 80; // [0:1:800]

explode = 0; // [0:1:100]

/* [General Dimensions] */

l_step_top = 415; // [100:1:1000]
w_step_top = 147; // [50:1:500]
w_step_bottom = 147; // [50:1:500]
d_step = 23; // [5:1:50]
l_step_bottom = 349; // [100:1:1000]

// TODO set this to d_step once it lines up
d_leg = 23; // [5:1:50]

dy_step_bottom = 220; // [100:1:500]

a_leg_outer = 100;
a_leg_inner = 162.5;

/* [Dovetail] */

g_shoulder_dt = 0.035; // [0:0.001:2]
g_cheek_dt = 0.12; // [0:0.001:2]
g_pin_dt = 0.001; // [0:0.001:2]
r_edge_dt = 0.25; // [0:0.001:2]
a_tail = 10; // [0:0.5:30]

/* [Hidden] */
test = "none";

// clockwise from origin
function leg_poly() =
  let (
    B = [75, 0],
    D = [0, 80],
    A = [
      cos(180 - a_leg_outer) * 433 + B[0],
      sin(180 - a_leg_outer) * 433,
    ],
    E = line_intersect(P1=D, a1=a_leg_inner - 90, P2=A, a2=0),
  ) [
      [0, 0],
      D,
      E,
      A,
      B,
  ];

module mask_bottom_joint() {
  translate(v=[0, dy_step_bottom, 0])
    translate(v=[w_step_bottom / 2, 0, 0])
      cube([w_step_bottom, d_step * 2, d_leg * 2], center=true);
}

module mask_top_joint() {
  translate(v=[w_step_top / 2, 0, 0])
    cube([w_step_top, d_step * 2, d_leg * 2], center=true);
}

module leg_body() {
  linear_extrude(h=d_leg, center=true)
    polygon(leg_poly());
}

module step_half_bottom() {
  intersection() {

    // build joint at origin then shift to destination for planing
    translate(v=[0, dy_step_bottom, 0]) {

      // complete step body as a dovetail
      translate(v=[w_step_bottom / 2, 0, 0])
        rotate(a=90, v=[0, 1, 0])
          dove_tail(
            w=d_step,
            l=d_leg,
            l_tail=d_leg / 2,
            l1=(l_step_bottom - d_leg) / 2,
            d=w_step_bottom,
            ratio=0,
            d_dowel=0,
          );

      // fill in dovetail beyond step with a shoulder gap
      difference() {
        {
          z = d_step;
          dz = z / 2 + g_shoulder_dt / 2;
          translate(v=[w_step_bottom / 4, 0, dz])
            cube([w_step_bottom / 2, d_step, z], center=true);
        }

        // shoulder gap with the inner angle
        translate(v=[-g_shoulder_dt / cos(180 - a_leg_inner), -dy_step_bottom, d_step / 2])
          leg_body();
      }
    }

    // plane sides flush using hull of both leg
    hull() {
      linear_extrude(h=l_step_bottom * 2, center=true) {
        polygon(leg_poly());
        mirror(v=[1, 0])
          polygon(leg_poly());
      }
    }
  }
}

module step_half_top() {

  // leg body with joint gaps removed
  difference() {
    translate(v=[0, -d_step / 2, l_step_bottom / 2 - l_step_top / 2])
      cube([w_step_top, d_step, l_step_top / 2], center=false);

    // remove top joint
    mask_top_joint();
  }
}

module leg() {

  // leg body with joint space removed
  difference() {
    leg_body();

    // remove bottom joint
    mask_bottom_joint();

    // remove top joint
    mask_top_joint();
  }

  // add bottom slot
  intersection() {
    leg_body();

    translate(v=[0, dy_step_bottom, 0])
      translate(v=[w_step_bottom / 2, 0, 0])
        rotate(a=90, v=[0, 1, 0])
          rotate(a=90, v=[0, 0, -1])
            dove_socket(
              l=d_step,
              w=d_leg,
              l_tail=d_leg / 2,
              l1=d_step,
              l2=d_step,
              d=w_step_bottom,
              ratio=0,
              d_dowel=0,
            );
  }

  // add top tail
  intersection() {
    leg_body();

    translate(v=[w_step_top / 2, 0, 0])
      rotate(a=90, v=[-1, 0, 0])
        rotate(a=90, v=[0, 1, 0])
          dove_tail(
            w=d_leg,
            l=d_step,
            l_tail=d_step / 2,
            l1=d_step,
            d=w_step_top,
            ratio=0,
            d_dowel=0,
          );
  }
}

module butler() {
  if (show_step_bottom) {
    translate(v=[explode, 0, 0]) {
      color(COL[0][0]) step_half_bottom();

      translate(v=[0, 0, l_step_bottom])
        mirror(v=[0, 0, 1])
          color(COL[0][1]) step_half_bottom();
    }
  }

  if (show_leg) {
    translate(v=[0, -explode, -explode])
      color(COL[1][0]) leg();

    
    translate(v=[0, -explode, explode])
      translate(v=[0, 0, l_step_bottom])
        mirror(v=[0, 0, 1])
          color(COL[1][1]) leg();
  }

  if (show_step_top) {
    color(COL[2][0]) step_half_top();
    translate(v=[0, 0, l_step_bottom])
      mirror(v=[0, 0, 1])
        color(COL[2][1]) step_half_top();
  }

  // translate(v=[-20, -20, 0])
  //   cube([40, 40, 40]);
}

render() {
  scale(scale) {
    if (box) {
      intersection() {
        #cube([box_x, box_y, box_z], center=true);
        butler();
      }
    } else {
      butler();
    }
  }
}
