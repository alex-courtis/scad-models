r_sleeve = 12.75; // [5:0.05:100]
h_sleeve = 19.0; // [5:0.05:100]
t_sleeve = 2.0; // [0.8:0.4:5]

h_collar = 2.4; // [0:0.1:100]
r_collar = r_sleeve + h_collar;
echo(r_collar=r_collar);

a_cutout = 0; // [0:0.5:90]

t_cutout = 0.2; // [0:0.01:10]

$fn = 200;

render() {
  difference() {
    union() {
      color(c="blue") {
        difference() {
          cylinder(r1=r_sleeve, r2=r_collar, h=h_collar);
          cylinder(r=r_sleeve - t_sleeve, h=h_sleeve);
        }
      }

      color(c="green") {
        translate(v=[0, 0, h_collar])
          difference() {
            cylinder(r=r_sleeve, h=h_sleeve);
            cylinder(r=r_sleeve - t_sleeve, h=h_sleeve);
          }
      }
    }

    color(c="red") {
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
