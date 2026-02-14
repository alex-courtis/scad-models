include <joints.scad>

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
