/* [Sleeve - Outer Radius] */
r_sleeve = 12.75; // [5:0.05:100]
dr_sleeve = 0; // [-10:0.05:20]
h_sleeve = 19.0; // [5:0.05:100]
t_sleeve = 2.0; // [0.8:0.4:5]

/* [Collar] */
h_collar = 2.4; // [0:0.1:100]
r_collar = r_sleeve + h_collar;
echo(r_collar=r_collar);

/* [Cutout Arc Triangle] */
a_cutout = 0; // [0:0.05:90]
t_cutout = 0.2; // [0:0.01:10]

/* [Fill Sleeve] */
h_fill = 0; // [0:0.05:100]
dr_fill = h_fill * dr_sleeve / h_sleeve;
echo(dr_fill=dr_fill);

/* [Holes - Inner Radius] */
r1_hole = [12.5, 12.5, 12.5]; // [0:0.05:50]
r2_hole = [6.5, 6.75, 5.5]; // [0:0.05:50]
h1_hole = [42.5, 32.5, 37.5]; // [0:0.05:50]
h2_hole = [5, 5, 5]; // [0:0.05:50]
dx_hole = -2.4; // [-20:0.4:0]
t_hole = 0.8; // [0.8:0.4:5]
n_hole = 0; // [0:1:3]

$fn = 200;

module holes(hollows_only = false) {

  echo("max", max(max(r1_hole), max(r2_hole)));
  dx = n_hole > 1 ? r_sleeve - max(max(r1_hole), max(r2_hole)) - t_hole + dx_hole : 0;
  // dx = n_hole > 1 ? r_sleeve - max(max(r1_hole), max(r2_hole)) - t_hole - t_sleeve : 0;
  for (i = [0:n_hole - 1]) {
    rotate(a=i * 360 / n_hole) {
      translate(v=[dx, 0, 0]) {
        color(c="brown") {
          difference() {
            if (!hollows_only) {
              cylinder(r1=r1_hole[i] + t_hole, r2=r2_hole[i] + t_hole, h=h1_hole[i]);
            }
            cylinder(r1=r1_hole[i], r2=r2_hole[i], h=h1_hole[i]);
          }
        }
        color(c="gray") {
          translate(v=[0, 0, h1_hole[i]]) {
            difference() {
              if (!hollows_only) {
                cylinder(r=r2_hole[i] + t_hole, h=h2_hole[i]);
              }
              cylinder(r=r2_hole[i], h=h2_hole[i]);
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
        if (h_collar) {
          difference() {
            cylinder(r1=r_sleeve, r2=r_collar, h=h_collar);
            cylinder(r=r_sleeve - t_sleeve, h=h_sleeve);
          }
        }
      }

      // sleeve
      color(c="green") {
        translate(v=[0, 0, h_collar])
          difference() {
            cylinder(r1=r_sleeve, r2=r_sleeve - dr_sleeve, h=h_sleeve);
            cylinder(r1=r_sleeve - t_sleeve, r2=r_sleeve - dr_sleeve - t_sleeve, h=h_sleeve);
          }
      }

      // fill
      color(c="orange") {
        if (h_fill) {
          cylinder(h=h_fill, r1=r_sleeve, r2=r_sleeve - dr_fill);
        }
      }
    }

    // cutout
    color(c="red") {
      if (a_cutout) {
        translate(v=[0, 0, t_cutout]) {
          linear_extrude(height=h_sleeve + h_collar - t_cutout) {
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
