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

explode = 0; // [0:1:100]

/* [Dovetail - Debug] */
g_shoulder_dt = 1; // [0:0.5:5]
g_cheek_dt = 1; // [0:0.5:5]
g_pin_dt = 1; // [0:0.5:5]
r_edge_dt = 0.5; // [0:0.5:5]
a_tail = 10; // [0:0.5:30]

/* [General Dimensions] */

scale = 1; // [0.1:0.01:1]

l_tail_abs = 10; // [1:1:100]
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
     M        N   
    /         |   
   /         /    
  /          |    
 /          /    
B           |
|          /
O          |
|         /
A---------E

OA is t_step_top / 2
*/

// AB from x axis
a_leg_inner = 72.5; // [60:1:90]

// DC from x axis
a_leg_outer = 80; // [70:1:90]

// ABCDE
leg_points =
let (
  A = [0, -t_step_top / 2],
  B = [0, 80 * scale - t_step_top / 2],
  E = [75 * scale, -t_step_top / 2],
  D = [
    cos(a_leg_outer) * 433 * scale + E[0],
    sin(a_leg_outer) * 433 * scale - t_step_top / 2,
  ],
  C = line_intersect(P1=B, a1=a_leg_inner, P2=D, a2=0),
) [point_round(A), point_round(B), point_round(C), point_round(D), point_round(E)];

echo(leg_points=leg_points);

x_max_leg = leg_points[3][0] - leg_points[0][0];
echo(x_max_leg=x_max_leg);

y_max_leg = leg_points[3][1] - leg_points[0][1];
echo(y_max_leg=y_max_leg);

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
      polygon(leg_points);
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

module leg() {
  intersection() {

    // body
    linear_extrude(h=t_leg, center=true)
      polygon(leg_points);

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
  legs();
  step_top();
}
