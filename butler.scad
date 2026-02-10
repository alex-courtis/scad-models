include <stool.scad>

/* [Testing] */
test_explode_z = 0; // [0:1:100]
show_wastes = false;

explode = 0; // [0:1:100]

/* [General Dimensions] */

/* [Mortise And Tenon] */
g_shoulder_mt = 0.04; // [0:0.001:2]
g_cheek_mt = 0.08; // [0:0.001:2]
g_side_mt = 0.01; // [0:0.001:2]

/* [Dovetail] */
g_shoulder_dt = 0.04; // [0:0.001:2]
g_cheek_dt = 0.08; // [0:0.001:2]
g_pin_dt = 0.003; // [0:0.001:2]

/* [Finishing] */

// 0 for no edges
r_edge = 0.20; // [0:0.001:2]

// 0 for no dowel
d_dowel = 2.30; // [0:0.05:5]

$fn = 200;

/* [Hidden] */
test = "none";

l_step_top = 415;
w_step_top = 147;
w_step_bottom = 147;
d_step = 23;

d_leg = 23;

l_joint_step = 17;
l_tail_step = 10;

// leg to leg
l_step_bottom = 349 - l_tail_step * 2;

dy_step_bottom = 220;

function leg_poly() =
  let (
    B = [75, 0],
    D = [0, 80],
    A = [
      cos(80) * 433 + B[0],
      sin(80) * 433,
    ],
    E = line_intersect(P1=D, a1=162.5 - 90, P2=A, a2=0),
  ) [
      [0, 0],
      D,
      E,
      A,
      B,
  ];

module step_half_bottom() {
  translate(v=[l_step_bottom / 2 + l_joint_step / 2, 0, 0])
    dove_tail(
      ratio=0,
      w=d_step,
      d=w_step_bottom,
      l1=l_step_bottom / 2,
      l=l_joint_step,
      l_tail=l_tail_step,
      d_dowel=0,
    );
}

module step_bottom() {
  translate(v=[0, dy_step_bottom, 0]) {
    rotate(a=90, v=[0, 1, 0])
      step_half_bottom();
    rotate(a=-90, v=[0, 1, 0])
      step_half_bottom();
  }
}

module step_half_top() {
  translate(v=[l_step_top / 4, 0, 0])
    cube([l_step_top / 2, d_step, w_step_top], center=true);
}

module step_top() {
  rotate(a=90, v=[0, 1, 0]) {
    step_half_top();
    rotate(a=180)
      step_half_top();
  }
}

module leg_joint_mask() {
  intersection() {
    linear_extrude(h=d_leg, center=true) {
      polygon(leg_poly());
    }

    // cut out space for the dovetail joint
    color(c="red")
      translate(v=[0, dy_step_bottom, 0])
        cube([300, d_step, d_leg], center=true);
  }
}

module leg() {

  // leg with joint cut out
  difference() {
    linear_extrude(h=d_leg, center=true)
      polygon(leg_poly());
    leg_joint_mask();
  }

  // joint
  intersection() {
    leg_joint_mask();
    translate(v=[w_step_bottom / 2, dy_step_bottom, 0])
      rotate(a=90, v=[1, 0, 0])
        rotate(a=90, v=[0, 1, 0])
          dove_socket(
            w=d_step,
            d=w_step_bottom,
            l=d_step,
            l_tail=l_tail_step,
            l1=d_step,
            l2=d_step,
            d_dowel=0,
          );
  }
}

render() {
  // legs
  translate(v=[0, 0, l_step_bottom / 2 + d_leg / 2 + explode]) {
    color(COL[0][0])
      translate(v=[explode, 0, 0])
        leg();
    color(COL[0][1])
      translate(v=[-explode, 0, 0])
        mirror(v=[1, 0, 0])
          leg();
  }
  translate(v=[0, 0, -l_step_bottom / 2 - d_leg / 2 - explode]) {
    color(COL[1][0])
      rotate(a=180, v=[0, 1, 0])
        translate(v=[explode, 0, 0])
          leg();
    color(COL[1][1])
      rotate(a=180, v=[0, 1, 0])
        translate(v=[-explode, 0, 0])
          mirror(v=[1, 0, 0])
            leg();
  }

  // bottom steps
  color(COL[2][0])
    translate(v=[w_step_bottom / 2 + explode, 0, 0])
      step_bottom();
  color(COL[2][1])
    translate(v=[-w_step_bottom / 2 - explode, 0, 0])
      step_bottom();

  // top steps
  color(COL[3][0])
    translate(v=[w_step_top / 2 + explode, -d_step / 2, 0])
      step_top();
  color(COL[3][1])
    translate(v=[-w_step_top / 2 - explode, -d_step / 2, 0])
      step_top();
}
