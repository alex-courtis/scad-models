include <lib/joints.scad>

/* [Debug] */

// joint waste
show_waste_layers = false;

// joint h and v edge lines
show_waste_lines = false;

show_leg = true;
show_step_bottom = true;
show_step_top = true;

show = "quarter"; // ["quarter", "half", "whole"]

// dowels
show_dowel_waste = false;

show_points = false;

explode = 0; // [0:1:100]

/* [Halving - 0.4 Nozzle Cheek Facing Up] */
g_shoulder_halving = 0.004; // [0:0.001:2]
g_cheek_halving = 0.12; // [0:0.001:2]
r_edge_halving = 0.15; // [0:0.001:2]

/* [Dovetail - 0.4 Nozzle Cheek Facing Up] */
a_tail = 10; // [1:0.5:30]
g_shoulder_dt = 0.035; // [0:0.001:2]
g_cheek_dt = 0.12; // [0:0.001:2]
g_pin_dt = 0.001; // [0:0.001:2]
r_edge_dt = 0.25; // [0:0.001:2]

/* [General Dimensions] */

scale = 0.4; // [0.1:0.01:1]

l_tail_abs = 11; // [0:0.5:100]
l_tail = l_tail_abs * scale;

l_step_top_abs = 415; // [100:1:1000]
l_step_top = l_step_top_abs * scale;

// inner leg to leg: 349 - l_tail * 2
l_step_bottom_abs = 327; // [100:1:1000]
l_step_bottom = l_step_bottom_abs * scale;

w_step_top_abs = 147; // [50:1:500]
w_step_top = w_step_top_abs * scale;

t_step_top_abs = 23; // [5:1:50]
t_step_top = t_step_top_abs * scale;

w_step_bottom_abs = 147; // [50:1:500]
w_step_bottom = w_step_bottom_abs * scale;

t_step_bottom_abs = 23; // [5:1:50]
t_step_bottom = t_step_bottom_abs * scale;

t_leg_abs = 23; // [5:1:50]
t_leg = t_leg_abs * scale; // [5:1:50]

ratio_leg_halving = 0.6; // [0.1:0.01:0.9]

h_dowel = 42; // [0:1:80]
d_dowel = 2.35; // [0:0.05:5]

/** 
            C-----D
           /     / 
          /      |
         /      / 
        /       | 
       /       /  
      /        |  
     M   Q    N   
    /         |   
   /         /    
  /          |    
 /          /    
B           |
|          /
|          |
|         /
O         |
|        /
A--------E

OA is t_step_top / 2
Mx == Qx == Nx
My is a bit more than half Cy accounting for the floor being the "middle of a joint"
*/

// AB from x axis
a_leg_inner = 72.5; // [60:1:90]

// DC from x axis
a_leg_outer = 80; // [70:1:90]

A = [0, -t_step_top / 2];
echo(A=A);

B = [0, 80 * scale - t_step_top / 2];
echo(B=B);

E = [75 * scale, A[1]];
echo(E=E);

D = [
  cos(a_leg_outer) * 433 * scale + E[0],
  sin(a_leg_outer) * 433 * scale - t_step_top / 2,
];
echo(D=D);

C = line_intersect(P1=B, a1=a_leg_inner, P2=D, a2=0);
echo(C=C);

My = (C[1] + t_step_top / 2) / 2;
M = line_intersect(P1=B, a1=a_leg_inner, P2=[0, My], a2=0);
echo(M=M);

N = line_intersect(P1=E, a1=a_leg_outer, P2=[0, My], a2=0);
echo(N=N);

Q = (M + N) / 2;
echo(Q=Q);

x_leg = D[0] - A[0];
echo(x_leg=x_leg);

y_leg = D[1] - A[1];
echo(y_leg=y_leg);

module leg_poly() {
  polygon([A, B, C, D, E]);
}

module dowel() {
  rotate(a=90, v=[0, 1, 0]) {
    if (show_dowel_waste)
      #cylinder(h=h_dowel, d=d_dowel, center=true);
    else
      cylinder(h=h_dowel, d=d_dowel, center=true);
  }
}

module step_top_quarter() {
  intersection() {

    // this would crash openscad starting at b8e0f1906, when the two legs were butted up against each other

    // body is joint covering entire leg x
    translate(v=[x_leg / 2, 0, 0])
      mirror(v=[0, 1, 0])
        rotate(a=90, v=[0, 1, 0])
          dove_socket(
            l=t_leg,
            w=t_step_top,
            l_tail=l_tail,
            l1=l_step_bottom / 2,
            l2=(l_step_top - l_step_bottom) / 2 - t_leg,
            t=x_leg,
            ratio=0,
            d_dowel=0,
          );

    // plane to leg bounds
    linear_extrude(h=l_step_top, center=true)
      leg_poly();
  }
}

