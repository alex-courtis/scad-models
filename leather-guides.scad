include <BOSL2/std.scad>
include <lib/geom.scad>

d_filament = 0.4;
t_layer = 0.2;

show_awl_guide_straight = true;
show_awl_guide_circle = true;

l1_awl = 3.25;
l2_awl = 1.9;
a_awl = 45;
s_awl = 5;

n_awl_straight = 18;

// h_guide = 4;
// scale_awl = 1.25;
h_guide = 2.5;
scale_awl = 1.156;

d1_nub = 1.2;
d2_nub = 1.6;
h_nub = 0.6;

chamfer_guide = h_guide * 0.25;

w_window_bottom = 1.5;
w_window_top = 2.5;

d_circle_holes = [30, 40, 50, 60, 70, 80, 90, 100];

poly_awl = [
  [0, l1_awl / 2],
  [-l2_awl / 2, 0],
  [0, -l1_awl / 2],
  [l2_awl / 2, 0],
];

$fn = 200;

module awl_mask(s = scale_awl, l1 = l1_awl, l2 = l2_awl) {
  // cylinder(h=10,d=1,center=true);
  extrude_from_to(
    [0, 0, -h_guide / 2 - 0.00001],
    [0, 0, h_guide / 2 + 0.00001],
    scale=s,
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

module nub() {
  cylinder(
    d1=d1_nub,
    d2=d2_nub,
    h=h_nub,
    center=true
  );
}

module awl_guide_straight() {

  l = s_awl * (n_awl_straight + 1);
  l_window = l - s_awl * 4;

  w1 = s_awl * 2;
  w2 = s_awl * 9;

  difference() {
    translate(v=[0, (w2 - w1) / 2, 0])
      cuboid(
        [l, w1 + w2, h_guide],
        chamfer=chamfer_guide,
      );

    // awl
    for (i = [-l / 2 + s_awl:s_awl:l / 2 - s_awl]) {
      translate(v=[i, 0, 0])
        rotate(a=a_awl)
          awl_mask();
    }

    // end windows
    translate(v=[-l / 2, 0, 0])
      window_mask(l=s_awl / 2);
    translate(v=[l / 2, 0, 0])
      window_mask(l=s_awl / 2);

    // 1x windows
    translate(v=[0, s_awl, 0])
      window_mask(l=l_window);
    translate(v=[0, -s_awl, 0])
      window_mask(l=l_window);

    // 2x window
    translate(v=[0, s_awl * 2, 0])
      window_mask(l=l_window);
  }

  // nubs
  for (i = [-l / 2 + s_awl / 2:s_awl * 3:l / 2 - s_awl / 2]) {
    translate(v=[i, 0, -h_guide / 2]) {
      for (j = [-w1 + s_awl / 2:s_awl * 2:w2 - s_awl / 2]) {
        translate(v=[0, j, -h_nub / 2])
          nub();
      }
    }
  }
}

module awl_guide_circle(d) {

  // round to a clean divisor of 90
  a_isoc = 2 * asin(s_awl / d);
  a = 90 / round(90 / a_isoc);

  d_outer = max(d + s_awl * 2, 70);

  difference() {
    cyl(
      d=d_outer,
      h=h_guide,
      chamfer=chamfer_guide,
    );

    for (i = [0:a:360 - a]) {
      rotate(a=i)
        translate(v=[d / 2, 0, 0])
          rotate(a=-a_awl)
            awl_mask();
    }

    // windows
    difference() {
      for (a = [0:90:90]) {
        rotate(a=a)
          window_mask(l=d_outer);
      }

      // outside
      tube(
        od=d_outer - s_awl / 2,
        id=d_outer - s_awl * 3 / 2,
        h=h_guide * 2,
      );

      // not over holes
      tube(
        od=d + s_awl * 1.5,
        id=d - s_awl * 1.5,
        h=h_guide * 2,
      );
    }
  }

  // nubs
  difference() {
    for (i = [s_awl:s_awl * 2:d_outer / 2]) {
      translate(v=[0, 0, -h_guide / 2]) {
        for (j = [s_awl:s_awl * 2:d_outer / 2]) {
          translate(v=[i, j, -h_nub / 2])
            nub();
          translate(v=[i, -j, -h_nub / 2])
            nub();
          translate(v=[-i, j, -h_nub / 2])
            nub();
          translate(v=[-i, -j, -h_nub / 2])
            nub();
        }
      }
    }
    tube(
      od=d + s_awl,
      id=d - s_awl,
      h=h_guide * 2,
    );
    tube(
      od=2 * d_outer,
      id=d_outer - s_awl,
      h=h_guide * 2,
    );
  }

  // fill in some support
  if (d >= 60)
    tube(h=h_guide, od=d / 2 + s_awl, id=d / 2 - s_awl);
}

render() {

  if (show_awl_guide_circle)
    for (i = [0:1:len(d_circle_holes) - 1]) {
      translate(v=[120 * i, 120, 0])
        awl_guide_circle(d=d_circle_holes[i]);
    }

  if (show_awl_guide_straight)
    translate(v=[0, 0, 0])
      awl_guide_straight();
}
