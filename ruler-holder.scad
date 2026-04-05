include <BOSL2/std.scad>
include <lib/geom.scad>

d_filament = 0.4; // [0.2:0.2:0.8]

/* [Inner Dimensions] */
inner = [
  4,
  280,
  34,
];

/* [Magnet Dimensions] */
magnet = [
  5 + 0.4,
  15 + 0.4,
  25 + 0.4,
];

/* [Outer Dimensions] */
t_wall = d_filament * 3;

l_cutout = 120;

outer = inner + [
  (magnet[0] + t_wall * 2) * 2,
  t_wall,
  t_wall * 2,
];

hollow = [
  (outer[0] - inner[0]) / 2 - t_wall,
  outer[1] - t_wall * 2,
  outer[2] - t_wall * 2,
];

$fn = 200; // [0:1:500]

module magnet_mask() {

  color(c="orange")
    translate(
      v=[
        magnet[0] / 2 + inner[0] / 2 + t_wall,
        0,
        0,
      ]
    )
      cube(magnet, center=true);
}

module magnet_enclosures() {
  enclosure = [magnet[0], magnet[1], outer[2] - t_wall * 2] + [t_wall, t_wall, 0];

  color(c="gray")
    translate(
      v=[
        enclosure[0] / 2 + inner[0] / 2 + t_wall,
        0,
        0,
      ]
    )
      cube(enclosure, center=true);
}

module hollow_mask() {
  translate(v=[(outer[0] - hollow[0]) / 2, 0, 0])
    cuboid(
      hollow,
      chamfer=hollow[0],
      edges=[LEFT],
    );
}

module holder() {

  difference() {
    color(c="steelblue")
      cuboid(
        outer,
        chamfer=t_wall / 2,
      );

    color(c="red")
      translate(v=[0, t_wall / 2, 0])
        cuboid(inner);

    color(c="pink") {
      hollow_mask();

      mirror(v=[1, 0, 0])
        hollow_mask();
    }
  }
}

render() {
  front_half(y=-95, s=outer[1] * 2)
    difference() {
      union() {
        holder();
        translate(v=[0, -115, 0])
          magnet_enclosures();
      }
      translate(v=[0, -115, 0]) {
        magnet_mask();
        translate(v=[0, 0, magnet[2]])
          magnet_mask();
      }
    }
}
