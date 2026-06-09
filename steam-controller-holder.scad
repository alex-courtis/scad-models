include <BOSL2/std.scad>
include <lib/geom.scad>

$fn = 400;

x = 125;
y = 70;
z = 101.3465;

y_extra = 4;

y_bottom = 4;
z_bottom = 10;

module top_extra() {
  translate(v=[0, -y_extra, 0]) {
    intersection() {
      translate(v=[0, -y + y_extra, z_bottom])
        cube([x, y, z], center=true);
      import("steam-controller-holder-model.stl", center=true);
    }
  }
}

module bottom_extra() {
  translate(v=[0, -y_extra, 0]) {
    intersection() {
      translate(v=[0, -y + y_extra, -z + z_bottom])
        cube([x, y, z], center=true);
      import("steam-controller-holder-model.stl", center=true);
    }
  }
}

module bottom_fill() {
  y_fill = 8;
  dy_fill = 5;
  z_fill = 6;
  translate(v=[0, -dy_fill, 0]) {
    intersection() {
      translate(v=[0, -(y - y_fill) / 2 + dy_fill, -(z - z_fill) / 2])
        cube([x, y_fill, z_fill], center=true);
      import("steam-controller-holder-model.stl", center=true);
    }
  }
}

render() {
  // size test
  // difference() {
  //   color(c="red")
  //     import("steam-controller-holder-model.stl", center=true);
  //
  //   color(c="blue")
  //     cube([x, y, z], center=true);
  // }

  color(c="green") {
    hull() {
    top_extra();
    translate(v=[0, -(y + y_extra) / 2, 0])
      mirror(v=[0, 1, 0])
        translate(v=[0, (y + y_extra) / 2, 0])
          top_extra();
    }
  }

  color(c="orange")
    bottom_extra();

  color(c="pink")
    bottom_fill();

  color(c="brown")
    import("steam-controller-holder-model.stl", center=true);
}