module step_top_half() {
  translate(v=[explode, -explode, 0]) {

    color(c=COL[2][0])
      step_top_quarter();

    if (show == "half" || show == "whole") {
      translate(v=[0, 0, l_step_bottom + t_leg])
        mirror(v=[0, 0, 1])
          color(c=COL[2][1])
            step_top_quarter();
    }
  }
}

module step_top() {
  if (show_step_top) {

    step_top_half();

    if (show == "whole") {
      translate(v=[0, 0, l_step_bottom + t_leg])
        rotate(a=180, v=[0, 1, 0])
          step_top_half();
    }
  }
}

module step_bottom_quarter() {

  // maths is hard with compound angles, build it out of two half halvings
  l_inner = (Q - M) [0] * sin(a_leg_inner) * 2;
  l_outer = (N - Q) [0] * sin(a_leg_outer) * 2;

  // from 0 to w_step_bottom
  l1_inner = Q[0] - l_inner / 2;
  l2_outer = w_step_bottom - l_outer / 2 - l_inner / 2 - l1_inner;

  // covers inner and outer
  l_bridge = -min(l_outer, l_inner) / 2;

  // entire length
  t = t_leg + l_step_bottom / 2;
  ratio = t_leg * ratio_leg_halving / t;

  // move down
  translate(v=[0, Q[1], 0]) {
    difference() {

      // move to joint centre
      translate(v=[Q[0], 0, l_step_bottom / 4]) {

        // inner halving
        halving(
          w=t_step_bottom,
          l=l_inner,
          l1=l1_inner,
          l2=l_bridge,
          t=t,
          a1=90 - a_leg_inner,
          a2=90 - a_leg_outer,
          inner=true,
          ratio=ratio,
        );

        // outer halving
        halving(
          w=t_step_bottom,
          l=l_outer,
          l1=l_bridge,
          l2=l2_outer,
          t=t,
          a1=90 - a_leg_inner,
          a2=90 - a_leg_outer,
          inner=true,
          ratio=ratio,
        );
      }

      translate(v=[0, 0, t_leg * 1.5])
        dowel();
    }
  }
}

module step_bottom_half() {
  translate(v=[explode, explode, 0]) {

    color(c=COL[0][0])
      step_bottom_quarter();

    if (show == "half" || show == "whole") {
      translate(v=[0, 0, l_step_bottom + t_leg])
        mirror(v=[0, 0, 1])
          color(c=COL[0][1])
            step_bottom_quarter();
    }
  }
}

module step_bottom() {
  if (show_step_bottom) {

    step_bottom_half();

    if (show == "whole") {
      translate(v=[0, 0, l_step_bottom + t_leg])
        rotate(a=180, v=[0, 1, 0])
          step_bottom_half();
    }
  }
}

module leg() {
  difference() {
    intersection() {

      // body
      linear_extrude(h=t_leg, center=true)
        leg_poly();

      // tail covers entire leg
      translate(v=[x_leg / 2, 0, 0])
        rotate(a=90, v=[0, 0, -1])
          rotate(a=90, v=[1, 0, 0])
            dove_tail(
              w=t_leg,
              l=t_step_top,
              l_tail=l_tail,
              l1=y_leg,
              t=x_leg,
              ratio=0,
              d_dowel=0,
            );

      // halving covers entire leg
      translate(v=Q)
        rotate(a=90)
          halving(
            l=t_step_bottom,
            w=x_leg * 2,
            t=t_leg,
            l1=y_leg,
            l2=y_leg,
            inner=false,
            ratio=ratio_leg_halving,
          );
    }

    translate(v=[0, t_step_top, 0])
      dowel();

    translate(v=[0, 2.5 * t_step_top, 0])
      dowel();
  }
}

module legs_half() {
  translate(v=[explode, 0, 0]) {
    translate(v=[0, 0, -explode])
      color(COL[1][0])
        leg();

    if (show == "half" || show == "whole") {
      translate(v=[0, 0, explode])
        translate(v=[0, 0, l_step_bottom + t_leg])
          mirror(v=[0, 0, 1])
            color(COL[1][1])
              leg();
    }
  }
}

module legs() {
  if (show_leg) {
    legs_half();

    if (show == "whole") {
      translate(v=[0, 0, l_step_bottom + t_leg])
        rotate(a=180, v=[0, 1, 0])
          legs_half();
    }
  }
}

render() {

  if (show_points) {
    d = 2;
    color(c="yellow") {
      for (p = [A, B, C, D, E, M, N, Q]) {
        translate(v=p)
          cylinder(d=d, h=t_leg * 2, center=true);
      }
    }
    color(c="red") {
      translate(v=[x_leg, y_leg])
        cylinder(d=d, h=t_leg * 2, center=true);
    }
  }

  legs();
  step_top();
  step_bottom();
}
