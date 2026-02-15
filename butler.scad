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

/* [Halving - Debug] */
g_shoulder_halving = 1; // [0:0.5:5]
g_cheek_halving = 1; // [0:0.5:5]
r_edge_halving = 0.5; // [0:0.5:5]

/* [Dovetail - Debug] */
a_tail = 10; // [1:0.5:30]
g_shoulder_dt = 1; // [0:0.5:5]
g_cheek_dt = 1; // [0:0.5:5]
g_pin_dt = 1; // [0:0.5:5]
r_edge_dt = 0.5; // [0:0.5:5]

/* [General Dimensions] */

scale = 1; // [0.1:0.01:1]

l_tail_abs = 10; // [0:0.5:100]
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

t_leg_abs = 23; // [5:1:50]
t_leg = t_leg_abs * scale; // [5:1:50]

h_dowel = 42; // [0:1:80]

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

_A = [0, -t_step_top / 2];
A = point_round(_A);

_B = [0, 80 * scale - t_step_top / 2];
B = point_round(_B);

_E = [75 * scale, A[1]];
E = point_round(_E);

_D = [
  cos(a_leg_outer) * 433 * scale + _E[0],
  sin(a_leg_outer) * 433 * scale - t_step_top / 2,
];
D = point_round(_D);

_C = line_intersect(P1=_B, a1=a_leg_inner, P2=_D, a2=0);
C = point_round(_C);

// do not round as these should be exact as per rounded leg
My = (C[1] + t_step_top / 2) / 2;
M = line_intersect(P1=B, a1=a_leg_inner, P2=[0, My], a2=0);
N = line_intersect(P1=E, a1=a_leg_outer, P2=[0, My], a2=0);
Q = (M + N) / 2;

echo(A=A);
echo(B=B);
echo(C=C);
echo(D=D);
echo(E=E);
echo(M=M);
echo(M=N);
echo(Q=Q);

// TODO are these necessary?
x_max_leg = D[0] - A[0];
echo(x_max_leg=x_max_leg);

y_max_leg = D[1] - A[1];
echo(y_max_leg=y_max_leg);

module leg_poly() {
  polygon([A, B, C, D, E]);
}

module step_top_quarter() {
  intersection() {

    // body is joint covering entire leg x
    translate(v=[x_max_leg / 2, 0, 0])
      mirror(v=[0, 1, 0])
        rotate(a=90, v=[0, 1, 0])
          dove_socket(
            l=t_leg,
            w=t_step_top,
            l_tail=l_tail,
            l1=l_step_bottom / 2,
            l2=(l_step_top - l_step_bottom) / 2 - t_leg,
            t=x_max_leg,
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

module step_bottom_quarter(){}

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
  intersection() {

    // body
    linear_extrude(h=t_leg, center=true)
      leg_poly();

    // tail covers entire leg
    translate(v=[x_max_leg / 2, 0, 0])
      rotate(a=90, v=[0, 0, -1])
        rotate(a=90, v=[1, 0, 0])
          dove_tail(
            w=t_leg,
            l=t_step_top,
            l_tail=l_tail,
            l1=y_max_leg,
            t=x_max_leg,
            ratio=0,
            d_dowel=0,
          );

    // halving covers entire leg
    translate(v=Q)
      rotate(a=90)
        halving(
          w=x_max_leg * 2,
          t=t_leg,
          l1=y_max_leg,
          l2=y_max_leg,
          inner=false,
        );
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
    color(c="yellow") {
      d = 2;
      translate(v=A)
        cylinder(d=d, h=t_leg * 2, center=true);
      translate(v=B)
        cylinder(d=d, h=t_leg * 2, center=true);
      translate(v=C)
        cylinder(d=d, h=t_leg * 2, center=true);
      translate(v=D)
        cylinder(d=d, h=t_leg * 2, center=true);
      translate(v=E)
        cylinder(d=d, h=t_leg * 2, center=true);
      translate(v=M)
        cylinder(d=d, h=t_leg * 2, center=true);
      translate(v=N)
        cylinder(d=d, h=t_leg * 2, center=true);
      translate(v=Q)
        cylinder(d=d, h=t_leg * 2, center=true);
    }
  }

  legs();
  step_top();
  step_bottom();
}
