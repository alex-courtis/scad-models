include <joints.scad>

/* [Debug] */

// joint waste
debug_waste_layers = false;

// joint h and v edge lines
debug_waste_lines = false;

// large gaps, edges and dowels
grd_debug = true;

// large gaps
g_debug = 0.5; // [0:0.1:5]

// large edges
r_edge_debug = 0.25; // [0:0.1:5]

// large dowels
d_dowel_debug = 1; // [0:0.1:5]

// child 0
test_explode_z = 0; // [0:1:100]

/* [Dimensions] */

// -x
l1 = 12; // [0:1:500]

// +x
l2 = 12; // [0:1:500]

// y
w = 15; // [1:1:500]

// z
t = 10; // [1:1:500]

a_dt = 0; // [-50:0.5:50]

a_halving = 0; // [-50:0.5:50]

a_mortise = -8; // [-50:0.5:50]
a_tenon = 8; // [-50:0.5:50]

/* [Tuning] */

$fn = 200; // [10:1:1000]

eps_end = 2; // [0:1:100]

eps_r_sphere_ratio = 1.010; // [1:0.001:1.1]

fn_edge_sphere = 24; // [1:1:200]

fn_edge_line = 12; // [1:1:200]

/* [Test Cases] */

test_dovetail = true;

test_mortise_tenon = true;

test_halving = true;

// -1 for all
test_model = -1; // [-1:1:12]

// -1 for all
test_child = -1; // [-1:1:1]

test_dx = 0; // [0:1:500]

test_dy = 80; // [0:1:500]

render() {
  if (test_dovetail)
    translate(v=[0, 0 * test_dy, 0])
      test_dovetail();
  if (test_mortise_tenon)
    translate(v=[0, 1 * test_dy, 0])
      test_mortise_tenon();
  if (test_halving)
    translate(v=[0, 2 * test_dy, 0])
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
      halving(a=a_halving);
  }

  test_joint(m=1, dx=dx) {
    halving(inner=true, a=a);

    rotate(a=90 - a)
      halving(a=-a);
  }

  test_joint(m=2, dx=dx) {
    halving(inner=true, a=-a_halving, l2=0);

    rotate(a=90 + a_halving)
      halving(a=a_halving, l1=0);
  }

  test_joint(m=3, dx=dx) {
    halving(inner=true, a=a, l1=0);

    rotate(a=90 - a)
      halving(a=-a, l2=0);
  }

  test_joint(m=4, dx=dx) {
    halving(a=-a_halving, inner=true, l=w - 5, w=w + 5);

    rotate(a=90 + a_halving)
      halving(a=a_halving, l=w + 5, w=w - 5);
  }

  test_joint(m=5, dx=dx) {
    halving(inner=true, a=a, l=w - 5, w=w + 5);

    rotate(a=90 - a)
      halving(a=-a, l=w + 5, w=w - 5);
  }

  test_joint(m=6, dx=dx) {
    t_lower = t + 7;
    dz_lower = ( -t + t_lower) / 2;
    rat_lower = t / 2 / t_lower;

    halving(inner=true, a=a, l=w - 5, w=w + 5);

    rotate(a=90 - a)
      translate(v=[0, 0, dz_lower])
        halving(a=-a, l=w + 5, w=w - 5, t=t_lower, ratio=rat_lower);
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

  test_joint(m=6, dx=dx) {
    rotate(a=90 + a)
      dove_tail(a=a, a_tail=a_tail, l=w_socket, w=l_socket, l1=l1_tail, l_tail=l_tail, ratio=0, d_dowel=0, w1=2, w2=-2);

    dove_socket(a=a, a_tail=a_tail, l=l_socket, w=w_socket, l_tail=l_tail, ratio=0, l1=l1_socket, l2=l2_socket, d_dowel=0);
  }

  test_joint(m=7, dx=dx) {
    rotate(a=90 + a)
      dove_tail(a=a, a_tail=a_tail, l=w_socket, w=l_socket, l1=l1_tail, l_tail=l_tail, ratio=0, d_dowel=0, w1=-2, w2=2);

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
      l1=0,
      l2=l2,
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
      w1=4,
      w2=3,
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

  test_joint(m=8, dx=dx) {
    tenon(
      a=a_tenon,
      w=w_tenon,
      w1=5,
      w2=5,
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

  test_joint(m=9, dx=dx) {
    tenon(
      a=a_tenon,
      w=w_tenon,
      w1=5,
      w2=5,
      t=t_tenon,
      l=w_mortise,
      l1=0,
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
}
