include <BOSL2/std.scad>

$fn = 120;

// widest top point
h_band = 34;

h_support = 25;

// band to padding
r_inner = 67;

// cutoff the outer
t_cutoff = 7;

// arc to support
// a = 135;
// a = 100;

// bottom_half(s=400,z=h_band/2)
// top_half(s=400,z=h_band/2)
// front_half(s=400, y=-10)
//   right_half(s=400, x=30)

// split print OK
//
// diff() {
//   cylinder(r=r_inner + h_band / 2 - t_cutoff, h=h_band) {
//     color(c="green")
//       tag("remove") attach(CENTER, CENTER)
//           torus(r_min=h_band / 2, r_maj=r_inner + h_band / 2);
//
//     color(c="orange")
//       tag("remove") attach(CENTER, CENTER)
//           pie_slice(ang=360 - a, r=r_inner + h_band, l=h_band);
//   }
// }

translate(v=[300, 0, 0])
  back_half(s=400, y=(r_inner + h_band / 2) * sin((180 - a) / 2))
    rotate(a=(180 - a) / 2) {
      translate(v=[0, 0, h_band]) {
        cylinder(r=r_inner + h_band / 2 - t_cutoff, h=h_support);
      }
      difference() {
        cylinder(r=r_inner + h_band / 2 - t_cutoff, h=h_band);
        torus(center=false, r_min=h_band / 2, r_maj=r_inner + h_band / 2);
      }
    }

// translate(v=[0, 300, 0]) {
//   r_band = 40;
//   w_band = 35;
//
//   r_out = 86;
//   h = w_band * 2;
//
//   x = sqrt(r_band ^ 2 - w_band ^ 2);
//   echo(x=x);
//   r_maj = r_out + x;
//   echo(r_maj=r_maj);
//   r_min = r_band;
//   echo(r_min=r_min);
//
//   y = r_band - x;
//   echo(y=y);
//   r_in = r_out - y;
//   echo(r_in=r_in);
//
//   render()
//     back_half(s=400)
//       diff() cylinder(r=r_out, h=h, anchor=CENTRE + BOTTOM) {
//           attach(CENTER, CENTER, inside=true) cylinder(r=r_in, h=h);
//           // attach(CENTER, CENTER, inside=true) cylinder(r=r_out - h / 2, h=h);
//           attach(CENTER, CENTER, inside=true) torus(r_maj=r_maj, r_min=r_min);
//         }
// }

// width of the band, height of the slot
w_band = 34;

// inset of the band slot from outside
dr_band = 10;

// outer radius
r_out = 86;

// corner radius
r_corn = 6;

// see fig1
r_min = (dr_band ^ 2 + (w_band / 2) ^ 2) / (2 * dr_band);
r_maj = r_out + r_min - dr_band;

// arc to support
a = 100;

render()
  translate(v=[-150, 0, 0])
    translate(v=[0, -r_out * cos(a / 2), 0])
      back_half(s=400, y=r_out * cos(a / 2))

        diff() cylinder(r=r_out, h=w_band, anchor=CENTRE + BOTTOM) {
            attach(CENTER, CENTER, inside=true) cylinder(r=r_out - dr_band, h=w_band);
            attach(CENTER, CENTER, inside=true) torus(r_maj=r_maj, r_min=r_min);
          }

render()
  translate(v=[-300, 0, 0])
    translate(v=[0, -(r_out - dr_band) * cos(a / 2), 0])
      diff() cylinder(r=r_out, h=w_band, anchor=CENTRE + BOTTOM) {
          attach(CENTER, CENTER, inside=true) cylinder(r=r_out - dr_band, h=w_band);
          attach(CENTER, CENTER, inside=true) torus(r_maj=r_maj, r_min=r_min);
          attach(CENTER, CENTER, inside=true) pie_slice(ang=(360 - a), spin=270 - a / 2, r=r_out, l=w_band);
        }

module cross_section() {
  difference() {
    translate(v=[dr_band / 2, 0]) {
      square([dr_band, w_band], center=true);
    }
    translate(v=[r_min, 0]) {
      circle(r=r_min);
    }
  }
}

module band_upper() {
  translate(v=[-r_out + dr_band, 0, 0]) {
    rotate(a=-a) {
      rotate_extrude(a=a) {
        translate(v=[r_out - dr_band, 0]) {
          cross_section();
        }
      }
    }
  }
  children();
}

module band_corner() {
  translate(v=[-r_corn, 0, 0]) {
    rotate(a=-180 + a / 2) {
      rotate_extrude(a=180 - a / 2) {
        translate(v=[r_corn, 0]) {
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
  h = 2 * sin(a / 2) * (r_out - dr_band - r_corn);
  translate(v=[0, -h, 0]) {
    translate(v=[0, h / 2, 0]) {
      rotate(a=90, v=[1, 0, 0]) {
        linear_extrude(center=true, h=h) {
          cross_section();
        }
      }
    }
    children();
  }
}

band_corner() band_lower() band_corner() band_upper();
