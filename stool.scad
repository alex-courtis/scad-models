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
 undef when not a convex polygon


          B-----------------------C   ^
         /       |               /    |
        /        |              /     |
       /         |             /      |
      /          |            /       |
     /-----------O-----------/        y
    /            |          /         |
|a1/             |      |a2/          |
| /              |      | /           |
|/               |      |/            |
A-----------------------D             -

<----------x----------->

*/
function skewed_rect0(x, y, a1, a2) =
  let (
    d1 = y / 2 * tan(a1),
    d2 = y / 2 * tan(a2),
    Ax = -x / 2 - d1,
    Bx = -x / 2 + d1,
    Cx = x / 2 + d2,
    Dx = x / 2 - d2,
  ) Bx < Cx && Ax < Dx ?
    [
      [Ax, -y / 2],
      [Bx, y / 2],
      [Cx, y / 2],
      [Dx, -y / 2],
    ]
  : undef;

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

// origin at tenon centre
module tenon(
  slot = w, // width of the slot
  l1 = l1, // rail from mid shoulder edge, negative x
  l2 = l2, // rail from mid shoulder edge, positive x
  w = w,
  d = d,
  a = a1,
  ratio = 7 / 18,
  l_gap = l_gap, // gap between shoulder and slot, half of this is removed from each
  d_gap = d_gap, // gap between cheeks, half of this is removed from the cheek
  r_edge = r_edge, // radius of cylinder cut into edges of slot
) {

  x_tenon = slot / cos(a);

  z_tenon = d * ratio - 2 * d_gap;

  tenon = skewed_rect0(x=x_tenon, y=w, a1=a, a2=a);
  rail1 = skewed_rect0(x=l1, y=w, a1=0, a2=a);
  rail2 = skewed_rect0(x=l2, y=w, a1=a, a2=0);

  difference() {
    union() {
      if (rail1)
        translate(v=[-(l1 + x_tenon) / 2, 0, 0])
          linear_extrude(h=d, center=true)
            polygon(rail1);

      if (tenon)
        linear_extrude(h=z_tenon, center=true)
          polygon(tenon);

      if (rail2)
        translate(v=[(l2 + x_tenon) / 2, 0, 0])
          linear_extrude(h=d, center=true)
            polygon(rail2);
    }

    // edge cuts
    if (r_edge) {
      dx = slot / 2;
      dz = z_tenon / 2;
      if (rail1) {
        edge_cyl(a=a, dx=-dx, dz=dz, r=r_edge);
        edge_cyl(a=a, dx=-dx, dz=-dz, r=r_edge);
      }
      if (rail2) {
        edge_cyl(a=a, dx=dx, dz=dz, r=r_edge);
        edge_cyl(a=a, dx=dx, dz=-dz, r=r_edge);
      }
    }
  }
}

// origin at slot centre
module mortise(
  tenon = w, // width of the tenon
  l1 = l1, // style from mid slot edge, negative x
  l2 = l2, // style from mid slot edge, positive x
  w = w,
  d = d,
  a = a1,
  ratio = 7 / 18,
  tenon_gap = l_gap, // gap between shoulders, half of this is removed from each shoulder
  d_gap = d_gap, // gap between cheeks, half of this is removed from the cheek
  r_edge = r_edge, // radius of cylinder cut into edges of slot
) {

  let (
    tenon = tenon + tenon_gap * 2,
    l1 = l1 > 0 ? l1 - tenon_gap : 0,
    l2 = l2 > 0 ? l2 - tenon_gap : 0,
  ) {
    x_slot = tenon / cos(a);
    dx_slot = (x_slot - tenon) / 2;
    slot = skewed_rect0(x=x_slot, y=w, a1=a, a2=a);

    x_style1 = l1 - dx_slot;
    style1 = skewed_rect0(x=x_style1, y=w, a1=0, a2=a);

    x_style2 = l2 - dx_slot;
    style2 = skewed_rect0(x=x_style2, y=w, a1=a, a2=0);

    z_wall = d / 2 * (1 - ratio);

    difference() {
      union() {

        // style1
        if (style1)
          translate(v=[-(x_style1 + x_slot) / 2, 0, 0])
            linear_extrude(h=d, center=true)
              polygon(style1);

        // slot body
        if (slot) {
          translate(v=[0, 0, -(d - z_wall) / 2])
            linear_extrude(h=z_wall, center=true)
              polygon(slot);
          translate(v=[0, 0, (d - z_wall) / 2])
            linear_extrude(h=z_wall, center=true)
              polygon(slot);
        }

        // style2
        if (style2) {
          translate(v=[(x_style2 + x_slot) / 2, 0, 0])
            linear_extrude(h=d, center=true)
              polygon(style2);
        }
      }

      // edge tolerance
      if (r_edge) {
        dx = x_slot / 2 - dx_slot;
        dz = d / 2 - z_wall;
        if (style1) {
          edge_cyl(a=a, dx=-dx, dz=dz, r=r_edge);
          edge_cyl(a=a, dx=-dx, dz=-dz, r=r_edge);
        }
        if (style2) {
          edge_cyl(a=a, dx=dx, dz=dz, r=r_edge);
          edge_cyl(a=a, dx=dx, dz=-dz, r=r_edge);
        }
      }
    }
  }
}

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
