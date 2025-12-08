include <BOSL2/std.scad>

$fn = 200;

w_def = 30;
d_def = 20;
l1_def = 40;
l2_def = 40;

a1_def = 10;
a2_def = -5;
a_def_tenon = 8;
a_def_mortise = -8;

ratios_def = [1 / 4, 3 / 5, 4 / 5];

l_gap_def = 0.025;
d_gap_def = 0.020;
r_edge_def = 0.2;

/*
Generic joint centred at the origin, shoulders along the y axis, length along the x axis measured to the midpoints of the shoulders.

Half gaps are applied to each cut and the same gaps should be applied to the other joints.

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

l is the sum of the (even) perpendiculars from AB to O and from CD to O. l_gap / 2 is added to each perpendicular.

a1 and a2 may be negative, with size less than 90.

When l1|l2 == 0, joint terminates at AB|CD, with no l_gap added.

Joint is cut at ratios from -z to +z, alternating cheeks and slots, starting with a slot when inner is set.

d_gap/2 is subtracted from each cheek and added to each slot.

r_edge is a cylinder cut into all cheek and slot edges.
*/
module joint(
  l = w_def, // x shoulder to shoulder
  l1 = l1_def, // -x end to near mid shoulder
  l2 = l2_def, // +x end to near mid shoulder
  w = w_def, // y
  d = d_def, // z
  a1 = a1_def, // -x
  a2 = a2_def, // +x
  ratios = ratios_def, // cuts in d, increasing z order
  l_gap = l_gap_def, // gap between shoulders, half of this is removed from each shoulder
  d_gap = d_gap_def, // gap between cheeks, half of this is removed from the cheek
  r_edge = r_edge_def, // radius of cylinder cut into edges of slot
  inner = false, // true for slot at bottom
) {
  assert(l > 0);
  assert(l1 >= 0);
  assert(l2 >= 0);
  assert(w > 0);
  assert(d > 0);
  assert(a1 < 90 && a1 > -90);
  assert(a2 < 90 && a2 > -90);
  assert(len(ratios) > 0);

  slot = skewed_rect(
    y=w,
    d1=(l + l_gap) / 2,
    d2=(l + l_gap) / 2,
    a1=a1,
    a2=a2,
  );

  // when not l1 or l2 body extends to the side of the joint, without l_gap
  body = skewed_rect(
    y=w,
    d1=l1 ? (l / 2 + l1) : l / 2,
    d2=l2 ? (l / 2 + l2) : l / 2,
    a1=l1 ? 0 : a1,
    a2=l2 ? 0 : a2,
  );

  edges = skewed_rect(
    y=w + 2 * r_edge,
    d1=l / 2 + l_gap / 2,
    d2=l / 2 + l_gap / 2,
    a1=a1,
    a2=a2,
  );

  // cheek /slot bottom from origin
  im = inner ? 1 : -1;
  dzs = [
    -d / 2,
    for (i = [0:1:len(ratios) - 1]) -d / 2 + ratios[i] * d + (i % 2 == 0 ? im : -im) * d_gap / 2,
    d / 2,
  ];

  // cheek / slot heights
  zs = [
    for (i = [0:1:len(dzs) - 2]) dzs[i + 1] - dzs[i],
  ];

  difference() {
    for (i = [0:1:len(zs) - 1]) {
      difference() {

        // all
        translate(v=[0, 0, dzs[i]])
          linear_extrude(h=zs[i], center=false)
            polygon(body);

        // maybe subtract slot
        if (inner && (i % 2 == 0) || !inner && (i % 2 == 1)) {
          translate(v=[0, 0, dzs[i]])
            linear_extrude(h=zs[i], center=false)
              polygon(slot);
        }
      }
    }

    // sharpen edges for printing
    // do this after the body to ensure manifold integrity
    if (r_edge) {
      for (i = [0:1:len(zs) - 1]) {
        if (i > 0) {
          translate(v=[0, 0, dzs[i]]) {
            if (l1)
              extrude_from_to(pt1=edges[0], pt2=edges[1])
                circle(r=r_edge);
            if (l2)
              extrude_from_to(pt1=edges[2], pt2=edges[3])
                circle(r=r_edge);
          }
        }
      }
    }
  }
}

/*
   Return poly ABCD
   d1 is perpendicular from AB to O
   d2 is perpendicular from CD to O
   undef when not a convex polygon
  
  
            B-----------------------C   ^
           /       |               /    |
          /        |              /     |
         /         |             /      |
        /          |            /       |
       M-----------O-----------N        y
      /            |          /         |
  |a1/             |      |a2/          |
  | /              |      | /           |
  |/               |      |/            |
  A-----------------------D             -
  
  */
function skewed_rect(y, d1, d2, a1, a2) =
  let (
    dx1 = y / 2 * tan(a1),
    dx2 = y / 2 * tan(a2),
    Mx = d1 / cos(a1),
    Nx = d2 / cos(a2),
    Ax = -Mx - dx1,
    Bx = -Mx + dx1,
    Cx = Nx + dx2,
    Dx = Nx - dx2,
  ) Bx < Cx && Ax < Dx ?
    [
      [Ax, -y / 2],
      [Bx, y / 2],
      [Cx, y / 2],
      [Dx, -y / 2],
    ]
  : undef;

// print with cheek facing up, default gaps are for 0.6
module halving(
  l = w_def,
  l1 = l1_def,
  l2 = l2_def,
  w = w_def,
  d = d_def,
  a1 = 0,
  a2 = 0,
  l_gap = 0.005,
  d_gap = 0.025,
  r_edge = 0.015,
  inner = false,
) {
  joint(
    l=l, l1=l1, l2=l2, w=w, d=d, a1=a1, a2=a2,
    ratios=[1 / 2],
    l_gap=l_gap, d_gap=d_gap, r_edge=r_edge,
    inner=inner,
  );
}

