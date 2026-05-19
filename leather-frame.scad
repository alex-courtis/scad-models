include <BOSL2/std.scad>

d_filament = 0.4;
t_layer = 0.2;

l1_awl = 3.25;

gap_hole = 5;
gap_edge = 4;
a_hole = 45;

l_rib = 60;
w_rib = gap_edge * 2;
t_rib = 3.0;
d_rib = 50;
t1_rib = 0.8;
t2_rib = 2.0;
l_rib_hole = l1_awl;
w_rib_hole = 1.2;

$fn = 200;

module rib_mask() {
  // #cylinder(h=t_rib * 6, d=1, center=true);
  // #cuboid([1, 1, t_rib * 3]);
  cuboid([l_rib_hole, w_rib_hole, t_rib * 2]);
}

module rib_straight(flat) {

  difference() {
    if (flat)
      cuboid([l_rib, w_rib, t_rib]);
    else
      prismoid(
        size1=[l_rib, t1_rib],
        size2=[l_rib, t2_rib],
        h=w_rib,
        anchor=CENTER,
        orient=FRONT,
      );

    for (i = [-l_rib / 2:gap_hole:l_rib / 2]) {
      translate(v=[i, 0, 0])
        rotate(a=a_hole)
          rib_mask();
    }
  }
}

module rib_curved() {

  // round to a clean divisor of 90
  a_isoc = 2 * asin(gap_hole / d_rib);
  a = 90 / round(90 / a_isoc);

  h = gap_edge * 2 * sin(45);

  od1 = d_rib - h;
  id1 = od1 - 2 * t2_rib / sin(45);

  od2 = d_rib + h;
  id2 = od2 - 2 * t1_rib / sin(45);

  module straight(shift_dir) {
    translate(v=[-shift_dir * (id1 / 2 + t2_rib * sin(45)), 0, 0])
      rotate(a=90)
        prismoid(
          size1=[l_rib, t2_rib / sin(45)],
          size2=[l_rib, t1_rib / sin(45)],
          h=h,
          shift=[0, shift_dir * (t2_rib / sin(45) - t1_rib / sin(45) + od2 - od1) / 2],
        );
  }

  module curve() {
    back_half() {
      tube(
        h=h,
        id1=id1,
        od1=od1,
        id2=id2,
        od2=od2,
      );
      translate(v=[0, 0, -(h - t2_rib) / 2])
        cyl(
          h=t2_rib,
          d1=od1,
          d2=od1 + t2_rib / 2,
        );
    }
  }

  difference() {
    curve();

    for (i = [0:a:180]) {
      rotate(a=i)
        translate(v=[d_rib / 2, 0, 0])
          rotate(a=-45, v=[0, 1, 0])
            rotate(a=a_hole)
              rib_mask();
    }
  }

  difference() {
    union() {
      translate(v=[0, -l_rib / 2, -h / 2]) {
        straight(shift_dir=-1);
        straight(shift_dir=1);

        rotate(a=90)
          prismoid(
            size1=[l_rib, od1],
            size2=[l_rib, od1 + t2_rib * 2],
            h=t2_rib,
          );
      }
    }
    for (i = [0:gap_hole:l_rib - 1]) {
      translate(v=[0, -i, 0]) {
        translate(v=[d_rib / 2, 0, 0]) {
          rotate(a=-45, v=[0, 1, 0])
            rotate(a=a_hole)
              rib_mask();
        }
        translate(v=[-d_rib / 2, 0, 0]) {
          rotate(a=45, v=[0, 1, 0])
            rotate(a=a_hole)
              rib_mask();
        }
      }
    }
  }
}

render() {
  translate(v=[0, 0, 0])
    rib_curved();
  // translate(v=[-120, 0, 0])
  //   rib_straight(flat=true);
  // translate(v=[-200, 0, 0])
  //   rib_straight(flat=false);
}
