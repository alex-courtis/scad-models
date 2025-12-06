include <BOSL2/std.scad>

$fn = 200;

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
function skewed_rect(x, y, a1, a2) =
  let (
    d1 = y / 2 * tan(a1),
    d2 = y / 2 * tan(a2),
    Ax = -x / 2 - d1,
    Bx = -x / 2 + d1,
    Cx = x / 2 + d2,
    Dx = x / 2 - d2,
  ) Bx <= Cx && Ax <= Dx ?
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
  l1 = 30, // rail from mid shoulder edge, negative x
  l2 = 40, // rail from mid shoulder edge, positive x
  w = 20,
  d = 10,
  slot = 15, // width of the slot
  r = 0.2, // radius of cylinder cut into edges of slot
  a = 8,
  ratio = 7 / 18
) {

  x_tenon = slot / cos(a);

  tenon = skewed_rect(x=x_tenon, y=w, a1=a, a2=a);
  rail1 = skewed_rect(x=l1, y=w, a1=0, a2=a);
  rail2 = skewed_rect(x=l2, y=w, a1=a, a2=0);

  difference() {
    union() {
      if (rail1)
        translate(v=[-(l1 + x_tenon) / 2, 0, 0])
          linear_extrude(h=d, center=true)
            polygon(rail1);

      if (tenon)
        linear_extrude(h=d * ratio, center=true)
          polygon(tenon);

      if (rail2)
        translate(v=[(l2 + x_tenon) / 2, 0, 0])
          linear_extrude(h=d, center=true)
            polygon(rail2);
    }

    // edge tolerance
    if (r) {
      dx = slot / 2;
      dz = d * ratio / 2;
      if (rail1) {
        edge_cyl(a=a, dx=-dx, dz=dz, r=r);
        edge_cyl(a=a, dx=-dx, dz=-dz, r=r);
      }
      if (rail2) {
        edge_cyl(a=a, dx=dx, dz=dz, r=r);
        edge_cyl(a=a, dx=dx, dz=-dz, r=r);
      }
    }
  }
}

// origin at slot centre
module mortise(
  l1 = 30, // style from mid slot edge, negative x
  l2 = 40, // style from mid slot edge, positive x
  w = 15,
  d = 10,
  tenon = 20, // width of the tenon
  a = 8,
  r = 0.2, // radius of cylinder cut into edges of slot
  ratio = 7 / 18,
) {

  x_slot = tenon / cos(a);
  dx_slot = (x_slot - tenon) / 2;
  slot = skewed_rect(x=x_slot, y=w, a1=a, a2=a);

  x_style1 = l1 - dx_slot;
  style1 = skewed_rect(x=x_style1, y=w, a1=0, a2=a);

  x_style2 = l2 - dx_slot;
  style2 = skewed_rect(x=x_style2, y=w, a1=a, a2=0);

  z_wall = d / 2 * (1 - ratio);

  difference() {
    union() {

      // style1
      if (style1)
        translate(v=[-(x_style1 + x_slot) / 2, 0, 0])
          linear_extrude(h=d, center=true)
            polygon(style1);

      // slots
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
    if (r) {
      dx = x_slot / 2 - dx_slot;
      dz = d / 2 - z_wall;
      if (style1) {
        edge_cyl(a=a, dx=-dx, dz=dz, r=r);
        edge_cyl(a=a, dx=-dx, dz=-dz, r=r);
      }
      if (style2) {
        edge_cyl(a=a, dx=dx, dz=dz, r=r);
        edge_cyl(a=a, dx=dx, dz=-dz, r=r);
      }
    }
  }
}

a = 10;
d = 15;
r = 0.2;

ratio_mortise = 5 / 15;
echo(ratio_mortise=ratio_mortise);

ratio_tenon = (5 - 0.05) / 15;
echo(ratio_tenon=ratio_tenon);

render() {
  union() {
    translate(v=[0, 50, 0])
    // rotate(a=90 + a)
    {
      color(c="saddlebrown")
        tenon(
          slot=20,
          l1=0,
          l2=5,
          w=15,
          d=d,
          a=a,
          r=r,
          ratio=ratio_tenon,
        );
      translate(v=[30, 0, 0])
        color(c="chocolate")
          tenon(
            slot=20,
            l1=5,
            l2=10,
            w=15,
            d=d,
            a=a,
            r=r,
            ratio=ratio_tenon,
          );
    }

    color(c="tan")
      mortise(
        tenon=15,
        l1=10,
        l2=10,
        w=20,
        d=d,
        a=-a,
        r=r,
        ratio=ratio_mortise,
      );

    translate(v=[-29, 0, 0])
      color(c="goldenrod")
        mortise(
          tenon=15,
          l1=0,
          l2=5,
          w=20,
          d=d,
          a=-a,
          r=r,
          ratio=ratio_mortise,
        );
  }
}
