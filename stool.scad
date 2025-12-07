include <BOSL2/std.scad>

$fn = 200;

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

// origin at joint centre
module general(
  l = l, // x shoulder to shoulder
  l1 = l1, // -x end to near mid shoulder
  l2 = l2, // +x end to near mid shoulder
  w = w, // y
  d = d, // z
  a1 = a1, // -x
  a2 = a2, // +x
  ratios = [1 / 4, 1 / 2, 3 / 4], // cuts in d, increasing z order
  l_gap = l_gap, // gap between shoulders, half of this is removed from each shoulder
  d_gap = d_gap, // gap between cheeks, half of this is removed from the cheek
  r_edge = r_edge, // radius of cylinder cut into edges of slot
  inner = false, // true for slot at bottom
) {

  slot = skewed_rect(
    y=w,
    d1=(l + l_gap) / 2,
    d2=(l + l_gap) / 2,
    a1=a1,
    a2=a2,
  );

  edges = skewed_rect(
    y=w + 2 * r_edge,
    d1=l / 2 + l_gap / 2,
    d2=l / 2 + l_gap / 2,
    a1=a1,
    a2=a2,
  );

  // TODO don't extend gap beyond ends when l1 or l2 zero
  body = [
    l1 ? [-l1 - l / 2, -w / 2] : slot[0], //A
    l1 ? [-l1 - l / 2, w / 2] : slot[1], // B
    l2 ? [l2 + l / 2, w / 2] : slot[2], // C
    l2 ? [l2 + l / 2, -w / 2] : slot[3], // D
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

// print with cheek facing up, gaps for 0.6
module halving(
  l = l,
  l1 = l1,
  l2 = l2,
  w = w,
  d = d,
  a1 = 0,
  a2 = 0,
  l_gap = 0.01,
  d_gap = 0.025,
  r_edge = 0.015,
  inner = false,
) {
  general(
    l=l, l1=l1, l2=l2, w=w, d=d, a1=a1, a2=a2,
    ratios=[1 / 2],
    l_gap=l_gap, d_gap=d_gap, r_edge=r_edge,
    inner=inner,
  );
}

// print with vertical cheeks, gaps for 0.6
module tenon(
  l = l, // width of the slot
  l1 = l1,
  l2 = l2,
  w = w,
  d = d,
  a1 = a1,
  a2 = a2,
  ratio = 1 / 3, // of the tenon
  l_gap = 0.0250,
  d_gap = 0.015,
  r_edge = 0.2,
) {

  general(
    l=l, l1=l1, l2=l2, w=w, d=d, a1=a1, a2=a2,
    ratios=[(1 - ratio) / 2, (1 + ratio) / 2],
    l_gap=l_gap, d_gap=d_gap, r_edge=r_edge,
    inner=true,
  );
}

// print with vertical slot, gaps for 0.6
module mortise(
  l = l, // width of the tenon
  l1 = l1,
  l2 = l2,
  w = w,
  d = d,
  a1 = a1,
  a2 = a2,
  ratio = 1 / 3, // of the slot
  l_gap = 0.0250,
  d_gap = 0.015,
  r_edge = 0.2,
) {
  general(
    l=l, l1=l1, l2=l2, w=w, d=d, a1=a1, a2=a2,
    ratios=[(1 - ratio) / 2, (1 + ratio) / 2],
    l_gap=l_gap, d_gap=d_gap, r_edge=r_edge,
    inner=false,
  );
}

render() {
  stool();
}

module stool() {
  w = 20;
  l = w;
  d = 30;
  d_leg = 20;

  translate(v=[0, 50, 0]) {

    color(c="peru")
      halving(a1=0, a2=0, w=w, d=d, l=l, l1=10, l2=10);

    color(c="chocolate")
      translate(v=[75, 0, 0])
        rotate(a=-90, v=[1, 0, 0])
          tenon(a1=8, a2=-8, w=d, d=w, l=d_leg * 2, l1=35, l2=0);

    color(c="saddlebrown")
      translate(v=[-75, 0, 0])
        rotate(a=90, v=[1, 0, 0])
          tenon(a1=0, a2=8, w=d, d=w, l=d_leg * 2, l1=0, l2=35);
  }

  {
    color(c="burlywood")
      halving(a1=0, a2=0, w=w, d=d, l=l, l1=10, l2=10, inner=true);

    color(c="sienna")
      translate(v=[65, 0, 0])
        rotate(a=-90, v=[1, 0, 0])
          tenon(a1=8, a2=8, w=d, d=w, l=d_leg, l1=35, l2=0);

    color(c="rosybrown")
      translate(v=[-75, 0, 0])
        rotate(a=90, v=[1, 0, 0])
          tenon(a1=8, a2=8, w=d, d=w, l=d_leg * 2, l1=0, l2=35);
  }

  {
    color(c="orange")
      translate(v=[0, -50, 0]) {
        mortise(a1=8, a2=8, w=d_leg, l=w * 2, l1=20, l2=0, d=15);
      }
  }
}
