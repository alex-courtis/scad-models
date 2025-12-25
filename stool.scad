include <BOSL2/std.scad>

$fn = 200;

w_def = 30;
d_def = 20;
l1_def = 40;
l2_def = 40;

a1_def = 10;
a2_def = -6;
a3_def = 4;
a4_def = -3;

a_def_tenon = 8;
a_def_mortise = -8;
a_def_dovetail = 10;

ratios_def = [1 / 4, 3 / 5, 4 / 5];

// l_gap_def = 0.025;
// d_gap_def = 0.020;
// r_edge_def = 0.2;

// TODO rename this lw_gap
l_gap_def = 1;
d_gap_def = 1;
r_edge_def = 1.5;

debug = false;

/**
Generic joint centred at the origin, shoulders along the y axis, length along the x axis measured to the midpoints of the shoulders.

|<------l1-------->|                       |<------l2-------->|
.                  .                       .                  .
.                  .                       .                  .
------------------------B-----------------------C--------------     ^
|                  .   /                   .   /              |     |
|                  .  /        y           .  /               |     |
|                  . /         ^           . /                |     |
|                  ./          |           ./                 |     |
|                  -           O-->x       -                  |     w
|                 /                       /                   |     |
|             |a1/                    |a2/                    |     |
|             | /                     | /                     |     |
|             |/                      |/                      |     |
--------------A-----------------------D------------------------     -

l is the sum of the (even) perpendiculars from AB to O and from CD to O. l_gap is added to each perpendicular.

a1 and a2 may be negative, with size less than 90.

When l1|l2 == 0, joint terminates at AB|CD, with no l_gap added.

Joint is cut at ratios from -z to +z, starting with waste when inner is set.

d_gap/2 is added to waste and should be applied to the other joint.

r_edge is a cylinder cut into all inner edges.
*/
module joint(
  l = w_def, // x shoulder to shoulder
  l1 = l1_def, // -x end to near mid shoulder
  l2 = l2_def, // +x end to near mid shoulder
  w = w_def, // y
  d = d_def, // z
  a1 = a1_def, // -x
  a2 = a2_def, // +x
  a3 = a3_def, // +y
  a4 = a4_def, // -y
  ratios = ratios_def, // cuts in d, increasing z order
  l_gap = l_gap_def, // removed from each shoulder
  d_gap = d_gap_def, // half added to bottom of waste
  r_edge = r_edge_def, // radius of cylinder cut into waste edges
  inner = false, // true for waste at bottom
) {
  assert(l > 0);
  assert(l1 >= 0);
  assert(l2 >= 0);
  assert(w > 0);
  assert(d > 0);
  assert(a1 < 90 && a1 > -90);
  assert(a2 < 90 && a2 > -90);
  assert(a3 < 90 && a3 > -90);
  assert(a4 < 90 && a4 > -90);
  assert(len(ratios) > 0);

  abcd = skewed_rect(
    y=w,
    d1=l / 2 + l_gap,
    d2=l / 2 + l_gap,
    a1=a1,
    a2=a2,
  );

  Ax = abcd[0][0];
  Ay = abcd[0][1];
  Bx = abcd[1][0];
  By = abcd[1][1];
  Cx = abcd[2][0];
  Cy = abcd[2][1];
  Dx = abcd[3][0];
  Dy = abcd[3][1];

  // when not l1 or l2, body extends to the side of the joint, without l_gap
  body = skewed_rect(
    y=w,
    d1=l1 ? (l / 2 + l1) : l / 2,
    d2=l2 ? (l / 2 + l2) : l / 2,
    a1=l1 ? 0 : a1,
    a2=l2 ? 0 : a2,
  );

  waste_top =
    !a3 ? undef
    : [
      [Bx, By],
      a3 > 0 ?
        line_intersect(Bx, By, -90 - a1, Cx, Cy, a3)
      : line_intersect(Bx, By, a3, Cx, Cy, -90 - a2),
      [Cx, Cy],
    ];

  waste_bottom =
    !a4 ? undef
    : [
      [Ax, Ay],
      a4 > 0 ?
        line_intersect(Ax, Ay, a4, Dx, Dy, 90 - a2)
      : line_intersect(Ax, Ay, -90 - a1, Dx, Dy, a4),
      [Dx, Dy],
    ];

  waste = [
    a4 < 0 ? waste_bottom[1] : abcd[0],
    a3 > 0 ? waste_top[1] : abcd[1],
    a3 < 0 ? waste_top[1] : abcd[2],
    a4 > 0 ? waste_bottom[1] : abcd[3],
  ];

  if (debug) {
    color(c="red")
      translate(v=[0, 0, d - 2])
        linear_extrude(h=1)
          polygon(abcd);

    color(c="orange")
      translate(v=[0, 0, d])
        linear_extrude(h=1)
          polygon(waste);

    color(c="green") if (waste_top)
      translate(v=[0, 0, d + 2])
        linear_extrude(h=1)
          polygon(waste_top);

    color(c="blue") if (waste_bottom)
      translate(v=[0, 0, d + 2])
        linear_extrude(h=1)
          polygon(waste_bottom);
  }

  joint_render(
    d=d,
    body=body,
    waste=waste,
    waste_top=waste_top,
    waste_bottom=waste_bottom,
    ratios=ratios,
    d_gap=d_gap,
    r_edge=r_edge,
    inner=inner,
  );
}

