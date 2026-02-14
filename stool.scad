include <lib/joints.scad>

$fn = 200;

/* [Default Dimensions] */

// -x
l1 = 12; // [0:1:500]

// +x
l2 = 12; // [0:1:500]

// y
w = 15; // [1:1:500]

// z
t = 10; // [1:1:500]

/* [Halving - Large Gaps] */
a_halving = 0; // [-50:0.5:50]
g_shoulder_halving = 0.1; // [0:0.001:2]
g_cheek_halving = 0.1; // [0:0.001:2]
r_edge_halving = 0.25; // [0:0.001:2]

/* [Mortise And Tenon - Large Gaps] */
a_mortise = -8; // [-50:0.5:50]
a_tenon = 8; // [-50:0.5:50]
g_shoulder_mt = 0.1; // [0:0.001:2]
g_cheek_mt = 0.1; // [0:0.001:2]
g_side_mt = 0.1; // [0:0.001:2]
r_edge_mt = 0.25; // [0:0.001:2]

/* [Dovetail - Large Gaps] */
a_dt = 0; // [-50:0.5:50]
a_tail = 10; // [-10:0.5:30]
g_shoulder_dt = 0.1; // [0:0.001:2]
g_cheek_dt = 0.1; // [0:0.001:2]
g_pin_dt = 0.1; // [0:0.001:2]
r_edge_dt = 0.25; // [0:0.001:2]

/* [Dowels - Large] */

d_dowel_v = 2; // [0:0.05:5]
d_dowel_h = 3; // [0:0.05:5]

/* [Debug] */

// joint waste
show_waste_layers = false;

// joint h and v edge lines
show_waste_lines = false;

/* [Tuning] */

$fn = 200; // [10:1:1000]

/* [Testing] */

// explode up
test_explode_z = 0; // [0:1:100]

test_dovetail = true;

test_mortise_tenon = true;

test_halving = true;

// -1 for all
test_model = -1; // [-1:1:8]

test_stool = false;

// -1 for all
test_child = -1; // [-1:1:1]

test_dx = 0; // [0:1:100]

render() {
  dy = 100;
  if (test_dovetail)
    translate(v=[0, 0 * dy, 0])
      test_dovetail();
  if (test_mortise_tenon)
    translate(v=[0, 1 * dy, 0])
      test_mortise_tenon();
  if (test_halving)
    translate(v=[0, 2 * dy, 0])
      test_halving();
  if (test_stool)
    translate(v=[-100, 0 * dy, 0])
      test_stool();
}

module test_joint(m, dx = 0, dy = 0) {
  if (test_model == -1 || test_model == m) {
    translate(v=[m * dx, dy, 0]) {
      if (test_child == -1 || test_child == 0)
        translate(v=[0, 0, test_explode_z])
          color(c=COL[m][0])
            children(0);

      if (test_child == -1 || test_child == 1)
        color(c=COL[m][1])
          children(1);
    }
  }
}

module test_halving() {
  a = a_halving + 17;

  dx = 45 + test_dx;

  test_joint(m=0, dx=dx) {
    halving(inner=true, a=-a_halving);

    rotate(a=90 + a_halving)
      halving();
  }

  test_joint(m=1, dx=dx) {
    halving(inner=true, a=a);

    rotate(a=90 - a)
      halving(a=-a);
  }

  test_joint(m=2, dx=dx) {
    halving(inner=true, a=-a_halving, l2=0);

    rotate(a=90 + a_halving)
      halving(l1=0);
  }

  test_joint(m=3, dx=dx) {
    halving(inner=true, a=a, l1=0);

    rotate(a=90 - a)
      halving(a=-a, l2=0);
  }
}

module test_dovetail() {

  a = a_dt + 4;
  a_tail = a_tail;

  l_socket = w;
  w_socket = w;

  l1_tail = l1;
  l_tail = w_socket * 5 / 7;

  l1_socket = l1 / 2;
  l2_socket = l2 / 2;

  dx = l1_socket + l2_socket + l_socket + test_dx;

  test_joint(m=0, dx=dx) {
    rotate(a=90 + a_dt)
      dove_tail(a_tail=a_tail, l=w_socket, w=l_socket, l1=l1_tail);

    dove_socket(a_tail=a_tail, l=l_socket, w=w_socket, l1=l1_socket, l2=l2_socket);
  }

