include <lib/joints.scad>

/* [Debug] */

// dowels
show_dowel_waste = false;

// joint waste
show_waste_layers = false;

// joint h and v edge lines
show_waste_lines = false;

show_leg = true;
show_step_bottom = true;
show_step_top = true;
show_half = false;

box = false;
box_x = 250; // [0:1:800]
box_y = 80; // [0:1:800]
box_z = 80; // [0:1:800]

explode = 0; // [0:1:100]

/* [Dovetail - Debug] */
g_shoulder_dt = 1; // [0:0.5:5]
g_cheek_dt = 1; // [0:0.5:5]
g_pin_dt = 1; // [0:0.5:5]
r_edge_dt = 0.5; // [0:0.5:5]

/* [General Dimensions] */

scale = 1; // [0.1:0.01:1]

l_step_top_abs = 415; // [100:1:1000]
w_step_top_abs = 147; // [50:1:500]
w_step_bottom_abs = 147; // [50:1:500]
d_step_abs = 23; // [5:1:50]
t_step_top_abs = 23; // [5:1:50]
l_step_bottom_abs = 349; // [100:1:1000]
d_leg_abs = 23; // [5:1:50]
dy_step_bottom_abs = 220; // [100:1:500]

l_step_top = l_step_top_abs * scale;
w_step_top = w_step_top_abs * scale;
w_step_bottom = w_step_bottom_abs * scale;
d_step = d_step_abs * scale;
t_step_top = t_step_top_abs * scale;
l_step_bottom = l_step_bottom_abs * scale;
d_leg = d_leg_abs * scale; // [5:1:50]
dy_step_bottom = dy_step_bottom_abs * scale; // [100:1:500]

h_dowel = 42; // [0:1:80]

/** 
            E-----A
           /     / 
          /      |
         /      / 
        /       | 
       /       /  
      /        |  
     /        /   
    /         |   
   /         /    
  /          |    
 /          /    
D           |
|          /
|          |
|         /
O---------B
*/

// OBA
alo = 100;

// ODE
ali = 162.5;

// clockwise from origin
function leg_poly() =
  let (
    B = [75 * scale, 0],
    D = [0, 80 * scale],
    A = [
      cos(180 - alo) * 433 * scale + B[0],
      sin(180 - alo) * 433 * scale,
    ],
    E = line_intersect(P1=D, a1=ali - 90, P2=A, a2=0),
  ) [
      [0, 0],
      D,
      E,
      A,
      B,
  ];

echo(leg_poly=leg_poly());

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
a_leg_inner = 72.5;

// DC from x axis
a_leg_outer = 80;

function leg_points() =
  let (
    A = [0, -t_step_top / 2],
    B = [0, 80 * scale - t_step_top / 2],
    E = [75 * scale, -t_step_top / 2],
    D = [
      cos(a_leg_outer) * 433 * scale + E[0],
      sin(a_leg_outer) * 433 * scale - t_step_top / 2,
    ],
    C = line_intersect(P1=B, a1=a_leg_inner, P2=D, a2=0),
  ) [
      point_round(A),
      point_round(B),
      point_round(C),
      point_round(D),
      point_round(E),
  ];
ABCDE = leg_points();

x_max_leg = ABCDE[3][0] - ABCDE[0][0];
echo(x_max_leg=x_max_leg);

y_max_leg = ABCDE[3][1] - ABCDE[0][1];
echo(y_max_leg=y_max_leg);

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
    translate(v=[0, 0, l_step_top / 2 + (l_step_bottom - l_step_top) / 2])
      linear_extrude(h=l_step_top, center=true) {
        polygon(leg_poly());
        mirror(v=[1, 0])
          polygon(leg_poly());
      }
  }
}

module step_half_bottom() {

