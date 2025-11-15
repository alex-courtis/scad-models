/* [Sleeve - Outer Radius] */
r_sleeve = 12.75; // [5:0.05:100]
dr_sleeve = 0; // [-10:0.05:20]
z_sleeve = 19.0; // [5:0.05:100]
t_sleeve = 2.0; // [0.8:0.4:5]

/* [Collar] */
z_collar = 2.4; // [0:0.1:100]
r_collar = r_sleeve + z_collar;
echo(r_collar=r_collar);

/* [Cutout Arc Triangle] */
a_cutout = 0; // [0:0.05:90]
dz_cutout = 0.2; // [0:0.01:10]

/* [Fill Sleeve] */
z_fill = 0; // [0:0.05:100]
dy_fill = 0; // [-200:0.05:0]
dr_fill = z_fill * dr_sleeve / z_sleeve;
echo(dr_fill=dr_fill);

/* [Bar] */
bar = false;
z_bar = 0; // [0:0.05:100]
dy_bar = 0; // [-100:0.05:100]
t_bar = 0; // [0:0.05:20]

/* [Holes - Inner Radius] */
r1_hole = [12.5, 12.5, 12.5]; // [0:0.05:50]
r2_hole = [6.5, 6.75, 5.5]; // [0:0.05:50]
z1_hole = [42.5, 32.5, 37.5]; // [0:0.05:50]
z2_hole = [5, 5, 5]; // [0:0.05:50]
dx_hole = -2.4; // [-20:0.4:0]
t_hole = 0.8; // [0.8:0.4:5]
n_hole = 0; // [0:1:3]

$fn = 200;

module holes(hollows_only = false) {

  dx = n_hole > 1 ? r_sleeve - max(max(r1_hole), max(r2_hole)) - t_hole + dx_hole : 0;
  for (i = [0:n_hole - 1]) {
    rotate(a=i * 360 / n_hole) {
      translate(v=[dx, 0, 0]) {
        color(c="brown") {
          difference() {
            if (!hollows_only) {
              cylinder(r1=r1_hole[i] + t_hole, r2=r2_hole[i] + t_hole, h=z1_hole[i]);
            }
            cylinder(r1=r1_hole[i], r2=r2_hole[i], h=z1_hole[i]);
          }
        }
        color(c="gray") {
          translate(v=[0, 0, z1_hole[i]]) {
            difference() {
              if (!hollows_only) {
                cylinder(r=r2_hole[i] + t_hole, h=z2_hole[i]);
              }
              cylinder(r=r2_hole[i], h=z2_hole[i]);
            }
          }
        }
      }
    }
  }
}

render() {
  difference() {
    union() {

      // collar
      color(c="blue") {
        if (z_collar) {
          difference() {
            cylinder(r1=r_sleeve, r2=r_collar, h=z_collar);
            cylinder(r=r_sleeve - t_sleeve, h=z_sleeve);
          }
        }
      }

      // sleeve
      color(c="green") {
        translate(v=[0, 0, z_collar])
          difference() {
            cylinder(r1=r_sleeve, r2=r_sleeve - dr_sleeve, h=z_sleeve);
            cylinder(r1=r_sleeve - t_sleeve, r2=r_sleeve - dr_sleeve - t_sleeve, h=z_sleeve);
          }
      }

      // fill
      color(c="orange") {
        if (z_fill) {
          z = min(z_fill, z_sleeve);
          difference() {
            cylinder(h=z, r1=r_sleeve, r2=r_sleeve - dr_fill);
            translate(v=[0, r_sleeve * 2 + dy_fill, z / 2]) {
              cube([r_sleeve * 2, r_sleeve * 2, z], center=true);
            }
          }
        }
      }

      // bar
      if (bar) {

        // outside portion
        color(c="darkviolet") {
          intersection() {
            translate(v=[0, 0, -z_bar]) {
              cylinder(r=r_sleeve, h=z_bar);
            }
            translate(v=[0, dy_bar, -z_bar / 2]) {
              cube([r_sleeve * 2, t_bar, z_bar], center=true);
            }
          }
        }

        // inside bar portion
        color(c="plum") {
          intersection() {
            cylinder(r1=r_sleeve, r2=r_sleeve - dr_sleeve, h=z_sleeve);
            translate(v=[0, dy_bar, z_sleeve / 2]) {
              cube([r_sleeve * 2, t_bar, z_sleeve], center=true);
            }
          }
        }
      }
    }

    // cutout
    color(c="red") {
      if (a_cutout) {
        translate(v=[0, 0, dz_cutout]) {
          linear_extrude(height=z_sleeve + z_collar - dz_cutout) {
            polygon(
              [
                [0, 0],
                [2 * r_collar, 0],
                [2 * r_collar * cos(a_cutout), 2 * r_collar * sin(a_cutout)],
                [0, 0],
              ]
            );
          }
        }
      }
    }

    // remove hole hollows
    holes(hollows_only=true);
  }

  // create hollow holes
  holes(hollows_only=false);
}