  test_joint(m=1, dx=dx) {
    rotate(a=90 + a)
      dove_tail(a=a, a_tail=a_tail, l=w_socket, w=l_socket, l1=l1_tail);

    dove_socket(a=a, a_tail=a_tail, l=l_socket, w=w_socket, l1=l1_socket, l2=l2_socket);
  }

  test_joint(m=2, dx=dx) {
    rotate(a=90 + a_dt)
      dove_tail(a_tail=a_tail, l=w_socket, w=l_socket, l1=l1_tail, l_tail=l_tail);

    dove_socket(a_tail=a_tail, l=l_socket, w=w_socket, l_tail=l_tail, l1=l1_socket, l2=l2_socket);
  }

  test_joint(m=3, dx=dx) {
    rotate(a=90 + a)
      dove_tail(a=a, a_tail=a_tail, l=w_socket, w=l_socket, l1=l1_tail, l_tail=l_tail);

    dove_socket(a=a, a_tail=a_tail, l=l_socket, w=w_socket, l_tail=l_tail, l1=l1_socket, l2=l2_socket);
  }

  test_joint(m=4, dx=dx) {
    rotate(a=90 + a_dt)
      dove_tail(a_tail=a_tail, l=w_socket, w=l_socket, l1=l1_tail, l_tail=l_tail, ratio=0, d_dowel=0);

    dove_socket(a_tail=a_tail, l=l_socket, w=w_socket, l_tail=l_tail, ratio=0, d_dowel=0, l1=l1_socket, l2=l2_socket);
  }

  test_joint(m=5, dx=dx) {
    rotate(a=90 + a)
      dove_tail(a=a, a_tail=a_tail, l=w_socket, w=l_socket, l1=l1_tail, l_tail=l_tail, ratio=0, d_dowel=0);

    dove_socket(a=a, a_tail=a_tail, l=l_socket, w=w_socket, l_tail=l_tail, ratio=0, l1=l1_socket, l2=l2_socket, d_dowel=0);
  }
}

module test_mortise_tenon() {
  all = test_model == -1;

  w_tenon = w;
  t_tenon = t;

  w_mortise = w;
  l_mortise = w;

  l_tenon_blind = w * 5 / 7;
  l_tenon_exposed = w * 7 / 5;

  dx = 45 + test_dx;

  test_joint(m=0, dx=dx) {
    tenon(
      a=0,
      w=w_tenon,
      t=t_tenon,
      l=w_mortise,
      l1=l1,
      l2=0,
    );
    rotate(a=90)
      mortise(
        a=0,
        w=w_mortise,
        t=t_tenon,
        l=l_mortise,
        l1=l1,
        l2=l2,
      );
  }

  test_joint(m=1, dx=dx) {
    tenon(
      a=a_tenon,
      w=w_tenon,
      t=t_tenon,
      l=w_mortise,
      l1=l1,
      l2=0
    );
    rotate(a=90 + a_mortise)
      mortise(
        a=a_mortise,
        w=w_mortise,
        t=t_tenon,
        l=l_mortise,
        l1=l1,
        l2=l2
      );
  }

  test_joint(m=2, dx=dx) {
    tenon(
      a=0,
      w=w_tenon,
      t=t_tenon,
      l=w_mortise,
      l1=l1,
      l2=l2,
    );
    rotate(a=90)
      mortise(
        a=0,
        w=w_mortise,
        t=t_tenon,
        l=l_mortise,
        l1=l1,
        l2=0
      );
  }

  test_joint(m=3, dx=dx) {
    tenon(
      a=a_tenon,
      w=w_tenon,
      t=t_tenon,
      l=w_mortise,
      l1=l1,
      l2=l2,
    );
    rotate(a=90 + a_mortise)
      mortise(
        a=a_mortise,
        w=w_mortise,
        t=t_tenon,
        l=l_mortise,
        l1=l1,
        l2=0
      );
  }

  test_joint(m=4, dx=dx) {
    tenon(
      a=a_tenon,
      w=w_tenon,
      t=t_tenon,
      l=w_mortise,
      l1=l1,
      l2=0,
      l_tenon=l_tenon_blind,
    );
    rotate(a=90 + a_mortise)
      mortise(
        a=a_mortise,
        w=w_mortise,
        t=t_tenon,
        l=l_mortise,
        l1=l1,
        l2=l2,
        l_tenon=l_tenon_blind,
      );
  }

