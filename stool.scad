include <BOSL2/std.scad>

/**
Joints centred at the origin, shoulders along the y axis, length along the x axis measured to the midpoints of the shoulders.

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

l is the sum of the (even) perpendiculars from AB to O and from CD to O.

a1 and a2 may be negative, with size less than 90.

When l1|l2 == 0, joint terminates at AB|CD, with no l_gap added.

Joint is cut at ratios from -z to +z, starting with waste when inner is set.

gap_cheek / 2 is added to z waste and should be applied to the other joint.

gap_shoulder is usually applied to shoulders AB CD, with half applied to inner shoulders.

r_edge is a sphere capped cylinder usually cut into all concave edges along xy and z.

d_pin may be cut through the joint at origin.
*/

$fn = 200;

w_def = 30;
d_def = 20;
l1_def = 40;
l2_def = 40;

a_def_tenon = 8;
a_def_mortise = -8;
a_def_dovetail = 30;
a_dov_def = 10;

ratios_def = [1 / 4, 3 / 5, 4 / 5];

gap_shoulder_halving_def = 0.025;
gap_cheek_halving_def = 0.1;

gap_shoulder_mortise_def = 0.1;
gap_cheek_mortise_def = 0.1;

gap_shoulder_tenon_def = 0.1;
gap_cheek_tenon_def = 0.1;

gap_shoulder_dove_def = 2;
gap_cheek_dove_def = 2;

r_edge_def = 0.20;

d_pin_def = 2.10;

debug = false;

