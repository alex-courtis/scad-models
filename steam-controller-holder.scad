include <BOSL2/std.scad>
include <lib/geom.scad>

$fn = 400;

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

render() {
  color(c="green")
    extra_body();

  color(c="orange")
    extra_fill();

  color(c="yellow")
    less_fill();

  color(c="brown") {
    difference() {
      import("steam-controller-holder-model.stl", center=true);
      less_mask();
      cord_hole();
    }
  }

  color(c="steelblue")
    cord_cover();
}