  test_joint(m=5, dx=dx) {
    tenon(
      a=a_tenon,
      w=w_tenon,
      t=t_tenon,
      l=w_mortise,
      l1=l1,
      l2=0,
    );
    rotate(a=90 + a_mortise)
      mortise(
        a=a_mortise,
        w=w_mortise,
        t=t_tenon,
        l=l_mortise,
        l1=0,
        l2=l2,
      );
  }

  test_joint(m=6, dx=dx) {
    tenon(
      a=a_tenon,
      w=w_tenon,
      t=t_tenon,
      l=w_mortise,
      l1=l1,
      l2=0,
      l_tenon=l_tenon_blind,
    );
    rotate(a=90 + a_mortise)
      mortise(
        a=a_mortise,
        w=w_mortise,
        t=t_tenon,
        l=l_mortise,
        l1=0,
        l2=l2,
        l_tenon=l_tenon_blind,
      );
  }

  test_joint(m=7, dx=dx) {
    tenon(
      a=a_tenon,
      w=w_tenon,
      t=t_tenon,
      l=w_mortise,
      l1=l1,
      l2=0,
      l_tenon=l_tenon_exposed,
    );
    rotate(a=90 + a_mortise)
      mortise(
        a=a_mortise,
        w=w_mortise,
        t=t_tenon,
        l=l_mortise,
        l1=l1,
        l2=l2,
      );
  }
}

module test_stool() {
  w_cross = 25;
  t_cross = 17;

  w_leg = 22;
  t_leg = t_cross;
  d1_leg_cap = 2;
  dx_leg_cap = w_cross - 5.5;

  a_tenon = 8;
  a_cross = 8;

  l12_halving = 5;
  l1_tenon = 8;
  l2_tenon = 5;
  l2_leg = 75;
  l1_mortise = 5;

  d_top = 125;
  h_top = 2.6;

  show_leg = true;
  show_top = true;
  show_half1 = true;
  show_half2 = true;
  show_half3 = true;
  show_half4 = true;
  dowels = true;

  dx = t_cross / 2 + l12_halving + w_leg / 2 + l1_tenon;

  module leg(a, blind, l1 = 0, ratio = 1 / 3, ratios = undef) {

    rotate(-90 - a) {
      difference() {
        mortise(a=-a, w=w_leg, t=t_cross, l=w_cross, l1=l1, l2=l2_leg + w_cross / 2, l_tenon=blind, ratio=ratio, ratios=ratios);

        translate(v=[l2_leg + w_cross, 0, 0])
          rotate(a)
            cube([w_cross, w_leg * 2, t_cross], center=true);
      }
    }
  }

  module half1() {

    // cross
    color(c="peru")
      rotate(a=-90, v=[1, 0, 0])
        halving(a=a_cross, t=w_cross, w=t_cross, l=t_cross, l1=l12_halving, l2=l12_halving, inner=false);

    // normal leg
    translate(v=[dx, 0, 0]) {
      color(c="chocolate")
        tenon(a=-a_tenon, w=w_cross, t=t_cross, l=w_leg, l1=l1_tenon, l2=0);

      if (show_leg)
        color(c="orange")
          translate(v=[0, 0, 0])
            leg(a=-a_tenon);
    }

    // tee leg
    translate(v=[-dx, 0, 0]) {
      color(c="saddlebrown")
        mirror(v=[1, 0, 0])
          tenon(a=-a_tenon, w=w_cross, t=t_cross, l=w_leg, l1=l1_tenon, l2=l2_tenon);

      if (show_leg)
        color(c="orange")
          translate(v=[0, 0, 0])
            leg(a=a_tenon);
    }
  }

  module half2() {

    // cross
    color(c="burlywood")
      rotate(a=90, v=[1, 0, 0])
        halving(a=a_cross, w=t_cross, t=w_cross, l=t_cross, l1=l12_halving, l2=l12_halving);

    // mortise leg
    translate(v=[dx, 0, 0]) {
      color(c="sienna")
        tenon(a=-a_tenon, w=w_cross, t=t_cross, l=w_leg, l1=l1_tenon, l2=0);

      if (show_leg)
        color(c="orange")
          leg(a=-a_tenon);
    }

