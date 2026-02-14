include <lib/joints.scad>

// joint waste
show_waste_layers = false;

// joint h and v edge lines
show_waste_lines = false;

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

render() {
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