// print with vertical cheeks, default gaps are for 0.6
// set l2 for a tee bridle
module tenon(
  l = w_def, // width of the slot
  l1 = l1_def,
  l2 = 0,
  w = w_def,
  d = d_def,
  a1 = a_def_tenon,
  a2 = a_def_tenon,
  ratio = 1 / 3, // of the tenon, centred
  l_gap = 0.100,
  d_gap = 0.020,
  r_edge = 0.3,
) {

  joint(
    l=l, l1=l1, l2=l2, w=w, d=d, a1=a1, a2=a2,
    ratios=[(1 - ratio) / 2, (1 + ratio) / 2],
    l_gap=l_gap, d_gap=d_gap, r_edge=r_edge,
    inner=true,
  );
}

// print with vertical slot, default gaps are for 0.6
// remove l1 or l2 for a corner bridle
module mortise(
  l = w_def, // width of the tenon
  l1 = l1_def,
  l2 = l2_def,
  w = w_def,
  d = d_def,
  a1 = a_def_mortise,
  a2 = a_def_mortise,
  ratio = 1 / 3, // of the slot, centred
  l_gap = 0.100,
  d_gap = 0.020,
  r_edge = 0.3,
) {
  joint(
    l=l, l1=l1, l2=l2, w=w, d=d, a1=a1, a2=a2,
    ratios=[(1 - ratio) / 2, (1 + ratio) / 2],
    l_gap=l_gap, d_gap=d_gap, r_edge=r_edge,
    inner=false,
  );
}

render() {
  stool();
  // mt_test();
}

module mt_test() {
  w_tenon = 30;
  d_tenon = 20;
  l12_tenon = 25;

  w_leg = d_tenon;
  l_leg = w_tenon;
  l1_leg = 25;

  a = 8;

  color(c="sienna")
    tenon(a1=-a, a2=-a, w=w_tenon, d=d_tenon, l=w_leg, l1=l12_tenon, l2=0);
  color(c="orange")
    rotate(a=90 + a)
      mortise(a1=a, a2=a, w=w_leg, d=d_tenon, l=l_leg, l1=l1_leg, l2=l1_leg);

  translate(v=[70, 0, 0]) {
    color(c="sienna")
      tenon(a1=-a, a2=-a, w=w_tenon, d=d_tenon, l=w_leg, l1=l12_tenon, l2=l12_tenon);
    color(c="orange")
      rotate(a=90 + a)
        mortise(a1=a, a2=a, w=w_leg, d=d_tenon, l=l_leg, l1=l1_leg, l2=0);
  }
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

  module leg(a) {
    l1_leg = 20;
    l = 120;

    rotate(90 + a) {
      mortise(a1=a, a2=a, w=w_leg, d=d_cross, l=l_leg, l1=l1_leg, l2=0);

      translate(v=[-l_leg / 2 - l1_leg, 0, 0]) {
        p = skewed_rect(y=w_leg, d1=l - l1_leg, d2=0, a1=a, a2=0);
        linear_extrude(h=d_cross, center=true)
          polygon(p);
      }
    }
  }

  color(c="wheat")
    translate(v=[0, (w_cross + h_top) / 2 + d_gap_def, 0])
      rotate(a=90, v=[1, 0, 0])
        cylinder(d=d_top, h=h_top, center=true);

  rotate(a=-90, v=[0, 1, 0]) {

    color(c="peru")
      rotate(a=-90, v=[1, 0, 0])
        halving(d=w_cross, w=d_cross, l=d_cross, l1=l12_halving, l2=l12_halving, inner=false);

    translate(v=[d_cross / 2 + l12_halving + l12_tenon + w_leg * 0.75, 0, 0]) {
      color(c="chocolate")
        tenon(a1=-a_tenon, a2=a_tenon, w=w_cross, d=d_cross, l=w_leg * 1.5, l1=l12_tenon, l2=0);

      color(c="orange")
        translate(v=[-d_leg * 0.25, 0, 0])
          leg(a=a_tenon);
    }

    translate(v=[-d_cross / 2 - l12_halving - l12_tenon - w_leg * 0.75, 0, 0]) {
      color(c="saddlebrown")
        tenon(a1=0, a2=a_tenon, w=w_cross, d=d_cross, l=w_leg * 1.5, l1=0, l2=l12_tenon);

      color(c="orange")
        translate(v=[d_leg * 0.25, 0, 0])
          leg(a=-a_tenon);
    }
  }

  color(c="burlywood")
    rotate(a=90, v=[1, 0, 0])
      halving(w=d_cross, d=w_cross, l=d_cross, l1=l12_halving, l2=l12_halving);

  translate(v=[d_cross / 2 + l12_halving + l12_tenon + w_leg / 2, 0, 0]) {
    color(c="sienna")
      tenon(a1=-a_tenon, a2=-a_tenon, w=w_cross, d=d_cross, l=w_leg, l1=l12_tenon, l2=0);

    color(c="orange")
      leg(a=a_tenon);
  }

  translate(v=[-d_cross / 2 - l12_halving - l12_tenon - w_leg * 0.75, 0, 0]) {
    color(c="rosybrown")
      tenon(a1=a_tenon, a2=a_tenon, w=w_cross, d=d_cross, l=w_leg * 1.5, l1=0, l2=l12_tenon);

    color(c="orange")
      translate(v=[d_leg * 0.25, 0, 0])
        leg(a=-a_tenon);
  }
}
