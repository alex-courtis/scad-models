include <BOSL2/std.scad>

$fn = 200;

/*
 Return poly ABCD
 empty when not a convex polygon


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
  : [];

// origin at tenon centre
module tenon(
  l1 = 30, // rail from mid shoulder edge, negative x
  l2 = 40, // rail from mid shoulder edge, positive x
  w = 20,
  d = 10,
  slot = 15, // width of the slot
  a = 8,
  ratio = 7 / 18
) {

  x_tenon = slot / cos(a);

  // rail1
  rail1 = skewed_rect(x=l1, y=w, a1=0, a2=a);
  if (rail1)
    translate(v=[-(l1 + x_tenon) / 2, 0, 0])
      linear_extrude(h=d, center=true)
        polygon(rail1);

  // tenon
  tenon = skewed_rect(x=x_tenon, y=w, a1=a, a2=a);
  if (tenon)
    linear_extrude(h=d * ratio, center=true)
      polygon(tenon);

  // rail2
  rail2 = skewed_rect(x=l2, y=w, a1=a, a2=0);
  if (rail2)
    translate(v=[(l2 + x_tenon) / 2, 0, 0])
      linear_extrude(h=d, center=true)
        polygon(rail2);
}

// origin at slot centre
module mortise(
  l1 = 30, // style from mid slot edge, negative x
  l2 = 40, // style from mid slot edge, positive x
  w = 15,
  d = 10,
  tenon = 20, // width of the tenon
  a = 8,
  ratio = 7 / 18
) {

  x_slot = tenon / cos(a);
  dx_slot = (x_slot - tenon) / 2;

  // style1
  x_style1 = l1 - dx_slot;
  style1 = skewed_rect(x=x_style1, y=w, a1=0, a2=a);
  if (style1)
    translate(v=[-(x_style1 + x_slot) / 2, 0, 0])
      linear_extrude(h=d, center=true)
        polygon(style1);

  // slots
  slot = skewed_rect(x=x_slot, y=w, a1=a, a2=a);
  if (slot) {
    z_wall = d / 2 * (1 - ratio);
    dz_wall = z_wall / 2 - d / 2;
    translate(v=[0, 0, -dz_wall])
      linear_extrude(h=z_wall, center=true)
        polygon(slot);
    translate(v=[0, 0, dz_wall])
      linear_extrude(h=z_wall, center=true)
        polygon(slot);
  }

  // style2
  x_style2 = l2 - dx_slot;
  style2 = skewed_rect(x=x_style2, y=w, a1=a, a2=0);
  if (style2)
    translate(v=[(x_style2 + x_slot) / 2, 0, 0])
      linear_extrude(h=d, center=true)
        polygon(style2);
}

a = 8;
d = 15;
ratio = 1 / 3;

render() {
  union() {
    translate(v=[0, 50, 0])
      rotate(a=90 + a)
        color(c="saddlebrown")
          tenon(
            slot=20,
            l1=0,
            l2=15,
            w=15,
            d=d,
            a=a,
            ratio=ratio,
          );

    color(c="tan")
      mortise(
        tenon=15,
        l1=10,
        l2=15,
        w=20,
        d=d,
        a=-a,
        ratio=ratio,
      );

    translate(v=[-30, 0, 0])
      color(c="tan")
        mortise(
          tenon=15,
          l1=0,
          l2=5,
          w=20,
          d=d,
          a=-a,
          ratio=ratio,
        );
  }
}