module joint_render(
  d,
  body,
  waste,
  ratios,
  inner, // true for waste at bottom
  d_gap,
  r_edge,
  edge_lines_h, // horizontal line segments to remove r_edge
  edge_points_v, // vertical points to remove r_edge
) {

  if (debug) {
    color(c="red")
      linear_extrude(h=1, center=true)
        polygon(waste);

    color(c="red")
      translate(v=[0, 0, d / 2])
        linear_extrude(h=1, center=true)
          polygon(waste);
  }

  // material/waste bottom up from origin
  im = inner ? 1 : -1;
  dzs = [
    -d / 2,
    for (i = [0:1:len(ratios) - 1]) -d / 2 + ratios[i] * d + (i % 2 == 0 ? im : -im) * d_gap / 2,
    d / 2,
  ];

  // material/waste heights
  zs = [
    for (i = [0:1:len(dzs) - 2]) dzs[i + 1] - dzs[i],
  ];

  difference() {

    // entire body
    translate(v=[0, 0, -d / 2])
      linear_extrude(h=d, center=false)
        polygon(body);

    for (i = [0:1:len(zs) - 1])
      translate(v=[0, 0, dzs[i]]) {

        wasting = inner && (i % 2 == 0) || !inner && (i % 2 == 1);

        // remove joint waste
        if (wasting)
          linear_extrude(h=zs[i], center=false)
            polygon(waste);

        // remove inner horizontal edges
        // cut out a cylinder and cap with spheres
        if (r_edge && edge_lines_h && i > 0)
          for (l = edge_lines_h)
            if (l[0] && l[1]) {
              extrude_from_to(pt1=l[0], pt2=l[1])
                circle(r=r_edge);
              translate(v=l[0])
                sphere(r=r_edge);
              translate(v=l[1])
                sphere(r=r_edge);
            }

        // remove inner vertical edges
        // these will intersect with the spheres from the horizontals
        if (r_edge && edge_points_v && wasting)
          for (p = edge_points_v)
            if (p) {
              translate(v=p)
                cylinder(r=r_edge, h=zs[i]);
              translate(v=p)
                sphere(r=r_edge);
              translate(v=[0, 0, zs[i]])
                translate(v=p)
                  sphere(r=r_edge);
            }
      }
  }
}

/**
   Return poly ABCD
   d1 is perpendicular from AB to O
   d2 is perpendicular from CD to O
   undef when not a convex polygon
  
  
            B-----------------------C   ^
           /       |               /    |
          /        |              /     |
         /         |             /      y1
        /          |            /       |
       M-----------O-----------N       ---
      /            |          /         |
  |a1/             |      |a2/          y2
  | /              |      | /           |
  |/               |      |/            |
  A-----------------------D             -
*/
function skewed_rect(y1, y2, d1, d2, a1, a2) =
  assert(is_num(y1))
  assert(is_num(y2))
  assert(is_num(d1))
  assert(is_num(d2))

  assert(is_num(a1))
  assert(a1 < 90 && a1 > -90)

  assert(is_num(a2))
  assert(a2 < 90 && a2 > -90)

  let (
    dxA = y2 * tan(a1),
    dxB = y1 * tan(a1),
    dxC = y1 * tan(a2),
    dxD = y2 * tan(a2),
    Mx = d1 / cos(a1),
    Nx = d2 / cos(a2),
    Ax = -Mx - dxA,
    Bx = -Mx + dxB,
    Cx = Nx + dxC,
    Dx = Nx - dxD,
  ) Bx < Cx && Ax < Dx ?
    [
      [Ax, -y2],
      [Bx, y1],
      [Cx, y1],
      [Dx, -y2],
    ]
  : undef;