  // build joint at origin then shift to destination for planing
  translate(v=[0, dy_step_bottom, 0]) {

    difference() {
      union() {
        // complete step body as a dovetail
        translate(v=[w_step_bottom / 2, 0, 0])
          rotate(a=90, v=[0, 1, 0])
            dove_tail(
              w=d_step,
              l=d_leg,
              l_tail=d_leg / 2,
              l1=(l_step_bottom - d_leg) / 2,
              t=w_step_bottom,
              ratio=0,
              d_dowel=0,
            );

        // TODO not manifold

        // fill in dovetail beyond step with a shoulder gap
        difference() {
          {
            z = d_step;
            dz = z / 2 + g_shoulder_dt / 2;
            translate(v=[w_step_bottom / 4, 0, dz])
              cube([w_step_bottom / 2, d_step, z], center=true);
          }

          // shoulder gap with the inner angle
          translate(v=[-g_shoulder_dt / cos(180 - ali), -dy_step_bottom, d_step / 2])
            leg_body();
        }
      }

      translate(v=[0, 0, d_leg * 2])
        rotate(a=90, v=[0, 1, 0]) {
          if (show_dowel_waste)
            #cylinder(h=h_dowel, d=d_dowel_v, center=true);
          else
            cylinder(h=h_dowel, d=d_dowel_v, center=true);
        }
    }
  }
}

module step_bottom() {
  intersection() {
    union() {
      step_half_bottom();

      if (!show_half)
        translate(v=[0, 0, l_step_bottom])
          mirror(v=[0, 0, 1])
            step_half_bottom();
    }

    // plane sides flush to legs
    legs_hull();
  }
}

module step_half_top() {

  module body() {
    translate(v=[0, -d_step / 2, (l_step_bottom - l_step_top) / 2])
      cube([w_step_top, d_step, l_step_top / 2], center=false);
  }

  difference() {
    union() {
      intersection() {
        body();

        // top tail covers entire width
        rotate(a=90, v=[0, 1, 0])
          mirror(v=[0, 1, 0])
            dove_socket(
              l=d_leg,
              w=d_step,
              l_tail=d_step / 2,
              l1=bounding_z,
              l2=bounding_z,
              t=bounding_x * 2,
              ratio=0,
              d_dowel=0,
            );
      }

      // fill in slot beyond step with a shoulder gap
      difference() {
        body();
        // x is exact, y not calculated and pushes it out a bit
        translate(v=[g_shoulder_dt / sin(180 - alo), -r_edge_dt, 0])
          legs_hull();
      }
    }

    translate(v=[0, 0, d_leg * 2])
      rotate(a=90, v=[0, 1, 0]) {
        if (show_dowel_waste)
          #cylinder(h=h_dowel, d=d_dowel_v, center=true);
        else
          cylinder(h=h_dowel, d=d_dowel_v, center=true);
      }
  }
}

module step_top() {
  step_half_top();

  if (!show_half)
    translate(v=[0, 0, l_step_bottom])
      mirror(v=[0, 0, 1])
        step_half_top();
}

module leg() {
  difference() {
    intersection() {

      leg_body();

      // bottom socket covers entire leg
      translate(v=[0, dy_step_bottom, 0])
        rotate(a=90, v=[0, 1, 0])
          rotate(a=90, v=[0, 0, -1])
            dove_socket(
              l=d_step,
              w=d_leg,
              l_tail=d_leg / 2,
              l1=bounding_y,
              l2=bounding_y,
              t=bounding_x * 2,
              ratio=0,
              d_dowel=0,
            );

      // top tail covers entire leg
      rotate(a=90, v=[-1, 0, 0])
        rotate(a=90, v=[0, 1, 0])
          dove_tail(
            w=d_leg,
            l=d_step,
            l_tail=d_step / 2,
            l1=bounding_y,
            t=bounding_x * 2,
            ratio=0,
            d_dowel=0,
          );
    }

    translate(v=[0, d_step, 0])
      rotate(a=90, v=[0, 1, 0]) {
        if (show_dowel_waste)
          #cylinder(h=h_dowel, d=d_dowel_v, center=true);
        else
          cylinder(h=h_dowel, d=d_dowel_v, center=true);
      }
    translate(v=[0, d_step * 3, 0])
      rotate(a=90, v=[0, 1, 0]) {
        if (show_dowel_waste)
          #cylinder(h=h_dowel, d=d_dowel_v, center=true);
        else
          cylinder(h=h_dowel, d=d_dowel_v, center=true);
      }
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
      #cube([box_x, box_y, box_z], center=true);
      butler();
    }
  } else {
    butler();
  }

  // difference() {
  //   translate(v=[0, 0, 5])
  //     linear_extrude(h=d_leg, center=true)
  //       polygon(leg_poly());
  //   linear_extrude(h=d_leg, center=true)
  //     polygon(leg_points());
  // }
}
