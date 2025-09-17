// use multiples of 0.8 nozzle size and exact wall
// double 0.8 for diameters

d_outer = 40;
d_inner = 24.8;

d_hole = 12;
d_bolt = 6;

d_lip = 17.6;

d_rim = 14.4;

d_top = 30;

d_bolt_head = 12;

w_nut = 9.8;
d_nut = w_nut * 2 / sqrt(3); // M6
echo(d_nut=d_nut);
d_nut_adjusted = d_nut * 1.015;
echo(d_nut_adjusted=d_nut_adjusted);
h_nut = 4.75;
h_nut_hole = 7;

d_washer = 12;
h_washer = 1.5;

h = 25;

h_lip = 2.5;
h_peg = 2.5;
h_top = 6;

dx_top = d_outer;
// dx_top = 0;

$fn = 200;

render() {
  translate(v=[dx_top, 0, h - h_lip]) {
    union() {
      difference() {
        color(c="orange")
          cylinder(d=d_lip, h=h_lip);
        color(c="pink")
          cylinder(d=d_rim, h=h_lip);
      }

      difference() {
        color(c="purple")
          translate(v=[0, 0, h_lip])
            cylinder(d=d_top, h=h_top);
        color(c="black")
          translate(v=[0, 0, h_lip])
            cylinder(d=d_bolt, h=h_top);
        color(c="red")
          translate(v=[0, 0, h_lip + h_top - h_washer])
            cylinder(d=d_washer, h=h_washer);
      }
    }
  }

  difference() {
    union() {
      color(c="blue")
        difference() {
          cylinder(d=d_outer, h=h);
          translate(v=[0, 0, h - h_lip])
            cylinder(d=d_inner, h=h_lip);
        }

      color(c="green")
        translate(v=[0, 0, h - h_lip])
          cylinder(d=d_hole, h=h_peg);
    }

    color(c="black")
      cylinder(d=d_bolt, h=h);

    color(c="red")
      cylinder(d=d_nut_adjusted, h=h_nut_hole, $fn=6);
  }
}
