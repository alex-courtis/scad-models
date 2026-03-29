include <BOSL2/std.scad>
include <lib/geom.scad>

l1_awl = 3.2;
l2_awl = 1.85;
a_awl = 45;
s_awl = 5;

h_guide = 4;
round_guide = 2;

w_window_bottom = 1.5;
w_window_top = 2.5;

// at h_guide 4
scale_awl = 1.4;

poly_awl = [
  [0, l1_awl / 2],
  [-l2_awl / 2, 0],
  [0, -l1_awl / 2],
  [l2_awl / 2, 0],
];

$fn = 200;

module clamp_circle() {
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

module awl_mask() {
  extrude_from_to(
    [0, 0, -h_guide / 2 - 0.00001],
    [0, 0, h_guide / 2 + 0.00001],
    scale=scale_awl,
  )
    polygon(poly_awl);
}

module window_mask(l) {
  prismoid(
    size1=[l, w_window_bottom],
    size2=[l, w_window_top],
    h=h_guide,
    anchor=CENTER,
  );
}

module awl_guide_straight() {

  l = s_awl * 15 + w_window_bottom;
  l_window = l - s_awl * 2 - w_window_bottom;

  w = s_awl * 10;

  difference() {
    cuboid(
      [l, w, h_guide],
      rounding=round_guide,
      except=[BOTTOM],
    );

    for (i = [-l / 2 + w_window_bottom / 2 + s_awl:s_awl:l / 2 - s_awl - w_window_bottom / 2]) {
      translate(v=[i, 0, 0]) {
        rotate(a=a_awl)
          awl_mask();
      }
    }

    // end windows
    translate(v=[-l / 2 + w_window_bottom / 2, 0, 0])
      window_mask(l=w_window_bottom);
    translate(v=[l / 2 - w_window_bottom / 2, 0, 0])
      window_mask(l=w_window_bottom);

    // 1x windows
    translate(v=[0, s_awl, 0])
      window_mask(l=l_window);
    translate(v=[0, -s_awl, 0])
      window_mask(l=l_window);

    // 2x windows
    translate(v=[0, s_awl * 2, 0])
      window_mask(l=l_window);
    translate(v=[0, -s_awl * 2, 0])
      window_mask(l=l_window);
  }
}

module awl_guide_circle() {

  d_holes = 27.5;

  // round to a clean divisor of 90
  a_isoc = 2 * asin(s_awl / d_holes);
  a = 90 / round(90 / a_isoc);

  difference() {
    cuboid(
      [d_holes * 2, d_holes * 2, h_guide],
      rounding=round_guide,
      except=[BOTTOM],
    );

    for (i = [0:a:360 - a]) {
      rotate(a=i)
        translate(v=[d_holes / 2, 0, 0])
          rotate(a=a_awl)
            awl_mask();
    }

    translate(v=[-d_holes, 0, 0])
      cube([1, 0.5, h_guide], center=true);

    translate(v=[d_holes, 0, 0])
      cube([1, 0.5, h_guide], center=true);

    translate(v=[0, -d_holes, 0])
      cube([0.5, 1, h_guide], center=true);

    translate(v=[0, d_holes, 0])
      cube([0.5, 1, h_guide], center=true);
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
