include <BOSL2/std.scad>

x_base = 19; // [10:0.1:100]
z_base = 13; // [10:0.1:100]

// ratio, overhangs end
x_clip = 0; // [-0.5:0.01:0.5]

// inside of clip
r_inner = 3.5; // [1:0.05:50]

// anticlockwise from above top of clip
a_anticlockwise_cutout = -50; // [-180:1:180]

// clockwise from above top of clip
a_clockwise_cutout = 135; // [-180:1:180]

t_base = 1.6; // [0.4:0.1:10]
t_clip = 1.6; // [0.4:0.1:10]

h_overhang_back = 0; // [0.0:0.1:10]
h_overhang_front = 0; // [0.0:0.1:10]
t_overhang = 1.2; // [0.4:0.1:10]

y_eccentricity = 1; // [0.25:0.025:1]

$fn = 200; // [0:5:1000]

r = r_inner + t_clip;

// mask2d_cove is limited to 0 < a < 180
if (a_anticlockwise_cutout || a_clockwise_cutout) {
  assert(a_clockwise_cutout + a_anticlockwise_cutout > 0);
  assert(a_clockwise_cutout + a_anticlockwise_cutout < 180);
}

render() {
  linear_extrude(height=z_base) {
    // base
    square([x_base, t_base]);

    // back overhang, optional
    if (h_overhang_back > 0) {
      translate(v=[-t_overhang, -h_overhang_back]) {
        square([t_overhang, h_overhang_back + t_base]);
      }
    }

    // front overhang, optional
    if (h_overhang_front > 0) {
      translate(v=[x_base, -h_overhang_front]) {
        square([t_overhang, h_overhang_front + t_base]);
      }
    }

    // clip
    dy_eccentricity = (y_eccentricity - 1) * r;
    dy_base = (t_base > t_clip ? t_base - t_clip : 0);
    translate(
      v=[
        x_base / 2 + x_base * x_clip,
        r + dy_base + dy_eccentricity,
        0,
      ]
    ) {
      scale(v=[1, y_eccentricity]) {
        difference() {
          circle(r=r);
          circle(r=r - t_clip - (1 - y_eccentricity) * t_clip);

          if (a_anticlockwise_cutout || a_clockwise_cutout) {
            rotate(a=90 - a_clockwise_cutout) {
              // limited to < 180
              mask2d_cove(r=r + 0.1, mask_angle=a_clockwise_cutout + a_anticlockwise_cutout);
            }
          } else {

            // double radius arc triangle up
            xo = 2 * r * cos(cutout_outer);
            yo = 2 * r * sin(cutout_outer);
            polygon(
              [
                [0, 0],
                [xo, yo],
                [2 * r, 0],
                [0, 0],
              ]
            );

            // double radius arc triangle down
            xi = 2 * r * cos(cutout_inner);
            yi = -2 * r * sin(cutout_inner);
            polygon(
              [
                [0, 0],
                [xi, yi],
                [2 * r, 0],
                [0, 0],
              ]
            );
          }
        }
      }
    }
  }
}
