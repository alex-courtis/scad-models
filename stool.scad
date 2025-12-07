include <BOSL2/std.scad>

$fn = 200;

d_gap = 0.0125;
l_gap = 0.0125;
w = 20;
d = 15;
l = w;
l1 = 10;
l2 = 10;
a1 = 8;
a2 = 8;
ratios = [0.5];
r_edge = 0.2;

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
function skewed_rect(x, y, d1, d2, a1, a2) =
  let (
    dx1 = y / 2 * tan(a1),
    dx2 = y / 2 * tan(a2),
    Mx = d1 / cos(a1),
    Nx = d1 / cos(a2),
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

module edge_cyl(a, dx, dz, r, h = 300) {
  rotate(a=-a, v=[0, 0, 1])
    translate(v=[dx, 0, dz])
      rotate(a=90, v=[1, 0, 0])
        cylinder(r=r, h=h, center=true);
}

// TODO: oblique end for corner bridles and rebates

// origin at cheek centre
module general(
  l = l, // shoulder to shoulder
  l1 = l1, // end to near mid shoulder
  l2 = l2, // end to near mid shoulder
  w = w,
  d = d,
  a1 = a1,
  a2 = a2,
  ratios = ratios, // cuts in d, ascending order
  l_gap = l_gap, // gap between shoulders, half of this is removed from each shoulder
  d_gap = d_gap, // gap between cheeks, half of this is removed from the cheek
  r_edge = r_edge, // radius of cylinder cut into edges of slot
  inner = false, // slot at bottom else cheek
) {

  slot = skewed_rect(
    y=w,
    d1=l / 2 + l_gap / 2,
    d2=l / 2 + l_gap / 2,
    a1=l1 ? a1 : 0,
    a2=l2 ? a2 : 0
  );

  body = [
    [-l1 - l / 2, -w / 2],
    [-l1 - l / 2, w / 2],
    [l2 + l / 2, w / 2],
    [l2 + l / 2, -w / 2],
  ];

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

        // material
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
          cyls = skewed_rect(
            y=w + 2 * r_edge,
            d1=l / 2 + l_gap / 2,
            d2=l / 2 + l_gap / 2,
            a1=l1 ? a1 : 0,
            a2=l2 ? a2 : 0
          );
          translate(v=[0, 0, dzs[i]]) {
            if (l1)
              extrude_from_to(pt1=cyls[0], pt2=cyls[1])
                circle(r=r_edge);
            if (l2)
              extrude_from_to(pt1=cyls[2], pt2=cyls[3])
                circle(r=r_edge);
          }
        }
      }
    }
  }
}

module halving(
  l = w, // shoulder to shoulder
  l1 = l1, // end to near mid shoulder
  l2 = l2, // end to near mid shoulder
  w = w,
  d = d,
  a1 = a1,
  a2 = a2,
  l_gap = l_gap, // gap between shoulders, half of this is removed from each shoulder
  d_gap = d_gap, // gap between cheeks, half of this is removed from the cheek
  r_edge = r_edge, // radius of cylinder cut into edges of slot
) {
  general(
    l=l,
    l1=l1,
    l2=l2,
    w=w,
    d=d,
    a1=a1,
    a2=a2,
    l_gap=l_gap,
    d_gap=d_gap,
    r_edge=r_edge
  );
}

// origin at tenon centre
module tenon(
  l = w, // width of the slot
  l1 = l1, // rail from mid shoulder edge, negative x
  l2 = l2, // rail from mid shoulder edge, positive x
  w = w,
  d = d,
  a = a1,
  ratio = 1 / 3,
  l_gap = l_gap, // gap between shoulder and slot, half of this is removed from each
  d_gap = d_gap, // gap between cheeks, half of this is removed from the cheek
  r_edge = r_edge, // radius of cylinder cut into edges of slot
) {

  general(
    l=l,
    l1=l1,
    l2=l2,
    w=w,
    d=d,
    a1=a1,
    a2=a2,
    ratios=[0.5 - ratio / 2, 0.5 + ratio / 2],
    l_gap=l_gap,
    d_gap=d_gap,
    r_edge=r_edge,
    inner=true,
  );
}

// origin at slot centre
module mortise(
  tenon = w, // width of the tenon
  l1 = l1, // style from mid slot edge, negative x
  l2 = l2, // style from mid slot edge, positive x
  w = w,
  d = d,
  a = a1,
  ratio = 1 / 3,
  l_gap = l_gap, // gap between shoulders, half of this is removed from each shoulder
  d_gap = d_gap, // gap between cheeks, half of this is removed from the cheek
  r_edge = r_edge, // radius of cylinder cut into edges of slot
) {
  general(
    l=l,
    l1=l1,
    l2=l2,
    w=w,
    d=d,
    a1=a1,
    a2=a2,
    ratios=[0.5 - ratio / 2, 0.5 + ratio / 2],
    l_gap=l_gap,
    d_gap=d_gap,
    r_edge=r_edge,
    inner=false,
  );
}

render() {
  bridles();

  translate(v=[0, 0, d * 4])
    halvings();
}

module halvings() {
  union() {
    color(c="peru")
      halving(
        a1=a1,
        a2=a2,
      );

    color(c="chocolate")
      translate(v=[l1 + l2 + w, 0, 0])
        halving(
          a1=0,
          a2=0,
        );

    color(c="saddlebrown")
      translate(v=[0, 0, d * 2])
        halving(
          a1=a1,
          a2=a2,
        );

    color(c="tan")
      translate(v=[l1 + l2 + w, 0, d * 2])
        halving(
          a1=0,
          a2=0,
        );
  }
}

module bridles() {
  union() {
    color(c="sienna") tenon(
      );

    color(c="rosybrown")
      translate(v=[l1 + l2 + w, 0, 0])
        tenon(
          l2=0
        );

    color(c="burlywood")
      translate(v=[0, 0, d * 2])
        mortise(
          a=-8,
        );

    color(c="wheat")
      translate(v=[l1 + l2 + w, 0, d * 2])
        mortise(
          l2=0,
        );
  }
}