    // blind leg
    translate(v=[-dx, 0, 0]) {
      color(c="rosybrown")
        mirror(v=[1, 0, 0])
          tenon(a=-a_tenon, w=w_cross, t=t_cross, l=w_leg, l1=l1_tenon, l2=0, l_tenon=w_leg * 0.75);

      if (show_leg)
        color(c="orange")
          translate(v=[0, 0, 0])
            leg(a=a_tenon, blind=w_leg * 0.75);
    }
  }

  module half3() {

    // cross
    color(c="peru")
      rotate(a=-90, v=[1, 0, 0])
        halving(a=a_cross, t=w_cross, w=t_cross, l=t_cross, l1=l12_halving, l2=l12_halving, inner=false);

    // fat tenon leg
    translate(v=[dx, 0, 0]) {
      color(c="chocolate")
        tenon(a=-a_tenon, w=w_cross, t=t_cross, l=w_leg, l1=l1_tenon, l2=0, ratio=1 / 2);

      if (show_leg)
        color(c="orange")
          translate(v=[0, 0, 0])
            leg(a=-a_tenon, ratio=1 / 2);
    }

    // full blind leg
    translate(v=[-dx, 0, 0]) {
      color(c="saddlebrown")
        mirror(v=[1, 0, 0])
          tenon(a=-a_tenon, w=w_cross, t=t_cross, l=w_leg, l1=l1_tenon, l2=0, l_tenon=w_leg * 0.75);

      if (show_leg)
        color(c="orange")
          translate(v=[0, 0, 0])
            leg(a=a_tenon, blind=w_leg * 0.75);
    }
  }

  module half4() {

    // cross
    color(c="burlywood")
      rotate(a=90, v=[1, 0, 0])
        halving(a=a_cross, w=t_cross, t=w_cross, l=t_cross, l1=l12_halving, l2=l12_halving);

    // double mortise leg
    translate(v=[dx, 0, 0]) {
      color(c="sienna")
        tenon(
          a=-a_tenon, w=w_cross, t=t_cross, l=w_leg, l1=l1_tenon, l2=0,
          ratios=[1 / 5, 2 / 5, 3 / 5, 4 / 5],
        );

      if (show_leg)
        color(c="orange")
          leg(
            a=-a_tenon,
            ratios=[1 / 5, 2 / 5, 3 / 5, 4 / 5],
          );
    }

    // double tenon leg
    translate(v=[-dx, 0, 0]) {
      color(c="rosybrown")
        mirror(v=[1, 0, 0])
          tenon(
            a=-a_tenon, w=w_cross, t=t_cross, l=w_leg, l1=l1_tenon, l2=0, l_tenon=w_leg * 1.75,
            ratios=[1 / 5, 2 / 5, 3 / 5, 4 / 5],
          );

      if (show_leg)
        color(c="orange")
          translate(v=[0, 0, 0])
            leg(
              a=a_tenon,
              ratios=[1 / 5, 2 / 5, 3 / 5, 4 / 5],
            );
    }
  }

  difference() {
    union() {

      // top
      if (show_top) {
        color(c="wheat")
          translate(v=[0, (w_cross + h_top) / 2 + g_cheek_halving, 0])
            rotate(a=90, v=[1, 0, 0])
              cylinder(d=d_top, h=h_top, center=true);
      }
      if (show_half1)
        half1();

      if (show_half2)
        rotate(a=-90 - a_cross, v=[0, 1, 0])
          half2();

      if (show_half3)
        translate(v=[0, 70, 0])
          mirror(v=[0, 1, 0])
            half3();

      if (show_half4)
        translate(v=[0, 70, 0])
          mirror(v=[0, 1, 0])
            rotate(a=-90 - a_cross, v=[0, 1, 0])
              half4();
    }

    // dowels
    if (dowels) {
      x_dowel = t_cross / 2 + l12_halving + l1_tenon + w_leg / 2;
      l_dowel = w_cross * 1.5;

      rotate(a=90, v=[1, 0, 0]) {
        translate(v=[x_dowel, 0, 0])
          cylinder(d=d_dowel_h, h=l_dowel, center=true);

        translate(v=[-x_dowel, 0, 0])
          cylinder(d=d_dowel_h, h=l_dowel, center=true);

        rotate(a=a_cross)
          translate(v=[0, x_dowel, 0])
            cylinder(d=d_dowel_h, h=l_dowel, center=true);

        rotate(a=a_cross)
          translate(v=[0, -x_dowel, 0])
            cylinder(d=d_dowel_h, h=l_dowel, center=true);
      }
    }
  }
}
