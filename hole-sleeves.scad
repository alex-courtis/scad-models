r_sleeve = 12.75;
h_sleeve = 19.0;
t_sleeve = 2.0;

h_collar = 2.4;
r_collar = r_sleeve + h_collar;
echo(r_collar=r_collar);

$fn = 200;

render() {
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
