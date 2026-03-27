include <BOSL2/std.scad>
include <lib/geom.scad>

l1_awl = 3.4;
l2_awl = 1.9;
a_awl = 45;
s_awl = 5;

h_guide = 4;
round_guide = 1;

$fn = 200;

module clamp_circle() {
  l = 70;
  w = 40;
  h = 5;
  d = 23;
  rounding = 2.5;

  translate(v=[0, 0, h / 2]) {
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
}

module awl_poly() {
  polygon(
    [
      [0, l1_awl / 2],
      [-l2_awl / 2, 0],
      [0, -l1_awl / 2],
      [l2_awl / 2, 0],
    ]
  );
}

module awl_guide_straight() {

  l = 25;
  w = 8;

  translate(v=[0, 0, h_guide / 2]) {
    difference() {
      cuboid(
        [l, w, h_guide],
        rounding=round_guide,
      );

      for (i = [-l / 2 + s_awl:s_awl:l / 2 - s_awl]) {
        translate(v=[i, 0, 0]) {
          rotate(a=a_awl)
            linear_extrude(h=h_guide * 2, center=true)
              awl_poly();
        }
      }
    }
  }
}

module awl_guide_circle() {

  d_guide = 35;
  d_holes = 27.5;

  // round to a clean divisor of 90
  a_isoc = 2 * asin(s_awl / d_holes);
  a = 90 / round(90 / a_isoc);

  translate(v=[0, 0, h_guide / 2]) {
    difference() {
      cyl(
        d=d_guide,
        h=h_guide,
        rounding=round_guide,
        center=true,
      );

      for (i = [0:a:360 - a]) {
        rotate(a=i)
          translate(v=[d_holes / 2, 0, 0])
            rotate(a=a_awl)
              linear_extrude(h=h_guide * 2, center=true)
                awl_poly();
      }
    }
  }
}

render() {
  translate(v=[200, 0, 0])
    clamp_circle();

  translate(v=[100, 0, 0])
    awl_guide_straight();

  translate(v=[0, 0, 0])
    awl_guide_circle();
}
