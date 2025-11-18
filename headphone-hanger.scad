include <BOSL2/std.scad>

$fn = 400;

// momentum 4, HD820
small = false;

// width of the band, height of the slot
w_band = small ? 34 : 43;

// inset of the band slot from outside
dr_band = small ? 10 : 5;

// thickness of the slot at the lowest point
t_slot = 3;

// thickness of the backing
t_back = 2.4;

// extend in and out of the band
w_outer = 2.4;
w_inner = small ? 30 : 50;

// either side of the break
h_shaft_pieces = 8;

// gap between shafts
dh_shaft = 0.4;

// hold pieces together
d_bolt_pieces = 3.1;
r_shaft_pieces = 3.4;

// hold hanger to wall
d_bolt_wall = 4.4;
r_shaft_wall = 6;

// total
h_shaft_wall = 12;

// inset from upper
dr_shaft_wall = 1.5;

// outer radius including slot
r_out = 79;

// corner radius
r_corn = 6;

// radius of the slot cross section, see fig1
r_slot = (dr_band ^ 2 + (w_band / 2) ^ 2) / (2 * dr_band);
echo(r_slot=r_slot);

// arc to support
a = small ? 85 : 95;

// length of the lower
l_chord = 2 * sin(a / 2) * (r_out - dr_band - r_corn);
echo(l_chord=l_chord);

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

module shaft_wall() {
  translate(v=[0, 0, -h_shaft_wall / 2 + (w_band + w_outer + w_inner) / 2]) {
    difference() {
      cylinder(r=r_shaft_wall, h=h_shaft_wall, center=true);
      cylinder(d=d_bolt_wall, h=h_shaft_wall, center=true);
    }
  }
}

module shaft_pieces() {
  translate(v=[0, 0, (w_outer - w_inner) / 2]) {
    difference() {
      cylinder(r=r_shaft_pieces, h=h_shaft_pieces, center=true);
      cylinder(d=d_bolt_pieces, h=h_shaft_pieces, center=true);
      cylinder(r=r_shaft_pieces, h=dh_shaft, center=true);
    }
  }
}

module band_upper() {
  translate(v=[-r_out + dr_band, 0, 0]) {
    rotate(a=-a) {

      color(c="pink") {
        rotate(a=a / 2) {
          translate(v=[r_out - dr_band - r_corn, 0, 0]) {
            shaft_pieces();
          }
        }
      }

      color(c="orange") {
        rotate(a=a / 12) {
          translate(v=[r_out - dr_band - t_slot - r_shaft_wall + dr_shaft_wall, 0, 0]) {
            shaft_wall();
          }
        }
        rotate(a=a * 11 / 12) {
          translate(v=[r_out - dr_band - t_slot - r_shaft_wall + dr_shaft_wall, 0, 0]) {
            shaft_wall();
          }
        }
      }

      color(c="yellow") {
        rotate_extrude(a=a) {
          translate(v=[r_out - dr_band - t_slot, 0]) {
            cross_section();
          }
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

    color(c="red") {
      shaft_pieces();
    }

    rotate(a=-180 + a / 2) {
      color(c="blue") {
        rotate_extrude(a=180 - a / 2) {
          translate(v=[r_corn - t_slot, 0]) {
            cross_section();
          }
        }
      }
      translate(v=[r_corn, 0, 0]) {
        children();
      }
    }
  }
}

module band_lower() {

  translate(v=[0, -l_chord, 0]) {
    color(c="green") {
      translate(v=[-t_slot, l_chord / 2, 0]) {
        rotate(a=90, v=[1, 0, 0]) {
          linear_extrude(center=true, h=l_chord) {
            cross_section();
          }
        }
      }
    }
    children();
  }
}

module band() {
  rotate(a=-90) {
    translate(v=[-dr_band, -l_chord / 2, (w_inner - w_outer) / 2]) {
      band_corner() band_upper() band_corner() band_lower();
    }
  }
}

render() {
  translate(v=[0, 0, 50]) {
    top_half(s=500) {
      band();
    }
  }
  bottom_half(s=500) {
    band();
  }
}
