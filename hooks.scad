x_base = 19; // [10:0.1:100]
z_base = 13; // [10:0.1:100]

// ratio, overhangs end
x_clip = 0; // [-0.5:0.01:0.5]

// inside of clip
r_inner = 3.5; // [1:0.05:50]

// left from above top of clip
a_cutout_left = 50; // [-180:1:180]

// right from above top of clip
a_cutout_right = 135; // [-180:1:180]

t_base = 1.6; // [0.4:0.1:10]
t_clip = 1.6; // [0.4:0.1:10]

h_overhang_back = 0; // [0.0:0.1:10]
h_overhang_front = 0; // [0.0:0.1:10]
t_overhang = 1.2; // [0.4:0.1:10]

y_eccentricity = 1; // [0.25:0.025:1]

$fn = 200; // [0:5:1000]

r = r_inner + t_clip;

assert(a_cutout_right >= a_cutout_left);

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

        // radius for the cutout mask - diamond
        ar = 2 * (r + t_clip);

        // left point
        xa = ar * cos(-a_cutout_left + 90);
        ya = ar * sin(-a_cutout_left + 90);

        // right point
        xc = ar * cos(a_cutout_right - 90);
        yc = -ar * sin(a_cutout_right - 90);

        // mid angle
        am = (180 - a_cutout_left - a_cutout_right) / 2;

        // mid point
        xm = ar * cos(am);
        ym = ar * sin(am);

        polygon(
          [
            [0, 0],
            [xc, yc],
            [xm, ym],
            [xa, ya],
            [0, 0],
          ]
        );
        }
      }
    }
  }
}
