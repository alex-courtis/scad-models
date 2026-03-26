include <BOSL2/std.scad>
include <lib/geom.scad>

$fn = 200;

module magnet() {
  l = 70;
  w = 40;
  h = 5;
  d = 23;
  rounding = 2.5;

  intersection() {
    tube(
      id=d,
      od=l * 2,
      h=h,
      rounding2=rounding / 2,
      center=true,
    );

    cuboid(
      [l, w, h],
      rounding=rounding,
      except=[BOTTOM],
    );
  }
}

render() {
  magnet();
}
