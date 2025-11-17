include <BOSL2/std.scad>

$fn = 120;

// width of the band, height of the slot
w_band = 34;

// inset of the band slot from outside
dr_band = 10;

// thickness of the slot at the lowest point
t_slot = 3;

// extend in and out of the band
w_outer = 1.2;
w_inner = 30;

// either side of the break
h_shaft = 9;

// gap between shafts
dh_shaft = 0.2;

d_bolt = 3;

// relative to r_corn
dr_shaft = -2.6;

// outer radius including slot
r_out = 86;

// corner radius
r_corn = 6;

// radius of the slot cross section, see fig1
r_slot = (dr_band ^ 2 + (w_band / 2) ^ 2) / (2 * dr_band);

// arc to support
a = 95;

// length of the lower
h = 2 * sin(a / 2) * (r_out - dr_band - r_corn);
echo(h=h);

module cross_section() {
  difference() {
    x = dr_band + t_slot;
    translate(v=[x / 2, 0]) {
      square([x, w_band + w_outer + w_inner], center=true);
    }
    translate(v=[r_slot + t_slot, (w_outer - w_inner) / 2]) {
      circle(r=r_slot);
    }
  }
}

module shaft() {
  translate(v=[0, 0, (w_outer - w_inner) / 2]) {
    difference() {
      cylinder(r=r_corn + dr_shaft, h=h_shaft, center=true);
      cylinder(d=d_bolt, h=h_shaft, center=true);
      cylinder(r=r_corn + dr_shaft, h=dh_shaft, center=true);
    }
  }
}

module band_upper() {
  translate(v=[-r_out + dr_band, 0, 0]) {
    rotate(a=-a) {

      color(c="pink") {
        rotate(a=a / 2) {
          translate(v=[r_out - dr_band - r_corn, 0, 0]) {
            shaft();
          }
        }
      }

      rotate_extrude(a=a) {
        translate(v=[r_out - dr_band - t_slot, 0]) {
          cross_section();
        }
      }
      translate(v=[r_out - dr_band, 0, 0]) {
        children();
      }
    }
  }
}

module band_corner() {
  translate(v=[-r_corn, 0, 0]) {

    color(c="red")
      shaft();

    rotate(a=-180 + a / 2) {
      rotate_extrude(a=180 - a / 2) {
        translate(v=[r_corn - t_slot, 0]) {
          cross_section();
        }
      }
      translate(v=[r_corn, 0, 0]) {
        children();
      }
    }
  }
}

module band_lower() {

  translate(v=[0, -h, 0]) {
    translate(v=[-t_slot, h / 2, 0]) {
      rotate(a=90, v=[1, 0, 0]) {
        linear_extrude(center=true, h=h) {
          cross_section();
        }
      }
    }
    children();
  }
}

module band() {
  rotate(a=-90) {
    translate(v=[-dr_band, -h / 2, (w_inner - w_outer) / 2]) {
      band_corner() band_upper() band_corner() band_lower();
    }
  }
}

render() {
  color(c="green")
    top_half(s=500) {
      band();
    }
  color(c="blue")
    bottom_half(s=500) {
      band();
    }
}
