// or just the wheel with rim
hub = true;

/* [Hub] */

// excluding h_wheel
h_hub = 20; // [5:1:50]

// inner including walls
r_hub = 25; // [10:1:50]

// inside r_hub
t_hub = 1.6; // [0.4:0.1:10]

// single slot
h_hub_starter = 10; // [1:1:50]

// single slot
w_hub_starter = 4; // [1:1:50]

/* [Wheel] */

// wheel and brace
t_wheel = 1.2; // [0.4:0.1:10]

// total
r_wheel = 80; // [10:1:400]

// slot larger than r_hub
dr_rim = 0.4; // [10:1:50]

// inside hub
h_rim = 6; // [0:0.1:10]

/* [Spokes] */

// gap, spoke, gap
a_spoke = 5; // [0:5:90]

// centered
h_spoke = 45; // [0:1:400]

// pairs: gap, spoke, gap
n_spokes = 4; // [0:1:10]

/* [Brace] */

// crosses hub
w_brace = 20; // [0:1:50]

// centre hole for drill shaft
d_hole_shaft = 4.10;

// other holes for brace
d_hole_brace = 3.1;

// offset from shaft hole
offset_hole_brace = 10;

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
      cylinder(d=d_hole_shaft, h=t_wheel);

      // brace holes
      translate(v=[0, offset_hole_brace, 0])
        cylinder(d=d_hole_brace, h=t_wheel);
      translate(v=[0, -offset_hole_brace, 0])
        cylinder(d=d_hole_brace, h=t_wheel);
    }
  }
}

module wheel_rim() {
  color(c="orange") {

    // connecting rim
    difference() {
      cylinder(r=r_hub - t_hub + dr_rim, h=t_wheel + h_rim);
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
      if (hub) {
        hub();
      } else {
        wheel_rim();
      }
    }
    hub_starter();
  }
}
