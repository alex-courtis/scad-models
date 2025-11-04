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
a_cutout = 0; // [0:0.5:90]
t_cutout = 0.2; // [0:0.01:10]

/* [Fill Sleeve] */
h_fill = 0; // [0:0.05:100]
dr_fill = h_fill * dr_sleeve / h_sleeve;
echo(dr_fill=dr_fill);

/* [Holes - Inner Radius] */
r1_hole = 12.5; // [0:0.05:50]
r2_hole = 6.5; // [0:0.05:50]
h1_hole = 30; // [0:0.05:50]
h2_hole = 5; // [0:0.05:50]
t_hole = 1.2; // [0.8:0.4:5]
n_hole = 0; // [0:1:4]

$fn = 200;

module holes(hollow = false) {
  for (i = [1:n_hole]) {
    rotate(a=i * 360 / n_hole) {
      dx = n_hole > 1 ? r_sleeve - max(r1_hole, r2_hole) - t_sleeve - t_hole : 0;
      translate(v=[dx, 0, 0]) {
        color(c="brown") {
          difference() {
            cylinder(r1=r1_hole + t_hole, r2=r2_hole + t_hole, h=h1_hole);
            if (hollow) {
              cylinder(r1=r1_hole, r2=r2_hole, h=h1_hole);
            }
          }
        }
        color(c="gray") {
          translate(v=[0, 0, h1_hole]) {
            difference() {
              cylinder(r=r2_hole + t_hole, h=h2_hole);
              if (hollow) {
                cylinder(r=r2_hole, h=h2_hole);
              }
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

    // remove holes
    if (n_hole && h_fill) {
      holes(hollow=false);
    }
  }

  // holes
  if (n_hole && h_fill) {
    holes(hollow=true);
  }
}