/**
Intersection point of two lines specified by point and angle
*/
function line_intersect(x1, y1, a1, x2, y2, a2) =
  assert(is_num(a1))
  assert(is_num(a2))
  assert(a1 != a2)

  let (
    // y = ax + b
    v1 = (a1 % 90 == 0),
    a = v1 ? undef : tan(a1),
    c = v1 ? undef : y1 - x1 * a,

    // y = bx + d
    v2 = (a2 % 90 == 0),
    b = tan(a2),
    d = y2 - x2 * b,

    // x = (d - c) / (a - b)
    x = v1 ?
      x1
    : v2 ?
      x2
    : (d - c) / (a - b),

    // y = a * x + c
    y = v1 ?
      (b * x + d)
    : (a * x + c),
  ) [
      x,
      y,
  ];

// print with cheek facing up, default gaps are for 0.6
module halving(
  l = w_def,
  l1 = l1_def,
  l2 = l2_def,
  w = w_def,
  d = d_def,
  a1 = 0,
  a2 = 0,
  a3 = 0,
  a4 = 0,
  l_gap = 0.002,
  d_gap = 0.045,
  r_edge = 0.010,
  inner = false,
) {
  joint(
    l=l, l1=l1, l2=l2, w=w, d=d, a1=a1, a2=a2, a3=a3, a4=a4,
    ratios=[1 / 2],
    l_gap=l_gap, d_gap=d_gap, r_edge=r_edge,
    inner=inner,
  );
}

// print with vertical cheeks
// set l2 for a tee bridle
module tenon(
  l = w_def, // depth of the slot
  l1 = l1_def,
  l2 = 0,
  w = w_def,
  d = d_def,
  a = a_def_tenon,
  l_tenon = undef, // length of the tenon, set to less than w for blind, overrides l2
  ratio = 1 / 3, // of the tenon, centred
  l_gap = l_gap_def, // one to each shoulder, half to blind end
  d_gap = d_gap_def,
  r_edge = r_edge_def,
  inner = true,
) {
  blind = l_tenon && l_tenon < w;

  // when not l1 or l2, body extends to the side of the joint, without l_gap
  d2 =
    blind ?
      l_tenon - l / 2 - l_gap / 2
    : l2 ?
      (l / 2 + l1)
    : l / 2;
  body = skewed_rect(
    y1=w / 2,
    y2=w / 2,
    d1=l1 ? (l / 2 + l1) : l / 2,
    d2=d2,
    a1=l1 ? 0 : a,
    a2=(blind || !l2) ? a : 0,
  );

  waste = skewed_rect(
    y1=w / 2,
    y2=w / 2,
    d1=l / 2 + l_gap,
    d2=l / 2 + l_gap,
    a1=a,
    a2=a,
  );

  edge_lines_h = [
    [waste[0], waste[1]],
    l2 ? [waste[2], waste[3]] : undef,
  ];

  joint_render(
    d=d,
    body=body,
    waste=waste,
    ratios=[(1 - ratio) / 2, (1 + ratio) / 2],
    d_gap=d_gap,
    r_edge=r_edge,
    inner=inner,
    edge_lines_h=edge_lines_h,
  );
}

// print with vertical slot
// remove l1 or l2 for a corner bridle
module mortise(
  l = w_def, // width of the tenon
  l1 = l1_def,
  l2 = l2_def,
  w = w_def,
  d = d_def,
  a = a_def_mortise,
  l_tenon = undef, // length of the tenon, set to less than w for blind
  ratio = 1 / 3, // of the slot, centred
  l_gap = l_gap_def, // one to each shoulder, half to blind
  d_gap = d_gap_def,
  r_edge = r_edge_def,
  inner = false,
) {
  blind = l_tenon && l_tenon < w;

  // when not l1 or l2, body extends to the side of the joint, without l_gap
  body = skewed_rect(
    y1=w / 2,
    y2=w / 2,
    d1=l1 ? (l / 2 + l1) : l / 2,
    d2=l2 ? (l / 2 + l2) : l / 2,
    a1=l1 ? 0 : a,
    a2=l2 ? 0 : a,
  );

  // full l_gap on shoulders, half on blind
  waste = skewed_rect(
    y1=w / 2,
    y2=blind ? l_tenon - w / 2 + l_gap / 2 : w / 2,
    d1=l / 2 + l_gap,
    d2=l / 2 + l_gap,
    a1=a,
    a2=a,
  );

  edge_lines_h = [
    l1 ? [waste[0], waste[1]] : undef,
    l2 ? [waste[2], waste[3]] : undef,
    blind ? [waste[0], waste[3]] : undef,
  ];

  edge_points_v = [
    blind ? waste[0] : undef,
    blind ? waste[3] : undef,
  ];

  joint_render(
    d=d,
    body=body,
    waste=waste,
    ratios=[(1 - ratio) / 2, (1 + ratio) / 2],
    d_gap=d_gap,
    r_edge=r_edge,
    inner=inner,
    edge_lines_h=edge_lines_h,
    edge_points_v=edge_points_v,
  );
}

