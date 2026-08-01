include <BOSL2/std.scad>
include <lib/geom.scad>

$fn = 400;

mount = "back"; // ["back", "front", "org"]

x = 125;
y = 70;
z = 101.3465;
a = 60;

y_extra = 13;
y_fill_extra = 6;
z_bottom_extra = 5;

y_less = 26;
y_fill_less = 17;
z_bottom_less = 10;

module extra_body_half() {
  translate(v=[0, -y_extra, 0]) {
    intersection() {
      translate(v=[0, -y + y_extra, z_bottom_extra])
        cube([x, y, z], center=true);
      import("steam-controller-holder-model.stl", center=true);
    }
  }
}

module extra_body() {
  hull() {
    extra_body_half();
    translate(v=[0, -(y + y_extra) / 2, 0])
      mirror(v=[0, 1, 0])
        translate(v=[0, (y + y_extra) / 2, 0])
          extra_body_half();
  }
}

module extra_fill() {
  translate(v=[0, -y_extra, 0]) {
    intersection() {
      translate(v=[0, -y + y_extra + y_fill_extra, -z + z_bottom_extra])
        cube([x, y, z], center=true);
      import("steam-controller-holder-model.stl", center=true);
    }
  }
}

module less_fill() {
  translate(v=[0, -y_less + y_fill_less, 0])
    intersection() {
      translate(v=[0, y - y_fill_less, -z + z_bottom_less])
        cube([x, y, z], center=true);
      import("steam-controller-holder-model.stl", center=true);
    }
}

module less_mask() {
  intersection() {
    translate(v=[0, y - y_less, -z + z_bottom_less])
      cube([x, y, z], center=true);
    import("steam-controller-holder-model.stl", center=true);
  }
}

module cord_cover() {
  x_cover = 52;
  y_cover = 60;
  dy_cover = 53.219;
  z_cover = 6;
  dz_cover = -2.645;
  y_cover_fill = 28.0;
  edge_cover = 5 + 1;
  y_gap = 21.9 + 0.101 - 1 + 5;

  rotate(a=a, v=[1, 0, 0]) {
    translate(v=[0, y_cover / 2 + dy_cover - y_cover_fill, dz_cover])
      difference() {
        cuboid(
          [x_cover, y_cover, z_cover],
          rounding=2.5,
          except=[
            FRONT,
          ],
        );
        translate(v=[0, y_cover / 2 - y_gap / 2 - edge_cover, 0])
          cuboid([x_cover - edge_cover * 2, y_gap, z_cover]);
      }
  }
}

module cord_hole() {
  translate(v=[0, -3.1, -45])
    cuboid(
      [15, 7.5, 40],
      rounding=2.5,
      except=[
        TOP,
      ],
    );
}

module mount_front() {
  color(c="green")
    extra_body();

  color(c="orange")
    extra_fill();

  color(c="yellow")
    less_fill();

  color(c="tan") {
    difference() {
      import("steam-controller-holder-model.stl", center=true);
      less_mask();
      cord_hole();
    }
  }

  color(c="steelblue")
    cord_cover();
}

module mount_back() {
  t_back = 8;
  w_back = 40;
  h_back = z - 1;
  dh_back = 8 / 2;

  // fits into body
  t_mid = 14.9;
  dt_mid = -1.8025;

  // fits into top
  t_top = 15;
  dt_top = dt_mid - 0.051;

  w_top = w_back;
  h_top = 16.3;
  dh_top = 0.62;
  r_top = 0.5;

  w_cord_hole = 14.15;
  t_cord_hole = 8.5;
  dt_cord_hole = -3.253 - 2.5 / 2;
  h_cord_hole = h_top;
  r_cord_hole = 2;

  z_top_rotated = 53.2182;

  module back(rounding) {
    translate(v=[0, y / 2 - t_back / 2, dh_back])
      cuboid(
        [w_back, t_back, h_back],
        rounding=rounding,
        edges=[
          FRONT,
        ],
      );
  }

  module top() {
    difference() {
      rotate(a=-a / 2, v=[1, 0, 0]) {
        translate(v=[0, dt_top, z_top_rotated - dh_top + h_top / 2]) {
          difference() {
            cuboid(
              size=[w_top, t_top, h_top],
              rounding=r_top,
              edges=[
                LEFT + TOP,
                RIGHT + TOP,
                FRONT + TOP,
              ]
            );
          }
        }
      }

      translate(v=[0, t_back, z / 2]) {
        back();
      }
    }
  }

  module cord_hole() {
    rotate(a=-a / 2, v=[1, 0, 0]) {
      translate(v=[0, dt_cord_hole, z_top_rotated - dh_top + h_top / 2]) {
        difference() {
          cuboid(
            size=[w_cord_hole, t_cord_hole, h_cord_hole + 0.01],
            rounding=r_cord_hole,
            edges=[
              LEFT + FRONT,
              LEFT + BACK,
              RIGHT + FRONT,
              RIGHT + BACK,
            ]
          );
        }
      }
    }
  }

  module clip_strengthener() {
    x_cover = 52;
    y_cover = 24;
    dy_cover = 53.219;
    z_cover = 6;
    dz_cover = -2.645;
    y_cover_fill = 28.0;

    rotate(a=a, v=[1, 0, 0]) {
      translate(v=[0, y_cover / 2 + dy_cover - y_cover_fill, dz_cover])
        difference() {
          cuboid(
            [x_cover, y_cover, z_cover],
          );
        }
    }
  }

  // intersection() {
  union() {
    difference() {
      union() {
        color(c="chocolate")
          import("steam-controller-holder-model.stl", center=true);

        back(rounding=2.5);

        top();

        clip_strengthener();
      }

      cord_hole();
    }
  }
}

module mount_raw() {
  color(c="darkgreen")
    import("steam-controller-holder-model.stl", center=true);
}

render() {
  if (mount == "front") {
    mount_front();
  } else if (mount == "back") {
    mount_back();
  } else if (mount == "org") {
    mount_raw();
  }
}
