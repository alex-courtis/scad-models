/* [Base] */
x_base = 19; // [5:0.1:100]
z_base = 13; // [5:0.1:100]

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
r_guides_inner = 1.6; // [0:0.05:20]

a_guides = 0; // [0:1:360]

$fn = 200; // [0:5:1000]

// centre at 0,0 cutouts left and right from max y
module cutout_cylinder(ri, t, al, ar) {
  rotate(a=90 - al) {
    rotate_extrude(a=360 + al - ar) {
      translate(v=[ri, 0]) {
        square([t, z_base]);
      }
    }
  }
}

module clip() {
  scale(v=[1, y_eccentricity]) {
    t = t_clip + (1 - y_eccentricity) * t_clip;

    translate(v=[0, r_inner + t]) {
      color(c="green") {
        cutout_cylinder(
          ri=r_inner,
          t=t,
          al=a_cutout_left,
          ar=a_cutout_right,
        );
      }

      color(c="olive") {
        rotate(a=-a_cutout_left) {
          translate(v=[0, r_inner + r_guides_inner + t, 0]) {
            cutout_cylinder(
              ri=r_guides_inner,
              t=t,
              al=-180,
              ar=180 - a_guides
            );
          }
        }
      }

      color(c="lime") {
        rotate(a=-a_cutout_right) {
          translate(v=[0, r_inner + r_guides_inner + t, 0]) {
            cutout_cylinder(
              ri=r_guides_inner,
              t=t,
              al=-180 + a_guides,
              ar=180,
            );
          }
        }
      }
    }
  }
}

module model() {
  // base
  color(c="blue") {
    cube([x_base, t_base, z_base]);
  }

  // overhang back
  color(c="goldenrod") {
    if (h_overhang_back > 0) {
      translate(v=[-t_overhang, -h_overhang_back, 0]) {
        cube([t_overhang, h_overhang_back + t_base, z_base]);
      }
    }
  }

  // overhang front
  color(c="sandybrown") {
    if (h_overhang_front > 0) {
      translate(v=[x_base, -h_overhang_front, 0]) {
        cube([t_overhang, h_overhang_front + t_base, z_base]);
      }
    }
  }

  // clip
  dx = x_base / 2 + x_base * x_clip;
  dy = (t_base > t_clip ? t_base - t_clip : 0); // push clip up when base is thicker
  dz = 0;
  translate(v=[dx, dy, dz]) {
    clip();
  }
}

render() model();
