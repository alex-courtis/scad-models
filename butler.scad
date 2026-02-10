include <stool.scad>

/* [Testing] */
test_explode_z = 0; // [0:1:100]
show_wastes = false;

explode = 0; // [0:1:100]

/* [General Dimensions] */

l_step_top = 415; // [100:1:1000]
w_step_top = 147; // [50:1:500]
w_step_bottom = 147; // [50:1:500]
d_step = 23; // [5:1:50]
l_step_bottom = 349; // [100:1:1000]

// TODO set this to d_step once it lines up
d_leg = 33; // [5:1:50]

// TODO remove
// l_joint_step = 17;
l_joint_step = 99;

l_tail_step = 11; // [0:1:25]

dy_step_bottom = 220;

/* [Dovetail] */
a_dt = 0; // [-50:0.5:50]
a_tail = 10; // [0:0.5:30]
g_shoulder_dt = 0.04; // [0:0.001:2]
g_cheek_dt = 0.10; // [0:0.001:2]
g_pin_dt = 0.002; // [0:0.001:2]
r_edge_dt = 0.25; // [0:0.001:2]
// ratio_dt = 0.5; // [0:0.05:1]
// l_tail = 0; // [0:1:30]
inner_dt = true;

/* [Finishing] */

$fn = 200;

/* [Hidden] */
test = "none";

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

// hull of both legs
module mask_bottom_step() {
  translate(v=[0, -dy_step_bottom, l_step_bottom / 4])
    hull() {
      linear_extrude(h=l_step_bottom, center=true) {
        polygon(leg_poly());
        mirror(v=[1, 0])
          polygon(leg_poly());
      }
    }
}

module mask_bottom_joint() {
  translate(v=[0, -dy_step_bottom, 0])
    linear_extrude(h=d_leg, center=true)
      polygon(leg_poly());
}

module step_bottom() {

  // step as a dovetail, planing sides flush with leg
  intersection() {
    translate(v=[w_step_bottom / 2, 0, 0])
      rotate(a=90, v=[0, 1, 0])
        dove_tail(
          w=d_step,
          l=d_leg,
          l_tail=l_tail_step,
          l1=l_step_bottom / 2 - l_tail_step,
          d=w_step_bottom,
          ratio=0,
          d_dowel=0,
        );

    mask_bottom_step();
  }

  // remove dovetail beyond step with a shoulder gap
  difference() {
    {
      z = l_tail_step + g_shoulder_dt / 2;
      dz = (z + d_leg + g_shoulder_dt) / 2 - l_tail_step;
      translate(v=[w_step_bottom / 4, 0, dz])
        cube([w_step_bottom / 2, d_step, z], center=true);
    }

    // shoulder gap from the 162.5 degree leg
    translate(v=[-g_shoulder_dt / cos(17.5), 0, d_step / 2])
      mask_bottom_joint();
  }
}

module leg2() {

  // body with gap for bottom step joint
  intersection() {
    difference() {
      mask_bottom_joint();

      translate(v=[w_step_bottom / 2, 0, 0])
        cube([w_step_bottom, d_step * 2, d_leg], center=true);
    }
  }

  // bottom step joint
  intersection() {
    mask_bottom_joint();

    translate(v=[w_step_bottom / 2, 0, 0])
      rotate(a=90, v=[0, 1, 0])
        rotate(a=90, v=[0, 0, -1])
          dove_socket(
            l=d_step,
            w=d_leg,
            l_tail=l_tail_step,
            l1=d_step,
            l2=d_step,
            d=w_step_bottom,
            ratio=0,
            d_dowel=0,
          );
  }
}

if (true)
  render() {

    color(COL[2][0])
      translate(v=[explode, 0, 0])
        step_bottom();

    color(COL[2][1])
      translate(v=[0, -explode, -explode])
        leg2();
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

if (false)
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
