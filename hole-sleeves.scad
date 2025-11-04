r_sleeve = 12.75; // [5:0.05:100]
dr_sleeve = 0; // [-10:0.05:20]
h_sleeve = 19.0; // [5:0.05:100]
t_sleeve = 2.0; // [0.8:0.4:5]

h_collar = 2.4; // [0:0.1:100]
r_collar = r_sleeve + h_collar;
echo(r_collar=r_collar);

a_cutout = 0; // [0:0.5:90]

t_cutout = 0.2; // [0:0.01:10]

h_fill = 0; // [0:0.05:100]

dr_fill = h_fill * dr_sleeve / h_sleeve;
echo(dr_fill=dr_fill);

$fn = 200;

render() {
  difference() {
    union() {

      // maybe collar
      color(c="blue") {
        if (h_collar) {
          difference() {
            cylinder(r1=r_sleeve, r2=r_collar, h=h_collar);
            cylinder(r=r_sleeve - t_sleeve, h=h_sleeve);
          }
        }
      }

      // always sleeve
      color(c="green") {
        translate(v=[0, 0, h_collar])
          difference() {
            cylinder(r1=r_sleeve, r2=r_sleeve - dr_sleeve, h=h_sleeve);
            cylinder(r1=r_sleeve - t_sleeve, r2=r_sleeve - dr_sleeve - t_sleeve, h=h_sleeve);
          }
      }
    }

    // maybe cutout
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
  }

  // maybe fill
  color(c="orange") {
    if (h_fill) {
      cylinder(h=h_fill, r1=r_sleeve, r2=r_sleeve - dr_fill);
    }
  }
}
