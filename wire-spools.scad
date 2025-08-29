/* [Hub] */

// excluding h_wheel
h_hub = 10; // [5:0.1:50]

// inner including walls
r_hub = 15; // [15:0.1:50]

// inside r_hub
t_hub = 1.6; // [0.4:0.1:10]

// single slot
h_hub_starter = 5; // [1:1:50]

// single slot
w_hub_starter = 3; // [1:1:50]

/* [Wheel] */

// wheel and brace
t_wheel = 1.6; // [0.4:0.1:10]

// total
r_wheel = 40; // [10:1:400]

// rim r_hub delta
dr_rim = -0.4; // [-50:1:50]

// inside hub
h_rim = 6; // [0:0.1:10]

/* [Spokes] */

// gap, spoke, gap
a_spoke = 10; // [0:5:90]

// centered
h_spoke = 15; // [0:1:400]

// pairs: gap, spoke, gap
n_spokes = 3; // [0:1:10]

/* [Brace] */

// crosses hub
w_brace = 20; // [0:1:50]

// centre hole for drill shaft
d_hole_shaft = 4.10; // [1:0.01:10]

// other holes for brace
d_hole_brace = 4.05; // [1:0.01:10]

// offset from shaft hole
offset_hole_brace = 10; // [0:1:400]

$fn = 200;

module wheel() {
  color(c="green") {
    difference() {

      // wheel itself
      cylinder(h=t_wheel, r=r_wheel);
      cylinder(h=t_wheel, r=r_hub - t_hub);

      // spoke cutouts
      for (i = [0:n_spokes - 1]) {
        a = i * (360 / n_spokes);
        rotate_extrude(a=a_spoke, start=a - a_spoke * 1.5) {
          translate(v=[(r_wheel + r_hub - h_spoke) / 2, 0, 0])
            square([h_spoke, t_wheel]);
        }
        rotate_extrude(a=a_spoke, start=a + a_spoke * 0.5) {
          translate(v=[(r_wheel + r_hub - h_spoke) / 2, 0, 0])
            square([h_spoke, t_wheel]);
        }
      }
    }

    difference() {

      // brace
      translate(v=[0, 0, t_wheel / 2])
        cube([w_brace, r_hub * 2, t_wheel], center=true);

      // shaft hole
      translate(v=[0, 0, -0.1])
        cylinder(d=d_hole_shaft, h=t_wheel + 0.2);

      // brace holes
      translate(v=[0, offset_hole_brace, -0.1])
        cylinder(d=d_hole_brace, h=t_wheel + 0.2);
      translate(v=[0, -offset_hole_brace, -0.1])
        cylinder(d=d_hole_brace, h=t_wheel + 0.2);
    }
  }
}

module wheel_rim() {
  color(c="orange") {

    // connecting rim
    difference() {
      cylinder(r=r_hub - t_hub, h=t_wheel + h_rim);
      cylinder(r=r_hub - t_hub + dr_rim - t_hub, h=t_wheel + h_rim);
    }
  }
}

module hub() {
  color(c="blue") {
    difference() {
      // hub itself
      cylinder(h=h_hub, r=r_hub);

      // middle
      cylinder(h=h_hub, r=r_hub - t_hub);
    }
  }
}

module hub_starter() {
  // slot
  translate(v=[r_hub / 2, 0, h_hub / 2])
    cube([r_hub, w_hub_starter, h_hub_starter], center=true);
}

render() {
  difference() {
    union() {
      wheel();
      hub();
    }
    hub_starter();
  }
}

translate(v=[0, r_wheel * 2 + t_wheel, 0])
  render() {
    difference() {
      union() {
        wheel();
        wheel_rim();
      }
      hub_starter();
    }
  }