/**
Render a generic joint centred at origin.
Entire body is z extruded and wasted out.
xy line segments capped with spheres specified by edge_lines_h are removed from each layer
z cylinders capped with spheres specified by edge_points_v are removed from waste and body layers
*/
module joint_render(
  d,
  body,
  waste,
  ratios,
  inner, // true for waste at bottom
  gap_cheek,
  r_edge,
  d_pin,
  edge_lines_h,
  edge_points_v_body,
  edge_points_v_waste,
) {

  // remove inner horizontal edges
  // cut out a cylinder and cap with spheres
  // accept that a small epsilon is needed to ensure the sphere intersects with the cylinder cleanly
  module edge_line(l) {
    #if (l[0] && l[1]) {
      extrude_from_to(pt1=l[0], pt2=l[1])
        circle(r=r_edge);
      translate(v=l[0])
        sphere(r=r_edge * 1.005);
      translate(v=l[1])
        sphere(r=r_edge * 1.005);
    }
  }

  // remove inner vertical edges
  // these will intersect with the spheres from the horizontals
  module edge_point(p, h) {
    #if(p) {
      translate(v=p)
        cylinder(r=r_edge, h=h);
      translate(v=p)
        sphere(r=r_edge);
      translate(v=[0, 0, h])
        translate(v=p)
          sphere(r=r_edge);
    }
  }

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
    for (i = [0:1:len(ratios) - 1]) -d / 2 + ratios[i] * d + (i % 2 == 0 ? im : -im) * gap_cheek / 2,
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

        if (r_edge && edge_lines_h && i > 0)
          for (l = edge_lines_h)
            edge_line(l=l);

        if (r_edge && edge_points_v_waste && wasting)
          for (p = edge_points_v_waste)
            edge_point(p=p, h=zs[i]);

        if (r_edge && edge_points_v_body && !wasting)
          for (p = edge_points_v_body)
            edge_point(p=p, h=zs[i]);
      }

    // centred pin
    if (d_pin) {
      cylinder(d=d_pin, h=d, center=true);
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

// print with cheek facing up
module halving(
  l = w_def,
  l1 = l1_def,
  l2 = l2_def,
  w = w_def,
  d = d_def,
  a = 0,
  ratio = 1 / 2,
  ratios = undef, // overrides ratio
  gap_shoulder = gap_shoulder_halving_def, // one to each shoulder
  gap_cheek = gap_cheek_halving_def, // half to each cheek
  r_edge = r_edge_def,
  d_pin = d_pin_def,
  inner = false,
) {

  // when not l1 or l2, body extends to the side of the joint, without gap_shoulder
  body = skewed_rect(
    y1=w / 2,
    y2=w / 2,
    d1=l1 ? (l / 2 + l1) : l / 2,
    d2=l2 ? (l / 2 + l2) : l / 2,
    a1=l1 ? 0 : a,
    a2=l2 ? 0 : a,
  );

  waste = skewed_rect(
    y1=w / 2,
    y2=w / 2,
    d1=l / 2 + gap_shoulder,
    d2=l / 2 + gap_shoulder,
    a1=a,
    a2=a,
  );

  edge_lines_h = [
    l1 ? [waste[0], waste[1]] : undef,
    l2 ? [waste[2], waste[3]] : undef,
  ];

  joint_render(
    d=d,
    body=body,
    waste=waste,
    ratios=ratios ? ratios : [ratio],
    gap_cheek=gap_cheek,
    r_edge=r_edge,
    d_pin=d_pin,
    inner=inner,
    edge_lines_h=edge_lines_h,
  );
}

// print with vertical cheeks
// set l2 for a tee bridle
// TODO allow l_tenon longer than w
module tenon(
  l = w_def, // depth of the slot
  l1 = l1_def,
  l2 = 0,
  w = w_def,
  d = d_def,
  a = a_def_tenon,
  l_tenon = undef, // length of the tenon, set to less than w for blind, overrides l2
  ratio = 1 / 3, // of the tenon, centred
  ratios = undef, // overrides ratio
  gap_shoulder = gap_shoulder_tenon_def, // one to each shoulder, half to blind end
  gap_cheek = gap_cheek_tenon_def, // half to each cheek
  r_edge = r_edge_def,
  d_pin = d_pin_def,
  inner = true,
) {
  blind = l_tenon && l_tenon < w;

  // when not l1 or l2, body extends to the side of the joint, without gap_shoulder
  d2 =
    blind ?
      l_tenon - l / 2 - gap_shoulder / 2
    : l2 ?
      (l / 2 + l2)
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
    d1=l / 2 + gap_shoulder,
    d2=l / 2 + gap_shoulder,
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
    ratios=ratios ? ratios : [(1 - ratio) / 2, (1 + ratio) / 2],
    gap_cheek=gap_cheek,
    r_edge=r_edge,
    d_pin=d_pin,
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
  ratios = undef, // overrides ratio
  gap_shoulder = gap_shoulder_mortise_def, // one to each shoulder, half to blind
  gap_cheek = gap_cheek_mortise_def, // half to each cheek
  r_edge = r_edge_def,
  d_pin = d_pin_def,
  inner = false,
) {
  blind = l_tenon && l_tenon < w;

  // when not l1 or l2, body extends to the side of the joint, without gap_shoulder
  body = skewed_rect(
    y1=w / 2,
    y2=w / 2,
    d1=l1 ? (l / 2 + l1) : l / 2,
    d2=l2 ? (l / 2 + l2) : l / 2,
    a1=l1 ? 0 : a,
    a2=l2 ? 0 : a,
  );

  // full gap_shoulder on shoulders, half on blind
  waste = skewed_rect(
    y1=w / 2,
    y2=blind ? l_tenon - w / 2 + gap_shoulder / 2 : w / 2,
    d1=l / 2 + gap_shoulder,
    d2=l / 2 + gap_shoulder,
    a1=a,
    a2=a,
  );

  edge_lines_h = [
    l1 ? [waste[0], waste[1]] : undef,
    l2 ? [waste[2], waste[3]] : undef,
    blind ? [waste[0], waste[3]] : undef,
  ];

  edge_points_v_waste = [
    (blind && l1) ? waste[0] : undef,
    (blind && l2) ? waste[3] : undef,
  ];

  joint_render(
    d=d,
    body=body,
    waste=waste,
    ratios=ratios ? ratios : [(1 - ratio) / 2, (1 + ratio) / 2],
    gap_cheek=gap_cheek,
    r_edge=r_edge,
    d_pin=d_pin,
    inner=inner,
    edge_lines_h=edge_lines_h,
    edge_points_v_waste=edge_points_v_waste,
  );
}

/**
|<-------l1-------->|
.                   .   
.                   .   
R---------------------------B                            ---------C   ^
|                   .      /                     -------/        /    |
|                   .     /              -------/               /     |
|                   .    /       -------/                      /      |
|                   .   S-------/                             /       |
|                   .  /                                     /        |
|                   . /                                     /         |
|                   ./                                     /          |
|                   -                  O                  /           w
|                  /                                     /            |
|                 /                                     /             |
|                /                                     /              |
|               T-----\                               /               |
|              /       ------\                       /                |
|           |a/               ------\               /                 |
|           |/                       ------\       /                  |
Q-----------A                               ------D                   -

a_dov is BCS and TDA
gap_shoulder AB, CD when blind 
*/
module dove_tail(
  l = w_def, // depth of the socket
  l1 = l1_def,
  w = w_def,
  d = d_def,
  a = a_def_dovetail,
  a_dov = a_dov_def,
  l_tail = undef, // length of the tail
  ratio = 1 / 2,
  gap_shoulder = gap_shoulder_dove_def, // one to each shoulder, half to blind end
  gap_cheek = gap_cheek_dove_def, // half to each cheek
  r_edge = r_edge_def,
  d_pin = d_pin_def,
  inner = true,
) {

  // TODO blind
  blind = l_tail && l_tail < w;

  QRBA = skewed_rect(
    y1=w / 2,
    y2=w / 2,
    d1=l / 2 + l1,
    d2=-l / 2 - gap_shoulder,
    a1=0,
    a2=a,
  );

  ABCD = skewed_rect(
    y1=w / 2,
    y2=w / 2,
    d1=l / 2 + gap_shoulder,
    d2=l / 2,
    a1=a,
    a2=a,
  );

  // A <-> D
  T = line_intersect(ABCD[0][0], ABCD[0][1], 90 - a, ABCD[3][0], ABCD[3][1], -a_dov);
  // B <-> C
  S = line_intersect(ABCD[1][0], ABCD[1][1], 90 - a, ABCD[2][0], ABCD[2][1], a_dov);

  // tail is cut out
  body = [
    QRBA[0],
    QRBA[1],
    QRBA[2],
    S,
    ABCD[2],
    ABCD[3],
    T,
    QRBA[3],
  ];

  waste = skewed_rect(
    y1=w / 2,
    y2=w / 2,
    d1=l / 2 + gap_shoulder,
    d2=l / 2 + gap_shoulder,
    a1=a,
    a2=a,
  );

  joint_render(
    d=d,
    body=body,
    waste=waste,
    [ratio],
    gap_cheek=gap_cheek,
    r_edge=r_edge,
    d_pin=d_pin,
    inner=inner,
    edge_lines_h=[[S, T]],
    edge_points_v_body=[S, T],
  );
}

render() {
  // stool();
  dove_test();
  // mt_test();
  // halving_test();
}

module dove_test() {
  dove_tail();
  // halving();
}

module halving_test() {
  a = 8;
  halving(
    a=a,
    l1=0,
  );
  rotate(a=90 - a)
    halving(
      a=-a,
      inner=true,
      l2=0,
    );
}

module mt_test() {
  w_tenon = 30;
  d_tenon = 20;
  l12_tenon = 25;

  w_leg = d_tenon;
  l_leg = w_tenon;
  l1_leg = 25;

  gap_shoulder = 0.5;
  gap_cheek = 0.5;
  r_edge = 0.5;

  a = 8;

  // tenon(
  //   l_tenon=25,
  //   l2=l2_def,
  //   // l1=0,
  // );
  //
  // // translate(v=[100, 0, 0])
  // rotate(a=90 + a_def_mortise)
  //   mortise(
  //     l_tenon=25,
  //     l1=0,
  //     // l2=0,
  //     l2=30,
  //     a=20,
  //     gap_shoulder=0,
  //   );

  color(c="sienna")
    tenon(a=-a, w=w_tenon, d=d_tenon, l=w_leg, l1=l12_tenon, l2=0, gap_shoulder=gap_shoulder, gap_cheek=gap_cheek, r_edge=r_edge);
  color(c="orange")
    rotate(a=90 + a)
      mortise(a=a, w=w_leg, d=d_tenon, l=l_leg, l1=l1_leg, l2=l1_leg, gap_shoulder=gap_shoulder, gap_cheek=gap_cheek, r_edge=r_edge);

  translate(v=[70, 0, 0]) {
    color(c="tan")
      tenon(a=-a, w=w_tenon, d=d_tenon, l=w_leg, l1=l12_tenon, l2=l12_tenon, gap_shoulder=gap_shoulder, gap_cheek=gap_cheek, r_edge=r_edge);
    color(c="chocolate")
      rotate(a=90 + a)
        mortise(a=a, w=w_leg, d=d_tenon, l=l_leg, l1=l1_leg, l2=0, gap_shoulder=gap_shoulder, gap_cheek=gap_cheek, r_edge=r_edge);
  }
}

module stool() {
  w_cross = 25;
  d_cross = 17;

  w_leg = 22;
  d_leg = d_cross;
  d1_leg_cap = 2;
  dx_leg_cap = w_cross - 5.5;

  a_tenon = 8;
  a_cross = 8;

  l12_halving = 5;
  l1_tenon = 8;
  l2_tenon = 5;
  l2_leg = 5;
  l1_mortise = 5;

  d_top = 125;
  h_top = 2.6;

  d_pin = d_pin_def;

  show_leg = true;
  show_top = false;
  show_half1 = true;
  show_half2 = true;
  show_half3 = true;
  show_half4 = true;
  one_leg = false;
  pins = true;

  dx = d_cross / 2 + l12_halving + w_leg / 2 + l1_tenon;

  module leg(a, blind, l1 = 0, ratio = 1 / 3, ratios = undef) {

    rotate(-90 - a) {
      mortise(a=-a, w=w_leg, d=d_cross, l=w_cross, l1=l1, l2=l2_leg, l_tenon=blind, ratio=ratio, ratios=ratios);

      translate(v=[dx_leg_cap, 0, 0]) {
        p = skewed_rect(y1=w_leg / 2, y2=w_leg / 2, d1=d1_leg_cap, d2=0, a1=0, a2=-a);
        linear_extrude(h=d_cross, center=true)
          polygon(p);
      }
    }
  }

  module half1() {

    // cross
    color(c="peru")
      rotate(a=-90, v=[1, 0, 0])
        halving(a=a_cross, d=w_cross, w=d_cross, l=d_cross, l1=l12_halving, l2=l12_halving, inner=false);

    // normal leg
    translate(v=[dx, 0, 0]) {
      color(c="chocolate")
        tenon(a=-a_tenon, w=w_cross, d=d_cross, l=w_leg, l1=l1_tenon, l2=0);

      if (show_leg)
        color(c="orange")
          translate(v=[0, 0, 0])
            leg(a=-a_tenon);
    }

    // tee leg
    translate(v=[-dx, 0, 0]) {
      color(c="saddlebrown")
        mirror(v=[1, 0, 0])
          tenon(a=-a_tenon, w=w_cross, d=d_cross, l=w_leg, l1=l1_tenon, l2=l2_tenon);

      if (show_leg)
        color(c="orange")
          translate(v=[0, 0, 0])
            leg(a=a_tenon);
    }
  }

  module half2() {

    // cross
    color(c="burlywood")
      rotate(a=90, v=[1, 0, 0])
        halving(a=a_cross, w=d_cross, d=w_cross, l=d_cross, l1=l12_halving, l2=l12_halving);

    // mortise leg
    translate(v=[dx, 0, 0]) {
      color(c="sienna")
        tenon(a=-a_tenon, w=w_cross, d=d_cross, l=w_leg, l1=l1_tenon, l2=0);

      if (show_leg)
        color(c="orange")
          leg(a=-a_tenon, l1=l1_mortise);
    }

    // blind leg
    translate(v=[-dx, 0, 0]) {
      color(c="rosybrown")
        mirror(v=[1, 0, 0])
          tenon(a=-a_tenon, w=w_cross, d=d_cross, l=w_leg, l1=l1_tenon, l2=0, l_tenon=w_leg * 0.75);

      if (show_leg)
        color(c="orange")
          translate(v=[0, 0, 0])
            leg(a=a_tenon, w_leg * 0.75);
    }
  }

  module half3() {

    // cross
    color(c="peru")
      rotate(a=-90, v=[1, 0, 0])
        halving(a=a_cross, d=w_cross, w=d_cross, l=d_cross, l1=l12_halving, l2=l12_halving, inner=false);

    // fat tenon leg
    translate(v=[dx, 0, 0]) {
      color(c="chocolate")
        tenon(a=-a_tenon, w=w_cross, d=d_cross, l=w_leg, l1=l1_tenon, l2=0, ratio=1 / 2);

      if (show_leg)
        color(c="orange")
          translate(v=[0, 0, 0])
            leg(a=-a_tenon, ratio=1 / 2);
    }

    // full blind leg
    translate(v=[-dx, 0, 0]) {
      color(c="saddlebrown")
        mirror(v=[1, 0, 0])
          tenon(a=-a_tenon, w=w_cross, d=d_cross, l=w_leg, l1=l1_tenon, l2=0, l_tenon=w_leg * 0.75);

      if (show_leg)
        color(c="orange")
          translate(v=[0, 0, 0])
            leg(a=a_tenon, w_leg * 0.75, l1=l1_mortise);
    }
  }

  module half4() {

    // cross
    color(c="burlywood")
      rotate(a=90, v=[1, 0, 0])
        halving(a=a_cross, w=d_cross, d=w_cross, l=d_cross, l1=l12_halving, l2=l12_halving);

    // double mortise leg
    translate(v=[dx, 0, 0]) {
      color(c="sienna")
        tenon(
          a=-a_tenon, w=w_cross, d=d_cross, l=w_leg, l1=l1_tenon, l2=0,
          ratios=[1 / 5, 2 / 5, 3 / 5, 4 / 5],
        );

      if (show_leg)
        color(c="orange")
          leg(
            a=-a_tenon, l1=l1_mortise,
            ratios=[1 / 5, 2 / 5, 3 / 5, 4 / 5],
          );
    }

    // double tenon leg
    translate(v=[-dx, 0, 0]) {
      color(c="rosybrown")
        mirror(v=[1, 0, 0])
          tenon(
            a=-a_tenon, w=w_cross, d=d_cross, l=w_leg, l1=l1_tenon, l2=0, l_tenon=w_leg * 1.75,
            ratios=[1 / 5, 2 / 5, 3 / 5, 4 / 5],
          );

      if (show_leg)
        color(c="orange")
          translate(v=[0, 0, 0])
            leg(
              a=a_tenon,
              ratios=[1 / 5, 2 / 5, 3 / 5, 4 / 5],
            );
    }
  }

  difference() {
    union() {

      // top
      if (show_top) {
        color(c="wheat")
          translate(v=[0, (w_cross + h_top) / 2 + gap_cheek_halving_def, 0])
            rotate(a=90, v=[1, 0, 0])
              cylinder(d=d_top, h=h_top, center=true);
      }
      if (show_half1)
        half1();

      if (show_half2)
        rotate(a=-90 - a_cross, v=[0, 1, 0])
          half2();

      if (show_half3)
        translate(v=[0, 70, 0])
          mirror(v=[0, 1, 0])
            half3();

      if (show_half4)
        translate(v=[0, 70, 0])
          mirror(v=[0, 1, 0])
            rotate(a=-90 - a_cross, v=[0, 1, 0])
              half4();
    }

    // pins
    if (pins) {
      x_pin = d_cross / 2 + l12_halving + l1_tenon + w_leg / 2;
      l_pin = 300;

      rotate(a=90, v=[1, 0, 0]) {
        translate(v=[x_pin, 0, 0])
          cylinder(d=d_pin, h=l_pin, center=true);

        translate(v=[-x_pin, 0, 0])
          cylinder(d=d_pin, h=l_pin, center=true);

        rotate(a=a_cross)
          translate(v=[0, x_pin, 0])
            cylinder(d=d_pin, h=l_pin, center=true);

        rotate(a=a_cross)
          translate(v=[0, -x_pin, 0])
            cylinder(d=d_pin, h=l_pin, center=true);
      }
    }
  }

  if (one_leg) {
    color(c="orange")
      leg(a=-a_tenon, blind=12);
  }
}