module dovetail_tail(
  l = w_def,
  l1 = l1_def,
  l2 = 0,
  w = w_def,
  d = d_def,
  a1 = 0,
  a2 = 0,
  a3 = a_def_dovetail,
  a4 = -a_def_dovetail,
  ratio = 1 / 2,
  l_gap = 0.030,
  d_gap = 0.040,
  r_edge = 0.30,
  inner = true,
) {
  joint(
    l=l, l1=l1, l2=l2, w=w, d=d, a1=a1, a2=a2, a3=a3, a4=a4,
    ratios=[ratio],
    l_gap=l_gap, d_gap=d_gap, r_edge=r_edge,
    inner=inner,
  );
}

module dovetail_socket(
  l = w_def,
  l1 = l1_def,
  l2 = l2_def,
  w = w_def,
  d = d_def,
  a1 = a_def_dovetail,
  a2 = -a_def_dovetail,
  a3 = 0,
  a4 = 0,
  ratio = 1 / 2,
  l_gap = 0.030,
  d_gap = 0.040,
  r_edge = 0.30,
  inner = false,
) {
  joint(
    l=l, l1=l1, l2=l2, w=w, d=d, a1=a1, a2=a2, a3=a3, a4=a4,
    ratios=[ratio],
    l_gap=l_gap, d_gap=d_gap, r_edge=r_edge,
    inner=inner,
  );
}

render() {
  // stool();
  mt_test();
  // dov_test();
}

module dov_test() {
  l_gap = 0.5;
  d_gap = 0.5;
  r_edge = 0.5;

  union() {
    color(c="tan")
      dovetail_socket(
        l_gap=l_gap,
        d_gap=d_gap,
        r_edge=r_edge,
        l1=20,
        l2=20,
      );

    rotate(a=-90)
      color(c="chocolate")
        dovetail_tail(
          l_gap=l_gap,
          d_gap=d_gap,
          r_edge=r_edge,
          l1=30,
          w=w_def + 5.725,
        );
  }
}

module mt_test() {
  w_tenon = 30;
  d_tenon = 20;
  l12_tenon = 25;

  w_leg = d_tenon;
  l_leg = w_tenon;
  l1_leg = 25;

  l_gap = 0.5;
  d_gap = 0.5;
  r_edge = 0.5;

  a = 8;

  tenon(
    l_tenon=25,
    l2=l2_def,
    // l1=0,
  );

  // translate(v=[100, 0, 0])
  rotate(a=90 + a_def_mortise)
    mortise(
      l_tenon=25,
      // l1=0,
      // l2=0,
      // // l2=30,
      // a=20,
      // l_gap=0,
    );

  // color(c="sienna")
  //   tenon(a=-a, w=w_tenon, d=d_tenon, l=w_leg, l1=l12_tenon, l2=0, l_gap=1, d_gap=1, r_edge=r_edge);
  // color(c="orange")
  //   rotate(a=90 + a)
  //     mortise(a=a, w=w_leg, d=d_tenon, l=l_leg, l1=l1_leg, l2=l1_leg, l_gap=1, d_gap=1, r_edge=r_edge);
  //
  // translate(v=[70, 0, 0]) {
  //   color(c="tan")
  //     tenon(a=-a, w=w_tenon, d=d_tenon, l=w_leg, l1=l12_tenon, l2=l12_tenon, l_gap=1, d_gap=1, r_edge=r_edge);
  //   color(c="chocolate")
  //     rotate(a=90 + a)
  //       mortise(a=a, w=w_leg, d=d_tenon, l=l_leg, l1=l1_leg, l2=0, l_gap=1, d_gap=1, r_edge=r_edge);
  // }
}

