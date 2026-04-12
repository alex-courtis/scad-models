include <BOSL2/std.scad>
include <lib/geom.scad>

d_filament = 0.4;
t_layer = 0.2;

show_awl_guide_straight = true;
show_awl_guide_circle = false;

l1_awl = 3.2;
l1_awl_t = [3.15, 3.2, 3.25];
l2_awl = 1.85;
l2_awl_t = [1.8, 1.85, 1.9];
a_awl = 45;
s_awl = 5;

n_awl_straight = 18;

h_guide = 4;

d_nub = 1.6;

chamfer_guide = h_guide * 0.4;

w_window_bottom = 1.5;
w_window_top = 2.5;

scale_awl = 1.25;
scale_awl_t = [1.1, 1.15, 1.2, 1.25, 1.3, 1.35];

d_circle_holes = [50, 75, 100];

poly_awl = [
  [0, l1_awl / 2],
  [-l2_awl / 2, 0],
  [0, -l1_awl / 2],
  [l2_awl / 2, 0],
];

function poly_awl_t(l1, l2) =
  [
    [0, l1 / 2],
    [-l2 / 2, 0],
    [0, -l1 / 2],
    [l2 / 2, 0],
  ];

$fn = 200;

module awl_mask(s=scale_awl, l1=l1_awl, l2=l2_awl) {
  // cylinder(h=10,r=1,center=true);
  extrude_from_to(
    [0, 0, -h_guide / 2 - 0.00001],
    [0, 0, h_guide / 2 + 0.00001],
    scale=s,
  )
    polygon(poly_awl_t(l1, l2));
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
  sphere(d=d_nub);
}

module awl_guide_straight() {

  l = s_awl * (n_awl_straight + 1);
  l_window = l - s_awl * 4;

  w1 = s_awl * 2;
  w2 = s_awl * 6.5;

  difference() {
    translate(v=[0, (w2 - w1) / 2, 0])
      cuboid(
        [l, w1 + w2, h_guide],
        chamfer=chamfer_guide,
        except=[BOTTOM],
      );

    // awl
    // for (i = [-l / 2 + s_awl:s_awl:l / 2 - s_awl]) {
    //   translate(v=[i, 0, 0])
    for (i = [0:1:n_awl_straight - 1]) {
      translate(v=[-l / 2 + s_awl + i * s_awl, 0, 0])
        rotate(a=a_awl) {

          i_awl = i % len(scale_awl_t);
          i_l12 = floor(i / len(scale_awl_t));

          awl_mask(
            s=scale_awl_t[i_awl],
            l1=l1_awl_t[i_l12],
            l2=l2_awl_t[i_l12],
          );
        }
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
  for (i = [-l / 2 + s_awl / 2:s_awl * 2:l / 2 - s_awl / 2]) {
    translate(v=[i, 0, -h_guide / 2]) {
      for (j = [-w1 + s_awl / 2:s_awl * 1.5:w2 - s_awl / 2]) {
        if (j) {
          translate(v=[0, j, 0])
            nub();
        }
      }
    }
  }
}

module awl_guide_circle(d) {

  // round to a clean divisor of 90
  a_isoc = 2 * asin(s_awl / d);
  a = 90 / round(90 / a_isoc);

  lw = d + s_awl * 2;

  difference() {
    cuboid(
      [lw, lw, h_guide],
      chamfer=chamfer_guide,
      except=[BOTTOM],
    );

    for (i = [0:a:360 - a]) {
      rotate(a=i)
        translate(v=[d / 2, 0, 0])
          rotate(a=-a_awl)
            awl_mask();
    }

    // inside windows
    for (a = [0:90:90]) {
      rotate(a=a)
        window_mask(l=d - s_awl * 2);
    }

    // outside windows
    for (a = [0:90:270]) {
      rotate(a=a)
        translate(v=[lw / 2, 0, 0])
          window_mask(l=s_awl / 2);
    }
  }
}

render() {

  if (show_awl_guide_circle)
    for (i = [0:1:len(d_circle_holes) - 1]) {
      translate(v=[100 * i, 100, 0])
        awl_guide_circle(d=d_circle_holes[i]);
    }

  if (show_awl_guide_straight)
    translate(v=[0, 0, 0])
      awl_guide_straight();
}
