/* [Base] */
x_base = 19; // [10:0.1:100]
z_base = 13; // [10:0.1:100]

t_base = 1.6; // [0.4:0.1:10]

/* [Overhang] */
h_overhang_back = 0; // [0.0:0.1:10]
h_overhang_front = 0; // [0.0:0.1:10]
t_overhang = 1.2; // [0.4:0.1:10]

/* [Clip] */

t_clip = 1.6; // [0.4:0.1:10]

// ratio, overhangs end
x_clip = 0; // [-0.5:0.01:0.5]

// inside of clip
r_inner = 3.5; // [1:0.05:50]

// left from above top of clip
a_cutout_left = 50; // [-180:1:180]

// right from above top of clip
a_cutout_right = 135; // [-180:1:180]

y_eccentricity = 1; // [0.25:0.025:1]

/* [Guides] */

// inside of guides
r_guides = 1; // [0:0.05:20]

a_guides = 135; // [0:1:360]

$fn = 200; // [0:5:1000]

// mask to cut out two angles from a circle
// 0 degrees is x,y == 0,r
// al is anticlockwise, ar is clockwise
module circle_mask(r, al, ar) {
  let (r = r * PI) {

    // left
    xl = r * cos(-al + 90);
    yl = r * sin(-al + 90);
    polygon(
      [
        [0, 0],
        [0, -r],
        [-r, -r],
        [-r, r],
        [al > 0 ? r : xl, al > 0 ? r : yl],
        [xl, yl],
        [0, 0],
      ]
    );

    // right
    xr = r * cos(ar - 90);
    yr = -r * sin(ar - 90);
    polygon(
      [
        [0, 0],
        [0, -r],
        [r, -r],
        [r, r],
        [ar > 0 ? r : xr, ar > 0 ? r : yr],
        [xr, yr],
        [0, 0],
      ]
    );
  }
}

module clip() {
  // clip
  dy_eccentricity = (y_eccentricity - 1) * r_inner + t_clip;
  dy_base = (t_base > t_clip ? t_base - t_clip : 0);
  translate(
    v=[
      x_base / 2 + x_base * x_clip,
      r_inner + dy_base + dy_eccentricity,
      0,
    ]
  ) {
    scale(v=[1, y_eccentricity]) {
      intersection() {
        difference() {
          circle(r=r_inner + t_clip);
          circle(r=r_inner - (1 - y_eccentricity) * t_clip);
        }

        circle_mask(r=r_inner + t_clip, al=a_cutout_left, ar=a_cutout_right);
      }
    }
  }
}

module model() {
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

    clip();
  }
}

render() {
  model();
}
