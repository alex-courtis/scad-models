include <BOSL2/std.scad>
include <lib/geom.scad>

show_clamp_circle = false;
show_awl_guide_straight = true;
show_awl_guide_circle = false;

l1_awl = 3.2;
l2_awl = 1.85;
a_awl = 45;
s_awl = 5;

n_awl_straight = 16;

h_guide = 4;
w_gridation = 1.5;

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
  if (l) {
    prismoid(
      size1=[l, w_window_bottom],
      size2=[l, w_window_top],
      h=h_guide,
      anchor=CENTER,
    );
  } else {
    cylinder(
      d1=w_window_bottom,
      d2=w_window_top,
      h=h_guide,
      center=true
    );
  }
}

module awl_guide_straight() {

  l_window = s_awl * (n_awl_straight - 1);
  l = l_window + 2 * s_awl + w_window_bottom;

  w1 = s_awl * 2;
  w2 = s_awl * 6;

  gridation_side = sqrt(w_gridation ^ 2 / 2);

  difference() {
    translate(v=[0, (w2 - w1) / 2, 0])
      cuboid(
        [l, w1 + w2, h_guide],
        rounding=round_guide,
        except=[BOTTOM],
      );

    // awl
    for (i = [-l / 2 + w_window_bottom / 2 + s_awl:s_awl:l / 2 - s_awl - w_window_bottom / 2]) {
      translate(v=[i, 0, 0])
        rotate(a=a_awl)
          awl_mask();
    }

    // w gridations except for awl row
    for (i = [-w1 + s_awl:s_awl:w2 - s_awl]) {
      if (i != -w1 + s_awl * 2)
        translate(v=[0, i, -h_guide / 2])
          rotate(a=45, v=[1, 0, 0])
            cuboid([l, gridation_side, gridation_side]);
    }

    // l gridations
    for (i = [-l / 2 + w_window_bottom / 2 + s_awl / 2:s_awl:l / 2 - w_window_bottom / 2]) {
      translate(v=[i, 0, -h_guide / 2])
        rotate(a=90, v=[0, 0, 1])
          rotate(a=45, v=[1, 0, 0])
            cuboid([(w1 + w2) * 2, gridation_side, gridation_side]);
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
          rotate(a=-a_awl)
            awl_mask();
    }

    // centre point window
    window_mask();

    // inside windows
    for (a = [0:90:270]) {
      rotate(a=a)
        translate(v=[d_holes / 4, 0, 0])
          window_mask(l=d_holes / 4);
    }

    // outside windows
    for (a = [0:90:270]) {
      rotate(a=a)
        translate(v=[d_holes * 3 / 4, 0, 0])
          window_mask(l=d_holes / 4);
    }
  }
}

render() {
  if (show_clamp_circle)
    translate(v=[200, 0, 0])
      clamp_circle();

  if (show_awl_guide_circle)
    translate(v=[100, 0, 0])
      awl_guide_circle();

  if (show_awl_guide_straight)
    translate(v=[0, 0, 0])
      awl_guide_straight();
}