module stool() {
  w_cross = 25;
  d_cross = 17;

  w_leg = d_cross;
  d_leg = d_cross;
  l_leg = w_cross;

  a_tenon = 8;

  l12_halving = 10;
  l12_tenon = 15;

  d_top = 125;
  h_top = 1.2;

  d_pin = 1.85;
  x_pin = d_top * 0.32;
  l_pin = h_top + w_cross + d_gap_def;

  show_leg = true;
  show_top = true;
  show_half1 = true;
  show_half2 = true;
  one_leg = false;

  module leg(a) {
    l1_leg = 20;
    l = 120;

    rotate(90 + a) {
      mortise(a=a, w=w_leg, d=d_cross, l=l_leg, l1=l1_leg, l2=0);

      translate(v=[-l_leg / 2 - l1_leg, 0, 0]) {
        p = skewed_rect(y=w_leg, d1=l - l1_leg, d2=0, a1=a, a2=0);
        linear_extrude(h=d_cross, center=true)
          polygon(p);
      }
    }
  }

  module half1() {
    // cross
    color(c="peru")
      rotate(a=-90, v=[1, 0, 0])
        halving(d=w_cross, w=d_cross, l=d_cross, l1=l12_halving, l2=l12_halving, inner=false);

    // oblique leg
    translate(v=[d_cross / 2 + l12_halving + l12_tenon + w_leg * 0.75, 0, 0]) {
      color(c="chocolate")
        tenon(a=-a_tenon, w=w_cross, d=d_cross, l=w_leg * 1.5, l1=l12_tenon, l2=0);

      if (show_leg)
        color(c="orange")
          translate(v=[-d_leg * 0.25, 0, 0])
            leg(a=a_tenon);
    }

    // straight leg
    translate(v=[-d_cross / 2 - l12_halving - l12_tenon - w_leg * 0.75, 0, 0]) {
      color(c="saddlebrown")
        tenon(a=a_tenon, w=w_cross, d=d_cross, l=w_leg * 1.5, l1=0, l2=l12_tenon);

      if (show_leg)
        color(c="orange")
          translate(v=[d_leg * 0.25, 0, 0])
            leg(a=-a_tenon);
    }
  }

  module half2() {
    // cross
    color(c="burlywood")
      rotate(a=90, v=[1, 0, 0])
        halving(w=d_cross, d=w_cross, l=d_cross, l1=l12_halving, l2=l12_halving);

    // flush leg
    translate(v=[d_cross / 2 + l12_halving + l12_tenon + w_leg / 2, 0, 0]) {
      color(c="sienna")
        tenon(a=-a_tenon, w=w_cross, d=d_cross, l=w_leg, l1=l12_tenon, l2=0);

      if (show_leg)
        color(c="orange")
          leg(a=a_tenon);
    }

    // parallel leg
    translate(v=[-d_cross / 2 - l12_halving - l12_tenon - w_leg * 0.75, 0, 0]) {
      color(c="rosybrown")
        tenon(a=a_tenon, w=w_cross, d=d_cross, l=w_leg * 1.5, l1=0, l2=l12_tenon);

      if (show_leg)
        color(c="orange")
          translate(v=[d_leg * 0.25, 0, 0])
            leg(a=-a_tenon);
    }
  }

  difference() {
    union() {

      // top
      if (show_top) {
        color(c="wheat")
          translate(v=[0, (w_cross + h_top) / 2 + d_gap_def, 0])
            rotate(a=90, v=[1, 0, 0])
              cylinder(d=d_top, h=h_top, center=true);
      }
      if (show_half1)
        half1();

      if (show_half2)
        rotate(a=-90, v=[0, 1, 0])
          half2();
    }

    // pins
    translate(v=[0, w_cross / 2 + h_top + d_gap_def, 0])
      rotate(a=90, v=[1, 0, 0]) {
        translate(v=[x_pin, 0, 0])
          cylinder(d=d_pin, h=l_pin, center=false);

        translate(v=[-x_pin, 0, 0])
          cylinder(d=d_pin, h=l_pin, center=false);

        translate(v=[0, x_pin, 0])
          cylinder(d=d_pin, h=l_pin, center=false);

        translate(v=[0, -x_pin, 0])
          cylinder(d=d_pin, h=l_pin, center=false);
      }
  }

  if (one_leg) {
    color(c="orange")
      leg(a=-a_tenon);
  }
}
